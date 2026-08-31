module GeometricExamples

include("common.jl")
include("convergence.jl")
include("tableau_lists.jl")

# Makie themes set in a module body are applied during precompilation only, so the shared
# plotting style has to be activated when the module is loaded.
__init__() = set_theme!(PLOT_THEME)

export tableaus_erk,
       tableaus_firk_gauss,
       tableaus_firk_lobatto,
       tableaus_vprk_gauss,
       tableaus_vprk_srk3,
       tableaus_vprk_lobatto,
       tableaus_vprk_lobatto_symplectic,
       tableaus_vprk_radau,
       tableaus_splitting

export integrate_partial, quiet_solver_warnings!

# `run_list` is deliberately *not* exported: every problem module in `src/<problem>.jl`
# defines its own three-argument `run_list` that binds the problem's plot recipes, and
# scripts commonly `using` both this package and a problem module.

end
