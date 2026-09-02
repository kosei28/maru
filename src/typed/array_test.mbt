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
test "unique" {
  assert_eq(
    from_json([1, 2, 3]).array().map(v => v.int().value()).unique().value(),
    [1, 2, 3],
  )
  assert_eq(from_json([]).array().map(v => v.int().value()).unique().value(), [])
  assert_invalid(
    () => from_json([1, 1]).array().map(v => v.int().value()).unique().value(),
    "must not contain duplicates",
  )
  assert_invalid(
    () => {
      from_json([1, 2, 1]).array().map(v => v.int().value()).unique().value()
    },
    "must not contain duplicates",
  )
}
