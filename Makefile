
# Weaving a problem into `docs/src/<problem>/` and building the documentation both live in
# `docs/`; this file only forwards to it, so that `make` works from the repository root too.

.PHONY: all weave documenter clean test

all:
	$(MAKE) -C docs all

weave:
	$(MAKE) -C docs weave

documenter:
	$(MAKE) -C docs documenter

test:
	julia --color=yes --project -e 'using Pkg; Pkg.test()'

clean:
	$(MAKE) -C docs clean
