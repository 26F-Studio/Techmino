return{
	color=COLOR.dRed,
	env={
		drop=60,lock=60,
		target=400,dropPiece=PLY.check_lineReach,
		bg="rainbow",bgm="push",
	},
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		setFont(55)
		local r=400-P.stat.row
		if r<0 then r=0 end
		mStr(r,69,335)
		P:drawTargetLine(r)
	end,
	score=function(P)return{P.stat.time,P.stat.piece}end,
	scoreDisp=function(D)return toTime(D[1]).."   "..D[2].." Pieces"end,
	comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		if P.stat.row<400 then return end
		local T=P.stat.time
		return
		T<=300 and 5 or
		T<=330 and 4 or
		T<=360 and 3 or
		T<=390 and 2 or
		T<=420 and 1 or
		0
	end,
}