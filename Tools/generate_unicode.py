#!/usr/bin/env python3
"""Generate compact Silex tables from an official, versioned UCD directory."""

from pathlib import Path
import argparse

ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"


def u21(value: int) -> str:
    return "".join(ALPHABET[(value >> shift) & 63] for shift in (18, 12, 6, 0))


def ranges(path: Path, wanted: dict[str, int], field: int = 1) -> list[tuple[int, int, int]]:
    result = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        text = raw.split("#", 1)[0].strip()
        if not text:
            continue
        parts = [part.strip() for part in text.split(";")]
        if field >= len(parts):
            continue
        name = parts[field]
        if name not in wanted:
            continue
        first, _, last = parts[0].partition("..")
        result.append((int(first, 16), int(last or first, 16), wanted[name]))
    return result


def encode_ranges(values: list[tuple[int, int, int]]) -> str:
    values.sort()
    return "".join(u21(first) + u21(last) + ALPHABET[kind] for first, last, kind in values)


def encode_plain_ranges(values: list[tuple[int, int, int]]) -> str:
    merged: list[tuple[int, int]] = []
    for first, last, _ in sorted(values):
        if merged and first <= merged[-1][1] + 1:
            merged[-1] = (merged[-1][0], max(merged[-1][1], last))
        else:
            merged.append((first, last))
    return "".join(u21(first) + u21(last) for first, last in merged)


def encode_mapping(mapping: dict[int, tuple[int, ...]], compatibility: set[int] | None = None) -> tuple[str, str, str]:
    keys, metadata, payload = [], [], []
    offset = 0
    for codepoint, mapped in sorted(mapping.items()):
        keys.append(u21(codepoint))
        metadata.append(u21(offset) + ALPHABET[len(mapped)])
        if compatibility is not None:
            metadata.append(ALPHABET[1 if codepoint in compatibility else 0])
        payload.extend(u21(value) for value in mapped)
        offset += len(mapped)
    return "".join(keys), "".join(metadata), "".join(payload)


def parse_unicode_data(path: Path):
    decomposition = {}
    compatibility = set()
    combining = {}
    lower = {}
    upper = {}
    categories = []
    category_first = None
    for raw in path.read_text(encoding="utf-8").splitlines():
        fields = raw.split(";")
        codepoint = int(fields[0], 16)
        name = fields[1]
        category = fields[2]
        if name.endswith(", First>"):
            category_first = (codepoint, category)
        elif name.endswith(", Last>"):
            if category_first is None or category_first[1] != category:
                raise ValueError(f"unpaired UnicodeData range at U+{codepoint:04X}")
            categories.append((category_first[0], codepoint, category))
            category_first = None
        else:
            categories.append((codepoint, codepoint, category))
        if fields[3] != "0":
            combining[codepoint] = int(fields[3])
        value = fields[5]
        if value:
            parts = value.split()
            if parts[0].startswith("<"):
                compatibility.add(codepoint)
                parts = parts[1:]
            decomposition[codepoint] = tuple(int(part, 16) for part in parts)
        if fields[12]:
            upper[codepoint] = (int(fields[12], 16),)
        if fields[13]:
            lower[codepoint] = (int(fields[13], 16),)
    return decomposition, compatibility, combining, lower, upper, categories


def parse_special_casing(path: Path, lower: dict, upper: dict):
    for raw in path.read_text(encoding="utf-8").splitlines():
        text = raw.split("#", 1)[0].strip()
        if not text:
            continue
        fields = [field.strip() for field in text.split(";")]
        condition = fields[4]
        if condition and condition != "Final_Sigma":
            continue
        codepoint = int(fields[0], 16)
        if not condition:
            lower[codepoint] = tuple(int(value, 16) for value in fields[1].split())
            upper[codepoint] = tuple(int(value, 16) for value in fields[3].split())


def parse_case_folding(path: Path) -> dict[int, tuple[int, ...]]:
    result = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        text = raw.split("#", 1)[0].strip()
        if not text:
            continue
        fields = [field.strip() for field in text.split(";")]
        if fields[1] in ("C", "F"):
            result[int(fields[0], 16)] = tuple(int(value, 16) for value in fields[2].split())
    return result


def function(name: str, value: str) -> str:
    visibility = "package " if name.startswith("regex_") else ""
    return f'{visibility}func {name}() str {{ return "{value}" }}\n'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("ucd", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    decomposition, compatibility, combining, lower, upper, categories = parse_unicode_data(args.ucd / "UnicodeData.txt")
    parse_special_casing(args.ucd / "SpecialCasing.txt", lower, upper)
    fold = parse_case_folding(args.ucd / "CaseFolding.txt")
    exclusions = {
        int(line.split("#", 1)[0].strip(), 16)
        for line in (args.ucd / "CompositionExclusions.txt").read_text().splitlines()
        if line.split("#", 1)[0].strip()
    }
    compositions = {}
    for composed, parts in decomposition.items():
        if composed not in compatibility and composed not in exclusions and len(parts) == 2 and combining.get(parts[0], 0) == 0:
            compositions[(parts[0], parts[1])] = composed
    decomp = encode_mapping(decomposition, compatibility)
    ccc_keys = "".join(u21(key) for key in sorted(combining))
    ccc_values = "".join(u21(combining[key]) for key in sorted(combining))
    composition_keys = "".join(u21(first) + u21(second) for first, second in sorted(compositions))
    composition_values = "".join(u21(compositions[key]) for key in sorted(compositions))
    lower_data = encode_mapping(lower)
    upper_data = encode_mapping(upper)
    fold_data = encode_mapping(fold)
    grapheme_names = {name: index for index, name in enumerate(("CR", "LF", "Control", "Extend", "ZWJ", "Regional_Indicator", "Prepend", "SpacingMark", "L", "V", "T", "LV", "LVT"), 1)}
    grapheme = ranges(args.ucd / "auxiliary" / "GraphemeBreakProperty.txt", grapheme_names)
    pictographic = ranges(args.ucd / "emoji" / "emoji-data.txt", {"Extended_Pictographic": 1})
    incb = ranges(args.ucd / "DerivedCoreProperties.txt", {"Consonant": 1, "Linker": 2, "Extend": 3}, field=2)
    properties = ranges(args.ucd / "DerivedCoreProperties.txt", {"Cased": 1, "Case_Ignorable": 1})
    cased = [value for value in properties if value[2] == 1]
    # Re-read separately because both requested properties intentionally share an encoding value.
    cased = ranges(args.ucd / "DerivedCoreProperties.txt", {"Cased": 1})
    ignorable = ranges(args.ucd / "DerivedCoreProperties.txt", {"Case_Ignorable": 1})
    category_groups = {
        "decimal": {"Nd"},
        "letter": {"Lu", "Ll", "Lt", "Lm", "Lo"},
        "mark": {"Mn", "Mc", "Me"},
        "number": {"Nd", "Nl", "No"},
        "separator": {"Zs", "Zl", "Zp"},
        "punctuation": {"Pc", "Pd", "Ps", "Pe", "Pi", "Pf", "Po"},
        "symbol": {"Sm", "Sc", "Sk", "So"},
    }
    regex_categories = {
        name: [(first, last, 1) for first, last, category in categories if category in wanted]
        for name, wanted in category_groups.items()
    }
    alphabetic = ranges(args.ucd / "DerivedCoreProperties.txt", {"Alphabetic": 1})
    join_control = ranges(args.ucd / "PropList.txt", {"Join_Control": 1})
    whitespace = ranges(args.ucd / "PropList.txt", {"White_Space": 1})
    connector = [(first, last, 1) for first, last, category in categories if category == "Pc"]
    regex_word = alphabetic + regex_categories["mark"] + regex_categories["decimal"] + connector + join_control
    values = {
        "decomposition_keys": decomp[0], "decomposition_metadata": decomp[1], "decomposition_values": decomp[2],
        "combining_keys": ccc_keys, "combining_values": ccc_values,
        "composition_keys": composition_keys, "composition_values": composition_values,
        "lowercase_keys": lower_data[0], "lowercase_metadata": lower_data[1], "lowercase_values": lower_data[2],
        "uppercase_keys": upper_data[0], "uppercase_metadata": upper_data[1], "uppercase_values": upper_data[2],
        "fold_keys": fold_data[0], "fold_metadata": fold_data[1], "fold_values": fold_data[2],
        "grapheme_ranges": encode_ranges(grapheme), "extended_pictographic_ranges": encode_plain_ranges(pictographic),
        "incb_ranges": encode_ranges(incb),
        "cased_ranges": encode_plain_ranges(cased), "case_ignorable_ranges": encode_plain_ranges(ignorable),
        "regex_decimal_ranges": encode_plain_ranges(regex_categories["decimal"]),
        "regex_letter_ranges": encode_plain_ranges(regex_categories["letter"]),
        "regex_mark_ranges": encode_plain_ranges(regex_categories["mark"]),
        "regex_number_ranges": encode_plain_ranges(regex_categories["number"]),
        "regex_separator_ranges": encode_plain_ranges(regex_categories["separator"]),
        "regex_punctuation_ranges": encode_plain_ranges(regex_categories["punctuation"]),
        "regex_symbol_ranges": encode_plain_ranges(regex_categories["symbol"]),
        "regex_whitespace_ranges": encode_plain_ranges(whitespace),
        "regex_word_ranges": encode_plain_ranges(regex_word),
    }
    header = "// Generated from Unicode 17.0.0 UCD. Do not edit by hand.\n// Unicode data: https://www.unicode.org/license.txt\n\n"
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(header + "".join(function(name, value) for name, value in values.items()), encoding="utf-8")


if __name__ == "__main__":
    main()
