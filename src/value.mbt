///|
/// A JSON value together with the path used in error messages.
struct Value {
  json : Json
  path : Path
}

///|
/// An object together with the path used in error messages.
struct Object {
  fields : Map[String, Json]
  path : Path
}

///|
/// Wrap a JSON value so it can be validated while a typed value is built.
pub fn value(json : Json) -> Value {
  { json, path: Root, }
}

///|
/// Return the underlying JSON. Use this as an escape hatch for types that
/// maru does not convert directly.
pub fn Value::raw(self : Value) -> Json {
  self.json
}

///|
/// Require this value to be JSON `null`.
pub fn Value::null(self : Value) -> Unit raise Invalid {
  match self.json {
    Null => ()
    other => err(self.path, "expected null, got \{json_kind(other)}")
  }
}

///|
/// Convert this value to `Bool`.
pub fn Value::bool(self : Value) -> Checked[Bool] raise Invalid {
  match self.json {
    True => { val: true, path: self.path, }
    False => { val: false, path: self.path, }
    other => err(self.path, "expected boolean, got \{json_kind(other)}")
  }
}

///|
/// Convert this value to `Int`.
///
/// JSON numbers must be finite integers in the 32-bit range.
pub fn Value::int(self : Value) -> Checked[Int] raise Invalid {
  let n = expect_integer(self)
  if n > 2147483647.0 || n < -2147483648.0 {
    err(self.path, "integer overflow")
  }
  { val: n.to_int(), path: self.path, }
}

///|
/// Convert this value to `Int64`.
///
/// JSON numbers must be finite integers in the 64-bit range.
pub fn Value::int64(self : Value) -> Checked[Int64] raise Invalid {
  let n = expect_integer(self)
  let i = n.to_int64()
  if i.to_double() != n {
    err(self.path, "integer overflow")
  }
  { val: i, path: self.path, }
}

///|
/// Convert this value to `Double`.
pub fn Value::double(self : Value) -> Checked[Double] raise Invalid {
  match self.json {
    Number(n, ..) => { val: n, path: self.path, }
    other => err(self.path, "expected number, got \{json_kind(other)}")
  }
}

///|
/// Convert this value to `String`.
pub fn Value::string(self : Value) -> Checked[String] raise Invalid {
  match self.json {
    String(s) => { val: s, path: self.path, }
    other => err(self.path, "expected string, got \{json_kind(other)}")
  }
}

///|
/// Convert this value to an array of `Value`s.
pub fn Value::array(self : Value) -> Checked[Array[Value]] raise Invalid {
  match self.json {
    Array(items) => {
      let values = items.mapi(fn(i, item) {
        { json: item, path: Index(self.path, i), }
      })
      { val: values, path: self.path, }
    }
    other => err(self.path, "expected array, got \{json_kind(other)}")
  }
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
    Some(json) => { json, path: Field(self.path, name), }
    None => err(Field(self.path, name), "missing field")
  }
}

///|
/// Get an optional field.
///
/// Returns `None` only when the key is absent. JSON `null` is `Some(Value)`.
pub fn Object::optional_field(self : Object, name : String) -> Value? {
  match self.fields.get(name) {
    Some(json) => Some({ json, path: Field(self.path, name), })
    None => None
  }
}

///|
/// Try each parser in order and return the first success.
///
/// Raises when every parser fails.
pub fn[T] first_of(
  value : Value,
  parsers : Array[(Value) -> T raise Invalid],
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

///|
fn expect_integer(value : Value) -> Double raise Invalid {
  match value.json {
    Number(n, ..) => {
      if n.is_nan() || n.is_inf() || n != n.trunc() {
        err(value.path, "expected integer")
      }
      n
    }
    other => err(value.path, "expected integer, got \{json_kind(other)}")
  }
}
