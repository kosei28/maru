///|
/// A successfully converted value that still carries its JSON path.
struct Checked[T] {
  val : T
  path : Path
}

///|
/// Types that have a length, used by `nonempty`, `min_len`, and `max_len`.
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
/// Unwrap the converted value.
pub fn[T] Checked::value(self : Checked[T]) -> T {
  self.val
}

///|
/// Map each array element. Errors keep the element's path.
pub fn[A, B] Checked::map(
  self : Checked[Array[A]],
  f : (A) -> B raise?,
) -> Checked[Array[B]] raise? {
  { val: self.val.map(f), path: self.path, }
}

///|
/// Reject empty strings and arrays.
pub fn[T : Length] Checked::nonempty(
  self : Checked[T],
) -> Checked[T] raise Invalid {
  expect_nonempty(self.path, Length::length(self.val))
  self
}

///|
/// Require a minimum length for strings and arrays.
pub fn[T : Length] Checked::min_len(
  self : Checked[T],
  n : Int,
) -> Checked[T] raise Invalid {
  expect_min_len(self.path, Length::length(self.val), n)
  self
}

///|
/// Require a maximum length for strings and arrays.
pub fn[T : Length] Checked::max_len(
  self : Checked[T],
  n : Int,
) -> Checked[T] raise Invalid {
  expect_max_len(self.path, Length::length(self.val), n)
  self
}

///|
/// Require a string to look like an email address.
pub fn Checked::email(self : Checked[String]) -> Checked[String] raise Invalid {
  if is_email(self.val) {
    self
  } else {
    err(self.path, "invalid email")
  }
}

///|
/// Require `self >= bound`.
pub fn[T : Compare + Show] Checked::min(
  self : Checked[T],
  bound : T,
) -> Checked[T] raise Invalid {
  if self.val >= bound {
    self
  } else {
    err(self.path, "must be at least \{bound}")
  }
}

///|
/// Require `self <= bound`.
pub fn[T : Compare + Show] Checked::max(
  self : Checked[T],
  bound : T,
) -> Checked[T] raise Invalid {
  if self.val <= bound {
    self
  } else {
    err(self.path, "must be at most \{bound}")
  }
}

///|
/// Require `min <= self <= max`.
pub fn[T : Compare + Show] Checked::range(
  self : Checked[T],
  min : T,
  max : T,
) -> Checked[T] raise Invalid {
  if self.val >= min && self.val <= max {
    self
  } else {
    err(self.path, "must be between \{min} and \{max}")
  }
}

///|
/// Apply a custom predicate. The message is used when it returns `false`.
pub fn[T] Checked::refine(
  self : Checked[T],
  predicate : (T) -> Bool,
  message : String,
) -> Checked[T] raise Invalid {
  if predicate(self.val) {
    self
  } else {
    err(self.path, message)
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

///|
fn is_email(s : String) -> Bool {
  guard s.split_once("@") is Some((user, domain)) else { return false }
  !(user.is_empty() ||
  domain.is_empty() ||
  domain.contains("@") ||
  s.contains_any(chars=" \t\r\n") ||
  user.contains("..") ||
  domain.contains("..") ||
  domain.has_prefix(".") ||
  domain.has_suffix(".") ||
  user.has_prefix(".") ||
  user.has_suffix(".") ||
  !domain.contains("."))
}
