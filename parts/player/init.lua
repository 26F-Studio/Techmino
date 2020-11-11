local Player=require("parts/player/player")
local prepareSequence=require("parts/player/prepareSequence")

local mt=love.math
local rnd,max,min=math.random,math.max,math.min
local ins=table.insert

local gameEnv0=require("parts/player/gameEnv0")


local PLY={
	update=require("parts/player/update"),
	draw=require("parts/player/draw"),
}

--------------------------<Lib Func>--------------------------
local function getNewStatTable()
	local T={
		time=0,score=0,
		key=0,rotate=0,hold=0,
		extraPiece=0,finesseRate=0,
		piece=0,row=0,dig=0,
		atk=0,digatk=0,
		send=0,recv=0,pend=0,off=0,
		clear={},clears={},spin={},spins={},
		pc=0,hpc=0,b2b=0,b3b=0,
		maxCombo=0,maxFinesseCombo=0,
	}
	for i=1,25 do
		T.clear[i]={0,0,0,0,0,0}
		T.spin[i]={0,0,0,0,0,0,0}
		T.clears[i]=0
		T.spins[i]=0
	end
	return T
end
local function pressKey(P,keyID)
	if P.keyAvailable[keyID]then
		P.keyPressing[keyID]=true
		P.actList[keyID](P)
		if P.control then
			if P.keyRec then
				ins(P.keyTime,1,GAME.frame)
				P.keyTime[11]=nil
			end
		end
		P.stat.key=P.stat.key+1
	end
end
local function releaseKey(P,keyID)
	P.keyPressing[keyID]=false
end
local function pressKey_Rec(P,keyID)
	if P.keyAvailable[keyID]then
		if GAME.recording then
			ins(GAME.rec,GAME.frame+1)
			ins(GAME.rec,keyID)
		end
		P.keyPressing[keyID]=true
		P.actList[keyID](P)
		if P.control then
			if P.keyRec then
				ins(P.keyTime,1,GAME.frame)
				P.keyTime[11]=nil
			end
		end
		P.stat.key=P.stat.key+1
	end
end
local function releaseKey_Rec(P,keyID)
	if GAME.recording then
		ins(GAME.rec,GAME.frame+1)
		ins(GAME.rec,-keyID)
	end
	P.keyPressing[keyID]=false
end
local function loadGameEnv(P)--Load gameEnv
	P.gameEnv={}--Current game setting environment
	local ENV=P.gameEnv
	--Load game settings
	for k,v in next,gameEnv0 do
		if modeEnv[k]~=nil then
			v=modeEnv[k]		--Mode setting
			-- DBP("mode-"..k..":"..tostring(v))
		elseif GAME.setting[k]~=nil then
			v=GAME.setting[k]	--Game setting
			-- DBP("game-"..k..":"..tostring(v))
		elseif SETTING[k]~=nil then
			v=SETTING[k]		--Global setting
			-- DBP("global-"..k..":"..tostring(v))
		-- else
			-- DBP("default-"..k..":"..tostring(v))
		end
		if type(v)~="table"then--Default setting
			ENV[k]=v
		else
			ENV[k]=copyTable(v)
		end
	end
end
local function applyGameEnv(P)--Finish gameEnv processing
	local ENV=P.gameEnv

	P._20G=ENV.drop==0
	P.dropDelay=ENV.drop
	P.lockDelay=ENV.lock

	P.color={}
	for _=1,7 do
		P.color[_]=SKIN.libColor[ENV.skin[_]]
	end

	P.keepVisible=ENV.visible=="show"
	P.showTime=
		ENV.visible=="show"and 1e99 or
		ENV.visible=="time"and 300 or
		ENV.visible=="fast"and 20 or
		ENV.visible=="none"and 0

	P.life=ENV.life

	P.keyAvailable={true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true}
	if ENV.noTele then
		for i=11,20 do
			if i~=14 then
				P.keyAvailable[i]=false
				virtualkey[i].ava=false
			end
		end
	end
	for _,v in next,ENV.keyCancel do
		P.keyAvailable[v]=false
		virtualkey[v].ava=false
	end
	if P._20G then
		P.keyAvailable[7]=false
		virtualkey[7].ava=false
	end
	if not ENV.hold then
		P.keyAvailable[8]=false
		virtualkey[8].ava=false
	end

	if type(ENV.mission)=="table"then
		P.curMission=1
	end

	ENV.das=max(ENV.das,ENV.mindas)
	ENV.arr=max(ENV.arr,ENV.minarr)
	ENV.sdarr=max(ENV.sdarr,ENV.minsdarr)
	ENV.next=min(ENV.next,SETTING.maxNext)

	if ENV.sequence~="bag"and ENV.sequence~="loop"then
		ENV.bagLine=false
	else
		ENV.bagLen=#ENV.bag
	end

	if ENV.next==0 then ENV.nextPos=false end

	if ENV.lockFX==0 then	ENV.lockFX=nil	end
	if ENV.dropFX==0 then	ENV.dropFX=nil	end
	if ENV.moveFX==0 then	ENV.moveFX=nil	end
	if ENV.clearFX==0 then	ENV.clearFX=nil end
	if ENV.shakeFX==0 then	ENV.shakeFX=nil	end

	if ENV.ghost==0 then	ENV.ghost=nil	end
	if ENV.center==0 then	ENV.center=nil	end
end
local function newEmptyPlayer(id,x,y,size)
	local P={id=id}
	PLAYERS[id]=P
	PLAYERS.alive[id]=P

	--Inherit functions of player class
	for k,v in next,Player do P[k]=v end

	if P.id==1 and GAME.recording then
		P.pressKey=pressKey_Rec
		P.releaseKey=releaseKey_Rec
	else
		P.pressKey=pressKey
		P.releaseKey=releaseKey
	end
	P.update=PLY.update.alive

	P.fieldOff={x=0,y=0,vx=0,vy=0}--For shake FX
	P.x,P.y,P.size=x,y,size or 1
	P.frameColor=0

	P.small=P.size<.1--If draw in small mode
	if P.small then
		P.centerX,P.centerY=P.x+300*P.size,P.y+600*P.size
		P.canvas=love.graphics.newCanvas(60,120)
		P.frameWait=rnd(30,120)
		P.draw=PLY.draw.small
	else
		P.keyRec=true--If calculate keySpeed
		P.centerX,P.centerY=P.x+300*P.size,P.y+370*P.size
		P.absFieldX=P.x+150*P.size
		P.absFieldY=P.y+60*P.size
		P.draw=PLY.draw.norm
		P.bonus={}--Text objects
	end
	P.randGen=mt.newRandomGenerator(GAME.seed)

	P.small=false
	P.alive=true
	P.control=false
	P.timing=false
	P.stat=getNewStatTable()

	P.modeData={point=0,event=0,counter=0}--Data use by mode
	P.keyTime={}P.keySpeed=0
	P.dropTime={}P.dropSpeed=0
	for i=1,10 do P.keyTime[i]=-1e5 end
	for i=1,10 do P.dropTime[i]=-1e5 end

	P.field,P.visTime={},{}
	P.atkBuffer={sum=0}

	--Royale-related
	P.badge,P.strength=0,0
	P.atkMode,P.swappingAtkMode=1,20
	P.atker,P.atking,P.lastRecv={}

	P.dropDelay,P.lockDelay=0,0
	P.color={}
	P.showTime=nil
	P.keepVisible=true

	--P.cur={bk=matrix[2], id=shapeID, color=colorID, name=nameID}
	--P.sc,P.dir={0,0},0--SpinCenterCoord, direction
	--P.r,P.c=0,0--row, col
	--P.hd={...},same as P.cur
	-- P.curX,P.curY,P.imgY,P.minY=0,0,0,0--x,y,ghostY
	P.holded=false
	P.next={}
	P.seqData={}

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

	P.human=false
	P.sound=false
	P:setRS("TRS")

	-- P.newNext=nil--Call prepareSequence()to get a function to get new next

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
	P.bonus={}--Texts

	P.endCounter=0--Used after gameover
	P.result=nil--String:"WIN"/"K.O."

	return P
end
--------------------------</Lib Func>--------------------------

--------------------------<Public>--------------------------
function PLY.check_lineReach(P)
	if P.stat.row>=P.gameEnv.target then
		P:win("finish")
end
end
function PLY.check_attackReach(P)
	if P.stat.atk>=P.gameEnv.target then
		P:win("finish")
	end
end

function PLY.newDemoPlayer(id,x,y,size)
	local P=newEmptyPlayer(id,x,y,size)
	P.sound=true

	-- rewrite some args
	P.small=false
	P.centerX,P.centerY=P.x+300*P.size,P.y+600*P.size
	P.absFieldX=P.x+150*P.size
	P.absFieldY=P.y+60*P.size
	P.draw=PLY.draw.demo
	P.control=true
	P.gameEnv={
		das=10,arr=2,sddas=2,sdarr=2,
		swap=true,

		ghost=SETTING.ghost,
		center=SETTING.center,
		smooth=SETTING.smooth,
		grid=SETTING.grid,
		text=SETTING.text,
		score=SETTING.score,
		lockFX=SETTING.lockFX,
		dropFX=SETTING.dropFX,
		moveFX=SETTING.moveFX,
		clearFX=SETTING.clearFX,
		shakeFX=SETTING.shakeFX,

		drop=1e99,lock=1e99,
		wait=10,fall=20,
		bone=false,
		next=6,
		hold=true,oncehold=true,
		ospin=true,
		sequence="bag",
		bag={1,2,3,4,5,6,7},
		face={0,0,0,0,0,0,0},
		skin=copyTable(SETTING.skin),
		mission=false,

		life=1e99,
		pushSpeed=3,
		block=true,
		noTele=false,
		visible="show",
		freshLimit=1e99,easyFresh=true,

		keyCancel={},
		mindas=0,minarr=0,minsdarr=0,
	}
	applyGameEnv(P)
	prepareSequence(P)
	P:loadAI({
		type="CC",
		next=5,
		hold=true,
		delay=30,
		delta=4,
		bag="bag",
		node=100000,
	})

	P:popNext()
end
function PLY.newRemotePlayer(id,x,y,size)
	local P=newEmptyPlayer(id,x,y,size)
	P.remote=true

	-- P.updateAction=buildActionFunctionFromActions(P, actions)

	loadGameEnv(P)
	applyGameEnv(P)
	prepareSequence(P)
end
function PLY.newAIPlayer(id,x,y,size,AIdata)
	local P=newEmptyPlayer(id,x,y,size)

	loadGameEnv(P)
	local ENV=P.gameEnv
	ENV.face={0,0,0,0,0,0,0}
	ENV.skin={1,7,11,3,14,4,9}
	if P.small then
		ENV.text=false
		ENV.lockFX=nil
		ENV.dropFX=nil
		ENV.moveFX=nil
		ENV.shakeFX=nil
	end
	applyGameEnv(P)
	prepareSequence(P)
	P:loadAI(AIdata)
end
function PLY.newPlayer(id,x,y,size)
	local P=newEmptyPlayer(id,x,y,size)
	P.human=true
	P.sound=true

	loadGameEnv(P)
	applyGameEnv(P)
	prepareSequence(P)

end
--------------------------</Public>--------------------------
return PLY