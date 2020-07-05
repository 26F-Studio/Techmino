local gc=love.graphics
local setColor=gc.setColor
local setWidth=gc.setLineWidth
local rect=gc.rectangle

local fx={}

local FXdraw={}
function FXdraw.ripple(S)
	setWidth(6)
	setColor(1,1,1,1-S.t)
	local r=(10*S.t)^1.2
	rect("line",S[1]-r,S[2]-r,S[3]+2*r,S[4]+2*r)
end
function FXdraw.shade(S)
	setColor(S[1],S[2],S[3],1-S.t)
	rect("fill",S[4],S[5],S[6],S[7],2)
end

local sysFX={}
function sysFX.update(dt)
	for i=#fx,1,-1 do
		local S=fx[i]
		S.t=S.t+dt*S.rate
		if S.t>=1 then
			for i=i,#fx do
				fx[i]=fx[i+1]
			end
		end
	end
end
function sysFX.draw()
	for i=1,#fx do
		fx[i]:draw()
	end
end
--0=ripple,x,y,w,h
--1=shade,r,g,b,x,y,w,h
function sysFX.new(type,duration,...)
	fx[#fx+1]={draw=FXdraw[type],t=0,rate=1/duration,...}
end
return sysFX