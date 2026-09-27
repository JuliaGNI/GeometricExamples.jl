# The method lists and the single-step check shared by `test/tableau_lists.jl` and
# `test/guiding-center-4d.jl`. The including file brings `GeometricExamples` into scope.

const tableaus_ode = (
    "Explicit Runge-Kutta" => tableaus_erk(),
    "Gauss-Legendre" => tableaus_firk_gauss(),
    "Lobatto" => tableaus_firk_lobatto()
)

const tableaus_iode = (
    "Gauss-Legendre VPRK" => tableaus_vprk_gauss(),
    "Symmetric SRK3 VPRK" => tableaus_vprk_srk3(),
    "Lobatto VPRK" => tableaus_vprk_lobatto(),
    "Symplectic Lobatto VPRK" => tableaus_vprk_lobatto_symplectic(),
    "Radau IIA VPRK" => tableaus_vprk_radau()
)

# `integrate_partial` reports a failure instead of throwing, which is exactly what a single-step
# smoke test wants: a method that diverges on a degenerate problem, or one whose projection has no
# integrator (`VPRKpInternal`), is a documented outcome and not a test failure. What *is* a failure
# is a method that cannot be built at all — the list naming something the ecosystem no longer has.
function integrates(problem, method)
    sol, last_good, err = integrate_partial(problem, method)
    err isa UndefVarError && return false
    return true
end
