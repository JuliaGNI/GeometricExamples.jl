# Superseded examples

Everything in this directory is the pre-0.2 form of the gallery: scripts written against
GeometricIntegrators 0.3/0.4, the removed `Simulation`/`run!`/HDF5 triad, `set_config`,
`getTableau*` constructors, and five different plotting backends. **None of it is part of the
build**; the directories are kept for reference against the published figures.

Migration status, family by family:

| | |
|---|---|
| `lotka_volterra_2d/`, `massless_charged_particle/`, `point_vortices/`, `standard_map/` | migrated to `src/` + `weave/` |
| `guiding_center_4d/` trajectory runs | migrated — see below |
| `guiding_center_4d/` Poincaré invariants | not yet, everything needed is in place |
| `charged_particles_3d/` | not migrated, and broken before the migration too |

## guiding_center_4d — trajectory pages: **migrated**

The four orbits of the medium-size tokamak in cylindrical coordinates
(`tokamak_fast_particles/guiding_center_4d_fast_*.jl`) are now built by
`src/guiding-center-4d.jl` plus one thin module per orbit, and the pages
`weave/guiding-center-4d-<orbit>-<family>.jmd`. The scripts here are kept for reference against the
published figures.

How the pieces map:

* The per-case `Δt`/`ntime` of the old settings files are the `CASES` table in
  `src/guiding-center-4d.jl`.
* `plottrajectory(sol; plottype = :trajectoryRZ)` and `:trajectory3d` and the component traces
  become the three recipe slots `plot_solution`, `plot_phase_portrait` and `plot_traces`. They are
  *adapters*: the `ChargedParticlePlots` extension takes plain coordinate vectors and returns
  `(figure, axis)` — which is what lets it draw the orbit in cartesian 3-space rather than in the
  first two state components — so the adapters do the downsampling and truncation the
  GeometricProblems recipes would otherwise do, and drop the axis.
* `compute_toroidal_momentum_error` becomes an entry in the `invariants` field of `PLOT_RECIPES`,
  handled by `GeometricProblems.Diagnostics.plot_invariant_error`, as the point vortices' angular
  momentum is. It is passed as the *function* rather than a key, because the guiding-centre problems
  declare only the energy among their `invariants`.
* `periodic = false`: the toroidal angle is periodic and wrapping it tears the trajectory figures
  apart. The old recipes unwrapped it; the solution now simply keeps winding.
* **The `*_comp` variants disappear.** `guiding_center_4d_fast_*_{firk,vprk}_comp.jl` differ from
  the plain scripts only in `set_config(:tab_compensated_summation, true)`, which no longer exists,
  so they would be exact duplicates.

`ChargedParticleDynamics` is pinned to its `finish-guiding-center-3d-upgrade` branch by revision in
`Project.toml`; that branch carries the interface changes and is not yet merged or released.

## guiding_center_4d — Poincaré invariants: **not yet migrated**

`guiding_center_4d_poincare_invariant_{1st,2nd}.jl` and the `poincare_invariant_{1st,2nd}/` trees
are built on the removed `PoincareInvariant1st(equ, loop, …)` / `evaluate_poincare_invariant` /
`write_to_hdf5` API. Everything needed to rebuild them is now on the CPD branch:
`guiding_center_4d_poincare_invariant_1st(N)` and `..._2nd(N)` return a noncanonical `FirstPI` or
`SecondPI` built from the guiding-centre one- and two-form, and
`guiding_center_4d_loop_ensemble(prob, pinv)` samples the parameterisation into an
`EnsembleProblem`. `src/standard-map.jl` is the worked example of the same pattern. The HDF5 output
disappears; the figures come from `plot_poincare_invariant_error`, `plot_poincare_loop` and
`plot_poincare_surface` in CPD's Makie extension, which draw in cartesian 3-space.

## charged_particles_3d: **not migrated, and broken independently**

`charged_particles_3d/*.jl` do not run and did not run before the migration either: they
`include("guiding_center_4d_settings_firk.jl")` and `include("guiding_center_4d.jl")`, neither of
which exists in that directory — the paths point at files that live in `../guiding_center_4d/`.
Whoever revives them will have to decide what was intended; it is not recoverable from the scripts
themselves.

## Everything else that did not survive the migration

See the *Known Gaps* section of the documentation (`docs/src/index.md`) for the integrators,
outputs and configuration knobs that have no counterpart in GeometricIntegrators 0.16 — formal
Lagrangian Runge-Kutta methods, the internal-stage projection, HDF5 solution output, compensated
summation, the splitting methods and the CGVI code path.
