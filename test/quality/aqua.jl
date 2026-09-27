using Test
using Aqua
using GeometricExamples

@testset "Aqua" begin
    Aqua.test_all(GeometricExamples; stale_deps = false)
    # ChargedParticleDynamics, Documenter, PoincareInvariants and Weave are used by the problem
    # scripts in `src/<problem>.jl` and by `docs/`, which the module does not load.
    @test_broken isempty(Aqua.find_stale_deps(Base.PkgId(GeometricExamples)))  # issue #7
end
