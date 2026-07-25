#
# Weave the documentation pages of one problem into `docs/src/<problem>/`.
#
#   julia --project=.. weave.jl <problem> [<page> ...]
#
# With no page arguments all pages of `<problem>` are woven; naming individual pages allows the
# CI workflow to build them as parallel matrix jobs.
#
# Examples:
#
#   julia --project=.. weave.jl lotka-volterra-2d
#   julia --project=.. weave.jl lotka-volterra-2d vprk-gauss vprk-radau
#

using GeometricIntegrators
using Weave

import GeometricExamples


# problem name (in `src/`, `weave/` and `docs/src/`) → module defined by `src/<problem>.jl`
const PROBLEMS = (
    "lotka-volterra-2d"                => :LotkaVolterra2dExamples,
    "lotka-volterra-2d-singular"       => :LotkaVolterra2dSingularExamples,
    "massless-charged-particle"        => :MasslessChargedParticleExamples,
    "point-vortices"                   => :PointVorticesExamples,
    "guiding-center-4d-barely-passing" => :GuidingCenter4dBarelyPassingExamples,
    "guiding-center-4d-barely-trapped" => :GuidingCenter4dBarelyTrappedExamples,
    "guiding-center-4d-deeply-passing" => :GuidingCenter4dDeeplyPassingExamples,
    "guiding-center-4d-deeply-trapped" => :GuidingCenter4dDeeplyTrappedExamples,
    "guiding-center-4d-poincare-1st"   => :GuidingCenter4dPoincare1stExamples,
    "guiding-center-4d-poincare-2nd"   => :GuidingCenter4dPoincare2ndExamples,
    "standard-map"                     => :StandardMapExamples,
)

# The Euler-Lagrange equations, and hence the `odeproblem`, do not depend on the gauge, so the
# explicit pages of the singular Lotka-Volterra gauge would duplicate those of the standard one
# and are not built. The standard map is a different kind of example altogether: it carries the
# Poincaré integral invariants rather than a comparison of trajectory diagnostics.
const TRAJECTORY_PAGES = ("erk", "firk-gauss", "firk-lobatto",
                          "vprk-gauss", "vprk-srk3", "vprk-lobatto",
                          "vprk-lobatto-symplectic", "vprk-radau")

# The guiding centre orbits get the families the pre-0.2 gallery ran for them: the fully implicit
# Runge-Kutta methods on the explicit formulation and the projected VPRK methods on the variational
# one. No `erk` page — an explicit method on a guiding centre orbit at these time steps is
# unconditionally unstable — and no Lobatto VPRK page, whose 126 runs would multiply by the four
# orbits; both are one line here if wanted.
const GUIDING_CENTER_PAGES = ("firk-gauss", "firk-lobatto", "vprk-gauss", "vprk-srk3", "vprk-radau")

# The Poincaré invariant pages carry the geometry in the page name, because it selects the
# equilibrium submodule of `ChargedParticleDynamics`. Their page set is the one the pre-0.2 gallery
# published: the medium tokamak with the implicit Runge-Kutta and the projected VPRK methods, and
# the symmetric quadratic field with the projected VPRK methods only. Each run integrates an
# ensemble of a few hundred members four times over, once per time step of the sweep, so the two
# `vprk-gauss` pages are the most expensive in the gallery — the Lobatto and Radau families are one
# line here if wanted.
const POINCARE_PAGES = ("tokamak-firk-gauss", "tokamak-vprk-gauss", "symmetric-vprk-gauss")

const PAGES = Dict(
    "lotka-volterra-2d"                => TRAJECTORY_PAGES,
    "lotka-volterra-2d-singular"       => filter(startswith("vprk"), TRAJECTORY_PAGES),
    "massless-charged-particle"        => TRAJECTORY_PAGES,
    "point-vortices"                   => (TRAJECTORY_PAGES..., "convergence"),
    "guiding-center-4d-barely-passing" => GUIDING_CENTER_PAGES,
    "guiding-center-4d-barely-trapped" => GUIDING_CENTER_PAGES,
    "guiding-center-4d-deeply-passing" => GUIDING_CENTER_PAGES,
    "guiding-center-4d-deeply-trapped" => GUIDING_CENTER_PAGES,
    "guiding-center-4d-poincare-1st"   => POINCARE_PAGES,
    "guiding-center-4d-poincare-2nd"   => POINCARE_PAGES,
    "standard-map"                     => ("poincare-1st", "poincare-2nd"),
)

source_path(problem, page) = joinpath(@__DIR__, "..", "weave", "$(problem)-$(page).jmd")


# Returns `(problem, module name, pages)` for the command line arguments.
function parse_arguments(args)
    isempty(args) && error("usage: julia --project=.. weave.jl <problem> [<page> ...]\n" *
                           "problems: " * join(first.(PROBLEMS), ", "))

    problem = args[1]

    i = findfirst(p -> first(p) == problem, PROBLEMS)
    i === nothing && error("unknown problem \"$problem\"; expected one of " *
                           join(first.(PROBLEMS), ", "))

    pages = length(args) > 1 ? args[2:end] : collect(PAGES[problem])

    for page in pages
        page in PAGES[problem] || error("unknown page \"$page\" for problem \"$problem\"; " *
                                        "expected one of " * join(PAGES[problem], ", "))
        isfile(source_path(problem, page)) || error("no such document: $(source_path(problem, page))")
    end

    (problem, last(PROBLEMS[i]), pages)
end

const problem, modname, pages = parse_arguments(ARGS)


Weave.set_chunk_defaults!(:echo => false, :results => "raw")

include(joinpath(@__DIR__, "../src/$(problem).jl"))

# resolved at top level, i.e. after the world of the `include` above
const mod = getfield(Main, modname)

# Drop the repetitive line search and tick warnings, which otherwise make up almost all of the
# build log; see `quiet_solver_warnings!` in src/common.jl.
GeometricExamples.quiet_solver_warnings!()

for page in pages
    weave(source_path(problem, page),
             out_path = "src/$(problem)",
             doctype = "github",
             mod = mod)
end
