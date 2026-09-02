///|
/// Types that have a length, used by `nonempty`, `min_len`, `max_len`, and `len`.
pub(open) trait Length {
  fn length(Self) -> Int
}

///|
pub impl Length for String with fn length(self) {
  self.length()
}

///|
pub impl[T] Length for Array[T] with fn length(self) {
  self.length()
}

///|
/// Reject empty strings and arrays.
pub fn[T : Length] Typed::nonempty(self : Typed[T]) -> Typed[T] raise Invalid {
  expect_nonempty(self.path, Length::length(self.val))
  self
}

///|
/// Require a minimum length for strings and arrays.
pub fn[T : Length] Typed::min_len(
  self : Typed[T],
  n : Int,
) -> Typed[T] raise Invalid {
  expect_min_len(self.path, Length::length(self.val), n)
  self
}

///|
/// Require a maximum length for strings and arrays.
pub fn[T : Length] Typed::max_len(
  self : Typed[T],
  n : Int,
) -> Typed[T] raise Invalid {
  expect_max_len(self.path, Length::length(self.val), n)
  self
}

///|
/// Require an exact length for strings and arrays.
pub fn[T : Length] Typed::len(
  self : Typed[T],
  n : Int,
) -> Typed[T] raise Invalid {
  if Length::length(self.val) == n {
    self
  } else {
    err(self.path, "length must be \{n}")
  }
}

///|
fn expect_nonempty(path : Path, len : Int) -> Unit raise Invalid {
  if len <= 0 {
    err(path, "must not be empty")
  }
}

///|
fn expect_min_len(path : Path, len : Int, n : Int) -> Unit raise Invalid {
  if len < n {
    err(path, "length must be at least \{n}")
  }
}

///|
fn expect_max_len(path : Path, len : Int, n : Int) -> Unit raise Invalid {
  if len > n {
    err(path, "length must be at most \{n}")
  }
}
