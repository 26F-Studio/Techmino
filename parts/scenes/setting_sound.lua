local gc=love.graphics
local Timer=love.timer.getTime

local sin=math.sin
local rnd=math.random

function sceneInit.setting_sound()
	sceneTemp={
		last=0,--Last sound time
		jump=0,--Animation timer(10 to 0)
	}
	BG.set("space")
end
function sceneBack.setting_sound()
	FILE.saveSetting()
end

function mouseDown.setting_sound(x,y)
	local S=sceneTemp
	if x>780 and x<980 and y>470 and S.jump==0 then
		S.jump=10
		local t=Timer()-S.last
		if t>1 then
			VOC.play((t<1.5 or t>15)and"doubt"or rnd()<.8 and"happy"or"egg")
			S.last=Timer()
		end
	end
end
function touchDown.setting_sound(_,x,y)
	mouseDown.setting_sound(x,y)
end

function Tmr.setting_sound()
	local t=sceneTemp.jump
	if t>0 then
		sceneTemp.jump=t-1
	end
end

function Pnt.setting_sound()
	gc.setColor(1,1,1)
	local t=Timer()
	local _=sceneTemp.jump
	local x,y=800,340+10*sin(t*.5)+(_-10)*_*.3
	gc.translate(x,y)
	gc.draw(IMG.miyaCH,0,0)
	gc.setColor(1,1,1,.7)
	gc.draw(IMG.miyaF1,4,47+4*sin(t*.9))
	gc.draw(IMG.miyaF2,42,107+5*sin(t))
	gc.draw(IMG.miyaF3,93,126+3*sin(t*.7))
	gc.draw(IMG.miyaF4,129,98+3*sin(t*.7))
	gc.translate(-x,-y)
end

WIDGET.init("setting_sound",{
	WIDGET.newText({name="title",		x=640,y=15,font=80}),

	WIDGET.newButton({name="game",		x=200,	y=80,w=240,h=80,color="lCyan",	font=35,code=WIDGET.lnk.swapScene("setting_game","swipeR")}),
	WIDGET.newButton({name="graphic",	x=1080,	y=80,w=240,h=80,color="lCyan",	font=35,code=WIDGET.lnk.swapScene("setting_video","swipeL")}),

	WIDGET.newSlider({name="sfx",		x=180,	y=200,w=400,					font=35,change=function()SFX.play("blip_1")end,						disp=WIDGET.lnk.SETval("sfx"),		code=WIDGET.lnk.SETsto("sfx")}),
	WIDGET.newSlider({name="stereo",	x=180,	y=500,w=400,					font=35,change=function()SFX.play("move",1,-1)SFX.play("lock",1,1)end,disp=WIDGET.lnk.SETval("stereo"),code=WIDGET.lnk.SETsto("stereo"),hide=function()return SETTING.sfx==0 end}),
	WIDGET.newSlider({name="spawn",	x=180,	y=300,w=400,					font=30,change=function()SFX.fplay("spawn_"..math.random(7),SETTING.spawn)end,disp=WIDGET.lnk.SETval("spawn"),	code=WIDGET.lnk.SETsto("spawn")}),
	WIDGET.newSlider({name="bgm",		x=180,	y=400,w=400,					font=35,change=function()BGM.freshVolume()end,						disp=WIDGET.lnk.SETval("bgm"),		code=WIDGET.lnk.SETsto("bgm")}),
	WIDGET.newSlider({name="vib",		x=750,	y=200,w=400,	unit=5,			font=25,change=function()VIB(2)end,									disp=WIDGET.lnk.SETval("vib"),		code=WIDGET.lnk.SETsto("vib")}),
	WIDGET.newSlider({name="voc",		x=750,	y=300,w=400,					font=35,change=function()VOC.play("test")end,						disp=WIDGET.lnk.SETval("voc"),		code=WIDGET.lnk.SETsto("voc")}),
	WIDGET.newButton({name="back",		x=1140,	y=640,w=170,h=80,				font=40,code=WIDGET.lnk.BACK}),
})