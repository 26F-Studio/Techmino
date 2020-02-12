local int,rnd=math.floor,math.random
local ins=table.insert
local pc_drop={50,45,40,35,30,26,22,18,15,12}
local pc_lock={55,50,45,40,36,32,30}
local pc_fall={18,16,14,12,10,9,8,7,6}
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
		local s=P.stat.pc*.5
		if int(s)==s and s>0 then
			P.gameEnv.drop=pc_drop[s]or 10
			P.gameEnv.lock=pc_lock[s]or 20
			P.gameEnv.fall=pc_fall[s]or 5
			if s==10 then
				P:showText(text.maxspeed,0,-140,100,"appear",.6)
			else
				P:showText(text.speedup,0,-140,40,"appear",.8)
			end
		end
	end
end

return{
	name={
		"全清训练",
		"全清训练",
		"PC Train",
	},
	level={
		"疯狂",
		"疯狂",
		"LUNATIC",
	},
	info={
		"简易PC题库,熟悉全清定式的组合",
		"简易全清题库,熟悉全清定式的组合",
		"Let's learn some PCs",
	},
	color=color.red,
	env={
		next=4,
		hold=false,
		drop=60,lock=60,
		fall=20,
		sequence="none",
		freshLimit=15,
		dropPiece=newPC,
		ospin=false,
		bg="rgb",bgm="newera",
	},
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
		L>=50 and 5 or
		L>=40 and 4 or
		L>=30 and 3 or
		L>=20 and 2 or
		L>=10 and 1
	end,
}