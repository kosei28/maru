///|
/// A location inside a JSON value.
///
/// Field names are joined with `.`, and array indices are written as `[n]`.
/// The root path is empty.
pub(all) enum Path {
  Root
  Field(Path, String)
  Index(Path, Int)
} derive(Eq)

///|
pub impl Show for Path with fn output(self, logger) {
  fn write_path(path : Path, logger : &Logger) -> Unit {
    match path {
      Root => ()
      Field(Root, name) => logger.write_string(name)
      Field(parent, name) => {
        write_path(parent, logger)
        logger.write_string(".")
        logger.write_string(name)
      }
      Index(parent, index) => {
        write_path(parent, logger)
        logger.write_string("[\{index}]")
      }
    }
  }

  write_path(self, logger)
}

///|
pub extend Path with Show::{to_string}
