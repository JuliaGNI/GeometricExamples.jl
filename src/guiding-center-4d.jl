module GuidingCenter4dExamples

    using GeometricIntegrators
    using CairoMakie

    using ChargedParticleDynamics
    using ChargedParticleDynamics.GuidingCenter4d.TokamakMediumCylindrical

    import GeometricExamples
    using GeometricExamples

    # The equilibrium is the module itself: `ElectromagneticFields.@code` injects the field into it,
    # so `EQUILIBRIUM.R`, `.X`, `.Y`, `.Z` are its coordinate functions and `cartesian_solution`
    # takes it as its second argument.
    const EQUILIBRIUM = ChargedParticleDynamics.GuidingCenter4d.TokamakMediumCylindrical


    # Time steps and numbers of steps of the published gallery
    # (`examples/guiding_center_4d/tokamak_fast_particles/*.jl` before v0.2, whose comments record a
    # per-case Δt). The published runs used ten times as many steps; as for the massless charged
    # particle, that is more than an automated documentation build can carry across a whole
    # projection matrix, and the orbits are already closed at this length.
    const CASES = (
        (:barely_passing, initial_conditions_barely_passing, 2.5, 12500),
        (:barely_trapped, initial_conditions_barely_trapped, 3.0, 12500),
        (:deeply_passing, initial_conditions_deeply_passing, 2.5, 12500),
        (:deeply_trapped, initial_conditions_deeply_trapped, 5.0, 12500),
    )

    _case(name) = CASES[findfirst(c -> c[1] === name, CASES)]

    """
        iodeproblem(case; kwargs...)
        odeproblem(case; kwargs...)

    The guiding centre problem of one particle case — `:barely_passing`, `:barely_trapped`,
    `:deeply_passing` or `:deeply_trapped` — at that case's time step and number of steps.

    `periodic = false`: the toroidal angle is periodic, and wrapping it would tear the trajectory
    figures apart. The old gallery's plot recipes unwrapped it; here the solution simply keeps
    winding.
    """
    function iodeproblem(case::Symbol; kwargs...)
        _, ics, Δt, nt = _case(case)
        guiding_center_4d_iode(ics()...; tspan = (0.0, Δt * nt), tstep = Δt, periodic = false, kwargs...)
    end

    function odeproblem(case::Symbol; kwargs...)
        _, ics, Δt, nt = _case(case)
        guiding_center_4d_ode(ics()...; tspan = (0.0, Δt * nt), tstep = Δt, periodic = false, kwargs...)
    end


    # ── Adapters ──────────────────────────────────────────────────────────────────────────────
    #
    # `run_list` expects the GeometricProblems recipe signatures — `solution(sol, equ; latex, nplot,
    # nt)`, `phase_portrait(sol; …)`, `traces(sol, equ; …)`, each returning a `Figure`. The
    # `ChargedParticlePlots` extension is deliberately lower level: its functions take plain
    # coordinate vectors and return `(figure, axis)`, which is what lets them draw the trajectory in
    # cartesian 3-space rather than in the first two state components. The adapters below do the
    # downsampling and truncation the recipes would otherwise do, and drop the axis.
    #
    # The three slots carry the figures the published gallery called `_trajectory_2d`,
    # `_trajectory_3d` and `_traces`.

    # `0:nplot:nt` over the stored steps, as the GeometricProblems recipes define it.
    _indices(sol, nplot, nt) = 0:nplot:(nt === :auto ? ntime(sol) : min(nt, ntime(sol)))

    _component(sol, idx, i) = [sol.q[n][i] for n in idx]

    "Poloidal `R`–`Z` projection of the orbit, the gallery's overview figure."
    function plot_solution(sol, equ; nplot = 1, nt = :auto, latex = false)
        idx = _indices(sol, nplot, nt)
        plot_trajectory_poloidal(_component(sol, idx, 1), _component(sol, idx, 2), EQUILIBRIUM)[1]
    end

    # The cartesian coordinates come from `cartesian_solution` rather than from the equilibrium's
    # `X`/`Y`/`Z` directly: those take the three *spatial* coordinates, and the guiding centre state
    # carries the parallel velocity as its fourth component.
    "The orbit in cartesian 3-space."
    function plot_phase_portrait(sol; nplot = 1, nt = :auto, latex = false)
        idx = _indices(sol, nplot, nt)
        cs = cartesian_solution(sol, EQUILIBRIUM)
        plot_trajectory_3d([cs.X[n] for n in idx], [cs.Y[n] for n in idx], [cs.Z[n] for n in idx])[1]
    end

    "Time traces of the four state components `R`, `Z`, `φ` and `u`."
    function plot_traces(sol, equ; nplot = 1, nt = :auto, latex = false)
        idx = _indices(sol, nplot, nt)
        ts = [sol.t[n] for n in idx]
        plot_trajectory_cylindrical(ts, (_component(sol, idx, i) for i in 1:4)...)[1]
    end


    # The toroidal momentum is the guiding centre's second invariant. The problems do not declare it
    # among their `invariants` — only the energy `:h` — so it is passed as the function itself,
    # wrapped to the `(t, q, params)` signature `compute_invariant` calls it with.
    const TOROIDAL_MOMENTUM = (t, q, params) -> toroidal_momentum(t, q)

    const PLOT_RECIPES = (solution       = plot_solution,
                          phase_portrait = plot_phase_portrait,
                          traces         = plot_traces,
                          invariants     = ((TOROIDAL_MOMENTUM, "toroidal_momentum", "Toroidal Momentum"),))

    run_list(args...; kwargs...) = GeometricExamples.run_list(PLOT_RECIPES, args...; kwargs...)

    export iodeproblem, odeproblem, run_list

end
