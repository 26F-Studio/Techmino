local sList={
	fieldH={1,2,3,4,6,8,10,15,20,30,50,100},
	visible={"show","easy","slow","medium","fast","none"},
	freshLimit={0,8,15,1e99},
	opponent={"X","9S Lv.1","9S Lv.2","9S Lv.3","9S Lv.4","9S Lv.5","CC Lv.1","CC Lv.2","CC Lv.3","CC Lv.4","CC Lv.5"},
	life={0,1,2,3,5,10,15,26,42,87,500},
	pushSpeed={1,2,3,5,15},
}

local scene={}

scene.widgetList={
	WIDGET.newText{name="title",		x=520,y=5,font=70,align="R"},
	WIDGET.newText{name="subTitle",		x=530,y=50,font=35,align="L",color="gray"},

	--Control
	WIDGET.newSlider{name="nextCount",	x=200,	y=150,	w=200,unit=6,disp=CUSval("nextCount"),code=CUSsto("nextCount")},
	WIDGET.newSlider{name="holdCount",	x=200,	y=240,	w=200,unit=6,disp=CUSval("holdCount"),code=CUSsto("holdCount")},
	WIDGET.newSwitch{name="infHold",	x=350,	y=340,				disp=CUSval("infHold"),	code=CUSrev("infHold"),hide=function()return CUSTOMENV.holdCount==0 end},
	WIDGET.newSwitch{name="phyHold",	x=350,	y=430,				disp=CUSval("phyHold"),	code=CUSrev("phyHold"),hide=function()return CUSTOMENV.holdCount==0 end},

	--Rule
	WIDGET.newSelector{name="fieldH",	x=270,	y=520,	w=260,color="sky",	list=sList.fieldH,		disp=CUSval("fieldH"),code=CUSsto("fieldH")},
	WIDGET.newSelector{name="visible",	x=840,	y=60,	w=260,color="lBlue",list=sList.visible,		disp=CUSval("visible"),code=CUSsto("visible")},
	WIDGET.newSelector{name="freshLimit",x=840,	y=160,	w=260,color="purple",list=sList.freshLimit,	disp=CUSval("freshLimit"),code=CUSsto("freshLimit")},
	WIDGET.newSelector{name="opponent",	x=1120,	y=60,	w=260,color="red",	list=sList.opponent,	disp=CUSval("opponent"),code=CUSsto("opponent")},
	WIDGET.newSelector{name="life",		x=1120,	y=160,	w=260,color="red",	list=sList.life,		disp=CUSval("life"),code=CUSsto("life")},
	WIDGET.newSelector{name="pushSpeed",x=1120,	y=260,	w=260,color="red",	list=sList.pushSpeed,	disp=CUSval("pushSpeed"),code=CUSsto("pushSpeed")},

	WIDGET.newSwitch{name="ospin",		x=870,	y=350,	font=30,disp=CUSval("ospin"),	code=CUSrev("ospin")},
	WIDGET.newSwitch{name="fineKill",	x=870,	y=530,	font=20,disp=CUSval("fineKill"),code=CUSrev("fineKill")},
	WIDGET.newSwitch{name="b2bKill",	x=870,	y=620,	font=20,disp=CUSval("b2bKill"),	code=CUSrev("b2bKill")},
	WIDGET.newSwitch{name="easyFresh",	x=1160,	y=350,	font=20,disp=CUSval("easyFresh"),code=CUSrev("easyFresh")},
	WIDGET.newSwitch{name="deepDrop",	x=1160,	y=440,	font=30,disp=CUSval("deepDrop"),code=CUSrev("deepDrop")},
	WIDGET.newSwitch{name="bone",		x=1160,	y=530,	disp=CUSval("bone"),			code=CUSrev("bone")},

	WIDGET.newButton{name="back",		x=1140,	y=640,	w=170,h=80,	font=40,code=backScene},
}

return scene