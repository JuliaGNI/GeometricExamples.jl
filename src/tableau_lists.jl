
# Lists of integration methods, one per family, as `(method, file_stem)` tuples.
#
# These replace the `get_tableau_list_*` functions of the pre-0.2 gallery, which listed
# `(Integrator, tableau, run_id)` triples built from the removed `getTableau*` constructors.
# Methods are structs now, so the integrator and the tableau have merged into one object:
#
#   IntegratorERK,           getTableauERK4()          →  RK416()
#   IntegratorERK,           getTableauERK438()        →  RK438()
#   IntegratorFIRK,          getTableauGLRK(s)         →  Gauss(s)
#   IntegratorFIRK,          getTableauLobIIIX(s)      →  LobattoIIIX(s)
#   IntegratorVPRKpNone,     getTableauVPGLRK(s)       →  VPRKGauss(s)
#   IntegratorVPRKpNone,     getTableauVPSRK3()        →  VPSRK3()
#   IntegratorVPRKpNone,     getTableauVPLobIIIX(s)    →  VPRKLobattoIIIX(s)
#   IntegratorVPRK,          getTableauVPRadIIAIIA(s)  →  VPRKRadauIIA(s)
#   IntegratorVPRKpStandard, …                         →  VPRKpStandard(method)
#   IntegratorSplitting,     getTableauStrang()        →  Strang()
#
# The old lists also spelled out the projection × tableau matrix by hand, 168 entries for the
# `vprk_projection` family alone, in which the `vprk_lobIIIF*` and `vprk_lobIIIG*` run IDs were
# attached to `getTableauVPLobIIIE*` tableaus — so six of the published figures were duplicates
# of the IIIE ones. The matrix is built by `_projected` below instead.

# The Lobatto families and the number of stages the gallery has always run them with. `s = 2, 3,
# 4`: `LobattoIII*(1)` does not exist (a one-stage Lobatto rule needs both end points).
const LOBATTO_FAMILIES = (:IIIA, :IIIB, :IIIC, :IIID, :IIIE, :IIIF, :IIIG)
const LOBATTO_STAGES = (2, 3, 4)

# Number of stages of the Gauss-Legendre methods, as in the published gallery.
const GAUSS_STAGES = (1, 2, 3, 4, 5, 6)

# The projections the gallery compares, as `(run ID suffix, headline label, constructor)`.
# `pnone` is the unprojected method itself.
#
# `VPRKpInternal` is listed because the gallery has always compared it, but the
# `InternalStageProjection` it builds has no integrator in GeometricIntegrators 0.18 — only the
# standard, symmetric and midpoint projections do (`src/projections/`). Its runs therefore fail
# immediately and are reported as such on the woven pages, rather than being silently dropped;
# see the "Known gaps" section of the documentation.
const PROJECTIONS = (
    ("pnone", "", identity),
    ("pstandard", "standard projection", VPRKpStandard),
    ("psymmetric", "symmetric projection", VPRKpSymmetric),
    ("psymplectic", "symplectic projection", VPRKpSymplectic),
    ("pmidpoint", "midpoint projection", VPRKpMidpoint),
    ("pinternal", "internal stage projection", VPRKpInternal)
)

# `_headline` in common.jl labels a projected run from its run ID rather than from the projection's
# type, because `VPRKpStandard` and `VPRKpSymplectic` both build a `StandardProjection` — and in
# fact build the *same* one whenever the method's `R∞` is `+1`, so the type cannot tell them apart
# even in principle. The run ID records which of them was asked for.
const PROJECTION_LABELS = Dict(suffix => label for (suffix, label, _) in PROJECTIONS)

# Cross a list of `(method, file_stem)` entries with every projection.
function _projected(list)
    Tuple(
        (project(method), "$(stem)_$(suffix)")
    for (method, stem) in list
    for (suffix, _, project) in PROJECTIONS
    )
end

"""
Explicit Runge-Kutta methods, for the explicit (`odeproblem`) formulation.
"""
tableaus_erk() = (
    (RK416(), "erk4_16"),
    (RK438(), "erk4_38")
)

"""
Gauss-Legendre Runge-Kutta methods, for the explicit (`odeproblem`) formulation.
"""
tableaus_firk_gauss() = Tuple(
    (Gauss(s), "firk_gauss$(s)") for s in GAUSS_STAGES
)

"""
The Lobatto IIIA–IIIG Runge-Kutta families, for the explicit (`odeproblem`) formulation.
"""
function tableaus_firk_lobatto()
    Tuple(
        (getfield(GeometricIntegrators, Symbol(:Lobatto, family))(s),
            "firk_lobatto_$(family)$(s)")
    for family in LOBATTO_FAMILIES for s in LOBATTO_STAGES
    )
end

"""
Gauss-Legendre variational partitioned Runge-Kutta methods with every projection.
"""
function tableaus_vprk_gauss()
    _projected(Tuple(
        (VPRKGauss(s), "vprk_gauss$(s)") for s in GAUSS_STAGES
    ))
end

"""
The three-stage symmetric Runge-Kutta method `VPSRK3` with every projection.
"""
tableaus_vprk_srk3() = _projected((
    (VPSRK3(), "vprk_srk3"),
))

"""
The Lobatto IIIA–IIIG variational partitioned Runge-Kutta families with every projection.

Of these, only `VPRKLobattoIIID`, `VPRKLobattoIIIE` and `VPRKLobattoIIIG` are symplectic. That
alone does not decide whether a run completes — of the non-symplectic families, IIIC and IIIF do
integrate the Lotka-Volterra problems, whereas `VPRKLobattoIIIA` and `VPRKLobattoIIIB` give a
singular system matrix on the very first step, projected or not, in both Lotka-Volterra gauges.
Those runs are reported as failures on the woven pages. See
[`tableaus_vprk_lobatto_symplectic`](@ref) for the symplectic IIIA-IIIB and IIIB-IIIA pairs, which
carry the null vector these degenerate systems need.
"""
function tableaus_vprk_lobatto()
    _projected(Tuple(
        (getfield(GeometricIntegrators, Symbol(:VPRKLobatto, family))(s),
            "vprk_lobatto_$(family)$(s)")
    for family in LOBATTO_FAMILIES for s in LOBATTO_STAGES
    ))
end

"""
The symplectic Lobatto IIIA-IIIB and IIIB-IIIA variational partitioned Runge-Kutta pairs with
every projection. Unlike the single-family methods of [`tableaus_vprk_lobatto`](@ref), these
satisfy the symplecticity conditions and carry the null vector the degenerate systems need.
"""
function tableaus_vprk_lobatto_symplectic()
    _projected(Tuple(
        (method(s), "vprk_lobatto_$(name)$(s)")
    for (name, method) in ((:IIIA_IIIB, VPRKLobattoIIIAIIIB), (
        :IIIB_IIIA, VPRKLobattoIIIBIIIA))
    for s in LOBATTO_STAGES
    ))
end

"""
Radau IIA variational partitioned Runge-Kutta methods. Unprojected, as in the published
gallery: the Radau methods are not symmetric, so most of the projections do not apply.
"""
tableaus_vprk_radau() = Tuple(
    (VPRKRadauIIA(s), "vprk_radau_IIA$(s)") for s in (2, 3)
)

"""
Splitting methods.

Currently unused: a splitting method needs an `sodeproblem`, and none of the problems this
gallery covers provides one. Its only consumer was the pre-0.2 3d charged particle, which is the
one family that was never migrated — see *Known Gaps* in the documentation.
"""
function tableaus_splitting()
    (
        (LieA(), "LieA"),
        (LieB(), "LieB"),
        (Strang(), "Strang"),
        (McLachlan2(), "McLachlan2"),
        (McLachlan4(), "McLachlan4"),
        (TripleJump(), "TripleJump"),
        (SuzukiFractal(), "SuzukiFractal")
    )
end
