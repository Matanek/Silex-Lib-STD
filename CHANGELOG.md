# Changelog

## [Unreleased]

- Add `Collections.Dictionary.find(key)`: an owned optional lookup available
  on immutable dictionaries, preserving the existing mutable `get` borrow.
- Add `Text.UTF8.byte_count(text)` to measure UTF-8 bytes without allocating a
  list, including borrowed text and embedded NUL.
