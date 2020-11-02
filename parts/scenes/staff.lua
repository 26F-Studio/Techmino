local gc=love.graphics
local kb,tc=love.keyboard,love.touch

local setFont=setFont
local mStr=mStr

function sceneInit.staff()
	sceneTemp={
		time=0,
		v=1,
	}
	BG.set("space")
end

function Tmr.staff(dt)
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

function Pnt.staff()
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

WIDGET.init("staff",{
	WIDGET.newButton({name="back",		x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk.BACK}),
})