///|
struct User {
  name : String
  email : String
  age : Int
  rating : Double
  nickname : String?
} derive(Eq, @debug.Debug)

///|
fn User::parse(value : Value) -> User raise Invalid {
  let obj = value.object()
  {
    name: obj.field("name").string().nonempty().value(),
    email: obj.field("email").string().email().value(),
    age: obj.field("age").int().range(0, 150).value(),
    rating: obj.field("rating").double().range(0.0, 5.0).value(),
    nickname: obj
    .optional_field("nickname")
    .map(v => v.string().max_len(30).value()),
  }
}

///|
fn[T] assert_invalid(f : () -> T raise Invalid, message : String) -> Unit raise {
  try {
    f() |> ignore
    fail("expected Invalid, got success")
  } catch {
    e => assert_eq(e.to_string(), message)
  }
}

///|
test "primitives" {
  assert_eq(from_json(true).bool().value(), true)
  assert_eq(from_json(false).bool().value(), false)
  assert_eq(from_json(42).int().value(), 42)
  assert_eq(from_json(42).int64().value(), 42L)
  assert_eq(from_json(1.5).double().value(), 1.5)
  assert_eq(from_json("hello").string().value(), "hello")
  from_json(null).null()
}

///|
test "object fields" {
  let json : Json = {
    "name": "Ada",
    "email": "ada@example.com",
    "age": 36,
    "rating": 4.5,
  }
  assert_eq(User::parse(from_json(json)), {
    name: "Ada",
    email: "ada@example.com",
    age: 36,
    rating: 4.5,
    nickname: None,
  })
}

///|
test "optional field" {
  let present : Json = {
    "name": "Ada",
    "email": "ada@example.com",
    "age": 36,
    "rating": 4.5,
    "nickname": "ada",
  }
  assert_eq(User::parse(from_json(present)).nickname, Some("ada"))
  assert_true(from_json({}).object().optional_field("nickname") is None)
}

///|
test "optional null is some" {
  assert_invalid(
    () => {
      from_json({ "nickname": null })
      .object()
      .optional_field("nickname")
      .map(v => v.string().value())
    },
    "nickname: expected string, got null",
  )
}

///|
test "array map" {
  let scores = from_json({ "scores": [10.0, 20.5, 100.0] })
    .object()
    .field("scores")
    .array()
    .map(v => v.double().range(0.0, 100.0).value())
    .value()
  assert_eq(scores, [10.0, 20.5, 100.0])
}

///|
test "path in nested errors" {
  let json : Json = {
    "users": [
      { "email": "a@b.com" },
      { "email": "b@c.com" },
      { "email": "not-an-email" },
    ],
  }
  assert_invalid(
    () => {
      from_json(json)
      .object()
      .field("users")
      .array()
      .map(v => v.object().field("email").string().email().value())
      .value()
    },
    "users[2].email: invalid email",
  )
}

///|
test "missing field path" {
  assert_invalid(
    () => from_json({ "x": 1 }).object().field("y").int().value(),
    "y: missing field",
  )
}

///|
test "type errors" {
  assert_invalid(
    () => from_json("nope").int().value(),
    "expected integer, got string",
  )
  assert_invalid(() => from_json(1.5).int().value(), "expected integer")
  assert_invalid(
    () => from_json(true).string().value(),
    "expected string, got boolean",
  )
  assert_invalid(() => from_json([]).object(), "expected object, got array")
}

///|
test "string checks" {
  assert_eq(
    from_json("abc").string().nonempty().min_len(2).max_len(5).value(),
    "abc",
  )
  assert_invalid(
    () => from_json("").string().nonempty().value(),
    "must not be empty",
  )
  assert_invalid(
    () => from_json("ab").string().min_len(3).value(),
    "length must be at least 3",
  )
  assert_invalid(
    () => from_json("abcd").string().max_len(3).value(),
    "length must be at most 3",
  )
  assert_eq(
    from_json("ada@example.com").string().email().value(),
    "ada@example.com",
  )
  assert_invalid(
    () => from_json("not-an-email").string().email().value(),
    "invalid email",
  )
}

///|
test "number checks" {
  assert_eq(from_json(10).int().min(0).max(20).range(0, 20).value(), 10)
  assert_invalid(() => from_json(-1).int().min(0).value(), "must be at least 0")
  assert_invalid(
    () => from_json(21).int().max(20).value(),
    "must be at most 20",
  )
  assert_invalid(
    () => from_json(151).int().range(0, 150).value(),
    "must be between 0 and 150",
  )
  assert_invalid(
    () => from_json(2147483648.0).int().value(),
    "integer overflow",
  )
}

///|
test "refine" {
  assert_eq(
    from_json(4).int().refine(fn(n) { n % 2 == 0 }, "must be even").value(),
    4,
  )
  assert_invalid(
    () => {
      from_json(3).int().refine(fn(n) { n % 2 == 0 }, "must be even").value()
    },
    "must be even",
  )
}

///|
test "first_of" {
  fn parse_id(v : Value) -> String raise Invalid {
    first_of(v, [v => v.string().value(), v => v.int().value().to_string()])
  }

  assert_eq(parse_id(from_json("abc")), "abc")
  assert_eq(parse_id(from_json(12)), "12")
  assert_invalid(() => parse_id(from_json(true)), "no matching parser")
}

///|
test "nullable via first_of" {
  fn parse_nickname(v : Value) -> String? raise Invalid {
    first_of(v, [
      v => {
        v.null()
        None
      },
      v => Some(v.string().value()),
    ])
  }

  assert_eq(parse_nickname(from_json(null)), None)
  assert_eq(parse_nickname(from_json("ada")), Some("ada"))
}

///|
test "raw escape hatch" {
  assert_eq(from_json({ "x": 1 }).raw().stringify(), "{\"x\":1}")
}

///|
test "array nonempty" {
  assert_invalid(
    () => from_json([]).array().nonempty().value(),
    "must not be empty",
  )
  assert_eq(from_json([1]).array().nonempty().value().length(), 1)
}
