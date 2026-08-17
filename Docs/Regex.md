# Regular expressions

`STD.Regex` compiles a pattern once, then searches immutable Unicode text.
Compilation is fallible and returns a structured error containing its kind,
Unicode-scalar position and a readable detail.

```sx
use STD.Regex

let identifier = try Regex.compile("[A-Za-z_][A-Za-z0-9_]*")
if identifier.match("silex_value") { print("valid identifier") }
```

The search methods are named after their intent:

- `contains(text)` reports whether an occurrence exists anywhere;
- `first(text)` returns the first occurrence as `Match?`;
- `find(text)` returns a lazy `Cursor`, directly usable in `for` or through `next()`;
- `match(text)` reports whether the pattern covers the whole text;
- `all(text)` materializes every occurrence as `Match[]`.

Searches are non-overlapping and empty matches advance by one Unicode scalar,
including the final text boundary.

```sx
for found in expression.find(text) { print(found.text()) }

var cursor = expression.find(text)
while found = cursor.next() { print(found.text()) }
```

## Presets

`Regex.Presets` provides common expressions without mixing domain names into
the core `Regex` type. On first use, each function calls `Regex.compile` with a
maintained pattern and caches the resulting ordinary `Regex` inside `Presets`.
Later calls return that value; the `Regex` type and engine have no preset-specific
path. Store the returned value when it will be used repeatedly.

```sx
let email = Regex.Presets.email()
if email.contains(message) { print("an email address is present") }

if Regex.Presets.ipv4().match("192.168.1.20") { print("valid IPv4") }
if Regex.Presets.ipv6().match("2001:db8::38") { print("valid IPv6") }
if Regex.Presets.digit().match("７") { print("one Unicode digit") }
```

- `digit()` covers exactly one Unicode decimal digit;
- `digits()` covers one or more Unicode decimal digits;
- `ipv4()` accepts four decimal octets from 0 through 255 without leading zeroes;
- `ipv6()` accepts full and `::`-compressed hexadecimal IPv6 addresses;
- `email()` recognizes practical mailbox addresses with a qualified DNS domain.

`email()` intentionally targets common application input rather than every
address permitted by the complete email RFC grammar. `ipv6()` does not include
the embedded-IPv4 notation; use a domain-specific parser when that distinction
or canonicalization matters.

Matching follows the common leftmost-first convention: the earliest start wins,
then the first viable alternative in pattern order. Quantifiers are greedy unless
followed by `?`; `a+` prefers the longest viable run while `a+?` prefers the
shortest.

## Matches, captures and transformations

Positions are Unicode-scalar indexes, consistently with `str.count()` and
`STD.Text.slice`. Capture zero is the whole match. Parenthesized captures are
numbered from one; `(?<name>...)` also makes a capture accessible by name and
`(?:...)` groups without capturing.

```sx
let pair = try Regex.compile("(?<key>\\w+)=(?<value>\\w+)")
if found = pair.first("language=Silex") {
    if value = found.capture("value") { print(value.text()) }
}
```

`split` preserves empty fields and removes separators. `replace_first` and
`replace_all` accept literal replacement text or `func(@Match) str`. String
replacements are deliberately literal: `$1` and backslashes have no hidden
replacement-language meaning; use a callback when captures are needed.

[ExtractContacts.sx](../Examples/Regex/ExtractContacts.sx) demonstrates direct
lazy iteration and named captures. [NormalizeLog.sx](../Examples/Regex/NormalizeLog.sx)
demonstrates options, callback replacement and splitting.

## Pattern language

The supported surface includes:

- Unicode literals, `.`, classes, ranges, negated classes and `|`;
- `*`, `+`, `?`, `{n}`, `{n,m}` and `{n,}`, plus their lazy forms;
- numbered and named captures, and noncapturing groups;
- `^`, `$`, Unicode word boundaries `\\b` and `\\B`;
- Unicode `\\d`, `\\w`, `\\s` and their uppercase negations;
- `\\p{...}` and `\\P{...}` for `L`/`Letter`, `M`/`Mark`, `N`/`Number`,
  `Nd`/`Decimal_Number`, `Z`/`Separator`, `P`/`Punctuation`, `S`/`Symbol`,
  `White_Space` and `Word`.

`\\w` follows Unicode Annex #18's useful word set: alphabetic characters, marks,
decimal digits, connector punctuation and join controls. ASCII-only identifiers
remain explicit with `[A-Za-z0-9_]`.

Patterns use ordinary Silex strings, so write `"\\d+"`. Regex literals are not
part of the language grammar.

## Options

`Regex.compile(pattern, Regex.Options(...))` accepts three independent options:

- `case_insensitive` uses Unicode simple case folding; multi-scalar expansions
  are excluded;
- `multi_line` lets `^` and `$` match around Unicode line terminators;
- `dot_matches_newline` lets `.` consume line terminators.

## Performance and deliberate limits

The engine streams UTF-8 directly and does not materialize a scalar copy of the
input. It runs an ordered Thompson NFA with iterative epsilon closure, reuses
its active-state buffers, and searches normalized Unicode ranges by binary
search. Its memory is bounded by the compiled pattern and active captures, not
by text length. Worst-case work is proportional to text length times the number
of active states; ambiguous repetition cannot cause exponential backtracking.

Large fixed-width finite repetitions use counters instead of duplicating the
subprogram. Other finite bounds remain limited to 10,000 so compilation stays
bounded. Backreferences and arbitrary lookaround are intentionally unsupported:
they would compromise the predictable time and memory contract for large texts.
