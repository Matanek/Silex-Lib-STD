# JSON

## Parse untrusted text

`JSON.parse(text)` returns `Result<JSON.Value, JSON.ParseError>`. Parse errors
carry a byte offset, one-origin line and column, a stable kind and a readable
detail. The overload with `maximum_depth` bounds recursive input; the default
limit is 128.

Inspect `Value.kind()` or use the optional typed projections `as_boolean`,
`as_string`, `as_number_text`, `as_array` and `as_object`. JSON numbers retain
their source decimal text instead of silently losing precision. Object members
preserve names and values, while duplicate names are rejected.

[ReadConfiguration.sx](../Examples/JSON/ReadConfiguration.sx) demonstrates the
success and source-located failure paths.
[InspectValueKinds.sx](../Examples/JSON/InspectValueKinds.sx) covers every
typed projection, explicit parse depth and the direct compatibility encoder.

## Construct output

Use `Value.null_value`, `boolean`, `string`, `number`, `array` and `object`.
Floating-point numbers and explicit number text are fallible because JSON
rejects non-finite or malformed values. Object construction is fallible because
duplicate names are rejected.

`JSON.stringify(value, Format.compact())` minimizes bytes;
`Format.pretty()` produces indented human-readable output. `Value.encoded`
offers the same choice through a boolean for compatibility. Prefer
`JSON.stringify` in new code because the format is named at the call site.
See [WriteReport.sx](../Examples/JSON/WriteReport.sx).
