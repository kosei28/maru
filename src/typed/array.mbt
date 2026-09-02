///|
/// Map each array element. Errors keep the element's path.
pub fn[A, B] Typed::map(
  self : Typed[Array[A]],
  f : (A) -> B raise?,
) -> Typed[Array[B]] raise? {
  { val: self.val.map(f), path: self.path, }
}

///|
/// Require array elements to be unique.
pub fn[T : Eq] Typed::unique(
  self : Typed[Array[T]],
) -> Typed[Array[T]] raise Invalid {
  let n = self.val.length()
  for i in 0..<n {
    for j in (i + 1)..<n {
      if self.val[i] == self.val[j] {
        err(self.path, "must not contain duplicates")
      }
    }
  }
  self
}
