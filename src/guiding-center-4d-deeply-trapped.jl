# The deeply trapped orbit of the four-dimensional guiding centre dynamics in the medium-size
# tokamak equilibrium in cylindrical coordinates. Everything but the choice of orbit lives in
# `guiding-center-4d.jl`, which this file loads; the four cases differ in their initial conditions
# and in the time step those need.
# Guarded so that more than one case can be loaded into a single session, as the test suite does.
isdefined(@__MODULE__, :GuidingCenter4dExamples) ||
    include(joinpath(@__DIR__, "guiding-center-4d.jl"))

module GuidingCenter4dDeeplyTrappedExamples

# `using GeometricExamples` puts the `tableaus_*` lists in scope: Weave evaluates each page's
# chunk inside this module.
using GeometricExamples

import ..GuidingCenter4dExamples as GC4

const CASE = :deeply_trapped

iodeproblem(; kwargs...) = GC4.iodeproblem(CASE; kwargs...)
odeproblem(; kwargs...) = GC4.odeproblem(CASE; kwargs...)

run_list(args...; kwargs...) = GC4.run_list(CASE, args...; kwargs...)

export iodeproblem, odeproblem, run_list

end
