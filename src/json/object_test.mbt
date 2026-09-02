///|
test "optional field" {
  assert_true(from_json({}).object().optional_field("nickname") is None)
  assert_eq(
    from_json({ "nickname": "ada" })
    .object()
    .optional_field("nickname")
    .map(v => v.string().value()),
    Some("ada"),
  )
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
test "missing field path" {
  assert_invalid(
    () => from_json({ "x": 1 }).object().field("y").int().value(),
    "y: missing field",
  )
}

///|
test "object type error" {
  assert_invalid(() => from_json([]).object(), "expected object, got array")
}
