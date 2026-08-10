
using LinearAlgebra: SingularException
using Logging
using Markdown
using Markdown: MD, Paragraph, LineBreak

using CairoMakie

using GeometricIntegrators
import GeometricIntegratorsBase
const GIB = GeometricIntegratorsBase
using SimpleSolvers: NonlinearSolverException

using GeometricProblems.Diagnostics: plot_energy_error, plot_energy_drift,
    plot_invariant_error, plot_invariant_drift,
    plot_constraint_error, plot_lagrange_multiplier


# Output directory for the figures, relative to the directory the weave document runs in.
const PLOT_DIR = "figures"


# Shared Makie plotting style (kept identical to the three publication companion packages
# `degenerate-variational-integrators`, `spark-methods-…` and `srk-methods-…`). Larger fonts
# and thicker lines than the Makie defaults, tuned for the fixed figure sizes of the
# GeometricProblems plot recipes. Unicode axis labels are selected via `latex=false` on every
# plot call below.
# The theme is activated in the module's `__init__` (a `set_theme!` in the module body would
# only run during precompilation and have no effect at runtime).
const PLOT_THEME = Theme(
    fontsize = 18,
    Lines    = (linewidth = 2,),
    Scatter  = (markersize = 10,),
    Axis     = (
        xlabelsize     = 22,
        ylabelsize     = 22,
        xticklabelsize = 16,
        yticklabelsize = 16,
        titlesize      = 20,
    ),
)


# Solver options for every run. The gallery used to set these globally through
# `set_config(:nls_atol, …)`, which no longer exists; they are now keyword arguments of the
# integrator. The values are the ones the publication companion packages settled on, which keeps
# the two comparable. The pre-0.2 settings files asked for `nls_atol = 8eps()`,
# `nls_rtol = 2eps()`, `nls_nmax = 20` — a tighter tolerance with fewer iterations allowed.
#
# `ChargedParticleDynamics` deliberately does *not* agree: its test suite asks for
# `f_abstol = 1E-12` and leaves `f_reltol` at its `√eps` default, because `SimpleSolvers` accepts an
# iterate when `rf ≤ f_abstol + f_reltol ‖F(x₀)‖`, so pinning both terms collapses that test to the
# absolute one — and on an ITER-scale equilibrium, where the residual carries `p = ϑ(q)` with
# `‖ϑ‖ ≈ 15`, no residual can fall below `‖ϑ‖ eps ≈ 3E-15` and the solver runs to its iteration cap
# on half the steps. See `scripts/study_solver_tolerances.jl` there.
#
# None of the problems here is in that class, so the settings above are kept for comparability with
# the companion packages rather than aligned with CPD. On the guiding-centre tokamak loop
# `‖ϑ‖ ≈ 0.985`, a floor of 2.2E-16, and the solver converges in two Newton iterations without any
# of 4000 solves reaching the cap; adopting CPD's setting was measured at ~20% on the projected VPRK
# runs and nothing on the rest, with identical step counts and failure modes across the gallery.
const SOLVER_OPTIONS = (f_abstol = 1E-14, f_reltol = 1E-14, max_iterations = 100)

# What every integrator here is actually built with: the tolerances above, plus the current
# `SOLVER_VERBOSITY` (see below). A function rather than a second constant, because the verbosity
# is settable and a `const` named tuple would freeze it at load time.
solver_options() = (SOLVER_OPTIONS..., verbosity = SOLVER_VERBOSITY[])


# Upper bound on the number of points drawn per curve. The runs here go up to 10⁵ time steps, and
# rendering a vector line of that many points is what dominates the cost of a page — a run of the
# massless charged particle integrates in a few seconds and then spends far longer being plotted.
# Every GeometricProblems recipe takes an `nplot` keyword that draws every `nplot`-th step, which
# is what the pre-0.2 gallery set by hand per problem (`nplot = 100` for the massless charged
# particle, `10` for Lotka-Volterra); `_nplot` below derives it from the length of the run instead.
# 10000 points is far more than a figure a few hundred pixels wide can resolve.
const MAX_PLOT_POINTS = 10000

_nplot(nt) = max(1, div(nt, MAX_PLOT_POINTS))


_linebreak(io) = show(io, "text/markdown", MD(Paragraph([LineBreak()])))


# Several of the method families in this gallery diverge on some of the problems — the
# non-symplectic Lobatto VPRK methods on the degenerate Lotka-Volterra Lagrangian in
# particular. The Newton solver then fails its line search in every iteration of every time
# step; in the SPARK companion package that once drowned a CI run in 173000 warnings, 99% of a
# 174583-line log. They are turned off at the source through `SOLVER_VERBOSITY`, which
# `SimpleSolvers` shares with its line search. The plotting stack offers no such switch:
# `PlotUtils` emits one unthrottled `No strict ticks found` per degenerate axis, so its warnings
# are dropped on the logging side instead and only their count is reported, by `run_list`.
const QUIET_LOG_MODULES = (:PlotUtils, :Makie)
const QUIET_LOG_COUNT = Ref(0)

# Solver verbosity, folded into the option set by `solver_options` above;
# `quiet_solver_warnings!` drops it to 0 for the weave builds. Interactive sessions keep the
# default, where the warnings are worth having: `SimpleSolvers` rate-limits them to a handful per
# session.
const SOLVER_VERBOSITY = Ref(1)

struct QuietLogger{L<:AbstractLogger} <: AbstractLogger
    parent::L
end

function Logging.shouldlog(logger::QuietLogger, level, _module, group, id)
    if level < Logging.Error && nameof(_module) ∈ QUIET_LOG_MODULES
        QUIET_LOG_COUNT[] += 1
        return false
    end
    Logging.shouldlog(logger.parent, level, _module, group, id)
end

Logging.min_enabled_level(logger::QuietLogger) = Logging.min_enabled_level(logger.parent)
Logging.catch_exceptions(logger::QuietLogger) = Logging.catch_exceptions(logger.parent)
Logging.handle_message(logger::QuietLogger, args...; kwargs...) =
    Logging.handle_message(logger.parent, args...; kwargs...)

# Turn off the solver warnings and install the filter for the plotting ones. Called by the weave
# driver, not on load, so that interactive sessions keep the warnings unless they ask for quiet.
function quiet_solver_warnings!()
    SOLVER_VERBOSITY[] = 0
    global_logger(QuietLogger(global_logger()))
end


# Integrate a problem step-by-step so that a crash (solver failure, singular matrix, NaNs, …)
# does not discard the whole run: we keep the solution up to the last successful time step.
# Returns `(sol, last_good, err)` where `last_good` is the index of the last completed step and
# `err` is `nothing` (success), `:nan` (NaNs in the state), or the caught exception. The steps
# after `last_good` are padded with the last good state so downstream invariant computations
# never see uninitialized data.
#
# This replaces the old gallery's `Simulation`/`run!` pair, which no longer exists, and its
# habit of wrapping every plot call in a `try`/`catch` to survive a crashed run.
function integrate_partial(problem, method; options = solver_options())
    sol = GIB.Solution(problem)
    nt  = GIB.ntime(sol)

    last_good = 0
    err = nothing

    # Building the integrator is inside the `try` as well: some of the methods this gallery lists
    # have no integrator in GeometricIntegrators 0.17 (see `PROJECTIONS` in tableau_lists.jl), and
    # such a method must fail like a diverging run rather than abort the whole page.
    try
        int     = GIB.GeometricIntegrator(problem, method; options...)
        solstep = GIB.solutionstep(int, sol[0])
        state   = GIB.current(solstep)

        for n in 1:nt
            GIB.reset!(solstep, GIB.timesteps(sol)[n])
            GIB.integrate!(solstep, int)
            if isnan(state)
                err = :nan
                break
            end
            copy!(sol, state, n)
            last_good = n
        end
    catch ex
        err = ex
    end

    # Pad every stored data series except the time axis. Which series a solution has depends on
    # the problem (`q`, `q̇` for an ODE; `q`, `p`, … for an IODE; plus `λ` for a DAE), so they
    # are taken from the solution itself rather than hard-coded.
    for k in keys(sol)
        k === :t && continue
        for n in (last_good+1):nt
            sol[k][n] = copy(sol[k][last_good])
        end
    end

    (sol, last_good, err)
end


# Short, human-readable one-line description of a crash (no stack trace).
function _failure_message(err)
    err === :nan                      && return "NaNs detected in the solution"
    err isa NonlinearSolverException  && return "solver error – " * err.msg
    err isa DomainError               && return "domain error"
    err isa SingularException         && return "singular matrix"
    # A diverging run can trip an `@assert` deep inside the solver instead of raising an exception
    # of its own; the assertion text is the only clue as to which invariant broke, so keep it.
    err isa AssertionError            && return "failed assertion – " * err.msg
    return string(nameof(typeof(err)))
end


# Reference a figure, but only if it was actually produced: a run that crashed early has no
# energy drift data, and one that crashed on the very first step has no figures at all.
# Referencing them regardless leaves broken images on the page and one
# `invalid local link/image` warning per figure in the Documenter build. Returns whether the
# reference was written.
function _plot_figure_md(file, name, filename)
    isfile(filename) || return false

    show(file, "text/markdown", Markdown.parse("![$name]($filename)"))
    _linebreak(file)

    true
end


# Write the page of one run as a flat list of figures, in the order given. This is the plain
# counterpart of `write_plots` below, for the pages whose figures do not fall into the fixed
# section skeleton of a trajectory run — the Poincaré invariant pages, whose figures are the
# invariant error and the advected loop or surface.
function _write_page(dir, file, name, fig_suff, suffixes)
    omitted = String[]

    open(file * ".md", "w") do f
        show(f, "text/markdown", Markdown.parse("# $name"))
        _linebreak(f)

        for suffix in suffixes
            _plot_figure_md(f, name, "$(dir)/$(file)$(suffix)$(fig_suff)") || push!(omitted, suffix)
        end
    end

    isempty(omitted) ||
        @warn("Omitted $(length(omitted)) figures from $(file).md that were not produced: " *
              join(omitted, ", "))

    nothing
end


# Write the page collecting all figures of one run. Must be called *after* `run_integrator`, so
# that the figures it references already exist on disk. `invariants` is the list of secondary
# invariants of the problem (see `run_list`), whose sections are appended after the energy;
# `attempted` are the figure suffixes `make_plots` tried to produce, so that only genuine
# failures are reported as omissions — a diagnostic that does not apply to the problem at hand
# (a constraint error for an explicit ODE run, say) is simply absent from both.
function write_plots(dir, file, name, fig_suff, invariants, attempted)

    plot_file = file * ".md"

    path(suffix) = "$(dir)/$(file)$(suffix)$(fig_suff)"

    # A figure that `make_plots` attempted but that is not on disk is a diagnostic that failed;
    # everything else it does not reference simply does not apply to this run.
    omitted = filter(suffix -> !isfile(path(suffix)), attempted)

    open(plot_file, "w") do f
        figures(suffixes...) = foreach(s -> _plot_figure_md(f, name, path(s)), suffixes)

        # A section heading is written only when at least one of its figures exists: a run may
        # legitimately produce none of them — an explicit ODE run has no constraint to violate, and
        # only the projected and DAE runs have Lagrange multipliers — and a heading over nothing
        # reads like a missing figure.
        function section(title, suffixes...)
            any(isfile, path.(suffixes)) || return
            show(f, "text/markdown", Markdown.parse("## $title"))
            _linebreak(f)
            figures(suffixes...)
        end

        show(f, "text/markdown", Markdown.parse("# $name"))
        _linebreak(f)

        figures("_solution", "_traces")

        section("Energy Error", "_energy_error", "_energy_drift")

        for (_, invname, invtitle) in invariants
            section(invtitle, "_$(invname)_error", "_$(invname)_drift")
        end

        section("Constraint", "_constraint_error")
        section("Lagrange Multiplier", "_lambda")
    end

    isempty(omitted) ||
        @warn("Omitted $(length(omitted)) figures from $(plot_file) that were not produced: " *
              join(omitted, ", "))

    nothing
end


# Save the figure produced by `plot` as `<dir>/<file><suffix><fig_suff>`. A failure is reported
# but not propagated: one diagnostic that cannot be plotted (which happens for runs that crash
# after very few time steps) must not cost us the remaining figures.
function _save_plot(plot, dir, file, suffix, fig_suff)
    try
        save(dir * "/" * file * suffix * fig_suff, plot())
    catch ex
        show(stdout, "text/markdown",
             Markdown.parse("**Plotting $(file)$(suffix) failed: $(_failure_message(ex)).**"))
        _linebreak(stdout)
        @warn("Plotting $(file)$(suffix) failed: $(_failure_message(ex))")
    end
end


# Plot the solution up to time step `last_good` (`:auto` plots the whole solution). All time
# trace panels are limited to `last_good` and share the full-timespan x-axis, so a partial run
# shows its trajectory up to the crash within the complete time interval.
# `recipes` is the problem's plot recipe bundle, see `run_list`. Returns the figure suffixes that
# were attempted, which is what `write_plots` needs to tell a failed diagnostic from one that does
# not apply to this problem in the first place.
function make_plots(sol, equ, recipes, dir, file, fig_suff, last_good)
    if !isdir(dir)
        mkpath(dir)
    end

    nt      = ntime(sol)
    ntplot  = last_good ≥ nt ? (:auto) : last_good
    nplot   = _nplot(nt)

    attempted = String[]

    function plot_figure(plot, suffix)
        push!(attempted, suffix)
        _save_plot(plot, dir, file, suffix, fig_suff)
    end

    # All GeometricProblems recipes set their own x-limits to the plotted time range, so no
    # post-processing is needed here.
    plot_figure(() -> recipes.solution(sol, equ; latex=false, nplot, nt=ntplot), "")
    plot_figure(() -> recipes.phase_portrait(sol; latex=false, nplot, nt=ntplot), "_solution")
    plot_figure(() -> recipes.traces(sol, equ; latex=false, nplot, nt=ntplot), "_traces")
    plot_figure(() -> plot_energy_error(sol; latex=false, nplot, nt=ntplot), "_energy_error")

    # Drift is an interval-based diagnostic: `plot_*_drift` splits the solution into ten
    # intervals and its `nt` counts those intervals, not time steps. Show only the intervals
    # completed before a crash – and skip the plot unless at least two of them were completed,
    # as a single point has no drift to show and a degenerate x-range throws. Solutions shorter
    # than ten steps have no intervals at all and make the recipe itself divide by zero, so they
    # are skipped outright (short runs only happen in local tests).
    interval = max(div(nt, 10), 1)
    ntdrift  = last_good ≥ nt ? (:auto) : div(last_good, interval)
    plot_drift = nt ≥ 10 && (ntdrift === :auto || ntdrift ≥ 2)

    plot_drift && plot_figure(() -> plot_energy_drift(sol; latex=false, nt=ntdrift), "_energy_drift")

    # Secondary invariants (the point vortices' angular momentum, …) through the generic
    # diagnostics of GeometricProblems.
    for (invariant, invname, _) in recipes.invariants
        plot_figure(() -> plot_invariant_error(sol; invariant, latex=false, nplot, nt=ntplot),
                    "_$(invname)_error")
        plot_drift && plot_figure(() -> plot_invariant_drift(sol; invariant, latex=false, nt=ntdrift),
                                  "_$(invname)_drift")
    end

    # `p` is absent from the solution of an explicit ODE run, which has no constraint to violate.
    if hasproperty(sol, :p)
        plot_figure(() -> plot_constraint_error(sol; latex=false, nplot, nt=ntplot), "_constraint_error")
    end

    # Lagrange multipliers exist for the DAE and projected runs only.
    if hasproperty(sol, :λ)
        plot_figure(() -> plot_lagrange_multiplier(sol; latex=false, nplot, nt=ntplot), "_lambda")
    end

    return attempted
end


function run_integrator(problem, method, recipes, dir, file, fig_suff)
    sol, last_good, err = integrate_partial(problem, method)

    if err !== nothing
        show(stdout, "text/markdown",
             Markdown.parse("**Simulation crashed after $(last_good) of $(ntime(sol)) time steps: $(_failure_message(err)).**"))
        _linebreak(stdout)
        @warn("Simulation crashed after $(last_good) of $(ntime(sol)) time steps: $(_failure_message(err))")
    end

    # Plot whatever was computed (the trajectory up to the last successful step). A run that
    # crashed on the very first step has nothing to plot, and its failure was just reported, so
    # there is nothing to call an omission either.
    last_good ≥ 1 || return String[]

    make_plots(sol, problem, recipes, dir, file, fig_suff, last_good)
end


# `Name(s)` for a tableau, e.g. `SymplecticGauss(2)`. Some tableau names already carry their stage
# count or another number (`LobattoIIIAIIIB3`, `RK416`), in which case appending it would be
# redundant or plain wrong.
function _tableau_headline(tab)
    name = string(tab.name)
    isdigit(last(name)) && return name
    return "$(name)($(tab.s))"
end

# Name of the projection of a projected run, taken from the trailing `_p…` of its run ID rather
# than from the projection's type: `VPRKpStandard` and `VPRKpSymplectic` both build a
# `StandardProjection`, and the very same one whenever the method's `R∞` is `+1`, so the type
# cannot tell them apart. Falls back to the type name for a projection built by hand.
function _projection_name(proj, file)
    m = match(r"_(p[a-z]+)$", file)
    m === nothing && return string(nameof(typeof(proj)))
    return get(PROJECTION_LABELS, m.captures[1], string(nameof(typeof(proj))))
end

# Headline of a single run. A projected method wraps an inner method, both of which are shown
# (`SymplecticGauss(2) with symmetric projection`). A method of a family carries the number of
# stages in an `s` field and is shown as `Name(s)`, e.g. `Gauss(2)`. The meta-methods that store a
# tableau instead — `VPRK`, which is what `initmethod` turns a family such as `VPRKGauss` into and
# hence what a projected method stores — carry no family name in their type and are named after
# that tableau. Methods without a tableau at all, for which `tableau` returns `missing` rather
# than throwing, are shown by their name alone.
function _headline(method, file = "")
    if method isa ProjectedMethod
        label = _projection_name(projection(method), file)
        return _headline(parent(method)) * (isempty(label) ? "" : " with " * label)
    end
    tab = tableau(method)
    tab === missing && return string(nameof(typeof(method)))
    hasfield(typeof(method), :s) && return "$(nameof(typeof(method)))($(method.s))"
    return _tableau_headline(tab)
end


# `recipes` comes first so that the problem modules in `src/<problem>.jl` can bind it with a
# one-line wrapper `run_list(args...; kwargs...) = GeometricExamples.run_list(PLOT_RECIPES, args...; kwargs...)`.
#
# `recipes` is a named tuple with the problem's GeometricProblems plot recipes
# `(solution, phase_portrait, traces)` and an `invariants` field listing the problem's
# conserved quantities beyond the energy as `(key, file_name, section_title)` triples, e.g.
# `((:p, "angular_momentum", "Angular Momentum"),)`. The remaining diagnostics are
# problem-agnostic.
#
# Each entry of `list` is `(method, file)`, optionally followed by a time step refinement factor
# and a number of time steps:
#
#   (method, file)              run the problem as it is
#   (method, file, factor)      run it with `timestep / factor` over the same time interval
#   (method, file, factor, nt)  … and stop after `nt` (refined) time steps
#
# `similar` retains everything else of the problem, so refining the time step alone scales the
# number of time steps by the same factor.
function run_list(recipes, problem, name, list, plot_dir = PLOT_DIR; fig_suff = ".png")

    for run in list
        method, file = run[1], run[2]

        factor = length(run) ≥ 3 ? run[3] : 1
        nsteps = length(run) ≥ 4 ? run[4] : nothing

        prob = factor == 1 ? problem : similar(problem; timestep = timestep(problem) / factor)

        if nsteps !== nothing
            t₀ = initialtime(prob)
            prob = similar(prob; timespan = (t₀, t₀ + nsteps * timestep(prob)))
        end

        headline = _headline(method, file) *
                   (factor == 1 ? "" : " with Δt/$(factor)") *
                   (nsteps === nothing ? "" : " over $(nsteps) steps")

        show(stdout, "text/markdown", Markdown.parse("## $(headline)"))
        _linebreak(stdout)

        show(stdout, "text/markdown", Markdown.parse("[Plots]($file.md)"))
        _linebreak(stdout)

        attempted = run_integrator(prob, method, recipes, plot_dir, file, fig_suff)

        # The page of figures is written only now, so that it can leave out the ones this run
        # did not produce; same for the overview figure embedded here.
        write_plots(plot_dir, file, name, fig_suff, recipes.invariants, attempted)

        overview = "$plot_dir/$file$fig_suff"
        isfile(overview) && show(stdout, "text/markdown", Markdown.parse("![$name]($overview)"))

        # Each run leaves a set of Makie figures behind; collecting them here keeps the peak
        # footprint of a list of well over a hundred methods within what a CI runner can hold.
        GC.gc()
    end

    if QUIET_LOG_COUNT[] > 0
        @info("Suppressed $(QUIET_LOG_COUNT[]) plotting warnings so far (see QUIET_LOG_MODULES)")
    end

    nothing
end
