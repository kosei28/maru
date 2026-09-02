///|
test "email format" {
  assert_string_ok("ada@example.com", v => v.email())
  assert_string_ok("a.b+tag@example.co.uk", v => v.email())
  assert_invalid(
    () => from_json("not-an-email").string().email().value(),
    "invalid email",
  )
  assert_invalid(
    () => from_json("ada@example").string().email().value(),
    "invalid email",
  )
  assert_invalid(
    () => from_json("@example.com").string().email().value(),
    "invalid email",
  )
  assert_invalid(
    () => from_json("ada@.example.com").string().email().value(),
    "invalid email",
  )
  assert_invalid(
    () => from_json("ada@example.com.").string().email().value(),
    "invalid email",
  )
  assert_invalid(
    () => from_json("ada@exam ple.com").string().email().value(),
    "invalid email",
  )
}

///|
test "url format" {
  assert_string_ok("https://example.com", v => v.url())
  assert_string_ok("http://localhost:8080/path?q=1", v => v.url())
  assert_string_ok("mailto:ada@example.com", v => v.url())
  assert_invalid(
    () => from_json("example.com").string().url().value(),
    "invalid url",
  )
  assert_invalid(() => from_json("http:").string().url().value(), "invalid url")
  assert_invalid(
    () => from_json("https://exam ple.com").string().url().value(),
    "invalid url",
  )
  assert_invalid(
    () => from_json("1https://example.com").string().url().value(),
    "invalid url",
  )
}

///|
test "uuid format" {
  assert_string_ok("550e8400-e29b-41d4-a716-446655440000", v => v.uuid())
  assert_string_ok("550E8400-E29B-41D4-A716-446655440000", v => v.uuid())
  assert_invalid(
    () => from_json("not-a-uuid").string().uuid().value(),
    "invalid uuid",
  )
  assert_invalid(
    () => from_json("550e8400e29b41d4a716446655440000").string().uuid().value(),
    "invalid uuid",
  )
  assert_invalid(
    () => {
      from_json("550e8400-e29b-41d4-a716-44665544000g").string().uuid().value()
    },
    "invalid uuid",
  )
}

///|
test "ipv4 format" {
  assert_string_ok("0.0.0.0", v => v.ipv4())
  assert_string_ok("192.0.2.1", v => v.ipv4())
  assert_string_ok("255.255.255.255", v => v.ipv4())
  assert_invalid(
    () => from_json("192.0.2.256").string().ipv4().value(),
    "invalid ipv4",
  )
  assert_invalid(
    () => from_json("192.0.2").string().ipv4().value(),
    "invalid ipv4",
  )
  assert_invalid(
    () => from_json("192.0.2.01").string().ipv4().value(),
    "invalid ipv4",
  )
  assert_invalid(
    () => from_json("192.0..1").string().ipv4().value(),
    "invalid ipv4",
  )
}

///|
test "ipv6 format" {
  assert_string_ok("2001:0db8:85a3:0000:0000:8a2e:0370:7334", v => v.ipv6())
  assert_string_ok("2001:db8::1", v => v.ipv6())
  assert_string_ok("::1", v => v.ipv6())
  assert_string_ok("1::", v => v.ipv6())
  assert_string_ok("::", v => v.ipv6())
  assert_string_ok("::ffff:192.0.2.1", v => v.ipv6())
  assert_invalid(
    () => from_json("1::2::3").string().ipv6().value(),
    "invalid ipv6",
  )
  assert_invalid(
    () => from_json(":::1").string().ipv6().value(),
    "invalid ipv6",
  )
  assert_invalid(
    () => from_json("gggg::1").string().ipv6().value(),
    "invalid ipv6",
  )
  assert_invalid(
    () => from_json("1:2:3:4:5:6:7").string().ipv6().value(),
    "invalid ipv6",
  )
  assert_invalid(
    () => from_json("::ffff:192.0.2.256").string().ipv6().value(),
    "invalid ipv6",
  )
}

///|
test "date format" {
  assert_string_ok("2024-02-29", v => v.date())
  assert_string_ok("2000-02-29", v => v.date())
  assert_string_ok("2024-04-30", v => v.date())
  assert_invalid(
    () => from_json("2023-02-29").string().date().value(),
    "invalid date",
  )
  assert_invalid(
    () => from_json("1900-02-29").string().date().value(),
    "invalid date",
  )
  assert_invalid(
    () => from_json("2024-04-31").string().date().value(),
    "invalid date",
  )
  assert_invalid(
    () => from_json("2024-13-01").string().date().value(),
    "invalid date",
  )
  assert_invalid(
    () => from_json("2024/02/29").string().date().value(),
    "invalid date",
  )
}

///|
test "time format" {
  assert_string_ok("00:00", v => v.time())
  assert_string_ok("23:59:59", v => v.time())
  assert_string_ok("23:59:59.5", v => v.time())
  assert_invalid(
    () => from_json("24:00:00").string().time().value(),
    "invalid time",
  )
  assert_invalid(
    () => from_json("23:59:60").string().time().value(),
    "invalid time",
  )
  assert_invalid(
    () => from_json("9:00").string().time().value(),
    "invalid time",
  )
  assert_invalid(
    () => from_json("23:59:59.").string().time().value(),
    "invalid time",
  )
}

///|
test "datetime format" {
  assert_string_ok("2024-01-02T03:04:05", v => v.datetime())
  assert_string_ok("2024-01-02T03:04:05Z", v => v.datetime())
  assert_string_ok("2024-01-02T03:04:05+09:00", v => v.datetime())
  assert_string_ok("2024-01-02T03:04:05-09:00", v => v.datetime())
  assert_invalid(
    () => from_json("2024-01-02 03:04:05").string().datetime().value(),
    "invalid datetime",
  )
  assert_invalid(
    () => from_json("2024-01-02T24:00:00Z").string().datetime().value(),
    "invalid datetime",
  )
  assert_invalid(
    () => from_json("2024-01-02T03:04:05+25:00").string().datetime().value(),
    "invalid datetime",
  )
}

///|
test "base64 format" {
  assert_string_ok("YWJj", v => v.base64())
  assert_string_ok("YQ==", v => v.base64())
  assert_string_ok("YWI=", v => v.base64())
  assert_string_ok("", v => v.base64())
  assert_invalid(
    () => from_json("abc!").string().base64().value(),
    "invalid base64",
  )
  assert_invalid(
    () => from_json("YQ=").string().base64().value(),
    "invalid base64",
  )
  assert_invalid(
    () => from_json("YQ===").string().base64().value(),
    "invalid base64",
  )
  assert_invalid(
    () => from_json("YQ=A").string().base64().value(),
    "invalid base64",
  )
}
