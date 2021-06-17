local gc=love.graphics
local kb,tc=love.keyboard,love.touch
local rnd=math.random
local ins,rem=table.insert,table.remove

local scene={}

local time,v
local patron=require"parts.patron"
local names
local counter

function scene.sceneInit()
	time=0
	v=1
	BG.set()
	names={}
	counter=26
end

function scene.mouseDown(x,y)
	local T=40*math.min(time,45)
	if x>230 and x<1050 then
		if math.abs(y-800+T)<70 then
			loadGame('sprintLock',true)
		elseif math.abs(y-2160+T)<70 then
			loadGame('sprintFix',true)
		end
	end
end

function scene.touchDown(x,y)
	scene.mouseDown(x,y)
end

function scene.keyDown(key,isRep)
	if isRep then return end
	if key=="escape"then
		SCN.back()
	else
		if key=="l"then
			loadGame('sprintLock',true)
		elseif key=="f"then
			loadGame('sprintFix',true)
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
	counter=counter-1
	if counter==0 then
		local N=patron[rnd(#patron)]
		local T=gc.newText(getFont(N.font),N.name)
		local r=rnd()<.5
		ins(names,{
			text=T,
			x=r and -T:getWidth()or SCR.w,
			y=rnd()*(SCR.h-T:getHeight()),
			w=T:getWidth(),
			vx=(r and 1 or -1)*(1.626+rnd())*(SCR.w+T:getWidth())/SCR.w,
		})
		counter=26
	end
	for i=#names,1,-1 do
		local N=names[i]
		N.x=N.x+N.vx
		if N.vx>0 and N.x>SCR.w or N.vx<0 and N.x<-N.w then
			rem(names,i)
		end
	end
end

function scene.draw()
	gc.replaceTransform(SCR.origin)
	gc.setColor(1,1,1,.3)
	for i=1,#names do
		local N=names[i]
		gc.draw(N.text,N.x,N.y)
	end

	gc.replaceTransform(SCR.xOy)
	gc.setColor(1,1,1)
	local T=40*math.min(time,45)
	local L=text.staff
	setFont(40)
	for i=1,#L do
		mStr(L[i],640,800+70*i-T)
	end
	mDraw(TEXTURE.title_color,640,800-T,nil,.6)
	mDraw(TEXTURE.title_color,640,2160-T,nil,.6)
	if time>50 then gc.print("CLICK ME →",50,550,-.5)end
end

scene.widgetList={
	WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene