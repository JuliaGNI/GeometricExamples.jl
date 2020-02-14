
const out_dir   = "../../docs/src/integrators/runge_kutta/lotka_volterra_2d/"
const run_id    = "lotka_volterra_2d_firk"

# create list of figures to put in list
figures_custom = ()

include("lotka_volterra_2d_settings.jl")

# solver settings
# set_config(:nls_atol, 8eps())
# set_config(:nls_rtol, 2eps())
# set_config(:nls_stol, 2eps())
set_config(:nls_nmax, 20)
