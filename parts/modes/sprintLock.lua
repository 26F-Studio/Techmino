return{
	color=COLOR.green,
	env={
		drop=60,lock=180,
		keyCancel={3,4,5},
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
	score=function(P)return{P.stat.row<=200 and P.stat.row or 200,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		if L<40 then
			return
			L>25 and 2 or
			L>10 and 1 or
			L>2 and 0
		end
		local T=P.stat.time
		return
		T<=60 and 5 or
		T<=100 and 4 or
		3
	end,
}