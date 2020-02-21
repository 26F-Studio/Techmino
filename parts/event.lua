local int,max,min=math.floor,math.max,math.min
local ins,rem=table.insert,table.remove
local function gameOver()
	saveStat()
	local M=curMode
	if M.pauseLimit and(pauseCount==1 and pauseTime>2.6 or pauseTime>6.26)then
		TEXT(text.invalidGame,640,260,80,"flicker",.5)
		return
	end
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
				saveUnlock()
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
				D.date=os.date("%Y/%m/%d %H:%M")
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
		P.modeData.event=1
		P:changeAtk()
	end
	if P.human then
		gameResult=result or"win"
		SFX.play("win")
		VOICE("win")
		if modeEnv.royaleMode then
			BGM.play("8-bit happiness")
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
		P.modeData.event=#players.alive+1
		P:showText(P.modeData.event,0,-120,60,"appear",1,12)
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
				A.modeData.point,A.badge=A.modeData.point+1,A.badge+P.badge+1
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
		SFX.play("fail")
		VOICE("lose")
		if modeEnv.royaleMode then BGM.play("end")end
	end
	if #players.alive==1 then
		Event.win(players.alive[1])
	end
	if #players==1 or(P.human and not players[2].human)then
		gameOver()
	end
	newTask(#players>1 and Event_task.lose or Event_task.finish,P)
end
return Event