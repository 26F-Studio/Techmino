local rnd=math.random
local ins=table.insert
local PCbase=require("parts/PCbase")
local PClist=require("parts/PClist")
local function task_PC(P)
	P.modeData.counter=P.modeData.counter+1
	if P.modeData.counter==21 then
		local t=P.stat.pc%2
		for i=1,4 do
			local r=getNewRow(0)
			for j=1,10 do
				r[j]=PCbase[4*t+i][j]
			end
			ins(P.field,1,r)
			ins(P.visTime,1,getNewRow(20))
		end
		P.fieldBeneath=P.fieldBeneath+120
		P.curY=P.curY+4
		P:freshgho()
		return true
	end
end
local function newPC(P)
	local r=P.field;r=r[#r]
	if r then
		local c=0
		for i=1,10 do if r[i]>0 then c=c+1 end end
		if c<5 then
			Event.lose(P)
		end
	end
	if P.stat.piece%4==0 and #P.field==0 then
		P.modeData.event=P.modeData.event==0 and 1 or 0
		local r=rnd(#PClist)
		local f=P.modeData.event==0
		for i=1,4 do
			local b=PClist[r][i]
			if f then
				if b<3 then b=3-b
				elseif b<5 then b=7-b
				end
			end
			P.next[#P.next+1]={bk=blocks[b][0],id=b,color=b,name=b}--P:newNext(b)'s simple version!
		end
		P.modeData.counter=P.stat.piece==0 and 20 or 0
		newTask(task_PC,P)
	end
end
return{
	name={
		"全清训练",
		"全清训练",
		"PC Train",
	},
	level={
		"普通",
		"普通",
		"NORMAL",
	},
	info={
		"简易PC题库,熟悉全清定式的组合",
		"简易全清题库,熟悉全清定式的组合",
		"Let's learn some PCs",
	},
	color=color.green,
	env={
		next=4,
		hold=false,
		drop=150,lock=150,
		fall=20,
		sequence="none",
		dropPiece=newPC,
		ospin=false,
		bg="rgb",bgm="oxygen",
	},
	pauseLimit=true,
	load=function()
		newPlayer(1,340,15)
		newPC(players[1])
	end,
	mesDisp=function(P,dx,dy)
		setFont(75)
		mStr(P.stat.pc,-82,330)
		mDraw(drawableText.pc,-82,412)
	end,
	score=function(P)return{P.stat.pc,P.stat.time}end,
	scoreDisp=function(D)return D[1].." PCs   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.pc
		return
		L>=100 and 5 or
		L>=60 and 4 or
		L>=40 and 3 or
		L>=25 and 2 or
		L>=15 and 1 or
		L>=1 and 0
	end,
}