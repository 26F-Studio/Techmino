local gc=love.graphics
local max,min=math.max,math.min

local floatWheel=0
local function wheelScroll(y)
	if y>0 then
		if floatWheel<0 then floatWheel=0 end
		floatWheel=floatWheel+y^1.2
	elseif y<0 then
		if floatWheel>0 then floatWheel=0 end
		floatWheel=floatWheel-(-y)^1.2
	end
	while floatWheel>=1 do
		love.keypressed("up")
		floatWheel=floatWheel-1
	end
	while floatWheel<=-1 do
		love.keypressed("down")
		floatWheel=floatWheel+1
	end
end

local scene={}

function scene.sceneInit()
	BG.set("rainbow")
	sceneTemp={
		text=require"parts/updateLog",--Text list
		pos=1,--Scroll pos
	}
	if newVersionLaunch then
		newVersionLaunch=nil
		sceneTemp.pos=3
	end
end

function scene.wheelMoved(_,y)
	wheelScroll(y)
end
function scene.keyDown(key)
	if key=="up"then
		sceneTemp.pos=max(sceneTemp.pos-1,1)
	elseif key=="down"then
		sceneTemp.pos=min(sceneTemp.pos+1,#sceneTemp.text)
	elseif key=="escape"then
		SCN.back()
	end
end

function scene.Pnt()
	gc.setColor(.2,.2,.2,.7)
	gc.rectangle("fill",30,45,1000,632)
	gc.setColor(1,1,1)
	gc.setLineWidth(4)
	gc.rectangle("line",30,45,1000,632)
	setFont(20)
	local S=sceneTemp
	gc.print(S.text[S.pos],40,50)
end

scene.widgetList={
	WIDGET.newKey{name="prev",		x=1155,	y=170,w=180,font=65,code=WIDGET.lnk_pressKey("up"),hide=WIDGET.lnk_STPeq("pos",1)},
	WIDGET.newKey{name="next",		x=1155,	y=400,w=180,font=65,code=WIDGET.lnk_pressKey("down"),hide=function()return sceneTemp.pos==#sceneTemp.text end},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene