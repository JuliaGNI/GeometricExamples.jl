
# GeometricExamples.jl

This package collects simulation results of
[GeometricIntegrators.jl](https://github.com/JuliaGNI/GeometricIntegrators.jl) belonging to various
publications. The example problems come from
[GeometricProblems.jl](https://github.com/JuliaGNI/GeometricProblems.jl), the Poincaré integral
invariants from [PoincareInvariants.jl](https://github.com/JuliaGNI/PoincareInvariants.jl), and all
figures are produced with [CairoMakie](https://docs.makie.org).

Each page of the documentation runs one family of integration methods over one problem and
collects, per run, the trajectory, its time traces, and the errors of the conserved quantities.
Runs that diverge are reported on their page together with the trajectory up to the point of
failure: comparing methods that do and do not preserve the geometric structure is the point of
these examples, so failures are shown rather than hidden.

Problems covered: the two-dimensional Lotka-Volterra model in its standard and its singular gauge,
the massless charged particle in 2d, the planar point vortices (including a convergence study), four
orbits of the four-dimensional guiding centre dynamics in a tokamak equilibrium and its first and
second Poincaré integral invariants, and the Chirikov standard map (first and second Poincaré
integral invariant).

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
outputs and run lengths that the modernization to GeometricIntegrators 0.16 left behind.

## References

- Michael Kraus. Hamilton-Pontryagin-Galerkin Integrators.
- Michael Kraus. Discontinuous Galerkin Variational Integrators for Degenerate Lagrangians.
- Michael Kraus. Discontinuous Galerkin Variational Integrators for Hamiltonian Systems with Dirac Constraints.
- Michael Kraus. Projected Variational Integrators for Degenerate Lagrangian Systems.
- Michael Kraus. Variational Integrators for Noncanonical Hamiltonian Systems.
- Michael Kraus, Joshua Burby. Conservation of Poincaré Integral Invariants in Numerical Simulations.

## License

The GeometricExamples.jl package is licensed under the [MIT "Expat" License](LICENSE.md).
All figures are licensed under the Creative Commons [CC BY-NC-SA 4.0 License](https://creativecommons.org/licenses/by-nc-sa/4.0/).
