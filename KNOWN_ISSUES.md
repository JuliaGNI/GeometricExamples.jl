# Known issues

### K2 · `README.md:72` names the old path of the weave smoke script.

- **location:** `README.md:72`
- **evidence:** the line says `julia --project test/test_scripts.jl`; the file is at
  `scripts/test_scripts.jl`. Fix: change the path.
- **kind:** docs
- **found:** 2026-09-27

### K3 · `src/standard-map.jl:39` names `test/runtests.jl`.

- **location:** `src/standard-map.jl:39`
- **evidence:** the comment says "`test/runtests.jl` pins it against the closed form"; the
  assertion is in `test/standard-map.jl`. Fix: change the comment.
- **kind:** docs
- **found:** 2026-09-27
