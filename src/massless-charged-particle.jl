module MasslessChargedParticleExamples

    # Time step of the published gallery
    # (`examples/massless_charged_particle/massless_charged_particle_settings.jl` before v0.2).
    const Δt = 0.1

    # The published figures used 10⁶ time steps. With the projection matrix of the VPRK pages
    # running well over a hundred methods per page, that is more than an automated documentation
    # build can carry, so the gallery now runs 10⁵ steps — a tenth of the time interval, and the
    # same length the publication companion packages use. Raise it for a one-off long run.
    const nt = 100000

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
