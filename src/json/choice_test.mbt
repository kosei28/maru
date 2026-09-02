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
