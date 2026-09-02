///|
using @error {type Invalid}

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
test {
  let json : Json = { "name": "Ada", "age": 36 }
  let obj = from_json(json).object()
  let name = obj.field("name").string().nonempty().value()
  let age = obj.field("age").int().range(0, 150).value()
  assert_eq(name, "Ada")
  assert_eq(age, 36)
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
