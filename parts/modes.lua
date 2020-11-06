return{
	{name="sprint_10",				x=0,		y=0,		size=35,shape=1,icon="sprint",		unlock={"sprint_20","sprint_40"}},
	{name="sprint_20",				x=-200,		y=0,		size=45,shape=1,icon="sprint"},
	{name="sprint_40",				x=0,		y=-300,		size=35,shape=1,icon="sprint",		unlock={"dig_10","sprint_100","marathon_normal","sprintFix","sprintLock","sprintPenta","sprintMPH"}},
	{name="sprint_100",				x=-200,		y=-200,		size=45,shape=1,icon="sprint",		unlock={"sprint_400","drought_normal"}},
	{name="sprint_400",				x=-400,		y=-200,		size=35,shape=1,icon="sprint",		unlock={"sprint_1000"}},
	{name="sprint_1000",			x=-600,		y=-200,		size=35,shape=1,icon="sprint"},

	{name="sprintFix",				x=180,		y=-410,		size=40,shape=3,icon="sprint_new"},
	{name="sprintLock",				x=240,		y=-300,		size=40,shape=3,icon="sprint_new"},
	{name="sprintPenta",			x=240,		y=-180,		size=40,shape=3,icon="sprint_new"},
	{name="sprintMPH",				x=180,		y=-70,		size=40,shape=3,icon="sprint_new"},

	{name="drought_normal",			x=-400,		y=0,		size=35,shape=1,icon="noI",			unlock={"drought_lunatic"}},
	{name="drought_lunatic",		x=-600,		y=0,		size=35,shape=1,icon="mess"},

	{name="dig_10",					x=-200,		y=-400,		size=35,shape=1,icon="dig",			unlock={"dig_40"}},
	{name="dig_40",					x=-400,		y=-400,		size=35,shape=1,icon="dig",			unlock={"dig_100"}},
	{name="dig_100",				x=-600,		y=-400,		size=35,shape=1,icon="dig",			unlock={"dig_400"}},
	{name="dig_400",				x=-800,		y=-200,		size=35,shape=1,icon="dig"},

	{name="marathon_normal",		x=0,		y=-600,		size=55,shape=1,icon="marathon",	unlock={"marathon_hard","marathon_ultimate","solo_1","round_1","blind_easy","classic_fast","survivor_easy","bigbang","zen"}},
	{name="marathon_hard",			x=0,		y=-800,		size=45,shape=1,icon="marathon",	unlock={"master_beginner"}},
	{name="marathon_ultimate",		x=-120,		y=-490,		size=35,shape=2,icon="marathon"},

	{name="solo_1",					x=-300,		y=-1000,	size=35,shape=1,icon="solo",		unlock={"solo_2"}},
	{name="solo_2",					x=-500,		y=-1000,	size=35,shape=1,icon="solo",		unlock={"solo_3"}},
	{name="solo_3",					x=-700,		y=-1000,	size=35,shape=1,icon="solo",		unlock={"solo_4","techmino49_easy"}},
	{name="solo_4",					x=-900,		y=-1000,	size=35,shape=1,icon="solo",		unlock={"solo_5"}},
	{name="solo_5",					x=-1100,	y=-1000,	size=35,shape=1,icon="solo"},

	{name="techmino49_easy",		x=-900,		y=-1200,	size=35,shape=1,icon="royale",		unlock={"techmino49_hard","techmino99_easy"}},
	{name="techmino49_hard",		x=-900,		y=-1400,	size=35,shape=1,icon="royale",		unlock={"techmino49_ultimate"}},
	{name="techmino49_ultimate",	x=-900,		y=-1600,	size=35,shape=1,icon="royale"},
	{name="techmino99_easy",		x=-1100,	y=-1400,	size=35,shape=1,icon="royale",		unlock={"techmino99_hard"}},
	{name="techmino99_hard",		x=-1100,	y=-1600,	size=35,shape=1,icon="royale",		unlock={"techmino99_ultimate"}},
	{name="techmino99_ultimate",	x=-1100,	y=-1800,	size=35,shape=1,icon="royale"},

	{name="round_1",				x=-300,		y=-800,		size=35,shape=1,icon="round",		unlock={"round_2"}},
	{name="round_2",				x=-500,		y=-800,		size=35,shape=1,icon="round",		unlock={"round_3"}},
	{name="round_3",				x=-700,		y=-800,		size=35,shape=1,icon="round",		unlock={"round_4"}},
	{name="round_4",				x=-900,		y=-800,		size=35,shape=1,icon="round",		unlock={"round_5"}},
	{name="round_5",				x=-1100,	y=-800,		size=35,shape=1,icon="round"},

	{name="master_beginner",		x=0,		y=-1000,	size=35,shape=1,icon="master",		unlock={"master_advance"}},
	{name="master_advance",			x=0,		y=-1200,	size=35,shape=3,icon="master",		unlock={"master_final","GM"}},
	{name="master_final",			x=0,		y=-1400,	size=40,shape=2,icon="master",		unlock={"master_phantasm"}},
	{name="master_phantasm",		x=0,		y=-1800,	size=40,shape=2,icon="master"},
	{name="GM",						x=150,		y=-1500,	size=35,shape=2,icon="master"},

	{name="blind_easy",				x=150,		y=-700,		size=35,shape=1,icon="blind",		unlock={"blind_normal"}},
	{name="blind_normal",			x=150,		y=-800,		size=35,shape=1,icon="blind",		unlock={"blind_hard"}},
	{name="blind_hard",				x=150,		y=-900,		size=35,shape=1,icon="blind",		unlock={"blind_lunatic"}},
	{name="blind_lunatic",			x=150,		y=-1000,	size=35,shape=3,icon="blind",		unlock={"blind_ultimate"}},
	{name="blind_ultimate",			x=150,		y=-1100,	size=35,shape=3,icon="blind",		unlock={"blind_wtf"}},
	{name="blind_wtf",				x=150,		y=-1200,	size=35,shape=2,icon="blind"},

	{name="classic_fast",			x=-300,		y=-1200,	size=40,shape=2,icon="classic"},

	{name="survivor_easy",			x=300,		y=-600,		size=35,shape=1,icon="survivor",	unlock={"survivor_normal"}},
	{name="survivor_normal",		x=500,		y=-600,		size=35,shape=1,icon="survivor",	unlock={"survivor_hard","attacker_hard","defender_normal","dig_hard"}},
	{name="survivor_hard",			x=700,		y=-600,		size=35,shape=1,icon="survivor",	unlock={"survivor_lunatic"}},
	{name="survivor_lunatic",		x=900,		y=-600,		size=35,shape=3,icon="survivor",	unlock={"survivor_ultimate"}},
	{name="survivor_ultimate",		x=1100,		y=-600,		size=35,shape=2,icon="survivor"},

	{name="attacker_hard",			x=300,		y=-800,		size=35,shape=1,icon="attacker",	unlock={"attacker_ultimate"}},
	{name="attacker_ultimate",		x=300,		y=-1000,	size=35,shape=1,icon="attacker"},

	{name="defender_normal",		x=500,		y=-800,		size=35,shape=1,icon="defender",	unlock={"defender_lunatic"}},
	{name="defender_lunatic",		x=500,		y=-1000,	size=35,shape=1,icon="defender"},

	{name="dig_hard",				x=700,		y=-800,		size=35,shape=1,icon="dig",			unlock={"dig_ultimate"}},
	{name="dig_ultimate",			x=700,		y=-1000,	size=35,shape=1,icon="dig"},

	{name="bigbang",				x=400,		y=-400,		size=55,shape=1,icon="bigbang",		unlock={"c4wtrain_normal","pctrain_normal","tech_normal"}},
	{name="c4wtrain_normal",		x=700,		y=-400,		size=35,shape=1,icon="c4wtrain",	unlock={"c4wtrain_lunatic"}},
	{name="c4wtrain_lunatic",		x=900,		y=-400,		size=35,shape=1,icon="c4wtrain"},

	{name="pctrain_normal",			x=700,		y=-220,		size=35,shape=1,icon="pctrain",		unlock={"pctrain_lunatic","pcchallenge_normal"}},
	{name="pctrain_lunatic",		x=900,		y=-220,		size=35,shape=1,icon="pctrain"},

	{name="pcchallenge_normal",		x=800,		y=-100,		size=35,shape=1,icon="pcchallenge",	unlock={"pcchallenge_hard"}},
	{name="pcchallenge_hard",		x=1000,		y=-100,		size=35,shape=3,icon="pcchallenge",	unlock={"pcchallenge_lunatic"}},
	{name="pcchallenge_lunatic",	x=1200,		y=-100,		size=35,shape=2,icon="pcchallenge"},

	{name="tech_normal",			x=400,		y=-150,		size=35,shape=1,icon="tech",		unlock={"tech_normal2","tech_hard","tech_finesse"}},
	{name="tech_normal2",			x=650,		y=150,		size=35,shape=3,icon="tech",		unlock={"tsd_easy"}},
	{name="tech_hard",				x=400,		y=40,		size=35,shape=1,icon="tech",		unlock={"tech_hard2","tech_lunatic"}},
	{name="tech_hard2",				x=200,		y=70,		size=35,shape=3,icon="tech"},
	{name="tech_lunatic",			x=400,		y=200,		size=35,shape=1,icon="tech",		unlock={"tech_lunatic2"}},
	{name="tech_lunatic2",			x=200,		y=230,		size=35,shape=3,icon="tech"},

	{name="tech_finesse",			x=800,		y=50,		size=35,shape=1,icon="tech",		unlock={"tech_finesse2"}},
	{name="tech_finesse2",			x=1000,		y=50,		size=35,shape=1,icon="tech"},

	{name="tsd_easy",				x=800,		y=250,		size=35,shape=1,icon="tsd",			unlock={"tsd_hard"}},
	{name="tsd_hard",				x=1000,		y=250,		size=35,shape=1,icon="tsd",			unlock={"tsd_ultimate"}},
	{name="tsd_ultimate",			x=1200,		y=250,		size=35,shape=1,icon="tsd"},

	{name="zen",					x=-800,		y=-600,		size=35,shape=1,icon="zen",			unlock={"ultra","infinite","infinite_dig"}},
	{name="ultra",					x=-1000,	y=-400,		size=35,shape=1,icon="ultra"},
	{name="infinite",				x=-800,		y=-400,		size=35,shape=1,icon="infinite"},
	{name="infinite_dig",			x=-1000,	y=-600,		size=35,shape=1,icon="infinite"},

	{name="custom_puzzle",			x=0,		y=2600,		size=45,shape=1,icon="none"},
	{name="custom_clear",			x=0,		y=2600,		size=45,shape=1,icon="none"},
}