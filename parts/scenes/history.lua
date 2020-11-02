local gc=love.graphics
local setFont=setFont
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

function sceneInit.history()
	BG.set("rainbow")
	sceneTemp={
		text=require("parts/updateLog"),--Text list
		pos=1,--Scroll pos
	}
	if newVersionLaunch then
		newVersionLaunch=nil
		sceneTemp.pos=3
	end
end

function wheelMoved.history(_,y)
	wheelScroll(y)
end
function keyDown.history(key)
	if key=="up"then
		sceneTemp.pos=max(sceneTemp.pos-1,1)
	elseif key=="down"then
		sceneTemp.pos=min(sceneTemp.pos+1,#sceneTemp.text)
	elseif key=="escape"then
		SCN.back()
	end
end

function Pnt.history()
	gc.setColor(.2,.2,.2,.7)
	gc.rectangle("fill",30,45,1000,632)
	gc.setColor(1,1,1)
	gc.setLineWidth(4)
	gc.rectangle("line",30,45,1000,632)
	setFont(20)
	local S=sceneTemp
	gc.print(S.text[S.pos],40,50)
end

WIDGET.init("history",{
	WIDGET.newKey({name="prev",		x=1155,	y=170,w=180,font=65,code=WIDGET.lnk.pressKey("up"),hide=WIDGET.lnk.STPeq("pos",1)}),
	WIDGET.newKey({name="next",		x=1155,	y=400,w=180,font=65,code=WIDGET.lnk.pressKey("down"),hide=function()return sceneTemp.pos==#sceneTemp.text end}),
	WIDGET.newButton({name="back",	x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk.BACK}),
})