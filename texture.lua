local gc=love.graphics
local N,c=gc.newImage
local function T(s,t)return gc.newText(setFont(s),t)end
local function C(x,y)
	c=gc.newCanvas(x,y)
	gc.setCanvas(c)
	return c
end

gc.setDefaultFilter("nearest","nearest")
blockImg=N("/image/block.png")
blockSkin,blockSkinmini={},{}
for i=1,13 do
	blockSkin[i]=C(30,30)
	blockSkinmini[i]=C(6,6)
end

virtualkeyIcon={}
for i=1,10 do
	virtualkeyIcon[i]=N("/image/virtualkey/"..actName[i]..".png")
end

gc.setColor(1,1,1)
mouseBlock={}
for i=1,7 do
	local b=blocks[i][0]
	mouseBlock[i]=C(#b[1],#b)
	gc.setColor(blockColor[i])
	for y=1,#b do for x=1,#b[1]do
		if b[y][x]then
			gc.rectangle("fill",x-1,#b-y,1,1)
		end
	end end
end

PTC={dust={}}--Particle systems
C(6,6)
gc.clear(1,1,1)
PTC.dust0=gc.newParticleSystem(c,1000)
PTC.dust0:setParticleLifetime(.2,.3)
PTC.dust0:setEmissionRate(0)
PTC.dust0:setLinearAcceleration(-1500,-200,1500,200)
PTC.dust0:setColors(1,1,1,.5,1,1,1,0)
c:release()
--Dust particles

PTC.attack={}
PTC.attack[1]=gc.newParticleSystem(N("/image/mess/atk1.png"),200)
PTC.attack[1]:setParticleLifetime(.25)
PTC.attack[1]:setEmissionRate(0)
PTC.attack[1]:setSpin(10)
PTC.attack[1]:setColors(1,1,1,.7,1,1,1,0)

PTC.attack[2]=gc.newParticleSystem(N("/image/mess/atk2.png"),200)
PTC.attack[2]:setParticleLifetime(.3)
PTC.attack[2]:setEmissionRate(0)
PTC.attack[2]:setSpin(8)
PTC.attack[2]:setColors(1,1,1,.7,1,1,1,0)

PTC.attack[3]=gc.newParticleSystem(N("/image/mess/atk3.png"),200)
PTC.attack[3]:setParticleLifetime(.4)
PTC.attack[3]:setEmissionRate(0)
PTC.attack[3]:setSpin(6)
PTC.attack[3]:setColors(1,1,1,.7,1,1,1,0)
--Attack particles

gc.setDefaultFilter("linear","linear")
titleImage=N("/image/mess/title.png")
dialCircle=N("/image/mess/dialCircle.png")
dialNeedle=N("/image/mess/dialNeedle.png")
badgeIcon=N("/image/mess/badge.png")
spinCenter=N("/image/mess/spinCenter.png")
lightBulb=N("/image/mess/lightBulb.png")
light=N("/image/mess/light.png")

background1=N("/image/BG/bg1.jpg")
background2=N("/image/BG/bg2.png")
groupCode=N("/image/mess/groupcode.png")
payCode=N("/image/mess/paycode.png")
drawableText={
	question=T(100,"?"),
	x=T(110,"×"),
	bpm=T(15,"BPM"),
	kpm=T(15,"KPM"),

	modeName=T(30),levelName=T(30),
	next=T(40),hold=T(40),
	pause=T(120),
	custom=T(80),
	keyboard=T(25),joystick=T(25),
	setting2Help=T(25),
}
c=gc.setCanvas()