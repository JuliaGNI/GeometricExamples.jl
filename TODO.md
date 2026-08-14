# TODO

Work this gallery could carry but does not yet. Distinct from the *Known Gaps* section of
[`docs/src/index.md`](docs/src/index.md), which records what the current stack makes impossible;
everything here is possible now and simply unbuilt.


## Reinstate the formal Lagrangian Runge-Kutta methods

- [ ] Rebuild the point-vortex runs on `lodeproblem_formal_lagrangian`.

`FLRK` was commented out of GeometricIntegrators when this gallery was modernized, which is why the
family was dropped. It came back in **0.16.8** — before the update to 0.17, so the *Known Gaps*
entry claiming it was unavailable had already been stale for a while — and is still, on 0.18, a full
`LODEMethod` again, `FLRK(tableau)` or `FLRK(method::RKMethod)`, with its own integrator and cache
(`src/integrators/rk/integrators_flrk.jl` upstream). Nothing blocks the family any longer.

What it needs, none of which a dependency update should have done on its own:

* A `tableaus_flrk_gauss()` (and possibly Lobatto) list in `src/tableau_lists.jl`. There is no FLRK
  entry there at all today — the *Known Gaps* text used to claim there was.
* A page. `GeometricProblems` provides `lodeproblem_formal_lagrangian` for `PointVortices` and
  `PointVorticesLinear` only, so the natural home is one more point-vortex page beside the eight
  existing ones.
* The page has to land in `weave/`, `docs/weave.jl`, `docs/make.jl`, `docs/Makefile`, the CI matrix
  in `.github/workflows/Documentation.yaml` and `docs/src/index.md` **together**: a page named in
  `docs/make.jl` but not woven fails the whole `documenter` job, not just that page.
* Check what the pre-0.2 gallery ran the family with. The `examples/` tree that would have said was
  removed in `a6a6887`; the git history has it.

When it is built, the *Known Gaps* entry in `docs/src/index.md` should go and this one with it.
