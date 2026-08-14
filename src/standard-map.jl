module StandardMapExamples

    using GeometricIntegrators
    using PoincareInvariants
    using CairoMakie

    using Markdown

    import GeometricExamples
    using GeometricExamples: PLOT_DIR, _linebreak, _save_plot, _write_page


    @doc raw"""
    The Chirikov standard map

    ```math
    \theta_{n+1} = \theta_{n} + p_{n+1} , \qquad
    p_{n+1} = p_{n} + K \sin (\theta_{n}) ,
    ```

    written as the partitioned ODE

    ```math
    \dot{\theta} = p , \qquad \dot{p} = K \sin (\theta) ,
    ```

    which [`SymplecticEulerA`](@ref) with unit time step integrates *exactly* into the map above:
    it takes the momentum step first, `p_{n+1} = p_n + K sin(θ_n)`, and then the position step
    with the new momentum, `θ_{n+1} = θ_n + p_{n+1}`. `Δt = 1` is therefore not a discretisation
    parameter but part of the model. (The pre-0.2 gallery named this method
    `getTableauSymplecticEulerB`; the A/B naming has swapped since. `SymplecticEulerB` gives the
    conjugate map `θ_{n+1} = θ_n + p_n`, `p_{n+1} = p_n + K sin(θ_{n+1})`, which is a different
    — equally symplectic — map.)

    Since GeometricIntegrators 0.18 that name is `GeometricIntegratorsBase`'s method rather than
    the partitioned Runge-Kutta one, which took the suffix `SymplecticEulerARK` when the two
    collided. It is the better fit here: it assumes a *separable* Hamiltonian, which is exactly
    what this problem is — `v = v(p)` and `f = f(θ)` above — and under that assumption the two
    substeps decouple and are taken explicitly, with no nonlinear solve at all. The map it
    produces is the same one, so the identity above is unaffected; `test/runtests.jl` pins it
    against the closed form.

    The map is not a `GeometricProblems` problem, so it lives here. It would fit
    `GeometricProblems.jl` well, but that package collects *flows*, not maps, and the identity
    "symplectic Euler-B with `Δt = 1` is the standard map" is a property of this pairing rather
    than of either part.
    """
    function podeproblem(θ₀ = [0.0], p₀ = [0.0]; K, timespan = (0.0, 20.0), timestep = 1.0)
        PODEProblem(standard_map_v, standard_map_f, timespan, timestep, θ₀, p₀;
                    parameters = (K = K,))
    end

    function standard_map_v(v, t, θ, p, params)
        v[1] = p[1]
        nothing
    end

    function standard_map_f(f, t, θ, p, params)
        f[1] = params.K * sin(θ[1])
        nothing
    end


    # Time step, number of steps and stochasticity parameters of the published gallery
    # (`examples/standard_map/standard_map_poincare_{1st,2nd}.jl` before v0.2). `K ≈ 0.971635`
    # is the critical value at which the last invariant torus breaks up.
    const Δt = 1.0
    const nt = 20

    const RUNS = (
        (0.6,      "k0.6"),
        (0.971635, "k0.971635"),
        (1.2,      "k1.2"),
        (2.0,      "k2.0"),
    )

    # Sample counts. The published figures used 100000 points on the loop and a 500×500 grid on
    # the surface. Every sample point is one member of a `GeometricEquations.EnsembleProblem`,
    # each of which gets its own integrator, so those counts are far beyond what an automated
    # documentation build can carry.
    #
    # The reduction costs nothing, because the accuracy of these runs is not limited by the
    # sample count. The map is symplectic, so the invariants are conserved *exactly*; what is
    # approximated is the quadrature of the loop/surface integral over the advected curve. In the
    # regular regime that quadrature is exact to machine precision — measured relative drift over
    # the 20 steps below is ~1e-15 for K = 0.6, and for K = 1.2 up to step 5 — but once the map
    # turns chaotic, neighbouring sample points separate exponentially and no attainable
    # resolution can follow the folded curve: for K = 1.2 over all 20 steps the measured drift is
    # O(10) both at the 20000 loop points used here and at the published 100000. That growth is
    # the phenomenon these figures are about, not an artefact of the counts.
    const NLOOP = 20000
    const NSURFACE = (60, 60)

    # Time slices drawn in the advected loop/surface figures.
    const NPLOT = 10


    # The loop and the surface of the published gallery, both centred on (π, π).
    loop(ϕ)       = (π * (1 + cospi(2ϕ)), π * (1 + 0.5 * sinpi(2ϕ)))
    surface(x, y) = (π + 0.25 * (x - 0.5) * π, π + 0.25 * (y - 0.5) * π)


    """
    Compute the first Poincaré integral invariant of the standard map for every value of `K` in
    `RUNS`, plot its relative error together with the advected loop, and write one markdown page
    per run.
    """
    function run_poincare_1st(name = "Standard Map"; plot_dir = PLOT_DIR, fig_suff = ".png")
        # The Fourier plan of the first invariant needs a periodic parameterisation, which the
        # loop above is; a finite-difference plan would do as well.
        pinv = CanonicalFirstPI{Float64, 2}(NLOOP)

        _run_invariant(pinv, name, "poincare_1st", plot_dir, fig_suff) do _, sol, file
            _save_plot(() -> plot_loop(sol; xlabel = "θ", ylabel = "p", nsteps = NPLOT),
                       plot_dir, file, "_loop", fig_suff)
            ["_loop"]
        end
    end


    """
    Compute the second Poincaré integral invariant of the standard map for every value of `K` in
    `RUNS`, plot its relative error together with the advected surface, and write one markdown
    page per run.
    """
    function run_poincare_2nd(name = "Standard Map"; plot_dir = PLOT_DIR, fig_suff = ".png")
        pinv = CanonicalSecondPI{Float64, 2}(prod(NSURFACE))

        # `plot_surface` needs to reshape the sample points into a grid, which only the
        # finite-difference plan lays out that way, so the figure uses a second, coarser
        # invariant object on the same surface.
        grid = CanonicalSecondPI{Float64, 2}(NSURFACE, SecondFinDiffPlan)

        _run_invariant(pinv, name, "poincare_2nd", plot_dir, fig_suff) do prob, _, file
            gridsol = integrate(PIEnsembleProblem(prob, grid, surface), SymplecticEulerA())
            _save_plot(() -> plot_surface(grid, gridsol; xlabel = "θ", ylabel = "p", nsteps = NPLOT),
                       plot_dir, file, "_surface", fig_suff)
            ["_surface"]
        end
    end


    # Shared driver of the two functions above. `extra` plots whatever is specific to the
    # invariant at hand (the advected loop or surface) and returns the figure suffixes it wrote.
    function _run_invariant(extra, pinv, name, stem, plot_dir, fig_suff)
        isdir(plot_dir) || mkpath(plot_dir)

        for (K, runid) in RUNS
            file = "$(stem)_$(runid)"
            prob = podeproblem(; K = K, timespan = (0.0, Δt * nt), timestep = Δt)

            show(stdout, "text/markdown", Markdown.parse("## K = $(K)"))
            _linebreak(stdout)
            show(stdout, "text/markdown", Markdown.parse("[Plots]($file.md)"))
            _linebreak(stdout)

            # `SymplecticEulerA` with unit time step integrates the standard map exactly, see
            # `podeproblem`.
            sol = integrate(PIEnsembleProblem(prob, pinv, _parameterisation(pinv)), SymplecticEulerA())

            _save_plot(() -> plot_invariant(pinv, sol; title = "K = $(K)"),
                       plot_dir, file, "_invariant", fig_suff)

            suffixes = ["_invariant"; extra(prob, sol, file)]

            _write_page(plot_dir, file, "$name, K = $(K)", fig_suff, suffixes)

            overview = "$plot_dir/$(file)_invariant$fig_suff"
            isfile(overview) && show(stdout, "text/markdown", Markdown.parse("![$name]($overview)"))

            GC.gc()
        end

        nothing
    end

    # The curve parameterisation for the first invariant, the surface one for the second.
    _parameterisation(::FirstPoincareInvariant) = loop
    _parameterisation(::SecondPoincareInvariant) = surface


    export run_poincare_1st, run_poincare_2nd

end
