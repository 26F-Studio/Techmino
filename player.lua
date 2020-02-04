-------------------------<Head>-------------------------
local int,ceil,abs,rnd,max,min=math.floor,math.ceil,math.abs,math.random,math.max,math.min
local ins,rem=table.insert,table.remove
local gc=love.graphics
local Timer=love.timer.getTime
local format=string.format
local scr=scr--screen camera
-------------------------</Head>-------------------------

-------------------------<GameData>-------------------------
local gameEnv0={
	das=10,arr=2,
	sddas=2,sdarr=2,
	quickR=true,swap=true,
	ghost=true,center=true,
	grid=false,swap=true,
	_20G=false,bone=false,
	drop=60,lock=60,
	wait=0,fall=0,
	next=6,hold=true,oncehold=true,
	sequence="bag7",

	block=true,
	visible="show",--keepVisible=visile~="show"
	Fkey=NULL,puzzle=false,ospin=true,
	freshLimit=1e99,easyFresh=true,
	fine=false,fineKill=false,
	target=1e99,dropPiece="null",
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
local spinName={"zspin","sspin","lspin","jspin","tspin","ospin","ispin"}
local clearName={"single","double","triple"}
local spin_n={[0]="spin_0","spin_1","spin_2","spin_3"}
local clear_n={"clear_1","clear_2","clear_3","clear_4"}
local ren_n={}for i=1,11 do ren_n[i]="ren_"..i end
local blockPos={4,4,4,4,4,5,4}
local TMP1,TMP2,TMP3,TMP4={1,2},{2,1},{2,2},{1.5,1.5}----------save cache
local scs={
	{[0]=TMP1,TMP2,TMP3,TMP3},
	{[0]=TMP1,TMP2,TMP3,TMP3},
	{[0]=TMP1,TMP2,TMP3,TMP3},
	{[0]=TMP1,TMP2,TMP3,TMP3},
	{[0]=TMP1,TMP2,TMP3,TMP3},
	{[0]=TMP4,TMP4,TMP4,TMP4},
	{[0]={0.5,2.5},{2.5,0.5},{1.5,2.5},{2.5,1.5}},
}
local CCblockID={4,3,5,6,1,2,0}
TMP1={0,0}
local TRS={
	[1]={
		[01]={TMP1,{-1,0},	{-1,1},	{0,-2},	{-1,-2},{0,1}	},
		[10]={TMP1,{1,0},	{1,-1},	{0,2},	{1,2},	{0,-1}	},
		[03]={TMP1,{1,0},	{1,1},	{0,-2},	{1,-1},	{1,-2}	},
		[30]={TMP1,{-1,0},	{-1,-1},{0,2},			{-1,2},	{0,-1}},
		[12]={TMP1,{1,0},	{1,-1},	{0,2},	{1,2}	},
		[21]={TMP1,{-1,0},	{-1,1},	{0,-2},	{-1,-2}	},
		[32]={TMP1,{-1,0},	{-1,-1},{0,2},	{-1,2}	},
		[23]={TMP1,{1,0},	{1,1},	{0,-2},	{1,-2}	},
		[02]={TMP1,{1,0},	{-1,0},	{0,-1},	{0,1}	},
		[20]={TMP1,{-1,0},	{1,0},	{0,1},	{0,-1}	},
		[13]={TMP1,{0,-1},	{0,1},	{-1,0},	{0,-2}	},
		[31]={TMP1,{0,1},	{0,-1},	{1,0},	{0,2}	},
	},--Z
	[2]={
		[01]={TMP1,{-1,0},	{-1,1},	{0,-2},	{-1,-1},{-1,-2}	},
		[10]={TMP1,{1,0},	{1,-1},	{0,2},			{1,2},	{0,-1}},
		[03]={TMP1,{1,0},	{1,1},	{0,-2},	{1,-2},	{0,1}	},
		[30]={TMP1,{-1,0},	{-1,-1},{0,2},	{-1,2},	{0,-1}	},
		[12]={TMP1,{1,0},	{1,-1},	{0,2},	{1,2}	},
		[21]={TMP1,{-1,0},	{-1,1},	{0,-2},	{-1,-2}	},
		[32]={TMP1,{-1,0},	{-1,-1},{0,2},	{-1,2}	},
		[23]={TMP1,{1,0},	{1,1},	{0,-2},	{1,-2}	},
		[02]={TMP1,{-1,0},	{1,0},	{0,-1},	{0,1}	},
		[20]={TMP1,{1,0},	{-1,0},	{0,1},	{0,-1}	},
		[13]={TMP1,{0,1},	{0,-1},	{-1,0},	{0,2}	},
		[31]={TMP1,{0,-1},	{0,1},	{1,0},	{0,-2}	},
	},--S
	[3]={
		[01]={TMP1,{-1,0},	{-1,1},	{0,-2},	{-1,-2},{0,1},	{-1,-1}	},
		[10]={TMP1,{1,0},	{1,-1},	{0,2},	{1,2},	{0,-1},	{1,1}	},
		[03]={TMP1,{1,0},	{1,1},	{0,-2},	{-1,1}	},
		[30]={TMP1,{-1,0},	{-1,-1},{0,2},	{-1,2}	},
		[12]={TMP1,{1,0},	{1,-1},	{0,2},	{1,2},	{1,1}	},
		[21]={TMP1,{-1,0},	{-1,1},	{0,-2},	{-1,-2},{-1,-1}	},
		[32]={TMP1,{-1,0},	{-1,-1},{1,0},	{0,2},	{-1,2}	},
		[23]={TMP1,{1,0},	{1,1},	{-1,0},	{0,-2},	{1,-2}	},
		[02]={TMP1,{1,0},	{-1,0},	{0,-1},	{0,1}	},
		[20]={TMP1,{-1,0},	{1,0},	{0,1},	{0,-1}	},
		[13]={TMP1,{0,1},	{1,0},	{0,-1}	},
		[31]={TMP1,{0,-1},	{-1,0},	{0,1}	},
	},--L
	[4]={
		[01]={TMP1,{-1,0},	{-1,1},	{0,-2},	{1,1}	},
		[10]={TMP1,{1,0},	{1,-1},	{0,2},	{1,2}	},
		[03]={TMP1,{1,0},	{1,1},	{0,-2},	{1,-2},	{0,1},	{1,-1}	},
		[30]={TMP1,{-1,0},	{-1,-1},{0,2},	{-1,2},	{0,-1},	{-1,1}	},
		[12]={TMP1,{1,0},	{1,-1},	{-1,0},	{0,2},	{1,2}	},
		[21]={TMP1,{-1,0},	{-1,1},	{1,0},	{0,-2},	{-1,-2}	},
		[32]={TMP1,{-1,0},	{-1,-1},{0,2},	{-1,2},	{-1,1}	},
		[23]={TMP1,{1,0},	{1,1},	{0,-2},	{1,-2},	{1,-1}	},
		[02]={TMP1,{-1,0},	{1,0},	{0,-1},	{0,1}	},
		[20]={TMP1,{1,0},	{-1,0},	{0,1},	{0,-1}	},
		[13]={TMP1,{0,-1},	{1,0},	{0,1}	},
		[31]={TMP1,{0,1},	{-1,0},	{0,-1}	},
	},--J
	[5]={
		[01]={TMP1,{-1,0},	{-1,1},	{0,-2},	{-1,-2},{-1,-1}	},
		[10]={TMP1,{1,0},	{1,-1},	{0,2},	{1,2},	{0,-1},	{1,1}},
		[03]={TMP1,{1,0},	{1,1},	{0,-2},	{1,-2}	},
		[30]={TMP1,{-1,0},	{-1,-1},{0,2},	{-1,2},	{0,-1}	},
		[12]={TMP1,{1,0},	{1,-1},	{0,-1},	{0,2},	{1,2},	{-1,-1}},
		[21]={TMP1,{-1,0},	{-1,1},	{0,-2},	{-1,-2},{1,1}	},
		[32]={TMP1,{-1,0},	{-1,-1},{0,-1},	{0,2},	{-1,2},	{1,-1}},
		[23]={TMP1,{1,0},	{1,1},	{0,-2},	{1,-2},	{-1,1}	},
		[02]={TMP1,{-1,0},	{1,0},	{0,1}	},
		[20]={TMP1,{1,0},	{-1,0},	{0,-1}	},
		[13]={TMP1,{0,-1},	{0,1},	{1,0},	{0,-2},	{0,2}},
		[31]={TMP1,{0,-1},	{0,1},	{-1,0},	{0,-2},	{0,2}},
	},--T
	[6]={},--O(special)
	[7]={
		[01]={TMP1,{0,1},	{1,0},	{-2,0},	{-2,-1},{1,2}	},
		[03]={TMP1,{0,1},	{-1,0},	{2,0},	{2,-1},	{-1,2}	},
		[10]={TMP1,{2,0},	{-1,0},	{-1,-2},{2,1},	{0,2}	},
		[30]={TMP1,{-2,0},	{1,0},	{1,-2},	{-2,1},	{0,2}	},
		[12]={TMP1,{-1,0},	{2,0},	{-1,2},	{2,-1}	},
		[32]={TMP1,{1,0},	{-2,0},	{1,-2},	{-2,-1}	},
		[21]={TMP1,{-2,0},	{1,0},	{1,-2},	{-2,1}	},
		[23]={TMP1,{2,0},	{-1,0},	{-1,-2},{2,1}	},
		[02]={TMP1,{-1,0},	{1,0},	{0,-1},	{0,1}	},
		[20]={TMP1,{1,0},	{-1,0},	{0,1},	{0,-1}	},
		[13]={TMP1,{0,-1},	{-1,0},	{1,0},	{0,1}	},
		[31]={TMP1,{1,0},	{-1,0}},
	}
}
local AIRS={{
	[01]={TMP1,{-1,0},	{-1,1},	{0,-2},	{-1,-2}	},
	[10]={TMP1,{1,0},	{1,-1},	{0,2},	{1,2}	},
	[03]={TMP1,{1,0},	{1,1},	{0,-2},	{1,-2}	},
	[30]={TMP1,{-1,0},	{-1,-1},{0,2},	{-1,2}	},
	[12]={TMP1,{1,0},	{1,-1},	{0,2},	{1,2}	},
	[21]={TMP1,{-1,0},	{-1,1},	{0,-2},	{-1,-2}	},
	[32]={TMP1,{-1,0},	{-1,-1},{0,2},	{-1,2}	},
	[23]={TMP1,{1,0},	{1,1},	{0,-2},	{1,-2}	},
}}for i=2,6 do AIRS[i]=AIRS[1]end
AIRS[7]={
	[01]={TMP1,{-2,0},	{1,0},	{-2,-1},{1,2}	},
	[10]={TMP1,{2,0},	{-1,0},	{2,1},	{-1,-2}	},
	[12]={TMP1,{-1,0},	{2,0},	{-1,2},	{2,-1}	},
	[21]={TMP1,{1,0},	{-2,0},	{1,-2},	{-2,1}	},
	[23]={TMP1,{2,0},	{-1,0},	{2,1},	{-1,-2}	},
	[32]={TMP1,{-2,0},	{1,0},	{-2,-1},{1,2}	},
	[30]={TMP1,{1,0},	{-2,0},	{1,-2},	{-2,1}	},
	[03]={TMP1,{-1,0},	{2,0},	{-1,2},	{2,-1}	},
}
local TMP1={
	[1]={
		{1,2,1,0,1,2,2,1},
		{2,2,3,1,1,2,3,2,2},
	},--Z
	[3]={
		{1,2,1,0,1,2,2,1},
		{2,2,3,2,1,2,3,3,2},
		{3,4,3,2,3,4,4,3},
		{2,3,2,1,2,3,3,2,2},
	},--L
	[6]={
		{1,2,2,1,0,1,2,2,1},
	},--O
	[7]={
		{1,2,1,0,1,2,1},
		{2,2,2,2,1,1,2,2,2,2},
	},--I
}--SZI逆态视为顺态，JLT算法相同
TMP1[2]=TMP1[1]
TMP1[4]=TMP1[3]
TMP1[5]=TMP1[3]
local finesseCtrlPar=TMP1
TMP1,TMP2,TMP3,TMP4=nil----------release
local CCblockID={4,3,5,6,1,2,0}
local freshMethod={
	none=NULL,
	bag7=function(P)
		if #P.next<6 then
			local bag={1,2,3,4,5,6,7}
			::L::P:newNext(rem(bag,rnd(#bag)))
			if bag[1]then goto L end
		end
	end,
	his4=function(P)
		if #P.next<6 then
			local j,i=0
			repeat
				i,j=rnd(7),j+1
			until i~=P.his[1]and i~=P.his[2]and i~=P.his[3]and i~=P.his[4]
			P:newNext(i)
			rem(P.his,1)P.his[4]=i
		end
	end,
	rnd=function(P)
		::L::local i=rnd(7)
		if i==P.next[5]then goto L end
		P:newNext(i)
	end,--random
	drought1=function(P)
		if #P.next<6 then
			local bag={1,2,3,4,5,6}
			::L::P:newNext(rem(bag,rnd(#bag)))
			if bag[1]then goto L end
		end
	end,
	drought2=function(P)
		if #P.next<6 then
			local bag={1,1,1,1,2,2,2,2,6,6,6,6,3,3,4,4,5,7}
			::L::P:newNext(rem(bag,rnd(#bag)))
			if bag[1]then goto L end
		end
	end,
}
-------------------------</GameData>-------------------------
local frameColor={
	[0]=color.white,
	color.lightGreen,
	color.lightBlue,
	color.lightPurple,
	color.lightOrange,
}
local attackColor={
	{color.darkGrey,color.white},
	{color.grey,color.white},
	{color.lightPurple,color.white},
	{color.lightRed,color.white},
	{color.darkGreen,color.cyan},
}
local function drawPixel(y,x,id)
	gc.draw(blockSkin[id],30*x-30,600-30*y)
end
local function drawDial(x,y,speed)
	gc.setColor(1,1,1)
	mStr(int(speed),x,y-18)
	gc.draw(dialCircle,x,y,nil,nil,nil,32,32)
	gc.setColor(1,1,1,.6)
	gc.draw(dialNeedle,x,y,2.094+(speed<=175 and .02094*speed or 4.712-52.36/(speed-125)),nil,nil,5,4)
end
--------------Used in draw player↑

player={}local player=player
function newDemoPlayer(id,x,y,size)
	local P={id=id}players[id]=P
	P.invincible=true
	for k,v in next,player do P[k]=v end
	players.alive[#players.alive+1]=P
	P.x,P.y,P.size=x,y,size
	P.fieldOff={x=0,y=0,vx=0,vy=0}
	P.small,P.keyRec=false,false

	P.centerX,P.centerY=P.x+300*P.size,P.y+670*P.size
	P.absFieldX=P.x+150*P.size
	P.absFieldY=P.y+60*P.size

	P.alive=true
	P.control=true
	P.timing=false
	P.stat={
		time=0,score=0,
		key=0,extraPiece=0,extraRate=0,
		rotate=0,hold=0,piece=0,row=0,
		atk=0,send=0,recv=0,pend=0,
		clear_1=0,clear_2=0,clear_3=0,clear_4=0,
		spin_0=0,spin_1=0,spin_2=0,spin_3=0,
		pc=0,b2b=0,b3b=0,
	}
	P.modeData={point=0,event=0}
	P.keyTime={}for i=1,10 do P.keyTime[i]=-1e5 end P.keySpeed=0
	P.dropTime={}for i=1,10 do P.dropTime[i]=-1e5 end P.dropSpeed=0

	P.atker={}
	P.strength=0

	P.field,P.visTime={},{}
	P.atkBuffer={sum=0}
	P.gameEnv={
		das=5,arr=2,
		sddas=2,sdarr=2,
		_20G=false,bone=false,
		drop=1e99,lock=1e99,
		wait=10,fall=20,
		next=6,hold=true,oncehold=true,
		sequence="bag7",
	
		block=true,
		visible="show",
		Fkey=NULL,puzzle=false,ospin=true,
		freshLimit=1e99,easyFresh=true,
		target=1e99,dropPiece="null",
	}
	P.cur={bk={{}},id=0,color=0,name=0}
		P.sc,P.dir,P.r,P.c={0,0},0,0,0
		P.curX,P.curY,P.y_img=0,0,0
	P.hd={bk={{}},id=0,color=0,name=0}
		P.holded=false
	P.next={}

	P.dropDelay,P.lockDelay=1e99,1e99
	P.freshTime=0
	P.spinLast,P.lastClear=false,nil
	P.spinSeq=0
	P.ctrlCount=0

	local bag1={1,2,3,4,5,6,7}
	for _=1,7 do
		P:newNext(rem(bag1,rnd(#bag1)))
	end
	P.freshNext=freshMethod.bag7
	if P.gameEnv.sequence==1 then P.bag={}--Bag7
	elseif P.gameEnv.sequence==2 then P.his={}for i=1,4 do P.his[i]=P.next.id[i+3]end--History4
	elseif P.gameEnv.sequence==3 then--Pure random
	end

	P.human=false
	P.AI_mode="CC"
	P.AI_stage=1
	P.AI_needFresh=false
	P.AI_keys={}
	P.AI_delay,P.AI_delay0=3,3
	P.AIdata={next=5,hold=true,_20G=false,bag7=true,node=80000}
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
		local CCBID={4,3,5,6,1,2,0}
		for i=1,5 do
			BOT.addNext(P.AI_bot,CCBID[P.next[i].id])
		end
	elseif P.AI_mode=="9S"then
		P.RS=TRS
	end
	P.showTime=1e99
	P.keepVisible=true
	P.keyPressing={}for i=1,12 do P.keyPressing[i]=false end
	P.moving,P.downing=0,0
	P.waiting,P.falling=-1,-1
	P.clearing,P.cleared={},{}
	P.combo,P.b2b=0,0
	P.fieldBeneath=0
	P.shade={}
	P.score1,P.b2b1=0,0
	P.bonus={}--texts

	P:resetblock()
	PTC.dust[1]=PTC.dust0:clone()
end
function newPlayer(id,x,y,size,AIdata)
	players[id]={id=id}
    local P=players[id]
    for k,v in next,player do P[k]=v end--Class function
	players.alive[#players.alive+1]=P
	P.x,P.y,P.size=x,y,size or 1
	P.fieldOff={x=0,y=0,vx=0,vy=0}--for shake FX
	P.small=P.size<.1--if draw in small mode
	P.keyRec=not P.small--if calculate keySpeed
	if P.small then
		P.centerX,P.centerY=P.x+300*P.size,P.y+600*P.size
		P.canvas=love.graphics.newCanvas(60,120)
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
		time=0,score=0,
		key=0,extraPiece=0,extraRate=0,
		rotate=0,hold=0,piece=0,row=0,
		atk=0,send=0,recv=0,pend=0,
		clear_1=0,clear_2=0,clear_3=0,clear_4=0,
		spin_0=0,spin_1=0,spin_2=0,spin_3=0,
		pc=0,b2b=0,b3b=0,
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

	P.gameEnv={}--Current game setting environment
	for k,v in next,gameEnv0 do
		if modeEnv[k]~=nil then
			P.gameEnv[k]=modeEnv[k]
		elseif setting[k]~=nil then
			P.gameEnv[k]=setting[k]
		else
			P.gameEnv[k]=v
		end
	end--reset current game settings
	P.cur={bk={{}},id=0,color=0,name=0}
		P.sc,P.dir,P.r,P.c={0,0},0,0,0
		P.curX,P.curY,P.y_img=0,0,0
	P.hd={bk={{}},id=0,color=0,name=0}
		P.holded=false
	P.next={}

	P.dropDelay,P.lockDelay=P.gameEnv.drop,P.gameEnv.lock
	P.freshTime=0
	P.spinLast,P.lastClear=false,nil
	P.spinSeq=0--for Ospin,each digit mean a spin
	P.ctrlCount=0--key press time,for finesse check

	P.his={rnd(7),rnd(7),rnd(7),rnd(7)}
	local s=P.gameEnv.sequence
	if s=="bag7"or s=="his4"then
		local bag1={1,2,3,4,5,6,7}
		for _=1,7 do
			P:newNext(rem(bag1,rnd(#bag1)))
		end
	elseif s=="rnd"then
		for _=1,6 do
			local r=rnd(7)
			P:newNext(r)
		end
	elseif s=="drought1"then
		local bag1={1,2,3,4,5,6}
		for _=1,6 do
			P:newNext(rem(bag1,rnd(#bag1)))
		end
	elseif s=="drought2"then
		local bag1={1,2,3,4,6,6}
		for _=1,6 do
			P:newNext(rem(bag1,rnd(#bag1)))
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
		end
	else
		P.human=true
		P.RS=TRS
		players.human=players.human+1
	end

	P.showTime=visible_opt[P.gameEnv.visible]
	P.keepVisible=P.gameEnv.visible=="show"
	P.keyPressing={}for i=1,12 do P.keyPressing[i]=false end
	P.moving,P.downing=0,0
	P.waiting,P.falling=-1,-1
	P.clearing,P.cleared={},{}
	P.combo,P.b2b=0,0
	P.fieldBeneath=0

	P.shade={}
	P.score1,P.b2b1=0,0
	P.bonus={}--texts

	P.endCounter=0--used after gameover
	P.counter=0--many usage
	P.result=nil--string:win/lose
end
function player.update(P,dt)
	if P.timing then P.stat.time=P.stat.time+dt end
	if P.alive then
		if P.keyRec then
			local v=0
			for i=2,10 do v=v+i*(i-1)*7.2/(frame-P.keyTime[i])end P.keySpeed=P.keySpeed*.99+v*.1
			v=0
			for i=2,10 do v=v+i*(i-1)*7.2/(frame-P.dropTime[i])end P.dropSpeed=P.dropSpeed*.99+v*.1
			--Update speeds
			if modeEnv.royaleMode then
				if P.keyPressing[9]then
					P.swappingAtkMode=min(P.swappingAtkMode+2,30)
				else
					P.swappingAtkMode=P.swappingAtkMode+((#P.field>15 and P.swappingAtkMode>4 or P.swappingAtkMode>8)and -1 or 1)
				end
			end
		end

		if not P.human and P.control and P.waiting==-1 then
			local C=P.AI_keys
			P.AI_delay=P.AI_delay-1
			if not C[1]then
				P.AI_stage=AI_think[P.AI_mode][P.AI_stage](P,C)
			elseif P.AI_delay<=0 then
				P:pressKey(C[1])P:releaseKey(C[1])
				local k=#C for i=1,k do C[i]=C[i+1]end--table.remove(C,1)
				P.AI_delay=P.AI_delay0*2
			end
		end
		if not P.keepVisible then
			for j=1,#P.field do for i=1,10 do
				if P.visTime[j][i]>0 then P.visTime[j][i]=P.visTime[j][i]-1 end
			end end
		end--Fresh visible time
		if P.moving<0 then
			if P.keyPressing[1]then
				if -P.moving<=P.gameEnv.das then
					P.moving=P.moving-1
				elseif P.waiting==-1 then
					local x=P.curX
					if P.gameEnv.arr>0 then
						P.act.moveLeft(P,true)
					else
						P.act.insLeft(P,true)
					end
					if x~=P.curX then
						P.moving=P.moving+P.gameEnv.arr-1
					elseif not P.small then
						P.fieldOff.vx=-setting.shakeFX*.8
					end
				end
			else
				P.moving=0
			end
		elseif P.moving>0 then
			if P.keyPressing[2]then
				if P.moving<=P.gameEnv.das then
					P.moving=P.moving+1
				elseif P.waiting==-1 then
					local x=P.curX
					if P.gameEnv.arr>0 then
						P.act.moveRight(P,true)
					else
						P.act.insRight(P,true)
					end
					if x~=P.curX then
						P.moving=P.moving-P.gameEnv.arr+1
					elseif not P.small then
						P.fieldOff.vx=setting.shakeFX*.8
					end
				end
			else
				P.moving=0
			end
		end
		if P.keyPressing[7]and not P.keyPressing[9]then
			local d=P.downing-P.gameEnv.sddas
			P.downing=P.downing+1
			if d>1 then
				if P.gameEnv.sdarr>0 then
					if d%P.gameEnv.sdarr==0 then
						P.act.down1(P)
					end
				else
					P.act.insDown(P)
				end
				if not P.small then
					P.fieldOff.vy=setting.shakeFX*.5
				end			
			end
		else
			P.downing=0
		end
		if P.falling>=0 then
			P.falling=P.falling-1
			if P.falling>=0 then
				goto stop
			else
				local L=#P.clearing
				if P.human and P.gameEnv.fall>0 and #P.field+L>P.clearing[L]then SFX("fall")end
				P.clearing,P.cleared={},{}
			end
		end
		if not P.control then goto stop end
		if P.waiting>=0 then
			P.waiting=P.waiting-1
			if P.waiting==-1 then P:resetblock()end
			goto stop
		end
		if P.curY~=P.y_img then
			if P.dropDelay>=0 then
				P.dropDelay=P.dropDelay-1
				if P.dropDelay>0 then goto stop end
			end
			P.curY=P.curY-1
			P.spinLast=false
			if P.y_img~=P.curY then
				P.dropDelay=P.gameEnv.drop
			elseif P.AI_mode=="CC"then
				P.AI_needFresh=true
				if not P.AIdata._20G and P.gameEnv.drop<P.AI_delay0*.5 then
					CC_switch20G(P)
				end
			end
			if P.freshTime<=P.gameEnv.freshLimit then
				P.lockDelay=P.gameEnv.lock
			end
		else
			P.lockDelay=P.lockDelay-1
			if P.lockDelay>=0 then goto stop end
			P:drop()
			if P.AI_mode=="CC"then
				P.AI_needFresh=true
			end
		end
		::stop::
		if P.b2b1==P.b2b then
		elseif P.b2b1<P.b2b then
			P.b2b1=min(P.b2b1*.98+P.b2b*.02+.4,P.b2b)
		else
			P.b2b1=max(P.b2b1*.95+P.b2b*.05-.6,P.b2b)
		end
		--Alive
	else
		if not P.small then
			P.keySpeed=P.keySpeed*.96+P.stat.key/P.stat.time*60*.04
			P.dropSpeed=P.dropSpeed*.96+P.stat.piece/P.stat.time*60*.04
			--Final average speeds
			if modeEnv.royaleMode then
				P.swappingAtkMode=min(P.swappingAtkMode+2,30)
			end
		end
		if P.falling>=0 then
			P.falling=P.falling-1
			if P.falling>=0 then
				goto stop
			else
				local L=#P.clearing
				if P.human and P.gameEnv.fall>0 and #P.field+L>P.clearing[L]then SFX("fall")end
				P.clearing,P.cleared={},{}
			end
		end::stop::
		if P.endCounter<40 then
			for j=1,#P.field do for i=1,10 do
				if P.visTime[j][i]<20 then P.visTime[j][i]=P.visTime[j][i]+.5 end
			end end--Make field visible
		end
		if P.b2b1>0 then P.b2b1=max(0,P.b2b1*.92-1)end
		--Dead
	end
	if P.stat.score>P.score1 then
		if P.stat.score-P.score1<10 then
			P.score1=P.score1+1
		else
			P.score1=int(min(P.score1*.9+P.stat.score*.1+1))
		end
	end
	for i=#P.shade,1,-1 do
		local S=P.shade[i]
		S[1]=S[1]-1+setting.dropFX*.25
		if S[1]<=0 then
			rem(P.shade,i)
		end
	end
	
	if setting.shakeFX>0 then
		local O=P.fieldOff
		O.vx,O.vy=O.vx*.8-abs(O.x)^1.2*(O.x>0 and .08 or -.08),O.vy*.8-abs(O.y)^1.2*(O.y>0 and .08 or -.08)
		O.x,O.y=O.x+O.vx,O.y+O.vy
	end--field shaking

	for i=#P.bonus,1,-1 do
		local b=P.bonus[i]
		if b.inf then
			if b.t<30 then
				b.t=b.t+.5
			end
		else
			b.t=b.t+b.speed
			if b.t>=60 then rem(P.bonus,i)end
		end
	end

	for i=#P.atkBuffer,1,-1 do
		local A=P.atkBuffer[i]
		A.time=A.time+1
		if not A.sent then
			if A.countdown>0 then
				A.countdown=max(A.countdown-garbageSpeed,0)
			end
		else
			if A.time>20 then
				rem(P.atkBuffer,i)
			end
		end
	end
	if P.fieldBeneath>0 then P.fieldBeneath=max(P.fieldBeneath-pushSpeed,0)end
	if not P.small then
		PTC.dust[P.id]:update(dt)
	end
end
function player.draw(P)
	if P.small then
		P.frameWait=P.frameWait-1
		if P.frameWait==0 then
			P.frameWait=8
			gc.setCanvas(P.canvas)
			gc.clear(0,0,0,.4)
			gc.push("transform")
			gc.origin()
			gc.setColor(1,1,1,P.result and max(20-P.endCounter,0)*.05 or 1)
			local F=P.field
			for j=1,#F do
				for i=1,10 do if F[j][i]>0 then
					gc.draw(blockSkinmini[F[j][i]],6*i-6,120-6*j)
				end end
			end--Field
			if P.alive then
				gc.setLineWidth(2)
				gc.setColor(frameColor[P.strength])gc.rectangle("line",1,1,58,118)
			end--Draw boarder
			if modeEnv.royaleMode then
				gc.setColor(1,1,1)
				for i=1,P.strength do
					gc.draw(badgeIcon,12*i-7,4,nil,.5)
				end
			end
			if P.result then
				gc.setColor(1,1,1,min(P.endCounter,60)*.01)
				setFont(22)mStr(P.result,32,47)
				setFont(20)mStr(P.rank,30,82)
			end
			gc.pop()
			gc.setCanvas()
			--draw content
		end
		gc.setColor(1,1,1)
		gc.draw(P.canvas,P.x,P.y,nil,P.size*10)
		if P.killMark then
			gc.setLineWidth(3)
			gc.setColor(1,0,0,min(P.endCounter,25)*.04)
			gc.circle("line",P.centerX,P.centerY,(840-20*min(P.endCounter,30))*P.size)
		end
		--draw Canvas
	else
		gc.push("transform")
		gc.translate(P.x,P.y)gc.scale(P.size)
		--Camera
		gc.setColor(0,0,0,.6)gc.rectangle("fill",0,0,600,690)
		gc.setLineWidth(7)gc.setColor(frameColor[P.strength])gc.rectangle("line",0,0,600,690,3)
		--Frame
		gc.translate(150+P.fieldOff.x,70+P.fieldOff.y)
		if P.gameEnv.grid then
			gc.setLineWidth(1)
			gc.setColor(1,1,1,.2)
			for x=1,9 do gc.line(30*x,-10,30*x,600)end
			for y=0,19 do
				y=30*(y-int(P.fieldBeneath/30))+P.fieldBeneath
				gc.line(0,y,300,y)
			end
		end--Grid
		gc.translate(0,P.fieldBeneath)
		gc.setScissor(scr.x+(P.absFieldX+P.fieldOff.x)*scr.k,scr.y+(P.absFieldY+P.fieldOff.y)*scr.k,300*P.size*scr.k,610*P.size*scr.k)
			if P.falling==-1 then
				for j=int(P.fieldBeneath/30+1),#P.field do
					for i=1,10 do
						if P.field[j][i]>0 then
							gc.setColor(1,1,1,min(P.visTime[j][i]*.05,1))
							drawPixel(j,i,P.field[j][i])
						end
					end
				end
			else--field block only
				local dy,stepY=0,setting.smo and(P.falling/(P.gameEnv.fall+1))^2.5*30 or 30
				local A=P.falling/P.gameEnv.fall
				local h,H=1,#P.field
				for j=int(P.fieldBeneath/30+1),H do
					while j==P.clearing[h]do
						h=h+1
						dy=dy+stepY
						gc.translate(0,-stepY)
						gc.setColor(1,1,1,A)
						gc.rectangle("fill",0,630-30*j,300,stepY)
					end
					for i=1,10 do
						if P.field[j][i]>0 then
							gc.setColor(1,1,1,min(P.visTime[j][i]*.05,1))
							drawPixel(j,i,P.field[j][i])
						end
					end
				end
				gc.translate(0,dy)
			end--Field with falling animation
			for i=1,#P.shade do
				local S=P.shade[i]
				gc.setColor(1,1,1,S[1]*.12)
				for x=S[3],S[5]do
					for y=S[6],S[4]do
						drawPixel(y,x,S[2])
					end
				end
			end--shade FX
			if P.waiting==-1 then
				if P.gameEnv.ghost then
					gc.setColor(1,1,1,.3)
					for i=1,P.r do for j=1,P.c do
						if P.cur.bk[i][j]then
							drawPixel(i+P.y_img-1,j+P.curX-1,P.cur.color)
						end
					end end
				end--Ghost
				-- local dy=setting.smo and(P.y_img~=P.curY and  or 1)^4*30 or 0
				local dy
				if setting.smo then
					if P.y_img~=P.curY then
						dy=(min(P.dropDelay,1e99)/P.gameEnv.drop-1)*30
					else
						dy=0
					end
					--[[
					if P.y_img~=P.curY then
						dy=(min(P.dropDelay,8e98)/P.gameEnv.drop)^4*30
					else
						dy=(min(P.lockDelay,8e98)/P.gameEnv.lock)^(P.gameEnv._20G and 3 or 7)*30
					end
					]]
				else
					dy=0
				end
				gc.translate(0,-dy)
				local trans=P.lockDelay/P.gameEnv.lock
				if P.gameEnv.block then
					gc.setColor(1,1,1,trans)
					for i=1,P.r do for j=1,P.c do
						if P.cur.bk[i][j]then
							gc.rectangle("fill",30*(j+P.curX-1)-33,597-30*(i+P.curY-1),36,36)
						end
					end end--BlockShade(lockdelay indicator)
					gc.setColor(1,1,1)
					for i=1,P.r do for j=1,P.c do
						if P.cur.bk[i][j]then
							drawPixel(i+P.curY-1,j+P.curX-1,P.cur.color)
						end
					end end--Block
				end
				if P.gameEnv.center then
					gc.setColor(1,1,1,trans)
					local x=30*(P.curX+P.sc[2]-1)-15
					gc.draw(spinCenter,x,600-30*(P.curY+P.sc[1]-1)+15,nil,nil,nil,4,4)
					gc.translate(0,dy)
					gc.setColor(1,1,1,.5)
					gc.draw(spinCenter,x,600-30*(P.y_img+P.sc[1]-1)+15,nil,nil,nil,4,4)
					goto E
				end--Rotate center
				gc.translate(0,dy)
			end
		::E::
		gc.setScissor()--In-playField things
		gc.setColor(1,1,1)
		gc.draw(PTC.dust[P.id])
		gc.translate(0,-P.fieldBeneath)
		gc.setBlendMode("replace","alphamultiply")--SPEED UPUP(?)
			gc.setLineWidth(2)
			gc.rectangle("line",-1,-11,302,612)--Draw boarder
			gc.rectangle("line",301,0,15,601)--Draw atkBuffer boarder
			local h=0
			for i=1,#P.atkBuffer do
				local A=P.atkBuffer[i]
				local bar=A.amount*30
				if h+bar>600 then bar=600-h end
				if not A.sent then
					if A.time<20 then
						bar=bar*(20*A.time)^.5*.05
						--Appear
					end
					if A.countdown>0 then
						gc.setColor(attackColor[A.lv][1])
						gc.rectangle("fill",303,599-h,11,-bar+3)
						gc.setColor(attackColor[A.lv][2])
						gc.rectangle("fill",303,599-h+(-bar+3),11,-(-bar+3)*(1-A.countdown/A.cd0))
						--Timing
					else
						local t=math.sin((Timer()-i)*30)*.5+.5
						local c1,c2=attackColor[A.lv][1],attackColor[A.lv][2]
						gc.setColor(c1[1]*t+c2[1]*(1-t),c1[2]*t+c2[2]*(1-t),c1[3]*t+c2[3]*(1-t))
						gc.rectangle("fill",303,599-h,11,-bar+3)
						--Warning
					end
				else
					gc.setColor(attackColor[A.lv][1])
					bar=bar*(20-A.time)*.05
					gc.rectangle("fill",303,599-h,11,-bar+2)
					--Disappear
				end
				h=h+bar
			end--Buffer line
			local a,b=P.b2b,P.b2b1 if a>b then a,b=b,a end
			gc.setColor(.8,1,.2)
			gc.rectangle("fill",-14,599,11,-b*.5)
			gc.setColor(P.b2b<40 and color.white or P.b2b<=1e3 and color.lightRed or color.lightBlue)
			gc.rectangle("fill",-14,599,11,-a*.5)
			gc.setColor(1,1,1)
			if Timer()%.5<.3 then
				gc.rectangle("fill",-15,b<40 and 578.5 or 98.5,13,3)
			end
			gc.rectangle("line",-16,-3,15,604)--Draw b2b bar boarder
			--B2B indictator
			gc.translate(-P.fieldOff.x,-P.fieldOff.y)
		gc.setBlendMode("alpha")

		if P.gameEnv.hold then
			mDraw(drawableText.hold,-82,-10)
			if P.holded then gc.setColor(.6,.5,.5)end
			local B=P.hd.bk
			for i=1,#B do for j=1,#B[1]do
				if B[i][j]then
					drawPixel(i+17.5-#B*.5,j-2.7-#B[1]*.5,P.hd.color)
				end
			end end
		end--Hold
		gc.setColor(1,1,1)
		mDraw(drawableText.next,381,-10)
		local N=1
		::L::
		if N<=P.gameEnv.next and P.next[N]then
			local b,c=P.next[N].bk,P.next[N].color
			for i=1,#b do for j=1,#b[1] do
				if b[i][j]then
					drawPixel(i+20-2.4*N-#b*.5,j+12.7-#b[1]*.5,c)
				end
			end end
			N=N+1
			goto L
		end
		--Next
		gc.setColor(.8,.8,.8)
		gc.draw(drawableText.modeName,-135,-65)
		gc.draw(drawableText.levelName,437-drawableText.levelName:getWidth(),-65)
		gc.setColor(1,1,1)
		if frame<180 then
			local count=179-frame
			gc.push("transform")
				gc.translate(155,220)
				setFont(100)
				if count%60>45 then gc.scale(1+(count%60-45)^2*.01,1)end
				mStr(int(count/60+1),0,0)
			gc.pop()
		end--Draw starting counter
		for i=1,#P.bonus do
			P.bonus[i]:draw(min((30-abs(P.bonus[i].t-30))*.05,1)*(not P.bonus[i].inf and #P.field>(9-P.bonus[i].dy*.0333)and .7 or 1))
		end--Effects
		setFont(30)
		gc.setColor(1,1,1)
		mStr(format("%.2f",P.stat.time),-82,518)--Time
		mStr(P.score1,-82,560)--Score
		gc.draw(drawableText.bpm,390,490)
		gc.draw(drawableText.kpm,350,583)
		setFont(30)
		drawDial(360,520,P.dropSpeed)
		drawDial(405,575,P.keySpeed)
		--Speed dials
		gc.setColor(1,1,1)
		modes[curMode.id].mesDisp(P)--Other messages
		if modeEnv.royaleMode then
			if P.atkMode then
				gc.setColor(1,.8,0,P.swappingAtkMode*.02)
				gc.rectangle("fill",RCPB[2*P.atkMode-1],RCPB[2*P.atkMode],90,35,8,4)
			end
			gc.setColor(1,1,1,P.swappingAtkMode*.025)
			gc.draw(royaleCtrlPad)
		end
		gc.pop()
	end
end
function player.demoDraw(P)
	gc.push("transform")
	gc.translate(P.x,P.y)gc.scale(P.size)gc.translate(P.fieldOff.x,P.fieldOff.y)
	--Camera
	gc.setColor(.1,.1,.1,.8)gc.rectangle("fill",0,0,300,600)
	gc.setLineWidth(2)gc.setColor(1,1,1)gc.rectangle("line",-1,-1,302,602)
	--Frame
	if P.falling==-1 then
		for j=int(P.fieldBeneath/30+1),#P.field do
			for i=1,10 do
				if P.field[j][i]>0 then
					gc.setColor(1,1,1,min(P.visTime[j][i]*.05,1))
					drawPixel(j,i,P.field[j][i])
				end
			end
		end
	else--field block only
		local dy,stepY=0,setting.smo and(P.falling/(P.gameEnv.fall+1))^2.5*30 or 30
		local A=P.falling/P.gameEnv.fall
		local h,H=1,#P.field
		for j=int(P.fieldBeneath/30+1),H do
			while j==P.clearing[h]do
				h=h+1
				dy=dy+stepY
				gc.translate(0,-stepY)
				gc.setColor(1,1,1,A)
				gc.rectangle("fill",0,630-30*j,300,stepY)
			end
			for i=1,10 do
				if P.field[j][i]>0 then
					gc.setColor(1,1,1,min(P.visTime[j][i]*.05,1))
					drawPixel(j,i,P.field[j][i])
				end
			end
		end
		gc.translate(0,dy)
	end--Field with falling animation
	for i=1,#P.shade do
		local S=P.shade[i]
		gc.setColor(1,1,1,S[1]*.12)
		for x=S[3],S[5]do
			for y=S[6],S[4]do
				drawPixel(y,x,S[2])
			end
		end
	end--shade FX
	if P.waiting==-1 then
		gc.setColor(1,1,1,.3)
		for i=1,P.r do for j=1,P.c do
			if P.cur.bk[i][j]then
				drawPixel(i+P.y_img-1,j+P.curX-1,P.cur.color)
			end
		end end
		--Ghost draw
		gc.setColor(1,1,1)
		for i=1,P.r do for j=1,P.c do
			if P.cur.bk[i][j]then
				drawPixel(i+P.curY-1,j+P.curX-1,P.cur.color)
			end
		end end--Block
	end
	gc.setColor(1,1,1,.3)
	local N=miniBlock[P.hd.id]
	if N then
		gc.draw(N,15,30,nil,16,nil,0,N:getHeight()*.5)
	end
	local N=1
	::L::
	if N<=P.gameEnv.next and P.next[N]then
		local p=miniBlock[P.next[N].id]
		gc.draw(p,285,40*N-10,nil,16,nil,p:getWidth(),p:getHeight()*.5)
		N=N+1
		goto L
	end
	--Next
	gc.setColor(1,1,1)
	gc.draw(PTC.dust[P.id])
	gc.translate(-P.fieldOff.x,-P.fieldOff.y)
	for i=1,#P.bonus do
		P.bonus[i]:draw(min((30-abs(P.bonus[i].t-30))*.05,1)*(not P.bonus[i].inf and #P.field>(9-P.bonus[i].dy*.0333)and .7 or 1))
	end--Effects
	gc.pop()
end
-------------------------<FX>-------------------------
function player:showText(text,type,font,dy,spd,inf)
	if not self.small then
		self.bonus[#self.bonus+1]={t=0,text=text,draw=textFX[type],font=font,dy=dy or 0,speed=spd or 1,inf=inf}
	end
end
function player:createShade(x1,y1,x2,y2)--x1<x2,y1>y2
	if self.gameEnv.block and y1>=y2 then
		self.shade[#self.shade+1]={5,self.cur.color,x1,y1,x2,y2}
	end
end
function player:createBeam(R,send,time,target,color,clear,spin,mini,combo)
	local x1,y1,x2,y2
	if self.small then x1,y1=self.centerX,self.centerY
	else x1,y1=self.x+(30*(self.curX+self.sc[2]-1)-30+15+150)*self.size,self.y+(600-30*(self.curY+self.sc[1]-1)+15+70)*self.size
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
	if modeEnv.royaleMode and not(self.human or R.human)then
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
-------------------------</FX>-------------------------

-------------------------<Method>-------------------------
local function ifoverlap(P,bk,x,y)
	local C=#bk[1]
	if x<1 or x+C>11 or y<1 then return true end
	if y>#P.field then return end
	for i=1,#bk do
		if P.field[y+i-1]then
			for j=1,C do
				if bk[i][j]and P.field[y+i-1][x+j-1]>0 then return true end
			end
		end
	end
end
local function ckfull(P,i)
	for j=1,10 do if P.field[i][j]<=0 then return end end
	return true
end
local function checkrow(P,start,height)--(cy,r)
	local c=0
	local h=start
	for i=1,height do
		if ckfull(P,h)then
			ins(P.clearing,h)
			ins(P.cleared,h+c)
			removeRow(P.field,h)
			removeRow(P.visTime,h)
			c=c+1
			if not P.small then
				local S=PTC.dust[P.id]
				for _=1,100 do
					S:setPosition(rnd(300),630-30*(h+c)+rnd(30))
					S:emit(2)
				end
			end
		else
			h=h+1
		end
	end
	h=#P.field
	for i=c,1,-1 do
		if P.clearing[i]>h then
			P.clearing[i]=nil
		end
	end
	return c
end
local function solid(P,x,y)
	if x<1 or x>10 or y<1 then return true end
	if y>#P.field then return false end
	return P.field[y][x]>0
end
local function getBlockDirection(P)
	return(P.curX+P.sc[2]-6.5)*.15
end

function player:fineError(rate)
	self.stat.extraPiece=self.stat.extraPiece+1
	self.stat.extraRate=self.stat.extraRate+rate
	if self.human then
		if self.gameEnv.fineKill then
			SFX("error_long")
			Event.lose(self)
		elseif setting.fine then
			SFX("error")
		end
	elseif self.gameEnv.fineKill then
		Event.lose(self)
	end
end
function player:garbageSend(R,send,time,...)
	if setting.atkFX>0 then
		self:createBeam(R,send,time,...)
	end
	R.lastRecv=self
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
function player:garbageRelease()
	local n,flag=1
	::L::
		local A=self.atkBuffer[n]
		if A and A.countdown<=0 and not A.sent then
			self:garbageRise(8+A.lv,A.amount,A.pos)
			self.atkBuffer.sum=self.atkBuffer.sum-A.amount
			A.sent,A.time=true,0
			self.stat.pend=self.stat.pend+A.amount
			n=n+1
			flag=true
		else
			goto E
		end
	goto L
	::E::
	if flag and self.AI_mode=="CC"then CC_updateField(self)end
end
function player:garbageRise(color,amount,pos)
	local t=self.showTime*2
	for _=1,amount do
		ins(self.field,1,getNewRow(color))
		ins(self.visTime,1,getNewRow(t))
		self.field[1][pos]=0
	end
	self.fieldBeneath=self.fieldBeneath+amount*30
	self.curY=self.curY+amount
	self:freshgho()
	for i=1,#self.clearing do
		self.clearing[i]=self.clearing[i]+amount
	end
	for i=1,#self.shade do
		local S=self.shade[i]
		S[4],S[6]=S[4]+amount,S[6]+amount
	end
	if #self.field>40 then Event.lose(self)end
end
function player:freshTarget()
	if self.atkMode==1 then
		if not self.atking or not self.atking.alive or rnd()<.1 then
			self:changeAtk(randomTarget(self))
		end
	elseif self.atkMode==2 then
		self:changeAtk(self~=mostBadge and mostBadge or secBadge or randomTarget(self))
	elseif self.atkMode==3 then
		self:changeAtk(self~=mostDangerous and mostDangerous or secDangerous or randomTarget(self))
	elseif self.atkMode==4 then
		for i=1,#self.atker do
			if not self.atker[i].alive then
				rem(self.atker,i)
				return
			end
		end
	end
end
function player:changeAtkMode(m)
	if self.atkMode==m then return end
	self.atkMode=m
	if m==1 then
		self:changeAtk(randomTarget(self))
	elseif m==2 then
		self:freshTarget()
	elseif m==3 then
		self:freshTarget()
	elseif m==4 then
		self:changeAtk()
	end
	::L::
end
function player:changeAtk(R)
	-- if not self.human then R=players[1]end--Delete first "--" to enable 1vALL mode
	if self.atking then
		local K=self.atking.atker
		for i=1,#K do
			if K[i]==self then
				rem(K,i)
				goto L
			end
		end
	end
	::L::
	if R then
		self.atking=R
		R.atker[#R.atker+1]=self
	else
		self.atking=nil
	end
end
function player:freshgho()
	self.y_img=min(#self.field+1,self.curY)
	if self.gameEnv._20G or self.keyPressing[7]and self.gameEnv.sdarr==0 then
		while not ifoverlap(self,self.cur.bk,self.curX,self.y_img-1)do
			self.y_img=self.y_img-1
			self.spinLast=false
		end
		if self.curY>self.y_img then
			if not self.small then
				if setting.dropFX>0 then
					self:createShade(self.curX,self.curY+1,self.curX+self.c-1,self.y_img+self.r-1)
				end
				self.fieldOff.vy=setting.shakeFX*.8
			end
			self.curY=self.y_img
		end
	else
		while not ifoverlap(self,self.cur.bk,self.curX,self.y_img-1)do
			self.y_img=self.y_img-1
		end
	end
end
function player:freshLockDelay()
	if self.lockDelay<self.gameEnv.lock then
		self.dropDelay=self.gameEnv.drop
		self.freshTime=self.freshTime+1
		if self.freshTime<=self.gameEnv.freshLimit then
			self.lockDelay=self.gameEnv.lock
		end
	end
end
function player:lock()
	for i=1,self.r do
		local y=self.curY+i-1
		if not self.field[y]then self.field[y],self.visTime[y]=getNewRow(0),getNewRow(0)end
		for j=1,self.c do
			if self.cur.bk[i][j]then
				self.field[y][self.curX+j-1]=self.cur.color
				self.visTime[y][self.curX+j-1]=self.showTime
			end
		end
	end
end
function player:spin(d,ifpre)
	local idir=(self.dir+d)%4
	--<Ospin>
	if self.cur.id==6 then
		if self.gameEnv.easyFresh then
			self:freshLockDelay()
		end
		if self.gameEnv.ospin then
			if self.curY==self.y_img then
				self.spinSeq=self.spinSeq%100*10+d
				local x,y=self.curX,self.curY
				local id
				if self.spinSeq==313 then--Z
					if solid(self,x-1,y)and solid(self,x+2,y)then
						if solid(self,x-1,y+2)and not solid(self,x-1,y+1)then--嵌
							self.curX=x-1
							self.dir=2
							id=1
						elseif not solid(self,x+1,y-1)and not solid(self,x+2,y-1)then--压
							self.curY=y-1
							self.dir=2
							id=1
						end
					end
				elseif self.spinSeq==131 then--S
					if solid(self,x-1,y)and solid(self,x+2,y)then
						if solid(self,x+2,y+2)and not solid(self,x+2,y+1)then--嵌
							self.dir=2
							id=2
						elseif not solid(self,x,y-1)and not solid(self,x-1,y-1)then--压
							self.curY=y-1
							self.curX=x-1
							self.dir=2
							id=2
						end
					end
				elseif self.spinSeq==331 then--L
					if solid(self,x-1,y+1)and solid(self,x+2,y+1)then
						if solid(self,x+2,y)and not solid(self,x-1,y)then--钩
							self.curX=x-1
							self.dir=0
							id=3
						elseif not solid(self,x,y-1)and not solid(self,x+2,y)then--扣
							self.curY=y-1
							self.dir=2
							id=3
						end
					end
				elseif self.spinSeq==113 then--J
					if solid(self,x+2,y+1)and solid(self,x-2,y+1)then
						if solid(self,x-2,y)and not solid(self,x+2,y)then--钩
							self.dir=0
							id=4
						elseif not solid(self,x+1,y-1)and not solid(self,x-1,y)then--扣
							self.curX=x-1
							self.curY=y-1
							self.dir=2
							id=4
						end
					end
				elseif self.spinSeq==111 then--T-R
					if solid(self,x+2,y+1)and solid(self,x-1,y+1)and solid(self,x+2,y)and not solid(self,x-1,y)then
						if solid(self,x,y-1)then--钩
							self.curX=x-1
							self.dir=0
							id=5
						else--转
							self.curY=y-1
							self.dir=1
							id=5
						end
					end
				elseif self.spinSeq==333 then--T-L
					if solid(self,x-1,y+1)and solid(self,x-1,y)and solid(self,x+2,y+1)and not solid(self,x+2,y)then
						if solid(self,x+1,y-1)then--钩
							self.dir=0
							id=5
						else--转
							self.curY=y-1
							self.dir=3
							id=5
						end
					end
				elseif self.spinSeq==222 then--I
					if solid(self,x+2,y+1)and solid(self,x-1,y+1)then
						if not solid(self,x-1,y)then
							if not solid(self,x+2,y)then
								self.curX=x-1
								self.dir=2
								id=7
							elseif not solid(self,x-2,y)then
								self.curX=x-2
								self.dir=2
								id=7
							end
						elseif not solid(self,x+2,y)and not solid(self,x+3,y)then
							self.dir=2
							id=7
						end
					end
				end
				if id then--Transform successed
					local C=self.cur
					C.id=id
					C.bk=blocks[id][self.dir]
					self.r,self.c=#C.bk,#C.bk[1]
					self.sc=scs[id][self.dir]
					self.spinLast=2
					self.stat.rotate=self.stat.rotate+1
					self:freshgho()
					SFX("rotatekick",nil,getBlockDirection(self))
					return
				end
			else
				self.spinSeq=0
			end
		end
		if self.human then
			SFX(ifpre and"prerotate"or"rotate",nil,getBlockDirection(self))
		end
		return
	end
	--</Ospin>
	local icb=blocks[self.cur.id][idir]
	local isc=scs[self.cur.id][idir]
	local ir,ic=#icb,#icb[1]
	local ix,iy=self.curX+self.sc[2]-isc[2],self.curY+self.sc[1]-isc[1]
	local t--succssful test
	local iki=self.RS[self.cur.id][self.dir*10+idir]
	for i=1,self.freshTime<=1.2*self.gameEnv.freshLimit and #iki or 1 do
		if not ifoverlap(self,icb,ix+iki[i][1],iy+iki[i][2])then
			ix,iy=ix+iki[i][1],iy+iki[i][2]
			t=i
			goto spin
		end
	end
	do return end
	::spin::
	if not self.small and setting.dropFX>0 then
		self:createShade(self.curX,self.curY+self.r-1,self.curX+self.c-1,self.curY)
	end
	local y0=self.curY
	self.curX,self.curY,self.dir=ix,iy,idir
	self.sc,self.cur.bk=scs[self.cur.id][idir],icb
	self.r,self.c=ir,ic
	self.spinLast=t==2 and 0 or 1
	if not ifpre then self:freshgho()end
	if self.gameEnv.easyFresh or y0>self.curY then self:freshLockDelay()end
	if self.human then
		SFX(ifpre and"prerotate"or ifoverlap(self,self.cur.bk,self.curX,self.curY+1)and ifoverlap(self,self.cur.bk,self.curX-1,self.curY)and ifoverlap(self,self.cur.bk,self.curX+1,self.curY)and"rotatekick"or"rotate",nil,getBlockDirection(self))
	end
	self.stat.rotate=self.stat.rotate+1
end
function player:hold(ifpre)
	if not self.holded and self.waiting==-1 and self.gameEnv.hold then
		--Finesse check
		local H,B=self.hd,self.cur
		if H and H.id==B.id and H.name==B.name then
			self:fineError(1.5)
		elseif self.ctrlCount>1 then
			self:fineError(2)
		end

		self.holded=self.gameEnv.oncehold
		self.spinLast=false
		self.ctrlCount=0
		self.spinSeq=0
		self.cur,self.hd=self.hd,self.cur
		self.hd.bk=blocks[self.hd.id][0]
		if self.cur.id==0 then
			self.cur=rem(self.next,1)
			self:freshNext()
			if self.AI_mode=="CC"then BOT.addNext(self.AI_bot,CCblockID[self.next[self.AIdata.next].id])end
		end
		self.sc,self.dir=scs[self.cur.id][0],0
		self.r,self.c=#self.cur.bk,#self.cur.bk[1]
		self.curX,self.curY=blockPos[self.cur.id],21+ceil(self.fieldBeneath/30)-self.r+min(int(#self.field*.2),2)

		if abs(self.moving)>self.gameEnv.das and not ifoverlap(self,self.cur.bk,self.curX+(self.moving>0 and 1 or -1),self.curY)then
			self.curX=self.curX+(self.moving>0 and 1 or -1)
		end
		--IMS

		self:freshgho()
		self.dropDelay,self.lockDelay,self.freshTime=self.gameEnv.drop,self.gameEnv.lock,max(self.freshTime-5,0)
		if ifoverlap(self,self.cur.bk,self.curX,self.curY)then self:lock()Event.lose(self)end

		if self.human then
			SFX(ifpre and"prehold"or"hold")
		end
		self.stat.hold=self.stat.hold+1
	end
end
function player:newNext(n)
	self.next[#self.next+1]={bk=blocks[n][0],id=n,color=self.gameEnv.bone and 8 or n,name=n}
end
function player:resetblock()
	self.holded=false
	self.spinLast=false
	self.spinSeq=0
	self.ctrlCount=0

	self.cur=rem(self.next,1)
	self:freshNext()
	if self.AI_mode=="CC"then BOT.addNext(self.AI_bot,CCblockID[self.next[self.AIdata.next].id])end
	self.sc,self.dir=scs[self.cur.id][0],0--spin center/direction
	self.r,self.c=#self.cur.bk,#self.cur.bk[1]--row/column
	self.curX,self.curY=blockPos[self.cur.id],21+ceil(self.fieldBeneath/30)+min(int(#self.field*.15)-self.r,0)--初始高度：7格+1,14格+2(非I)
	self.dropDelay,self.lockDelay,self.freshTime=self.gameEnv.drop,self.gameEnv.lock,0

	if self.keyPressing[8]then self:hold(true)end
	if self.keyPressing[3]then self:spin(1,true)end
	if self.keyPressing[4]then self:spin(3,true)end
	if self.keyPressing[5]then self:spin(2,true)end
	if abs(self.moving)>self.gameEnv.das and not ifoverlap(self,self.cur.bk,self.curX+(self.moving>0 and 1 or -1),self.curY)then
		self.curX=self.curX+(self.moving>0 and 1 or -1)
	end
	--Initial SYSs
	if ifoverlap(self,self.cur.bk,self.curX,self.curY)then self:lock()Event.lose(self)end
	self:freshgho()
	if self.keyPressing[6]then self.act.hardDrop(self)self.keyPressing[6]=false end
end
function player:drop()--Place piece
	self.dropTime[11]=ins(self.dropTime,1,frame)--update speed dial
	self.waiting=self.gameEnv.wait
	local dospin=0
	if self.spinLast then
		if self.cur.id<6 then
			local x,y=self.curX+self.sc[2]-1,self.curY+self.sc[1]-1
			local c=0
			if solid(self,x-1,y+1)then c=c+1 end
			if solid(self,x+1,y+1)then c=c+1 end
			if c==0 then goto NTC end
			if solid(self,x-1,y-1)then c=c+1 end
			if solid(self,x+1,y-1)then c=c+1 end
			if c>2 then dospin=dospin+1 end
		end--Three point
		::NTC::
		if self.cur.id~=6 and ifoverlap(self,self.cur.bk,self.curX-1,self.curY)and ifoverlap(self,self.cur.bk,self.curX+1,self.curY)and ifoverlap(self,self.cur.bk,self.curX,self.curY+1)then
			dospin=dospin+2
		end--Immobile
	end

	--极简检测(遮挡)
	local finesse
	if self.curY>18 then
		finesse=true--高处防误判直接最简
	else
		local y0=self.curY
		local x,c=self.curX,self.c

		local B=self.cur.bk
		for x=1,c do
			local y
			for i=#B,1,-1 do
				if B[i][x]then y=i;goto L2 end
			end
			goto L1
			::L2::
			if y then
				x=self.curX+x-1
				for y=y0+y,#self.field do
					if solid(self,x,y)then finesse=true;goto L1 end--有遮挡视为最简
				end
			end
		end
		::L1::
	end
	
	self:lock()
	local CHN=getFreeVoiceChannel()
	local cc,send,exblock=checkrow(self,self.curY,self.r),0,0--Currect clear&send&sendTime
	if self.clearing[1]then self.falling=self.gameEnv.fall end
	local cscore,sendTime=0,0
	local mini
	if self.spinLast then
		if cc>0 then
			if dospin>0 then
				dospin=dospin+self.spinLast
				if dospin<2 then
					mini=self.cur.id<6 and cc<3 and cc<self.r
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

	--极简检测(操作)
	if not finesse then
		if dospin then self.ctrlCount=self.ctrlCount-2 end--对无遮挡spin宽松两步
		local id=self.cur.id
		local dir=self.dir+1
		if id<3 or id==7 then
			if dir>2 then
				dir=dir-2
			end
		end--SZI的逆态视为顺态
		local R,I=self.ctrlCount,finesseCtrlPar[id][dir][self.curX]--Real key/Ideal key
		local d=R-I
		if d>0 then
			if I==0 then I=1 end
			local rate=R/I
			if rate>2.5 then rate=2.5 end
			self:fineError(rate)
			--非最简
		end
	end

	if cc>0 then
		self.combo=self.combo+1
		if cc==4 then
			cscore=1000
			if self.b2b>1000 then
				self:showText(text.techrashB3B,"fly",80,-30)
				send=6
				sendTime=100
				exblock=exblock+1
				cscore=cscore*1.8
				self.stat.b3b=self.stat.b3b+1
				if self.human then
					VOICE("b3b",CHN)
				end
			elseif self.b2b>=50 then
				self:showText(text.techrashB2B,"drive",80,-30)
				sendTime=80
				send=5
				cscore=cscore*1.3
				self.stat.b2b=self.stat.b2b+1
				if self.human then
					VOICE("b2b",CHN)
				end
			else
				self:showText(text.techrash,"stretch",80,-30)
				sendTime=60
				send=4
			end
			self.b2b=self.b2b+120
			self.lastClear=74
			self.stat.clear_4=self.stat.clear_4+1
			if self.human then
				VOICE("techrash",CHN)
			end
		elseif cc>0 then
			local clearKey=clear_n
			if dospin then
				cscore=spinSCR[self.cur.name][cc]
				if self.b2b>1000 then
					self:showText(text.b3b..text.spin[self.cur.name]..text.clear[cc],"spin",40,-30)
					send=b2bATK[cc]+1
					exblock=exblock+1
					cscore=cscore*2
					self.stat.b3b=self.stat.b3b+1
					if self.human then
						VOICE("b3b",CHN)
					end
				elseif self.b2b>=50 then
					self:showText(text.b2b..text.spin[self.cur.name]..text.clear[cc],"spin",40,-30)
					send=b2bATK[cc]
					cscore=cscore*1.2
					self.stat.b2b=self.stat.b2b+1
					if self.human then
						VOICE("b2b",CHN)
					end
				else
					self:showText(text.spin[self.cur.name]..text.clear[cc],"spin",50,-30)
					send=2*cc
				end
				sendTime=20+send*20
				if mini then
					self:showText(text.mini,"appear",40,-80)
					send=ceil(send*.5)
					sendTime=sendTime+60
					cscore=cscore*.5
					self.b2b=self.b2b+b2bPoint[cc]*.5
					if self.human then
						VOICE("mini",CHN)
					end
				else
					self.b2b=self.b2b+b2bPoint[cc]
				end
				self.lastClear=self.cur.id*10+cc
				clearKey=spin_n
				if self.human then
					SFX(spin_n[cc])
					VOICE(spinName[self.cur.name],CHN)
				end
			elseif #self.field>0 then
				self.b2b=max(self.b2b-250,0)
				self:showText(text.clear[cc],"appear",32+cc*3,-30,(8-cc)*.3)
				send=cc-1
				sendTime=20+send*20
				cscore=cscore+clearSCR[cc]
				self.lastClear=cc
			end
			self.stat[clearKey[cc]]=self.stat[clearKey[cc]]+1
			if self.human then
				VOICE(clearName[cc],CHN)
			end
		end
		send=send+(renATK[self.combo]or 3)
		if #self.field==0 then
			self:showText(text.PC,"flicker",70,-80)
			send=min(send,3)+min(6+self.stat.pc,10)
			exblock=exblock+2
			sendTime=sendTime+60
			if self.stat.row>4 then
				self.b2b=1200
				cscore=cscore+500*min(6+self.stat.pc,10)
			else
				cscore=cscore+500
			end
			self.stat.pc=self.stat.pc+1
			self.lastClear=self.cur.id*10+5
			if self.human then
				SFX("perfectclear")
				VOICE("pc",CHN)
			end
		end
		if self.combo>2 then
			self:showText(text.cmb[min(self.combo,20)],self.combo<10 and"appear"or"flicker",20+min(self.combo,25)*3,60)
			cscore=cscore+min(20*self.combo,300)*cc
		end
		sendTime=sendTime+25*self.combo
		if self.human then
			SFX(clear_n[cc])
			SFX(ren_n[min(self.combo,11)])
			if self.combo>14 then SFX("ren_mega",(self.combo-10)*.1)end
			VIB(cc+1)
		end
		if self.b2b>1200 then self.b2b=1200 end

		if modeEnv.royaleMode then
			local i=min(#self.atker,9)
			if i>1 then
				send=send+reAtk[i]
				exblock=exblock+reDef[i]
			end
		end--Counter attack

		if send>0 then
			self.stat.atk=self.stat.atk+send
			--ATK statistics
			if exblock then exblock=int(exblock*(1+self.strength*.25))end
			send=send*(1+self.strength*.25)
			if mini then send=send*.8 end
			send=int(send)
			--Badge Buff
			if send==0 then goto L end
				self:showText(send,"zoomout",40,70)
			if exblock==0 then goto L end
				self:showText(exblock,"zoomout",20,115)
			::L::
			send=send+exblock
			local k=0
			::R::
			if self.atkBuffer.sum>0 and send>0 then
				::F::
					k=k+1
					local A=self.atkBuffer[k]
					if not A then goto E end
				if A.sent then goto F end
				if send>=A.amount then
					send=send-A.amount
					self.atkBuffer.sum=self.atkBuffer.sum-A.amount
					A.sent,A.time=true,0
					if send>0 then goto R end
				else
					A.amount=A.amount-send
					self.atkBuffer.sum=self.atkBuffer.sum-send
					send=0
				end
			end
			::E::
			send=send-exblock
			if send>0 then
				local T
				if modeEnv.royaleMode then
					if self.atkMode==4 then
						local M=#self.atker
						if M>0 then
							for i=1,M do
								self:garbageSend(self.atker[i],send,sendTime,M,self.cur.color,self.lastClear,dospin,mini,self.combo)
							end
						else
							T=randomTarget(self)
						end
					else
						self:freshTarget()
						T=self.atking
					end
				elseif #players.alive>1 then
					T=randomTarget(self)
				end
				if T then
					self:garbageSend(T,send,sendTime,1,self.cur.color,self.lastClear,dospin,mini,self.combo)
				end
				self.stat.send=self.stat.send+send
				if self.human and send>3 then SFX("emit",min(send,8)*.1)end
			end
		end
	else
		self.combo=0
		local dropScore=10
		if dospin then
			self:showText(text.spin[self.cur.name],"appear",50,-30)
			self.b2b=self.b2b+20
			self.stat.spin_0=self.stat.spin_0+1
			if self.human then
				SFX("spin_0")
				VOICE(spinName[self.cur.name],CHN)
			end
			dropScore=25--spin bonus
		end

		if self.gameEnv._20G then
			dropScore=dropScore*2
		elseif self.gameEnv.drop<3 then
			dropScore=dropScore*1.5
		end--dropSpeed bonus

		if self.dropSpeed>60 then
			dropScore=dropScore*self.dropSpeed/60
		elseif self.dropSpeed>120 then
			dropScore=dropScore*1,2*self.dropSpeed/120
		elseif self.dropSpeed>180 then
			dropScore=dropScore*1.5*self.dropSpeed/180
		end--speed bonus

		cscore=cscore+int(dropScore)
		if self.b2b>1000 then
			self.b2b=max(self.b2b-40,1000)
		end
		self:garbageRelease()
	end
	self.stat.score=self.stat.score+cscore
	self.stat.piece,self.stat.row=self.stat.piece+1,self.stat.row+cc
	Event[self.gameEnv.dropPiece](self)
	if self.human then SFX("lock",nil,getBlockDirection(self))end
end
function player:pressKey(i)
	self.keyPressing[i]=true
	if self.id==1 then
		virtualkeyDown[i]=true
		virtualkeyPressTime[i]=10
	end
	if self.alive then
		self.act[actName[i]](self)
		self.keyTime[11]=ins(self.keyTime,1,frame)
		self.stat.key=self.stat.key+1
	end
	--ins(rec,{i,frame})
end
function player:releaseKey(i)
	self.keyPressing[i]=false
	if self.id==1 then virtualkeyDown[i]=false end
	-- if recording then ins(rec,{-i,frame})end
end
-------------------------</Methods>-------------------------

-------------------------<Controls>-------------------------
player.act={}
function player.act.moveLeft(P,auto)
	if not auto then
		P.ctrlCount=P.ctrlCount+1
	end
	if P.keyPressing[9]then
		if P.gameEnv.swap then
			P:changeAtkMode(1)
		end
	elseif P.control and P.waiting==-1 then
		if not ifoverlap(P,P.cur.bk,P.curX-1,P.curY)then
			P.curX=P.curX-1
			local y0=P.curY
			P:freshgho()
			if P.gameEnv.easyFresh or y0~=P.curY then P:freshLockDelay()end
			if P.human and P.curY==P.y_img then SFX("move")end
			P.spinLast=false
			if not auto then
				P.moving=-1
			end
		else
			P.moving=-P.gameEnv.das-1
		end
	else
		P.moving=-1
	end
end
function player.act.moveRight(P,auto)
	if not auto then
		P.ctrlCount=P.ctrlCount+1
	end
	if P.keyPressing[9]then
		if P.gameEnv.swap then
			P:changeAtkMode(2)
		end
	elseif P.control and P.waiting==-1 then
		if not ifoverlap(P,P.cur.bk,P.curX+1,P.curY)then
			P.curX=P.curX+1
			local y0=P.curY
			P:freshgho()
			if P.gameEnv.easyFresh or y0~=P.curY then P:freshLockDelay()end
			if P.human and P.curY==P.y_img then SFX("move")end
			P.spinLast=false
			if not auto then
				P.moving=1
			end
		else
			P.moving=P.gameEnv.das+1
		end
	else
		P.moving=1
	end
end
function player.act.rotRight(P)
	if P.control and P.waiting==-1 then
		P.ctrlCount=P.ctrlCount+1
		P:spin(1)
		P.keyPressing[3]=false
	end
end
function player.act.rotLeft(P)
	if P.control and P.waiting==-1 then
		P.ctrlCount=P.ctrlCount+1
		P:spin(3)
		P.keyPressing[4]=false
	end
end
function player.act.rotFlip(P)
	if P.control and P.waiting==-1 then
		P.ctrlCount=P.ctrlCount+2
		P:spin(2)
		P.keyPressing[5]=false
	end
end
function player.act.hardDrop(P)
	if P.keyPressing[9]then
		if P.gameEnv.swap then
			P:changeAtkMode(3)
		end
		P.keyPressing[6]=false
	elseif P.control and P.waiting==-1 then
		if P.curY~=P.y_img then
			if not P.small then
				if setting.dropFX>0 then
					P:createShade(P.curX,P.curY+1,P.curX+P.c-1,P.y_img+P.r-1)
				end
			end
			P.curY=P.y_img
			P.spinLast=false
			if not P.small then
				P.fieldOff.vy=setting.shakeFX
			end
			if P.human then
				SFX("drop",nil,getBlockDirection(P))
				VIB(1)
			end
		end
		P.lockDelay=-1
		P:drop()
		P.keyPressing[6]=false
	end
end
function player.act.softDrop(P)
	if P.keyPressing[9]then
		if P.gameEnv.swap then
			P:changeAtkMode(4)
		end
	else
		P.downing=1
		if P.control and P.waiting==-1 then
			if P.curY~=P.y_img then
				P.curY=P.curY-1
				P.spinLast=false
			end
		end
	end
end
function player.act.hold(P)
	if P.control and P.waiting==-1 then
		P:hold()
	end
end
function player.act.func(P)
	P.gameEnv.Fkey(P)
end
function player.act.restart(P)
	if P.gameEnv.quickR or frame<180 then
		clearTask("play")
		resetPartGameData()
	end
end
function player.act.insLeft(P,auto)
	local x0,y0=P.curX,P.curY
	while not ifoverlap(P,P.cur.bk,P.curX-1,P.curY)do
		P.curX=P.curX-1
		if not P.small and setting.dropFX>0 then
			P:createShade(P.curX+1,P.curY+P.r-1,P.curX+1,P.curY)
		end
		P:freshgho()
	end
	if x0~=P.curX then
		if P.gameEnv.easyFresh or y0~=P.curY then P:freshLockDelay()end
	end
	if not P.small then
		P.fieldOff.vx=-setting.shakeFX*.8
	end
	if auto then
		if P.ctrlCount==0 then P.ctrlCount=1 end
	else
		P.ctrlCount=P.ctrlCount+1
	end
end
function player.act.insRight(P,auto)
	local x0,y0=P.curX,P.curY
	while not ifoverlap(P,P.cur.bk,P.curX+1,P.curY)do
		P.curX=P.curX+1
		if not P.small and setting.dropFX>0 then
			P:createShade(P.curX+P.c-1,P.curY+P.r-1,P.curX+P.c-1,P.curY)
		end
		P:freshgho()
	end
	if x0~=P.curX then
		if P.gameEnv.easyFresh or y0~=P.curY then P:freshLockDelay()end
	end
	if not P.small then
		P.fieldOff.vx=setting.shakeFX*.8
	end
	if auto then
		if P.ctrlCount==0 then P.ctrlCount=1 end
	else
		P.ctrlCount=P.ctrlCount+1
	end
end
function player.act.insDown(P)
	if P.curY~=P.y_img then
		if not P.small then
			if setting.dropFX>0 then
				P:createShade(P.curX,P.curY+1,P.curX+P.c-1,P.y_img+P.r-1)
			end
		end
		P.curY,P.lockDelay,P.spinLast=P.y_img,P.gameEnv.lock,false
	end
end
function player.act.down1(P)
	if P.curY~=P.y_img then
		P.curY=P.curY-1
		P.spinLast=false
	end
end
function player.act.down4(P)
	for _=1,4 do
		if P.curY~=P.y_img then
			P.curY=P.curY-1
			P.spinLast=false
		else
			break
		end
	end
end
function player.act.down10(P)
	for _=1,10 do
		if P.curY~=P.y_img then
			P.curY=P.curY-1
			P.spinLast=false
		else
			break
		end
	end
end
function player.act.dropLeft(P)
	P.act.insLeft(P)
	P.act.hardDrop(P)
end
function player.act.dropRight(P)
	P.act.insRight(P)
	P.act.hardDrop(P)
end
function player.act.addLeft(P)
	P.act.insLeft(P)
	P.act.insDown(P)
	P.act.insRight(P)
	P.act.hardDrop(P)
end
function player.act.addRight(P)
	P.act.insRight(P)
	P.act.insDown(P)
	P.act.insLeft(P)
	P.act.hardDrop(P)
end
-------------------------</Controls>-------------------------