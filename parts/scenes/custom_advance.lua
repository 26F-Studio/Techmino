local scene={}

scene.widgetList={
	WIDGET.newText{name="title",		x=520,y=5,font=70,align="R"},
	WIDGET.newText{name="subTitle",		x=530,y=50,font=35,align="L",color="grey"},

	--Control
	WIDGET.newSlider{name="mindas",		x=180,	y=150,w=400,unit=15,font=25,disp=lnk_CUSval("mindas"),	code=lnk_CUSsto("mindas")},
	WIDGET.newSlider{name="minarr",		x=180,	y=220,w=400,unit=10,font=25,disp=lnk_CUSval("minarr"),	code=lnk_CUSsto("minarr")},
	WIDGET.newSlider{name="minsdarr",	x=180,	y=290,w=200,unit=4,	font=20,disp=lnk_CUSval("minsdarr"),code=lnk_CUSsto("minsdarr")},
	WIDGET.newSlider{name="nextCount",	x=180,	y=380,w=200,unit=6,	disp=lnk_CUSval("nextCount"),code=lnk_CUSsto("nextCount")},
	WIDGET.newSlider{name="holdCount",	x=180,	y=450,w=200,unit=6,	disp=lnk_CUSval("holdCount"),code=lnk_CUSsto("holdCount")},
	WIDGET.newSwitch{name="infHold",	x=280,	y=530,				disp=lnk_CUSval("infHold"),	code=lnk_CUSrev("infHold"),hide=function()return CUSTOMENV.holdCount==0 end},

	--Rule
	WIDGET.newSelector{name="fieldH",	x=550,	y=520,	w=260,color="sky",	list={1,2,3,4,6,8,10,15,20,30,50,100},disp=lnk_CUSval("fieldH"),code=lnk_CUSsto("fieldH")},

	WIDGET.newSelector{name="visible",	x=840,	y=60,	w=260,color="lBlue",list={"show","easy","slow","medium","fast","none"},disp=lnk_CUSval("visible"),code=lnk_CUSsto("visible")},
	WIDGET.newSelector{name="target",	x=840,	y=160,	w=260,color="green",list={10,20,40,100,200,500,1000,1e99},	disp=lnk_CUSval("target"),code=lnk_CUSsto("target")},
	WIDGET.newSelector{name="freshLimit",x=840,	y=260,	w=260,color="purple",list={0,8,15,1e99},					disp=lnk_CUSval("freshLimit"),code=lnk_CUSsto("freshLimit")},
	WIDGET.newSelector{name="opponent",	x=1120,	y=60,	w=260,color="red",	list={"X","9S Lv.1","9S Lv.2","9S Lv.3","9S Lv.4","9S Lv.5","CC Lv.1","CC Lv.2","CC Lv.3","CC Lv.4","CC Lv.5"},disp=lnk_CUSval("opponent"),code=lnk_CUSsto("opponent")},
	WIDGET.newSelector{name="life",		x=1120,	y=160,	w=260,color="red",	list={0,1,2,3,5,10,15,26,42,87,500},	disp=lnk_CUSval("life"),code=lnk_CUSsto("life")},
	WIDGET.newSelector{name="pushSpeed",x=1120,	y=260,	w=260,color="red",	list={1,2,3,5,15},						disp=lnk_CUSval("pushSpeed"),code=lnk_CUSsto("pushSpeed")},

	WIDGET.newSwitch{name="ospin",		x=870,	y=350,	font=30,disp=lnk_CUSval("ospin"),	code=lnk_CUSrev("ospin")},
	WIDGET.newSwitch{name="noTele",		x=870,	y=440,	font=25,disp=lnk_CUSval("noTele"),	code=lnk_CUSrev("noTele")},
	WIDGET.newSwitch{name="fineKill",	x=870,	y=530,	font=20,disp=lnk_CUSval("fineKill"),code=lnk_CUSrev("fineKill")},
	WIDGET.newSwitch{name="b2bKill",	x=870,	y=620,	font=20,disp=lnk_CUSval("b2bKill"),	code=lnk_CUSrev("b2bKill")},
	WIDGET.newSwitch{name="easyFresh",	x=1160,	y=350,	font=20,disp=lnk_CUSval("easyFresh"),code=lnk_CUSrev("easyFresh")},
	WIDGET.newSwitch{name="deepDrop",	x=1160,	y=440,	font=30,disp=lnk_CUSval("deepDrop"),code=lnk_CUSrev("deepDrop")},
	WIDGET.newSwitch{name="bone",		x=1160,	y=530,	disp=lnk_CUSval("bone"),			code=lnk_CUSrev("bone")},

	WIDGET.newButton{name="back",		x=1140,	y=640,	w=170,h=80,	font=40,code=backScene},
}

return scene