using Test
using GeometricIntegrators
using GeometricExamples

# The guiding-centre Poincaré integral invariants have their own driver too. A run of it integrates
# an ensemble of a few hundred members once per time step of its sweep, which is far too much for a
# test, so what is tested here are the pieces it composes — at a handful of sample points over four
# time steps, for both invariants, on both geometries and in both formulations.
include("../src/guiding-center-4d-poincare-1st.jl")
include("../src/guiding-center-4d-poincare-2nd.jl")

using CairoMakie: Figure
using PoincareInvariants

const GCP = GuidingCenter4dPoincareExamples

@testset "Guiding Center 4d Poincaré Invariants" begin
    Δt = 2.5
    timespan = (0.0, 4Δt)

    # The loop takes any number of sample points; 45 = 9·10/2 is a Padua number, which is what the
    # surface's Chebyshev plan rounds its point count up to.
    npoints(kind) = kind === :first ? 32 : 45

    @testset "$(kind), $(geometry)" for kind in (:first, :second),
        geometry in (:tokamak, :symmetric)

        spec = GCP.SPECS[kind]
        equ = GCP.GEOMETRIES[geometry]

        # One invariant object across the runs, as the driver reuses it across its time steps.
        pinv = spec.invariant(equ, npoints(kind))

        # The explicit formulation with a fully implicit Runge-Kutta method and the variational one
        # with a projected VPRK method: the two pairings the pages are built on.
        @testset "$(nameof(typeof(method)))" for (problem, method) in ((
            GCP.odeproblem, Gauss(2)), (GCP.iodeproblem, VPRKpSymmetric(VPRKGauss(2))))
            prob = problem(kind, geometry; timespan = timespan, timestep = Δt)
            sol = integrate(spec.ensemble(equ, prob, pinv), method)
            I = compute!(pinv, sol, parameters(prob))

            @test I isa Vector
            @test length(I) == 5
            # The dynamics is symplectic, so the invariant is conserved up to the integrator's error.
            @test maximum(abs, (I .- I[begin]) ./ I[begin]) < 1E-2
        end
    end

    # The adapters that gather cartesian coordinate vectors out of an `EnsembleSolution`, and the
    # figures built from them, are the part most likely to break on a CPD interface change; the
    # weave path is the only other thing that exercises them. Both geometries are checked because
    # `to_cartesian` is a coordinate transformation on the tokamak and the identity on the
    # symmetric field.
    @testset "figures, $(kind), $(geometry)" for kind in (:first, :second),
        geometry in (:tokamak, :symmetric)

        spec = GCP.SPECS[kind]
        equ = GCP.GEOMETRIES[geometry]

        pinv = spec.invariant(equ, npoints(kind))
        prob = GCP.odeproblem(kind, geometry; timespan = timespan, timestep = Δt)
        sol = integrate(spec.ensemble(equ, prob, pinv), Gauss(2))

        ts, X, Y, Z = GCP._cartesian_slices(sol, equ)
        @test length(ts) == length(X) == length(Y) == length(Z) == 5
        @test all(length.(X) .== nsamples(sol))

        XT, YT, ZT = GCP._cartesian_orbits(sol, equ)
        @test length(XT) == length(YT) == length(ZT) == nsamples(sol)
        @test all(length.(XT) .== 5)

        # `plot_invariant` has to be qualified: `ChargedParticleDynamics` exports one of its own.
        @test PoincareInvariants.plot_invariant(pinv, "Δt = $(Δt)" => sol;
            p = parameters(prob)) isa Figure

        mktempdir() do dir
            suffixes = spec.figures(sol, equ, dir, "figure", ".png")
            @test !isempty(suffixes)
            @test all(suffix -> isfile("$(dir)/figure$(suffix).png"), suffixes)
        end
    end

    # The two thin modules differ from each other in the invariant they bind and in nothing else,
    # which a copy-paste leaves easy to get wrong and the weave path would only reveal by producing
    # the same figures twice.
    @test GuidingCenter4dPoincare1stExamples.KIND === :first
    @test GuidingCenter4dPoincare2ndExamples.KIND === :second
end
