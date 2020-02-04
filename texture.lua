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

gc.setDefaultFilter("linear","linear")
titleImage=N("/image/mess/title.png")
coloredTitleImage=N("/image/mess/title_colored.png")
dialCircle=N("/image/mess/dialCircle.png")
dialNeedle=N("/image/mess/dialNeedle.png")
badgeIcon=N("/image/mess/badge.png")
spinCenter=N("/image/mess/spinCenter.png")
batteryImage=N("/image/mess/power.png")
chargeImage=N("/image/mess/charge.png")

background1=N("/image/BG/bg1.jpg")
background2=N("/image/BG/bg2.png")
groupCode=N("/image/mess/groupcode.png")
payCode=N("/image/mess/paycode.png")
drawableText={
	question=T(100,"?"),
	bpm=T(15,"BPM"),kpm=T(15,"KPM"),

	modeName=T(30),levelName=T(30),
	next=T(40),hold=T(40),
	pause=T(120),finish=T(120),
	custom=T(80),
	keyboard=T(25),joystick=T(25),
	setting2Help=T(25),
	musicRoom=T(80),
	nowPlaying=T(50),
	warning=T(30),
}
c=gc.setCanvas()