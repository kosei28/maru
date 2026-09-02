///|
/// A validation failure, carrying the JSON path where it occurred.
pub(all) suberror Invalid {
  Invalid(Path, String)
} derive(Eq)

///|
pub impl Show for Invalid with fn output(self, logger) {
  match self {
    Invalid(Root, message) => logger.write_string(message)
    Invalid(path, message) => {
      Show::output(path, logger)
      logger.write_string(": ")
      logger.write_string(message)
    }
  }
}

///|
pub extend Invalid with Show::{to_string}

///|
fn[T] err(path : Path, message : String) -> T raise Invalid {
  raise Invalid(path, message)
}
