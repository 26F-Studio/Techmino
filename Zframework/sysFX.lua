local gc=love.graphics
local setColor=gc.setColor
local setWidth=gc.setLineWidth
local ins,rem=table.insert,table.remove

local fx={}

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
function FXupdate.attack(S,dt)
	S.t=S.t+dt
	local L=S.drag
	if S.t>.8 then
		S.rad=S.rad*1.05+.1
		S.x,S.y=S.x2,S.y2
	elseif S.t>.2 then
		local t=(S.t-.2)*1.6667
		t=(3-2*t)*t*t
		S.x,S.y=S.x1*(1-t)+S.x2*t,S.y1*(1-t)+S.y2*t

		ins(L,S.x)ins(L,S.y)
	end
	if #L==4+4*setting.atkFX then
		rem(L,1)rem(L,1)
	end
return S.t>1
end
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
function FXdraw.badge(S)
	gc.setColor(1,1,1,S.t<.2 and S.t*.6 or S.t<.8 and 1 or(1-S.t)*.6)
	gc.draw(IMG.badgeIcon,S.x,S.y)
end
function FXdraw.attack(S)
	gc.setLineWidth(5)
	gc.push("transform")
		local t=S.t
		local a=(t<.2 and t*5 or t<.8 and 1 or 5-t*5)*S.a
		local L=S.drag
		local len=#L
		local r,g,b=S.r,S.g,S.b
		local rad,crn=S.rad,S.corner
		for i=1,len,2 do
			gc.setColor(r,g,b,.4*a*i/len)
			gc.translate(L[i],L[i+1])
			gc.rotate(t*.1)
			gc.circle("fill",0,0,rad,crn)
			gc.rotate(-t*.1)
			gc.translate(-L[i],-L[i+1])
		end
		gc.translate(S.x,S.y)
		gc.rotate(t*6)
		gc.setColor(r,g,b,a*.5)gc.circle("line",0,0,rad,crn)
		gc.setColor(r,g,b,a)gc.circle("fill",0,0,rad,crn)
	gc.pop()
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

function sysFX.newBadge(x1,y1,x2,y2)
	fx[#fx+1]={
		update=FXupdate.badge,
		draw=FXdraw.badge,
		t=0,
		x=x1,y=y1,
		x1=x1,y1=y1,
		x2=x2,y2=y2,
	}
end
function sysFX.newAttack(x1,y1,x2,y2,rad,corner,type,r,g,b,a)
	fx[#fx+1]={
		update=FXupdate.attack,
		draw=FXdraw.attack,
		t=0,
		x=x1,y=y1,
		x1=x1,y1=y1,--Start pos
		x2=x2,y2=y2,--End pos
		rad=rad,
		corner=corner,
		type=type,
		r=r,g=g,b=b,a=a,
		drag={},--Afterimage coordinate list
	}
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