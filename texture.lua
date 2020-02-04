local gc=love.graphics
local N=gc.newImage
local int=math.floor
local function T(s,t)return gc.newText(setFont(s),t)end
local function C(x,y)
	local c=gc.newCanvas(x,y)
	gc.setCanvas(c)
	return c
end
local c

gc.setDefaultFilter("nearest","nearest")
blockImg=N("/image/block.png")
blockSkin,blockSkinmini={},{}
for i=1,13 do
	blockSkin[i]=C(30,30)
	blockSkinmini[i]=C(6,6)
end

local VKI=N("/image/virtualkey.png")
VKIcon={}
for i=1,#actName do
	VKIcon[i]=C(36,36)
	gc.draw(VKI,(i-1)%5*-36,int((i-1)*.2)*-36)
end

gc.setColor(1,1,1)
miniBlock={}
for i=1,7 do
	local b=blocks[i][0]
	miniBlock[i]=C(#b[1],#b)
	gc.setColor(blockColor[i])
	for y=1,#b do for x=1,#b[1]do
		if b[y][x]then
			gc.rectangle("fill",x-1,#b-y,1,1)
		end
	end end
end

puzzleMark={}
gc.setLineWidth(3)
for i=1,13 do
	puzzleMark[i]=C(30,30)
	if i>7 then
		gc.setColor(blockColor[i])
		gc.rectangle("line",7,7,16,16)
	else
		local c=blockColor[i]
		gc.setColor(c[1],c[2],c[3],.6)
		gc.rectangle("line",5,5,20,20)
		gc.rectangle("line",10,10,10,10)
	end
end
c=C(30,30)
gc.setColor(1,1,1)
gc.line(5,5,25,25)
gc.line(5,25,25,5)
puzzleMark[-1]=C(30,30)
gc.setColor(1,1,1,.9)
gc.draw(c)
c:release()

PTC={dust={}}--Particle systems
c=C(6,6)
gc.clear(1,1,1)
PTC.dust0=gc.newParticleSystem(c,1000)
c:release()
PTC.dust0:setParticleLifetime(.2,.3)
PTC.dust0:setEmissionRate(0)
PTC.dust0:setLinearAcceleration(-1500,-200,1500,200)
PTC.dust0:setColors(1,1,1,.5,1,1,1,0)
--Dust particles

gc.setDefaultFilter("linear","linear")
titleImage=N("/image/mess/title.png")
coloredTitleImage=N("/image/mess/title_colored.png")
dialCircle=N("/image/mess/dialCircle.png")
dialNeedle=N("/image/mess/dialNeedle.png")
badgeIcon=N("/image/mess/badge.png")
spinCenter=N("/image/mess/spinCenter.png")
batteryImage=N("/image/mess/power.png")

background1=N("/image/BG/bg1.jpg")
background2=N("/image/BG/bg2.png")
groupCode=N("/image/mess/groupcode.png")
payCode=N("/image/mess/paycode.png")
drawableText={
	question=T(100,"?"),
	bpm=T(15,"BPM"),kpm=T(15,"KPM"),
	speedLV=T(20,"speed level"),
	atk=T(20,"Attack"),
	eff=T(20,"Efficiency"),
	tsd=T(35,"TSD"),
	line=T(25,"Lines"),
	techrash=T(25,"Techrash"),
	grade=T(25,"Grade"),
	wave=T(30,"Wave"),
	rpm=T(35,"RPM"),
	nextWave=T(30,"Next"),
	combo=T(20,"Combo"),
	mxcmb=T(20,"Max Combo"),
	pc=T(20,"Perfect Clear"),
	ko=T(25,"KO"),

	modeName=T(30),levelName=T(30),
	next=T(40),hold=T(40),

	win=T(120),finish=T(120),
	lose=T(120),pause=T(120),

	custom=T(80),
	setting_game=T(80),setting_graphic=T(80),setting_sound=T(80),
	keyboard=T(25),joystick=T(25),
	ctrlSetHelp=T(30),
	musicRoom=T(80),
	nowPlaying=T(50),
	warning=T(30),
	VKTchW=T(30),
	VKOrgW=T(30),
	VKCurW=T(30),
}
gc.setCanvas()