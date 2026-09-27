using Test
using GeometricIntegrators
import GeometricProblems
using GeometricExamples

# Integrate every method of every family for a single time step on every problem. This is a
# smoke test of the method lists against the current GeometricIntegrators: it catches renamed or
# removed methods, which is the failure mode a version bump of the ecosystem produces. Whether a
# method converges on a given problem is the subject of the woven pages, not of this test.

include("helpers/tableaus.jl")

const problems = (
    GeometricProblems.LotkaVolterra2d,
    GeometricProblems.LotkaVolterra2dSingular,
    GeometricProblems.MasslessChargedParticle,
    GeometricProblems.PointVortices
)

const nt = 1

@testset "$(nameof(problem))" for problem in problems
    Δt = problem.Δt

    @testset "$(family)" for (family, list) in tableaus_ode
        ode = problem.odeproblem(; timestep = Δt, timespan = (0.0, nt * Δt))
        @testset "$(run[2])" for run in list
            @test integrates(ode, run[1])
        end
    end

    @testset "$(family)" for (family, list) in tableaus_iode
        iode = problem.iodeproblem(; timestep = Δt, timespan = (0.0, nt * Δt))
        @testset "$(run[2])" for run in list
            @test integrates(iode, run[1])
        end
    end
end
