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
pub fn Value::bool(self : Value) -> Typed[Bool] raise Invalid {
  match self.json {
    True => Typed::new(true, self.path)
    False => Typed::new(false, self.path)
    other => err(self.path, "expected boolean, got \{json_kind(other)}")
  }
}

///|
/// Convert this value to `Int`.
///
/// JSON numbers must be finite integers in the 32-bit range.
pub fn Value::int(self : Value) -> Typed[Int] raise Invalid {
  let n = expect_integer(self)
  if n > 2147483647.0 || n < -2147483648.0 {
    err(self.path, "integer overflow")
  }
  Typed::new(n.to_int(), self.path)
}

///|
/// Convert this value to `Int64`.
///
/// JSON numbers must be finite integers in the 64-bit range.
pub fn Value::int64(self : Value) -> Typed[Int64] raise Invalid {
  let n = expect_integer(self)
  // 2^63 is exact in Double; Int64.MAX = 2^63-1 is not.
  if n >= 9223372036854775808.0 || n < -9223372036854775808.0 {
    err(self.path, "integer overflow")
  }
  Typed::new(n.to_int64(), self.path)
}

///|
/// Convert this value to `Double`.
///
/// JSON numbers that overflow to infinity are rejected.
pub fn Value::double(self : Value) -> Typed[Double] raise Invalid {
  match self.json {
    Number(n, ..) => {
      if n.is_nan() || n.is_inf() {
        err(self.path, "must be finite")
      }
      Typed::new(n, self.path)
    }
    other => err(self.path, "expected number, got \{json_kind(other)}")
  }
}

///|
/// Convert this value to `String`.
pub fn Value::string(self : Value) -> Typed[String] raise Invalid {
  match self.json {
    String(s) => Typed::new(s, self.path)
    other => err(self.path, "expected string, got \{json_kind(other)}")
  }
}

///|
/// Convert this value to an array of `Value`s.
pub fn Value::array(self : Value) -> Typed[Array[Value]] raise Invalid {
  match self.json {
    Array(items) => {
      let values = items.mapi(fn(i, item) {
        { json: item, path: Path::Index(self.path, i), }
      })
      Typed::new(values, self.path)
    }
    other => err(self.path, "expected array, got \{json_kind(other)}")
  }
}

///|
fn expect_integer(value : Value) -> Double raise Invalid {
  match value.json {
    Number(n, ..) => {
      if n != n.trunc() {
        err(value.path, "expected integer")
      }
      n
    }
    other => err(value.path, "expected integer, got \{json_kind(other)}")
  }
}
