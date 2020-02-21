local gc=love.graphics
local sin,cos,rnd,min=math.sin,math.cos,math.random,math.min

local W,H,R--w,h+=100,r=real Radius
local stars={}
local planet={}

local function newPlanet()
	local a=rnd()*3.142
	local r=(H+W)*(2+rnd())*.05
	planet.r=r
	planet.x=W*.5+cos(a)*(R+r)
	planet.y=H*.5+sin(a)*(R+r)
	planet.vx=-cos(a+rnd()-.5)*.0626
	planet.vy=-sin(a+rnd()-.5)*.0626
	planet.R=.7+rnd()*.2
	planet.G=.7+rnd()*.1
end

local space={}--LIB
function space.resize(w,h)
	R=((w*.5)^2+(h*.5)^2)^.5
	W,H=w+100,h+100
end
function space.new()
	if not W then space.resize(scr.w,scr.h)end
	newPlanet()
	for i=1,2600,5 do
		local s=0.75*2^(rnd()*1.5)
		stars[i]=s					--size
		stars[i+1]=rnd(W)			--x
		stars[i+2]=rnd(H)			--y
		stars[i+3]=(rnd()-.5)*.05*s	--vx
		stars[i+4]=(rnd()-.5)*.05*s	--vy
	end--800 stars
end
function space.translate(dx,dy)
	planet.x=planet.x+dx*.26
	planet.y=planet.y+dy*.26
	for i=1,2600,5 do
		local s=stars[i]
		stars[i+1]=stars[i+1]+dx*s
		stars[i+2]=stars[i+2]+dy*s
	end
end
function space.scale(k)
	planet.r=planet.r*k^.15
	for i=1,2600,5 do
		local s=stars[i]
		local x=stars[i+1]
		local y=stars[i+2]
		s=s*k
		x=W*.5+(x-W*.5)*k
		y=H*.5+(y-H*.5)*k
		if k>1 then
			if x%W~=x or y%H~=y then
				s=.75
				x=W*.5+(rnd()-.5)*W*.5
				y=H*.5+(rnd()-.5)*H*.5
			end
			--out,new small one
		elseif s<.75 then
			local vx,vy
			repeat
				s=rnd()*.75+2.25
				stars[i]=s			--size
				x=rnd(W)			--x
				y=rnd(H)			--y
				vx=(rnd()-.5)*.15	--vx
				vy=(rnd()-.5)*.15	--vy
			until x<100 or x>W-100 or y<100 or y>H-100
			stars[i+3]=vx
			stars[i+4]=vy
			--disappear,new big one
		end
		stars[i]=s
		stars[i+1]=x
		stars[i+2]=y
	end
end
function space.update(dt)
	local x,y=planet.x,planet.y
	planet.x=planet.x+planet.vx
	planet.y=planet.y+planet.vy
	if((planet.x-W*.5)^2+(planet.y-H*.5)^2)^.5>R+planet.r then
		newPlanet()
	end
	for i=1,2600,5 do
		stars[i+1]=(stars[i+1]+stars[i+3])%W
		stars[i+2]=(stars[i+2]+stars[i+4])%H
	end--stars moving
end
function space.draw()
	if not stars[1]then return end
	gc.translate(-50,-50)
	gc.setLineWidth(7)
	gc.setColor(planet.R,planet.G,.6,.2)
	gc.circle("line",planet.x,planet.y,planet.r+1)
	gc.setColor(planet.R,planet.G,.6,.5)
	gc.circle("fill",planet.x,planet.y,planet.r)
	gc.setColor(.9,.9,.9)
	for i=1,2600,5 do
		local x,y=stars[i+1],stars[i+2]
		gc.circle("fill",x,y,stars[i])
	end
	gc.translate(50,50)
end
function space.discard()
	stars={}
	planet={}
	collectgarbage()
end
return space