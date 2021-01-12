local gc=love.graphics
local max,min=math.max,math.min

local scene={}

local texts--Text list
local scrollPos--Scroll down length

function scene.sceneInit()
	BG.set("cubes")
	texts=require"parts/updateLog"
	scrollPos=1
	if newVersionLaunch then
		newVersionLaunch=false
		scrollPos=3
	end
end

function scene.wheelMoved(_,y)
	wheelScroll(y)
end
function scene.keyDown(key)
	if key=="up"then
		scrollPos=max(scrollPos-6,1)
	elseif key=="down"then
		scrollPos=min(scrollPos+6,#texts-22)
	elseif key=="escape"then
		SCN.back()
	end
end

function scene.draw()
	gc.setColor(.2,.2,.2,.7)
	gc.rectangle("fill",30,45,1000,632)
	gc.setColor(1,1,1)
	gc.setLineWidth(4)
	gc.rectangle("line",30,45,1000,632)
	setFont(20)
	for i=0,22 do
		gc.print(texts[scrollPos+i],40,50+27*i)
	end
end

scene.widgetList={
	WIDGET.newKey{name="prev",		x=1155,	y=170,w=180,fText="↑",font=65,code=pressKey"up",hide=function()return scrollPos==1 end},
	WIDGET.newKey{name="next",		x=1155,	y=400,w=180,fText="↓",font=65,code=pressKey"down",hide=function()return scrollPos==#texts end},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=backScene},
}

return scene