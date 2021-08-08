local PCbase=require"parts.modes.PCbase"
local PClist=require"parts.modes.PClist"
local PCtype={
	1,1,1,1,2,
	1,1,1,1,3,
	1,1,1,2,
	1,2,1,3,
	1,2,3,
}
local function task_PC(P)
	P.control=false
	for _=1,26 do YIELD()end
	P.control=true
	local base=PCbase[P.modeData.type]
	P:pushLineList(base[P.holeRND:random(#base)],P.modeData.symmetry)
end
local function check(P)
	local r=P.field
	if #r>0 then
		if #r+P.stat.row%4>4 then
			P:lose()
		end
	else
		local type=PCtype[P.stat.pc+1]or 3
		local L=PClist[type][P.holeRND:random(#PClist[type])]
		local symmetry=P.holeRND:random()>.5
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
		sequence='none',
		dropPiece=check,
		RS="SRS",
		bg='rgb',bgm='oxygen',
	},
	load=function()
		PLY.newPlayer(1)
		check(PLAYERS[1])
	end,
	mesDisp=function(P)
		setFont(70)
		mStr(P.stat.pc,63,300)
		mText(drawableText.pc,63,380)
	end,
	score=function(P)return{P.stat.pc,P.stat.time}end,
	scoreDisp=function(D)return D[1].." PCs   "..STRING.time(D[2])end,
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