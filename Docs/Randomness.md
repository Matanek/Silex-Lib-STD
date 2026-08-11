# Randomness

`Randomizer()` seeds a pseudo-random sequence from the system. A numeric seed
produces a repeatable sequence for tests, simulations and procedural content.

`get_int(minimum, maximum)` and `get_float(minimum, maximum)` use a half-open
interval. Both require `minimum < maximum`. `get_bool()` produces an unbiased
boolean from the sequence. See [RollDice.sx](../Examples/Random/RollDice.sx).

`Algorithms.Random.choose` borrows one value from a non-empty slice.
`shuffle` reorders a mutable slice in place. See
[ShufflePlaylist.sx](../Examples/Random/ShufflePlaylist.sx).

`Randomizer` is not a cryptographic generator. Tokens, keys, salts and other
security-sensitive bytes must come from `Crypto.random_bytes`.
