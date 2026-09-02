///|
/// Numeric zero, used by `positive` and related checks.
pub(open) trait Zero {
  fn zero() -> Self
}

///|
pub impl Zero for Int with fn zero() {
  0
}

///|
pub impl Zero for Int64 with fn zero() {
  0L
}

///|
pub impl Zero for Double with fn zero() {
  0.0
}

///|
/// Numbers that support remainder, used by `multiple_of`.
pub(open) trait Remainder {
  fn rem(Self, Self) -> Self
}

///|
pub impl Remainder for Int with fn rem(self, n) {
  self % n
}

///|
pub impl Remainder for Int64 with fn rem(self, n) {
  self % n
}

///|
pub impl Remainder for Double with fn rem(self, n) {
  self % n
}

///|
/// Require `self >= bound`.
pub fn[T : Compare + Show] Typed::min(
  self : Typed[T],
  bound : T,
) -> Typed[T] raise Invalid {
  if self.val >= bound {
    self
  } else {
    err(self.path, "must be at least \{bound}")
  }
}

///|
/// Require `self <= bound`.
pub fn[T : Compare + Show] Typed::max(
  self : Typed[T],
  bound : T,
) -> Typed[T] raise Invalid {
  if self.val <= bound {
    self
  } else {
    err(self.path, "must be at most \{bound}")
  }
}

///|
/// Require `min <= self <= max`.
pub fn[T : Compare + Show] Typed::range(
  self : Typed[T],
  min : T,
  max : T,
) -> Typed[T] raise Invalid {
  if self.val >= min && self.val <= max {
    self
  } else {
    err(self.path, "must be between \{min} and \{max}")
  }
}

///|
/// Require `self > bound`.
pub fn[T : Compare + Show] Typed::gt(
  self : Typed[T],
  bound : T,
) -> Typed[T] raise Invalid {
  if self.val > bound {
    self
  } else {
    err(self.path, "must be greater than \{bound}")
  }
}

///|
/// Require `self < bound`.
pub fn[T : Compare + Show] Typed::lt(
  self : Typed[T],
  bound : T,
) -> Typed[T] raise Invalid {
  if self.val < bound {
    self
  } else {
    err(self.path, "must be less than \{bound}")
  }
}

///|
/// Require `self > 0`.
pub fn[T : Compare + Zero] Typed::positive(
  self : Typed[T],
) -> Typed[T] raise Invalid {
  expect_positive(self.path, self.val > Zero::zero())
  self
}

///|
/// Require `self < 0`.
pub fn[T : Compare + Zero] Typed::negative(
  self : Typed[T],
) -> Typed[T] raise Invalid {
  expect_negative(self.path, self.val < Zero::zero())
  self
}

///|
/// Require `self >= 0`.
pub fn[T : Compare + Zero] Typed::nonnegative(
  self : Typed[T],
) -> Typed[T] raise Invalid {
  expect_nonnegative(self.path, self.val >= Zero::zero())
  self
}

///|
/// Require `self <= 0`.
pub fn[T : Compare + Zero] Typed::nonpositive(
  self : Typed[T],
) -> Typed[T] raise Invalid {
  expect_nonpositive(self.path, self.val <= Zero::zero())
  self
}

///|
/// Require `self` to be a multiple of `n`.
pub fn[T : Remainder + Zero + Eq + Show] Typed::multiple_of(
  self : Typed[T],
  n : T,
) -> Typed[T] raise Invalid {
  let zero = Zero::zero()
  expect_multiple_of(
    self.path,
    n != zero && Remainder::rem(self.val, n) == zero,
    n,
  )
  self
}

///|
fn expect_positive(path : Path, ok : Bool) -> Unit raise Invalid {
  if !ok {
    err(path, "must be positive")
  }
}

///|
fn expect_negative(path : Path, ok : Bool) -> Unit raise Invalid {
  if !ok {
    err(path, "must be negative")
  }
}

///|
fn expect_nonnegative(path : Path, ok : Bool) -> Unit raise Invalid {
  if !ok {
    err(path, "must be non-negative")
  }
}

///|
fn expect_nonpositive(path : Path, ok : Bool) -> Unit raise Invalid {
  if !ok {
    err(path, "must be non-positive")
  }
}

///|
fn[T : Show] expect_multiple_of(
  path : Path,
  ok : Bool,
  n : T,
) -> Unit raise Invalid {
  if !ok {
    err(path, "must be a multiple of \{n}")
  }
}
