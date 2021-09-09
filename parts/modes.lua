return{
    {name='sprint_10l',    x=0,         y=0,        size=40,shape=1,icon="sprint1",     unlock={'sprint_20l','sprint_40l'}},
    {name='sprint_20l',    x=-200,      y=200,      size=50,shape=1,icon="sprint1"},
    {name='sprint_40l',    x=0,         y=-300,     size=40,shape=1,icon="sprint2",     unlock={'dig_10l','sprint_100l','marathon_n','sprintPenta','sprintMPH','stack_e'}},
    {name='sprint_100l',   x=-200,      y=0,        size=50,shape=1,icon="sprint2",     unlock={'sprint_400l','drought_n'}},
    {name='sprint_400l',   x=-400,      y=0,        size=40,shape=1,icon="sprint3",     unlock={'sprint_1000l'}},
    {name='sprint_1000l',  x=-600,      y=0,        size=40,shape=1,icon="sprint3"},

    {name='sprintPenta',   x=210,       y=-370,     size=40,shape=3,icon="tech"},
    {name='sprintMPH',     x=210,       y=-230,     size=40,shape=3,icon="tech"},

    {name='drought_n',     x=-400,      y=200,      size=40,shape=1,icon="drought",     unlock={'drought_l'}},
    {name='drought_l',     x=-600,      y=200,      size=40,shape=1,icon="drought"},

    {name='stack_e',       x=-200,      y=-400,     size=40,shape=1,icon="mess",        unlock={'stack_h'}},
    {name='stack_h',       x=-400,      y=-400,     size=40,shape=1,icon="mess",        unlock={'stack_u'}},
    {name='stack_u',       x=-600,      y=-400,     size=40,shape=1,icon="mess"},

    {name='dig_10l',       x=-200,      y=-200,     size=40,shape=1,icon="dig_sprint",  unlock={'dig_40l'}},
    {name='dig_40l',       x=-400,      y=-200,     size=40,shape=1,icon="dig_sprint",  unlock={'dig_100l'}},
    {name='dig_100l',      x=-600,      y=-200,     size=40,shape=1,icon="dig_sprint",  unlock={'dig_400l'}},
    {name='dig_400l',      x=-800,      y=-200,     size=40,shape=1,icon="dig_sprint"},

    {name='marathon_n',    x=0,         y=-600,     size=60,shape=1,icon="marathon",    unlock={'marathon_h','rhythm_e','solo_e','round_e','blind_e','classic_h','survivor_e','bigbang','zen'}},
    {name='marathon_h',    x=0,         y=-800,     size=50,shape=1,icon="marathon",    unlock={'master_n'}},

    {name='solo_e',        x=-600,      y=-1000,    size=40,shape=1,icon="solo",        unlock={'solo_n'}},
    {name='solo_n',        x=-800,      y=-1000,    size=40,shape=1,icon="solo",        unlock={'solo_h'}},
    {name='solo_h',        x=-1000,     y=-1000,    size=40,shape=1,icon="solo",        unlock={'solo_l','techmino49_e'}},
    {name='solo_l',        x=-1200,     y=-1000,    size=40,shape=1,icon="solo",        unlock={'solo_u'}},
    {name='solo_u',        x=-1400,     y=-1000,    size=40,shape=1,icon="solo"},

    {name='techmino49_e',  x=-1100,     y=-1200,    size=40,shape=1,icon="t49",         unlock={'techmino49_h','techmino99_e'}},
    {name='techmino49_h',  x=-1100,     y=-1400,    size=40,shape=1,icon="t49",         unlock={'techmino49_u'}},
    {name='techmino49_u',  x=-1100,     y=-1600,    size=40,shape=1,icon="t49"},
    {name='techmino99_e',  x=-1300,     y=-1400,    size=40,shape=1,icon="t99",         unlock={'techmino99_h'}},
    {name='techmino99_h',  x=-1300,     y=-1600,    size=40,shape=1,icon="t99",         unlock={'techmino99_u'}},
    {name='techmino99_u',  x=-1300,     y=-1800,    size=40,shape=1,icon="t99"},

    {name='round_e',       x=-600,      y=-800,     size=40,shape=1,icon="round",       unlock={'round_n'}},
    {name='round_n',       x=-800,      y=-800,     size=40,shape=1,icon="round",       unlock={'round_h'}},
    {name='round_h',       x=-1000,     y=-800,     size=40,shape=1,icon="round",       unlock={'round_l'}},
    {name='round_l',       x=-1200,     y=-800,     size=40,shape=1,icon="round",       unlock={'round_u'}},
    {name='round_u',       x=-1400,     y=-800,     size=40,shape=1,icon="round"},

    {name='master_n',      x=0,         y=-1000,    size=40,shape=1,icon="master",      unlock={'master_h'}},
    {name='master_h',      x=0,         y=-1200,    size=40,shape=3,icon="master",      unlock={'master_final','master_ex','master_ph','master_m'}},
    {name='master_m',      x=150,      y=-1320,    size=30,shape=3,icon="master"},
    {name='master_final',  x=0,         y=-1600,    size=40,shape=2,icon="master"},
    {name='master_ph',     x=-150,      y=-1500,    size=40,shape=2,icon="master"},
    {name='master_ex',     x=150,       y=-1500,    size=40,shape=2,icon="master_ex"},

    {name='rhythm_e',      x=-350,      y=-1000,    size=40,shape=1,icon="rhythm",      unlock={'rhythm_h'}},
    {name='rhythm_h',      x=-350,      y=-1200,    size=40,shape=3,icon="rhythm",      unlock={'rhythm_u'}},
    {name='rhythm_u',      x=-350,      y=-1400,    size=40,shape=2,icon="rhythm"},

    {name='blind_e',       x=150,       y=-700,     size=40,shape=1,icon="hidden",      unlock={'blind_n'}},
    {name='blind_n',       x=150,       y=-800,     size=40,shape=1,icon="hidden",      unlock={'blind_h'}},
    {name='blind_h',       x=150,       y=-900,     size=35,shape=1,icon="hidden",      unlock={'blind_l'}},
    {name='blind_l',       x=150,       y=-1000,    size=35,shape=3,icon="hidden",      unlock={'blind_u'}},
    {name='blind_u',       x=150,       y=-1100,    size=30,shape=3,icon="hidden",      unlock={'blind_wtf'}},
    {name='blind_wtf',     x=150,       y=-1200,    size=25,shape=2,icon="hidden"},

    {name='classic_h',     x=-150,      y=-950,     size=40,shape=2,icon="classic",     unlock={'classic_l'}},
    {name='classic_l',     x=-150,      y=-1100,    size=40,shape=2,icon="classic",     unlock={'classic_u'}},
    {name='classic_u',     x=-150,      y=-1250,    size=40,shape=2,icon="classic"},

    {name='survivor_e',    x=300,       y=-600,     size=40,shape=1,icon="survivor",    unlock={'survivor_n'}},
    {name='survivor_n',    x=500,       y=-600,     size=40,shape=1,icon="survivor",    unlock={'survivor_h','attacker_h','defender_n','dig_h'}},
    {name='survivor_h',    x=700,       y=-600,     size=40,shape=1,icon="survivor",    unlock={'survivor_l'}},
    {name='survivor_l',    x=900,       y=-600,     size=40,shape=3,icon="survivor",    unlock={'survivor_u'}},
    {name='survivor_u',    x=1100,      y=-600,     size=40,shape=2,icon="survivor"},

    {name='attacker_h',    x=300,       y=-800,     size=40,shape=1,icon="attack",      unlock={'attacker_u'}},
    {name='attacker_u',    x=300,       y=-1000,    size=40,shape=1,icon="attack"},

    {name='defender_n',    x=500,       y=-800,     size=40,shape=1,icon="defend",      unlock={'defender_l'}},
    {name='defender_l',    x=500,       y=-1000,    size=40,shape=1,icon="defend"},

    {name='dig_h',         x=700,       y=-800,     size=40,shape=1,icon="dig",         unlock={'dig_u'}},
    {name='dig_u',         x=700,       y=-1000,    size=40,shape=1,icon="dig"},

    {name='bigbang',       x=400,       y=-400,     size=50,shape=1,icon="bigbang",     unlock={'c4wtrain_n','pctrain_n','tech_n'}},
    {name='c4wtrain_n',    x=700,       y=-400,     size=40,shape=1,icon="pc",          unlock={'c4wtrain_l'}},
    {name='c4wtrain_l',    x=900,       y=-400,     size=40,shape=1,icon="pc"},

    {name='pctrain_n',     x=700,       y=-250,     size=40,shape=1,icon="pc",          unlock={'pctrain_l','pc_n'}},
    {name='pctrain_l',     x=900,       y=-250,     size=40,shape=1,icon="pc"},

    {name='pc_n',          x=800,       y=-110,     size=40,shape=1,icon="pc",          unlock={'pc_h'}},
    {name='pc_h',          x=950,       y=-110,     size=40,shape=3,icon="pc",          unlock={'pc_l','pc_inf'}},
    {name='pc_l',          x=1100,      y=-110,     size=40,shape=3,icon="pc"},
    {name='pc_inf',        x=1100,      y=-250,     size=40,shape=2,icon="pc"},

    {name='tech_n',        x=400,       y=-110,     size=40,shape=1,icon="tech",        unlock={'tech_n_plus','tech_h','tech_finesse','sprintAtk'}},
    {name='tech_n_plus',   x=600,       y=160,      size=40,shape=3,icon="tech",        unlock={'tsd_e','backfire_n'}},
    {name='tech_h',        x=220,       y=120,      size=40,shape=1,icon="tech",        unlock={'tech_h_plus','tech_l'}},
    {name='tech_h_plus',   x=20,        y=150,      size=35,shape=3,icon="tech"},
    {name='tech_l',        x=220,       y=280,      size=40,shape=1,icon="tech",        unlock={'tech_l_plus'}},
    {name='tech_l_plus',   x=20,        y=310,      size=35,shape=3,icon="tech"},

    {name='tech_finesse',  x=800,       y=50,       size=40,shape=1,icon="tech",        unlock={'tech_finesse_f'}},
    {name='tech_finesse_f',x=1000,      y=50,       size=40,shape=1,icon="tech"},

    {name='tsd_e',         x=800,       y=200,      size=40,shape=1,icon="tsd",         unlock={'tsd_h'}},
    {name='tsd_h',         x=1000,      y=200,      size=40,shape=1,icon="tsd",         unlock={'tsd_u'}},
    {name='tsd_u',         x=1200,      y=200,      size=40,shape=1,icon="tsd"},

    {name='backfire_n',    x=800,       y=350,      size=40,shape=1,icon="backfire",    unlock={'backfire_h'}},
    {name='backfire_h',    x=950,       y=350,      size=40,shape=1,icon="backfire",    unlock={'backfire_l'}},
    {name='backfire_l',    x=1100,      y=350,      size=40,shape=3,icon="backfire",    unlock={'backfire_u'}},
    {name='backfire_u',    x=1250,      y=350,      size=35,shape=2,icon="backfire"},

    {name='sprintAtk',     x=400,       y=200,      size=40,shape=1,icon="sprint2"},

    {name='zen',           x=-800,      y=-600,     size=40,shape=1,icon="zen",         unlock={'ultra','infinite','infinite_dig'}},
    {name='ultra',         x=-1000,     y=-600,     size=40,shape=1,icon="ultra"},
    {name='infinite',      x=-1000,     y=-400,     size=40,shape=1,icon='infinite'},
    {name='infinite_dig',  x=-800,      y=-400,     size=40,shape=1,icon="dig"},

    --Secret
    {name='sprintFix'},
    {name='sprintLock'},
    {name='sprintSmooth'},
    {name='marathon_bfmax'},

    --Old
    {name='master_l'},
    {name='master_u'},
    {name='classic_fast'},

    --Special
    {name='custom_puzzle'},
    {name='custom_clear'},
    {name="netBattle"},
}
