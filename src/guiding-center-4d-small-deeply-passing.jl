# The deeply passing orbit of the four-dimensional guiding centre dynamics in the small tokamak equilibrium
# in cylindrical coordinates, whose particles are slow enough to need a time step three hundred
# times larger than the medium tokamak's. Everything but the choice of case lives in
# `guiding-center-4d.jl`, which this file loads.

# Guarded so that more than one case can be loaded into a single session, as the test suite does.
isdefined(@__MODULE__, :GuidingCenter4dExamples) ||
    include(joinpath(@__DIR__, "guiding-center-4d.jl"))

module GuidingCenter4dSmallDeeplyPassingExamples

    # `using GeometricExamples` puts the `tableaus_*` lists in scope: Weave evaluates each page's
    # chunk inside this module.
    using GeometricExamples

    import ..GuidingCenter4dExamples as GC4

    const CASE = :small_deeply_passing

    iodeproblem(; kwargs...) = GC4.iodeproblem(CASE; kwargs...)
    odeproblem(; kwargs...) = GC4.odeproblem(CASE; kwargs...)

    run_list(args...; kwargs...) = GC4.run_list(CASE, args...; kwargs...)

    export iodeproblem, odeproblem, run_list

end
