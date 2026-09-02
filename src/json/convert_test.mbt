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
  assert_invalid(
    () => from_json(2147483648.0).int().value(),
    "integer overflow",
  )
  assert_invalid(() => from_json(1.0e20).int64().value(), "integer overflow")
}
