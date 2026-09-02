///|
/// An object together with the path used in error messages.
struct Object {
  fields : Map[String, Json]
  path : Path
}

///|
/// Convert this value to an object.
pub fn Value::object(self : Value) -> Object raise Invalid {
  match self.json {
    Object(fields) => { fields, path: self.path, }
    other => err(self.path, "expected object, got \{json_kind(other)}")
  }
}

///|
/// Get a required field. Missing keys raise; JSON `null` is still a `Value`.
pub fn Object::field(self : Object, name : String) -> Value raise Invalid {
  match self.fields.get(name) {
    Some(json) => { json, path: Path::Field(self.path, name), }
    None => err(Path::Field(self.path, name), "missing field")
  }
}

///|
/// Get an optional field.
///
/// Returns `None` only when the key is absent. JSON `null` is `Some(Value)`.
pub fn Object::optional_field(self : Object, name : String) -> Value? {
  match self.fields.get(name) {
    Some(json) => Some({ json, path: Path::Field(self.path, name), })
    None => None
  }
}
