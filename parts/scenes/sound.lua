local int=math.floor

function sceneInit.sound()
	sceneTemp={
		mini=false,
		b2b=false,
		b3b=false,
		pc=false,
	}
end

local blockName={"z","s","j","l","t","o","i"}
local lineCount={
	"single",
	"double",
	"triple",
}
function keyDown.sound(key)
	local S=sceneTemp
	if key=="1"then
		S.mini=not S.mini
	elseif key=="2"then
		S.b2b=not S.b2b
		if S.b2b then S.b3b=false end
	elseif key=="3"then
		S.b3b=not S.b3b
		if S.b3b then S.b2b=false end
	elseif key=="4"then
		S.pc=not S.pc
	elseif type(key)=="number"then
		local CHN=VOC.getFreeChannel()
		if S.mini then VOC.play("mini",CHN)end
		if S.b2b then VOC.play("b2b",CHN)
		elseif S.b3b then VOC.play("b3b",CHN)
		end
		VOC.play(blockName[int(key/10)].."spin",CHN)
		if key%10>0 then VOC.play(lineCount[key%10],CHN)end
		if S.pc then VOC.play("perfect_clear",CHN)end
	elseif key=="escape"then
		SCN.back()
	end
end

WIDGET.init("sound",{
	WIDGET.newText({name="title",	x=30,	y=15,font=70,align="L"}),
	WIDGET.newSlider({name="sfx",	x=760,	y=60,w=400,font=35,change=function()SFX.play("blip_1")end,disp=WIDGET.lnk.SETval("sfx"),code=WIDGET.lnk.SETsto("sfx")}),
	WIDGET.newSlider({name="voc",	x=760,	y=120,w=400,font=35,change=function()VOC.play("test")end,disp=WIDGET.lnk.SETval("voc"),code=WIDGET.lnk.SETsto("voc")}),

	WIDGET.newKey({name="move",		x=110,	y=140,w=160,h=50,code=function()SFX.play("move")end}),
	WIDGET.newKey({name="lock",		x=110,	y=205,w=160,h=50,code=function()SFX.play("lock")end}),
	WIDGET.newKey({name="drop",		x=110,	y=270,w=160,h=50,code=function()SFX.play("drop")end}),
	WIDGET.newKey({name="fall",		x=110,	y=335,w=160,h=50,code=function()SFX.play("fall")end}),
	WIDGET.newKey({name="rotate",	x=110,	y=400,w=160,h=50,code=function()SFX.play("rotate")end}),
	WIDGET.newKey({name="rotatekick",x=110,	y=465,w=160,h=50,code=function()SFX.play("rotatekick")end}),
	WIDGET.newKey({name="hold",		x=110,	y=530,w=160,h=50,code=function()SFX.play("hold")end}),
	WIDGET.newKey({name="prerotate",x=110,	y=595,w=160,h=50,code=function()SFX.play("prerotate")end}),
	WIDGET.newKey({name="prehold",	x=110,	y=660,w=160,h=50,code=function()SFX.play("prehold")end}),

	WIDGET.newKey({name="_1",		x=280,	y=140,w=160,h=50,code=function()SFX.play("clear_1")end}),
	WIDGET.newKey({name="_2",		x=280,	y=205,w=160,h=50,code=function()SFX.play("clear_2")end}),
	WIDGET.newKey({name="_3",		x=280,	y=270,w=160,h=50,code=function()SFX.play("clear_3")end}),
	WIDGET.newKey({name="_4",		x=280,	y=335,w=160,h=50,code=function()SFX.play("clear_4")end}),
	WIDGET.newKey({name="spin0",	x=280,	y=400,w=160,h=50,code=function()SFX.play("spin_0")end}),
	WIDGET.newKey({name="spin1",	x=280,	y=465,w=160,h=50,code=function()SFX.play("spin_1")end}),
	WIDGET.newKey({name="spin2",	x=280,	y=530,w=160,h=50,code=function()SFX.play("spin_2")end}),
	WIDGET.newKey({name="spin3",	x=280,	y=595,w=160,h=50,code=function()SFX.play("spin_3")end}),
	WIDGET.newKey({name="_pc",		x=280,	y=660,w=160,h=50,code=function()SFX.play("clear")end}),

	WIDGET.newKey({name="z0",		x=650,	y=205,w=140,h=50,code=WIDGET.lnk.pressKey(10)}),
	WIDGET.newKey({name="z1",		x=650,	y=270,w=140,h=50,code=WIDGET.lnk.pressKey(11)}),
	WIDGET.newKey({name="z2",		x=650,	y=335,w=140,h=50,code=WIDGET.lnk.pressKey(12)}),
	WIDGET.newKey({name="z3",		x=650,	y=400,w=140,h=50,code=WIDGET.lnk.pressKey(13)}),
	WIDGET.newKey({name="t0",		x=650,	y=465,w=140,h=50,code=WIDGET.lnk.pressKey(50)}),
	WIDGET.newKey({name="t1",		x=650,	y=530,w=140,h=50,code=WIDGET.lnk.pressKey(51)}),
	WIDGET.newKey({name="t2",		x=650,	y=595,w=140,h=50,code=WIDGET.lnk.pressKey(52)}),
	WIDGET.newKey({name="t3",		x=650,	y=660,w=140,h=50,code=WIDGET.lnk.pressKey(53)}),

	WIDGET.newKey({name="s0",		x=810,	y=205,w=140,h=50,code=WIDGET.lnk.pressKey(20)}),
	WIDGET.newKey({name="s1",		x=810,	y=270,w=140,h=50,code=WIDGET.lnk.pressKey(21)}),
	WIDGET.newKey({name="s2",		x=810,	y=335,w=140,h=50,code=WIDGET.lnk.pressKey(22)}),
	WIDGET.newKey({name="s3",		x=810,	y=400,w=140,h=50,code=WIDGET.lnk.pressKey(23)}),
	WIDGET.newKey({name="o0",		x=810,	y=465,w=140,h=50,code=WIDGET.lnk.pressKey(60)}),
	WIDGET.newKey({name="o1",		x=810,	y=530,w=140,h=50,code=WIDGET.lnk.pressKey(61)}),
	WIDGET.newKey({name="o2",		x=810,	y=595,w=140,h=50,code=WIDGET.lnk.pressKey(62)}),
	WIDGET.newKey({name="o3",		x=810,	y=660,w=140,h=50,code=WIDGET.lnk.pressKey(63)}),

	WIDGET.newKey({name="j0",		x=970,	y=205,w=140,h=50,code=WIDGET.lnk.pressKey(30)}),
	WIDGET.newKey({name="j1",		x=970,	y=270,w=140,h=50,code=WIDGET.lnk.pressKey(31)}),
	WIDGET.newKey({name="j2",		x=970,	y=335,w=140,h=50,code=WIDGET.lnk.pressKey(32)}),
	WIDGET.newKey({name="j3",		x=970,	y=400,w=140,h=50,code=WIDGET.lnk.pressKey(33)}),
	WIDGET.newKey({name="i0",		x=970,	y=465,w=140,h=50,code=WIDGET.lnk.pressKey(70)}),
	WIDGET.newKey({name="i1",		x=970,	y=530,w=140,h=50,code=WIDGET.lnk.pressKey(71)}),
	WIDGET.newKey({name="i2",		x=970,	y=595,w=140,h=50,code=WIDGET.lnk.pressKey(72)}),
	WIDGET.newKey({name="i3",		x=970,	y=660,w=140,h=50,code=WIDGET.lnk.pressKey(73)}),

	WIDGET.newKey({name="l0",		x=1130,	y=205,w=140,h=50,code=WIDGET.lnk.pressKey(40)}),
	WIDGET.newKey({name="l1",		x=1130,	y=270,w=140,h=50,code=WIDGET.lnk.pressKey(41)}),
	WIDGET.newKey({name="l2",		x=1130,	y=335,w=140,h=50,code=WIDGET.lnk.pressKey(42)}),
	WIDGET.newKey({name="l3",		x=1130,	y=400,w=140,h=50,code=WIDGET.lnk.pressKey(43)}),

	WIDGET.newSwitch({name="mini",	x=515,	y=465,disp=WIDGET.lnk.STPval("mini"),code=WIDGET.lnk.pressKey("1")}),
	WIDGET.newSwitch({name="b2b",	x=515,	y=530,disp=WIDGET.lnk.STPval("b2b"),code=WIDGET.lnk.pressKey("2")}),
	WIDGET.newSwitch({name="b3b",	x=515,	y=595,disp=WIDGET.lnk.STPval("b3b"),code=WIDGET.lnk.pressKey("3")}),
	WIDGET.newSwitch({name="pc",	x=515,	y=660,disp=WIDGET.lnk.STPval("pc"),code=WIDGET.lnk.pressKey("4")}),

	WIDGET.newButton({name="back",	x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk.BACK}),
})