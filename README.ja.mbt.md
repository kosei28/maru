# maru

[English](README.md)

スキーマを値として持たず、検証しながら型付きの値を構築する、MoonBit 向けのミニマルなバリデーションライブラリ。

```mbt check
///|
test {
  let json : Json = { "name": "Ada", "age": 36 }
  let obj = @maru.from_json(json).object()
  let name = obj.field("name").string().nonempty().value()
  let age = obj.field("age").int().range(0, 150).value()
  assert_eq(name, "Ada")
  assert_eq(age, 36)
}
```

## インストール

```bash
moon add kosei28/maru
```

`moon.pkg` に import する:

```text
import {
  "kosei28/maru"
}
```

## 方針

- schema-as-value を持たない
- validator builder や遅延評価を持たない
- 取得・型検証・値検証を分離する
- エラー伝播には MoonBit の `raise` を使う
- maru の型は値と path を保持するだけの薄いラッパーにする
- 最初に `from_json` で JSON を `Value` に包む
- 最後に `.value()` で素の MoonBit 値へ戻す
- 未対応の型は `Value::raw()` を使って自前でパースできる

## 基本モデル

生の `Json`、オブジェクトのフィールド、配列要素はすべて同じ `Value` として扱う。

```mbt check
///|
test {
  let value = @maru.from_json({ "ok": true })
  assert_eq(value.object().field("ok").bool().value(), true)
}
```

```text
value.null()
value.bool()
value.int()
value.int64()
value.double()
value.string()
value.array()
value.object()
```

## 型変換と値検証

プリミティブ型への変換後は `Checked[T]` として path を保持する。

```text
Value
  ↓ int()
Checked[Int]
  ↓ range(...)
Checked[Int]
  ↓ value()
Int
```

主な検証:

```text
.nonempty()
.min_len(n)
.max_len(n)
.email()

.min(n)
.max(n)
.range(min, max)

.refine(predicate, message)
```

失敗時は `@maru.Invalid` を `raise` する。
メッセージには失敗した位置の path が付く。

```text
users[2].email: invalid email
```

## struct の構築

```moonbit nocheck
///|
fn User::parse(value : @maru.Value) -> User raise @maru.Invalid {
  let obj = value.object()
  User::{
    name: obj.field("name").string().nonempty().value(),
    email: obj.field("email").string().email().value(),
    age: obj.field("age").int().range(0, 150).value(),
    rating: obj.field("rating").double().range(0.0, 5.0).value(),
    nickname: obj
    .optional_field("nickname")
    .map(v => v.string().max_len(30).value()),
  }
}
```

トップレベルからは `User::parse(@maru.from_json(json))` で使う。

## オブジェクト

フィールド取得と型検証は分離する。

```text
Object
  ↓ field("name")
Value
  ↓ string()
Checked[String]
```

- `field` は必須フィールド。キーが無ければエラー
- `optional_field` はキーが存在しない場合のみ `None`

```mbt check
///|
test {
  let obj = @maru.from_json({ "name": "Ada" }).object()
  let nickname = obj
    .optional_field("nickname")
    .map(v => v.string().max_len(30).value())
  assert_eq(nickname, None)
}
```

## 配列

配列要素も `Value` として扱う。

```mbt check
///|
test {
  let scores = @maru.from_json({ "scores": [10.0, 99.5] })
    .object()
    .field("scores")
    .array()
    .map(v => v.double().range(0.0, 100.0).value())
    .value()
  assert_eq(scores, [10.0, 99.5])
}
```

## 複数の候補

`first_of` は同じ `Value` に複数の parser を順番に適用し、最初に成功した値を返す。

```mbt check
///|
test {
  let id = @maru.first_of(@maru.from_json(7), [
    v => v.string().value(),
    v => v.int().value().to_string(),
  ])
  assert_eq(id, "7")
}
```

nullable も同じように書ける。

```mbt check
///|
test {
  let nickname : String? = @maru.first_of(@maru.from_json(null), [
    v => { v.null(); None },
    v => Some(v.string().value()),
  ])
  assert_eq(nickname, None)
}
```

## 生の JSON

`Value.raw()` は maru が直接対応していない型を自前でパースするための escape hatch。
`Checked[T]` には `raw()` を提供しない。

```text
from_json(json)    -> Value
Value.raw()        -> Json
Checked[T].value() -> T
```
