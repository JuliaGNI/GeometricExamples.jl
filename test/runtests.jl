
using Test
using GeometricIntegrators
import GeometricProblems
using GeometricExamples

# Integrate every method of every family for a single time step on every problem. This is a
# smoke test of the method lists against the current GeometricIntegrators: it catches renamed or
# removed methods, which is the failure mode a version bump of the ecosystem produces. Whether a
# method converges on a given problem is the subject of the woven pages, not of this test.

const tableaus_ode = (
    "Explicit Runge-Kutta"      => tableaus_erk(),
    "Gauss-Legendre"            => tableaus_firk_gauss(),
    "Lobatto"                   => tableaus_firk_lobatto(),
)

const tableaus_iode = (
    "Gauss-Legendre VPRK"       => tableaus_vprk_gauss(),
    "Symmetric SRK3 VPRK"       => tableaus_vprk_srk3(),
    "Lobatto VPRK"              => tableaus_vprk_lobatto(),
    "Symplectic Lobatto VPRK"   => tableaus_vprk_lobatto_symplectic(),
    "Radau IIA VPRK"            => tableaus_vprk_radau(),
)

const problems = (
    GeometricProblems.LotkaVolterra2d,
    GeometricProblems.LotkaVolterra2dSingular,
    GeometricProblems.MasslessChargedParticle,
    GeometricProblems.PointVortices,
)

const nt = 1

# `integrate_partial` reports a failure instead of throwing, which is exactly what a single-step
# smoke test wants: a method that diverges on a degenerate problem, or one whose projection has no
# integrator (`VPRKpInternal`), is a documented outcome and not a test failure. What *is* a failure
# is a method that cannot be built at all — the list naming something the ecosystem no longer has.
function integrates(problem, method)
    sol, last_good, err = integrate_partial(problem, method)
    err isa UndefVarError && return false
    return true
end

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

# The guiding centre problems come from `ChargedParticleDynamics` rather than `GeometricProblems`,
# and each of the four orbits fixes its own time step, so they are driven through the problem module
# instead of the loop above. One step per method, as there.
include("../src/guiding-center-4d.jl")

@testset "Guiding Center 4d" begin
    @testset "$(case)" for (case, _, Δt, _) in GuidingCenter4dExamples.CASES
        # `similar` keeps the case's own time step and shortens the interval to a single step.
        ode = GuidingCenter4dExamples.odeproblem(case; tspan = (0.0, Δt))
        iode = GuidingCenter4dExamples.iodeproblem(case; tspan = (0.0, Δt))

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
    # the weave path is the only other thing that exercises them.
    @testset "plot adapters" begin
        using CairoMakie: Figure
        Δt = 2.5
        sol = integrate(GuidingCenter4dExamples.iodeproblem(:barely_passing;
                                                            tspan = (0.0, 20 * Δt)), VPRKGauss(2))
        equ = GuidingCenter4dExamples.EQUILIBRIUM
        @test GuidingCenter4dExamples.plot_solution(sol, equ; latex = false) isa Figure
        @test GuidingCenter4dExamples.plot_phase_portrait(sol; latex = false) isa Figure
        @test GuidingCenter4dExamples.plot_traces(sol, equ; latex = false) isa Figure
        # Downsampling and truncation are the adapters' own work, not the recipes'.
        @test GuidingCenter4dExamples.plot_traces(sol, equ; nplot = 5, nt = 10, latex = false) isa Figure
    end
end

# The standard map and the Poincaré integral invariants are not a `GeometricProblems` problem and
# have their own driver, so they are tested separately: one value of `K`, a handful of sample
# points, and a couple of time steps.
include("../src/standard-map.jl")

@testset "Standard Map" begin
    using PoincareInvariants

    prob = StandardMapExamples.podeproblem(; K = 1.2, timespan = (0.0, 5.0), timestep = 1.0)

    # SymplecticEulerA with unit time step *is* the standard map, so check that identity here: it
    # is the one assumption of the whole example that is neither GeometricIntegrators' nor ours.
    sol = integrate(prob, SymplecticEulerA())
    θ, p = 0.0, 0.0
    for n in 1:5
        p += 1.2 * sin(θ)
        θ += p
        @test sol.q[n][1] ≈ θ
        @test sol.p[n][1] ≈ p
    end

    # The map is symplectic, so both invariants are conserved exactly; what is approximated is the
    # quadrature over the advected curve and surface. In the regular regime that quadrature holds
    # up — to machine precision for the loop, to about 1E-11 for the surface over these ten steps
    # — while the chaotic regime, where it degrades exponentially, is the subject of the woven
    # pages rather than of a test.
    regular = StandardMapExamples.podeproblem(; K = 0.6, timespan = (0.0, 10.0), timestep = 1.0)

    pi1 = CanonicalFirstPI{Float64, 2}(2000)
    I1 = compute!(pi1, integrate(PIEnsembleProblem(regular, pi1, StandardMapExamples.loop),
                                 SymplecticEulerA()))
    @test maximum(abs, (I1 .- I1[1]) ./ I1[1]) < 1E-13

    pi2 = CanonicalSecondPI{Float64, 2}(2000)
    I2 = compute!(pi2, integrate(PIEnsembleProblem(regular, pi2, StandardMapExamples.surface),
                                 SymplecticEulerA()))
    @test maximum(abs, (I2 .- I2[1]) ./ I2[1]) < 1E-10
end
