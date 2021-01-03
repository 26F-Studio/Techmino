local int=math.floor

local scene={}

local mini,b2b,b3b,pc

function scene.sceneInit()
	mini,b2b,b3b,pc=false,false,false,false
end

local blockName={"z","s","j","l","t","o","i"}
local lineCount={"single","double","triple","techrash"}
function scene.keyDown(key)
	if key=="1"then
		mini=not mini
	elseif key=="2"then
		b2b=not b2b
		if b2b then b3b=false end
	elseif key=="3"then
		b3b=not b3b
		if b3b then b2b=false end
	elseif key=="4"then
		pc=not pc
	elseif type(key)=="number"then
		local CHN=VOC.getFreeChannel()
		if mini then VOC.play("mini",CHN)end
		if b2b then VOC.play("b2b",CHN)
		elseif b3b then VOC.play("b3b",CHN)
		end
		if key>=10 then
			VOC.play(blockName[int(key/10)].."spin",CHN)
		end
		if lineCount[key%10]then VOC.play(lineCount[key%10],CHN)end
		if pc then VOC.play("perfect_clear",CHN)end
	elseif key=="escape"then
		SCN.back()
	end
end

scene.widgetList={
	WIDGET.newText{name="title",	x=30,	y=15,font=70,align="L"},
	WIDGET.newSlider{name="sfx",	x=510,	y=60,w=330,font=35,change=function()SFX.play("blip_1")end,disp=WIDGET.lnk_SETval("sfx"),code=WIDGET.lnk_SETsto("sfx")},
	WIDGET.newSlider{name="voc",	x=510,	y=120,w=330,font=35,change=function()VOC.play("test")end,disp=WIDGET.lnk_SETval("voc"),code=WIDGET.lnk_SETsto("voc")},

	WIDGET.newKey{name="move",		x=110,	y=140,w=160,h=50,font=20,code=function()SFX.play("move")end},
	WIDGET.newKey{name="lock",		x=110,	y=205,w=160,h=50,font=20,code=function()SFX.play("lock")end},
	WIDGET.newKey{name="drop",		x=110,	y=270,w=160,h=50,font=20,code=function()SFX.play("drop")end},
	WIDGET.newKey{name="fall",		x=110,	y=335,w=160,h=50,font=20,code=function()SFX.play("fall")end},
	WIDGET.newKey{name="rotate",	x=110,	y=400,w=160,h=50,font=20,code=function()SFX.play("rotate")end},
	WIDGET.newKey{name="rotatekick",x=110,	y=465,w=160,h=50,font=20,code=function()SFX.play("rotatekick")end},
	WIDGET.newKey{name="hold",		x=110,	y=530,w=160,h=50,font=20,code=function()SFX.play("hold")end},
	WIDGET.newKey{name="prerotate",x=110,	y=595,w=160,h=50,font=20,code=function()SFX.play("prerotate")end},
	WIDGET.newKey{name="prehold",	x=110,	y=660,w=160,h=50,font=20,code=function()SFX.play("prehold")end},

	WIDGET.newKey{name="clear1",	x=280,	y=140,w=160,h=50,font=20,code=function()SFX.play("clear_1")end},
	WIDGET.newKey{name="clear2",	x=280,	y=205,w=160,h=50,font=20,code=function()SFX.play("clear_2")end},
	WIDGET.newKey{name="clear3",	x=280,	y=270,w=160,h=50,font=20,code=function()SFX.play("clear_3")end},
	WIDGET.newKey{name="clear4",	x=280,	y=335,w=160,h=50,font=20,code=function()SFX.play("clear_4")end},
	WIDGET.newKey{name="spin0",		x=280,	y=400,w=160,h=50,font=20,code=function()SFX.play("spin_0")end},
	WIDGET.newKey{name="spin1",		x=280,	y=465,w=160,h=50,font=20,code=function()SFX.play("spin_1")end},
	WIDGET.newKey{name="spin2",		x=280,	y=530,w=160,h=50,font=20,code=function()SFX.play("spin_2")end},
	WIDGET.newKey{name="spin3",		x=280,	y=595,w=160,h=50,font=20,code=function()SFX.play("spin_3")end},
	WIDGET.newKey{name="_pc",		x=280,	y=660,w=160,h=50,font=20,code=function()SFX.play("clear")end},

	WIDGET.newKey{name="_1",		x=970,	y=75,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(1)},
	WIDGET.newKey{name="_2",		x=1130,	y=75,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(2)},
	WIDGET.newKey{name="_3",		x=970,	y=140,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(3)},
	WIDGET.newKey{name="_4",		x=1130,	y=140,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(4)},

	WIDGET.newKey{name="z0",		x=650,	y=205,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(10)},
	WIDGET.newKey{name="z1",		x=650,	y=270,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(11)},
	WIDGET.newKey{name="z2",		x=650,	y=335,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(12)},
	WIDGET.newKey{name="z3",		x=650,	y=400,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(13)},
	WIDGET.newKey{name="t0",		x=650,	y=465,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(50)},
	WIDGET.newKey{name="t1",		x=650,	y=530,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(51)},
	WIDGET.newKey{name="t2",		x=650,	y=595,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(52)},
	WIDGET.newKey{name="t3",		x=650,	y=660,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(53)},

	WIDGET.newKey{name="s0",		x=810,	y=205,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(20)},
	WIDGET.newKey{name="s1",		x=810,	y=270,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(21)},
	WIDGET.newKey{name="s2",		x=810,	y=335,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(22)},
	WIDGET.newKey{name="s3",		x=810,	y=400,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(23)},
	WIDGET.newKey{name="o0",		x=810,	y=465,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(60)},
	WIDGET.newKey{name="o1",		x=810,	y=530,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(61)},
	WIDGET.newKey{name="o2",		x=810,	y=595,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(62)},
	WIDGET.newKey{name="o3",		x=810,	y=660,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(63)},

	WIDGET.newKey{name="j0",		x=970,	y=205,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(30)},
	WIDGET.newKey{name="j1",		x=970,	y=270,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(31)},
	WIDGET.newKey{name="j2",		x=970,	y=335,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(32)},
	WIDGET.newKey{name="j3",		x=970,	y=400,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(33)},
	WIDGET.newKey{name="i0",		x=970,	y=465,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(70)},
	WIDGET.newKey{name="i1",		x=970,	y=530,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(71)},
	WIDGET.newKey{name="i2",		x=970,	y=595,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(72)},
	WIDGET.newKey{name="i3",		x=970,	y=660,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(73)},

	WIDGET.newKey{name="l0",		x=1130,	y=205,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(40)},
	WIDGET.newKey{name="l1",		x=1130,	y=270,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(41)},
	WIDGET.newKey{name="l2",		x=1130,	y=335,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(42)},
	WIDGET.newKey{name="l3",		x=1130,	y=400,w=140,h=50,font=20,code=WIDGET.lnk_pressKey(43)},

	WIDGET.newSwitch{name="mini",	x=515,	y=465,font=25,disp=function()return mini end,code=WIDGET.lnk_pressKey("1")},
	WIDGET.newSwitch{name="b2b",	x=515,	y=530,font=25,disp=function()return b2b end,code=WIDGET.lnk_pressKey("2")},
	WIDGET.newSwitch{name="b3b",	x=515,	y=595,font=25,disp=function()return b3b end,code=WIDGET.lnk_pressKey("3")},
	WIDGET.newSwitch{name="pc",		x=515,	y=660,font=25,disp=function()return pc end,code=WIDGET.lnk_pressKey("4")},

	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene