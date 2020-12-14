local gc=love.graphics
local Timer=love.timer.getTime

local sin=math.sin
local rnd=math.random

local scene={}

function scene.sceneInit()
	sceneTemp={
		last=0,--Last touch time
		jump=0,--Animation timer(10 to 0)
		cv=SETTING.cv,
	}
	BG.set("space")
end
function scene.sceneBack()
	FILE.save(SETTING,"settings")
end

function scene.mouseDown(x,y)
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
function scene.touchDown(_,x,y)
	scene.mouseDown(x,y)
end

function scene.Tmr()
	local t=sceneTemp.jump
	if t>0 then
		sceneTemp.jump=t-1
	end
end

function scene.Pnt()
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

scene.widgetList={
	WIDGET.newText{name="title",	x=640,y=15,font=80},

	WIDGET.newButton{name="game",	x=200,	y=80,w=240,h=80,color="lCyan",font=35,code=WIDGET.lnk_swapScene("setting_game","swipeR")},
	WIDGET.newButton{name="graphic",x=1080,	y=80,w=240,h=80,color="lCyan",font=35,code=WIDGET.lnk_swapScene("setting_video","swipeL")},

	WIDGET.newSlider{name="sfx",	x=180,	y=200,w=400,		font=35,change=function()SFX.play("blip_1")end,	disp=WIDGET.lnk_SETval("sfx"),code=WIDGET.lnk_SETsto("sfx")},
	WIDGET.newSlider{name="stereo",	x=180,	y=500,w=400,		font=35,change=function()SFX.play("move",1,-1)SFX.play("lock",1,1)end,disp=WIDGET.lnk_SETval("stereo"),code=WIDGET.lnk_SETsto("stereo"),hide=function()return SETTING.sx==0 end},
	WIDGET.newSlider{name="spawn",	x=180,	y=300,w=400,		font=30,change=function()SFX.fplay("spawn_"..math.random(7),SETTING.spawn)end,disp=WIDGET.lnk_SETval("spawn"),code=WIDGET.lnk_SETsto("spawn")},
	WIDGET.newSlider{name="bgm",	x=180,	y=400,w=400,		font=35,										disp=WIDGET.lnk_SETval("bgm"),code=function(v)SETTING.bgm=v BGM.freshVolume()end},
	WIDGET.newSlider{name="vib",	x=750,	y=200,w=400,unit=5,	font=25,change=function()VIB(2)end,				disp=WIDGET.lnk_SETval("vib"),code=WIDGET.lnk_SETsto("vib")},
	WIDGET.newSlider{name="voc",	x=750,	y=300,w=400,		font=35,change=function()VOC.play("test")end,	disp=WIDGET.lnk_SETval("voc"),code=WIDGET.lnk_SETsto("voc")},
	WIDGET.newSelector{name="cv",	x=1100,	y=380,w=200,		list={"miya","naki"},							disp=WIDGET.lnk_STPval("cv"),code=WIDGET.lnk_STPsto("cv")},
	WIDGET.newButton{name="apply",	x=1100,	y=460,w=180,h=80,	code=function()SETTING.cv=sceneTemp.cv VOC.loadAll()end,hide=function()return SETTING.cv==sceneTemp.cv end},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,	font=40,code=WIDGET.lnk_BACK},
}

return scene