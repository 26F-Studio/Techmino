return{
	color=COLOR.lGrey,
	env={
		drop=60,lock=60,
		target=1000,dropPiece=PLY.check_lineReach,
		bg="rainbow",bgm="push",
	},
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(55)
		local r=1000-P.stat.row
		if r<0 then r=0 end
		mStr(r,69,265)
		PLY.draw.drawTargetLine(P,r)
	end,
	score=function(P)return{P.stat.frame/60,P.stat.piece}end,
	scoreDisp=function(D)return toTime(D[1]).."   "..D[2].." Pieces"end,
	comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		if P.stat.row<1000 then return end
		local T=P.stat.frame/60
		return
		T<=750 and 5 or
		T<=950 and 4 or
		T<=1100 and 3 or
		T<=1260 and 2 or
		T<=1600 and 1 or
		0
	end,
}