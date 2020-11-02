function sceneInit.setting_touchSwitch()
	BG.set("matrix")
end

local function VKAdisp(n)return function()return VK_org[n].ava end end
local function VKAcode(n)return function()VK_org[n].ava=not VK_org[n].ava end end

WIDGET.init("setting_touchSwitch",{
	WIDGET.newSwitch({name="b1",	x=280,	y=80,	font=35,disp=VKAdisp(1),code=VKAcode(1)}),
	WIDGET.newSwitch({name="b2",	x=280,	y=140,	font=35,disp=VKAdisp(2),code=VKAcode(2)}),
	WIDGET.newSwitch({name="b3",	x=280,	y=200,	font=35,disp=VKAdisp(3),code=VKAcode(3)}),
	WIDGET.newSwitch({name="b4",	x=280,	y=260,	font=35,disp=VKAdisp(4),code=VKAcode(4)}),
	WIDGET.newSwitch({name="b5",	x=280,	y=320,	font=35,disp=VKAdisp(5),code=VKAcode(5)}),
	WIDGET.newSwitch({name="b6",	x=280,	y=380,	font=35,disp=VKAdisp(6),code=VKAcode(6)}),
	WIDGET.newSwitch({name="b7",	x=280,	y=440,	font=35,disp=VKAdisp(7),code=VKAcode(7)}),
	WIDGET.newSwitch({name="b8",	x=280,	y=500,	font=35,disp=VKAdisp(8),code=VKAcode(8)}),
	WIDGET.newSwitch({name="b9",	x=280,	y=560,	font=35,disp=VKAdisp(9),code=VKAcode(9)}),
	WIDGET.newSwitch({name="b10",	x=280,	y=620,	font=35,disp=VKAdisp(10),code=VKAcode(10)}),
	WIDGET.newSwitch({name="b11",	x=580,	y=80,	font=35,disp=VKAdisp(11),code=VKAcode(11)}),
	WIDGET.newSwitch({name="b12",	x=580,	y=140,	font=35,disp=VKAdisp(12),code=VKAcode(12)}),
	WIDGET.newSwitch({name="b13",	x=580,	y=200,	font=35,disp=VKAdisp(13),code=VKAcode(13)}),
	WIDGET.newSwitch({name="b14",	x=580,	y=260,	font=35,disp=VKAdisp(14),code=VKAcode(14)}),
	WIDGET.newSwitch({name="b15",	x=580,	y=320,	font=35,disp=VKAdisp(15),code=VKAcode(15)}),
	WIDGET.newSwitch({name="b16",	x=580,	y=380,	font=35,disp=VKAdisp(16),code=VKAcode(16)}),
	WIDGET.newSwitch({name="b17",	x=580,	y=440,	font=35,disp=VKAdisp(17),code=VKAcode(17)}),
	WIDGET.newSwitch({name="b18",	x=580,	y=500,	font=35,disp=VKAdisp(18),code=VKAcode(18)}),
	WIDGET.newSwitch({name="b19",	x=580,	y=560,	font=35,disp=VKAdisp(19),code=VKAcode(19)}),
	WIDGET.newSwitch({name="b20",	x=580,	y=620,	font=35,disp=VKAdisp(20),code=VKAcode(20)}),
	WIDGET.newButton({name="norm",	x=840,	y=100,	w=240,h=80,		font=35,code=function()for i=1,20 do VK_org[i].ava=i<11 end end}),
	WIDGET.newButton({name="pro",	x=1120,	y=100,	w=240,h=80,		font=35,code=function()for i=1,20 do VK_org[i].ava=true end end}),
	WIDGET.newSwitch({name="hide",	x=1170,	y=200,					font=40,disp=WIDGET.lnk.SETval("VKSwitch"),code=WIDGET.lnk.SETrev("VKSwitch")}),
	WIDGET.newSwitch({name="track",	x=1170,	y=300,					font=35,disp=WIDGET.lnk.SETval("VKTrack"),code=WIDGET.lnk.SETrev("VKTrack")}),
	WIDGET.newSlider({name="sfx",	x=800,	y=380,	w=180,			font=35,change=function()SFX.play("virtualKey",SETTING.VKSFX)end,disp=WIDGET.lnk.SETval("VKSFX"),code=WIDGET.lnk.SETsto("VKSFX")}),
	WIDGET.newSlider({name="vib",	x=800,	y=460,	w=180,unit=2,	font=35,change=function()VIB(SETTING.VKVIB)end,disp=WIDGET.lnk.SETval("VKVIB"),code=WIDGET.lnk.SETsto("VKVIB")}),
	WIDGET.newSwitch({name="icon",	x=850,	y=300,	font=40,disp=WIDGET.lnk.SETval("VKIcon"),code=WIDGET.lnk.SETrev("VKIcon")}),
	WIDGET.newButton({name="tkset",	x=1120,	y=420,	w=240,h=80,
		code=function()
			SCN.go("setting_trackSetting")
		end,
		hide=function()
			return not SETTING.VKTrack
		end}),
	WIDGET.newSlider({name="alpha",	x=840,	y=540,	w=400,font=40,disp=WIDGET.lnk.SETval("VKAlpha"),code=WIDGET.lnk.SETsto("VKAlpha")}),
	WIDGET.newButton({name="back",	x=1140,	y=640,	w=170,h=80,font=40,code=WIDGET.lnk.BACK}),
})