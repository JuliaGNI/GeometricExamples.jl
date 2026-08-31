using Documenter
using GeometricIntegrators

makedocs(;
    authors = "Michael Kraus",
    sitename = "GeometricExamples.jl",
    # Integrators that diverge on a problem produce no figures, and the pages generated for them
    # reference those (missing) images. Downgrade the resulting broken-link errors to warnings
    # (Documenter ≥ 1 errors by default).
    warnonly = [:cross_references],
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        assets = String[]
    ),
    pages = [
        "Home" => "index.md",
        "Lotka-Volterra 2d" => [
            "Explicit Runge-Kutta Methods" => "lotka-volterra-2d/lotka-volterra-2d-erk.md",
            "Gauss-Legendre Runge-Kutta Methods" => "lotka-volterra-2d/lotka-volterra-2d-firk-gauss.md",
            "Lobatto Runge-Kutta Methods" => "lotka-volterra-2d/lotka-volterra-2d-firk-lobatto.md",
            "Gauss-Legendre VPRK Methods" => "lotka-volterra-2d/lotka-volterra-2d-vprk-gauss.md",
            "Symmetric SRK3 VPRK Method" => "lotka-volterra-2d/lotka-volterra-2d-vprk-srk3.md",
            "Lobatto VPRK Methods" => "lotka-volterra-2d/lotka-volterra-2d-vprk-lobatto.md",
            "Symplectic Lobatto VPRK Pairs" => "lotka-volterra-2d/lotka-volterra-2d-vprk-lobatto-symplectic.md",
            "Radau IIA VPRK Methods" => "lotka-volterra-2d/lotka-volterra-2d-vprk-radau.md"
        ],
        "Lotka-Volterra 2d (singular Lagrangian)" => [
            "Gauss-Legendre VPRK Methods" => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-gauss.md",
            "Symmetric SRK3 VPRK Method" => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-srk3.md",
            "Lobatto VPRK Methods" => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-lobatto.md",
            "Symplectic Lobatto VPRK Pairs" => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-lobatto-symplectic.md",
            "Radau IIA VPRK Methods" => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-radau.md"
        ],
        "Massless Charged Particle" => [
            "Explicit Runge-Kutta Methods" => "massless-charged-particle/massless-charged-particle-erk.md",
            "Gauss-Legendre Runge-Kutta Methods" => "massless-charged-particle/massless-charged-particle-firk-gauss.md",
            "Lobatto Runge-Kutta Methods" => "massless-charged-particle/massless-charged-particle-firk-lobatto.md",
            "Gauss-Legendre VPRK Methods" => "massless-charged-particle/massless-charged-particle-vprk-gauss.md",
            "Symmetric SRK3 VPRK Method" => "massless-charged-particle/massless-charged-particle-vprk-srk3.md",
            "Symplectic Lobatto VPRK Pairs" => "massless-charged-particle/massless-charged-particle-vprk-lobatto-symplectic.md",
            "Radau IIA VPRK Methods" => "massless-charged-particle/massless-charged-particle-vprk-radau.md"
        ],
        "Point Vortices" => [
            "Explicit Runge-Kutta Methods" => "point-vortices/point-vortices-erk.md",
            "Gauss-Legendre Runge-Kutta Methods" => "point-vortices/point-vortices-firk-gauss.md",
            "Lobatto Runge-Kutta Methods" => "point-vortices/point-vortices-firk-lobatto.md",
            "Gauss-Legendre VPRK Methods" => "point-vortices/point-vortices-vprk-gauss.md",
            "Symmetric SRK3 VPRK Method" => "point-vortices/point-vortices-vprk-srk3.md",
            "Lobatto VPRK Methods" => "point-vortices/point-vortices-vprk-lobatto.md",
            "Symplectic Lobatto VPRK Pairs" => "point-vortices/point-vortices-vprk-lobatto-symplectic.md",
            "Radau IIA VPRK Methods" => "point-vortices/point-vortices-vprk-radau.md",
            "Convergence" => "point-vortices/point-vortices-convergence.md"
        ],
        "Guiding Center 4d (Barely Passing)" => [
            "Gauss-Legendre Runge-Kutta Methods" => "guiding-center-4d-barely-passing/guiding-center-4d-barely-passing-firk-gauss.md",
            "Lobatto Runge-Kutta Methods" => "guiding-center-4d-barely-passing/guiding-center-4d-barely-passing-firk-lobatto.md",
            "Gauss-Legendre VPRK Methods" => "guiding-center-4d-barely-passing/guiding-center-4d-barely-passing-vprk-gauss.md",
            "Symmetric SRK3 VPRK Method" => "guiding-center-4d-barely-passing/guiding-center-4d-barely-passing-vprk-srk3.md",
            "Radau IIA VPRK Methods" => "guiding-center-4d-barely-passing/guiding-center-4d-barely-passing-vprk-radau.md"
        ],
        "Guiding Center 4d (Barely Trapped)" => [
            "Gauss-Legendre Runge-Kutta Methods" => "guiding-center-4d-barely-trapped/guiding-center-4d-barely-trapped-firk-gauss.md",
            "Lobatto Runge-Kutta Methods" => "guiding-center-4d-barely-trapped/guiding-center-4d-barely-trapped-firk-lobatto.md",
            "Gauss-Legendre VPRK Methods" => "guiding-center-4d-barely-trapped/guiding-center-4d-barely-trapped-vprk-gauss.md",
            "Symmetric SRK3 VPRK Method" => "guiding-center-4d-barely-trapped/guiding-center-4d-barely-trapped-vprk-srk3.md",
            "Radau IIA VPRK Methods" => "guiding-center-4d-barely-trapped/guiding-center-4d-barely-trapped-vprk-radau.md"
        ],
        "Guiding Center 4d (Deeply Passing)" => [
            "Gauss-Legendre Runge-Kutta Methods" => "guiding-center-4d-deeply-passing/guiding-center-4d-deeply-passing-firk-gauss.md",
            "Lobatto Runge-Kutta Methods" => "guiding-center-4d-deeply-passing/guiding-center-4d-deeply-passing-firk-lobatto.md",
            "Gauss-Legendre VPRK Methods" => "guiding-center-4d-deeply-passing/guiding-center-4d-deeply-passing-vprk-gauss.md",
            "Symmetric SRK3 VPRK Method" => "guiding-center-4d-deeply-passing/guiding-center-4d-deeply-passing-vprk-srk3.md",
            "Radau IIA VPRK Methods" => "guiding-center-4d-deeply-passing/guiding-center-4d-deeply-passing-vprk-radau.md"
        ],
        "Guiding Center 4d (Deeply Trapped)" => [
            "Gauss-Legendre Runge-Kutta Methods" => "guiding-center-4d-deeply-trapped/guiding-center-4d-deeply-trapped-firk-gauss.md",
            "Lobatto Runge-Kutta Methods" => "guiding-center-4d-deeply-trapped/guiding-center-4d-deeply-trapped-firk-lobatto.md",
            "Gauss-Legendre VPRK Methods" => "guiding-center-4d-deeply-trapped/guiding-center-4d-deeply-trapped-vprk-gauss.md",
            "Symmetric SRK3 VPRK Method" => "guiding-center-4d-deeply-trapped/guiding-center-4d-deeply-trapped-vprk-srk3.md",
            "Radau IIA VPRK Methods" => "guiding-center-4d-deeply-trapped/guiding-center-4d-deeply-trapped-vprk-radau.md"
        ],
        "Guiding Center 4d, Small Tokamak (Barely Passing)" => [
            "Gauss-Legendre Runge-Kutta Methods" => "guiding-center-4d-small-barely-passing/guiding-center-4d-small-barely-passing-firk-gauss.md",
            "Gauss-Legendre VPRK Methods" => "guiding-center-4d-small-barely-passing/guiding-center-4d-small-barely-passing-vprk-gauss.md"
        ],
        "Guiding Center 4d, Small Tokamak (Barely Trapped)" => [
            "Gauss-Legendre Runge-Kutta Methods" => "guiding-center-4d-small-barely-trapped/guiding-center-4d-small-barely-trapped-firk-gauss.md",
            "Gauss-Legendre VPRK Methods" => "guiding-center-4d-small-barely-trapped/guiding-center-4d-small-barely-trapped-vprk-gauss.md"
        ],
        "Guiding Center 4d, Small Tokamak (Deeply Passing)" => [
            "Gauss-Legendre Runge-Kutta Methods" => "guiding-center-4d-small-deeply-passing/guiding-center-4d-small-deeply-passing-firk-gauss.md",
            "Gauss-Legendre VPRK Methods" => "guiding-center-4d-small-deeply-passing/guiding-center-4d-small-deeply-passing-vprk-gauss.md"
        ],
        "Guiding Center 4d, Small Tokamak (Deeply Trapped)" => [
            "Gauss-Legendre Runge-Kutta Methods" => "guiding-center-4d-small-deeply-trapped/guiding-center-4d-small-deeply-trapped-firk-gauss.md",
            "Gauss-Legendre VPRK Methods" => "guiding-center-4d-small-deeply-trapped/guiding-center-4d-small-deeply-trapped-vprk-gauss.md"
        ],
        "Guiding Center 4d (1st Poincaré Invariant)" => [
            "Tokamak, Gauss-Legendre Runge-Kutta Methods" => "guiding-center-4d-poincare-1st/guiding-center-4d-poincare-1st-tokamak-firk-gauss.md",
            "Tokamak, Gauss-Legendre VPRK Methods" => "guiding-center-4d-poincare-1st/guiding-center-4d-poincare-1st-tokamak-vprk-gauss.md",
            "Symmetric Field, Gauss-Legendre VPRK Methods" => "guiding-center-4d-poincare-1st/guiding-center-4d-poincare-1st-symmetric-vprk-gauss.md"
        ],
        "Guiding Center 4d (2nd Poincaré Invariant)" => [
            "Tokamak, Gauss-Legendre Runge-Kutta Methods" => "guiding-center-4d-poincare-2nd/guiding-center-4d-poincare-2nd-tokamak-firk-gauss.md",
            "Tokamak, Gauss-Legendre VPRK Methods" => "guiding-center-4d-poincare-2nd/guiding-center-4d-poincare-2nd-tokamak-vprk-gauss.md",
            "Symmetric Field, Gauss-Legendre VPRK Methods" => "guiding-center-4d-poincare-2nd/guiding-center-4d-poincare-2nd-symmetric-vprk-gauss.md"
        ],
        "Standard Map" => [
            "1st Poincaré Integral Invariant" => "standard-map/standard-map-poincare-1st.md",
            "2nd Poincaré Integral Invariant" => "standard-map/standard-map-poincare-2nd.md"
        ]
    ]
)

# Skipped when the weave matrix of the CI workflow did not complete (`DEPLOY_DOCS` is set there):
# publishing a site that is missing the pages of the failed jobs would silently drop results from
# the documentation. Defaults to deploying, so that local builds and manual runs are unaffected.
if get(ENV, "DEPLOY_DOCS", "true") == "true"
    deploydocs(;
        repo = "github.com/JuliaGNI/GeometricExamples.jl",
        devbranch = "main"
    )
else
    @warn "Incomplete weave run – skipping deploydocs. The built site is kept as a CI artifact."
end
