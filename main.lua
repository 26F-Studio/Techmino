lib={
	gc=love.graphics,
	kb=love.keyboard,
	ms=love.mouse,
	tc=love.touch,
	tm=love.timer,
	fs=love.filesystem,
	wd=love.window,
	mt=love.math,
	sys=love.system,
}for k,v in pairs(lib)do _G[k]=v end lib=nil
toN,toS=tonumber,tostring
int,ceil,abs,rnd,max,min,sin,cos,atan,pi=math.floor,math.ceil,math.abs,math.random,math.max,math.min,math.sin,math.cos,math.atan,math.pi
sub,gsub,find,format,byte,char=string.sub,string.gsub,string.find,string.format,string.byte,string.char
ins,rem,sort=table.insert,table.remove,table.sort
null=function()end

ww,wh=gc.getWidth(),gc.getHeight()
Timer=tm.getTime--Easy&Quick to get time!
mx,my,mouseShow=-20,-20,false
xOy=love.math.newTransform()
focus=true

system=sys.getOS()
touching=nil--1st touching ID

scene=""
bgmPlaying=nil
curBG="none"
BGblock={ct=150,next=7}

kb.setKeyRepeat(false)
kb.setTextInput(false)
ms.setVisible(false)

Fonts={}
function setFont(s)
	if s~=currentFont then
		if Fonts[s]then
			gc.setFont(Fonts[s])
		else
			local t=gc.setNewFont("font.ttf",s-5)
			Fonts[s]=t
			gc.setFont(t)
		end
		currentFont=s
	end
end

gameEnv0={
	das=10,arr=2,
	sddas=0,sdarr=2,
	ghost=true,center=true,bone=false,
	drop=30,lock=45,
	wait=1,fall=1,
	next=6,hold=true,oncehold=true,
	sequence="bag7",
	block=true,visible="show",
	_20G=false,target=1e99,
	freshLimit=1e99,
	ospin=true,
	reach=null,
	bg="none",
	bgm="race"
}
customSel={
	drop=20,
	lock=20,
	wait=1,
	fall=1,
	next=7,
	hold=1,
	sequence=1,
	visible=1,
	target=4,
	freshLimit=3,
	opponent=1,
}
loadmode={
	sprint=function()
		createPlayer(1,340,15)
	end,
	marathon=function()
		createPlayer(1,340,15)
	end,
	classic=function()
		createPlayer(1,340,15)
	end,
	zen=function()
		createPlayer(1,340,15)
	end,
	infinite=function()
		createPlayer(1,340,15)
	end,
	solo=function()
		createPlayer(1,340,15)
		createPlayer(2,965,360,.5,customRange.opponent[3*curMode.lv])
	end,
	tsd=function()
		createPlayer(1,340,15)
	end,
	blind=function()
		createPlayer(1,340,15)
	end,
	dig=function()
		createPlayer(1,340,15)
		local P=players[1]
		if curMode.lv==1 then
			ins(players[1].task,Event.task.dig_normal)
			pushSpeed=1
		elseif curMode.lv==2 then
			ins(players[1].task,Event.task.dig_lunatic)
			pushSpeed=1
		end
	end,
	survivor=function()
		createPlayer(1,340,15)
		local P=players[1]
		ins(players[1].task,Event.task[curMode.lv==1 and"survivor_easy"or curMode.lv==2 and"survivor_normal"or curMode.lv==3 and"survivor_hard"or curMode.lv==4 and"survivor_lunatic"])
		pushSpeed=curMode.lv>2 and 2 or 1
	end,
	tech=function()
		createPlayer(1,340,15)
	end,
	pctrain=function()
		createPlayer(1,340,15)
		P=players[1]
		Event.newPC()
		P.freshNext()
	end,
	pcchallenge=function()
		createPlayer(1,340,15)
	end,
	techmino41=function()
		createPlayer(1,340,15)--Player
		if curMode.lv==5 then players[1].gameEnv.drop=15 end
		local n,min,max=2
		if curMode.lv==1 then min,max=5,30
		elseif curMode.lv==2 then min,max=3,25
		elseif curMode.lv==3 then min,max=2,20
		elseif curMode.lv==4 then min,max=2,10
		elseif curMode.lv==5 then min,max=1,6
		end
		for i=1,4 do for j=1,5 do
			createPlayer(n,77*i-55,140*j-125,.2,rnd(min,max))
			n=n+1
		end end
		for i=9,12 do for j=1,5 do
			createPlayer(n,77*i+275,140*j-125,.2,rnd(min,max))
			n=n+1
		end end
		--AIs

	end,
	techmino99=function()
		createPlayer(1,340,15)--Player
		if curMode.lv==5 then players[1].gameEnv.drop=15 end
		local n,min,max=2
		if curMode.lv==1 then min,max=5,32
		elseif curMode.lv==2 then min,max=3,25
		elseif curMode.lv==3 then min,max=2,18
		elseif curMode.lv==4 then min,max=2,12
		elseif curMode.lv==5 then min,max=1,12
		end
		for i=1,7 do for j=1,7 do
			createPlayer(n,46*i-36,97*j-72,.135,rnd(min,max))
			n=n+1
		end end
		for i=15,21 do for j=1,7 do
			createPlayer(n,46*i+264,97*j-72,.135,rnd(min,max))
			n=n+1
		end end
		--AIs

	end,
	drought=function()
		createPlayer(1,340,15)
	end,
	hotseat=function()
		if curMode.lv==1 then
			createPlayer(1,20,15)
			createPlayer(2,650,15)
		elseif curMode.lv==2 then
			createPlayer(1,20,100,.65)
			createPlayer(2,435,100,.65)
			createPlayer(3,850,100,.65)
		elseif curMode.lv==3 then
			createPlayer(1,25,160,.5)
			createPlayer(2,335,160,.5)
			createPlayer(3,645,160,.5)
			createPlayer(4,955,160,.5)
		end
	end,
	custom=function()
		for i=1,#customID do
			local k=customID[i]
			modeEnv[k]=customRange[k][customSel[k]]
		end
		modeEnv._20G=modeEnv.drop==-1
		if modeEnv.opponent==0 then
			createPlayer(1,340,15)
		else
			modeEnv.target=nil
			createPlayer(1,20,15)
			createPlayer(2,660,85,.9,modeEnv.opponent)
		end
	end,
}
mesDisp={
	--Default:font=35,white
	sprint=function()
		setFont(70)
		mStr(max(P.gameEnv.target-P.cstat.row,0),-75,260)
	end,
	marathon=function()
		setFont(50)
		mStr(P.cstat.row,-75,320)
		mStr(P.gameEnv.target,-75,370)
		gc.rectangle("fill",-120,376,90,4)
	end,
	classic=function()
		setFont(80)
		local r=P.gameEnv.target*.1
		mStr(r<11 and 19+r or r==11 and"00"or r==12 and"0a"or format("%x",r*10-110),-75,210)
		setFont(20)
		mStr("speed level",-75,290)
		setFont(50)
		mStr(P.cstat.row,-75,320)
		mStr(P.gameEnv.target,-75,370)
		gc.rectangle("fill",-120,376,90,4)
	end,
	zen=function()
		setFont(75)
		mStr(max(200-P.cstat.row,0),-75,280)
	end,
	infinite=function()
		setFont(50)
		mStr(P.cstat.atk,-75,310)
		mStr(format("%.2f",2.5*P.cstat.atk/P.cstat.piece),-75,420)
		setFont(20)
		mStr("Attack",-75,363)
		mStr("Efficiency",-75,475)
	end,
	tsd=function()
		setFont(35)
		mStr("TSD",-75,405)
		setFont(80)
		mStr(P.cstat.event,-75,330)
	end,
	blind=function()
		setFont(25)
		mStr("Rows",-75,300)
		mStr("Techrash",-75,420)
		setFont(80)
		mStr(P.cstat.row,-75,220)
		mStr(P.cstat.techrash,-75,340)
	end,
	dig=function()
		setFont(70)
		mStr(P.cstat.event,-75,310)
		setFont(30)
		mStr("Wave",-75,375)
	end,
	survivor=function()
		setFont(70)
		mStr(P.cstat.event,-75,310)
		setFont(30)
		mStr("Wave",-75,375)
	end,
	pctrain=function()
		setFont(25)
		mStr("Perfect Clear",-75,410)
		setFont(80)
		mStr(P.cstat.pc,-75,330)
	end,
	pcchallenge=function()
		setFont(25)
		mStr("Perfect Clear",-75,430)
		setFont(80)
		mStr(P.cstat.pc,-75,350)
		setFont(50)
		mStr(max(100-P.cstat.row,0),-75,250)
	end,
	techmino41=function()
		setFont(40)
		mStr(#players.alive.."/41",-75,175)
		mStr(P.ko,-60,215)
		setFont(25)
		gc.print("KO",-115,225)
		gc.setColor(1,.5,0,.6)
		gc.print(P.badge,-35,227)
		gc.setColor(1,1,1)
		setFont(30)
		gc.print(up0to4[P.strength],-125,290)
		for i=1,P.strength do
			gc.draw(badgeIcon,16*i-130,260)
		end
	end,
	techmino99=function()
		setFont(40)
		mStr(#players.alive.."/99",-75,175)
		mStr(P.ko,-60,215)
		setFont(25)
		gc.print("KO",-115,225)
		gc.setColor(1,.5,0,.6)
		gc.print(P.badge,-35,227)
		gc.setColor(1,1,1)
		setFont(30)
		gc.print(up0to4[P.strength],-125,290)
		for i=1,P.strength do
			gc.draw(badgeIcon,16*i-130,260)
		end
	end,
	drought=function()
		setFont(75)
		mStr(max(100-P.cstat.row,0),-75,280)
	end,
	custom=function()
		if P.gameEnv.target<1e4 then
			setFont(75)
			mStr(max(P.gameEnv.target-P.cstat.row,0),-75,280)
		end
	end
}
--Game system Data
setting={
	lang=1,
	sfx=true,bgm=true,vib=3,
	fullscreen=false,
	bgblock=true,
	das=10,arr=2,
	sddas=0,sdarr=2,
	ghost=true,center=true,
	keyMap={
		{"left","right","x","z","c","up","down","space","tab","r","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"dpleft","dpright","a","b","y","dpup","dpdown","rightshoulder","x","leftshoulder","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
		{"","","","","","","","","","","","",""},
	},--keyboard & joystick
	keyLib={
		{1},
		{2},
		{3},
		{4},
	},--Players' key setting(s)
	virtualkey={
		{80,720-80,6400,80},--moveLeft
		{240,720-80,6400,80},--moveRight
		{1280-240,720-80,6400,80},--rotRight
		{1280-400,720-80,6400,80},--rotLeft
		{1280-240,720-240,6400,80},--rotFlip
		{1280-80,720-80,6400,80},--hardDrop
		{1280-80,720-240,6400,80},--softDrop
		{1280-80,720-400,6400,80},--hold
		{80,80,6400,80},--restart
	},
	virtualkeyAlpha=3,
	virtualkeyIcon=true,
	virtualkeySwitch=false,
	frameMul=100,
}
stat={
	run=0,
	game=0,
	gametime=0,
	piece=0,
	row=0,
	atk=0,
	key=0,
	hold=0,
	rotate=0,
	spin=0,
}
virtualkey={
	{80,720-80,6400,80},--moveLeft
	{240,720-80,6400,80},--moveRight
	{1280-240,720-80,6400,80},--rotRight
	{1280-400,720-80,6400,80},--rotLeft
	{1280-240,720-240,6400,80},--rotFlip
	{1280-80,720-80,6400,80},--hardDrop
	{1280-80,720-240,6400,80},--softDrop
	{1280-80,720-400,6400,80},--hold
	{80,360,6400,80},--swap
	{80,80,6400,80},--restart
	--[[
	{x=0,y=0,r=0},--toLeft
	{x=0,y=0,r=0},--toRight
	{x=0,y=0,r=0},--toDown
	]]

}
virtualkeyDown={false,false,false,false,false,false,false,false,false,false,false,false,false}
virtualkeyPressTime={0,0,0,0,0,0,0,0,0,0,0,0,0}
--User Data&User Setting
require("toolfunc")
userData=fs.newFile("userdata")
userSetting=fs.newFile("usersetting")
if fs.getInfo("userdata")then
	loadData()
end
if fs.getInfo("usersetting")then
	loadSetting()
elseif system=="Android" or system=="iOS"then
	setting.virtualkeySwitch=true
end

require("gamefunc")
require("ai")
require("timer")
require("paint")
require("call&sys")
require("largeList")
require("list")
swapLanguage(setting.lang)
require("texture")