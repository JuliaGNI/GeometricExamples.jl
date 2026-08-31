
# GeometricExamples.jl

[![Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliagni.github.io/GeometricExamples.jl/dev/)
[![CI](https://github.com/JuliaGNI/GeometricExamples.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaGNI/GeometricExamples.jl/actions/workflows/CI.yml)
[![Documentation build](https://github.com/JuliaGNI/GeometricExamples.jl/actions/workflows/Documentation.yaml/badge.svg)](https://github.com/JuliaGNI/GeometricExamples.jl/actions/workflows/Documentation.yaml)

This package collects simulation results of
[GeometricIntegrators.jl](https://github.com/JuliaGNI/GeometricIntegrators.jl) belonging to various
publications. The example problems come from
[GeometricProblems.jl](https://github.com/JuliaGNI/GeometricProblems.jl), the Poincaré integral
invariants from [PoincareInvariants.jl](https://github.com/JuliaGNI/PoincareInvariants.jl), and all
figures are produced with [CairoMakie](https://docs.makie.org).

**The results are the documentation: [juliagni.github.io/GeometricExamples.jl/dev](https://juliagni.github.io/GeometricExamples.jl/dev/).**
Each of its 65 pages runs one family of integration methods over one problem and collects, per run,
the trajectory, its time traces, and the errors of the conserved quantities. Runs that diverge are
reported on their page together with the trajectory up to the point of failure: comparing methods
that do and do not preserve the geometric structure is the point of these examples, so failures are
shown rather than hidden.

Problems covered:

* [Lotka-Volterra 2d](https://juliagni.github.io/GeometricExamples.jl/dev/lotka-volterra-2d/lotka-volterra-2d-erk/),
  in its [standard](https://juliagni.github.io/GeometricExamples.jl/dev/lotka-volterra-2d/lotka-volterra-2d-vprk-gauss/)
  and its [singular gauge](https://juliagni.github.io/GeometricExamples.jl/dev/lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-gauss/)
* [The massless charged particle](https://juliagni.github.io/GeometricExamples.jl/dev/massless-charged-particle/massless-charged-particle-firk-gauss/) in 2d
* [The planar point vortices](https://juliagni.github.io/GeometricExamples.jl/dev/point-vortices/point-vortices-vprk-gauss/),
  including a [convergence study](https://juliagni.github.io/GeometricExamples.jl/dev/point-vortices/point-vortices-convergence/)
* The four-dimensional guiding centre dynamics: four orbits in a
  [medium-size](https://juliagni.github.io/GeometricExamples.jl/dev/guiding-center-4d-barely-passing/guiding-center-4d-barely-passing-vprk-gauss/)
  and a [small](https://juliagni.github.io/GeometricExamples.jl/dev/guiding-center-4d-small-barely-passing/guiding-center-4d-small-barely-passing-vprk-gauss/)
  tokamak equilibrium, and its
  [first](https://juliagni.github.io/GeometricExamples.jl/dev/guiding-center-4d-poincare-1st/guiding-center-4d-poincare-1st-tokamak-vprk-gauss/)
  and [second](https://juliagni.github.io/GeometricExamples.jl/dev/guiding-center-4d-poincare-2nd/guiding-center-4d-poincare-2nd-tokamak-vprk-gauss/)
  Poincaré integral invariants
* The Chirikov standard map, again with its
  [first](https://juliagni.github.io/GeometricExamples.jl/dev/standard-map/standard-map-poincare-1st/)
  and [second](https://juliagni.github.io/GeometricExamples.jl/dev/standard-map/standard-map-poincare-2nd/)
  Poincaré integral invariant

Only `dev` is published: the package carries no release tags, so Documenter builds nothing under
`stable`.

## Reproducing the Figures

Weave all pages into `docs/src/<problem>/` and build the documentation into `docs/build/`
(`-j8` runs eight pages in parallel; `-k` keeps going if one of them fails):

```
cd docs
make -j8 -k weave
make documenter
```

`make -j8 point-vortices` weaves all pages of a single problem, and

```
julia --project=.. weave.jl point-vortices vprk-gauss
```

a single page. From the repository root, `make weave`, `make documenter` and `make test` forward to
the same targets.

Run the test suite, which integrates every method of every family for a single time step and checks
the standard map against its closed form:

```
julia --project -e 'using Pkg; Pkg.test()'
```

`julia --project test/test_scripts.jl` additionally exercises the whole weave path — the run
drivers, the crash reporting and the CairoMakie stack — in a temporary directory.

## Status

Every family of the pre-0.2 gallery has been migrated to `src/` + `weave/` except the 3d charged
particle, which was already broken before the modernization. The pre-0.2 scripts themselves have been
removed; the `[Unreleased]` section of [`CHANGELOG.md`](CHANGELOG.md) records how they map onto the
current structure, which of them never ran, and the one study that did not come across, and the git
history holds the originals. The *Known Gaps* section of the documentation covers the integrators,
outputs and run lengths that the modernization left behind, and [`TODO.md`](TODO.md) the families
the current stack could carry again but that are not built yet.

## References

- Michael Kraus. Hamilton-Pontryagin-Galerkin Integrators.
- Michael Kraus. Discontinuous Galerkin Variational Integrators for Degenerate Lagrangians.
- Michael Kraus. Discontinuous Galerkin Variational Integrators for Hamiltonian Systems with Dirac Constraints.
- Michael Kraus. Projected Variational Integrators for Degenerate Lagrangian Systems.
- Michael Kraus. Variational Integrators for Noncanonical Hamiltonian Systems.
- Michael Kraus, Joshua Burby. Conservation of Poincaré Integral Invariants in Numerical Simulations.

## Development

### Git hooks

Two hooks live in `.githooks`. They are **not active in a fresh clone** — `core.hooksPath` is local
configuration and does not travel with a push — so enable them once per clone:

```sh
git config core.hooksPath .githooks
```

**`pre-commit`** acts on **staged `.jl` files only**, and exits immediately when a commit stages
none, so a documentation- or workflow-only commit is not slowed down by it:

- **JuliaFormatter `--check`**, honouring this repository's own `.JuliaFormatter.toml` — **blocks**
  the commit. Formatting is mechanical and always fixable.
- **`fatou lint`**, when `fatou` is installed — **advisory only**, and deliberately so: its
  `unused-import` rule does not follow `include`, so it flags the load-bearing imports of every
  module file.
- **`using <Package>`**, which catches a syntax error or a broken `include` — **blocks**.

**`pre-push`** runs the full test suite with `--check-bounds=auto`, but **only when pushing to
`main` or `master`**; a topic branch is left to CI. It prints nothing for **10–30 minutes**, which
looks exactly like a network hang and is not one. If you do interrupt it, check for an orphaned
Julia process that the killed hook left behind.

Either hook can be bypassed for a single command with `--no-verify`, for a change you know it does
not apply to:

```sh
git commit --no-verify
git push --no-verify
```

The hooks are generated from one shared copy and are byte-identical across the related
repositories, so edit them there rather than here — a local edit is silently undone by the next
install.


## License

The GeometricExamples.jl package is licensed under the [MIT "Expat" License](LICENSE.md).
All figures are licensed under the Creative Commons [CC BY-NC-SA 4.0 License](https://creativecommons.org/licenses/by-nc-sa/4.0/).
