# Parked examples

Everything in this directory is the pre-0.2 form of the gallery: scripts written against
GeometricIntegrators 0.3/0.4, the removed `Simulation`/`run!`/HDF5 triad, `set_config`,
`getTableau*` constructors, and five different plotting backends. The problems that
[GeometricProblems.jl](https://github.com/JuliaGNI/GeometricProblems.jl) provides —
`lotka_volterra_2d/`, `massless_charged_particle/`, `point_vortices/`, `standard_map/` — have been
migrated to `src/` and `weave/`; the directories are kept here only for reference against the
published figures and are not part of the build.

The two remaining families **have not been migrated** and are the subject of this file.

## guiding_center_4d, charged_particles_3d

These depend on
[ChargedParticleDynamics.jl](https://github.com/JuliaPlasma/ChargedParticleDynamics.jl) for the
problems (`GuidingCenter4d.TokamakMediumCylindrical` and friends), the initial conditions, the
diagnostics and the plot recipes. Its released version 0.1.0 targets GeometricEquations 0.18 /
GeometricProblems 0.6 / ElectromagneticFields 0.5 and ships `Plots`/`RecipesBase` recipes, none of
which is compatible with the GeometricIntegrators 0.16 / GeometricProblems 0.7 stack the rest of
this gallery now uses. An upgrade is in progress upstream; these examples are revived once
**ChargedParticleDynamics v0.2.0** is released.

What that will involve, based on how the migrated examples turned out:

* **A problem module per case.** `src/guiding-center-4d.jl` in the shape of
  `src/massless-charged-particle.jl`: the `Δt`/`nt` constants from the per-case settings files
  (`tokamak_fast_particles/guiding_center_4d_fast_barely_passing.jl` and its siblings) and a
  `PLOT_RECIPES` bundle binding the problem's recipes. One module per particle case, since each has
  its own initial conditions and time step.
* **Plot recipes from CPD's Makie extension.** `guiding_center_4d.jl`'s `plottrajectory`
  (`:trajectoryRZ`, `:trajectory3d`), `plotenergyerror` and `plottoroidalmomentumerror` calls map
  onto the `ChargedParticlePlots` extension that the CPD working tree is growing. The
  `plot_solution`/`plot_phase_portrait`/`plot_traces` triple that `run_list` expects has to be
  named there, as `GeometricProblems` does for its own problems.
* **The toroidal momentum through the generic diagnostics.**
  `problem.compute_toroidal_momentum_error` becomes an entry in the `invariants` field of
  `PLOT_RECIPES`, handled by `GeometricProblems.Diagnostics.plot_invariant_error` — the same
  mechanism the point vortices use for their angular momentum. This requires the guiding-centre
  problems to declare the toroidal momentum among their `invariants`, as the point-vortex problems
  now do.
* **Poincaré invariants on the new interface.** `guiding_center_4d_poincare_invariant_{1st,2nd}.jl`
  and the `poincare_invariant_{1st,2nd}/` trees are built on the removed
  `PoincareInvariant1st(equ, loop, …)` / `evaluate_poincare_invariant` / `write_to_hdf5` API. They
  move onto PoincareInvariants 0.5 the way `src/standard-map.jl` does: `FirstPI`/`SecondPI` with the
  problem's own one- and two-form, `PIEnsembleProblem(prob, pinv, init)` with CPD's
  `guiding_center_4d_loop.jl`/`guiding_center_4d_surface.jl` parameterisations, `integrate`, then
  `compute!`. The HDF5 output disappears; `plot_invariant`, `plot_loop` and `plot_surface` come from
  the PoincareInvariants Makie extension.
* **The `*_comp` variants disappear.** `guiding_center_4d_fast_*_{firk,vprk}_comp.jl` differ from
  the plain scripts only in `set_config(:tab_compensated_summation, true)`, which no longer exists,
  so they would be exact duplicates.

## charged_particles_3d is broken independently of this

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
