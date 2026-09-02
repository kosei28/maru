# maru

[日本語](README.ja.mbt.md)

A minimal MoonBit validation library that constructs a typed value while validating, without holding a schema as a value.

```mbt check
///|
test {
  let json : Json = { "name": "Ada", "age": 36 }
  let obj = @maru.from_json(json).object()
  let name = obj.field("name").string().nonempty().value()
  let age = obj.field("age").int().range(0, 150).value()
  assert_eq(name, "Ada")
  assert_eq(age, 36)
}
```

## Install

```bash
moon add kosei28/maru
```

Then import it in `moon.pkg`:

```text
import {
  "kosei28/maru"
}
```

## Design

- No schema-as-value
- No validator builder or delayed evaluation
- Keep fetching, type checks, and value checks separate
- Propagate errors with MoonBit `raise`
- maru types are thin wrappers that only hold a value and a path
- Start with `from_json` to wrap JSON as a `Value`
- Finish with `.value()` to unwrap to a plain MoonBit value
- Parse unsupported types yourself via `Value::raw()`

## Model

Raw `Json`, object fields, and array elements are all the same `Value`.

```mbt check
///|
test {
  let value = @maru.from_json({ "ok": true })
  assert_eq(value.object().field("ok").bool().value(), true)
}
```

```text
value.null()
value.bool()
value.int()
value.int64()
value.double()
value.string()
value.array()
value.object()
```

## Type conversion and checks

After converting to a primitive, the result is `Checked[T]` and still carries a path.

```text
Value
  ↓ int()
Checked[Int]
  ↓ range(...)
Checked[Int]
  ↓ value()
Int
```

Main checks:

```text
.nonempty()
.min_len(n)
.max_len(n)
.email()

.min(n)
.max(n)
.range(min, max)

.refine(predicate, message)
```

On failure, maru `raise`s `@maru.Invalid`.
The message includes the path where it failed.

```text
users[2].email: invalid email
```

## Building a struct

```moonbit nocheck
///|
fn User::parse(value : @maru.Value) -> User raise @maru.Invalid {
  let obj = value.object()
  User::{
    name: obj.field("name").string().nonempty().value(),
    email: obj.field("email").string().email().value(),
    age: obj.field("age").int().range(0, 150).value(),
    rating: obj.field("rating").double().range(0.0, 5.0).value(),
    nickname: obj
    .optional_field("nickname")
    .map(v => v.string().max_len(30).value()),
  }
}
```

From the top level, call `User::parse(@maru.from_json(json))`.

## Objects

Fetching a field and checking its type are separate.

```text
Object
  ↓ field("name")
Value
  ↓ string()
Checked[String]
```

- `field` is required. A missing key is an error
- `optional_field` returns `None` only when the key is absent

```mbt check
///|
test {
  let obj = @maru.from_json({ "name": "Ada" }).object()
  let nickname = obj
    .optional_field("nickname")
    .map(v => v.string().max_len(30).value())
  assert_eq(nickname, None)
}
```

## Arrays

Array elements are `Value`s as well.

```mbt check
///|
test {
  let scores = @maru.from_json({ "scores": [10.0, 99.5] })
    .object()
    .field("scores")
    .array()
    .map(v => v.double().range(0.0, 100.0).value())
    .value()
  assert_eq(scores, [10.0, 99.5])
}
```

## Multiple candidates

`first_of` applies parsers to the same `Value` in order and returns the first success.

```mbt check
///|
test {
  let id = @maru.first_of(@maru.from_json(7), [
    v => v.string().value(),
    v => v.int().value().to_string(),
  ])
  assert_eq(id, "7")
}
```

nullable values can be written the same way.

```mbt check
///|
test {
  let nickname : String? = @maru.first_of(@maru.from_json(null), [
    v => { v.null(); None },
    v => Some(v.string().value()),
  ])
  assert_eq(nickname, None)
}
```

## Raw JSON

`Value.raw()` is the escape hatch for types maru does not convert directly.
`Checked[T]` has no `raw()`.

```text
from_json(json)    -> Value
Value.raw()        -> Json
Checked[T].value() -> T
```
