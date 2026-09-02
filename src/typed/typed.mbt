///|
using @error {type Path, type Invalid, err}

///|
/// A converted value that still carries its JSON path.
struct Typed[T] {
  val : T
  path : Path
}

///|
/// Unwrap the converted value.
pub fn[T] Typed::value(self : Typed[T]) -> T {
  self.val
}

///|
pub fn[T] Typed::new(val : T, path : Path) -> Typed[T] {
  { val, path, }
}

///|
/// Require `self == expected`.
pub fn[T : Eq + Show] Typed::eq(
  self : Typed[T],
  expected : T,
) -> Typed[T] raise Invalid {
  if self.val == expected {
    self
  } else {
    err(self.path, "must be \{expected}")
  }
}

///|
/// Apply a custom predicate. The message is used when it returns `false`.
pub fn[T] Typed::refine(
  self : Typed[T],
  predicate : (T) -> Bool,
  message : String,
) -> Typed[T] raise Invalid {
  if predicate(self.val) {
    self
  } else {
    err(self.path, message)
  }
}
