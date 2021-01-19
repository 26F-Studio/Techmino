local gc=love.graphics
local int=math.floor

local scene={}

local timer

function scene.sceneInit()
	timer=2
end

scene.keyDown=NULL
scene.mouseDown=NULL
scene.touchDown=NULL

function scene.update(dt)
	timer=timer-dt
	if timer<0 then
		SCN.swapTo("play","none")
	end
end

function scene.draw()
	if timer<1 then
		SCN.scenes.play.draw()
	end

	gc.setColor(.15,.15,.15,timer)
	gc.push("transform")
		gc.origin()
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
	gc.pop()

	gc.setColor(1,1,1,5*(2-timer))
	gc.arc("fill","pie",640,360,160,-1.5708,timer*3.1416-1.5708)
end

return scene