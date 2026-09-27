using Test
using GeometricIntegrators
using GeometricExamples

# The standard map and the Poincaré integral invariants are not a `GeometricProblems` problem and
# have their own driver, so they are tested separately: one value of `K`, a handful of sample
# points, and a couple of time steps.
include("../src/standard-map.jl")

@testset "Standard Map" begin
    using PoincareInvariants

    prob = StandardMapExamples.podeproblem(; K = 1.2, timespan = (0.0, 5.0), timestep = 1.0)

    # SymplecticEulerA with unit time step *is* the standard map, so check that identity here: it
    # is the one assumption of the whole example that is neither GeometricIntegrators' nor ours.
    # Since GeometricIntegrators 0.18 the name resolves to GeometricIntegratorsBase's explicit
    # method for separable Hamiltonians rather than to the partitioned Runge-Kutta one, now
    # `SymplecticEulerARK`; this assertion is what says the substitution kept the map intact.
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
    I2 = compute!(pi2,
        integrate(PIEnsembleProblem(regular, pi2, StandardMapExamples.surface),
            SymplecticEulerA()))
    @test maximum(abs, (I2 .- I2[1]) ./ I2[1]) < 1E-10
end
