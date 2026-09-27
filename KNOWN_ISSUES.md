# Known issues

### K1 · `test/tableau_lists.jl` is in `slow` but runs in about 2 s after compilation.

- **location:** `test/runtests.jl:11`
- **evidence:** `test/runtests.jl` puts `tableau_lists.jl` in `slow`. After compilation, in one
  process, its second run takes 2.08–2.19 s (940 pass); only its first, fresh run takes about
  381 s, almost all compilation. The layout rule sends a file to `slow` only above 60 s after
  compilation, so a `core` run skips the main smoke test of the method lists.
  `guiding-center-4d.jl` in `slow` is correct: 97.8–102.4 s after compilation. Fix: move its
  `@safetestset` line from `slow` to `core`.
- **kind:** defect
- **found:** 2026-09-27

### K2 · `README.md:72` names the old path of the weave smoke script.

- **location:** `README.md:72`
- **evidence:** the line says `julia --project test/test_scripts.jl`; the file is at
  `scripts/test_scripts.jl`. Fix: change the path.
- **kind:** docs
- **found:** 2026-09-27

### K3 · `src/standard-map.jl:39` names `test/runtests.jl`.

- **location:** `src/standard-map.jl:39`
- **evidence:** the comment says "`test/runtests.jl` pins it against the closed form"; the
  assertion is in `test/standard-map.jl`. `CHANGELOG.md:64`, in `[Unreleased]`, says the same.
  Fix: change the comment.
- **kind:** docs
- **found:** 2026-09-27

### K4 · `test/Project.toml` lists four dependencies that no test loads directly.

- **location:** `test/Project.toml`
- **evidence:** `GeometricIntegratorsBase`, `LinearAlgebra`, `Logging` and `SimpleSolvers` are
  loaded only by `src/common.jl`, inside the package module, not by a test file or by an included
  `src/<problem>.jl` script (`grep -n "^using\|^import" src/*.jl test/*.jl`). The `[Unreleased]`
  CHANGELOG sentence "also lists the packages that the included `src/<problem>.jl` scripts load"
  overstates the list for these four. Fix: drop the four entries and their bounds, or correct the
  sentence.
- **kind:** dead code
- **found:** 2026-09-27
