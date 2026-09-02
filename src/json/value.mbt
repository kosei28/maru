///|
using @error {type Path, type Invalid, err}

///|
using @typed {type Typed}

///|
/// A JSON value together with the path used in error messages.
struct Value {
  json : Json
  path : Path
}

///|
/// Wrap JSON as a `Value` so it can be validated while a typed value is built.
pub fn from_json(json : Json) -> Value {
  { json, path: Path::Root, }
}

///|
/// Return the underlying JSON. Use this as an escape hatch for types that
/// maru does not convert directly.
pub fn Value::raw(self : Value) -> Json {
  self.json
}

///|
fn json_kind(json : Json) -> String {
  match json {
    Null => "null"
    True | False => "boolean"
    Number(_, ..) => "number"
    String(_) => "string"
    Array(_) => "array"
    Object(_) => "object"
  }
}
