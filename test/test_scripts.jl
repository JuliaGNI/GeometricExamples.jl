#
# Smoke test for the weave path: `run_list`, `run_convergence` and the Poincaré invariant drivers,
# `integrate_partial`, and the whole CairoMakie plotting stack.
#
#   julia --project test/test_scripts.jl
#
# Not part of `runtests.jl`: it is comparatively slow and produces files.
#

using GeometricIntegrators
using GeometricExamples

for problem in ("lotka-volterra-2d", "lotka-volterra-2d-singular",
                "massless-charged-particle", "point-vortices", "standard-map")
    include(joinpath(@__DIR__, "../src/$(problem).jl"))
end

# The drivers write one markdown page per run into the working directory and the figures into
# `figures/` below it, so they run in a temporary directory rather than in the repository.
mktempdir() do dir
    cd(dir) do
        # A hundred time steps: enough for the energy drift diagnostic, which needs at least ten
        # steps to have intervals.
        short(mod, kind = :iodeproblem) = getfield(mod, kind)(; timestep = 0.01, timespan = (0.0, 1.0))

        # One method per family, and one that is expected to fail (`VPRKpInternal`, whose
        # projection has no integrator), so that the crash-reporting path is exercised too.
        # The explicit and fully implicit Runge-Kutta methods run on the `odeproblem`, the
        # variational ones on the `iodeproblem`, exactly as the weave pages do.
        LotkaVolterra2dExamples.run_list(short(LotkaVolterra2dExamples, :odeproblem),
            "Lotka-Volterra 2d", ((RK416(), "erk4_16"), (Gauss(2), "firk_gauss2")))
        LotkaVolterra2dExamples.run_list(short(LotkaVolterra2dExamples), "Lotka-Volterra 2d",
            ((VPRKpSymmetric(VPRKGauss(2)), "vprk_gauss2_psymmetric"),
             (VPRKpInternal(VPRKGauss(2)), "vprk_gauss2_pinternal")))

        # The singular Lagrangian, on which the non-symplectic Lobatto VPRK methods break down.
        LotkaVolterra2dSingularExamples.run_list(short(LotkaVolterra2dSingularExamples),
            "Lotka-Volterra 2d (singular)",
            ((VPRKLobattoIIIAIIIB(3), "vprk_lobatto_IIIA_IIIB3"),
             (VPRKLobattoIIIA(3), "vprk_lobatto_IIIA3")))

        MasslessChargedParticleExamples.run_list(short(MasslessChargedParticleExamples),
            "Massless Charged Particle", ((VPRKGauss(2), "vprk_gauss2"),))

        # The point vortices exercise the secondary-invariant path (angular momentum).
        PointVorticesExamples.run_list(short(PointVorticesExamples), "Point Vortices",
            ((VPRKGauss(2), "vprk_gauss2"),))

        # … and the convergence study, with few refinements to keep it quick.
        PointVorticesExamples.run_convergence(
            PointVorticesExamples.iodeproblem(; timestep = 0.1, timespan = (0.0, 1.0)),
            "Point Vortices", ((VPRKGauss(2), "vprk_gauss2"),); nrefine = 3, nreference = 2)

        # The Poincaré integral invariants.
        StandardMapExamples.run_poincare_1st()
        StandardMapExamples.run_poincare_2nd()

        @info "Generated pages and figures in $(dir):" readdir(dir) readdir("figures")
    end
end
