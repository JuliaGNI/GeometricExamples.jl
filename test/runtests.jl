using SafeTestsets

const GROUPS = isempty(ARGS) ? ["core", "slow"] : ARGS

if "core" in GROUPS
    @safetestset "Aqua" include("quality/aqua.jl")
    @safetestset "Standard Map" include("standard-map.jl")
    @safetestset "Guiding Center 4d Poincaré Invariants" include("guiding-center-4d-poincare.jl")
end
if "slow" in GROUPS
    @safetestset "Method lists" include("tableau_lists.jl")
    @safetestset "Guiding Center 4d" include("guiding-center-4d.jl")
end
