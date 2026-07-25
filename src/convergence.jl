
using GeometricProblems.Diagnostics: plot_convergence, plot_order


# Number of time step halvings a convergence study measures, and the number of *further* halvings
# used for its reference solution. Taking the finest measured run as the reference would make the
# reference error comparable to the smallest error measured against it, which flattens the
# apparent order of the high-order methods; two extra halvings put the reference error 2^(2p)
# below the finest measured one.
const NREFINE = 8
const NREFERENCE = 2


# Reference slope for a convergence plot, or `nothing` when the method reports no usable order —
# `order(::ProjectedMethod)` is `missing`, for instance. Where an order *is* reported it is only a
# nominal one: for a partitioned method it is the minimum over both halves of the tableau
# (`order(VPRKGauss(s)) == s`, not `2s`), and the order a method actually attains on a
# noncanonical or degenerate problem may differ from either. The reference line is therefore a
# guide only; the measured order is what the companion `_order` figure reports.
_reference_order(method) = (o = order(method); o isa Integer && o > 0 ? o : nothing)


# Relative error of the final state of `sol` against that of the reference solution `ref`, in the
# maximum norm over the state components.
function _final_state_error(sol, ref)
    q, qref = sol.q[end], ref.q[end]
    scale = max(maximum(abs, qref), one(eltype(qref)))
    maximum(abs, q .- qref) / scale
end


# Span of the relative error of one invariant over the whole run — the diagnostic the pre-0.2
# gallery used (`abs(maximum(H_err) - minimum(H_err))`). `invariant` is a key into
# `invariants(problem)` or the invariant function itself, as for
# `GeometricProblems.Diagnostics.plot_invariant_error`, whose extension computes the same series
# but is only reachable through the plotting functions.
function _invariant_error_span(sol, invariant)
    equ = sol.problem
    f = invariant isa Symbol ? invariants(equ)[invariant] : invariant
    _, Δ = sol isa Union{SolutionPODE, SolutionPDAE} ?
           compute_invariant_error(sol.t, sol.q, sol.p, parameters(equ), f) :
           compute_invariant_error(sol.t, sol.q, parameters(equ), f)
    maximum(Δ) - minimum(Δ)
end


"""
Convergence study of one method over a sequence of halved time steps.

Integrates `problem` with `method` for time steps `Δt / 2^(i-1)`, `i = 1, …, nrefine`, all over the
same time interval, and reports

* the error of the final state against a reference run of the same method with `nreference`
  further halvings,
* the observed order of convergence from successive halvings, and
* the span of the relative error of the energy and of every invariant in `invariants`
  (a list of `(key, file_name, title)` triples, as in `run_list`),

as log-log figures produced by `GeometricProblems.Diagnostics.plot_convergence` and
`plot_order`, plus one markdown page per method.

The pre-0.2 gallery instead compared successive refinements at a single point in time — the first
step of the coarsest grid — and took the reference order from a hand-maintained column of the
tableau list. Both are replaced here.

Returns nothing; writes `<prefix><file>_solution`, `…_order`, `…_energy` and one
`…_<invariant>` figure per invariant. The `prefix` matters: a convergence page and a trajectory
page of the same problem share a directory and are given the same method list, so without it the
two would write over each other's pages and figures.
"""
function run_convergence(problem, name, list, invariants = (), plot_dir = PLOT_DIR;
                         nrefine = NREFINE, nreference = NREFERENCE, prefix = "convergence_",
                         fig_suff = ".png")

    isdir(plot_dir) || mkpath(plot_dir)

    for run in list
        method, file = run[1], prefix * run[2]

        show(stdout, "text/markdown", Markdown.parse("## $(_headline(method, file))"))
        _linebreak(stdout)
        show(stdout, "text/markdown", Markdown.parse("[Plots]($file.md)"))
        _linebreak(stdout)

        # The last `nreference` entries are the reference runs, which are not plotted.
        h    = [timestep(problem) / 2^(i-1) for i in 1:(nrefine + nreference)]
        sols = Vector{Any}(undef, length(h))
        good = Int[]

        # A method that fails does so at most of the time steps, and one paragraph per refinement
        # would bury the page, so the failures are collected and reported as one line per reason.
        failures = Dict{String, Vector{Float64}}()

        for i in eachindex(h)
            prob = similar(problem; timestep = h[i])
            sol, last_good, err = integrate_partial(prob, method)

            if err === nothing
                push!(good, i)
            else
                push!(get!(failures, _failure_message(err), Float64[]), h[i])
            end

            sols[i] = sol
        end

        for (reason, steps) in sort!(collect(failures); by = first)
            message = "**Crashed at $(length(steps)) of $(length(h)) time steps " *
                      "(Δt = $(join(steps, ", "))): $(reason).**"
            show(stdout, "text/markdown", Markdown.parse(message))
            _linebreak(stdout)
            @warn(replace(message, "**" => ""))
        end

        # The finest completed run is the reference; the coarse runs are measured against it. When
        # the reference runs themselves crashed this falls back to the finest run that did
        # complete, which costs accuracy at the fine end but still gives a usable study.
        ref_i = isempty(good) ? 0 : last(good)
        ref   = ref_i == 0 ? nothing : sols[ref_i]

        # Plotted are the `nrefine` coarse time steps that completed, never a reference run.
        idx = filter(i -> i ≤ nrefine && i != ref_i, good)

        if isempty(idx)
            @warn("Convergence study of $(file) has no usable runs – skipped")
            _write_convergence_page(plot_dir, file, name, fig_suff, invariants, String[])
            continue
        end

        if ref_i ≤ nrefine
            @warn("Convergence study of $(file) lost its reference runs; " *
                  "using Δt = $(h[ref_i]) as the reference instead")
        end

        ε = [_final_state_error(sols[i], ref) for i in idx]

        # The observed order between two consecutive *plotted* runs. Normalising by the number of
        # halvings between them, `log2(hⱼ / hⱼ₊₁)`, keeps this right when a run in between crashed
        # and the two are more than one halving apart.
        p = [log2(ε[j] / ε[j+1]) / log2(h[idx[j]] / h[idx[j+1]]) for j in 1:(length(ε)-1)]

        refslope = _reference_order(method)

        attempted = String[]
        figure(plot, suffix) = (push!(attempted, suffix); _save_plot(plot, plot_dir, file, suffix, fig_suff))

        figure(() -> plot_convergence(h[idx], ε; order = refslope, latex = false),
               "_solution")
        length(p) ≥ 1 && figure(() -> plot_order(h[idx[1:end-1]], p; latex = false), "_order")

        figure(() -> plot_convergence(h[idx], [_invariant_error_span(sols[i], :h) for i in idx];
                                      order = refslope, latex = false),
               "_energy")

        for (invariant, invname, _) in invariants
            figure(() -> plot_convergence(h[idx], [_invariant_error_span(sols[i], invariant) for i in idx];
                                          order = refslope, latex = false),
                   "_$(invname)")
        end

        _write_convergence_page(plot_dir, file, name, fig_suff, invariants, attempted)

        overview = "$plot_dir/$(file)_solution$fig_suff"
        isfile(overview) && show(stdout, "text/markdown", Markdown.parse("![$name]($overview)"))

        GC.gc()
    end

    nothing
end


function _write_convergence_page(dir, file, name, fig_suff, invariants, attempted)
    path(suffix) = "$(dir)/$(file)$(suffix)$(fig_suff)"

    omitted = filter(suffix -> !isfile(path(suffix)), attempted)

    open(file * ".md", "w") do f
        # As in `write_plots`, a section heading is written only when at least one of its figures
        # exists, so that a study that could not be carried out leaves an empty page rather than a
        # skeleton of headings.
        function section(title, suffixes...)
            any(isfile, path.(suffixes)) || return
            show(f, "text/markdown", Markdown.parse("## $title"))
            _linebreak(f)
            foreach(s -> _plot_figure_md(f, name, path(s)), suffixes)
        end

        show(f, "text/markdown", Markdown.parse("# $name"))
        _linebreak(f)

        section("Solution Error", "_solution", "_order")
        section("Energy Error", "_energy")

        for (_, invname, invtitle) in invariants
            section(invtitle, "_$(invname)")
        end
    end

    isempty(omitted) ||
        @warn("Omitted $(length(omitted)) figures from $(file).md that were not produced: " *
              join(omitted, ", "))

    nothing
end
