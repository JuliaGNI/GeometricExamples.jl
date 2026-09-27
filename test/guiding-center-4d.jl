using Test
using GeometricIntegrators
using GeometricExamples

include("helpers/tableaus.jl")

# The guiding centre problems come from `ChargedParticleDynamics` rather than `GeometricProblems`,
# and each of the four orbits fixes its own time step, so they are driven through the problem module
# instead of the loop in `test/tableau_lists.jl`. One step per method, as there.
include("../src/guiding-center-4d.jl")

@testset "Guiding Center 4d" begin
    @testset "$(case)" for (case, _, _, Δt, _) in GuidingCenter4dExamples.CASES
        # `similar` keeps the case's own time step and shortens the interval to a single step.
        ode = GuidingCenter4dExamples.odeproblem(case; timespan = (0.0, Δt))
        iode = GuidingCenter4dExamples.iodeproblem(case; timespan = (0.0, Δt))

        @testset "$(family)" for (family, list) in tableaus_ode
            @testset "$(run[2])" for run in list
                @test integrates(ode, run[1])
            end
        end

        @testset "$(family)" for (family, list) in tableaus_iode
            @testset "$(run[2])" for run in list
                @test integrates(iode, run[1])
            end
        end
    end

    # The adapters that bridge the `ChargedParticlePlots` coordinate-vector API to the recipe
    # signatures `run_list` expects are the part most likely to break on a CPD interface change, and
    # the weave path is the only other thing that exercises them. Both equilibria are checked: they
    # are reached through the `EQUILIBRIA` table rather than by `using`, and each draws its own flux
    # surfaces in the poloidal figure and its own coordinate transformation in the cartesian one.
    @testset "plot adapters, $(case)" for case in (:barely_passing, :small_barely_passing)
        using CairoMakie: Figure
        Δt = GuidingCenter4dExamples._case(case)[4]
        equ = GuidingCenter4dExamples.equilibrium(case)
        sol = integrate(
            GuidingCenter4dExamples.iodeproblem(case; timespan = (0.0, 20 * Δt)),
            VPRKGauss(2))

        @test GuidingCenter4dExamples.plot_solution(equ, sol; latex = false) isa Figure
        @test GuidingCenter4dExamples.plot_phase_portrait(equ, sol; latex = false) isa
              Figure
        @test GuidingCenter4dExamples.plot_traces(equ, sol; latex = false) isa Figure
        # Downsampling and truncation are the adapters' own work, not the recipes'.
        @test GuidingCenter4dExamples.plot_traces(
            equ, sol; nplot = 5, nt = 10, latex = false) isa Figure

        # The bundle `run_list` receives must call those adapters with this case's equilibrium, and
        # carry the equilibrium's own toroidal momentum.
        recipes = GuidingCenter4dExamples.plot_recipes(equ)
        @test recipes.solution(sol, nothing; latex = false) isa Figure
        @test recipes.phase_portrait(sol; latex = false) isa Figure
        @test recipes.traces(sol, nothing; latex = false) isa Figure
        @test recipes.invariants[1][1](0.0, sol.q[0], nothing) isa Real
    end
end
