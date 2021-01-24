local scene={}

local inited

function scene.sceneInit()
	BG.set("cubes")
	if not inited then
		inited=true
		WIDGET.active.texts:setTexts(require"parts/updateLog")
	end
	if newVersionLaunch then
		newVersionLaunch=false
	end
end

function scene.wheelMoved(_,y)
	wheelScroll(y)
end
function scene.keyDown(k)
	if k=="up"then
		WIDGET.active.texts:scroll(-5)
	elseif k=="down"then
		WIDGET.active.texts:scroll(5)
	elseif k=="pgup"then
		WIDGET.active.texts:scroll(-20)
	elseif k=="pgdown"then
		WIDGET.active.texts:scroll(20)
	end
end

scene.widgetList={
	WIDGET.newTextBox{name="texts",	x=30,y=45,w=1000,h=640,font=20,fix=true},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=backScene},
}

return scene