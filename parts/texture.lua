local gc=love.graphics
local N=gc.newImage
local int=math.floor
local function T(s,t)return gc.newText(setFont(s),t)end
local function C(x,y)
	local _=gc.newCanvas(x,y)
	gc.setCanvas(_)
	return _
end
local c

gc.setDefaultFilter("nearest","nearest")
gc.setColor(1,1,1)
local VKI=N("/image/virtualkey.png")
VKIcon={}
for i=1,20 do
	VKIcon[i]=C(36,36)
	gc.draw(VKI,(i-1)%5*-36,int((i-1)*.2)*-36)
end

miniBlock={}
for i=1,25 do
	local b=blocks[i][0]
	miniBlock[i]=C(#b[1],#b)
	for y=1,#b do for x=1,#b[1]do
		if b[y][x]then
			gc.rectangle("fill",x-1,#b-y,1,1)
		end
	end end
end

mapCross=C(40,40)
gc.setColor(1,1,1)
gc.setLineWidth(4)
gc.line(0,20,40,20)
gc.line(20,0,20,40)

gc.setDefaultFilter("linear","linear")

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
	D=T(100,"D"),
	C=T(100,"C"),
	B=T(100,"B"),
	A=T(100,"A"),
	S=T(100,"S"),


	modeName=T(30),levelName=T(30),


	anykey=T(40),
	next=T(40),hold=T(40),
	win=T(120),finish=T(120),
	lose=T(120),pause=T(120),

	custom=T(80),sequence=T(80),
	setting_game=T(80),setting_video=T(80),setting_sound=T(80),
	setting_control=T(70),setting_skin=T(70),
	preview=T(40),
	keyboard=T(25),joystick=T(25),
	ctrlSetHelp=T(30),
	musicRoom=T(80),
	nowPlaying=T(50),
	VKTchW=T(30),VKOrgW=T(30),VKCurW=T(30),
	noScore=T(45),
	highScore=T(30),
}
gc.setCanvas()