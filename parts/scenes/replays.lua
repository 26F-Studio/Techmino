local gc=love.graphics

local scene={}

function scene.sceneInit()
end

function scene.draw()
end

scene.widgetList={
	WIDGET.newButton{name="back",	x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene