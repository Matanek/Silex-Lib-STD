# Errors from STD

Fallible system APIs return `Result<Value, STD.Error>`. Use `try` when the
caller can preserve the error, or `match` when the application must recover,
retry, translate or report it.

`Error` carries:

- `kind`, a portable category such as `not_found`, `permission_denied`,
  `timed_out`, `invalid_data` or `limit_exceeded`;
- `operation`, the STD capability that failed;
- optional `subject`, normally a path or host;
- `detail`, a human-readable explanation.

Branch on `kind` for behavior and display `operation`, `subject` and `detail`
for diagnostics. Do not parse `detail`; it is explanatory text rather than a
stable machine contract.

JSON uses its more precise `ParseError` and `BuildError` types because source
location and JSON grammar failures are domain concepts rather than system
errors.
