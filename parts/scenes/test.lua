local gc=love.graphics
local ins,rem=table.insert,table.remove

local scene={}

local list,timer
local function push(mes)
	ins(list,{mes,120})
	timer=1
end

function scene.sceneInit()
	list={}
	timer=0
	love.keyboard.setKeyRepeat(false)
end

function scene.sceneBack()
	list=nil
	love.keyboard.setKeyRepeat(true)
end

function scene.gamepadDown(key)
	push("[gamepadDown] <"..key..">")
end
function scene.gamepadUp(key)
	push{COLOR.grey,"[gamepadUp] <"..key..">"}
end
function scene.keyDown(key)
	push("[keyDown] <"..key..">")
end
function scene.keyUp(key)
	push{COLOR.grey,"[keyUp] <"..key..">"}
end
function scene.mouseDown(x,y,k)
	push(("[mouseDown] <%d: %d, %d>"):format(k,x,y))
end
function scene.mouseMove(x,y)
	SYSFX.newShade(.5,x-3,y-3,7,7)
end
function scene.mouseUp(x,y,k)
	SYSFX.newRectRipple(1,x-10,y-10,21,21)
	push{COLOR.grey,"[mouseUp] <"..k..">"}
end
function scene.touchClick(x,y)
	SYSFX.newRipple(.5,x,y,50)
	push("[touchClick]")
end
function scene.touchDown(x,y)
	SYSFX.newRipple(.5,x,y,50)
	push(("[touchDown] <%d: %d, %d>"):format(x,y))
end
function scene.touchMove(x,y)
	SYSFX.newRipple(.5,x,y,50)
end
function scene.touchUp(x,y)
	SYSFX.newRipple(.5,x,y,50)
	push{COLOR.grey,"[touchUp]"}
end
function scene.wheelMoved(dx,dy)
	push(("[wheelMoved] <%d, %d>"):format(dx,dy))
end

function scene.update(dt)
	if timer>0 then
		timer=timer-dt/.526
	end
	for i=#list,1,-1 do
		list[i][2]=list[i][2]-1
		if list[i][2]==0 then
			rem(list,i)
		end
	end
end

function scene.draw()
	setFont(15)
	for i=1,#list do
		gc.setColor(1,1,1,list[i][2]/30)
		gc.print(list[i][1],20,20*i)
	end
end

scene.widgetList={

}

return scene