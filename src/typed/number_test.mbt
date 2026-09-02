///|
test "number checks" {
  assert_eq(from_json(10).int().min(0).max(20).range(0, 20).value(), 10)
  assert_eq(from_json(0).int().min(0).range(0, 20).value(), 0)
  assert_eq(from_json(20).int().max(20).range(0, 20).value(), 20)
  assert_invalid(() => from_json(-1).int().min(0).value(), "must be at least 0")
  assert_invalid(
    () => from_json(21).int().max(20).value(),
    "must be at most 20",
  )
  assert_invalid(
    () => from_json(-1).int().range(0, 150).value(),
    "must be between 0 and 150",
  )
  assert_invalid(
    () => from_json(151).int().range(0, 150).value(),
    "must be between 0 and 150",
  )
  assert_eq(from_json(5).int().gt(4).lt(6).value(), 5)
  assert_eq(
    from_json(1.5).double().min(1.0).max(2.0).range(1.0, 2.0).value(),
    1.5,
  )
  assert_eq(from_json(1).int().positive().value(), 1)
  assert_eq(from_json(-1).int().negative().value(), -1)
  assert_eq(from_json(0).int().nonnegative().nonpositive().value(), 0)
  assert_eq(from_json(10).int().multiple_of(5).value(), 10)
  assert_eq(from_json(-10).int().multiple_of(5).value(), -10)
  assert_eq(from_json(1.5).double().gt(1.0).value(), 1.5)
  assert_eq(from_json(6.0).double().multiple_of(2.0).positive().value(), 6.0)
  assert_eq(from_json(-1.5).double().negative().value(), -1.5)
  assert_eq(from_json(0.0).double().nonnegative().nonpositive().value(), 0.0)
  assert_eq(from_json(3).int64().positive().multiple_of(3L).value(), 3L)
  assert_eq(from_json(-3).int64().negative().value(), -3L)
  assert_eq(from_json(0).int64().nonnegative().nonpositive().value(), 0L)
  assert_invalid(
    () => from_json(5).int().gt(5).value(),
    "must be greater than 5",
  )
  assert_invalid(() => from_json(5).int().lt(5).value(), "must be less than 5")
  assert_invalid(
    () => from_json(0).int().positive().value(),
    "must be positive",
  )
  assert_invalid(
    () => from_json(0).int().negative().value(),
    "must be negative",
  )
  assert_invalid(
    () => from_json(-1).int().nonnegative().value(),
    "must be non-negative",
  )
  assert_invalid(
    () => from_json(1).int().nonpositive().value(),
    "must be non-positive",
  )
  assert_invalid(
    () => from_json(0.0).double().positive().value(),
    "must be positive",
  )
  assert_invalid(
    () => from_json(1).int64().negative().value(),
    "must be negative",
  )
  assert_invalid(
    () => from_json(10).int().multiple_of(3).value(),
    "must be a multiple of 3",
  )
  assert_invalid(
    () => from_json(10).int().multiple_of(0).value(),
    "must be a multiple of 0",
  )
  assert_invalid(
    () => from_json(6.0).double().multiple_of(4.0).value(),
    "must be a multiple of 4",
  )
}
