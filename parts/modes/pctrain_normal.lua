local PCbase=require"parts/modes/PCbase"
local PClist=require"parts/modes/PClist"
local PCtype={
[0]=1,1,1,1,2,
	1,1,1,1,3,
	1,1,1,2,
	1,1,1,3,
	1,1,2,
	1,1,3,
	1,2,
	1,3,
	2,
	3,
}
local function task_PC(P)
	local D=P.modeData
	while true do
		D.counter=D.counter+1
		if D.counter==26 then
			local base=PCbase[D.type]
			P:pushLineList(base[P:RND(#base)],D.symmetry)
		end
		coroutine.yield()
	end
end
local function check(P)
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
		P:pushNextList(L,symmetry)
		P.modeData.counter=P.stat.piece==0 and 20 or 0
		P:newTask(task_PC)
	end
end
return{
	color=COLOR.green,
	env={
		nextCount=4,
		holdCount=0,
		drop=120,lock=180,
		fall=20,
		sequence="none",
		dropPiece=check,
		RS="SRS",
		ospin=false,
		bg="rgb",bgm="oxygen",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
		check(PLAYERS[1])
	end,
	mesDisp=function(P)
		setFont(75)
		mStr(P.stat.pc,69,400)
		mText(drawableText.pc,69,482)
	end,
	score=function(P)return{P.stat.pc,P.stat.frame/60}end,
	scoreDisp=function(D)return D[1].." PCs   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.pc
		return
		L>=126 and 5 or
		L>=62 and 4 or
		L>=42 and 3 or
		L>=26 and 2 or
		L>=12 and 1 or
		L>=2 and 0
	end,
}