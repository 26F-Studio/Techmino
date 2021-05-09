local scene={}

function scene.sceneInit()
	BG.set('cubes')
	WIDGET.active.texts:setTexts(require"parts.updateLog")
end

function scene.wheelMoved(_,y)
	WHEELMOV(y)
end
function scene.keyDown(k)
	if k=="up"then
		WIDGET.active.texts:scroll(-5)
	elseif k=="down"then
		WIDGET.active.texts:scroll(5)
	elseif k=="pageup"then
		WIDGET.active.texts:scroll(-20)
	elseif k=="pagedown"then
		WIDGET.active.texts:scroll(20)
	elseif k=="escape"then
		SCN.back()
	end
end

scene.widgetList={
	WIDGET.newTextBox{name="texts",x=30,y=45,w=1000,h=640,font=20,fix=true},
	WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene