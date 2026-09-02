# maru

A small MoonBit validation library.
Validate JSON in place while constructing a typed value, without turning input into a schema.

See `README.mbt.md` for the API. Keep the implementation small.

## Design

- No schema-as-value, validator builder, or delayed evaluation
- Keep fetching, type checks, and value checks separate
- Wrappers only hold a value and a path
- Start with `from_json` to wrap JSON as a `Value`
- Finish with `.value()` to unwrap to a plain MoonBit value
- Parse unsupported types yourself via `Value::raw()`
- Raise `@maru.Invalid` on failure (`Error` is reserved in MoonBit)
- Unions use `first_of` (try parsers in order, take the first success). This is not OpenAPI `oneOf`

Do not add: a Zod-style DSL, schema → type inference, JSON Schema, serialization, or codegen.

## Layout

```text
moon.mod          # source = "src"
README.mbt.md
src/
  moon.pkg
  *.mbt
  maru_test.mbt
  pkg.generated.mbti
```

There is a single package under `src/`. After changing the public API, check the diff of `src/pkg.generated.mbti`.

## Coding

- Separate toplevel items with `///|`. Order does not matter
- Prefer `assert_eq` / `assert_true` in tests. Check errors with `assert_invalid` against the message
- Use `v => ...` for closures that raise

## Commands

```text
moon fmt
moon check --deny-warn
moon test
moon info
```

Run `moon info && moon fmt` at the end of a change.
