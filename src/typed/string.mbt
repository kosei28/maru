///|
/// Require a string to start with `prefix`.
pub fn Typed::starts_with(
  self : Typed[String],
  prefix : String,
) -> Typed[String] raise Invalid {
  if self.val.has_prefix(prefix) {
    self
  } else {
    err(self.path, "must start with \{prefix}")
  }
}

///|
/// Require a string to end with `suffix`.
pub fn Typed::ends_with(
  self : Typed[String],
  suffix : String,
) -> Typed[String] raise Invalid {
  if self.val.has_suffix(suffix) {
    self
  } else {
    err(self.path, "must end with \{suffix}")
  }
}

///|
/// Require a string to contain `part`.
pub fn Typed::includes(
  self : Typed[String],
  part : String,
) -> Typed[String] raise Invalid {
  if self.val.contains(part) {
    self
  } else {
    err(self.path, "must include \{part}")
  }
}

///|
/// Require a string to be lowercase.
pub fn Typed::lowercase(self : Typed[String]) -> Typed[String] raise Invalid {
  if is_lowercase(self.val) {
    self
  } else {
    err(self.path, "must be lowercase")
  }
}

///|
/// Require a string to be uppercase.
pub fn Typed::uppercase(self : Typed[String]) -> Typed[String] raise Invalid {
  if is_uppercase(self.val) {
    self
  } else {
    err(self.path, "must be uppercase")
  }
}

///|
/// Require a string to contain a MoonBit regex match.
/// Use `^` and `$` to require the whole string.
pub fn Typed::regex(
  self : Typed[String],
  pattern : String,
) -> Typed[String] raise Invalid {
  if regex_matches(pattern, self.val) {
    self
  } else {
    err(self.path, "must match pattern")
  }
}

///|
fn is_lowercase(s : StringView) -> Bool {
  s.to_lower().to_owned() == s.to_owned()
}

///|
fn is_uppercase(s : StringView) -> Bool {
  s.to_upper().to_owned() == s.to_owned()
}

///|
fn regex_matches(pattern : StringView, s : StringView) -> Bool {
  let re = @string.Regex::unsafe_from_string(pattern)
  re.execute(s) is Some(_)
}
