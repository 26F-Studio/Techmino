local gc=love.graphics
local int=math.floor

local scene={}

local timer

function scene.sceneInit()
	timer=1
end

scene.keyDown=NULL
scene.mouseDown=NULL
scene.touchDown=NULL

function scene.update(dt)
	timer=timer-dt*.8
	if timer<0 then
		SFX.play("click")
		SCN.swapTo("play","none")
	end
end

function scene.draw()
	--Game scene
	if timer*1.26<1 then
		SCN.scenes.play.draw()
	end

	--Grey screen cover
	gc.setColor(.15,.15,.15,timer*1.26)
	gc.push("transform")
		gc.origin()
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
	gc.pop()

	--Pie counter
	gc.setColor(1,1,1,4*(1-timer))
	gc.arc("fill","pie",640,360,160,-1.5708,timer*6.2832-1.5708)
end

return scene