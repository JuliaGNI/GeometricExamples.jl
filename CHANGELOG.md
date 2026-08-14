# Changelog

All notable changes to GeometricExamples.jl are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Changed

- **The solver stack moves to GeometricIntegrators 0.18, GeometricIntegratorsBase 0.6 and
  SimpleSolvers 0.11.** The three bounds move together: 0.18 requires GeometricIntegratorsBase 0.6,
  which requires SimpleSolvers 0.11. RungeKutta 0.6, QuadratureRules 0.2 and CompactBasisFunctions
  0.3 arrive transitively and take no `[compat]` entry of their own. ChargedParticleDynamics,
  GeometricProblems, PoincareInvariants and CairoMakie are unchanged.

  **Every step count and every trajectory in this gallery is unchanged.** The one visible
  difference is a failure message: SimpleSolvers 0.11 rejects any non-finite search direction where
  0.10.1 tested only for `NaN`, so `vprk_lobatto_IIIA4_p{symmetric,midpoint}` on the point vortices
  — which still stop after 23 steps — now report *solver error – non-finite direction vector*
  instead of *solver error – NaN detected in direction vector*. (The same fix is not cosmetic
  everywhere: in the SPARK companion package it takes eleven runs that used to crash all the way
  to the end of their interval.)

- **`SymplecticEulerA` is now GeometricIntegratorsBase's method, not the Runge-Kutta one.**
  GeometricIntegratorsBase 0.5.2 added explicit symplectic Euler A/B, implicit midpoint and
  Crank-Nicolson integrators, so GeometricIntegrators 0.18 suffixed its four colliding Runge-Kutta
  methods — `SymplecticEulerA` → `SymplecticEulerARK`, and likewise `SymplecticEulerB`,
  `ImplicitMidpoint` and `CrankNicolson`. `src/standard-map.jl` is the only place in this gallery
  that uses any of them, and it keeps the unsuffixed name deliberately: the new method assumes a
  separable Hamiltonian, which the standard map is, and under that assumption takes the same two
  substeps in the same order without a nonlinear solve at all. The map is identical, and
  `test/runtests.jl` pins it against the closed form.

- **`max_iterations = 100` stays, again.** GeometricIntegratorsBase 0.6 added `f_stall_window = 50`
  to its `default_options` — retire a solve that spends fifty iterations without halving its
  residual — which is precisely the case this gallery keeps the cap for. Measured on 0.18/0.6.2, it
  does not replace it. For a *projected* method the option never reaches the solver at all, because
  GeometricIntegrators' projection path still replaces the defaults with the caller's options
  rather than merging them (`src/projections/projection.jl:51`); the nine point-vortex runs the cap
  is about take 21 s with it and 248 s without, at either setting of `f_stall_window`, with
  identical step counts. For an *unprojected* method it does reach the solver, and changes nothing:
  over 132 combinations — the Lobatto IIIA–IIIG, Gauss and Radau VPRK families against the point
  vortices, both Lotka-Volterra gauges and the massless charged particle — not one step count or
  failure mode differs between `f_stall_window = 50` and `0`. The comment above `SOLVER_OPTIONS`
  records this alongside the earlier measurement.

### Added

- **The four guiding-centre orbits are back.** The barely and deeply passing and trapped orbits of
  the four-dimensional guiding centre dynamics in the medium-size tokamak equilibrium in cylindrical
  coordinates — the largest part of the pre-0.2 gallery — are rebuilt as `src/guiding-center-4d.jl`
  plus one thin module per orbit, with five pages each (the implicit Runge-Kutta and projected VPRK
  families the pre-0.2 `runall.sh` ran for them). That takes the gallery from 32 to 52 pages.

  The problems come from `ChargedParticleDynamics`, whose plotting extension is deliberately lower
  level than the GeometricProblems recipes: it takes plain coordinate vectors and returns
  `(figure, axis)`, which is what lets it draw the orbit in cartesian 3-space and over the
  equilibrium's flux surfaces rather than in the first two state components. `run_list` therefore
  gets *adapters* — `plot_solution` (poloidal `R`–`Z`), `plot_phase_portrait` (cartesian 3d) and
  `plot_traces` (the four state components) — which do the downsampling and truncation the recipes
  would otherwise do and drop the axis.

  The toroidal momentum is shown alongside the energy through the `invariants` field of the recipe
  bundle, as the point vortices' angular momentum is. It is passed as the function rather than a key,
  since the guiding-centre problems declare only the energy among their `invariants`. The orbits run
  with `periodic = false`: the toroidal angle is periodic and wrapping it tears the trajectory
  figures apart.

- **The small tokamak's four orbits**, from
  `examples/guiding_center_4d/tokamak_slow_particles/`, as eight pages. Its particles are far slower
  than the medium tokamak's — `u ~ 8E-4` against `3E-1` — so they run at `Δt = 800` rather than
  `2.5`, which is the time step those scripts used, over the same 12500 steps as every other case.
  The scripts asked for 1.25·10⁶ steps, but at 12500 the orbits still close between 208 and 1239
  times, so the longer interval buys nothing for the figures.

  These cases had never run: they read a `run_id` they never define, no `_firk`/`_vprk` wrapper was
  written for them and no runner references them, so there is no published figure set to reproduce —
  only the configuration. For the same reason there is no family set to match, and they get the two
  Gauss families rather than all five. That takes the gallery to 65 pages.

  `src/guiding-center-4d.jl` reaches its equilibria through an `EQUILIBRIA` table instead of
  `using` one of them, as `src/guiding-center-4d-poincare.jl` already had to: every guiding-centre
  submodule of ChargedParticleDynamics exports the same names, so no two can be brought into scope
  together. The plot adapters therefore take the equilibrium as their first argument and
  `plot_recipes(equ)` binds it into the bundle `run_list` consumes, since it is a property of the
  case rather than of the solution. `CASES` gained the equilibrium and names its initial conditions
  by symbol; the medium-tokamak cases keep their unprefixed names, which the existing problem names,
  page files and documentation are built on.

- **The guiding-centre Poincaré integral invariants are back**, the last family the modernization
  had left behind. `src/guiding-center-4d-poincare.jl` plus one thin module per invariant replace
  `examples/guiding_center_4d/guiding_center_4d_poincare_invariant_{1st,2nd}.jl` and the twenty-four
  `poincare_invariant_{1st,2nd}/*_dt*.jl` run scripts, which were written against the
  `PoincareInvariant1st(equ, loop, …)` / `evaluate_poincare_invariant` / `write_to_hdf5` API removed
  in `PoincareInvariants` 0.4. Six pages, the six the pre-0.2 gallery published: both invariants on
  the medium tokamak with the Gauss-Legendre Runge-Kutta and the projected Gauss-Legendre VPRK
  methods, and on the symmetric quadratic field with the projected VPRK methods only. That takes the
  gallery from 52 to 58 pages.

  The invariants are *noncanonical*, built from the guiding-centre one-form `ϑ = A + u b` and
  `ω = dϑ` rather than from a canonical pairing, so `compute!` and
  `PoincareInvariants.plot_invariant` are passed the problem's parameters. `plot_invariant` has to be
  qualified: `ChargedParticleDynamics` exports one of its own and these pages need both packages.

  Two things differ from the trajectory family. The equilibrium is a page-level argument rather than
  a thin module per geometry, because every guiding-centre submodule of CPD exports the *same* names
  — one method each, closing over its own loop, surface and magnetic moment — so the two cannot be
  `using`ed together and the driver reaches them through a `GEOMETRIES` table. And the four time
  steps `Δt ∈ {10, 5, 2, 1}` that the pre-0.2 gallery gave a page each are overlaid as four curves in
  one figure per method: the same computation, with the comparison those four pages were making on a
  single pair of axes.

  Run lengths and sample counts are reduced — 10³ time units instead of 5·10⁴, 200 loop points and
  231 Padua points instead of up to 2000 and 200×200 — because every sample point is one ensemble
  member with its own implicit integrator and each run is repeated four times over. Measured over the
  reduced interval, the first invariant of the tokamak loop is identical to ten digits at 100, 200,
  400 and 800 sample points, while the drift it measures spans six orders of magnitude between the
  methods: `VPRKGauss(2)` loses 3E-1 of it at `Δt = 10` and 3E-3 at `Δt = 1`, its symmetric
  projection 3E-5 and 5E-11. What limits these runs is the integrator, not the quadrature on the
  advected loop or surface.

  The figures come from CPD's Makie extension, which draws in cartesian 3-space, and so need the same
  kind of adapters as the trajectory pages: `_cartesian_slices` gathers one coordinate vector per
  saved time out of the `EnsembleSolution` for the advected loop or surface, `_cartesian_orbits` the
  same data per member for the bundle of orbits. Unlike `src/standard-map.jl`, the second invariant
  needs no second grid object — `plot_poincare_surface` scatters its points instead of reshaping
  them, so the accurate Chebyshev invariant serves both the number and the figure.

- **`TODO.md`**, for what the current stack would carry if someone wrote the pages, as against the
  *Known Gaps* section of the documentation, which is for what it makes impossible. It opens with
  the formal Lagrangian Runge-Kutta methods; see *Changed* below.

### Changed

- **The dependency stack moves to ChargedParticleDynamics 0.4, ElectromagneticFields 0.8,
  GeometricIntegrators 0.17, GeometricIntegratorsBase 0.5, GeometricProblems 0.8 and SimpleSolvers
  0.10.** EulerLagrange 0.5 arrives transitively through GeometricProblems and ElectromagneticFields
  through ChargedParticleDynamics, so neither takes a `[compat]` entry of its own.

  **This is not value-preserving, and the guiding-centre orbits are the reason.**
  ElectromagneticFields 0.7.0 corrected an orientation error in the Hodge star, which had been handed
  the unsigned volume element `|det DF|`, so `B` was reversed in the four left-handed charts. Both
  equilibria this gallery uses — the medium and small tokamaks in cylindrical `(R, Z, φ)` coordinates
  — are built on one of them, so every trajectory and Poincaré page over them shows a different orbit
  than the pages published from 0.2. The models are exactly equivariant under the change: `ϑ = A + u b`
  and `H = ½u² + μ|B| + φ` are both invariant under `b → -b` together with `u → -u`, so the old
  dynamics at parallel velocity `u` *is* the new dynamics at `-u`. Everything cartesian is untouched,
  including the `SymmetricField` of the Poincaré pages. ChargedParticleDynamics 0.4 additionally drops
  a hand-rolled sign compensation on `uᵢ` in the small tokamak's `GuidingCenter4d` modules, which had
  been correcting for the reversed field, so those four cases again start the same physical particle
  as the medium tokamak's.

  The solver half of the stack changed no interface this gallery uses. ChargedParticleDynamics 0.3
  changed a great many, renaming every problem constructor to the `GeometricProblems` scheme with no
  deprecation shims:

  | Was | Is |
  |---|---|
  | `guiding_center_4d_{ode,iode}` | `{ode,iode}problem` |
  | `guiding_center_4d_{loop,surface}_{ode,iode}` | `{loop,surface}_{ode,iode}problem` |
  | `guiding_center_4d_{loop,surface}_ensemble` | `{loop,surface}_ensemble` |
  | `guiding_center_4d_poincare_invariant_{1st,2nd}` | `poincare_invariant_{1st,2nd}` |
  | `tspan` / `tstep` | `timespan` / `timestep` |

  One change there is not a rename: `initial_conditions_*` now returns the named tuple
  `(q = …, params = …)` and `parameters` is a keyword, so `_problem` in `src/guiding-center-4d.jl`
  passes that tuple whole where it used to splat it into two positional arguments. The renames also
  make the equilibrium submodules collide with the problem modules of `GeometricProblems` itself; the
  `EQUILIBRIA` and `GEOMETRIES` tables were already there because the submodules collide with each
  other, and are now doubly necessary.

  Re-verified against 0.17 and still true: `VPRKpInternal` builds an `InternalStageProjection` that
  has no integrator, and `Simulations`/HDF5 output is still commented out upstream.

- **Solver warnings are silenced through the solver rather than the logger.** SimpleSolvers 0.10
  builds a line search with its solver's `Options`, so `verbosity = 0` finally reaches the
  per-iteration line-search warnings that made up almost all of a weave log; `quiet_solver_warnings!`
  now drops `SOLVER_VERBOSITY` to 0 and `:SimpleSolvers` leaves `QUIET_LOG_MODULES`. The
  `QuietLogger` stays for the plotting stack, whose `No strict ticks found` has neither a verbosity
  switch nor a `maxlog`. Since the verbosity is settable it cannot live in the `const SOLVER_OPTIONS`
  tuple; `solver_options()` folds the two together and is what `integrate_partial` and the Poincaré
  ensemble runs build their integrators with.

- **`max_iterations = 100` stays, where the three publication companion packages dropped theirs.**
  SimpleSolvers 0.10's `max_stalls = 2` retires a solve after two steps that leave the iterate
  unmoved, which made the cap redundant in those packages. It is not redundant here: `max_stalls`
  never fires on a solve whose iterate keeps *moving* without converging, and that solve is then
  bounded by nothing but `max_iterations`, whose default is 1000. Measured over every page this
  gallery builds, at 1000 time steps per run, the cap is worth **96 s against 297 s**. Almost all of
  the difference is four point-vortex runs that complete their thousand steps either way —
  `vprk_lobatto_IIIB{3,4}_p{symmetric,midpoint}`, 3.5–5.1 s each with the cap and 43–62 s without —
  and the same shape appears at about six-fold wherever a run sits near its residual floor. Dropping
  it would also cost figures rather than gain them: `vprk_lobatto_IIIA4_p{symmetric,midpoint}` on
  the point vortices fall from 23 completed steps to none, the stagnation detector retiring them
  before the cap would have. (The `IIIA3` pair fails on a singular matrix at the first step with or
  without the cap; an earlier draft of this entry counted them in.) The comment above
  `SOLVER_OPTIONS` records this, since the shared value is exactly what invites someone to align the
  four packages again.

- **The formal Lagrangian Runge-Kutta methods are work rather than a gap.** `FLRK` was commented out
  of GeometricIntegrators when this gallery was modernized, which is why the point-vortex runs on
  `lodeproblem_formal_lagrangian` were dropped. It came back in **0.16.8**, before this update, so the
  *Known Gaps* entry claiming it unavailable had already been stale at the 0.16.9 the gallery
  resolved — as had its claim that `src/tableau_lists.jl` recorded the gap, which no revision ever
  did. The family is now tracked in `TODO.md`.

- **The massless charged particle runs 10⁴ time steps instead of 10⁵, and has no Lobatto VPRK
  page.** This workflow had never run before this release, so the cost of its pages had never been
  measured: on the CI runners its `vprk-gauss`, `vprk-lobatto` and `vprk-lobatto-symplectic` pages
  each exceeded even a four hour job timeout, while `point-vortices` runs the same 126-method
  Lobatto matrix in 49 minutes — at 10⁴ steps rather than 10⁵. It is now the only problem whose run
  length is not the published one; the 36-run Gauss and symplectic-Lobatto matrices cover the same
  ground as the dropped 126-run page. A single missing page fails the whole `documenter` job
  (`'…-vprk-gauss.md' is not an existing page!`), so a page that cannot be built has to leave the
  registries rather than be left failing.

- **The weave job's `timeout-minutes` is 240**, up from 120, which killed the two tokamak
  `vprk-gauss` invariant pages. Measured on the CI runners: 19-20 min for the six-method
  `firk-gauss` pages, 46-49 min for the symmetric field's 36-method `vprk-gauss` pages, and over
  120 min for the tokamak's, which are stiffer. Not a solver-configuration problem, though it looks
  like one: this equilibrium's residual floor is `‖ϑ‖·eps = 2.2E-16`, well below the `f_abstol` the
  gallery asks for, the solver converges in two Newton iterations and none of 4000 solves reached
  its iteration cap. See ChargedParticleDynamics' `scripts/study_solver_tolerances.jl` for the
  ITER-scale equilibria where too tight an `f_abstol` genuinely is the problem.

- **`_write_page` moved from `src/standard-map.jl` into `src/common.jl`.** It writes a page as a flat
  list of figures, which is what both the standard map's and the guiding centre's invariant pages
  need; `write_plots`, with its fixed trajectory section skeleton, is not applicable to either.

- **`ChargedParticleDynamics` is a dependency again.** 0.2.0 was the release that carried the
  interface changes the examples need — the update to GeometricEquations 0.21 /
  GeometricSolutions 0.6, the `PoincareInvariants` 0.5 rewrite of the 4d loop and surface
  invariants, and the `ChargedParticlePlots` Makie extension. The bound has since moved on to
  `"0.4"`; see the stack entry at the top of this section.

  For most of this release cycle it was a `[sources]` pin on the branch carrying those changes,
  which had two consequences now undone. It forced a **Julia 1.11 floor**, since `[sources]` is a
  Pkg 1.11 feature and 1.10 silently ignored the pin, resolved the registered 0.1.0 and failed on
  its `GeometricProblems = "0.6"` bound; the floor is back to 1.10 and CI tests `lts` again. And it
  broke the build outright when the branch was deleted on merge — a branch pin has no guarantee of
  outliving the branch, which is worth remembering the next time one looks expedient.

### Removed

- **The `examples/` directory**, the pre-0.2 form of the gallery: 83 scripts — 77 Julia files and
  six shell runners — written against GeometricIntegrators 0.3/0.4, the removed
  `Simulation`/`run!`/HDF5 triad, `set_config`, `getTableau*` constructors and five plotting
  backends. Every family it covered is now in `src/` + `weave/`, and the git history holds the
  originals; what is worth carrying forward rather than looking up is recorded here.

  Its README described the directory as kept "for reference against the published figures", but those
  figures were never committed — the 221 PNGs archived beside the point-vortex and standard-map
  scripts were untracked working-tree files throughout, so no clone ever had them. The published
  figures are the papers'.

  **The one piece of functionality that did not come across** is
  `point_vortices/point_vortices_convergence_comparison.jl`, which refined a time step twelve times
  from `Δt = 0.2` and overlaid the five VPRK projections on shared axes. `src/convergence.jl` does
  the study, but writes a `_convergence`/`_order` figure per method instead of one comparing them,
  and it measures the error against a reference run rather than between successive refinements. An
  overlay variant of `run_convergence` would restore it.

  **Four things in there had never run at all**, so nothing was lost by not porting them, and it is
  worth recording that the omissions were not oversights:
  - `charged_particles_3d/*.jl` `include` settings and driver files that do not exist in that
    directory — the paths point into `../guiding_center_4d/`. Reviving them means deciding what was
    intended; it is not recoverable from the scripts.
  - `guiding_center_4d/papers/*.jl` call `get_tableau_list_vprk_papers()` and
    `get_tableau_list_vprk_lob()`, which exist in no committed revision of `src/`.
  - `guiding_center_4d/guiding_center_4d_symmetric_poincare_invariant_1st.jl` defines none of the
    `Δt`, `ntime`, `nloop`, `pinv` or `tableau_list` the driver it includes reads, and imports two
    names (`plot_loop`, `plot_trajectories`) that never existed.
  - `guiding_center_4d/tokamak_slow_particles/*.jl` read a `run_id` they never define and had no
    driver wrapper, which is why the small tokamak's pages reproduce a configuration and not a
    figure set. Also `guiding_center_4d/poincare_invariant_2nd/*_fast_*.jl`, whose
    `include("guiding_center_4d_settings_*.jl")` is missing the `../` its siblings have, and
    `lotka_volterra_4d/`, which was an empty directory.

  The `Δt` and step counts of the old settings files survive as the `CASES` table of
  `src/guiding-center-4d.jl` and the `Δt`/`nt` constants at the top of each problem module. Those
  comments still name the pre-0.2 script each value came from, and are kept for provenance: the
  `examples/…` paths in them, and in `docs/weave.jl`, resolve in the git history rather than in the
  working tree.

### Known limitations

The **3d charged particle** remains unmigrated and was already broken before the modernization. Of the
three error curves each published Poincaré invariant run drew, only the invariant of the one-form
survives: `PoincareInvariants` 0.5 computes one invariant from the form it is handed, and a projected
solution no longer carries the `λ` series the third one needed. See the *Known Gaps* section of the
documentation.

**No documentation build has been run since the move to ChargedParticleDynamics 0.4.** The test
suite covers the renamed constructors and the plot adapters — 2902 assertions, all passing — but
every guiding-centre figure will be redrawn with the corrected field orientation, and nothing has
looked at the result yet.


## [0.2.0] - 2026-07-25

The gallery is modernized from the 2018–2020 JuliaGNI ecosystem to GeometricIntegrators 0.16,
GeometricProblems 0.7, PoincareInvariants 0.5 and CairoMakie 0.15, and adopts the Weave +
Documenter architecture of the three publication companion packages
(`degenerate-variational-integrators`, `spark-methods-for-degenerate-lagrangian-systems`,
`srk-methods-for-degenerate-lagrangian-systems`).

Nothing in the previous version ran: `Project.toml` pinned `GeometricIntegrators = "0.3, 0.4"`, and
the scripts called the since-removed `Simulation`/`run!`/HDF5 triad, `set_config`, the `getTableau*`
constructors, `Pkg.installed`, `Pkg.dir`, `readstring`, `info`/`warn`, `linspace` and
`zeros(::Array)`, across five plotting backends.

### Added

- **A Weave + Documenter gallery.** One `src/<problem>.jl` module per problem binds that problem's
  plot recipes into a `run_list` wrapper; one `weave/<problem>-<page>.jmd` per method family runs it;
  `docs/weave.jl` weaves a page into `docs/src/<problem>/` and `docs/make.jl` builds the site. The
  32 pages of the current gallery are:

  | problem | pages |
  |---|---|
  | Lotka-Volterra 2d | `erk`, `firk-gauss`, `firk-lobatto`, `vprk-gauss`, `vprk-srk3`, `vprk-lobatto`, `vprk-lobatto-symplectic`, `vprk-radau` |
  | Lotka-Volterra 2d (singular Lagrangian) | the five `vprk-*` pages |
  | Massless charged particle | as Lotka-Volterra 2d |
  | Point vortices | as Lotka-Volterra 2d, plus `convergence` |
  | Standard map | `poincare-1st`, `poincare-2nd` |

  The singular Lotka-Volterra gauge has no explicit pages: the gauge affects only the variational
  formulation, so its `odeproblem` — and hence its `erk` and `firk-*` pages — would duplicate the
  standard gauge's.
- **`src/common.jl`**, the run driver, ported from the publication companion packages: a shared
  CairoMakie theme, `run_list`, `make_plots`, `write_plots`, and `integrate_partial`, which
  integrates step by step so that a crash keeps the trajectory up to the last good step instead of
  discarding the run. Comparing methods that do and do not preserve the geometric structure is the
  point of these examples, so a diverging run is reported on its page together with what it did
  compute. `QuietLogger` filters the repetitive solver and tick warnings that such runs produce and
  reports only their count.

  Beyond the companion packages' version it adds: a `recipes.invariants` field for conserved
  quantities besides the energy; construction of the integrator *inside* `integrate_partial`'s
  `try`, so that a method with no integrator fails like a diverging run rather than aborting the
  page; and `make_plots` returning the figure suffixes it attempted, so that `write_plots` can tell
  a failed diagnostic from one that does not apply to the run at hand.
- **`src/convergence.jl`**, the point-vortex convergence study: each method is integrated over the
  same interval with time steps `Δt / 2ⁱ` plus two further halvings that serve as the reference
  solution, and the error of the final state, the observed order, and the span of the relative
  energy and angular-momentum error are plotted. The pre-0.2 study instead compared successive
  refinements at a single point in time — the first step of the coarsest grid — and took the
  expected order from a hand-maintained column of the tableau list.
- **`src/standard-map.jl`**, the Chirikov standard map and its first and second Poincaré integral
  invariants on the PoincareInvariants 0.5 interface. The map is not a `GeometricProblems` problem
  and lives here, because the identity that makes it one — `SymplecticEulerA` with unit time step
  integrates it *exactly* — is a property of the pairing rather than of either part.
- **A test suite.** `test/runtests.jl` integrates every method of every family for a single time
  step on every problem, which is what catches a renamed or removed method after an ecosystem bump,
  and checks the standard map against its closed-form iteration and its invariants against machine
  precision in the regular regime. `test/test_scripts.jl` exercises the whole weave path — the run
  drivers, the crash reporting and the CairoMakie stack — in a temporary directory.
- **CI and Documentation workflows.** The documentation workflow fans the 32 pages out over a matrix
  with `fail-fast: false` and gates deployment on a complete run, so that a crashing integrator
  costs one page rather than the site. `docs/Makefile` mirrors that matrix, so `make -j8 -k weave`
  reproduces it locally.
- **A *Known Gaps* section** in the documentation index, and `examples/README.md`, recording what
  the modernization left behind and what reviving the parked examples will involve.

### Changed

- **`src/tableau_lists.jl`** rewritten. Methods are structs now, so the integrator and the tableau
  have merged into one object: `IntegratorERK, getTableauERK4()` → `RK416()`,
  `IntegratorFIRK, getTableauGLRK(s)` → `Gauss(s)`,
  `IntegratorFIRK, getTableauLobIIIX(s)` → `LobattoIIIX(s)`,
  `IntegratorVPRKpNone, getTableauVPGLRK(s)` → `VPRKGauss(s)`,
  `IntegratorVPRK, getTableauVPRadIIAIIA(s)` → `VPRKRadauIIA(s)`,
  `IntegratorVPRKpStandard, …` → `VPRKpStandard(method)`, and so on. The projection × tableau matrix
  is generated by `_projected` rather than written out by hand, which is what the bug fix below is
  about.
- **Solver options** are keyword arguments of the integrator (`f_abstol`, `f_reltol`,
  `max_iterations`) instead of the removed global `set_config(:nls_atol, …)`; the values are those
  of the publication companion packages, which keeps the two comparable.
- **Figures are downsampled** through the GeometricProblems recipes' `nplot` keyword, derived as
  `max(1, div(nt, 10000))`. This is not cosmetic: rendering a 100 001-point vector line dominates
  the cost of a page — a 10⁵-step massless-charged-particle run integrates in about five seconds and
  then spends far longer being plotted — and without it the largest page takes hours rather than a
  quarter of an hour, well past what the documentation workflow allows. The derived value reproduces
  the `nplot = 100` the pre-0.2 gallery set by hand for that problem.
- **The massless charged particle runs 10⁵ time steps** rather than the published 10⁶, and the
  **standard-map invariants are sampled** with 2·10⁴ loop points and a 60×60 surface grid rather
  than 10⁵ and 500×500. The trajectory reduction is a concession to a build that runs the whole
  projection matrix on every page. The sampling reduction costs nothing: the map is symplectic, so
  what is approximated is the quadrature over the advected curve, and that is resolution-limited
  only in the chaotic regime — for `K = 1.2` over 20 steps the measured drift is `O(10)` at both
  2·10⁴ and the published 10⁵ points, while the regular regime is exact to `~1e-15` at either.
- The `runall.sh` / `run_poincare_*.sh` wrappers, which invoked a personal `jpddd` shim, are
  replaced by the `Makefile` targets.

### Fixed

- **Six run IDs showed the wrong method.** `get_tableau_list_vprk_projection` attached the run IDs
  `vprk_lobIIIF{2,3,4}` and `vprk_lobIIIG{2,3,4}` to `getTableauVPLobIIIE*` tableaus, so those six
  published figures were duplicates of the Lobatto IIIE ones. Generating the matrix removes the
  class of bug along with the instance.
- **The standard map was integrated by the wrong method.** The pre-0.2 scripts used
  `getTableauSymplecticEulerB`, but the A/B naming has swapped since: `SymplecticEulerA` is what
  reproduces `θ_{n+1} = θ_n + p_{n+1}`, `p_{n+1} = p_n + K sin θ_n` exactly at `Δt = 1`, while
  `SymplecticEulerB` gives the conjugate map. `test/runtests.jl` now pins this against the closed
  form.
- **The convergence page overwrote the trajectory pages.** Both are given the same method list and
  write into the same directory, so their run IDs collided; `run_convergence` now prefixes its
  output.
- **`pstandard` and `psymplectic` runs were indistinguishable on the page.** `VPRKpStandard` and
  `VPRKpSymplectic` both build a `StandardProjection` — the *same* one whenever the method's `R∞` is
  `+1` — so the projection's type cannot tell them apart. Run headlines are now labelled from the
  run ID, which records which was asked for.

- The default branch is renamed from `master` to `main`. The `Documentation` workflow triggers on it
  and `deploydocs` takes it as its `devbranch`.

### Removed

- **`src/generate_html.jl`**, the bespoke HTML gallery generator: its `get_config_dictionary()` no
  longer exists, and the woven Documenter pages replace it.
- **`src/package_version.jl`**: `Pkg.dir`, `readstring` and `Pkg.installed` are all gone from Julia.
  Package versions are recorded in `Manifest.toml`.
- The `GR`, `ORCA`, `PGFPlots`, `PGFPlotsX`, `PlotlyJS`, `Plots`, `PyPlot`, `ImageMagick`, `Showoff`,
  `DataStructures` and `ImportMacros` dependencies. All plotting is CairoMakie; `@import X as y` is
  plain `import X as y` on current Julia.
- The `ChargedParticleDynamics` and `ElectromagneticFields` dependencies, together with the
  guiding-centre and charged-particle examples they carry — see *Known limitations* below.

### Known limitations

The examples under `examples/guiding_center_4d/` and `examples/charged_particle_3d/` are **kept but
not built**: they depend on
[ChargedParticleDynamics.jl](https://github.com/JuliaPlasma/ChargedParticleDynamics.jl), whose
released version still targets the previous generation of the ecosystem. They are revived once a
compatible version is released; `examples/README.md` records what that involves.

Everything else without a counterpart in the current stack is listed under *Known Gaps* in the
documentation index: formal Lagrangian Runge-Kutta methods (`IntegratorFLRK` is commented out in
GeometricIntegrators 0.16), the internal-stage projection (`VPRKpInternal` constructs but has no
integrator, so its runs fail and are reported as such), HDF5 solution output (`Simulation`/`run!`
are gone), compensated summation, the splitting methods (no problem here provides an `sodeproblem`),
and the never-called CGVI code path.


## [0.1.0]

The HTML gallery built on GeometricIntegrators 0.3/0.4. See the git history.

[0.2.0]: https://github.com/JuliaGNI/GeometricExamples.jl/releases/tag/v0.2.0
