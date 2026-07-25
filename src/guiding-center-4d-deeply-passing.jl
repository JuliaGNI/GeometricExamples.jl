# The deeply passing orbit of the four-dimensional guiding centre dynamics in the medium-size
# tokamak equilibrium in cylindrical coordinates. Everything but the choice of orbit lives in
# `guiding-center-4d.jl`, which this file loads; the four cases differ in their initial conditions
# and in the time step those need.
include(joinpath(@__DIR__, "guiding-center-4d.jl"))

module GuidingCenter4dDeeplyPassingExamples

    # `using GeometricExamples` puts the `tableaus_*` lists in scope: Weave evaluates each page's
    # chunk inside this module.
    using GeometricExamples

    import ..GuidingCenter4dExamples as GC4

    const CASE = :deeply_passing

    iodeproblem(; kwargs...) = GC4.iodeproblem(CASE; kwargs...)
    odeproblem(; kwargs...) = GC4.odeproblem(CASE; kwargs...)

    run_list(args...; kwargs...) = GC4.run_list(args...; kwargs...)

    export iodeproblem, odeproblem, run_list

end
