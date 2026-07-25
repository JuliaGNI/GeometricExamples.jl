module GuidingCenter4dPoincareExamples

    using GeometricIntegrators
    using PoincareInvariants
    using CairoMakie

    using ChargedParticleDynamics

    using Markdown

    import GeometricExamples
    using GeometricExamples: PLOT_DIR, SOLVER_OPTIONS, QUIET_LOG_COUNT,
                             _failure_message, _headline, _linebreak, _save_plot, _write_page


    # The two equilibria the pre-0.2 gallery computed the invariants on. Unlike
    # `src/guiding-center-4d.jl`, which needs only one of them, this module cannot `using` the
    # submodules: they export the *same* names (`guiding_center_4d_loop_ode`,
    # `guiding_center_4d_poincare_invariant_1st`, …), one method each, closing over that
    # equilibrium's loop, surface and magnetic moment. Everything below therefore reaches them
    # through this table, module-qualified.
    #
    # `TokamakMediumCylindrical` is the pre-0.2 `TokamakFastLoop`/`TokamakFastSurface` — the
    # medium-size tokamak in cylindrical coordinates, loop and surface centred on
    # `(R, Z) = (1.75, 0)` at `u = 0.5`, `μ = 1E-3` — and `SymmetricField` the pre-0.2
    # `SymmetricLoop`/`SymmetricSurface`, the quadratic field `B = B₀ (1 + x² + y²) eᶻ` in
    # cartesian coordinates at `μ = 1E-2`. Both parameterisations survived the CPD rewrite
    # unchanged, so nothing about the published geometry needs to be restated here.
    const GEOMETRIES = (
        tokamak   = ChargedParticleDynamics.GuidingCenter4d.TokamakMediumCylindrical,
        symmetric = ChargedParticleDynamics.GuidingCenter4d.SymmetricField,
    )


    # Time interval, time steps and sample counts. The published gallery ran each page four times,
    # once per time step of `TIMESTEPS`, over a fixed interval: `t_end = 5E4` for the first
    # invariant, `2.5E4` for the second on the tokamak and `1E4` for the second on the symmetric
    # field, sampling the loop at 200 (tokamak) or 2000 (symmetric) points and the surface on a
    # 200×200 or 100×100 grid.
    #
    # Every sample point is one member of a `GeometricEquations.EnsembleProblem` with its own
    # implicit integrator, so the published counts are far out of reach for an automated build: the
    # four runs of a single method already cost `N × t_end × (1 + 1/2 + 1/5 + 1/10)` member-steps.
    # The interval is therefore cut to 10³ and the sample counts to ~200, which brings the most
    # expensive page (36 projected VPRK methods) to about ten minutes.
    #
    # Neither reduction changes what the figures show, because what limits these runs is the
    # integrator and not the quadrature on the advected loop or surface. Measured over the interval
    # below, the first invariant of the tokamak loop comes out as -0.18748739226999156 at 100, 200,
    # 400 and 800 sample points alike, and the second to ten digits at 45, 105, 231 and 435 — while
    # the drift spans six orders of magnitude between the methods and their time steps, which is
    # what the four curves of every `_invariant` figure are there to show: `VPRKGauss(2)` loses
    # 3E-1 of the invariant at `Δt = 10` and 3E-3 at `Δt = 1`, its symmetric projection 3E-5 and
    # 5E-11.
    const TIMESPAN_END = 1E3
    const TIMESTEPS = (10.0, 5.0, 2.0, 1.0)

    # Loop sample count, and point specification of the surface. `FirstFourierPlan` takes any
    # number of loop points; the second invariant's `SecondChebyshevPlan` samples the surface at
    # Padua points and rounds the count up to the next Padua number, of which 231 = 21·22/2 is one.
    const NLOOP = 200
    const NSURFACE = 231

    # Time slices drawn in the advected loop and surface figures, and orbits drawn in the
    # trajectory bundle. The published values were 4–10, depending on the page.
    const NPLOT = 5
    const NTRAJECTORIES = 10


    # ── Adapters ──────────────────────────────────────────────────────────────────────────────
    #
    # `ChargedParticleDynamics`' Makie extension is deliberately lower level than a plot recipe:
    # `plot_poincare_loop`, `plot_poincare_surface` and `plot_poincare_trajectories` take plain
    # vectors of cartesian coordinates and return `(figure, axis)`, which is what lets them draw
    # the advected loop in cartesian 3-space rather than in the first two state components. The
    # adapters below gather those vectors out of the `EnsembleSolution` and drop the axis, as the
    # trajectory adapters in `src/guiding-center-4d.jl` do for the trajectory recipes.
    #
    # `to_cartesian` is injected into the equilibrium module by `ElectromagneticFields.@code`. It
    # takes the three spatial coordinates and ignores the guiding centre state's fourth component,
    # the parallel velocity, so the state vector can be passed to it whole. On `SymmetricField`,
    # whose coordinates are already cartesian, it is the identity.

    # One entry per saved time, each holding the coordinate of every ensemble member: the advected
    # loop or surface, sliced in time.
    function _cartesian_slices(sol, equ)
        ts = [sol[1].t[n] for n in 0:ntime(sol[1])]
        slices = [[equ.to_cartesian(sol[j].t[n], sol[j].q[n]) for j in 1:nsamples(sol)]
                  for n in 0:ntime(sol[1])]
        coordinate(i) = [[point[i] for point in slice] for slice in slices]
        (ts, coordinate(1), coordinate(2), coordinate(3))
    end

    # The same data by ensemble member instead of by time: the bundle of orbits the loop points
    # travel along.
    function _cartesian_orbits(sol, equ)
        orbits = [[equ.to_cartesian(sol[j].t[n], sol[j].q[n]) for n in 0:ntime(sol[j])]
                  for j in 1:nsamples(sol)]
        coordinate(i) = [[point[i] for point in orbit] for orbit in orbits]
        (coordinate(1), coordinate(2), coordinate(3))
    end


    # The geometry figures of the first invariant: the advected loop and the orbits its points
    # travel along, the published `_loop` and `_trajectories`. Returns the suffixes it wrote.
    function _loop_figures(sol, equ, dir, file, fig_suff)
        ts, X, Y, Z = _cartesian_slices(sol, equ)
        _save_plot(() -> plot_poincare_loop(ts, X, Y, Z; nplot = NPLOT)[1],
                   dir, file, "_loop", fig_suff)

        XT, YT, ZT = _cartesian_orbits(sol, equ)
        _save_plot(() -> plot_poincare_trajectories(XT, YT, ZT; nplot = NTRAJECTORIES)[1],
                   dir, file, "_trajectories", fig_suff)

        ["_loop", "_trajectories"]
    end

    # The geometry figure of the second invariant, the published `_area`. `plot_poincare_surface`
    # is a 3-d scatter and does not reshape its points into a grid, so — unlike
    # `PoincareInvariants.plot_surface`, around which `src/standard-map.jl` needs a second, coarser
    # invariant object on a finite-difference plan — the accurate Chebyshev invariant serves both
    # the number and the figure here.
    function _surface_figures(sol, equ, dir, file, fig_suff)
        ts, X, Y, Z = _cartesian_slices(sol, equ)
        _save_plot(() -> plot_poincare_surface(ts, X, Y, Z; nplot = NPLOT)[1],
                   dir, file, "_surface", fig_suff)

        ["_surface"]
    end


    # Everything that distinguishes the two invariants, in one table. `invariant` builds the
    # noncanonical `FirstPI`/`SecondPI` from the equilibrium's one- and two-form, `ode`/`iode` the
    # base problem whose flow advects the loop or the surface, and `ensemble` samples the
    # parameterisation into one ensemble member per sample point.
    const SPECS = (
        first = (stem      = "poincare_1st",
                 npoints   = NLOOP,
                 invariant = (m, N) -> m.guiding_center_4d_poincare_invariant_1st(N),
                 ode       = (m; kwargs...) -> m.guiding_center_4d_loop_ode(; kwargs...),
                 iode      = (m; kwargs...) -> m.guiding_center_4d_loop_iode(; kwargs...),
                 ensemble  = (m, prob, pinv) -> m.guiding_center_4d_loop_ensemble(prob, pinv),
                 figures   = _loop_figures),

        second = (stem      = "poincare_2nd",
                  npoints   = NSURFACE,
                  invariant = (m, N) -> m.guiding_center_4d_poincare_invariant_2nd(N),
                  ode       = (m; kwargs...) -> m.guiding_center_4d_surface_ode(; kwargs...),
                  iode      = (m; kwargs...) -> m.guiding_center_4d_surface_iode(; kwargs...),
                  ensemble  = (m, prob, pinv) -> m.guiding_center_4d_surface_ensemble(prob, pinv),
                  figures   = _surface_figures),
    )


    """
        odeproblem(kind, geometry; kwargs...)
        iodeproblem(kind, geometry; kwargs...)

    The base problem of the `kind` (`:first` or `:second`) invariant on `geometry` (`:tokamak` or
    `:symmetric`), whose flow advects the loop or the surface. Its initial condition is a
    placeholder that the ensemble builder replaces with the sampled points, so only the time span
    and time step need to be passed. `ChargedParticleDynamics` still names those `tspan` and
    `tstep`, not `timespan` and `timestep`.

    The explicit form pairs with the fully implicit Runge-Kutta methods, the variational one with
    the projected VPRK methods, exactly as on the trajectory pages.
    """
    odeproblem(kind::Symbol, geometry::Symbol; kwargs...) =
        SPECS[kind].ode(GEOMETRIES[geometry]; kwargs...)

    iodeproblem(kind::Symbol, geometry::Symbol; kwargs...) =
        SPECS[kind].iode(GEOMETRIES[geometry]; kwargs...)


    # Integrate one ensemble, reporting a failure on the page instead of propagating it. Building
    # the integrator happens inside `integrate`, so this covers the methods that have no integrator
    # in GeometricIntegrators 0.16 — the internal stage projection listed on every VPRK page — as
    # well as a diverging run. `GeometricExamples.integrate_partial`, which the trajectory pages use
    # for the same purpose, is not applicable: it steps a single `GeometricSolution` by hand.
    function _integrate_ensemble(ensemble, method, label)
        try
            integrate(ensemble, method; SOLVER_OPTIONS...)
        catch ex
            show(stdout, "text/markdown",
                 Markdown.parse("**$(label) failed: $(_failure_message(ex)).**"))
            _linebreak(stdout)
            @warn("$(label) failed: $(_failure_message(ex))")
            nothing
        end
    end


    """
        run_poincare(kind, geometry, problem, name, list; plot_dir = PLOT_DIR, fig_suff = ".png")

    Compute the `kind` (`:first` or `:second`) Poincaré integral invariant of the four-dimensional
    guiding centre dynamics on `geometry` (`:tokamak` or `:symmetric`) with every method of `list`,
    and write one markdown page per method.

    `problem` is `odeproblem` or `iodeproblem`, whichever formulation the methods of `list` apply
    to. Each method is run once per time step in `TIMESTEPS` over the same time interval, and the
    relative errors of the invariant are drawn as four labelled curves in one figure — the published
    gallery devoted a page to each time step, and how fast a method loses the invariant as the time
    step is coarsened is precisely what those four pages were comparing.

    The advected loop or surface, and for the first invariant the bundle of orbits its points travel
    along, are drawn from the finest run that completed.
    """
    function run_poincare(kind::Symbol, geometry::Symbol, problem, name, list,
                          plot_dir = PLOT_DIR; fig_suff = ".png")

        spec = SPECS[kind]
        equ = GEOMETRIES[geometry]

        isdir(plot_dir) || mkpath(plot_dir)

        for run in list
            method, runid = run[1], run[2]

            file = "$(spec.stem)_$(geometry)_$(runid)"
            headline = _headline(method, runid)

            show(stdout, "text/markdown", Markdown.parse("## $(headline)"))
            _linebreak(stdout)

            show(stdout, "text/markdown", Markdown.parse("[Plots]($file.md)"))
            _linebreak(stdout)

            # One invariant object for all time steps: it depends on the equilibrium's one- or
            # two-form and on the number of sample points only, not on the flow that advects them.
            pinv = spec.invariant(equ, spec.npoints)

            sweep = Pair{String}[]
            params = nothing

            for Δt in TIMESTEPS
                prob = problem(geometry; tspan = (0.0, TIMESPAN_END), tstep = Δt)
                sol = _integrate_ensemble(spec.ensemble(equ, prob, pinv), method, "Δt = $(Δt)")
                sol === nothing && continue
                push!(sweep, "Δt = $(Δt)" => sol)
                params = parameters(prob)
            end

            suffixes = String[]

            if isempty(sweep)
                show(stdout, "text/markdown",
                     Markdown.parse("**No time step completed; no figures for this run.**"))
                _linebreak(stdout)
            else
                # `plot_invariant` has to be qualified: `ChargedParticleDynamics` exports one of its
                # own, for the error of a scalar invariant over a single solution, and this page
                # needs both packages loaded. `p` is not optional here — these are *noncanonical*
                # invariants, built from `ϑ` and `ω = dϑ`, which take the parameters.
                _save_plot(() -> PoincareInvariants.plot_invariant(pinv, sweep...; p = params,
                                                                   title = headline),
                           plot_dir, file, "_invariant", fig_suff)
                push!(suffixes, "_invariant")

                # The geometry figures come from the last, finest run of the sweep.
                append!(suffixes, spec.figures(last(sweep).second, equ, plot_dir, file, fig_suff))
            end

            _write_page(plot_dir, file, "$name, $headline", fig_suff, suffixes)

            overview = "$plot_dir/$(file)_invariant$fig_suff"
            isfile(overview) && show(stdout, "text/markdown", Markdown.parse("![$name]($overview)"))

            # Each run holds one ensemble solution per time step, and one set of Makie figures.
            GC.gc()
        end

        if QUIET_LOG_COUNT[] > 0
            @info("Suppressed $(QUIET_LOG_COUNT[]) solver/plotting warnings so far (see QUIET_LOG_MODULES)")
        end

        nothing
    end


    export odeproblem, iodeproblem, run_poincare

end
