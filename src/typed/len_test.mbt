///|
test "string length" {
  assert_eq(
    from_json("abc").string().nonempty().min_len(2).max_len(5).len(3).value(),
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
  assert_invalid(
    () => from_json("ab").string().len(3).value(),
    "length must be 3",
  )
}

///|
test "array length" {
  assert_eq(from_json([1]).array().nonempty().value().length(), 1)
  assert_eq(
    from_json([1, 2, 3]).array().min_len(2).max_len(5).len(3).value().length(),
    3,
  )
  assert_invalid(
    () => from_json([]).array().nonempty().value(),
    "must not be empty",
  )
  assert_invalid(
    () => from_json([1]).array().min_len(2).value(),
    "length must be at least 2",
  )
  assert_invalid(
    () => from_json([1, 2, 3]).array().max_len(2).value(),
    "length must be at most 2",
  )
  assert_invalid(
    () => from_json([1]).array().len(2).value(),
    "length must be 2",
  )
}
