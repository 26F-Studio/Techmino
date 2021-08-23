local Player=require"parts.player.player"
local getSeqGen=require"parts.player.seqGenerators"
local gameEnv0=require"parts.player.gameEnv0"

local rnd,max=math.random,math.max
local ins=table.insert

local ply_draw=require"parts.player.draw"
local ply_update=require"parts.player.update"
local PLY={draw=ply_draw}

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

	--Set key/timer event
	if P.id==1 and GAME.recording then
		P.pressKey=pressKey_Rec
		P.releaseKey=releaseKey_Rec
	else
		P.pressKey=pressKey
		P.releaseKey=releaseKey
	end
	P.update=ply_update.alive

	--Field position
	P.fieldOff={--Shake FX
		x=0,y=0,
		vx=0,vy=0,
		a=0,va=0,
	}
	P.x,P.y,P.size=0,0,1
	P.frameColor=COLOR.Z

	--Set these at Player:setPosition()
	-- P.fieldX,P.fieldY=...
	-- P.centerX,P.centerY=...
	-- P.absFieldX,P.absFieldY=...

	--Minimode
	P.miniMode=mini
	if mini then
		P.canvas=love.graphics.newCanvas(60,120)
		P.frameWait=rnd(26,62)
		P.draw=ply_draw.small
	else
		P.draw=ply_draw.norm
	end

	--States
	P.type='none'
	P.sound=false
	P.alive=true
	P.control=false
	P.timing=false
	P.result=false--String: 'finish'|'win'|'lose'
	P.stat=getNewStatTable()
	P.modeData=setmetatable({},modeDataMeta)--Data use by mode
	P.keyPressing={}for i=1,12 do P.keyPressing[i]=false end
	P.clearingRow,P.clearedRow={},{}--Clearing animation height,cleared row mark
	P.dropFX,P.moveFX,P.lockFX,P.clearFX={},{},{},{}
	P.tasks={}
	P.bonus={}--Texts

	--Times
	P.frameRun=GAME.frameStart--Frame run, mainly for replay
	P.endCounter=0--Used after gameover
	P.dropTime={}for i=1,10 do P.dropTime[i]=-1e99 end P.dropSpeed=0

	--Randomizers
	P.seqRND=love.math.newRandomGenerator(GAME.seed)
	P.atkRND=love.math.newRandomGenerator(GAME.seed)
	P.holeRND=love.math.newRandomGenerator(GAME.seed)
	P.aiRND=love.math.newRandomGenerator(GAME.seed)

	--Field-related
	P.field,P.visTime={},{}
	P.keepVisible=true
	P.showTime=false
	P.garbageBeneath=0
	P.fieldBeneath=0
	P.fieldUp=0

	--Attack-related
	P.atkBuffer={}
	P.atkBufferSum,P.atkBufferSum1=0,0
	P.spike,P.spikeTime=0,0
	P.spikeText=love.graphics.newText(getFont(100))

	--Attacker-related
	P.badge,P.strength=0,0
	P.atkMode,P.swappingAtkMode=1,20
	P.atker,P.atking,P.lastRecv={}

	--User-related
	P.username=""
	P.uid=false
	P.sid=false

	--Block states
	--[[
		P.curX,P.curY,P.ghoY,P.minY=0,0,0,0--x,y,ghostY
		P.cur={
			id=shapeID,
			bk=matrix[2],
			sc=table[2],
			dir=direction,
			name=nameID
			color=colorID,
		}
		P.newNext=false--Warped coroutine to get new next, loaded in applyGameEnv()
	]]
	P.movDir,P.moving,P.downing=0,0,0--Last move key,DAS charging,downDAS charging
	P.dropDelay,P.lockDelay=0,0
	P.waiting,P.falling=-1,-1
	P.freshTime=0
	P.spinLast=false
	P.spinSeq=0--For Ospin, each digit mean a spin
	P.ctrlCount=0--Key press time, for finesse check

	--Game states
	P.combo=0
	P.b2b,P.b2b1=0,0--B2B point & Displayed B2B point
	P.score1=0--Displayed score
	P.pieceCount=0--Count pieces from next, for drawing bagline
	P.finesseCombo,P.finesseComboTime=0,0
	P.nextQueue={}
	P.holdQueue={}
	P.holdTime=0
	P.lastPiece={
		id=0,name=0,--block id/name

		curX=0,curY=0,--block position
		centX=0,centY=0,--center position
		dir=0,--direction

		frame=-1e99,--lock time
		autoLock=true,--if lock with gravity

		finePts=0,--finesse Points

		row=0,dig=0,--lines/garbage cleared
		score=0,--score gained
		atk=0,exblock=0,--lines attack/defend
		off=0,send=0,--lines offset/sent

		spin=false,mini=false,--if spin/mini
		pc=false,hpc=false,--if pc/hpc
		special=false,--if special clear (spin, >=4, pc)
	}
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
		if type(v)~='table'then--Default setting
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
		MES.new('warn',"Bad conf from "..P.username.."#"..P.uid)
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
		if type(v)~='table'then--Default setting
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

	P.skinLib=SKIN.lib[ENV.skinSet]

	P:setInvisible(
		ENV.visible=='show'and -1 or
		ENV.visible=='easy'and 300 or
		ENV.visible=='slow'and 100 or
		ENV.visible=='medium'and 60 or
		ENV.visible=='fast'and 20 or
		ENV.visible=='none'and 0
	)
	P:set20G(P._20G)
	P:setHold(ENV.holdCount)
	P:setNext(ENV.nextCount,ENV.nextStartPos>1)
	P:setRS(ENV.RS)

	if type(ENV.mission)=='table'then
		P.curMission=1
	end

	ENV.das=max(ENV.das,ENV.mindas)
	ENV.arr=max(ENV.arr,ENV.minarr)
	ENV.sdarr=max(ENV.sdarr,ENV.minsdarr)

	ENV.bagLine=(ENV.sequence=='bag'or ENV.sequence=='loop')and #ENV.seqData

	if ENV.nextCount==0 then ENV.nextPos=false end

	P.newNext=coroutine.wrap(getSeqGen(P))
	P:newNext(P.gameEnv.seqData)
	if ENV.noInitSZO then
		for _=1,5 do
			local C=P.nextQueue[1]
			if C and(C.id==1 or C.id==2 or C.id==6)then
				table.remove(P.nextQueue,1)
			else
				break
			end
		end
		P:newNext()
	end

	if P.miniMode then
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
	if ENV.ghost==0 then	ENV.ghost=false		end
	if ENV.grid==0 then		ENV.grid=false		end
	if ENV.center==0 then	ENV.center=false	end
	if ENV.lineNum==0 then	ENV.lineNum=false	end
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
	P.type='computer'
	P.sound=true
	P.demo=true

	P.frameRun=180
	P.draw=ply_draw.demo
	P.control=true
	GAME.modeEnv=DemoEnv
	loadGameEnv(P)
	applyGameEnv(P)
	P:loadAI{
		type='CC',
		next=5,
		hold=true,
		delay=30,
		delta=6,
		bag='bag',
		node=100000,
	}
	P:popNext()
end
function PLY.newRemotePlayer(id,mini,ply)
	local P=newEmptyPlayer(id,mini)
	P.type='remote'
	P.update=ply_update.remote_alive

	P.draw=ply_draw.norm

	P.stream={}
	P.streamProgress=1

	netPLY.setPlayerObj(ply,P)
	P.uid=ply.uid
	P.username=ply.username
	P.sid=ply.sid

	loadRemoteEnv(P,ply.config)
	applyGameEnv(P)
end
function PLY.newAIPlayer(id,AIdata,mini)
	local P=newEmptyPlayer(id,mini)
	P.type='computer'

	loadGameEnv(P)
	local ENV=P.gameEnv
	ENV.face={0,0,0,0,0,0,0}
	ENV.skin={1,7,11,3,14,4,9}
	applyGameEnv(P)
	P:loadAI(AIdata)
end
function PLY.newPlayer(id,mini)
	local P=newEmptyPlayer(id,mini)
	P.type='human'
	P.sound=true

	P.uid=USER.uid
	P.username=USERS.getUsername(USER.uid)

	loadGameEnv(P)
	applyGameEnv(P)
end
--------------------------</Public>--------------------------
return PLY