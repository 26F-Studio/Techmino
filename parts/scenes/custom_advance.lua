WIDGET.init("custom_advance",{
	WIDGET.newText({name="title",		x=520,y=5,font=70,align="R"}),
	WIDGET.newText({name="subTitle",	x=530,y=50,font=35,align="L",color="grey"}),

	--Visual
	WIDGET.newSwitch({name="block",		x=620,	y=430,				font=25,	disp=WIDGET.lnk.CUSval("block"),	code=WIDGET.lnk.CUSrev("block")}),
	WIDGET.newSlider({name="ghost",		x=490,	y=500,w=200,unit=.6,font=25,	disp=WIDGET.lnk.CUSval("ghost"),	code=WIDGET.lnk.CUSsto("ghost")}),
	WIDGET.newSlider({name="center",	x=490,	y=560,w=200,unit=1,	font=25,	disp=WIDGET.lnk.CUSval("center"),	code=WIDGET.lnk.CUSsto("center")}),

	WIDGET.newSwitch({name="bagLine",	x=1190,	y=340,				disp=WIDGET.lnk.CUSval("bagLine"),	code=WIDGET.lnk.CUSrev("bagLine")}),
	WIDGET.newSwitch({name="highCam",	x=1190,	y=410,				disp=WIDGET.lnk.CUSval("highCam"),	code=WIDGET.lnk.CUSrev("highCam")}),
	WIDGET.newSwitch({name="nextPos",	x=1190,	y=480,				disp=WIDGET.lnk.CUSval("nextPos"),	code=WIDGET.lnk.CUSrev("nextPos")}),
	WIDGET.newSwitch({name="bone",		x=1190,	y=550,				disp=WIDGET.lnk.CUSval("bone"),	code=WIDGET.lnk.CUSrev("bone")}),

	--Control
	WIDGET.newSlider({name="next",		x=130,	y=410,w=200,unit=6,	disp=WIDGET.lnk.CUSval("next"),	code=WIDGET.lnk.CUSsto("next")}),
	WIDGET.newSwitch({name="hold",		x=260,	y=480,				disp=WIDGET.lnk.CUSval("hold"),	code=WIDGET.lnk.CUSrev("hold")}),
	WIDGET.newSwitch({name="oncehold",	x=260,	y=560,				disp=WIDGET.lnk.CUSval("oncehold"),code=WIDGET.lnk.CUSrev("oncehold"),hide=function()return not CUSTOMENV.hold end}),

	WIDGET.newSlider({name="mindas",	x=180,	y=150,w=400,unit=15,font=25,	disp=WIDGET.lnk.CUSval("mindas"),	code=WIDGET.lnk.CUSsto("mindas")}),
	WIDGET.newSlider({name="minarr",	x=180,	y=220,w=400,unit=10,font=25,	disp=WIDGET.lnk.CUSval("minarr"),	code=WIDGET.lnk.CUSsto("minarr")}),
	WIDGET.newSlider({name="minsdarr",	x=180,	y=290,w=200,unit=4,	font=20,	disp=WIDGET.lnk.CUSval("minsdarr"),code=WIDGET.lnk.CUSsto("minsdarr")}),

	--Rule
	WIDGET.newSwitch({name="ospin",		x=910,	y=340,				font=30,	disp=WIDGET.lnk.CUSval("ospin"),	code=WIDGET.lnk.CUSrev("ospin")}),
	WIDGET.newSwitch({name="noTele",	x=910,	y=420,				font=25,	disp=WIDGET.lnk.CUSval("noTele"),	code=WIDGET.lnk.CUSrev("noTele")}),
	WIDGET.newSwitch({name="fineKill",	x=910,	y=490,				font=20,	disp=WIDGET.lnk.CUSval("fineKill"),code=WIDGET.lnk.CUSrev("fineKill")}),
	WIDGET.newSwitch({name="easyFresh",	x=910,	y=560,				font=20,	disp=WIDGET.lnk.CUSval("easyFresh"),code=WIDGET.lnk.CUSrev("easyFresh")}),
	WIDGET.newSelector({name="visible",	x=840,	y=60,w=260,color="lBlue",		list={"show","time","fast","none"},		disp=WIDGET.lnk.CUSval("visible"),	code=WIDGET.lnk.CUSsto("visible")}),
	WIDGET.newSelector({name="target",		x=840,	y=160,w=260,color="green",	list={10,20,40,100,200,500,1000,1e99},	disp=WIDGET.lnk.CUSval("target"),	code=WIDGET.lnk.CUSsto("target")}),
	WIDGET.newSelector({name="freshLimit",	x=840,	y=260,w=260,color="purple",	list={0,8,15,1e99},						disp=WIDGET.lnk.CUSval("freshLimit"),code=WIDGET.lnk.CUSsto("freshLimit")}),
	WIDGET.newSelector({name="opponent",	x=1120,	y=60,w=260,color="red",		list={0,1,2,3,4,5,6,7,8,9,10},			disp=WIDGET.lnk.CUSval("opponent"),code=WIDGET.lnk.CUSsto("opponent")}),
	WIDGET.newSelector({name="life",		x=1120,	y=160,w=260,color="red",	list={0,1,2,3,5,10,15,26,42,87,500},	disp=WIDGET.lnk.CUSval("life"),	code=WIDGET.lnk.CUSsto("life")}),
	WIDGET.newSelector({name="pushSpeed",	x=1120,	y=260,w=260,color="red",	list={1,2,3,5,15},						disp=WIDGET.lnk.CUSval("pushSpeed"),code=WIDGET.lnk.CUSsto("pushSpeed")}),

	WIDGET.newButton({name="back",			x=1140,	y=640,	w=170,h=80,	font=40,code=WIDGET.lnk.BACK}),
})