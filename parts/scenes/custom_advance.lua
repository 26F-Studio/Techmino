local scene={}

scene.widgetList={
	WIDGET.newText{name="title",		x=520,y=5,font=70,align="R"},
	WIDGET.newText{name="subTitle",		x=530,y=50,font=35,align="L",color="grey"},

	--Visual
	WIDGET.newSwitch{name="block",		x=620,	y=600,				font=25,disp=WIDGET.lnk_CUSval("block"),	code=WIDGET.lnk_CUSrev("block")},
	WIDGET.newSlider{name="ghost",		x=500,	y=450,w=200,unit=.6,font=25,disp=WIDGET.lnk_CUSval("ghost"),	code=WIDGET.lnk_CUSsto("ghost")},
	WIDGET.newSlider{name="center",		x=500,	y=520,w=200,unit=1,	font=25,disp=WIDGET.lnk_CUSval("center"),	code=WIDGET.lnk_CUSsto("center")},

	WIDGET.newSwitch{name="bagLine",	x=1190,	y=340,disp=WIDGET.lnk_CUSval("bagLine"),code=WIDGET.lnk_CUSrev("bagLine")},
	WIDGET.newSwitch{name="highCam",	x=1190,	y=410,disp=WIDGET.lnk_CUSval("highCam"),code=WIDGET.lnk_CUSrev("highCam")},
	WIDGET.newSwitch{name="nextPos",	x=1190,	y=480,disp=WIDGET.lnk_CUSval("nextPos"),code=WIDGET.lnk_CUSrev("nextPos")},
	WIDGET.newSwitch{name="bone",		x=1190,	y=550,disp=WIDGET.lnk_CUSval("bone"),	code=WIDGET.lnk_CUSrev("bone")},

	--Control
	WIDGET.newSlider{name="nextCount",	x=150,y=450,w=200,unit=6,	disp=WIDGET.lnk_CUSval("nextCount"),code=WIDGET.lnk_CUSsto("nextCount")},
	WIDGET.newSlider{name="holdCount",	x=150,y=520,w=200,unit=6,	disp=WIDGET.lnk_CUSval("holdCount"),code=WIDGET.lnk_CUSsto("holdCount")},
	WIDGET.newSwitch{name="infHold",	x=260,y=600,				disp=WIDGET.lnk_CUSval("infHold"),	code=WIDGET.lnk_CUSrev("infHold"),hide=function()return CUSTOMENV.holdCount==0 end},

	WIDGET.newSlider{name="mindas",		x=180,	y=150,w=400,unit=15,font=25,disp=WIDGET.lnk_CUSval("mindas"),	code=WIDGET.lnk_CUSsto("mindas")},
	WIDGET.newSlider{name="minarr",		x=180,	y=220,w=400,unit=10,font=25,disp=WIDGET.lnk_CUSval("minarr"),	code=WIDGET.lnk_CUSsto("minarr")},
	WIDGET.newSlider{name="minsdarr",	x=180,	y=290,w=200,unit=4,	font=20,disp=WIDGET.lnk_CUSval("minsdarr"),	code=WIDGET.lnk_CUSsto("minsdarr")},

	--Rule
	WIDGET.newSwitch{name="ospin",		x=910,	y=340,	font=30,disp=WIDGET.lnk_CUSval("ospin"),	code=WIDGET.lnk_CUSrev("ospin")},
	WIDGET.newSwitch{name="noTele",		x=910,	y=410,	font=25,disp=WIDGET.lnk_CUSval("noTele"),	code=WIDGET.lnk_CUSrev("noTele")},
	WIDGET.newSwitch{name="fineKill",	x=910,	y=480,	font=20,disp=WIDGET.lnk_CUSval("fineKill"),	code=WIDGET.lnk_CUSrev("fineKill")},
	WIDGET.newSwitch{name="b2bKill",	x=910,	y=550,	font=20,disp=WIDGET.lnk_CUSval("b2bKill"),	code=WIDGET.lnk_CUSrev("b2bKill")},
	WIDGET.newSwitch{name="easyFresh",	x=910,	y=620,	font=20,disp=WIDGET.lnk_CUSval("easyFresh"),code=WIDGET.lnk_CUSrev("easyFresh")},

	WIDGET.newSelector{name="RS",		x=410,	y=370,	w=260,color="sea",	list={"TRS","SRS","C2","C2sym","Classic","None"},disp=WIDGET.lnk_CUSval("RS"),code=WIDGET.lnk_CUSsto("RS")},
	WIDGET.newSelector{name="visible",	x=840,	y=60,	w=260,color="lBlue",list={"show","time","fast","none"},		disp=WIDGET.lnk_CUSval("visible"),	code=WIDGET.lnk_CUSsto("visible")},
	WIDGET.newSelector{name="target",	x=840,	y=160,	w=260,color="green",list={10,20,40,100,200,500,1000,1e99},	disp=WIDGET.lnk_CUSval("target"),	code=WIDGET.lnk_CUSsto("target")},
	WIDGET.newSelector{name="freshLimit",x=840,	y=260,	w=260,color="purple",list={0,8,15,1e99},					disp=WIDGET.lnk_CUSval("freshLimit"),code=WIDGET.lnk_CUSsto("freshLimit")},
	WIDGET.newSelector{name="opponent",	x=1120,	y=60,	w=260,color="red",	list={0,1,2,3,4,5,6,7,8,9,10},			disp=WIDGET.lnk_CUSval("opponent"),code=WIDGET.lnk_CUSsto("opponent")},
	WIDGET.newSelector{name="life",		x=1120,	y=160,	w=260,color="red",	list={0,1,2,3,5,10,15,26,42,87,500},	disp=WIDGET.lnk_CUSval("life"),	code=WIDGET.lnk_CUSsto("life")},
	WIDGET.newSelector{name="pushSpeed",x=1120,	y=260,	w=260,color="red",	list={1,2,3,5,15},						disp=WIDGET.lnk_CUSval("pushSpeed"),code=WIDGET.lnk_CUSsto("pushSpeed")},

	WIDGET.newButton{name="back",		x=1140,	y=640,	w=170,h=80,	font=40,code=WIDGET.lnk_BACK},
}

return scene