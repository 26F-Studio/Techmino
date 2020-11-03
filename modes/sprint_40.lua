return{
	color=COLOR.green,
	env={
		drop=60,lock=60,
		target=40,dropPiece=PLY.check_lineReach,
		bg="bg2",bgm="race",
	},
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		setFont(55)
		local r=40-P.stat.row
		if r<0 then r=0 end
		mStr(r,69,335)
		P:drawTargetLine(r)
	end,
	score=function(P)return{P.stat.time,P.stat.piece}end,
	scoreDisp=function(D)return toTime(D[1]).."   "..D[2].." Pieces"end,
	comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		if P.stat.row<40 then return end
		local T=P.stat.time
		return
		T<=26 and 5 or
		T<=32.6 and 4 or
		T<=52.6 and 3 or
		T<=92.9 and 2 or
		T<=183 and 1 or
		0
	end,
}