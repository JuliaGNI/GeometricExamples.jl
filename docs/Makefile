
# The page matrix of .github/workflows/Documentation.yaml. `PAGES_<problem>` mirrors the `PAGES`
# dictionary of weave.jl: the singular Lotka-Volterra gauge only differs in its variational
# formulation, so it has no explicit pages, and the standard map carries the Poincaré invariants.
TRAJECTORY_PAGES = erk \
                   firk-gauss \
                   firk-lobatto \
                   vprk-gauss \
                   vprk-srk3 \
                   vprk-lobatto \
                   vprk-lobatto-symplectic \
                   vprk-radau

PROBLEMS = lotka-volterra-2d \
           lotka-volterra-2d-singular \
           massless-charged-particle \
           point-vortices \
           standard-map

PAGES_lotka-volterra-2d          = $(TRAJECTORY_PAGES)
PAGES_lotka-volterra-2d-singular = $(filter vprk-%,$(TRAJECTORY_PAGES))
PAGES_massless-charged-particle  = $(TRAJECTORY_PAGES)
PAGES_point-vortices             = $(TRAJECTORY_PAGES) convergence
PAGES_standard-map               = poincare-1st poincare-2nd

# One target per woven page: `make -j8 weave` reproduces the fan-out of the CI matrix and `make -k`
# its `fail-fast: false`, so that a crashing integrator does not cost us the remaining pages.
PAGE_TARGETS = $(foreach problem,$(PROBLEMS),$(addprefix page/$(problem)/,$(PAGES_$(problem))))

.PHONY: all documenter weave clean $(PAGE_TARGETS) $(PROBLEMS)

all: weave documenter

documenter: weave
	julia --color=yes --project=.. make.jl

weave: $(PAGE_TARGETS)

$(PAGE_TARGETS):
	julia --color=yes --project=.. weave.jl $(word 2,$(subst /, ,$@)) $(word 3,$(subst /, ,$@))

# `make -j8 point-vortices` weaves all pages of one problem.
define problem_target
$(1): $(addprefix page/$(1)/,$(PAGES_$(1)))
endef
$(foreach problem,$(PROBLEMS),$(eval $(call problem_target,$(problem))))

clean:
	rm -Rf build
	$(foreach problem,$(PROBLEMS),rm -Rf src/$(problem);)
