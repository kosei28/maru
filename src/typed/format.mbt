///|
/// Require a string to look like an email address.
pub fn Typed::email(self : Typed[String]) -> Typed[String] raise Invalid {
  if is_email(self.val) {
    self
  } else {
    err(self.path, "invalid email")
  }
}

///|
/// Require a string to look like a URL.
pub fn Typed::url(self : Typed[String]) -> Typed[String] raise Invalid {
  if is_url(self.val) {
    self
  } else {
    err(self.path, "invalid url")
  }
}

///|
/// Require a string to look like a UUID.
pub fn Typed::uuid(self : Typed[String]) -> Typed[String] raise Invalid {
  if is_uuid(self.val) {
    self
  } else {
    err(self.path, "invalid uuid")
  }
}

///|
/// Require a string to look like an IPv4 address.
pub fn Typed::ipv4(self : Typed[String]) -> Typed[String] raise Invalid {
  if is_ipv4(self.val) {
    self
  } else {
    err(self.path, "invalid ipv4")
  }
}

///|
/// Require a string to look like an IPv6 address.
pub fn Typed::ipv6(self : Typed[String]) -> Typed[String] raise Invalid {
  if is_ipv6(self.val) {
    self
  } else {
    err(self.path, "invalid ipv6")
  }
}

///|
/// Require a string to be an ISO 8601 date (`YYYY-MM-DD`).
pub fn Typed::date(self : Typed[String]) -> Typed[String] raise Invalid {
  if is_date(self.val) {
    self
  } else {
    err(self.path, "invalid date")
  }
}

///|
/// Require a string to be an ISO 8601 time (`HH:MM[:SS[.s+]]`).
pub fn Typed::time(self : Typed[String]) -> Typed[String] raise Invalid {
  if is_time(self.val) {
    self
  } else {
    err(self.path, "invalid time")
  }
}

///|
/// Require a string to be an ISO 8601 datetime.
pub fn Typed::datetime(self : Typed[String]) -> Typed[String] raise Invalid {
  if is_datetime(self.val) {
    self
  } else {
    err(self.path, "invalid datetime")
  }
}

///|
/// Require a string to be standard Base64.
pub fn Typed::base64(self : Typed[String]) -> Typed[String] raise Invalid {
  if is_base64(self.val) {
    self
  } else {
    err(self.path, "invalid base64")
  }
}

///|
fn is_email(s : StringView) -> Bool {
  guard s.split_once("@") is Some((user, domain)) else { return false }
  !(user.is_empty() ||
  domain.is_empty() ||
  domain.contains("@") ||
  s.contains_any(chars=" \t\r\n") ||
  user.contains("..") ||
  domain.contains("..") ||
  domain.has_prefix(".") ||
  domain.has_suffix(".") ||
  user.has_prefix(".") ||
  user.has_suffix(".") ||
  !domain.contains("."))
}

///|
fn is_url(s : StringView) -> Bool {
  if s.contains_any(chars=" \t\r\n") {
    return false
  }
  guard s.split_once(":") is Some((scheme, rest)) else { return false }
  !rest.is_empty() && is_url_scheme(scheme)
}

///|
fn is_url_scheme(s : StringView) -> Bool {
  if s.is_empty() {
    return false
  }
  let mut first = true
  for c in s {
    if first {
      if !c.is_ascii_alphabetic() {
        return false
      }
      first = false
    } else if !(is_ascii_alnum(c) || c == '+' || c == '.' || c == '-') {
      return false
    }
  }
  true
}

///|
fn is_uuid(s : StringView) -> Bool {
  if s.length() != 36 {
    return false
  }
  let mut i = 0
  for c in s {
    if i == 8 || i == 13 || i == 18 || i == 23 {
      if c != '-' {
        return false
      }
    } else if !c.is_ascii_hexdigit() {
      return false
    }
    i = i + 1
  }
  true
}

///|
fn is_ipv4(s : StringView) -> Bool {
  let parts = split_sep(s, ".")
  if parts.length() != 4 {
    return false
  }
  for part in parts {
    guard parse_octet(part) is Some(_) else { return false }
  }
  true
}

///|
fn parse_octet(s : StringView) -> Int? {
  if s.is_empty() || s.length() > 3 {
    return None
  }
  let mut n = 0
  let mut i = 0
  for c in s {
    guard digit(c) is Some(d) else { return None }
    if i == 0 && d == 0 && s.length() > 1 {
      return None
    }
    n = n * 10 + d
    i = i + 1
  }
  if n > 255 {
    None
  } else {
    Some(n)
  }
}

///|
fn is_ipv6(s : StringView) -> Bool {
  if s.contains(":::") {
    return false
  }
  if s.contains("::") {
    guard s.split_once("::") is Some((left, right)) else { return false }
    if left.contains("::") || right.contains("::") {
      return false
    }
    guard ipv6_group_count(left, ipv4=false) is Some(ln) else { return false }
    guard ipv6_group_count(right, ipv4=true) is Some(rn) else { return false }
    ln + rn < 8
  } else {
    match ipv6_group_count(s, ipv4=true) {
      Some(n) => n == 8
      None => false
    }
  }
}

///|
fn ipv6_group_count(s : StringView, ipv4~ : Bool) -> Int? {
  if s.is_empty() {
    return Some(0)
  }
  let parts = split_sep(s, ":")
  let last = parts.length() - 1
  let mut n = 0
  for i in 0..<parts.length() {
    let p = parts[i]
    if ipv4 && i == last && p.contains(".") {
      if !is_ipv4(p) {
        return None
      }
      n = n + 2
    } else if is_h16(p) {
      n = n + 1
    } else {
      return None
    }
  }
  Some(n)
}

///|
fn is_h16(s : StringView) -> Bool {
  let n = s.length()
  if n < 1 || n > 4 {
    return false
  }
  for c in s {
    if !c.is_ascii_hexdigit() {
      return false
    }
  }
  true
}

///|
fn is_date(s : StringView) -> Bool {
  if s.length() != 10 {
    return false
  }
  let mut i = 0
  let mut year = 0
  let mut month = 0
  let mut day = 0
  for c in s {
    if i == 4 || i == 7 {
      if c != '-' {
        return false
      }
    } else {
      guard digit(c) is Some(d) else { return false }
      if i < 4 {
        year = year * 10 + d
      } else if i < 7 {
        month = month * 10 + d
      } else {
        day = day * 10 + d
      }
    }
    i = i + 1
  }
  month >= 1 && month <= 12 && day >= 1 && day <= days_in_month(year, month)
}

///|
fn days_in_month(year : Int, month : Int) -> Int {
  match month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    4 | 6 | 9 | 11 => 30
    2 => if is_leap_year(year) { 29 } else { 28 }
    _ => 0
  }
}

///|
fn is_leap_year(year : Int) -> Bool {
  year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
}

///|
fn is_time(s : StringView) -> Bool {
  let parts = split_sep(s, ":")
  match parts.length() {
    2 => is_hour(parts[0]) && is_minute(parts[1])
    3 => is_hour(parts[0]) && is_minute(parts[1]) && is_second(parts[2])
    _ => false
  }
}

///|
fn is_datetime(s : StringView) -> Bool {
  guard s.split_once("T") is Some((date, rest)) else { return false }
  if !is_date(date) {
    return false
  }
  if rest.has_suffix("Z") {
    guard rest.strip_suffix("Z") is Some(time) else { return false }
    return is_time(time)
  }
  match split_offset(rest) {
    Some((time, offset)) => is_time(time) && is_offset(offset)
    None => is_time(rest)
  }
}

///|
fn split_offset(s : StringView) -> (StringView, StringView)? {
  match s.split_once("+") {
    Some((time, offset)) =>
      if time.is_empty() {
        None
      } else {
        Some((time, offset))
      }
    None =>
      match s.split_once("-") {
        Some((time, offset)) =>
          if time.is_empty() {
            None
          } else {
            Some((time, offset))
          }
        None => None
      }
  }
}

///|
fn is_offset(s : StringView) -> Bool {
  let parts = split_sep(s, ":")
  parts.length() == 2 && is_hour(parts[0]) && is_minute(parts[1])
}

///|
fn is_hour(s : StringView) -> Bool {
  is_two_digits(s, 23)
}

///|
fn is_minute(s : StringView) -> Bool {
  is_two_digits(s, 59)
}

///|
fn is_second(s : StringView) -> Bool {
  match s.split_once(".") {
    Some((sec, frac)) =>
      is_two_digits(sec, 59) && !frac.is_empty() && is_all_digits(frac)
    None => is_two_digits(s, 59)
  }
}

///|
fn is_two_digits(s : StringView, max : Int) -> Bool {
  if s.length() != 2 {
    return false
  }
  guard parse_nonneg(s) is Some(n) else { return false }
  n <= max
}

///|
fn parse_nonneg(s : StringView) -> Int? {
  if s.is_empty() {
    return None
  }
  let mut n = 0
  for c in s {
    guard digit(c) is Some(d) else { return None }
    n = n * 10 + d
  }
  Some(n)
}

///|
fn is_all_digits(s : StringView) -> Bool {
  for c in s {
    if !c.is_ascii_digit() {
      return false
    }
  }
  true
}

///|
fn is_base64(s : StringView) -> Bool {
  if s.length() % 4 != 0 {
    return false
  }
  let mut padding = 0
  for c in s {
    if padding > 0 {
      if c != '=' {
        return false
      }
      padding = padding + 1
    } else if c == '=' {
      padding = 1
    } else if !is_base64_char(c) {
      return false
    }
  }
  padding <= 2
}

///|
fn is_base64_char(c : Char) -> Bool {
  is_ascii_alnum(c) || c == '+' || c == '/'
}

///|
fn is_ascii_alnum(c : Char) -> Bool {
  c.is_ascii_alphabetic() || c.is_ascii_digit()
}

///|
fn digit(c : Char) -> Int? {
  if c.is_ascii_digit() {
    Some(c.to_int() - '0'.to_int())
  } else {
    None
  }
}

///|
fn split_sep(s : StringView, sep : StringView) -> Array[StringView] {
  let parts : Array[StringView] = []
  fn push_parts(rest : StringView) -> Unit {
    match rest.split_once(sep) {
      Some((head, tail)) => {
        parts.push(head)
        push_parts(tail)
      }
      None => parts.push(rest)
    }
  }

  push_parts(s)
  parts
}
