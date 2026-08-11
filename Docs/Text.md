# Unicode text

Ordinary `str` values contain valid UTF-8. `STD.Text` provides immutable,
locale-independent operations for trimming, exact search, replacement,
Unicode-scalar slicing, splitting, joining and title casing.

`index_of` and `slice` measure Unicode scalar positions, consistently with
`str.count()`. Search operations are case-sensitive. Use `case_fold` to build a
locale-independent caseless comparison key. Normalization supports NFC, NFD,
NFKC and NFKD; choose compatibility forms only when their semantic folding is
intended. [CleanNames.sx](../Examples/Text/CleanNames.sx) shows a small input
cleaning pipeline; [CompareUnicode.sx](../Examples/Text/CompareUnicode.sx)
builds normalized search keys.

Unicode scalars are not always user-visible characters. `Text.Grapheme`
returns extended grapheme-cluster boundaries, counts and strings for cursor
movement or UI truncation. See
[CountGraphemes.sx](../Examples/Text/CountGraphemes.sx).

Use `Text.UTF8.bytes` and `decode` only at byte-oriented boundaries. `decode`
reports the invalid byte position instead of replacing malformed input.
`scalars` and `from_scalars` expose explicit Unicode scalar conversion. See
[Utf8RoundTrip.sx](../Examples/Text/Utf8RoundTrip.sx).

## Read and write explicitly encoded text

`Text.Encoding` supports UTF-8, UTF-16 and UTF-32 in both applicable byte
orders. `encode` writes a payload without a byte order mark;
`encode_with_bom` prepends the matching signature. `detect_bom` returns the
encoding when a recognized signature is present. `decode` accepts either a
matching BOM or a BOM-free payload and reports an error kind plus byte offset
for invalid length, invalid sequences or a conflicting BOM.

[DecodeDocument.sx](../Examples/Text/DecodeDocument.sx) detects and decodes a
UTF-16 document. The executable encoding test round-trips every supported
encoding with and without a BOM.
