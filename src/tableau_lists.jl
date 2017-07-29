
# list of integrators (integrator, tableau, sim_id)


function get_tableau_list_firk(T=Float64)
    tableau_list = (
        (IntegratorFIRK,              getTableauGLRK(1),      "glrk1"      ),
        (IntegratorFIRK,              getTableauGLRK(2),      "glrk2"      ),
        (IntegratorFIRK,              getTableauGLRK(3),      "glrk3"      ),
        (IntegratorFIRK,              getTableauGLRK(4),      "glrk4"      ),
        (IntegratorFIRK,              getTableauGLRK(5),      "glrk5"      ),
        (IntegratorFIRK,              getTableauGLRK(6),      "glrk6"      ),
        (IntegratorFIRK,              getTableauLobIIIA2(),   "lobIIIA2"   ),
        (IntegratorFIRK,              getTableauLobIIIA3(),   "lobIIIA3"   ),
        (IntegratorFIRK,              getTableauLobIIIA4(),   "lobIIIA4"   ),
        (IntegratorFIRK,              getTableauLobIIIB2(),   "lobIIIB2"   ),
        (IntegratorFIRK,              getTableauLobIIIB3(),   "lobIIIB3"   ),
        (IntegratorFIRK,              getTableauLobIIIB4(),   "lobIIIB4"   ),
        (IntegratorFIRK,              getTableauLobIIIC2(),   "lobIIIC2"   ),
        (IntegratorFIRK,              getTableauLobIIIC3(),   "lobIIIC3"   ),
        (IntegratorFIRK,              getTableauLobIIIC4(),   "lobIIIC4"   ),
        (IntegratorFIRK,              getTableauLobIIID2(),   "lobIIID2"   ),
        (IntegratorFIRK,              getTableauLobIIID3(),   "lobIIID3"   ),
        (IntegratorFIRK,              getTableauLobIIID4(),   "lobIIID4"   ),
        (IntegratorFIRK,              getTableauLobIIIE2(),   "lobIIIE2"   ),
        (IntegratorFIRK,              getTableauLobIIIE3(),   "lobIIIE3"   ),
        (IntegratorFIRK,              getTableauLobIIIE4(),   "lobIIIE4"   ),
        (IntegratorFIRK,              getTableauLobIIIF2(),   "lobIIIF2"   ),
        (IntegratorFIRK,              getTableauLobIIIF3(),   "lobIIIF3"   ),
        (IntegratorFIRK,              getTableauLobIIIF4(),   "lobIIIF4"   ),
        (IntegratorFIRK,              getTableauLobIIIG2(),   "lobIIIG2"   ),
        (IntegratorFIRK,              getTableauLobIIIG3(),   "lobIIIG3"   ),
        (IntegratorFIRK,              getTableauLobIIIG4(),   "lobIIIG4"   ),
    )
end


function get_tableau_list_vprk(T=Float64)
    tableau_list = (
        (IntegratorVPRKpNone,         getTableauVPGLRK(1, T=T), "vprk_glrk1"   ),
        (IntegratorVPRKpNone,         getTableauVPGLRK(2, T=T), "vprk_glrk2"   ),
        (IntegratorVPRKpNone,         getTableauVPGLRK(3, T=T), "vprk_glrk3"   ),
        (IntegratorVPRKpNone,         getTableauVPGLRK(4, T=T), "vprk_glrk4"   ),
        (IntegratorVPRKpNone,         getTableauVPGLRK(5, T=T), "vprk_glrk5"   ),
        (IntegratorVPRKpNone,         getTableauVPGLRK(6, T=T), "vprk_glrk6"   ),
        (IntegratorVPRKpNone,         getTableauVPSRK3(),       "vprk_srk3"    ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIA2(),   "vprk_lobIIIA2"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIA3(),   "vprk_lobIIIA3"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIA4(),   "vprk_lobIIIA4"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIB2(),   "vprk_lobIIIB2"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIB3(),   "vprk_lobIIIB3"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIB4(),   "vprk_lobIIIB4"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIC2(),   "vprk_lobIIIC2"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIC3(),   "vprk_lobIIIC3"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIC4(),   "vprk_lobIIIC4"),
        (IntegratorVPRKpNone,         getTableauVPLobIIID2(),   "vprk_lobIIID2"),
        (IntegratorVPRKpNone,         getTableauVPLobIIID3(),   "vprk_lobIIID3"),
        (IntegratorVPRKpNone,         getTableauVPLobIIID4(),   "vprk_lobIIID4"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIE2(),   "vprk_lobIIIE2"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIE3(),   "vprk_lobIIIE3"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIE4(),   "vprk_lobIIIE4"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIE2(),   "vprk_lobIIIF2"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIE3(),   "vprk_lobIIIF3"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIE4(),   "vprk_lobIIIF4"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIE2(),   "vprk_lobIIIG2"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIE3(),   "vprk_lobIIIG3"),
        (IntegratorVPRKpNone,         getTableauVPLobIIIE4(),   "vprk_lobIIIG4"),
    )
end


function get_tableau_list_vprk_projection(T=Float64)
    tableau_list = (
        (IntegratorVPRKpNone,         getTableauVPGLRK(1, T=T), "vprk_glrk1_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPGLRK(1, T=T), "vprk_glrk1_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPGLRK(1, T=T), "vprk_glrk1_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPGLRK(1, T=T), "vprk_glrk1_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPGLRK(1, T=T), "vprk_glrk1_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPGLRK(2, T=T), "vprk_glrk2_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPGLRK(2, T=T), "vprk_glrk2_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPGLRK(2, T=T), "vprk_glrk2_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPGLRK(2, T=T), "vprk_glrk2_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPGLRK(2, T=T), "vprk_glrk2_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPGLRK(3, T=T), "vprk_glrk3_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPGLRK(3, T=T), "vprk_glrk3_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPGLRK(3, T=T), "vprk_glrk3_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPGLRK(3, T=T), "vprk_glrk3_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPGLRK(3, T=T), "vprk_glrk3_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPGLRK(4, T=T), "vprk_glrk4_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPGLRK(4, T=T), "vprk_glrk4_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPGLRK(4, T=T), "vprk_glrk4_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPGLRK(4, T=T), "vprk_glrk4_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPGLRK(4, T=T), "vprk_glrk4_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPGLRK(5, T=T), "vprk_glrk5_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPGLRK(5, T=T), "vprk_glrk5_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPGLRK(5, T=T), "vprk_glrk5_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPGLRK(5, T=T), "vprk_glrk5_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPGLRK(5, T=T), "vprk_glrk5_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPGLRK(6, T=T), "vprk_glrk6_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPGLRK(6, T=T), "vprk_glrk6_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPGLRK(6, T=T), "vprk_glrk6_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPGLRK(6, T=T), "vprk_glrk6_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPGLRK(6, T=T), "vprk_glrk6_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPSRK3(),       "vprk_srk3_pnone"       ),
        (IntegratorVPRKpStandard,     getTableauVPSRK3(),       "vprk_srk3_pstandard"   ),
        (IntegratorVPRKpSymmetric,    getTableauVPSRK3(),       "vprk_srk3_psymmetric"  ),
        (IntegratorVPRKpSymplectic,   getTableauVPSRK3(),       "vprk_srk3_psymplectic" ),
        (IntegratorVPRKpMidpoint,     getTableauVPSRK3(),       "vprk_srk3_pmidpoint"   ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIA2(),   "vprk_lobIIIA2_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIA2(),   "vprk_lobIIIA2_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIA2(),   "vprk_lobIIIA2_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIA2(),   "vprk_lobIIIA2_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIA2(),   "vprk_lobIIIA2_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIA3(),   "vprk_lobIIIA3_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIA3(),   "vprk_lobIIIA3_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIA3(),   "vprk_lobIIIA3_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIA3(),   "vprk_lobIIIA3_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIA3(),   "vprk_lobIIIA3_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIA4(),   "vprk_lobIIIA4_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIA4(),   "vprk_lobIIIA4_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIA4(),   "vprk_lobIIIA4_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIA4(),   "vprk_lobIIIA4_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIA4(),   "vprk_lobIIIA4_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIB2(),   "vprk_lobIIIB2_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIB2(),   "vprk_lobIIIB2_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIB2(),   "vprk_lobIIIB2_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIB2(),   "vprk_lobIIIB2_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIB2(),   "vprk_lobIIIB2_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIB3(),   "vprk_lobIIIB3_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIB3(),   "vprk_lobIIIB3_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIB3(),   "vprk_lobIIIB3_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIB3(),   "vprk_lobIIIB3_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIB3(),   "vprk_lobIIIB3_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIB4(),   "vprk_lobIIIB4_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIB4(),   "vprk_lobIIIB4_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIB4(),   "vprk_lobIIIB4_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIB4(),   "vprk_lobIIIB4_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIB4(),   "vprk_lobIIIB4_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIC2(),   "vprk_lobIIIC2_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIC2(),   "vprk_lobIIIC2_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIC2(),   "vprk_lobIIIC2_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIC2(),   "vprk_lobIIIC2_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIC2(),   "vprk_lobIIIC2_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIC3(),   "vprk_lobIIIC3_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIC3(),   "vprk_lobIIIC3_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIC3(),   "vprk_lobIIIC3_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIC3(),   "vprk_lobIIIC3_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIC3(),   "vprk_lobIIIC3_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIC4(),   "vprk_lobIIIC4_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIC4(),   "vprk_lobIIIC4_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIC4(),   "vprk_lobIIIC4_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIC4(),   "vprk_lobIIIC4_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIC4(),   "vprk_lobIIIC4_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIID2(),   "vprk_lobIIID2_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIID2(),   "vprk_lobIIID2_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIID2(),   "vprk_lobIIID2_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIID2(),   "vprk_lobIIID2_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIID2(),   "vprk_lobIIID2_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIID3(),   "vprk_lobIIID3_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIID3(),   "vprk_lobIIID3_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIID3(),   "vprk_lobIIID3_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIID3(),   "vprk_lobIIID3_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIID3(),   "vprk_lobIIID3_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIID4(),   "vprk_lobIIID4_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIID4(),   "vprk_lobIIID4_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIID4(),   "vprk_lobIIID4_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIID4(),   "vprk_lobIIID4_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIID4(),   "vprk_lobIIID4_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIE2(),   "vprk_lobIIIE2_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIE2(),   "vprk_lobIIIE2_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIE2(),   "vprk_lobIIIE2_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIE2(),   "vprk_lobIIIE2_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIE2(),   "vprk_lobIIIE2_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIE3(),   "vprk_lobIIIE3_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIE3(),   "vprk_lobIIIE3_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIE3(),   "vprk_lobIIIE3_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIE3(),   "vprk_lobIIIE3_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIE3(),   "vprk_lobIIIE3_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIE4(),   "vprk_lobIIIE4_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIE4(),   "vprk_lobIIIE4_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIE4(),   "vprk_lobIIIE4_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIE4(),   "vprk_lobIIIE4_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIE4(),   "vprk_lobIIIE4_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIF2(),   "vprk_lobIIIF2_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIF2(),   "vprk_lobIIIF2_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIF2(),   "vprk_lobIIIF2_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIF2(),   "vprk_lobIIIF2_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIF2(),   "vprk_lobIIIF2_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIF3(),   "vprk_lobIIIF3_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIF3(),   "vprk_lobIIIF3_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIF3(),   "vprk_lobIIIF3_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIF3(),   "vprk_lobIIIF3_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIF3(),   "vprk_lobIIIF3_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIF4(),   "vprk_lobIIIF4_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIF4(),   "vprk_lobIIIF4_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIF4(),   "vprk_lobIIIF4_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIF4(),   "vprk_lobIIIF4_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIF4(),   "vprk_lobIIIF4_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIG2(),   "vprk_lobIIIG2_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIG2(),   "vprk_lobIIIG2_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIG2(),   "vprk_lobIIIG2_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIG2(),   "vprk_lobIIIG2_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIG2(),   "vprk_lobIIIG2_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIG3(),   "vprk_lobIIIG3_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIG3(),   "vprk_lobIIIG3_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIG3(),   "vprk_lobIIIG3_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIG3(),   "vprk_lobIIIG3_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIG3(),   "vprk_lobIIIG3_pmidpoint"  ),
        (IntegratorVPRKpNone,         getTableauVPLobIIIG4(),   "vprk_lobIIIG4_pnone"      ),
        (IntegratorVPRKpStandard,     getTableauVPLobIIIG4(),   "vprk_lobIIIG4_pstandard"  ),
        (IntegratorVPRKpSymmetric,    getTableauVPLobIIIG4(),   "vprk_lobIIIG4_psymmetric" ),
        (IntegratorVPRKpSymplectic,   getTableauVPLobIIIG4(),   "vprk_lobIIIG4_psymplectic"),
        (IntegratorVPRKpMidpoint,     getTableauVPLobIIIG4(),   "vprk_lobIIIG4_pmidpoint"  ),
    )
end