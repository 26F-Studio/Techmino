return{
	color=COLOR.green,
	env={
		drop=60,lock=60,
		sequence="bag",bag={8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25},
		target=40,dropPiece=PLY.check_lineReach,
		bg="aura",bgm="waterfall",
	},
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		setFont(55)
		local r=40-P.stat.row
		if r<0 then r=0 end
		mStr(r,69,335)
		PLY.draw.drawTargetLine(P,r)
	end,
	score=function(P)return{P.stat.time,P.stat.piece}end,
	scoreDisp=function(D)return toTime(D[1]).."   "..D[2].." Pieces"end,
	comp=function(a,b)return a[1]<b[1]or(a[1]==b[1] and a[2]<b[2])end,
	getRank=function(P)
		if P.stat.row<40 then return end
		local T=P.stat.time
		return
		T<=76 and 5 or
		T<=90 and 4 or
		T<=150 and 3 or
		T<=260 and 2 or
		T<=500 and 1 or
		0
	end,
}