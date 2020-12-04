local gc=love.graphics
local kb,tc=love.keyboard,love.touch

local scene={}

function scene.sceneInit()
	sceneTemp={
		time=0,
		v=1,
	}
	BG.set("space")
end

function scene.mouseDown(x,y)
	if x>230 and x<1050 then
		if math.abs(y-800+sceneTemp.time*40)<70 then
			SCN.pop()SCN.push()
			loadGame("sprintLock")
		elseif math.abs(y-2160+sceneTemp.time*40)<70 then
			SCN.pop()SCN.push()
			loadGame("sprintFix")
		end
	end
end

function scene.touchDown(_,x,y)
	scene.mouseDown(x,y)
end

function scene.keyDown(k)
	if kb.isDown("s")then
		if k=="l"then
			SCN.pop()
			loadGame("sprintLock")
		elseif k=="f"then
			SCN.pop()
			loadGame("sprintFix")
		end
	end
end

function scene.Tmr(dt)
	local S=sceneTemp
	if(kb.isDown("space","return")or tc.getTouches()[1])and S.v<6.26 then
		S.v=S.v+.26
	elseif S.v>1 then
		S.v=S.v-.26
	end
	S.time=S.time+S.v*dt
	if S.time>45 then
		S.time=45
	end
end

function scene.Pnt()
	local L=text.staff
	local t=sceneTemp.time
	setFont(40)
	gc.setColor(1,1,1)
	for i=1,#L do
		mStr(L[i],640,800+70*i-t*40)
	end
	mDraw(IMG.title_color,640,800-t*40,nil,2)
	mDraw(IMG.title_color,640,2160-t*40,nil,2)
end

scene.widgetList={
	WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene