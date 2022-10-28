return {
    {name='sprint_10l',    x=0,         y=0,        size=40,shape=1,icon="sprint1",     unlock={'sprint_20l','sprint_40l'}},
    {name='sprint_20l',    x=-200,      y=200,      size=50,shape=1,icon="sprint1"},
    {name='sprint_40l',    x=0,         y=-300,     size=40,shape=1,icon="sprint2",     unlock={'dig_10l','sprint_100l','marathon_n','sprintPenta','sprintMPH','sprint123','secret_grade'}},
    {name='sprint_100l',   x=-400,      y=200,      size=50,shape=1,icon="sprint2",     unlock={'sprint_400l','drought_n'}},
    {name='sprint_400l',   x=-600,      y=200,      size=40,shape=1,icon="sprint3",     unlock={'sprint_1000l'}},
    {name='sprint_1000l',  x=-800,      y=200,      size=40,shape=1,icon="sprint3"},

    {name='sprint123',     x=160,       y=-400,     size=40,shape=1,icon="sprint_tri"},
    {name='sprintMPH',     x=200,       y=-260,     size=40,shape=3,icon="sprint2"},
    {name='sprintPenta',   x=130,       y=-140,     size=40,shape=3,icon="sprint_pento"},

    {name='secret_grade',  x=-200,      y=-400,     size=40,shape=1,icon="secret_grade"},

    {name='drought_n',     x=-600,      y=400,      size=40,shape=1,icon="drought",     unlock={'drought_l'}},
    {name='drought_l',     x=-800,      y=400,      size=40,shape=1,icon="drought"},

    {name='dig_10l',       x=-200,      y=-200,     size=40,shape=1,icon="dig_sprint",  unlock={'dig_40l','dig_eff_10l'}},
    {name='dig_40l',       x=-400,      y=-200,     size=40,shape=1,icon="dig_sprint",  unlock={'dig_100l'}},
    {name='dig_100l',      x=-600,      y=-200,     size=40,shape=1,icon="dig_sprint",  unlock={'dig_400l'}},
    {name='dig_400l',      x=-800,      y=-200,     size=40,shape=1,icon="dig_sprint"},

    {name='dig_eff_10l',   x=-400,      y=0,        size=40,shape=1,icon="dig_sprint",  unlock={'dig_eff_40l'}},
    {name='dig_eff_40l',   x=-600,      y=0,        size=40,shape=1,icon="dig_sprint",  unlock={'dig_eff_100l'}},
    {name='dig_eff_100l',  x=-800,      y=0,        size=40,shape=1,icon="dig_sprint",  unlock={'dig_eff_400l'}},
    {name='dig_eff_400l',  x=-1000,     y=0,        size=40,shape=1,icon="dig_sprint"},

    {name='marathon_n',    x=0,         y=-600,     size=60,shape=1,icon="marathon",    unlock={'marathon_h','solo_e','round_e','big_n','blind_e','classic_e','survivor_e','c4wtrain_n','pctrain_n','sprintAtk','zen'}},
    {name='marathon_h',    x=0,         y=-800,     size=50,shape=1,icon="marathon",    unlock={'master_n','strategy_e'}},

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

    {name='big_n',         x=-400,      y=-400,     size=40,shape=1,icon="big",         unlock={'big_h'}},
    {name='big_h',         x=-600,      y=-400,     size=40,shape=1,icon="big",},

    {name='master_n',      x=0,         y=-1000,    size=40,shape=1,icon="master",      unlock={'master_h','strategy_h'}},
    {name='master_h',      x=0,         y=-1200,    size=40,shape=3,icon="master",      unlock={'master_final','master_ex','master_ph','master_m','master_g','strategy_u'}},
    {name='master_m',      x=100,       y=-1550,    size=40,shape=2,icon="master"},
    {name='master_final',  x=-100,      y=-1550,    size=40,shape=2,icon="master"},
    {name='master_ph',     x=-170,      y=-1450,    size=40,shape=2,icon="master"},
    {name='master_g',      x=0,         y=-1600,    size=40,shape=3,icon="master"},
    {name='master_ex',     x=170,       y=-1450,    size=40,shape=2,icon="master_ex"},

    {name='strategy_e',     x=-150,     y=-1020,    size=40,shape=3,icon="master",      unlock={'strategy_e_plus'}},
    {name='strategy_h',     x=-150,     y=-1150,    size=35,shape=3,icon="master",      unlock={'strategy_h_plus'}},
    {name='strategy_u',     x=-150,     y=-1280,    size=30,shape=2,icon="master",      unlock={'strategy_u_plus'}},
    {name='strategy_e_plus',x=-300,     y=-1120,    size=40,shape=3,icon="master"},
    {name='strategy_h_plus',x=-300,     y=-1250,    size=35,shape=3,icon="master"},
    {name='strategy_u_plus',x=-300,     y=-1380,    size=30,shape=2,icon="master"},

    {name='blind_e',       x=150,       y=-700,     size=40,shape=1,icon="hidden",      unlock={'blind_n','master_instinct'}},
    {name='blind_n',       x=150,       y=-800,     size=40,shape=1,icon="hidden",      unlock={'blind_h'}},
    {name='blind_h',       x=150,       y=-900,     size=35,shape=1,icon="hidden",      unlock={'blind_l'}},
    {name='blind_l',       x=150,       y=-1000,    size=35,shape=3,icon="hidden2",     unlock={'blind_u'}},
    {name='blind_u',       x=150,       y=-1100,    size=30,shape=3,icon="hidden2",     unlock={'blind_wtf'}},
    {name='blind_wtf',     x=150,       y=-1200,    size=25,shape=2,icon="hidden2"},
    {name='master_instinct',x=285,      y=-835,     size=40,shape=3,icon="hidden"},

    {name='classic_e',     x=-200,      y=-850,     size=40,shape=1,icon="classic",     unlock={'classic_h'}},
    {name='classic_h',     x=-300,      y=-950,     size=40,shape=3,icon="classic",     unlock={'classic_l'}},
    {name='classic_l',     x=-400,      y=-1050,    size=35,shape=3,icon="classic",     unlock={'classic_u'}},
    {name='classic_u',     x=-500,      y=-1150,    size=30,shape=2,icon="classic"},

    {name='survivor_e',    x=450,       y=-600,     size=40,shape=1,icon="survivor",    unlock={'survivor_n'}},
    {name='survivor_n',    x=650,       y=-600,     size=40,shape=1,icon="survivor",    unlock={'survivor_h','attacker_h','defender_n','dig_h'}},
    {name='survivor_h',    x=850,       y=-600,     size=40,shape=1,icon="survivor",    unlock={'survivor_l'}},
    {name='survivor_l',    x=1050,      y=-600,     size=40,shape=3,icon="survivor",    unlock={'survivor_u'}},
    {name='survivor_u',    x=1250,      y=-600,     size=40,shape=2,icon="survivor"},

    {name='attacker_h',    x=450,       y=-800,     size=40,shape=1,icon="attack",      unlock={'attacker_u'}},
    {name='attacker_u',    x=450,       y=-1000,    size=40,shape=1,icon="attack"},

    {name='defender_n',    x=650,       y=-800,     size=40,shape=1,icon="defend",      unlock={'defender_l'}},
    {name='defender_l',    x=650,       y=-1000,    size=40,shape=1,icon="defend"},

    {name='dig_h',         x=850,       y=-800,     size=40,shape=1,icon="dig",         unlock={'dig_u'}},
    {name='dig_u',         x=850,       y=-1000,    size=40,shape=1,icon="dig"},

    {name='c4wtrain_n',    x=700,       y=-450,     size=40,shape=1,icon="pc",          unlock={'c4wtrain_l'}},
    {name='c4wtrain_l',    x=900,       y=-450,     size=40,shape=1,icon="pc"},

    {name='pctrain_n',     x=700,       y=-300,     size=40,shape=1,icon="pc",          unlock={'pctrain_l','pc_n'}},
    {name='pctrain_l',     x=900,       y=-300,     size=40,shape=1,icon="pc"},

    {name='pc_n',          x=800,       y=-140,     size=40,shape=1,icon="pc",          unlock={'pc_h'}},
    {name='pc_h',          x=950,       y=-140,     size=40,shape=3,icon="pc",          unlock={'pc_l','pc_inf'}},
    {name='pc_l',          x=1100,      y=-140,     size=40,shape=3,icon="pc"},
    {name='pc_inf',        x=1100,      y=-280,     size=40,shape=2,icon="pc"},

    {name='sprintAtk',     x=500,       y=-280,     size=40,shape=1,icon="sprint2",     unlock={'sprintEff','tech_n','tech_finesse','tsd_e','backfire_n'}},

    {name='sprintEff',     x=360,       y=-150,     size=40,shape=1,icon="sprint2"},

    {name='tech_n',        x=400,       y=20,       size=40,shape=1,icon="tech",        unlock={'tech_n_plus','tech_h'}},
    {name='tech_n_plus',   x=200,       y=-10,      size=40,shape=3,icon="tech"},
    {name='tech_h',        x=400,       y=170,      size=40,shape=1,icon="tech",        unlock={'tech_h_plus','tech_l'}},
    {name='tech_h_plus',   x=200,       y=140,      size=35,shape=3,icon="tech"},
    {name='tech_l',        x=400,       y=320,      size=40,shape=1,icon="tech",        unlock={'tech_l_plus'}},
    {name='tech_l_plus',   x=200,       y=290,      size=35,shape=3,icon="tech"},

    {name='tech_finesse',  x=800,       y=20,       size=40,shape=1,icon="tech",        unlock={'tech_finesse_f'}},
    {name='tech_finesse_f',x=1000,      y=20,       size=40,shape=1,icon="tech"},

    {name='tsd_e',         x=720,       y=170,      size=40,shape=1,icon="tsd",         unlock={'tsd_h'}},
    {name='tsd_h',         x=960,       y=170,      size=40,shape=1,icon="tsd",         unlock={'tsd_u'}},
    {name='tsd_u',         x=1200,      y=170,      size=40,shape=1,icon="tsd"},

    {name='backfire_n',    x=650,       y=320,      size=40,shape=1,icon="backfire",    unlock={'backfire_h'}},
    {name='backfire_h',    x=850,       y=320,      size=40,shape=1,icon="backfire",    unlock={'backfire_l'}},
    {name='backfire_l',    x=1050,      y=320,      size=40,shape=3,icon="backfire",    unlock={'backfire_u'}},
    {name='backfire_u',    x=1250,      y=320,      size=35,shape=2,icon="backfire"},

    {name='zen',           x=-1000,     y=-600,     size=40,shape=1,icon="zen",         unlock={'ultra','infinite','infinite_dig','marathon_inf'}},
    {name='ultra',         x=-1200,     y=-600,     size=40,shape=1,icon="ultra"},
    {name='infinite',      x=-1200,     y=-400,     size=40,shape=1,icon='infinite'},
    {name='infinite_dig',  x=-1000,     y=-400,     size=40,shape=1,icon="dig"},
    {name='marathon_inf',  x=-800,      y=-400,     size=40,shape=1,icon="marathon"}
}
