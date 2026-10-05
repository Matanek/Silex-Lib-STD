# Changelog

## [Unreleased]

- Add single-atom negative Regex assertions `(?!atom)` without consuming
  input, plus explicit byte offsets on matches and captures.

- Add `Collections.Dictionary.find(key)`: an owned optional lookup available
  on immutable dictionaries, preserving the existing mutable `get` borrow.
- Add `Text.UTF8.byte_count(text)` to measure UTF-8 bytes without allocating a
  list, including borrowed text and embedded NUL.
