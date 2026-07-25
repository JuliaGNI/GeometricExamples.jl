
# GeometricExamples.jl

This package collects simulation results of
[GeometricIntegrators.jl](https://github.com/JuliaGNI/GeometricIntegrators.jl) belonging to
various publications. The example problems come from
[GeometricProblems.jl](https://github.com/JuliaGNI/GeometricProblems.jl) and the Poincaré integral
invariants from [PoincareInvariants.jl](https://github.com/JuliaGNI/PoincareInvariants.jl); all
figures are produced with [CairoMakie](https://docs.makie.org).

Every page below runs one family of integration methods over one problem and collects, for each
run, the trajectory, its time traces, and the errors of the conserved quantities. Runs that
diverge are reported on their page together with the trajectory up to the point of failure — the
comparison of methods that do and do not preserve the geometric structure is the point of these
examples, so failures are shown rather than hidden.


## Numerical Examples

### Lotka-Volterra 2d

* [Explicit Runge-Kutta Methods](lotka-volterra-2d/lotka-volterra-2d-erk.md)
* [Gauss-Legendre Runge-Kutta Methods](lotka-volterra-2d/lotka-volterra-2d-firk-gauss.md)
* [Lobatto Runge-Kutta Methods](lotka-volterra-2d/lotka-volterra-2d-firk-lobatto.md)
* [Gauss-Legendre VPRK Methods](lotka-volterra-2d/lotka-volterra-2d-vprk-gauss.md)
* [Symmetric SRK3 VPRK Method](lotka-volterra-2d/lotka-volterra-2d-vprk-srk3.md)
* [Lobatto VPRK Methods](lotka-volterra-2d/lotka-volterra-2d-vprk-lobatto.md)
* [Symplectic Lobatto VPRK Pairs](lotka-volterra-2d/lotka-volterra-2d-vprk-lobatto-symplectic.md)
* [Radau IIA VPRK Methods](lotka-volterra-2d/lotka-volterra-2d-vprk-radau.md)

### Lotka-Volterra 2d (singular Lagrangian)

The singular gauge differs from the standard one by a gauge transformation, so it leads to the
same Euler-Lagrange equations but to different variational integrators. Its explicit
(`odeproblem`) pages would therefore duplicate those above and are not built.

* [Gauss-Legendre VPRK Methods](lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-gauss.md)
* [Symmetric SRK3 VPRK Method](lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-srk3.md)
* [Lobatto VPRK Methods](lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-lobatto.md)
* [Symplectic Lobatto VPRK Pairs](lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-lobatto-symplectic.md)
* [Radau IIA VPRK Methods](lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-radau.md)

### Massless Charged Particle

* [Explicit Runge-Kutta Methods](massless-charged-particle/massless-charged-particle-erk.md)
* [Gauss-Legendre Runge-Kutta Methods](massless-charged-particle/massless-charged-particle-firk-gauss.md)
* [Lobatto Runge-Kutta Methods](massless-charged-particle/massless-charged-particle-firk-lobatto.md)
* [Gauss-Legendre VPRK Methods](massless-charged-particle/massless-charged-particle-vprk-gauss.md)
* [Symmetric SRK3 VPRK Method](massless-charged-particle/massless-charged-particle-vprk-srk3.md)
* [Lobatto VPRK Methods](massless-charged-particle/massless-charged-particle-vprk-lobatto.md)
* [Symplectic Lobatto VPRK Pairs](massless-charged-particle/massless-charged-particle-vprk-lobatto-symplectic.md)
* [Radau IIA VPRK Methods](massless-charged-particle/massless-charged-particle-vprk-radau.md)

### Point Vortices

Besides the energy, the point vortices conserve the angular momentum, whose error each page shows
alongside the energy error.

* [Explicit Runge-Kutta Methods](point-vortices/point-vortices-erk.md)
* [Gauss-Legendre Runge-Kutta Methods](point-vortices/point-vortices-firk-gauss.md)
* [Lobatto Runge-Kutta Methods](point-vortices/point-vortices-firk-lobatto.md)
* [Gauss-Legendre VPRK Methods](point-vortices/point-vortices-vprk-gauss.md)
* [Symmetric SRK3 VPRK Method](point-vortices/point-vortices-vprk-srk3.md)
* [Lobatto VPRK Methods](point-vortices/point-vortices-vprk-lobatto.md)
* [Symplectic Lobatto VPRK Pairs](point-vortices/point-vortices-vprk-lobatto-symplectic.md)
* [Radau IIA VPRK Methods](point-vortices/point-vortices-vprk-radau.md)
* [Convergence](point-vortices/point-vortices-convergence.md)

### Standard Map

* [1st Poincaré Integral Invariant](standard-map/standard-map-poincare-1st.md)
* [2nd Poincaré Integral Invariant](standard-map/standard-map-poincare-2nd.md)


## Known Gaps

This gallery was modernized from the 2018–2020 JuliaGNI ecosystem to GeometricIntegrators 0.16 /
GeometricProblems 0.7 / PoincareInvariants 0.5 / CairoMakie 0.15. A few things it used to cover
have no counterpart in the current stack and are recorded here rather than quietly dropped.

* **Guiding-centre and charged-particle examples.** The largest part of the pre-0.2 gallery — the
  4d guiding-centre dynamics in a tokamak field, the 3d charged particle, and the guiding-centre
  Poincaré integral invariants — comes from
  [ChargedParticleDynamics.jl](https://github.com/JuliaPlasma/ChargedParticleDynamics.jl), whose
  released version still targets GeometricEquations 0.18 / GeometricProblems 0.6 and Plots
  recipes. Those scripts are kept under `examples/` and revived when ChargedParticleDynamics
  v0.2.0 is released; see `examples/README.md` for what that will involve.
* **Formal Lagrangian Runge-Kutta methods.** `IntegratorFLRK` is commented out in
  GeometricIntegrators 0.16, so the point-vortex runs on `lodeproblem_formal_lagrangian` have no
  counterpart. The method list in `src/tableau_lists.jl` records this.
* **Internal-stage projection.** `VPRKpInternal` still constructs, but the
  `InternalStageProjection` it builds has no integrator in GeometricIntegrators 0.16 — only the
  standard, symmetric and midpoint projections do. Its runs are listed on the VPRK pages and fail
  immediately there, which is what a missing integrator looks like.
* **HDF5 output.** `Simulation`/`run!` and the HDF5 writing they did are commented out in
  GeometricIntegrators 0.16. The pages produce figures only; no solution files are written.
* **Compensated summation.** `set_config(:tab_compensated_summation, …)` no longer exists, so the
  `*_comp` variants of the guiding-centre scripts would now duplicate the plain ones.
* **Splitting methods.** A splitting method needs an `sodeproblem`, which none of the problems
  above provides. `tableaus_splitting()` is defined but unused; its only consumer was the
  charged-particle tree.
* **Continuous Galerkin variational integrators.** `IntegratorCGVI` maps to
  `CGVI(basis, quadrature)`, but the code path that ran it was never called by any script in the
  pre-0.2 gallery and is not carried over.
* **Run lengths.** The massless charged particle used to be integrated over 10⁶ time steps and the
  standard-map invariants sampled with 10⁵ loop points and a 500×500 surface grid. Those counts
  are out of reach for an automated build that runs the whole projection matrix on every page; the
  reduced values are documented at the top of `src/massless-charged-particle.jl` and
  `src/standard-map.jl`, together with why they do not change the conclusions.
* **A fixed tableau list bug.** The pre-0.2 `get_tableau_list_vprk_projection` attached the run
  IDs `vprk_lobIIIF*` and `vprk_lobIIIG*` to `getTableauVPLobIIIE*` tableaus, so six of the
  published run IDs showed the Lobatto IIIE results. The projection matrix is now generated rather
  than written out by hand, and those runs show the IIIF and IIIG methods they name.


## References

- Michael Kraus. Hamilton-Pontryagin-Galerkin Integrators.
- Michael Kraus. Projected Variational Integrators for Degenerate Lagrangian Systems.
- Michael Kraus. SPARK Methods for Degenerate Lagrangian Systems.
- Michael Kraus. Symplectic Runge-Kutta Methods for Certain Degenerate Lagrangian Systems.
- Michael Kraus. Symplectic Lobatto Runge-Kutta Methods for Degenerate Lagrangian Systems.
- Michael Kraus. Variational Integrators for Degenerate Lagrangians.
- Michael Kraus. Variational Integrators for Noncanonical Hamiltonian Systems.
- Michael Kraus, Joshua Burby. Conservation of Poincaré Integral Invariants in Numerical Simulations.


## Figure License

> Copyright (c) Michael Kraus <michael.kraus@ipp.mpg.de>
>
> All figures are licensed under the Creative Commons [CC BY-NC-SA 4.0 License](https://creativecommons.org/licenses/by-nc-sa/4.0/).


## Software License

> Copyright (c) Michael Kraus <michael.kraus@ipp.mpg.de>
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all
> copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.
