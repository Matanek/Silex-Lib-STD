# Iterators and algorithms

`Iterator<T>` is a finite, consuming sequence. `next()` advances and returns
`T?`; `remaining()` and `is_empty()` describe the unconsumed suffix. Arrays and
slices enter this model through `Iterator.iterate`.

`Algorithms.Iteration` consumes the iterator passed to it:

- `any` and `all` answer predicate questions;
- `count_where` counts matches;
- `find` returns the first match;
- `contains` accepts an explicit equality function;
- `map` and `filter` return new consuming iterators.

Create a new iterator to repeat a traversal. Collections return snapshot
iterators, so advancing one does not mutate the source collection. See
[AnalyzeValues.sx](Recipes/Collections/AnalyzeValues.md).

`Algorithms.Sort.sort` orders a mutable slice in place using the supplied
strict ordering callback. `Algorithms.Random.choose` requires a non-empty
slice; `shuffle` mutates a slice in place. Their `Randomizer` extension methods
provide the same operations when that reading is more natural.
