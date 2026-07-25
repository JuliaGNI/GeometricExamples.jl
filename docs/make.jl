using Documenter
using GeometricIntegrators

makedocs(;
    authors="Michael Kraus",
    sitename="GeometricExamples.jl",
    # Integrators that diverge on a problem produce no figures, and the pages generated for them
    # reference those (missing) images. Downgrade the resulting broken-link errors to warnings
    # (Documenter ≥ 1 errors by default).
    warnonly=[:cross_references],
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",

        "Lotka-Volterra 2d" => [
            "Explicit Runge-Kutta Methods"        => "lotka-volterra-2d/lotka-volterra-2d-erk.md",
            "Gauss-Legendre Runge-Kutta Methods"  => "lotka-volterra-2d/lotka-volterra-2d-firk-gauss.md",
            "Lobatto Runge-Kutta Methods"         => "lotka-volterra-2d/lotka-volterra-2d-firk-lobatto.md",
            "Gauss-Legendre VPRK Methods"         => "lotka-volterra-2d/lotka-volterra-2d-vprk-gauss.md",
            "Symmetric SRK3 VPRK Method"          => "lotka-volterra-2d/lotka-volterra-2d-vprk-srk3.md",
            "Lobatto VPRK Methods"                => "lotka-volterra-2d/lotka-volterra-2d-vprk-lobatto.md",
            "Symplectic Lobatto VPRK Pairs"       => "lotka-volterra-2d/lotka-volterra-2d-vprk-lobatto-symplectic.md",
            "Radau IIA VPRK Methods"              => "lotka-volterra-2d/lotka-volterra-2d-vprk-radau.md",
        ],

        "Lotka-Volterra 2d (singular Lagrangian)" => [
            "Gauss-Legendre VPRK Methods"         => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-gauss.md",
            "Symmetric SRK3 VPRK Method"          => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-srk3.md",
            "Lobatto VPRK Methods"                => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-lobatto.md",
            "Symplectic Lobatto VPRK Pairs"       => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-lobatto-symplectic.md",
            "Radau IIA VPRK Methods"              => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-radau.md",
        ],

        "Massless Charged Particle" => [
            "Explicit Runge-Kutta Methods"        => "massless-charged-particle/massless-charged-particle-erk.md",
            "Gauss-Legendre Runge-Kutta Methods"  => "massless-charged-particle/massless-charged-particle-firk-gauss.md",
            "Lobatto Runge-Kutta Methods"         => "massless-charged-particle/massless-charged-particle-firk-lobatto.md",
            "Gauss-Legendre VPRK Methods"         => "massless-charged-particle/massless-charged-particle-vprk-gauss.md",
            "Symmetric SRK3 VPRK Method"          => "massless-charged-particle/massless-charged-particle-vprk-srk3.md",
            "Lobatto VPRK Methods"                => "massless-charged-particle/massless-charged-particle-vprk-lobatto.md",
            "Symplectic Lobatto VPRK Pairs"       => "massless-charged-particle/massless-charged-particle-vprk-lobatto-symplectic.md",
            "Radau IIA VPRK Methods"              => "massless-charged-particle/massless-charged-particle-vprk-radau.md",
        ],

        "Point Vortices" => [
            "Explicit Runge-Kutta Methods"        => "point-vortices/point-vortices-erk.md",
            "Gauss-Legendre Runge-Kutta Methods"  => "point-vortices/point-vortices-firk-gauss.md",
            "Lobatto Runge-Kutta Methods"         => "point-vortices/point-vortices-firk-lobatto.md",
            "Gauss-Legendre VPRK Methods"         => "point-vortices/point-vortices-vprk-gauss.md",
            "Symmetric SRK3 VPRK Method"          => "point-vortices/point-vortices-vprk-srk3.md",
            "Lobatto VPRK Methods"                => "point-vortices/point-vortices-vprk-lobatto.md",
            "Symplectic Lobatto VPRK Pairs"       => "point-vortices/point-vortices-vprk-lobatto-symplectic.md",
            "Radau IIA VPRK Methods"              => "point-vortices/point-vortices-vprk-radau.md",
            "Convergence"                         => "point-vortices/point-vortices-convergence.md",
        ],

        "Standard Map" => [
            "1st Poincaré Integral Invariant"     => "standard-map/standard-map-poincare-1st.md",
            "2nd Poincaré Integral Invariant"     => "standard-map/standard-map-poincare-2nd.md",
        ],
    ],
)

# Skipped when the weave matrix of the CI workflow did not complete (`DEPLOY_DOCS` is set there):
# publishing a site that is missing the pages of the failed jobs would silently drop results from
# the documentation. Defaults to deploying, so that local builds and manual runs are unaffected.
if get(ENV, "DEPLOY_DOCS", "true") == "true"
    deploydocs(;
        repo="github.com/DDMGNI/GeometricExamples.jl",
        devbranch="master"
    )
else
    @warn "Incomplete weave run – skipping deploydocs. The built site is kept as a CI artifact."
end
