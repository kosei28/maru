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
test "raw escape hatch" {
  assert_eq(from_json({ "x": 1 }).raw().stringify(), "{\"x\":1}")
}
