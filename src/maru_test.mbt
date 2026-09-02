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
  assert_eq(value(true).bool().value(), true)
  assert_eq(value(false).bool().value(), false)
  assert_eq(value(42).int().value(), 42)
  assert_eq(value(42).int64().value(), 42L)
  assert_eq(value(1.5).double().value(), 1.5)
  assert_eq(value("hello").string().value(), "hello")
  value(null).null()
}

///|
test "object fields" {
  let json : Json = {
    "name": "Ada",
    "email": "ada@example.com",
    "age": 36,
    "rating": 4.5,
  }
  assert_eq(User::parse(value(json)), {
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
  assert_eq(User::parse(value(present)).nickname, Some("ada"))
  assert_true(value({}).object().optional_field("nickname") is None)
}

///|
test "optional null is some" {
  assert_invalid(
    () => {
      value({ "nickname": null })
      .object()
      .optional_field("nickname")
      .map(v => v.string().value())
    },
    "nickname: expected string, got null",
  )
}

///|
test "array map" {
  let scores = value({ "scores": [10.0, 20.5, 100.0] })
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
      value(json)
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
    () => value({ "x": 1 }).object().field("y").int().value(),
    "y: missing field",
  )
}

///|
test "type errors" {
  assert_invalid(
    () => value("nope").int().value(),
    "expected integer, got string",
  )
  assert_invalid(() => value(1.5).int().value(), "expected integer")
  assert_invalid(
    () => value(true).string().value(),
    "expected string, got boolean",
  )
  assert_invalid(() => value([]).object(), "expected object, got array")
}

///|
test "string checks" {
  assert_eq(
    value("abc").string().nonempty().min_len(2).max_len(5).value(),
    "abc",
  )
  assert_invalid(
    () => value("").string().nonempty().value(),
    "must not be empty",
  )
  assert_invalid(
    () => value("ab").string().min_len(3).value(),
    "length must be at least 3",
  )
  assert_invalid(
    () => value("abcd").string().max_len(3).value(),
    "length must be at most 3",
  )
  assert_eq(
    value("ada@example.com").string().email().value(),
    "ada@example.com",
  )
  assert_invalid(
    () => value("not-an-email").string().email().value(),
    "invalid email",
  )
}

///|
test "number checks" {
  assert_eq(value(10).int().min(0).max(20).range(0, 20).value(), 10)
  assert_invalid(() => value(-1).int().min(0).value(), "must be at least 0")
  assert_invalid(() => value(21).int().max(20).value(), "must be at most 20")
  assert_invalid(
    () => value(151).int().range(0, 150).value(),
    "must be between 0 and 150",
  )
  assert_invalid(() => value(2147483648.0).int().value(), "integer overflow")
}

///|
test "refine" {
  assert_eq(
    value(4).int().refine(fn(n) { n % 2 == 0 }, "must be even").value(),
    4,
  )
  assert_invalid(
    () => value(3).int().refine(fn(n) { n % 2 == 0 }, "must be even").value(),
    "must be even",
  )
}

///|
test "first_of" {
  fn parse_id(v : Value) -> String raise Invalid {
    first_of(v, [v => v.string().value(), v => v.int().value().to_string()])
  }

  assert_eq(parse_id(value("abc")), "abc")
  assert_eq(parse_id(value(12)), "12")
  assert_invalid(() => parse_id(value(true)), "no matching parser")
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

  assert_eq(parse_nickname(value(null)), None)
  assert_eq(parse_nickname(value("ada")), Some("ada"))
}

///|
test "raw escape hatch" {
  assert_eq(value({ "x": 1 }).raw().stringify(), "{\"x\":1}")
}

///|
test "array nonempty" {
  assert_invalid(
    () => value([]).array().nonempty().value(),
    "must not be empty",
  )
  assert_eq(value([1]).array().nonempty().value().length(), 1)
}
