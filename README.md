# sml-stemmer

[![CI](https://github.com/sjqtentacles/sml-stemmer/actions/workflows/ci.yml/badge.svg)](https://github.com/sjqtentacles/sml-stemmer/actions/workflows/ci.yml)

English word stemming for Standard ML. Implements two algorithms:

- **Porter stemmer** — the classic 1980 algorithm (steps 1a through 5b);
  fast and widely used in IR systems. Output matches Porter's reference
  vocabulary (e.g. `agreed` → `agre`, `relational` → `relat`).
- **Snowball English** — a Porter2-style variant that additionally strips
  apostrophe possessives (step 0) before applying the Porter pipeline, so
  `dog's` and `dog` stem alike.

Both functions are purely functional, allocation-light string-to-string maps.

## API sketch

```sml
Stemmer.porter "running"          (* "run" *)
Stemmer.porter "generously"       (* "gener" *)
Stemmer.porter "happiness"        (* "happi" *)
Stemmer.porter "agreed"           (* "agre" *)
Stemmer.porter "relational"       (* "relat" *)

Stemmer.snowballEnglish "running" (* "run" *)
Stemmer.snowballEnglish "dog's"   (* "dog" *)

Stemmer.stem "cats"               (* "cat"; alias for porter *)
Stemmer.stemAll ["cats","ponies"] (* ["cat","poni"] *)
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

## Example

`make example` builds and runs [`examples/demo.sml`](examples/demo.sml), which
prints `porter` vs `snowballEnglish` side by side for a handful of words
spanning different suffix classes (`dog's` shows the two diverge, since only
Snowball strips the possessive), then batch-stems the same list with
`stemAll` (output is byte-identical under MLton and Poly/ML):

```
Porter vs Snowball-English stemmer:

  word        porter      snowballEnglish
  running     run         run
  flies       fli         fli
  happiness   happi       happi
  dog's       dog'        dog
  caresses    caress      caress
  agreed      agre        agre

stemAll on the same word list:
  [run, fli, happi, dog', caress, agre]
```

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
