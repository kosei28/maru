///|
using @json {from_json}

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
fn assert_string_ok(
  s : String,
  f : (Typed[String]) -> Typed[String] raise Invalid,
) -> Unit raise {
  assert_eq(f(from_json(s.to_json()).string()).value(), s)
}

///|
test "eq" {
  assert_eq(from_json("red").string().eq("red").value(), "red")
  assert_eq(from_json(7).int().eq(7).value(), 7)
  assert_eq(from_json(true).bool().eq(true).value(), true)
  assert_invalid(
    () => from_json("blue").string().eq("red").value(),
    "must be red",
  )
  assert_invalid(() => from_json(1).int().eq(2).value(), "must be 2")
}

///|
test "refine" {
  assert_eq(
    from_json(4).int().refine(fn(n) { n % 2 == 0 }, "must be even").value(),
    4,
  )
  assert_invalid(
    () => {
      from_json(3).int().refine(fn(n) { n % 2 == 0 }, "must be even").value()
    },
    "must be even",
  )
}
