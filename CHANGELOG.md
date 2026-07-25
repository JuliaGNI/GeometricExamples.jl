# Changelog

All notable changes to GeometricExamples.jl are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


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

[0.2.0]: https://github.com/DDMGNI/GeometricExamples.jl/releases/tag/v0.2.0
