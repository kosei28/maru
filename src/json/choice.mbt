///|
/// A function that parses a `Value` into `T`.
pub type Parser[T] = (Value) -> T raise Invalid

///|
/// Try each parser in order and return the first success.
///
/// Raises when every parser fails.
pub fn[T] first_of(
  value : Value,
  parsers : Array[Parser[T]],
) -> T raise Invalid {
  for parser in parsers {
    try {
      return parser(value)
    } catch {
      Invalid(_) => ()
    }
  }
  err(value.path, "no matching parser")
}
