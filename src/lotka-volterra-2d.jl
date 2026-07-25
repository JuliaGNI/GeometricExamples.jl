module LotkaVolterra2dExamples

    # Time step and number of time steps of the published gallery
    # (`examples/lotka_volterra_2d/lotka_volterra_2d_settings.jl` before v0.2).
    const Δt = 0.01
    const nt = 10000

    using GeometricIntegrators

    using GeometricProblems.LotkaVolterra2d

    import GeometricExamples
    using GeometricExamples

    const PLOT_RECIPES = (solution       = plot_solution,
                          phase_portrait = plot_phase_portrait,
                          traces         = plot_traces,
                          invariants     = ())

    run_list(args...; kwargs...) = GeometricExamples.run_list(PLOT_RECIPES, args...; kwargs...)

    export run_list

end
