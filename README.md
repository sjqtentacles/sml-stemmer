# sml-stemmer

[![CI](https://github.com/sjqtentacles/sml-stemmer/actions/workflows/ci.yml/badge.svg)](https://github.com/sjqtentacles/sml-stemmer/actions/workflows/ci.yml)

English word stemming for Standard ML. Implements two algorithms:

- **Porter stemmer** — the classic 1980 algorithm; fast and widely used in IR systems.
- **Snowball English** — an improved Porter2 variant with better handling of
  irregular words.

Both functions are purely functional, allocation-free string-to-string maps.

## API sketch

```sml
Stemmer.porter "running"          (* "run" *)
Stemmer.porter "generously"       (* "generous" *)
Stemmer.porter "happiness"        (* "happi" *)

Stemmer.snowballEnglish "running"      (* "run" *)
Stemmer.snowballEnglish "generously"   (* "generous" *)
Stemmer.snowballEnglish "happiness"    (* "happi" *)
```

## When to use which

| | Porter | Snowball English |
|---|---|---|
| Speed | Faster | ~same |
| Accuracy | Good | Better on edge cases |
| Stability | Very stable | Stable |
| Use case | Legacy IR systems | New projects |

## Known limitations

- **English only** — no support for other languages (French, German, etc.).
- Stemming is not lemmatisation: stems are not guaranteed to be dictionary words.
- Very short words (≤ 2 characters) are returned unchanged.
- Proper nouns and acronyms may be incorrectly truncated.

## Installing with smlpkg

```sh
smlpkg add github.com/sjqtentacles/sml-stemmer
smlpkg sync
```

Reference from your `.mlb`:

```
lib/github.com/sjqtentacles/sml-stemmer/stemmer.mlb
```

## Building and testing

```sh
make test        # MLton
make test-poly   # Poly/ML
make all-tests   # both
make clean
```

## Project layout

```
sml.pkg
Makefile
lib/github.com/sjqtentacles/sml-stemmer/
  stemmer.sig     STEMMER signature
  stemmer.sml     Porter and Snowball English implementations
  stemmer.mlb
test/
  test.sml        known-word stem assertion suite
```

## License

MIT. See [LICENSE](LICENSE).
