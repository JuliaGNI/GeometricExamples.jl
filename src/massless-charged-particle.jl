module MasslessChargedParticleExamples

    # Time step of the published gallery
    # (`examples/massless_charged_particle/massless_charged_particle_settings.jl` before v0.2).
    const Δt = 0.1

    # The published figures used 10⁶ time steps, and the first cut of this gallery 10⁵ — a tenth of
    # the time interval, and the length the publication companion packages use. Even that is beyond
    # what the documentation build can carry: at 10⁵ steps the three VPRK pages of this problem each
    # exceeded a four hour job timeout on the CI runners, which are several times slower than a
    # development machine, while `point-vortices` runs the same 126-method Lobatto matrix in 49
    # minutes at 10⁴. This problem is now the only one whose run length is not the published one;
    # raise it for a one-off long run.
    const nt = 10000

    using GeometricIntegrators

    using GeometricProblems.MasslessChargedParticle

    import GeometricExamples
    using GeometricExamples

    const PLOT_RECIPES = (solution       = plot_solution,
                          phase_portrait = plot_phase_portrait,
                          traces         = plot_traces,
                          invariants     = ())

    run_list(args...; kwargs...) = GeometricExamples.run_list(PLOT_RECIPES, args...; kwargs...)

    export run_list

end
