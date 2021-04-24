local Player=require"parts.player.player"
local getSeqGen=require"parts.player.getSeqGen"
local gameEnv0=require"parts.player.gameEnv0"

local rnd,max=math.random,math.max
local ins=table.insert

local PLY={
	update=require"parts.player.update",
	draw=require"parts.player.draw",
}

--------------------------<Libs>--------------------------
local modeDataMeta do
	local rawset=rawset
	modeDataMeta={
		__index=function(self,k)rawset(self,k,0)return 0 end,
		__newindex=function(self,k,v)rawset(self,k,v)end,
	}
end
local function getNewStatTable()
	local T={
		time=0,frame=0,score=0,
		key=0,rotate=0,hold=0,
		extraPiece=0,finesseRate=0,
		piece=0,row=0,dig=0,
		atk=0,digatk=0,
		send=0,recv=0,pend=0,off=0,
		clear={},clears={},spin={},spins={},
		pc=0,hpc=0,b2b=0,b3b=0,
		maxCombo=0,maxFinesseCombo=0,
	}
	for i=1,29 do
		T.clear[i]={0,0,0,0,0,0}
		T.spin[i]={0,0,0,0,0,0,0}
		T.clears[i]=0
		T.spins[i]=0
	end
	return T
end
local function pressKey(P,keyID)
	if P.keyAvailable[keyID]and P.alive then
		P.keyPressing[keyID]=true
		P.actList[keyID](P)
		if P.control then
			ins(P.keyTime,1,P.frameRun)
			P.keyTime[11]=nil
		end
		P.stat.key=P.stat.key+1
	end
end
local function releaseKey(P,keyID)
	P.keyPressing[keyID]=false
end
local function pressKey_Rec(P,keyID)
	if P.keyAvailable[keyID]and P.alive then
		local L=GAME.rep
		ins(L,P.frameRun)
		ins(L,keyID)
		P.keyPressing[keyID]=true
		P.actList[keyID](P)
		if P.control then
			ins(P.keyTime,1,P.frameRun)
			P.keyTime[11]=nil
		end
		P.stat.key=P.stat.key+1
	end
end
local function releaseKey_Rec(P,keyID)
	local L=GAME.rep
	ins(L,P.frameRun)
	ins(L,32+keyID)
	P.keyPressing[keyID]=false
end
local function newEmptyPlayer(id,mini)
	local P={id=id}
	PLAYERS[id]=P
	PLY_ALIVE[id]=P

	--Inherit functions of Player class
	for k,v in next,Player do P[k]=v end

	if P.id==1 and GAME.recording then
		P.pressKey=pressKey_Rec
		P.releaseKey=releaseKey_Rec
	else
		P.pressKey=pressKey
		P.releaseKey=releaseKey
	end
	P.update=PLY.update.alive

	P.fieldOff={--Shake FX
		x=0,y=0,
		vx=0,vy=0,
		a=0,va=0,
	}
	P.x,P.y,P.size=0,0,1
	P.frameColor=0

	--Set these at Player:setPosition()
	-- P.fieldX,P.fieldY=...
	-- P.centerX,P.centerY=...
	-- P.absFieldX,P.absFieldY=...

	--If draw in small mode
	P.mini=mini
	if mini then
		P.canvas=love.graphics.newCanvas(60,120)
		P.frameWait=rnd(26,62)
		P.draw=PLY.draw.small
	else
		P.draw=PLY.draw.norm
	end

	P.randGen=love.math.newRandomGenerator(GAME.seed)

	P.frameRun=GAME.frameStart
	P.alive=true
	P.control=false
	P.timing=false
	P.stat=getNewStatTable()

	P.modeData=setmetatable({},modeDataMeta)--Data use by mode

	P.keyTime={}P.keySpeed=0
	P.dropTime={}P.dropSpeed=0
	for i=1,10 do P.keyTime[i]=-1e99 end
	for i=1,10 do P.dropTime[i]=-1e99 end

	P.field,P.visTime={},{}
	P.atkBuffer={sum=0}

	--Royale-related
	P.badge,P.strength=0,0
	P.atkMode,P.swappingAtkMode=1,20
	P.atker,P.atking,P.lastRecv={}

	--Network-related
	P.username="_"
	P.uid=-1
	P.sid=-1

	P.dropDelay,P.lockDelay=0,0
	P.showTime=false
	P.keepVisible=true

	--[[
	P.cur={
		id=shapeID,
		bk=matrix[2],
		sc=table[2],
		dir=direction,
		name=nameID
		color=colorID,
	}
	]]
	-- P.curX,P.curY,P.ghoY,P.minY=0,0,0,0--x,y,ghostY
	P.holdQueue={}
	P.holdTime=0
	P.nextQueue={}

	P.freshTime=0
	P.spinLast=false
	P.lastPiece={
		id=0,name=0,--block id/name

		finePts=0,--finesse Points

		row=0,dig=0,--lines/garbage cleared
		score=0,--score gained
		atk=0,exblock=0,--lines attack/defend
		off=0,send=0,--lines offset/sent

		spin=false,mini=false,--if spin/mini
		pc=false,hpc=false,--if pc/hpc
		special=false,--if special clear (spin, >=4, pc)
	}
	P.spinSeq=0--For Ospin, each digit mean a spin
	P.ctrlCount=0--Key press time, for finesse check
	P.pieceCount=0--Count pieces from next, for drawing bagline

	P.type="none"
	P.sound=false

	-- P.newNext=false--Warped coroutine to get new next, loaded in applyGameEnv()

	P.keyPressing={}for i=1,12 do P.keyPressing[i]=false end
	P.movDir,P.moving,P.downing=0,0,0--Last move key,DAS charging,downDAS charging
	P.waiting,P.falling=-1,-1
	P.clearingRow,P.clearedRow={},{}--Clearing animation height,cleared row mark
	P.combo,P.b2b=0,0
	P.finesseCombo=0
	P.garbageBeneath=0
	P.fieldBeneath=0
	P.fieldUp=0

	P.score1,P.b2b1=0,0
	P.finesseComboTime=0
	P.dropFX,P.moveFX,P.lockFX,P.clearFX={},{},{},{}
	P.tasks={}--Tasks
	P.bonus={}--Text objects

	P.endCounter=0--Used after gameover
	P.result=false--String:"WIN"/"K.O."

	return P
end
local function loadGameEnv(P)--Load gameEnv
	P.gameEnv={}--Current game setting environment
	local ENV=P.gameEnv
	local GAME,SETTING=GAME,SETTING
	--Load game settings
	for k,v in next,gameEnv0 do
		if GAME.modeEnv[k]~=nil then
			v=GAME.modeEnv[k]	--Mode setting
			-- print("mode-"..k..":"..tostring(v))
		elseif GAME.setting[k]~=nil then
			v=GAME.setting[k]	--Game setting
			-- print("game-"..k..":"..tostring(v))
		elseif SETTING[k]~=nil then
			v=SETTING[k]		--Global setting
			-- print("global-"..k..":"..tostring(v))
		-- else
			-- print("default-"..k..":"..tostring(v))
		end
		if type(v)~="table"then--Default setting
			ENV[k]=v
		else
			ENV[k]=TABLE.copy(v)
		end
	end
	if ENV.allowMod then
		for _,M in next,GAME.mod do
			M.func(P,M.list and M.list[M.sel])
		end
	end
end
local function loadRemoteEnv(P,confStr)--Load gameEnv
	confStr=JSON.decode(confStr)
	if not confStr then
		confStr={}
		LOG.print("Bad conf from "..P.username.."#"..P.uid)
	end

	P.gameEnv={}--Current game setting environment
	local ENV=P.gameEnv
	local GAME,SETTING=GAME,SETTING
	--Load game settings
	for k,v in next,gameEnv0 do
		if GAME.modeEnv[k]~=nil then
			v=GAME.modeEnv[k]	--Mode setting
		elseif confStr[k]~=nil then
			v=confStr[k]			--Game setting
		elseif SETTING[k]~=nil then
			v=SETTING[k]		--Global setting
		end
		if type(v)~="table"then--Default setting
			ENV[k]=v
		else
			ENV[k]=TABLE.copy(v)
		end
	end
end
local function applyGameEnv(P)--Finish gameEnv processing
	local ENV=P.gameEnv

	P._20G=ENV.drop==0
	P.dropDelay=ENV.drop
	P.lockDelay=ENV.lock
	P.freshTime=ENV.freshLimit

	P.life=ENV.life

	P.keyAvailable={true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true}
	if ENV.noTele then
		for i=11,20 do
			if i~=14 then
				P.keyAvailable[i]=false
			end
		end
	end
	if not ENV.fkey1 then P.keyAvailable[9]=false end
	if not ENV.fkey2 then P.keyAvailable[10]=false end
	for _,v in next,ENV.keyCancel do
		P.keyAvailable[v]=false
	end

	P:setInvisible(
		ENV.visible=="show"and -1 or
		ENV.visible=="easy"and 300 or
		ENV.visible=="slow"and 100 or
		ENV.visible=="medium"and 60 or
		ENV.visible=="fast"and 20 or
		ENV.visible=="none"and 0
	)
	P:set20G(P._20G)
	P:setHold(ENV.holdCount)
	P:setNext(ENV.nextCount,ENV.nextStartPos>1)
	P:setRS(ENV.RS)

	if type(ENV.mission)=="table"then
		P.curMission=1
	end

	ENV.das=max(ENV.das,ENV.mindas)
	ENV.arr=max(ENV.arr,ENV.minarr)
	ENV.sdarr=max(ENV.sdarr,ENV.minsdarr)

	if ENV.sequence~="bag"and ENV.sequence~="loop"then
		ENV.bagLine=false
	else
		ENV.bagLen=#ENV.seqData
	end

	if ENV.nextCount==0 then ENV.nextPos=false end

	P.newNext=coroutine.wrap(getSeqGen(P))
	P.newNext(P,P.gameEnv.seqData)

	if P.mini then
		ENV.lockFX=false
		ENV.dropFX=false
		ENV.moveFX=false
		ENV.clearFX=false
		ENV.splashFX=false
		ENV.shakeFX=false
		ENV.text=false
	end
	if ENV.lockFX==0 then	ENV.lockFX=false	end
	if ENV.dropFX==0 then	ENV.dropFX=false	end
	if ENV.moveFX==0 then	ENV.moveFX=false	end
	if ENV.clearFX==0 then	ENV.clearFX=false	end
	if ENV.splashFX==0 then	ENV.splashFX=false	end
	if ENV.shakeFX==0 then	ENV.shakeFX=false	end
	if ENV.atkFX==0 then	ENV.atkFX=false		end
	if ENV.ghost==0 then	ENV.ghost=false	end
	if ENV.center==0 then	ENV.center=false end
end
--------------------------</Libs>--------------------------

--------------------------<Public>--------------------------
local DemoEnv={
	face={0,0,0,0,0,0,0},
	das=10,arr=2,sddas=2,sdarr=2,
	drop=60,lock=60,
	wait=10,fall=20,
	highCam=false,
	life=1e99,
	allowMod=false,
	fine=false,
}
function PLY.newDemoPlayer(id)
	local P=newEmptyPlayer(id)
	P.type="computer"
	P.sound=true
	P.demo=true

	P.frameRun=180
	P.draw=PLY.draw.demo
	P.control=true
	GAME.modeEnv=DemoEnv
	loadGameEnv(P)
	applyGameEnv(P)
	P:loadAI{
		type="CC",
		next=5,
		hold=true,
		delay=30,
		delta=6,
		bag="bag",
		node=100000,
	}
	P:popNext()
end
function PLY.newRemotePlayer(id,mini,data)
	local P=newEmptyPlayer(id,mini)
	P.type="remote"
	P.update=PLY.update.remote_alive

	P.draw=PLY.draw.norm_remote

	P.stream={}
	P.streamProgress=1

	data.p=P
	P.uid=data.uid
	P.username=data.username
	P.sid=data.sid
	loadRemoteEnv(P,data.config)

	applyGameEnv(P)
end

function PLY.newAIPlayer(id,AIdata,mini)
	local P=newEmptyPlayer(id,mini)
	P.type="computer"

	loadGameEnv(P)
	local ENV=P.gameEnv
	ENV.face={0,0,0,0,0,0,0}
	ENV.skin={1,7,11,3,14,4,9}
	applyGameEnv(P)
	P:loadAI(AIdata)
end
function PLY.newPlayer(id,mini)
	local P=newEmptyPlayer(id,mini)
	P.type="human"
	P.sound=true

	P.uid=USER.uid
	P.sid=-1

	loadGameEnv(P)
	applyGameEnv(P)
end
--------------------------</Public>--------------------------
return PLY