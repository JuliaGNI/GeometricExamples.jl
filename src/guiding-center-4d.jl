module GuidingCenter4dExamples

    using GeometricIntegrators
    using CairoMakie

    using ChargedParticleDynamics

    import GeometricExamples
    using GeometricExamples

    # The two tokamak equilibria the pre-0.2 gallery ran, reached through this table rather than
    # brought into scope with `using`: every guiding-centre submodule of ChargedParticleDynamics
    # exports the same names — `initial_conditions_*`, `odeproblem`, `toroidal_momentum` — one
    # method each, so no two of them can be `using`ed together. This is the same indirection
    # `src/guiding-center-4d-poincare.jl` needs for its two geometries. Since CPD 0.3 renamed the
    # constructors to the `GeometricProblems` scheme those names also collide with the problem
    # modules of `GeometricProblems` itself, which is a second reason to keep them qualified.
    #
    # `ElectromagneticFields.@code` injects the magnetic field into the module itself, so the module
    # *is* the equilibrium: `equ.R`, `.X`, `.Y`, `.Z` are its coordinate functions, and
    # `cartesian_solution` and `plot_trajectory_poloidal` take it as an argument.
    const EQUILIBRIA = (
        medium = ChargedParticleDynamics.GuidingCenter4d.TokamakMediumCylindrical,
        small  = ChargedParticleDynamics.GuidingCenter4d.TokamakSmallCylindrical,
    )


    # `(case, equilibrium, initial conditions, Δt, number of steps)`.
    #
    # The medium-tokamak time steps are those of the published gallery
    # (`examples/guiding_center_4d/tokamak_fast_particles/*.jl` before v0.2, whose comments record a
    # per-case Δt); its published runs used ten times as many steps, which is more than an automated
    # documentation build can carry across a whole projection matrix, and the orbits are already
    # closed at this length.
    #
    # The small tokamak carries slow particles — `u ~ 8E-4` against the medium tokamak's `3E-1` — so
    # its orbits need a time step three hundred times larger. `Δt = 800` is the one
    # `examples/guiding_center_4d/tokamak_slow_particles/*.jl` used; those scripts asked for 1.25·10⁶
    # steps, but at 12500 the orbits are resolved many times over — between 208 and 1239 poloidal
    # transits, depending on the case — so they are run at the same length as everything else.
    #
    # The medium-tokamak cases keep their unprefixed names, which the problem names, page files and
    # documentation of the trajectory family are built on.
    const CASES = (
        (:barely_passing,       :medium, :initial_conditions_barely_passing,   2.5, 12500),
        (:barely_trapped,       :medium, :initial_conditions_barely_trapped,   3.0, 12500),
        (:deeply_passing,       :medium, :initial_conditions_deeply_passing,   2.5, 12500),
        (:deeply_trapped,       :medium, :initial_conditions_deeply_trapped,   5.0, 12500),
        (:small_barely_passing, :small,  :initial_conditions_barely_passing, 800.0, 12500),
        (:small_barely_trapped, :small,  :initial_conditions_barely_trapped, 800.0, 12500),
        (:small_deeply_passing, :small,  :initial_conditions_deeply_passing, 800.0, 12500),
        (:small_deeply_trapped, :small,  :initial_conditions_deeply_trapped, 800.0, 12500),
    )

    _case(name) = CASES[findfirst(c -> c[1] === name, CASES)]

    "The equilibrium module a case belongs to."
    equilibrium(case::Symbol) = EQUILIBRIA[_case(case)[2]]


    """
        iodeproblem(case; kwargs...)
        odeproblem(case; kwargs...)

    The guiding centre problem of one particle case at that case's equilibrium, time step and number
    of steps. The cases are `:barely_passing`, `:barely_trapped`, `:deeply_passing` and
    `:deeply_trapped` on the medium-size tokamak, and the same four prefixed with `small_` on the
    small one.

    `periodic = false`: the toroidal angle is periodic, and wrapping it would tear the trajectory
    figures apart. The old gallery's plot recipes unwrapped it; here the solution simply keeps
    winding.
    """
    iodeproblem(case::Symbol; kwargs...) = _problem(:iodeproblem, case; kwargs...)
    odeproblem(case::Symbol; kwargs...) = _problem(:odeproblem, case; kwargs...)

    # `initial_conditions_*` returns `(q = …, params = …)`, and the constructors take that named
    # tuple whole — the magnetic moment `μ` of the case travels in its `params`. Before CPD 0.3 the
    # initial conditions were a bare tuple and `parameters` a positional argument, so this was a
    # splat.
    function _problem(constructor::Symbol, case::Symbol; kwargs...)
        _, eq, ics, Δt, nt = _case(case)
        equ = EQUILIBRIA[eq]
        getproperty(equ, constructor)(getproperty(equ, ics)();
                                      timespan = (0.0, Δt * nt), timestep = Δt,
                                      periodic = false, kwargs...)
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

    "Poloidal `R`–`Z` projection of the orbit, over the equilibrium's flux surfaces."
    function plot_solution(equ, sol; nplot = 1, nt = :auto, latex = false)
        idx = _indices(sol, nplot, nt)
        plot_trajectory_poloidal(_component(sol, idx, 1), _component(sol, idx, 2), equ)[1]
    end

    # The cartesian coordinates come from `cartesian_solution` rather than from the equilibrium's
    # `X`/`Y`/`Z` directly: those take the three *spatial* coordinates, and the guiding centre state
    # carries the parallel velocity as its fourth component.
    "The orbit in cartesian 3-space."
    function plot_phase_portrait(equ, sol; nplot = 1, nt = :auto, latex = false)
        idx = _indices(sol, nplot, nt)
        cs = cartesian_solution(sol, equ)
        plot_trajectory_3d([cs.X[n] for n in idx], [cs.Y[n] for n in idx], [cs.Z[n] for n in idx])[1]
    end

    "Time traces of the four state components `R`, `Z`, `φ` and `u`."
    function plot_traces(equ, sol; nplot = 1, nt = :auto, latex = false)
        idx = _indices(sol, nplot, nt)
        ts = [sol.t[n] for n in idx]
        plot_trajectory_cylindrical(ts, (_component(sol, idx, i) for i in 1:4)...)[1]
    end


    # The recipe bundle of one equilibrium. `run_list` calls the recipes with the *problem* as their
    # second argument, which these adapters have no use for — the equilibrium is bound here instead,
    # since it is a property of the case and not of the solution.
    #
    # The toroidal momentum is the guiding centre's second invariant. The problems do not declare it
    # among their `invariants` — only the energy `:h` — so it is passed as the function itself,
    # wrapped to the `(t, q, params)` signature `compute_invariant` calls it with.
    function plot_recipes(equ)
        (solution       = (sol, _prob; kwargs...) -> plot_solution(equ, sol; kwargs...),
         phase_portrait = (sol; kwargs...) -> plot_phase_portrait(equ, sol; kwargs...),
         traces         = (sol, _prob; kwargs...) -> plot_traces(equ, sol; kwargs...),
         invariants     = (((t, q, params) -> equ.toroidal_momentum(t, q),
                            "toroidal_momentum", "Toroidal Momentum"),))
    end

    run_list(case::Symbol, args...; kwargs...) =
        GeometricExamples.run_list(plot_recipes(equilibrium(case)), args...; kwargs...)

    export iodeproblem, odeproblem, run_list

end
