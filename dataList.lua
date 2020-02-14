local int,rnd,max,min=math.floor,math.random,math.max,math.min
local format=string.format
local ins,rem=table.insert,table.remove
local gc=love.graphics

local AISpeed={60,50,45,35,25,15,9,6,4,2}
function AITemplate(type,speedLV,next,hold,node)
	if type=="CC"then
		return{
			type="CC",
			next=next,
			hold=hold,--hold,-------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			delta=AISpeed[speedLV],
			node=node,
		}
	elseif type=="9S"then
		return{
			type="9S",
			delta=int(AISpeed[speedLV]*.5),
		}
	end
end
-------------------------<Events>-------------------------
local function gameOver()
	local M=curMode
	local R=M.getRank
	if R then
		local P=players[1]
		R=R(P)--new rank
		if R then
			local r=modeRanks[M.id]--old rank
			if R>r then
				modeRanks[M.id]=R
				if r==0 then
					for i=1,#M.unlock do
						local m=M.unlock[i]
						modeRanks[m]=modes[m].score and 0 or 6
					end
				end
			end
			local D=M.score(P)
			local L=M.records
			local p=#L--排名数-1
			if p>0 then
				::L::
				if M.comp(D,L[p])then--是否靠前
					p=p-1
					if p>0 then
						goto L
					end
				end
			end
			if p<10 then
				if p==0 then
					P:showText(text.newRecord,0,-100,100,"beat",.5)
				end
				ins(L,p+1,D)
				if L[11]then L[11]=nil end
				saveRecord(M.saveFileName,L)
			end
		end
	end
end--Save record
local function die(P)--Same thing when win/lose,not really die!
	P.alive=false
	P.control=false
	P.timing=false
	P.waiting=1e99
	P.b2b=0
	clearTask(P)
	for i=1,#P.atkBuffer do
		P.atkBuffer[i].sent=true
		P.atkBuffer[i].time=0
	end
	for i=1,#P.field do
		for j=1,10 do
			P.visTime[i][j]=min(P.visTime[i][j],20)
		end
	end
end
Event={}
function Event.reach_winCheck(P)
	if P.stat.row>=P.gameEnv.target then
		Event.win(P,"finish")
	end
end
function Event.win(P,result)
	die(P)
	P.result="WIN"
	if modeEnv.royaleMode then
		P.rank=1
		P:changeAtk()
	end
	if P.human then
		gameResult=result or"win"
		SFX("win")
		VOICE("win")
		if modeEnv.royaleMode then
			BGM("8-bit happiness")
		end
	end
	newTask(Event_task.finish,P)
	if curMode.id=="custom_puzzle"then
		P:showText(text.win,0,0,90,"beat",.4)
	else
		P:showText(text.win,0,0,90,"beat",.5,.2)
	end
	if P.human then
		gameOver()
	end
end
function Event.lose(P)
	if P.invincible then
		while P.field[1]do
			removeRow(P.field)
			removeRow(P.visTime)
		end
		if P.AI_mode=="CC"then
			P.AI_needFresh=true
		end
		return
	end
	die(P)
	for i=1,#players.alive do
		if players.alive[i]==P then
			rem(players.alive,i)
			break
		end
	end
	P.result="K.O."
	if modeEnv.royaleMode then
		P:changeAtk()
		P.rank=#players.alive+1
		P:showText(P.rank,0,-120,60,"appear",1,12)
		P.strength=0
		if P.lastRecv then
			local A,i=P,0
			repeat
				A,i=A.lastRecv,i+1
			until not A or A.alive or A==P or i==3
			if A and A.alive then
				if P.id==1 or A.id==1 then
					P.killMark=A.id==1
				end
				A.ko,A.badge=A.ko+1,A.badge+P.badge+1
				for i=A.strength+1,4 do
					if A.badge>=royaleData.powerUp[i]then
						A.strength=i
					end
				end
				P.lastRecv=A
				if P.id==1 or A.id==1 then
					newTask(Event_task.throwBadge,A,{P,max(3,P.badge)*4})
				end
				freshMostBadge()
			end
		else
			P.badge=-1
		end
		freshMostDangerous()
		for i=1,#players.alive do
			if players.alive[i].atking==P then
				players.alive[i]:freshTarget()
			end
		end
		if #players.alive==royaleData.stage[gameStage]then
			royaleLevelup()
		end
	end
	P.gameEnv.keepVisible=P.gameEnv.visible~="show"
	P:showText(text.lose,0,0,90,"appear",.5,.2)
	if P.human then
		gameResult="lose"
		SFX("fail")
		VOICE("lose")
		if modeEnv.royaleMode then BGM("end")end
	end
	if #players.alive==1 then
		Event.win(players.alive[1])
	end
	if #players==1 or(P.human and not players[2].human)then
		gameOver()
	end
	newTask(#players>1 and Event_task.lose or Event_task.finish,P)
end
-------------------------</Events>-------------------------

-------------------------<Tasks>-------------------------
Event_task={}
function Event_task.finish(P)
	if scene.cur~="play"then return true end
	P.endCounter=P.endCounter+1
	if P.endCounter>120 then pauseGame()end
end
function Event_task.lose(P)
	P.endCounter=P.endCounter+1
	if P.endCounter>80 then
		for i=1,#P.field do
			for j=1,10 do
				if P.visTime[i][j]>0 then
					P.visTime[i][j]=P.visTime[i][j]-1
				end
			end
		end
		if P.endCounter==120 then
			while P.field[1]do
				removeRow(P.field)
				removeRow(P.visTime)
			end
			if #players==1 and scene=="play"then
				pauseGame()
			end
			return true
		end
	end
end
function Event_task.throwBadge(A,data)
	data[2]=data[2]-1
	if data[2]%4==0 then
		local S,R=data[1],data[1].lastRecv
		local x1,y1,x2,y2
		if S.small then
			x1,y1=S.centerX,S.centerY
		else
			x1,y1=S.x+308*S.size,S.y+450*S.size
		end
		if R.small then
			x2,y2=R.centerX,R.centerY
		else
			x2,y2=R.x+66*R.size,R.y+344*R.size
		end
		FX_badge[#FX_badge+1]={x1,y1,x2,y2,t=0}
		--generate badge object

		if not A.ai and data[2]%8==0 then
			SFX("collect")
		end
	end
	if data[2]<=0 then return true end
end
function Event_task.bgmFadeOut(_,id)
	local v=bgm[id]:getVolume()-.025*setting.bgm*.1
	bgm[id]:setVolume(v>0 and v or 0)
	if v<=0 then
		bgm[id]:stop()
		return true
	end
end
function Event_task.bgmFadeIn(_,id)
	local v=min(bgm[id]:getVolume()+.025*setting.bgm*.1,setting.bgm*.1)
	bgm[id]:setVolume(v)
	if v>=setting.bgm*.1 then return true end
end
-------------------------</Tasks>-------------------------
-------------------------<Modes>--------------------------
modes={
	{"sprint_10",						id=1,	x=0,		y=0,		shape=1,size=35,unlock={2,3}},
	{"sprint_20",						id=2,	x=-300,		y=0,		shape=1,size=45,unlock={73,74,75}},
	{"sprint_40",						id=3,	x=0,		y=-400,		shape=1,size=55,unlock={4,9}},
	{"sprint_100",						id=4,	x=-200,		y=-400,		shape=1,size=45,unlock={5,7}},
	{"sprint_400",						id=5,	x=-400,		y=-400,		shape=1,size=35,unlock={6}},
	{"sprint_1000",						id=6,	x=-600,		y=-400,		shape=1,size=35,unlock={}},
		{"drought_normal",				id=7,	x=-400,		y=-200,		shape=1,size=35,unlock={8}},
		{"drought_lunatic",				id=8,	x=-600,		y=-200,		shape=1,size=35,unlock={}},
	{"marathon_normal",					id=9,	x=0,		y=-600,		shape=1,size=55,unlock={10,11,22,31,36,37,48,68,71,72}},
	{"marathon_hard",					id=10,	x=0,		y=-800,		shape=1,size=45,unlock={27}},
		{"solo_1",						id=11,	x=-300,		y=-1000,	shape=1,size=35,unlock={12}},
		{"solo_2",						id=12,	x=-500,		y=-1000,	shape=1,size=35,unlock={13}},
		{"solo_3",						id=13,	x=-700,		y=-1000,	shape=1,size=35,unlock={14,16}},
		{"solo_4",						id=14,	x=-900,		y=-1000,	shape=1,size=35,unlock={15}},
		{"solo_5",						id=15,	x=-1100,	y=-1000,	shape=1,size=35,unlock={}},
			{"techmino49_easy",			id=16,	x=-900,		y=-1200,	shape=1,size=35,unlock={17,19}},
			{"techmino49_hard",			id=17,	x=-900,		y=-1400,	shape=1,size=35,unlock={18}},
			{"techmino49_ultimate",		id=18,	x=-900,		y=-1600,	shape=1,size=35,unlock={}},

			{"techmino99_easy",			id=19,	x=-1100,	y=-1400,	shape=1,size=35,unlock={20}},
			{"techmino99_hard",			id=20,	x=-1100,	y=-1600,	shape=1,size=35,unlock={21}},
			{"techmino99_ultimate",		id=21,	x=-1100,	y=-1800,	shape=1,size=35,unlock={}},
		{"round_1",						id=22,	x=-300,		y=-800,		shape=1,size=35,unlock={23}},
		{"round_2",						id=23,	x=-500,		y=-800,		shape=1,size=35,unlock={24}},
		{"round_3",						id=24,	x=-700,		y=-800,		shape=1,size=35,unlock={25}},
		{"round_4",						id=25,	x=-900,		y=-800,		shape=1,size=35,unlock={26}},
		{"round_5",						id=26,	x=-1100,	y=-800,		shape=1,size=35,unlock={}},

		{"master_beginner",				id=27,	x=0,		y=-1000,	shape=1,size=35,unlock={28}},
		{"master_adavnce",				id=28,	x=0,		y=-1200,	shape=1,size=35,unlock={29,30}},
		{"master_final",				id=29,	x=0,		y=-1400,	shape=1,size=35,unlock={}},
		{"GM",							id=30,	x=150,		y=-1500,	shape=1,size=35,unlock={}},

		{"blind_easy",					id=31,	x=150,		y=-700,		shape=1,size=35,unlock={32}},
		{"blind_normal",				id=32,	x=150,		y=-800,		shape=1,size=35,unlock={33}},
		{"blind_hard",					id=33,	x=150,		y=-900,		shape=1,size=35,unlock={34}},
		{"blind_lunatic",				id=34,	x=150,		y=-1000,	shape=1,size=35,unlock={35}},
		{"blind_ultimate",				id=35,	x=150,		y=-1100,	shape=1,size=35,unlock={}},

		{"classic_fast",				id=36,	x=-300,		y=-1200,	shape=1,size=35,unlock={}},
        
		{"survivor_easy",				id=37,	x=300,		y=-600,		shape=1,size=35,unlock={38}},
		{"survivor_normal",				id=38,	x=500,		y=-600,		shape=1,size=35,unlock={39,42,44,46}},
		{"survivor_hard",				id=39,	x=700,		y=-600,		shape=1,size=35,unlock={40}},
		{"survivor_lunatic",			id=40,	x=900,		y=-600,		shape=1,size=35,unlock={41}},
		{"survivor_ultimate",			id=41,	x=1100,		y=-600,		shape=1,size=35,unlock={}},
			{"attacker_hard",			id=42,	x=300,		y=-800,		shape=1,size=35,unlock={43}},
			{"attacker_ultimate",		id=43,	x=300,		y=-1000,	shape=1,size=35,unlock={}},

			{"defender_normal",			id=44,	x=500,		y=-800,		shape=1,size=35,unlock={45}},
			{"defender_lunatic",		id=45,	x=500,		y=-1000,	shape=1,size=35,unlock={}},

			{"dig_hard",				id=46,	x=700,		y=-800,		shape=1,size=35,unlock={47}},
			{"dig_ultimate",			id=47,	x=700,		y=-1000,	shape=1,size=35,unlock={}},

		{"bigbang",						id=48,	x=400,		y=-400,		shape=1,size=55,unlock={49,51,56}},
			{"c4wtrain_normal",			id=49,	x=700,		y=-400,		shape=1,size=35,unlock={50}},
			{"c4wtrain_lunatic",		id=50,	x=900,		y=-400,		shape=1,size=35,unlock={}},

			{"pctrain_normal",			id=51,	x=700,		y=-200,		shape=1,size=35,unlock={52,53}},
			{"pctrain_lunatic",			id=52,	x=900,		y=-200,		shape=1,size=35,unlock={}},
				{"pcchallenge_normal",	id=53,	x=800,		y=-100,		shape=1,size=35,unlock={54}},
				{"pcchallenge_hard",	id=54,	x=1000,		y=-100,		shape=1,size=35,unlock={55}},
				{"pcchallenge_lunatic",	id=55,	x=1200,		y=-100,		shape=1,size=35,unlock={}},
			{"tech_normal",				id=56,	x=400,		y=-100,		shape=1,size=35,unlock={57,58}},
			{"tech_normal+",			id=57,	x=650,		y=150,		shape=1,size=35,unlock={64,67}},
			{"tech_hard",				id=58,	x=400,		y=50,		shape=1,size=35,unlock={59,60}},
			{"tech_hard+",				id=59,	x=250,		y=50,		shape=1,size=35,unlock={}},
			{"tech_lunatic",			id=60,	x=400,		y=200,		shape=1,size=35,unlock={61,62}},
			{"tech_lunatic+",			id=61,	x=250,		y=200,		shape=1,size=35,unlock={}},
			{"tech_ultimate",			id=62,	x=400,		y=350,		shape=1,size=35,unlock={63}},
			{"tech_ultimate+",			id=63,	x=250,		y=350,		shape=1,size=35,unlock={}},
				{"tsd_easy",			id=64,	x=800,		y=200,		shape=1,size=35,unlock={65}},
				{"tsd_hard",			id=65,	x=1000,		y=200,		shape=1,size=35,unlock={66}},
				{"tsd_ultimate",		id=66,	x=1200,		y=200,		shape=1,size=35,unlock={}},

				{"ultra",				id=67,	x=650,		y=400,		shape=1,size=35,unlock={}},
		{"zen",							id=68,	x=-900,		y=-600,		shape=1,size=35,unlock={69,70}},
		{"infinite",					id=69,	x=-900,		y=-400,		shape=1,size=35,unlock={}},
		{"infinite_dig",				id=70,	x=-1100,	y=-600,		shape=1,size=35,unlock={}},
		{"custom_clear",				id=71,	x=200,		y=-350,		shape=2,size=45,unlock={}},
		{"custom_puzzle",				id=72,	x=200,		y=-200,		shape=2,size=45,unlock={}},
	{"hotseat_2P",						id=73,	x=-300,		y=200,		shape=2,size=45,unlock={}},
	{"hotseat_3P",						id=74,	x=-450,		y=200,		shape=2,size=45,unlock={}},
	{"hotseat_4P",						id=75,	x=-600,		y=200,		shape=2,size=45,unlock={}},
}
modeRanks={}
for i=1,#modes do
	modeRanks[i]=false
	assert(i==modes[i].id,"ModeID error:"..i)
end
modeRanks[1]=0