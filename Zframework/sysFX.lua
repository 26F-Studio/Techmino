local gc=love.graphics
local setColor=gc.setColor
local setWidth=gc.setLineWidth
local ins,rem=table.insert,table.remove

local fx={}

local FXupdate={}
function FXupdate.ripple(S,dt)
	S.t=S.t+dt*S.rate
	return S.t>=1
end
function FXupdate.rectRipple(S,dt)
	S.t=S.t+dt*S.rate
	return S.t>=1
end
function FXupdate.shade(S,dt)
	S.t=S.t+dt*S.rate
	return S.t>=1
end

local FXdraw={}
function FXdraw.ripple(S)
	setWidth(2)
	local t=S.t
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

local sysFX={}
function sysFX.update(dt)
	for i=#fx,1,-1 do
		if fx[i]:update(dt) then
			rem(fx,i)
		end
	end
end
function sysFX.draw()
	for i=1,#fx do
		fx[i]:draw()
	end
end

function sysFX.newRipple(duration,x,y,r)
	fx[#fx+1]={
		update=FXupdate.ripple,
		draw=FXdraw.ripple,
		t=0,
		rate=1/duration,
		x=x,y=y,r=r,
	}
end
function sysFX.newRectRipple(duration,x,y,w,h)
	fx[#fx+1]={
		update=FXupdate.rectRipple,
		draw=FXdraw.rectRipple,
		t=0,
		rate=1/duration,
		x=x,y=y,w=w,h=h,
	}
end
function sysFX.newShade(duration,r,g,b,x,y,w,h)
	fx[#fx+1]={
		update=FXupdate.shade,
		draw=FXdraw.shade,
		t=0,
		rate=1/duration,
		r=r,g=g,b=b,
		x=x,y=y,w=w,h=h,
	}
end
return sysFX