local gc=love.graphics
local setColor,setWidth=gc.setColor,gc.setLineWidth
local max,min=math.max,math.min
local rnd=math.random
local rem=table.remove

local fx={}

local function normUpdate(S,dt)
	S.t=S.t+dt*S.rate
	return S.t>1
end

local FXupdate={}
function FXupdate.badge(S,dt)
	S.t=S.t+dt
	if S.t<.2 then
		S.x,S.y=S.x1-14,S.y1-14
	elseif S.t<.8 then
		local t=((S.t-.2)*1.6667)
		t=(3-2*t)*t*t
		S.x,S.y=S.x1*(1-t)+S.x2*t-14,S.y1*(1-t)+S.y2*t-14
	else
		S.x,S.y=S.x2-14,S.y2-14
	end
	return S.t>=1
end
FXupdate.attack=normUpdate
FXupdate.ripple=normUpdate
FXupdate.rectRipple=normUpdate
FXupdate.shade=normUpdate
function FXupdate.cell(S,dt)
	if S.vx then
		S.x=S.x+S.vx*S.rate
		S.y=S.y+S.vy*S.rate
		if S.ax then
			S.vx=S.vx+S.ax*S.rate
			S.vy=S.vy+S.ay*S.rate
		end
	end
	S.t=S.t+dt*S.rate
	return S.t>1
end
FXupdate.line=normUpdate

local FXdraw={}
function FXdraw.badge(S)
	setColor(1,1,1,S.t<.2 and S.t*.6 or S.t<.8 and 1 or(1-S.t)*.6)
	gc.draw(IMG.badgeIcon,S.x,S.y)
end
function FXdraw.attack(S)
	setColor(S.r*2,S.g*2,S.b*2,S.a*min(4-S.t*4,1))

	setWidth(S.wid)
	local t1,t2=max(5*S.t-4,0),min(S.t*4,1)
	gc.line(
		S.x1*(1-t1)+S.x2*t1,
		S.y1*(1-t1)+S.y2*t1,
		S.x1*(1-t2)+S.x2*t2,
		S.y1*(1-t2)+S.y2*t2
	)

	setWidth(S.wid*.6)
	t1,t2=max(4*S.t-3,0),min(S.t*5,1)
	gc.line(
		S.x1*(1-t1)+S.x2*t1,
		S.y1*(1-t1)+S.y2*t1,
		S.x1*(1-t2)+S.x2*t2,
		S.y1*(1-t2)+S.y2*t2
	)
end
function FXdraw.ripple(S)
	local t=S.t
	setWidth(2)
	setColor(1,1,1,1-t)
	gc.circle("line",S.x,S.y,t*(2-t)*S.r)
end
function FXdraw.rectRipple(S)
	setWidth(6)
	setColor(1,1,1,1-S.t)
	local r=(10*S.t)^1.2
	gc.rectangle("line",S.x-r,S.y-r,S.w+2*r,S.h+2*r)
end
function FXdraw.shade(S)
	setColor(S.r,S.g,S.b,1-S.t)
	gc.rectangle("fill",S.x,S.y,S.w,S.h,2)
end
function FXdraw.cell(S)
	setColor(1,1,1,1-S.t)
	gc.draw(S.image,S.x,S.y,nil,S.size,nil,S.cx,S.cy)
end
function FXdraw.line(S)
	setColor(1,1,1,S.a*(1-S.t))
	gc.line(S.x1,S.y1,S.x2,S.y2)
end

local SYSFX={}
function SYSFX.update(dt)
	for i=#fx,1,-1 do
		if fx[i]:update(dt) then
			rem(fx,i)
		end
	end
end
function SYSFX.draw()
	for i=1,#fx do
		fx[i]:draw()
	end
end

function SYSFX.newBadge(x1,y1,x2,y2)
	fx[#fx+1]={
		update=FXupdate.badge,
		draw=FXdraw.badge,
		t=0,
		x=x1,y=y1,
		x1=x1,y1=y1,
		x2=x2,y2=y2,
	}
end
function SYSFX.newAttack(rate,x1,y1,x2,y2,wid,r,g,b,a)
	fx[#fx+1]={
		update=FXupdate.attack,
		draw=FXdraw.attack,
		t=0,
		rate=rate,
		x1=x1,y1=y1,--Start pos
		x2=x2,y2=y2,--End pos
		wid=wid,--Line width
		r=r,g=g,b=b,a=a,
	}
end
function SYSFX.newRipple(rate,x,y,r)
	fx[#fx+1]={
		update=FXupdate.ripple,
		draw=FXdraw.ripple,
		t=0,
		rate=rate,
		x=x,y=y,r=r,
	}
end
function SYSFX.newRectRipple(rate,x,y,w,h)
	fx[#fx+1]={
		update=FXupdate.rectRipple,
		draw=FXdraw.rectRipple,
		t=0,
		rate=rate,
		x=x,y=y,w=w,h=h,
	}
end
function SYSFX.newShade(rate,x,y,w,h,r,g,b)
	fx[#fx+1]={
		update=FXupdate.shade,
		draw=FXdraw.shade,
		t=0,
		rate=rate,
		x=x,y=y,w=w,h=h,
		r=r or 1,g=g or 1,b=b or 1,
	}
end
function SYSFX.newCell(rate,image,size,x,y,vx,vy,ax,ay)
	fx[#fx+1]={
		update=FXupdate.cell,
		draw=FXdraw.cell,
		t=0,
		rate=rate*(.9+rnd()*.2),
		image=image,size=size,
		cx=image:getWidth()*.5,cy=image:getHeight()*.5,
		x=x,y=y,
		vx=vx,vy=vy,
		ax=ax,ay=ay,
	}
end
function SYSFX.newLine(rate,x1,y1,x2,y2,r,g,b,a)
	fx[#fx+1]={
		update=FXupdate.line,
		draw=FXdraw.line,
		t=0,
		rate=rate,
		x1=x1 or 0,y1=y1 or 0,
		x2=x2 or x1 or 1280,y2=y2 or y1 or 720,
		r=r or 1,g=g or 1,b=b or 1,a=a or 1,
	}
end
return SYSFX