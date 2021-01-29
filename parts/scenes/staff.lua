local gc=love.graphics
local kb,tc=love.keyboard,love.touch

local scene={}

local time,v

function scene.sceneInit()
	time=0
	v=1
	BG.set()
end

function scene.mouseDown(x,y)
	local T=40*math.min(time,45)
	if x>230 and x<1050 then
		if math.abs(y-800+T)<70 then
			loadGame("sprintLock",true)
		elseif math.abs(y-2160+T)<70 then
			loadGame("sprintFix",true)
		end
	end
end

function scene.touchDown(_,x,y)
	scene.mouseDown(x,y)
end

function scene.keyDown(k)
	if k=="escape"then
		SCN.back()
	elseif kb.isDown("s")then
		if k=="l"then
			loadGame("sprintLock",true)
		elseif k=="f"then
			loadGame("sprintFix",true)
		end
	end
end

function scene.update(dt)
	if(kb.isDown("space","return")or tc.getTouches()[1])and v<6.26 then
		v=v+.26
	elseif v>1 then
		v=v-.26
	end
	time=time+v*dt
end

function scene.draw()
	local T=40*math.min(time,45)
	local L=text.staff
	setFont(40)
	gc.setColor(1,1,1)
	for i=1,#L do
		mStr(L[i],640,800+70*i-T)
	end
	mDraw(TEXTURE.title_color,640,800-T,nil,.6)
	mDraw(TEXTURE.title_color,640,2160-T,nil,.6)
	if time>55 then gc.print("CLICK ME →",50,550,-.5)end
end

scene.widgetList={
	WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,font=40,code=backScene},
}

return scene