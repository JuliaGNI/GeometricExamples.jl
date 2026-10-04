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

### K4 · `src/guiding-center-4d-poincare.jl:47` names a stale value of the tokamak loop's first invariant.

- **location:** `src/guiding-center-4d-poincare.jl:47`
- **evidence:** the comment says the first invariant of the tokamak loop "comes out as
  -0.18748739226999156 at 100, 200, 400 and 800 sample points alike"; over `TIMESPAN_END = 1e3` at
  `N = 100` and `N = 200`, `compute!(pinv, sol, parameters(prob))[begin]` is
  -0.17184534083074765, on `origin/main` (ChargedParticleDynamics 0.4.1) and on this branch
  (0.5.2) alike. Fix: correct the value.
- **kind:** docs
- **found:** 2026-10-04
