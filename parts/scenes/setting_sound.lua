local gc=love.graphics

local sin=math.sin
local rnd=math.random

local scene={}

local last--Last touch time
local jump--Animation timer(10 to 0)
local cv=SETTING.cv

function scene.sceneInit()
	last,jump=0,0
	cv=SETTING.cv
	BG.set()
end
function scene.sceneBack()
	FILE.save(SETTING,'conf/settings')
end

function scene.mouseDown(x,y)
	if x>780 and x<980 and y>470 and jump==0 then
		jump=10
		local t=TIME()-last
		if t>1 then
			VOC.play((t<1.5 or t>15)and"doubt"or rnd()<.8 and"happy"or"egg")
			last=TIME()
		end
	end
end
function scene.touchDown(x,y)
	scene.mouseDown(x,y)
end

function scene.update()
	if jump>0 then jump=jump-1 end
end

function scene.draw()
	gc.setColor(1,1,1)
	local t=TIME()
	local x,y=800,340+10*sin(t*.5)+(jump-10)*jump*.3
	gc.translate(x,y)
	if cv=="miya"then
		gc.draw(IMG.miyaCH)
		gc.setColor(1,1,1,.7)
		gc.draw(IMG.miyaF1,4,47+4*sin(t*.9))
		gc.draw(IMG.miyaF2,42,107+5*sin(t))
		gc.draw(IMG.miyaF3,93,126+3*sin(t*.7))
		gc.draw(IMG.miyaF4,129,98+3*sin(t*.5))
	elseif cv=="naki"then
		gc.draw(IMG.nakiCH,-30)
	end
	gc.translate(-x,-y)
end

scene.widgetList={
	WIDGET.newText{name="title",	x=640,y=15,font=80},

	WIDGET.newButton{name="game",	x=200,	y=80,w=240,h=80,color='lC',font=35,code=swapScene("setting_game",'swipeR')},
	WIDGET.newButton{name="graphic",x=1080,	y=80,w=240,h=80,color='lC',font=35,code=swapScene("setting_video",'swipeL')},

	WIDGET.newSlider{name="sfx",	x=180,	y=200,w=400,		font=35,change=function()SFX.play('blip_1')end,disp=SETval("sfx"),code=SETsto("sfx")},
	WIDGET.newSlider{name="spawn",	x=180,	y=300,w=400,		font=30,change=function()SFX.fplay("spawn_"..math.random(7),SETTING.sfx_spawn)end,disp=SETval("sfx_spawn"),code=SETsto("sfx_spawn")},
	WIDGET.newSlider{name='warn',	x=180,	y=400,w=400,		font=30,change=function()SFX.fplay("warning",SETTING.sfx_warn)end,disp=SETval("sfx_warn"),code=SETsto("sfx_warn")},
	WIDGET.newSlider{name="bgm",	x=180,	y=500,w=400,		font=35,disp=SETval("bgm"),code=function(v)SETTING.bgm=v BGM.freshVolume()end},
	WIDGET.newSlider{name="stereo",	x=180,	y=600,w=400,		font=35,change=function()SFX.play('move',1,-1)SFX.play('lock',1,1)end,disp=SETval("stereo"),code=SETsto("stereo"),hideF=function()return SETTING.sx==0 end},
	WIDGET.newSlider{name="vib",	x=750,	y=200,w=400,unit=5,	font=25,change=function()VIB(2)end,disp=SETval("vib"),code=SETsto("vib")},
	WIDGET.newSlider{name="voc",	x=750,	y=300,w=400,		font=35,change=function()VOC.play('test')end,disp=SETval("voc"),code=SETsto("voc")},
	WIDGET.newSelector{name="cv",	x=1100,	y=380,w=200,		list={'miya','naki'},disp=function()return cv end,code=function(i)cv=i end},
	WIDGET.newButton{name="apply",	x=1100,	y=460,w=180,h=80,	code=function()SETTING.cv=cv VOC.loadAll()end,hideF=function()return SETTING.cv==cv end},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,	font=40,code=backScene},
}

return scene