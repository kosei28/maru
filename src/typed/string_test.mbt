///|
test "string content checks" {
  assert_eq(from_json("hello").string().starts_with("he").value(), "hello")
  assert_eq(from_json("hello").string().starts_with("hello").value(), "hello")
  assert_eq(from_json("hello").string().ends_with("lo").value(), "hello")
  assert_eq(from_json("hello").string().includes("ell").value(), "hello")
  assert_eq(from_json("hello").string().lowercase().value(), "hello")
  assert_eq(from_json("").string().lowercase().uppercase().value(), "")
  assert_eq(from_json("123").string().lowercase().uppercase().value(), "123")
  assert_eq(from_json("HELLO").string().uppercase().value(), "HELLO")
  assert_eq(from_json("abc").string().regex("^[a-z]+$").value(), "abc")
  assert_eq(from_json("1abc2").string().regex("[a-z]+").value(), "1abc2")
  assert_invalid(
    () => from_json("hello").string().starts_with("x").value(),
    "must start with x",
  )
  assert_invalid(
    () => from_json("hello").string().ends_with("x").value(),
    "must end with x",
  )
  assert_invalid(
    () => from_json("hello").string().includes("x").value(),
    "must include x",
  )
  assert_invalid(
    () => from_json("Hello").string().lowercase().value(),
    "must be lowercase",
  )
  assert_invalid(
    () => from_json("Hello").string().uppercase().value(),
    "must be uppercase",
  )
  assert_invalid(
    () => from_json("abc1").string().regex("^[a-z]+$").value(),
    "must match pattern",
  )
  assert_invalid(
    () => from_json("123").string().regex("[a-z]+").value(),
    "must match pattern",
  )
}
