local int=math.floor
local pc_drop={50,45,40,35,30,26,22,18,15,12}
local pc_lock={55,50,45,40,36,32,30}
local pc_fall={18,16,14,12,10,9,8,7,6}
local PCbase=require("modes/PCbase")
local PClist=require("modes/PClist")
local PCtype={[0]=1,2,3,2,3}

local function task_PC(P)
	P.modeData.counter=P.modeData.counter+1
	if P.modeData.counter==26 then
		local base=PCbase[P.modeData.type]
		P:pushLine(base[P:RND(#base)],P.modeData.symmetry)
		return true
	end
end
local function newPC(P)
	local r=P.field
	if r[1]then
		r=r[#r]
		local c=0
		for i=1,10 do if r[i]>0 then c=c+1 end end
		if c<5 then P:lose()end
	end
	if #P.field==0 then
		local type=PCtype[P.stat.pc]or P:RND(2,3)
		local L=PClist[type][P:RND(#PClist[1])]
		local symmetry=P:RND()>.5
		P.modeData.type=type
		P.modeData.symmetry=symmetry
		P:pushNext(L,symmetry)
		P.modeData.counter=P.stat.piece==0 and 20 or 0
		P:newTask(task_PC)

		local s=P.stat.pc*.25
		if int(s)==s and s>0 then
			P.gameEnv.drop=pc_drop[s]or 10
			P.gameEnv.lock=pc_lock[s]or 20
			P.gameEnv.fall=pc_fall[s]or 5
			if s==10 then
				P:showTextF(text.maxspeed,0,-140,100,"appear",.6)
			else
				P:showTextF(text.speedup,0,-140,40,"appear",.8)
			end
		end
	end
end

return{
	color=COLOR.red,
	env={
		next=4,
		hold=false,
		drop=60,lock=60,
		fall=20,
		sequence="none",
		freshLimit=15,
		dropPiece=newPC,
		ospin=false,
		bg="rgb",bgm="oxygen",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
		newPC(PLAYERS[1])
	end,
	mesDisp=function(P)
		setFont(75)
		mStr(P.stat.pc,69,400)
		mText(drawableText.pc,69,482)
	end,
	score=function(P)return{P.stat.pc,P.stat.time}end,
	scoreDisp=function(D)return D[1].." PCs   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.pc
		return
		L>=62 and 5 or
		L>=42 and 4 or
		L>=26 and 3 or
		L>=18 and 2 or
		L>=10 and 1 or
		L>=2 and 0
	end,
}