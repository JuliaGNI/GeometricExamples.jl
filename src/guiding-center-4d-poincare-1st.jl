# The first Poincaré integral invariant of the four-dimensional guiding centre dynamics.
# Everything but the choice of invariant lives in `guiding-center-4d-poincare.jl`, which this file
# loads; the two invariants differ in the form they integrate, in the parameterisation the ensemble
# samples — a loop here, a surface there — and in the figures that go with it.

# Guarded, unlike the trajectory modules' include of `guiding-center-4d.jl`: the two invariants
# share this file, and the test suite loads both of them into one session.
isdefined(@__MODULE__, :GuidingCenter4dPoincareExamples) ||
    include(joinpath(@__DIR__, "guiding-center-4d-poincare.jl"))

module GuidingCenter4dPoincare1stExamples

# `using GeometricExamples` puts the `tableaus_*` lists in scope: Weave evaluates each page's
# chunk inside this module.
using GeometricExamples

import ..GuidingCenter4dPoincareExamples as GCP

const KIND = :first

odeproblem(geometry; kwargs...) = GCP.odeproblem(KIND, geometry; kwargs...)
iodeproblem(geometry; kwargs...) = GCP.iodeproblem(KIND, geometry; kwargs...)

run_poincare(args...; kwargs...) = GCP.run_poincare(KIND, args...; kwargs...)

export odeproblem, iodeproblem, run_poincare

end
