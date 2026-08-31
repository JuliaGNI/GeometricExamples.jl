module PointVorticesExamples

# Time step and number of time steps of the published gallery
# (`examples/point_vortices/point_vortices.jl` before v0.2).
const Δt = 0.05
const nt = 10000

using GeometricIntegrators

using GeometricProblems.PointVortices

import GeometricExamples
using GeometricExamples

# Besides the energy, the point vortices conserve the angular momentum, which the problems
# carry as their `:p` invariant. The old gallery plotted it with hand-written PyPlot code; it
# now goes through `GeometricProblems.Diagnostics.plot_invariant_error`.
const PLOT_RECIPES = (solution = plot_solution,
    phase_portrait = plot_phase_portrait,
    traces = plot_traces,
    invariants = ((:p, "angular_momentum", "Angular Momentum"),))

run_list(args...; kwargs...) = GeometricExamples.run_list(PLOT_RECIPES, args...; kwargs...)

# The convergence study of the pre-0.2 gallery
# (`examples/point_vortices/point_vortices_convergence.jl`), which used exactly these values.
# The interval is far shorter than that of the trajectory pages, and the coarsest time step
# larger: the error has to be dominated by the discretisation over the ten halvings, not by
# trajectories that have had 500 time units to diverge.
const Δt_convergence = 0.1
const nt_convergence = 10

function run_convergence(problem, name, list; kwargs...)
    GeometricExamples.run_convergence(
        problem, name, list, PLOT_RECIPES.invariants; kwargs...)
end

export run_list, run_convergence

end
