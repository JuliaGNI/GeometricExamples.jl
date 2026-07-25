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
| `guiding_center_4d/` Poincaré invariants | migrated — see below |
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

## guiding_center_4d — Poincaré invariants: **migrated**

`guiding_center_4d_poincare_invariant_{1st,2nd}.jl` and the `poincare_invariant_{1st,2nd}/` trees are
now `src/guiding-center-4d-poincare.jl` plus one thin module per invariant, and the six pages
`weave/guiding-center-4d-poincare-{1st,2nd}-<geometry>-<family>.jmd`. The scripts here are kept for
reference against the published figures.

How the pieces map:

| pre-0.2 | v0.2 |
|---|---|
| `PoincareInvariant1st(init, f_loop, ϑ, Δt, 4, nloop, ntime, nsave)` | `guiding_center_4d_poincare_invariant_1st(N)`, then `guiding_center_4d_loop_ensemble(prob, pinv)`, `integrate` and `compute!(pinv, sol, parameters(prob))` |
| `PoincareInvariant2nd(…, ω, …, nx, ny, …)` | `guiding_center_4d_poincare_invariant_2nd(N)`, whose default Chebyshev plan samples the surface at Padua points, and `guiding_center_4d_surface_ensemble` |
| `TokamakFastLoop` / `TokamakFastSurface` | `GuidingCenter4d.TokamakMediumCylindrical` — same equilibrium, same loop, surface and `μ = 10⁻³` |
| `SymmetricLoop` / `SymmetricSurface` | `GuidingCenter4d.SymmetricField` — same parameterisations, `μ = 10⁻²` |
| four `*_dt{1,2,5,10}.jl` scripts per page | the `TIMESTEPS` sweep, overlaid in one figure per method |
| `_poincare_1st_q` / `_poincare_2nd_q` | `_invariant`, one curve per time step |
| `_loop`, `_trajectories`, `_area` | `_loop`, `_trajectories`, `_surface` |
| `Simulation`/`run!` + `write_to_hdf5` | `integrate` on the `EnsembleProblem`; no solution files are written |

* **The two equilibria cannot be `using`ed together.** Every guiding-centre submodule exports the
  same names, one method each, closing over its own loop and surface, so the driver reaches both
  through a `GEOMETRIES` table and qualifies every call. This is why the geometry is a page-level
  argument rather than a second set of thin modules.
* `SymmetricSurface` used to hand the four Hessians `D²ϑ₁`–`D²ϑ₄` of the one-form to
  `PoincareInvariant2nd` and offered trapezoidal variants alongside. Both the variants and the
  Hessians are gone from CPD with the 0.5 rewrite; neither was ever called from here.
* `guiding_center_4d_symmetric_poincare_invariant_1st.jl` in this directory is a stub that cannot
  have produced a figure: it defines none of `Δt`, `ntime`, `nloop`, `pinv` or `tableau_list` that
  the driver it includes reads, and imports two names (`plot_loop`, `plot_trajectories`) that never
  existed. The eight `poincare_invariant_2nd/*_fast_*.jl` scripts are likewise broken as committed —
  their `include("guiding_center_4d_settings_*.jl")` is missing the `../` that the sibling scripts
  have. Nothing is lost by not reproducing either.
* **What did not come back:** the `_poincare_*_p` and `_poincare_*_l` curves, and the run lengths.
  See the *Known Gaps* section of the documentation (`docs/src/index.md`) for both.

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
