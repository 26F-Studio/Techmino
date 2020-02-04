local gc=love.graphics
local int,ceil,abs,rnd,max,min=math.floor,math.ceil,math.abs,math.random,math.max,math.min
local ins,rem=table.insert,table.remove
local null=function()end
local gameEnv0={
	das=10,arr=2,
	sddas=2,sdarr=2,
	ghost=true,center=true,
	grid=false,swap=true,
	_20G=false,bone=false,
	drop=60,lock=60,
	wait=0,fall=0,
	next=6,hold=true,oncehold=true,
	sequence="bag7",

	block=true,
	visible="show",--keepVisible=visile~="show"
	Fkey=null,puzzle=false,ospin=true,
	freshLimit=1e99,easyFresh=true,
	target=1e99,dropPiece=null,
	bg="none",bgm="race"
}
local renATK={[0]=0,0,0,1,1,2,2,3,3,4,4}--3 else
local b2bPoint={50,100,180}
local b2bATK={3,5,8}
local clearSCR={80,200,400}
local spinSCR={--[blockName][row]
	{200,750,1600},--Z
	{200,750,1600},--S
	{220,700,1600},--L
	{220,700,1600},--J
	{250,800,1500},--T
	{300,1000,2200},--O
	{300,1000,1800},--I
}--MUL:1.2,2.0
--Techrash:1K;MUL:1.3,1.8
--Mini*=.5
local visible_opt={show=1e99,time=300,fast=20,none=5}
local reAtk={0,0,1,1,1,2,2,3,3}
local reDef={0,1,1,2,3,3,4,4,5}
local blockName={"Z","S","L","J","T","O","I"}
local clearName={"single","double","triple"}
local spin_n={[0]="spin_0","spin_1","spin_2","spin_3"}
local clear_n={"clear_1","clear_2","clear_3","clear_4"}
local ren_n={}for i=1,11 do ren_n[i]="ren_"..i end
local blockPos={4,4,4,4,4,5,4}
local scs={
	{[0]={1,2},{2,1},{2,2},{2,2}},
	{[0]={1,2},{2,1},{2,2},{2,2}},
	{[0]={1,2},{2,1},{2,2},{2,2}},
	{[0]={1,2},{2,1},{2,2},{2,2}},
	{[0]={1,2},{2,1},{2,2},{2,2}},
	{[0]={1.5,1.5},{1.5,1.5},{1.5,1.5},{1.5,1.5},},
	{[0]={0.5,2.5},{2.5,0.5},{1.5,2.5},{2.5,1.5}},
}
local ORG={0,0}
local TRS={
	[1]={
		[01]={ORG,{-1,0},	{-1,1},	{0,-2},	{-1,-2},{0,1}	},
		[10]={ORG,{1,0},	{1,-1},	{0,2},	{1,2},	{0,-1}	},
		[03]={ORG,{1,0},	{1,1},	{0,-2},	{1,-1},	{1,-2}	},
		[30]={ORG,{-1,0},	{-1,-1},{0,2},			{-1,2},	{0,-1}},
		[12]={ORG,{1,0},	{1,-1},	{0,2},	{1,2}	},
		[21]={ORG,{-1,0},	{-1,1},	{0,-2},	{-1,-2}	},
		[32]={ORG,{-1,0},	{-1,-1},{0,2},	{-1,2}	},
		[23]={ORG,{1,0},	{1,1},	{0,-2},	{1,-2}	},
		[02]={ORG,{1,0},	{-1,0},	{0,-1},	{0,1}	},
		[20]={ORG,{-1,0},	{1,0},	{0,1},	{0,-1}	},
		[13]={ORG,{0,-1},	{0,1},	{-1,0},	{0,-2}	},
		[31]={ORG,{0,1},	{0,-1},	{1,0},	{0,2}	},
	},--Z
	[2]={
		[01]={ORG,{-1,0},	{-1,1},	{0,-2},	{-1,-1},{-1,-2}	},
		[10]={ORG,{1,0},	{1,-1},	{0,2},			{1,2},	{0,-1}},
		[03]={ORG,{1,0},	{1,1},	{0,-2},	{1,-2},	{0,1}	},
		[30]={ORG,{-1,0},	{-1,-1},{0,2},	{-1,2},	{0,-1}	},
		[12]={ORG,{1,0},	{1,-1},	{0,2},	{1,2}	},
		[21]={ORG,{-1,0},	{-1,1},	{0,-2},	{-1,-2}	},
		[32]={ORG,{-1,0},	{-1,-1},{0,2},	{-1,2}	},
		[23]={ORG,{1,0},	{1,1},	{0,-2},	{1,-2}	},
		[02]={ORG,{-1,0},	{1,0},	{0,-1},	{0,1}	},
		[20]={ORG,{1,0},	{-1,0},	{0,1},	{0,-1}	},
		[13]={ORG,{0,1},	{0,-1},	{-1,0},	{0,2}	},
		[31]={ORG,{0,-1},	{0,1},	{1,0},	{0,-2}	},
	},--S
	[3]={
		[01]={ORG,{-1,0},	{-1,1},	{0,-2},	{-1,-2},{0,1},	{-1,-1}	},
		[10]={ORG,{1,0},	{1,-1},	{0,2},	{1,2},	{0,-1},	{1,1}	},
		[03]={ORG,{1,0},	{1,1},	{0,-2},	{-1,1}	},
		[30]={ORG,{-1,0},	{-1,-1},{0,2},	{-1,2}	},
		[12]={ORG,{1,0},	{1,-1},	{0,2},	{1,2},	{1,1}	},
		[21]={ORG,{-1,0},	{-1,1},	{0,-2},	{-1,-2},{-1,-1}	},
		[32]={ORG,{-1,0},	{-1,-1},{1,0},	{0,2},	{-1,2}	},
		[23]={ORG,{1,0},	{1,1},	{-1,0},	{0,-2},	{1,-2}	},
		[02]={ORG,{1,0},	{-1,0},	{0,-1},	{0,1}	},
		[20]={ORG,{-1,0},	{1,0},	{0,1},	{0,-1}	},
		[13]={ORG,{0,1},	{1,0},	{0,-1}	},
		[31]={ORG,{0,-1},	{-1,0},	{0,1}	},
	},--L
	[4]={
		[01]={ORG,{-1,0},	{-1,1},	{0,-2},	{1,1}	},
		[10]={ORG,{1,0},	{1,-1},	{0,2},	{1,2}	},
		[03]={ORG,{1,0},	{1,1},	{0,-2},	{1,-2},	{0,1},	{1,-1}	},
		[30]={ORG,{-1,0},	{-1,-1},{0,2},	{-1,2},	{0,-1},	{-1,1}	},
		[12]={ORG,{1,0},	{1,-1},	{-1,0},	{0,2},	{1,2}	},
		[21]={ORG,{-1,0},	{-1,1},	{1,0},	{0,-2},	{-1,-2}	},
		[32]={ORG,{-1,0},	{-1,-1},{0,2},	{-1,2},	{-1,1}	},
		[23]={ORG,{1,0},	{1,1},	{0,-2},	{1,-2},	{1,-1}	},
		[02]={ORG,{-1,0},	{1,0},	{0,-1},	{0,1}	},
		[20]={ORG,{1,0},	{-1,0},	{0,1},	{0,-1}	},
		[13]={ORG,{0,-1},	{1,0},	{0,1}	},
		[31]={ORG,{0,1},	{-1,0},	{0,-1}	},
	},--J
	[5]={
		[01]={ORG,{-1,0},	{-1,1},	{0,-2},	{-1,-2},{-1,-1}	},
		[10]={ORG,{1,0},	{1,-1},	{0,2},	{1,2},	{0,-1},	{1,1}},
		[03]={ORG,{1,0},	{1,1},	{0,-2},	{1,-2}	},
		[30]={ORG,{-1,0},	{-1,-1},{0,2},	{-1,2},	{0,-1}	},
		[12]={ORG,{1,0},	{1,-1},	{0,-1},	{0,2},	{1,2},	{-1,-1}},
		[21]={ORG,{-1,0},	{-1,1},	{0,-2},	{-1,-2},{1,1}	},
		[32]={ORG,{-1,0},	{-1,-1},{0,-1},	{0,2},	{-1,2},	{1,-1}},
		[23]={ORG,{1,0},	{1,1},	{0,-2},	{1,-2},	{-1,1}	},
		[02]={ORG,{-1,0},	{1,0},	{0,1}	},
		[20]={ORG,{1,0},	{-1,0},	{0,-1}	},
		[13]={ORG,{0,-1},	{0,1},	{1,0},	{0,-2},	{0,2}},
		[31]={ORG,{0,-1},	{0,1},	{-1,0},	{0,-2},	{0,2}},
	},--T
	[6]={},--O(special)
	[7]={
		[01]={ORG,{0,1},	{1,0},	{-2,0},	{-2,-1},{1,2}	},
		[03]={ORG,{0,1},	{-1,0},	{2,0},	{2,-1},	{-1,2}	},
		[10]={ORG,{2,0},	{-1,0},	{-1,-2},{2,1},	{0,2}	},
		[30]={ORG,{-2,0},	{1,0},	{1,-2},	{-2,1},	{0,2}	},
		[12]={ORG,{-1,0},	{2,0},	{-1,2},	{2,-1}	},
		[32]={ORG,{1,0},	{-2,0},	{1,-2},	{-2,-1}	},
		[21]={ORG,{-2,0},	{1,0},	{1,-2},	{-2,1}	},
		[23]={ORG,{2,0},	{-1,0},	{-1,-2},{2,1}	},
		[02]={ORG,{-1,0},	{1,0},	{0,-1},	{0,1}	},
		[20]={ORG,{1,0},	{-1,0},	{0,1},	{0,-1}	},
		[13]={ORG,{0,-1},	{-1,0},	{1,0},	{0,1}	},
		[31]={ORG,{1,0},	{-1,0}},
	}
}
local AIRS={{
	[01]={ORG,{-1,0},	{-1,1},	{0,-2},	{-1,-2}	},
	[10]={ORG,{1,0},	{1,-1},	{0,2},	{1,2}	},
	[03]={ORG,{1,0},	{1,1},	{0,-2},	{1,-2}	},
	[30]={ORG,{-1,0},	{-1,-1},{0,2},	{-1,2}	},
	[12]={ORG,{1,0},	{1,-1},	{0,2},	{1,2}	},
	[21]={ORG,{-1,0},	{-1,1},	{0,-2},	{-1,-2}	},
	[32]={ORG,{-1,0},	{-1,-1},{0,2},	{-1,2}	},
	[23]={ORG,{1,0},	{1,1},	{0,-2},	{1,-2}	},
}}for i=2,6 do AIRS[i]=AIRS[1]end
AIRS[7]={
	[01]={ORG,{-2,0},	{1,0},	{-2,-1},{1,2}	},
	[10]={ORG,{2,0},	{-1,0},	{2,1},	{-1,-2}	},
	[12]={ORG,{-1,0},	{2,0},	{-1,2},	{2,-1}	},
	[21]={ORG,{1,0},	{-2,0},	{1,-2},	{-2,1}	},
	[23]={ORG,{2,0},	{-1,0},	{2,1},	{-1,-2}	},
	[32]={ORG,{-2,0},	{1,0},	{-2,-1},{1,2}	},
	[30]={ORG,{1,0},	{-2,0},	{1,-2},	{-2,1}	},
	[03]={ORG,{-1,0},	{2,0},	{-1,2},	{2,-1}	},
}
local CCblockID={4,3,5,6,1,2,0}
local function newNext(n)
	P.next[#P.next+1]={bk=blocks[n][0],id=n,color=P.gameEnv.bone and 8 or n,name=n}
end
local freshMethod={
	none=function()end,
	bag7=function()
		if #P.next<6 then
			local bag={1,2,3,4,5,6,7}
			::L::
				newNext(rem(bag,rnd(#bag)))
			if bag[1]then goto L end
		end
	end,
	his4=function()
		if #P.next<6 then
			local j,i=0
			repeat
				i,j=rnd(7),j+1
			until i~=P.his[1]and i~=P.his[2]and i~=P.his[3]and i~=P.his[4]
			newNext(i)
			rem(P.his,1)P.his[4]=i
		end
	end,
	rnd=function()
		local i
		::L::
			i=rnd(7)
		if i==P.next[5]then goto L end
		newNext(i)
	end,--random
	drought1=function()
		if #P.next<6 then
			local bag={1,2,3,4,5,6}
			::L::
				newNext(rem(bag,rnd(#bag)))
			if bag[1]then goto L end
		end
	end,
	drought2=function()
		if #P.next<6 then
			local bag={1,1,1,1,2,2,2,2,6,6,6,6,3,3,4,4,5,7}
			::L::
				newNext(rem(bag,rnd(#bag)))
			if bag[1]then goto L end
		end
	end,
}
local shadeColor={
	{1,0,0,.3},
	{0,1,0,.3},
	{1,.5,0,.3},
	{0,0,1,.3},
	{1,0,1,.3},
	{1,1,0,.3},
	{0,1,1,.3},
}
local function createShade(x1,y1,x2,y2)--x1<x2,y1>y2
	if P.gameEnv.block and y1>=y2 then
		P.shade[#P.shade+1]={5,P.cur.color,x1,y1,x2,y2}
	end
end
local function randomTarget(p)
	if #players.alive>1 then
		local r
		::L::
			r=players.alive[rnd(#players.alive)]
		if r==p then goto L end
		return r
	end
end
function freshTarget(P)
	if P.atkMode==1 then
		if not P.atking.alive or rnd()<.1 then
			changeAtk(P,randomTarget(P))
		end
	elseif P.atkMode==2 then
		changeAtk(P,P~=mostBadge and mostBadge or secBadge or randomTarget(P))
	elseif P.atkMode==3 then
		changeAtk(P,P~=mostDangerous and mostDangerous or secDangerous or randomTarget(P))
	elseif P.atkMode==4 then
		for i=1,#P.atker do
			if not P.atker[i].alive then
				rem(P.atker,i)
				return
			end
		end
	end
end
function changeAtkMode(m)
	if P.atkMode==m then return end
	P.atkMode=m
	if m==1 then
		changeAtk(P,randomTarget(P))
	elseif m==2 then
		freshTarget(P)
	elseif m==3 then
		freshTarget(P)
	elseif m==4 then
		changeAtk(P)
	end
	::L::
end
function changeAtk(P,R)
	-- if not P.human then R=players[1]end--1vALL mode
	if P.atking then
		local K=P.atking.atker
		for i=1,#K do
			if K[i]==P then
				rem(K,i)
				goto L
			end
		end
	end
	::L::
	if R then
		P.atking=R
		R.atker[#R.atker+1]=P
	else
		P.atking=nil
	end
end
function freshMostDangerous()
	mostDangerous,secDangerous=nil
	local m,m2=0,0
	for i=1,#players.alive do
		local h=#players.alive[i].field
		if h>=m then
			mostDangerous,secDangerous=players.alive[i],mostDangerous
			m,m2=h,m
		elseif h>=m2 then
			secDangerous=players.alive[i]
			m2=h
		end
	end
end
function freshMostBadge()
	mostBadge,secBadge=nil
	local m,m2=0,0
	for i=1,#players.alive do
		local h=players.alive[i].badge
		if h>=m then
			mostBadge,secBadge=players.alive[i],mostBadge
			m,m2=h,m
		elseif h>=m2 then
			secBadge=players.alive[i]
			m2=h
		end
	end
end
function royaleLevelup()
	gameStage=gameStage+1
	local spd
	if(gameStage==3 or gameStage>4)and players[1].alive then
		showText(players[1],text.royale_remain(#players.alive),"beat",50,-100,.3)
	end
	if gameStage==2 then
		spd=30
	elseif gameStage==3 then
		spd=15
		garbageSpeed=.6
		if players[1].alive then BGM("cruelty")end
	elseif gameStage==4 then
		spd=10
		pushSpeed=3
	elseif gameStage==5 then
		spd=5
		garbageSpeed=1
	elseif gameStage==6 then
		spd=3
		if players[1].alive then BGM("final")end
	end
	for i=1,#players.alive do
		local P=players.alive[i]
		P.gameEnv.drop=spd
	end
	if curMode.lv==3 then
		for i=1,#players.alive do
			local P=players.alive[i]
			P.gameEnv.drop=int(P.gameEnv.drop*.3)
			if P.gameEnv.drop==0 then
				P.curY=P.y_img
				P.gameEnv._20G=true
				if P.AI_mode=="CC"then CC_switch20G(P)end--little cheating,never mind
			end
		end
	end
end
function loadGame(mode,level)
	--rec={}
	curMode={id=modeID[mode],lv=level}
	drawableText.modeName:set(text.modeName[mode])
	drawableText.levelName:set(modeLevel[modeID[mode]][level])
	needResetGameData=true
	gotoScene("play","deck")
end
local function resetPartGameData()
	frame=30
	destroyPlayers()
	players={alive={}}human=0
	loadmode[curMode.id]()
	if modeEnv.task then
		for i=1,#players do
			newTask(Event_task[modeEnv.task],players[i])
		end
	end
	if modeEnv.royaleMode then
		for i=1,#players do
			changeAtk(players[i],randomTarget(players[i]))
		end
	end
	for i=1,#virtualkey do
		virtualkey[i].press=false
	end
	collectgarbage()
end
function resetGameData()
	gamefinished=false
	frame=0
	garbageSpeed=1
	pushSpeed=3
	pauseTime=0--Time paused
	pauseCount=0--Times paused
	destroyPlayers()
	players={alive={}}human=0
	local E=defaultModeEnv[curMode.id]
	modeEnv=E[curMode.lv]or E[1]
	loadmode[curMode.id]()--bg/bgm need redefine in custom,so up here
	if modeEnv.task then
		for i=1,#players do
			newTask(Event_task[modeEnv.task],players[i])
		end
	end
	curBG=modeEnv.bg
	BGM(modeEnv.bgm)

	FX_badge={}
	FX_attack={}
	for _,v in next,PTC.dust do
		v:release()
	end
	for i=1,#players do
		if not players[i].small then
			PTC.dust[i]=PTC.dust0:clone()
			PTC.dust[i]:start()
		end
	end
	if modeEnv.royaleMode then
		for i=1,#players do
			changeAtk(players[i],randomTarget(players[i]))
		end
		mostBadge,mostDangerous,secBadge,secDangerous=nil
		gameStage=1
		garbageSpeed=.3
		pushSpeed=2
	end
	for i=1,#virtualkey do
		virtualkey[i].press=false
	end
	stat.game=stat.game+1
	local m,p=#freeRow,40*#players+1
	while freeRow[p]do
		m,freeRow[m]=m-1
	end
	freeRow.L=#freeRow
	SFX("ready")
	collectgarbage()
end
function gameStart()
	SFX("start")
	for P=1,#players do
		P=players[P]
		_G.P=P
		P.control=true
		P.timing=true
		resetblock()
	end
	setmetatable(_G,nil)
end
function createPlayer(id,x,y,size,AIdata)
	players[id]={id=id}
	P=players[id]
	local P=P
	players.alive[#players.alive+1]=P
	P.index={__index=P}
	P.x,P.y,P.size=x,y,size or 1
	P.fieldOffX,P.fieldOffY=0,0
	P.small=P.size<.1
	if P.small then
		P.centerX,P.centerY=P.x+300*P.size,P.y+600*P.size
		P.canvas=gc.newCanvas(60,120)
		P.frameWait=rnd(30,120)
	else
		P.centerX,P.centerY=P.x+300*P.size,P.y+670*P.size
		P.absFieldX=P.x+150*P.size
		P.absFieldY=P.y+60*P.size
	end

	P.alive=true
	P.control=false
	P.timing=false
	P.stat={
		time=0,
		key=0,rotate=0,hold=0,piece=0,row=0,
		atk=0,send=0,recv=0,pend=0,
		clear_1=0,clear_2=0,clear_3=0,clear_4=0,
		spin_0=0,spin_1=0,spin_2=0,spin_3=0,
		pc=0,b2b=0,b3b=0,score=0,
	}--Current gamestat
	P.modeData={point=0,event=0}--data use by mode
	P.keyTime={}for i=1,10 do P.keyTime[i]=-1e5 end P.keySpeed=0
	P.dropTime={}for i=1,10 do P.dropTime[i]=-1e5 end P.dropSpeed=0

	P.field,P.visTime={},{}
	P.atkBuffer={sum=0}

	P.ko,P.badge,P.strength=0,0,0
	P.atkMode,P.swappingAtkMode=1,20
	P.atker,P.atking,P.lastRecv={}
	--Royale-related

	P.gameEnv={}--Game setting vars,like dropDelay setting
	for k,v in pairs(gameEnv0)do
		if modeEnv[k]~=nil then
			P.gameEnv[k]=modeEnv[k]
		elseif setting[k]~=nil then
			P.gameEnv[k]=setting[k]
		else
			P.gameEnv[k]=v
		end
	end--reset current game settings
	P.cur={bk={{}},id=0,color=0,name=0}
		P.sc,P.dir,P.r,P.c=ORG,0,0,0
		P.curX,P.curY,P.y_img=0,0,0
	P.hold={bk={{}},id=0,color=0,name=0}
		P.holded=false
	P.next={}

	P.dropDelay,P.lockDelay=P.gameEnv.drop,P.gameEnv.lock
	P.freshTime=0
	P.spinLast,P.lastClear=false,nil

	P.his={rnd(7),rnd(7),rnd(7),rnd(7)}
	local s=P.gameEnv.sequence
	if s=="bag7"or s=="his4"then
		local bag1={1,2,3,4,5,6,7}
		for i=1,7 do
			newNext(rem(bag1,rnd(#bag1)))
		end
	elseif s=="rnd"then
		for i=1,6 do
			local r=rnd(7)
			newNext(r)
		end
	elseif s=="drought1"then
		local bag1={1,2,3,4,5,6}
		for i=1,6 do
			newNext(rem(bag1,rnd(#bag1)))
		end
	elseif s=="drought2"then
		local bag1={1,2,3,4,6,6}
		for i=1,6 do
			newNext(rem(bag1,rnd(#bag1)))
		end
	end

	P.freshNext=freshMethod[P.gameEnv.sequence]
	if P.gameEnv.sequence==1 then P.bag={}--Bag7
	elseif P.gameEnv.sequence==2 then P.his={}for i=1,4 do P.his[i]=P.next.id[i+3]end--History4
	elseif P.gameEnv.sequence==3 then--Pure random
	end

	if AIdata then
		P.human=false
		P.AI_mode=AIdata.type
		P.AI_stage=1
		P.AI_needFresh=false
		P.AI_keys={}
		P.AI_delay=min(int(P.gameEnv.drop*.8),2*AIdata.delta)
		P.AI_delay0=AIdata.delta
		P.AIdata={
			next=AIdata.next,
			hold=AIdata.hold,
			_20G=P.gameEnv._20G,
			bag7=AIdata.bag7=="bag7",
			node=AIdata.node,
		}
		if not BOT then P.AI_mode="9S"end
		if P.AI_mode=="CC"then
			P.RS=AIRS
			local opt,wei=BOT.getConf()
				BOT.setHold(opt,P.AIdata.hold)
				BOT.set20G(opt,P.AIdata._20G)
				BOT.setBag(opt,P.AIdata.bag7)
				BOT.setNode(opt,P.AIdata.node)
			P.AI_bot=BOT.new(opt,wei)
			BOT.free(opt)BOT.free(wei)
			for i=1,AIdata.next do
				BOT.addNext(P.AI_bot,CCblockID[P.next[i].id])
			end
		elseif P.AI_mode=="9S"then
			P.RS=TRS
			P.AI_keys={}
			P.AI_Delay=min(int(P.gameEnv.drop*.8),2*AIdata.delta)
			P.AI_Delay0=AIdata.delta
		end
	else
		P.human=true
		P.RS=TRS
		human=human+1
	end

	P.showTime=visible_opt[P.gameEnv.visible]
	P.keepVisible=P.gameEnv.visible=="show"
	P.keyPressing={}for i=1,12 do P.keyPressing[i]=false end
	P.moving,P.downing=0,0
	P.waiting,P.falling=-1,-1
	P.clearing={}
	P.combo,P.b2b=0,0
	P.fieldBeneath=0

	P.shade={}
	P.score1,P.b2b1=0,0
	P.bonus={}--texts

	P.endCounter=0--used after gameover
	P.counter=0--many usage
	P.result=nil--string:win/lose
end
function showText(P,text,type,font,dy,spd,inf)
	if not P.small then
		P.bonus[#P.bonus+1]={t=0,text=text,draw=textFX[type],font=font,dy=dy or 0,speed=spd or 1,inf=inf}
	end
end
local function createBeam(S,R,send,time,target,color,clear,spin,mini,combo)
	local x1,y1,x2,y2
	if S.small then x1,y1=S.centerX,S.centerY
	else x1,y1=S.x+(30*(P.curX+P.sc[2]-1)-30+15+150)*S.size,S.y+(600-30*(P.curY+P.sc[1]-1)+15+70)*S.size
	end
	if R.small then x2,y2=R.centerX,R.centerY
	else x2,y2=R.x+308*R.size,R.y+450*R.size
	end

	local radius,corner
	local a,r,g,b=1,unpack(blockColor[color])
	if clear>10 then
		radius=10+3*send+100/(target+4)
		local t=clear%10
		if t==1 then
			corner=3
			r=.3+r*.4
			g=.3+g*.4
			b=.3+b*.4
		elseif t==2 then
			corner=5
			r=.5+r*.5
			g=.5+g*.5
			b=.5+b*.5
		elseif t<6 then
			corner=6
			r=.6+r*.4
			g=.6+g*.4
			b=.6+b*.4
		else
			r=.8+r*.2
			g=.8+g*.2
			b=.8+b*.2
			corner=20
		end
	else
		if combo>3 then
			radius=min(15+combo,30)
			corner=3
		else
			radius=30
			corner=4
		end
		r=1-r*.3
		g=1-g*.3
		b=1-b*.3
	end
	if modeEnv.royaleMode and not(S.human or R.human)then
		radius=radius*.4
		a=.35
	end
	FX_attack[#FX_attack+1]={
		x=x1,y=y1,--current pos
		x1=x1,y1=y1,--start pos
		x2=x2,y2=y2,--end pos
		rad=radius*(setting.atkFX+2)*.2,
		corner=corner,
		type=type==1 and"fill"or"line",
		r=r,g=g,b=b,a=a*(setting.atkFX+1)*.25,
		t=0,
		drag={},--Afterimage coordinate list
	}
end
local function garbageSend(S,R,send,time,...)
	if setting.atkFX>0 then
		createBeam(S,R,send,time,...)
	end
	R.lastRecv=S
	if R.atkBuffer.sum<20 then
		local B=R.atkBuffer
		if B.sum+send>20 then send=20-B.sum end--no more then 20
		local m,k=#B,1
		while k<=m and time>B[k].countdown do k=k+1 end
		for i=m,k,-1 do
			B[i+1]=B[i]
		end
		B[k]={
			pos=rnd(10),
			amount=send,
			countdown=time,
			cd0=time,
			time=0,
			sent=false,
			lv=min(int(send^.69),5),
		}--Sorted insert(by time)
		B.sum=B.sum+send
		R.stat.recv=R.stat.recv+send
		if R.human then
			SFX(send<4 and "blip_1"or"blip_2",min(send+1,5)*.1)
		end
	end
end
local function garbageRelease()
	local flag
	::L::
		local A=P.atkBuffer[1]
		if A and A.countdown<=0 and not A.sent then
			garbageRise(8+A.lv,A.amount,A.pos)
			P.atkBuffer.sum=P.atkBuffer.sum-A.amount
			A.sent,A.time=true,0
			P.stat.pend=P.stat.pend+A.amount
			flag=true
		else
			goto E
		end
	goto L
	::E::
	if flag and P.AI_mode=="CC"then CC_updateField(P)end
end
function garbageRise(color,amount,pos)
	local t=P.showTime*2
	for _=1,amount do
		ins(P.field,1,getNewRow(color))
		ins(P.visTime,1,getNewRow(t))
		P.field[1][pos]=0
	end
	P.fieldBeneath=P.fieldBeneath+amount*30
	P.curY=P.curY+amount
	freshgho()
	for i=1,#P.clearing do
		P.clearing[i]=P.clearing[i]+amount
	end
	for i=1,#P.shade do
		local S=P.shade[i]
		S[4],S[6]=S[4]+amount,S[6]+amount
	end
	if #P.field>40 then Event.lose()end
end
local function ifoverlap(bk,x,y)
	if x<1 or x+#bk[1]>11 or y<1 then return true end
	if y>#P.field then return end
	for i=1,#bk do for j=1,#bk[1]do
		if P.field[y+i-1]and bk[i][j]and P.field[y+i-1][x+j-1]>0 then return true end
	end end
end
local function ckfull(i)
	for j=1,10 do if P.field[i][j]<=0 then return end end
	return true
end
local function checkrow(start,height)--(cy,r)
	local c=0
	local h=start
	for i=1,height do
		if ckfull(h)then
			ins(P.clearing,h)
			removeRow(P.field,h)
			removeRow(P.visTime,h)
			c=c+1
			if not P.small then
				local S=PTC.dust[P.id]
				for k=1,100 do
					S:setPosition(rnd(300),600-30*h+rnd(30))
					S:emit(3)
				end
			end
		else
			h=h+1
		end
	end
	return c
end
local function solid(x,y)
	if x<1 or x>10 or y<1 then return true end
	if y>#P.field then return false end
	return P.field[y][x]>0
end
function freshgho()
	P.y_img=min(#P.field+1,P.curY)
	if P.gameEnv._20G or P.keyPressing[7]and P.gameEnv.sdarr==0 then
		::L::if not ifoverlap(P.cur.bk,P.curX,P.y_img-1)then
			P.y_img=P.y_img-1
			P.spinLast=false
			goto L
		end
		if P.curY>P.y_img then
			if P.human then
				if setting.dropFX>0 then
					createShade(P.curX,P.curY+1,P.curX+P.c-1,P.y_img+P.r-1)
				end
				if setting.shakeFX>0 then
					P.fieldOffY=2*setting.shakeFX+1
				end
			end
			P.curY=P.y_img
		end
	else
		::L::if not ifoverlap(P.cur.bk,P.curX,P.y_img-1)then
			P.y_img=P.y_img-1
			goto L
		end
	end
end
local function freshLockDelay()
	if P.lockDelay<P.gameEnv.lock then
		P.dropDelay=P.gameEnv.drop
		if P.freshTime<=P.gameEnv.freshLimit then
			P.lockDelay=P.gameEnv.lock
		end
		P.freshTime=P.freshTime+1
	end
end
local function lock()
	for i=1,P.r do
		local y=P.curY+i-1
		if not P.field[y]then P.field[y],P.visTime[y]=getNewRow(0),getNewRow(0)end
		for j=1,P.c do
			if P.cur.bk[i][j]then
				P.field[y][P.curX+j-1]=P.cur.color
				P.visTime[y][P.curX+j-1]=P.showTime
			end
		end
	end
end
local function spin(d,ifpre)
	local idir=(P.dir+d)%4
	if P.cur.id==6 then
		if P.gameEnv.easyFresh then
			freshLockDelay()
		end
		if P.human then
			SFX(ifpre and"prerotate"or"rotate")
		end
		if P.gameEnv.ospin and P.freshTime>10 then
			if d==1 then
				if P.curY==P.y_img and solid(P.curX+2,P.curY+1)and solid(P.curX+2,P.curY)and solid(P.curX-1,P.curY+1)and not solid(P.curX-1,P.curY)then
					if solid(P.curX-2,P.curY)then
						P.curX=P.curX-1
						goto T
					else
						P.curX=P.curX-2
						goto I
					end
				end
			elseif d==-1 then
				if P.curY==P.y_img and solid(P.curX-1,P.curY+1)and solid(P.curX-1,P.curY)and solid(P.curX+2,P.curY+1)and not solid(P.curX+2,P.curY)then
					if solid(P.curX+3,P.curY)then
						goto T
					else
						goto I
					end
				end
			elseif d==2 and P.curY==P.y_img and solid(P.curX-1,P.curY+1)and solid(P.curX+2,P.curY+1)and not solid(P.curX-1,P.curY)and not solid(P.curX+2,P.curY)then
				P.curX=P.curX-1
				goto I
			end
			do return end
			::T::
				P.cur.id=5
				P.cur.bk=blocks[5][0]
				P.sc=scs[5][0]
				P.r,P.c,P.dir=2,3,0
				P.spinLast=2
				P.stat.rotate=P.stat.rotate+1
			do return end
			::I::
				P.cur.id=7
				P.cur.bk=blocks[7][2]
				P.sc=scs[7][2]
				P.r,P.c,P.dir=1,4,2
				P.spinLast=2
				P.stat.rotate=P.stat.rotate+1
			end
		return
	end
	local icb=blocks[P.cur.id][idir]
	local isc=scs[P.cur.id][idir]
	local ir,ic=#icb,#icb[1]
	local ix,iy=P.curX+P.sc[2]-isc[2],P.curY+P.sc[1]-isc[1]
	local t--succssful test
	local iki=P.RS[P.cur.id][P.dir*10+idir]
	for i=1,P.freshTime<=1.2*P.gameEnv.freshLimit and #iki or 1 do
		if not ifoverlap(icb,ix+iki[i][1],iy+iki[i][2])then
			ix,iy=ix+iki[i][1],iy+iki[i][2]
			t=i
			goto spin
		end
	end
	do return end
	::spin::
	if P.human and setting.dropFX>0 then
		createShade(P.curX,P.curY+P.r-1,P.curX+P.c-1,P.curY)
	end
	local y0=P.curY
	P.curX,P.curY,P.dir=ix,iy,idir
	P.sc,P.cur.bk=scs[P.cur.id][idir],icb
	P.r,P.c=ir,ic
	P.spinLast=t==2 and 0 or 1
	if not ifpre then freshgho()end
	if P.gameEnv.easyFresh or y0>P.curY then freshLockDelay()end
	if P.human then
		SFX(ifpre and"prerotate"or ifoverlap(P.cur.bk,P.curX,P.curY+1)and ifoverlap(P.cur.bk,P.curX-1,P.curY)and ifoverlap(P.cur.bk,P.curX+1,P.curY)and"rotatekick"or"rotate")
	end
	P.stat.rotate=P.stat.rotate+1
end
local function hold(ifpre)
	if not P.holded and P.waiting==-1 and P.gameEnv.hold then
		P.holded=P.gameEnv.oncehold
		P.cur,P.hold=P.hold,P.cur
		P.hold.bk=blocks[P.hold.id][0]
		if P.cur.id==0 then
			P.cur=rem(P.next,1)
			P.freshNext()
			if P.AI_mode=="CC"then BOT.addNext(P.AI_bot,CCblockID[P.next[P.AIdata.next].id])end
		end
		P.sc,P.dir=scs[P.cur.id][0],0
		P.r,P.c=#P.cur.bk,#P.cur.bk[1]
		P.curX,P.curY=blockPos[P.cur.id],21+ceil(P.fieldBeneath/30)-P.r+min(int(#P.field*.2),2)

		if abs(P.moving)>P.gameEnv.das and not ifoverlap(P.cur.bk,P.curX+(P.moving>0 and 1 or -1),P.curY)then
			P.curX=P.curX+(P.moving>0 and 1 or -1)
		end
		--IMS

		freshgho()
		P.dropDelay,P.lockDelay,P.freshTime=P.gameEnv.drop,P.gameEnv.lock,max(P.freshTime-5,0)
		if ifoverlap(P.cur.bk,P.curX,P.curY)then lock()Event.lose()end

		if P.human then
			SFX(ifpre and"prehold"or"hold")
		end
		P.stat.hold=P.stat.hold+1
	end
end
function resetblock()
	P.holded,P.spinLast=false,false
	P.cur=rem(P.next,1)
	P.freshNext()
	if P.AI_mode=="CC"then BOT.addNext(P.AI_bot,CCblockID[P.next[P.AIdata.next].id])end
	P.sc,P.dir=scs[P.cur.id][0],0--spin center/direction
	P.r,P.c=#P.cur.bk,#P.cur.bk[1]--row/column
	P.curX,P.curY=blockPos[P.cur.id],21+ceil(P.fieldBeneath/30)-P.r+min(int(#P.field*.2),2)
	P.dropDelay,P.lockDelay,P.freshTime=P.gameEnv.drop,P.gameEnv.lock,0

	if P.keyPressing[8]then hold(true)end
	if P.keyPressing[3]then spin(1,true)end
	if P.keyPressing[4]then spin(-1,true)end
	if P.keyPressing[5]then spin(2,true)end
	if abs(P.moving)>P.gameEnv.das and not ifoverlap(P.cur.bk,P.curX+(P.moving>0 and 1 or -1),P.curY)then
		P.curX=P.curX+(P.moving>0 and 1 or -1)
	end
	--Initial SYSs
	if ifoverlap(P.cur.bk,P.curX,P.curY)then lock()Event.lose()end
	freshgho()
	if P.keyPressing[6]then act.hardDrop()P.keyPressing[6]=false end
end
function drop()--Place piece
	P.dropTime[11]=ins(P.dropTime,1,frame)--update speed dial
	P.waiting=P.gameEnv.wait
	local dospin=0
	if P.spinLast then
		if P.cur.id<6 then
			local x,y=P.curX+P.sc[2]-1,P.curY+P.sc[1]-1
			local c=0
			if solid(x-1,y+1)then c=c+1 end
			if solid(x+1,y+1)then c=c+1 end
			if c==0 then goto NTC end
			if solid(x-1,y-1)then c=c+1 end
			if solid(x+1,y-1)then c=c+1 end
			if c>2 then dospin=dospin+1 end
		end--Three point
		::NTC::
		if P.cur.id~=6 and ifoverlap(P.cur.bk,P.curX-1,P.curY)and ifoverlap(P.cur.bk,P.curX+1,P.curY)and ifoverlap(P.cur.bk,P.curX,P.curY+1)then
			dospin=dospin+2
		end--Immobile
	end
	lock()
	local CHN=getFreeVoiceChannel()
	local cc,send,exblock=checkrow(P.curY,P.r),0,0--Currect clear&send&sendTime
	if cc>0 then P.falling=P.gameEnv.fall end
	local cscore,sendTime=0,0
	local mini
	if P.spinLast then
		if cc>0 then
			if dospin>0 then
				dospin=dospin+P.spinLast
				if dospin<2 then
					mini=P.cur.id<6 and cc<3 and cc<P.r
				end
			else
				dospin=false
			end
		elseif cc==0 then
			if dospin==0 then
				dospin=false
			end
		end
	else
		dospin=false
	end

	if cc>0 then
		P.combo=P.combo+1
		if cc==4 then
			cscore=1000
			if P.b2b>1000 then
				showText(P,text.techrashB3B,"fly",80,-30)
				send=6
				sendTime=100
				exblock=exblock+1
				cscore=cscore*1.8
				P.stat.b3b=P.stat.b3b+1
				if P.human then
					VOICE("b3b",CHN)
				end
			elseif P.b2b>=50 then
				showText(P,text.techrashB2B,"drive",80,-30)
				sendTime=80
				send=5
				cscore=cscore*1.3
				P.stat.b2b=P.stat.b2b+1
				if P.human then
					VOICE("b2b",CHN)
				end
			else
				showText(P,text.techrash,"stretch",80,-30)
				sendTime=60
				send=4
			end
			P.b2b=P.b2b+120
			P.lastClear=74
			P.stat.clear_4=P.stat.clear_4+1
			if P.human then
				VOICE("tts",CHN)
			end
		elseif cc>0 then
			local clearKey=clear_n
			if dospin then
				cscore=spinSCR[P.cur.name][cc]
				if P.b2b>1000 then
					showText(P,text.b3b..text.spin[P.cur.name]..text.clear[cc],"spin",40,-30)
					send=b2bATK[cc]+1
					exblock=exblock+1
					cscore=cscore*2
					P.stat.b3b=P.stat.b3b+1
					if P.human then
						VOICE("b3b",CHN)
					end
				elseif P.b2b>=50 then
					showText(P,text.b2b..text.spin[P.cur.name]..text.clear[cc],"spin",40,-30)
					send=b2bATK[cc]
					cscore=cscore*1.2
					P.stat.b2b=P.stat.b2b+1
					if P.human then
						VOICE("b2b",CHN)
					end
				else
					showText(P,text.spin[P.cur.name]..text.clear[cc],"spin",50,-30)
					send=2*cc
				end
				sendTime=20+send*20
				if mini then
					showText(P,text.mini,"appear",40,-80)
					send=ceil(send*.5)
					sendTime=sendTime+60
					cscore=cscore*.5
					P.b2b=P.b2b+b2bPoint[cc]*.5
					if P.human then
						VOICE("mini",CHN)
					end
				else
					P.b2b=P.b2b+b2bPoint[cc]
				end
				P.lastClear=P.cur.id*10+cc
				clearKey=spin_n
				if P.human then
					SFX(spin_n[cc])
					VOICE(blockName[P.cur.name],CHN)
					VOICE("spin_",CHN)
				end
			elseif #P.field>0 then
				P.b2b=max(P.b2b-250,0)
				showText(P,text.clear[cc],"appear",32+cc*3,-30,(8-cc)*.3)
				send=cc-1
				sendTime=20+send*20
				cscore=cscore+clearSCR[cc]
				P.lastClear=cc
			end
			P.stat[clearKey[cc]]=P.stat[clearKey[cc]]+1
			if P.human then
				VOICE(clearName[cc],CHN)
			end
		end
		send=send+(renATK[P.combo]or 3)
		if #P.field==0 then
			showText(P,text.PC,"flicker",70,-80)
			send=min(send,4)+min(6+P.stat.pc,10)
			exblock=exblock+2
			sendTime=sendTime+60
			if P.stat.row>4 then
				P.b2b=1200
				cscore=cscore+500*min(6+P.stat.pc,10)
			else
				cscore=cscore+500
			end
			P.stat.pc=P.stat.pc+1
			P.lastClear=P.cur.id*10+5
			if P.human then
				SFX("perfectclear")
				VOICE("pc",CHN)
			end
		end
		if P.combo>2 then
			showText(P,text.cmb[min(P.combo,20)],P.combo<10 and"appear"or"flicker",20+min(P.combo,25)*3,60)
			cscore=cscore+min(20*P.combo,300)*cc
		end
		sendTime=sendTime+25*P.combo
		if P.human then
			SFX(clear_n[cc])
			SFX(ren_n[min(P.combo,11)])
			if P.combo>14 then SFX("ren_mega",(P.combo-10)*.1)end
			VIB(cc+1)
		end
		if P.b2b>1200 then P.b2b=1200 end

		if modeEnv.royaleMode then
			local i=min(#P.atker,9)
			if i>1 then
				send=send+reAtk[i]
				exblock=exblock+reDef[i]
			end
		end--Counter attack

		if send>0 then
			P.stat.atk=P.stat.atk+send
			--ATK statistics
			if exblock then exblock=int(exblock*(1+P.strength*.25))end
			send=send*(1+P.strength*.25)
			if mini then send=send*.8 end
			send=int(send)
			--Badge Buff
			if send==0 then goto L end
				showText(P,send,"zoomout",40,70)
			if exblock==0 then goto L end
				showText(P,exblock,"zoomout",20,115)
			::L::
			send=send+exblock
			local k=0
			::R::
			if P.atkBuffer.sum>0 and send>0 then
				::F::
					k=k+1
					local A=P.atkBuffer[k]
					if not A then goto E end
				if A.sent then goto F end
				if send>=A.amount then
					send=send-A.amount
					P.atkBuffer.sum=P.atkBuffer.sum-A.amount
					A.sent,A.time=true,0
					if send>0 then goto R end
				else
					A.amount=A.amount-send
					P.atkBuffer.sum=P.atkBuffer.sum-send
					send=0
				end
			end
			::E::
			send=send-exblock
			if send>0 then
				local T
				if modeEnv.royaleMode then
					if P.atkMode==4 then
						local M=#P.atker
						if M>0 then
							for i=1,M do
								garbageSend(P,P.atker[i],send,sendTime,M,P.cur.color,P.lastClear,dospin,mini,P.combo)
							end
						else
							T=randomTarget(P)
						end
					else
						freshTarget(P)
						T=P.atking
					end
				elseif #players.alive>1 then
					T=randomTarget(P)
				end
				if T then
					garbageSend(P,T,send,sendTime,1,P.cur.color,P.lastClear,dospin,mini,P.combo)
				end
				P.stat.send=P.stat.send+send
				if P.human and send>3 then SFX("emit",min(send,8)*.125)end
			end
		end
	else
		P.combo=0
		if dospin then
			showText(P,text.spin[P.cur.name],"appear",50,-30)
			P.b2b=P.b2b+20
			P.stat.spin_0=P.stat.spin_0+1
			if P.human then
				SFX("spin_0")
				VOICE(blockName[P.cur.name],CHN)
				VOICE("spin",CHN)
			end
			cscore=cscore+30
		end
		cscore=cscore+10
		if P.b2b>1000 then
			P.b2b=max(P.b2b-40,1000)
		end
		garbageRelease()
	end
	P.stat.score=P.stat.score+cscore
	P.stat.piece,P.stat.row=P.stat.piece+1,P.stat.row+cc
	P.gameEnv.dropPiece()
	if P.human then SFX("lock")end
end
function pressKey(i,p)
	P=p;P.keyPressing[i]=true
	if P.human then
		virtualkeyDown[i]=true
		virtualkeyPressTime[i]=10
	end
	if P.alive then
		act[actName[i]]()
		P.keyTime[11]=ins(P.keyTime,1,frame)
		P.stat.key=P.stat.key+1
	end
	--ins(rec,{i,frame})
end
function releaseKey(i,p)
	p.keyPressing[i]=false
	if p.id==1 then virtualkeyDown[i]=false end
	-- if recording then ins(rec,{-i,frame})end
end
act={
	moveLeft=function(auto)
		if P.keyPressing[9]then
			if setting.swap then
				changeAtkMode(1)
			end
		elseif P.control and P.waiting==-1 then
			if not ifoverlap(P.cur.bk,P.curX-1,P.curY)then
				P.curX=P.curX-1
				local y0=P.curY
				freshgho()
				if P.gameEnv.easyFresh or y0~=P.curY then freshLockDelay()end
				if P.human and P.curY==P.y_img then SFX("move")end
				P.spinLast=false
				if not auto then P.moving=-1 end
			else
				P.moving=-P.gameEnv.das-1
			end
		else
			P.moving=-1
		end
	end,
	moveRight=function(auto)
		if P.keyPressing[9]then
			if setting.swap then
				changeAtkMode(2)
			end
		elseif P.control and P.waiting==-1 then
			if not ifoverlap(P.cur.bk,P.curX+1,P.curY)then
				P.curX=P.curX+1
				local y0=P.curY
				freshgho()
				if P.gameEnv.easyFresh or y0~=P.curY then freshLockDelay()end
				if P.human and P.curY==P.y_img then SFX("move")end
				P.spinLast=false
				if not auto then P.moving=1 end
			else
				P.moving=P.gameEnv.das+1
			end
		else
			P.moving=1
		end
	end,
	rotRight=function()
		if P.control and P.waiting==-1 then
			spin(1)
			P.keyPressing[3]=false
		end
	end,
	rotLeft=function()
		if P.control and P.waiting==-1 then
			spin(-1)
			P.keyPressing[4]=false
		end
	end,
	rotFlip=function()
		if P.control and P.waiting==-1 then
			spin(2)
			P.keyPressing[5]=false
		end
	end,
	hardDrop=function()
		if P.keyPressing[9]then
			if setting.swap then
				changeAtkMode(3)
			end
			P.keyPressing[6]=false
		elseif P.control and P.waiting==-1 then
			if P.curY~=P.y_img then
				if P.human then
					if setting.dropFX>0 then
						createShade(P.curX,P.curY+1,P.curX+P.c-1,P.y_img+P.r-1)
					end
					if setting.shakeFX>0 then
						P.fieldOffY=2*setting.shakeFX+1
					end
				end
				P.curY=P.y_img
				P.spinLast=false
				if P.human then
					SFX("drop")
					VIB(1)
				end
			end
			P.lockDelay=-1
			drop()
			P.keyPressing[6]=false
		end
	end,
	softDrop=function()
		if P.keyPressing[9]then
			if setting.swap then
				changeAtkMode(4)
			end
		else
			if P.curY~=P.y_img then
				P.curY=P.curY-1
				P.spinLast=false
			end
			P.downing=1
		end
	end,
	hold=function()
		if P.control and P.waiting==-1 then
			hold()
		end
	end,
	func=function()
		P.gameEnv.Fkey()
	end,
	restart=function()
		if not setting.holdR or frame<180 then
			clearTask("play")
			resetPartGameData()
		end
	end,

	insDown=function()
		if P.curY~=P.y_img then
			if P.human then
				if setting.dropFX>0 then
					createShade(P.curX,P.curY+1,P.curX+P.c-1,P.y_img+P.r-1)
				end
				if setting.shakeFX>0 then
					P.fieldOffY=2*setting.shakeFX
				end
			end
			P.curY,P.lockDelay,P.spinLast=P.y_img,P.gameEnv.lock,false
		end
	end,
	insLeft=function()
		local x0,y0=P.curX,P.curY
		::L::if not ifoverlap(P.cur.bk,P.curX-1,P.curY)then
			P.curX=P.curX-1
			if P.human and setting.dropFX>0 then
				createShade(P.curX+1,P.curY+P.r-1,P.curX+1,P.curY)
			end
			freshgho()
			goto L
		end
		if x0~=P.curX then
			if P.human and setting.shakeFX>0 then
				P.fieldOffX=-2*setting.shakeFX
			end
			if P.gameEnv.easyFresh or y0~=P.curY then freshLockDelay()end
		end
	end,
	insRight=function()
		local x0,y0=P.curX,P.curY
		::L::if not ifoverlap(P.cur.bk,P.curX+1,P.curY)then
			P.curX=P.curX+1
			if P.human and setting.dropFX>0 then
				createShade(P.curX+P.c-1,P.curY+P.r-1,P.curX+P.c-1,P.curY)
			end
			freshgho()
			goto L
		end
		if x0~=P.curX then
			if P.human and setting.shakeFX>0 then
				P.fieldOffX=2*setting.shakeFX
			end
			if P.gameEnv.easyFresh or y0~=P.curY then freshLockDelay()end
		end
	end,
	down1=function()
		if P.curY~=P.y_img then
			P.curY=P.curY-1
			P.spinLast=false
		end
	end,
	down4=function()
		for i=1,4 do
			if P.curY~=P.y_img then
				P.curY=P.curY-1
				P.spinLast=false
			else
				break
			end
		end
	end,
	quit=function()Event.lose()end,
	--System movements
}