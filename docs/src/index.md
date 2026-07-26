
# GeometricExamples.jl

This package collects simulation results of
[GeometricIntegrators.jl](https://github.com/JuliaGNI/GeometricIntegrators.jl) belonging to
various publications. The example problems come from
[GeometricProblems.jl](https://github.com/JuliaGNI/GeometricProblems.jl) and the Poincaré integral
invariants from [PoincareInvariants.jl](https://github.com/JuliaGNI/PoincareInvariants.jl); all
figures are produced with [CairoMakie](https://docs.makie.org).

Every page below runs one family of integration methods over one problem and collects, for each
run, the trajectory, its time traces, and the errors of the conserved quantities. The Poincaré
invariant pages replace those diagnostics with the error of the invariant itself and with the loop
or surface whose advection defines it. Runs that diverge are reported on their page together with
the trajectory up to the point of failure — the comparison of methods that do and do not preserve
the geometric structure is the point of these examples, so failures are shown rather than hidden.


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

This problem is integrated over 10⁴ time steps rather than the 10⁵ of the other problems, and has no
Lobatto VPRK page: at the published run length its 126-run Lobatto matrix is the most expensive
combination in the gallery and does not fit the documentation build. The 36-run Gauss and
symplectic-Lobatto matrices below cover the same ground.

* [Explicit Runge-Kutta Methods](massless-charged-particle/massless-charged-particle-erk.md)
* [Gauss-Legendre Runge-Kutta Methods](massless-charged-particle/massless-charged-particle-firk-gauss.md)
* [Lobatto Runge-Kutta Methods](massless-charged-particle/massless-charged-particle-firk-lobatto.md)
* [Gauss-Legendre VPRK Methods](massless-charged-particle/massless-charged-particle-vprk-gauss.md)
* [Symmetric SRK3 VPRK Method](massless-charged-particle/massless-charged-particle-vprk-srk3.md)
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

### Guiding Center 4d (Barely Passing)

* [Gauss-Legendre Runge-Kutta Methods](guiding-center-4d-barely-passing/guiding-center-4d-barely-passing-firk-gauss.md)
* [Lobatto Runge-Kutta Methods](guiding-center-4d-barely-passing/guiding-center-4d-barely-passing-firk-lobatto.md)
* [Gauss-Legendre VPRK Methods](guiding-center-4d-barely-passing/guiding-center-4d-barely-passing-vprk-gauss.md)
* [Symmetric SRK3 VPRK Method](guiding-center-4d-barely-passing/guiding-center-4d-barely-passing-vprk-srk3.md)
* [Radau IIA VPRK Methods](guiding-center-4d-barely-passing/guiding-center-4d-barely-passing-vprk-radau.md)

### Guiding Center 4d (Barely Trapped)

* [Gauss-Legendre Runge-Kutta Methods](guiding-center-4d-barely-trapped/guiding-center-4d-barely-trapped-firk-gauss.md)
* [Lobatto Runge-Kutta Methods](guiding-center-4d-barely-trapped/guiding-center-4d-barely-trapped-firk-lobatto.md)
* [Gauss-Legendre VPRK Methods](guiding-center-4d-barely-trapped/guiding-center-4d-barely-trapped-vprk-gauss.md)
* [Symmetric SRK3 VPRK Method](guiding-center-4d-barely-trapped/guiding-center-4d-barely-trapped-vprk-srk3.md)
* [Radau IIA VPRK Methods](guiding-center-4d-barely-trapped/guiding-center-4d-barely-trapped-vprk-radau.md)

### Guiding Center 4d (Deeply Passing)

* [Gauss-Legendre Runge-Kutta Methods](guiding-center-4d-deeply-passing/guiding-center-4d-deeply-passing-firk-gauss.md)
* [Lobatto Runge-Kutta Methods](guiding-center-4d-deeply-passing/guiding-center-4d-deeply-passing-firk-lobatto.md)
* [Gauss-Legendre VPRK Methods](guiding-center-4d-deeply-passing/guiding-center-4d-deeply-passing-vprk-gauss.md)
* [Symmetric SRK3 VPRK Method](guiding-center-4d-deeply-passing/guiding-center-4d-deeply-passing-vprk-srk3.md)
* [Radau IIA VPRK Methods](guiding-center-4d-deeply-passing/guiding-center-4d-deeply-passing-vprk-radau.md)

### Guiding Center 4d (Deeply Trapped)

* [Gauss-Legendre Runge-Kutta Methods](guiding-center-4d-deeply-trapped/guiding-center-4d-deeply-trapped-firk-gauss.md)
* [Lobatto Runge-Kutta Methods](guiding-center-4d-deeply-trapped/guiding-center-4d-deeply-trapped-firk-lobatto.md)
* [Gauss-Legendre VPRK Methods](guiding-center-4d-deeply-trapped/guiding-center-4d-deeply-trapped-vprk-gauss.md)
* [Symmetric SRK3 VPRK Method](guiding-center-4d-deeply-trapped/guiding-center-4d-deeply-trapped-vprk-srk3.md)
* [Radau IIA VPRK Methods](guiding-center-4d-deeply-trapped/guiding-center-4d-deeply-trapped-vprk-radau.md)

### Guiding Center 4d (1st Poincaré Invariant)

The invariant ``I_{1} = \oint_{\gamma} \vartheta_{i} (q) \, dq^{i}`` of the guiding centre one-form,
computed on an advected loop of a few hundred ensemble members. Each run integrates the loop at four
time steps over the same interval, whose relative errors share one figure.

* [Tokamak, Gauss-Legendre Runge-Kutta Methods](guiding-center-4d-poincare-1st/guiding-center-4d-poincare-1st-tokamak-firk-gauss.md)
* [Tokamak, Gauss-Legendre VPRK Methods](guiding-center-4d-poincare-1st/guiding-center-4d-poincare-1st-tokamak-vprk-gauss.md)
* [Symmetric Field, Gauss-Legendre VPRK Methods](guiding-center-4d-poincare-1st/guiding-center-4d-poincare-1st-symmetric-vprk-gauss.md)

### Guiding Center 4d (2nd Poincaré Invariant)

The invariant ``I_{2} = \int_{S} \omega_{ij} (q) \, dq^{i} \wedge dq^{j}`` of the guiding centre
two-form, on an advected surface sampled at Padua points.

* [Tokamak, Gauss-Legendre Runge-Kutta Methods](guiding-center-4d-poincare-2nd/guiding-center-4d-poincare-2nd-tokamak-firk-gauss.md)
* [Tokamak, Gauss-Legendre VPRK Methods](guiding-center-4d-poincare-2nd/guiding-center-4d-poincare-2nd-tokamak-vprk-gauss.md)
* [Symmetric Field, Gauss-Legendre VPRK Methods](guiding-center-4d-poincare-2nd/guiding-center-4d-poincare-2nd-symmetric-vprk-gauss.md)

### Standard Map

* [1st Poincaré Integral Invariant](standard-map/standard-map-poincare-1st.md)
* [2nd Poincaré Integral Invariant](standard-map/standard-map-poincare-2nd.md)


## Known Gaps

This gallery was modernized from the 2018–2020 JuliaGNI ecosystem to GeometricIntegrators 0.16 /
GeometricProblems 0.7 / PoincareInvariants 0.5 / CairoMakie 0.15. A few things it used to cover
have no counterpart in the current stack and are recorded here rather than quietly dropped.

* **The guiding-centre problems will need updating again.**
  [ChargedParticleDynamics.jl](https://github.com/JuliaPlasma/ChargedParticleDynamics.jl) 0.2.0 —
  which carries the interface changes the orbits and invariants above need, the update to
  GeometricEquations 0.21 / GeometricSolutions 0.6, the PoincareInvariants 0.5 rewrite of the 4d
  loop and surface invariants, and the `ChargedParticlePlots` Makie extension — is a plain
  dependency again, but its `TODO.md` records a further breaking rename of exactly the constructors
  and keywords used here (`guiding_center_4d_ode` → `odeproblem`, `tspan`/`tstep` →
  `timespan`/`timestep`). That will arrive as 0.3 and the call sites in
  `src/guiding-center-4d.jl` and `src/guiding-center-4d-poincare.jl` will have to follow.
* **The 3d charged particle** is not rebuilt. Its pre-0.2 scripts are kept under `examples/`, and
  `examples/README.md` records what reviving them involves; they were already broken before the
  modernization, as they include settings and driver files that do not exist in their directory.
* **Two of the three error curves of the published Poincaré invariant figures.** Each pre-0.2 run
  drew the invariant of the one-form on ``q``, the canonical ``\oint_\gamma p_i \, dq^i`` of the
  variational solution, and a Lagrange-multiplier-corrected form. PoincareInvariants 0.5 computes
  one invariant from the form it is handed, and the solution of a projected run no longer carries
  the ``\lambda`` series, so only the first of the three survives. The ``O(\Delta t^2)``-corrected
  variant `plot_poincare_invariant_error(t, I, K, Δt)` of the `ChargedParticlePlots` extension is
  unused for the same reason: the trapezoidal second-invariant variants that produced its `K` were
  removed in the PoincareInvariants 0.5 rewrite.
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
* **Run lengths.** The massless charged particle used to be integrated over 10⁶ time steps, the
  standard-map invariants sampled with 10⁵ loop points and a 500×500 surface grid, and the
  guiding-centre invariants advected over 5·10⁴ time units with up to 2000 loop points or a
  200×200 surface grid. Those counts are out of reach for an automated build that runs the whole
  projection matrix on every page — for the guiding centre every sample point is one ensemble
  member with its own implicit integrator, and each run is repeated at four time steps. The reduced
  values are documented at the top of `src/massless-charged-particle.jl`, `src/standard-map.jl` and
  `src/guiding-center-4d-poincare.jl`, together with the measurements showing that they do not
  change the conclusions: the guiding-centre invariants are unchanged to ten digits between 100 and
  800 sample points, while the drift they measure spans six orders of magnitude between methods.

  The massless charged particle is the one problem where this bites hardest, and its run length is
  now 10⁴ rather than the 10⁵ the companion packages use. Measured on the CI runners, which are
  several times slower than a development machine, its three VPRK pages each exceeded a four hour
  job timeout at 10⁵ steps, while `point-vortices` runs the same 126-method Lobatto matrix in 49
  minutes at 10⁴. Its Lobatto VPRK page is dropped as well.
* **One page per time step.** The pre-0.2 gallery published the guiding-centre invariants as four
  pages per method family, one for each of Δt ∈ {10, 5, 2, 1}. The four runs are now overlaid in
  one figure per method instead, which is the same computation and puts the comparison the four
  pages were making on a single pair of axes.
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
