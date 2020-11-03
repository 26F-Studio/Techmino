local min=math.min
return{
	color=COLOR.green,
	env={
		drop=20,lock=60,
		sequence="bag",
		bag={1,1,2,2,3,3,4,4,5,5,6,6},
		target=100,dropPiece=PLY.check_lineReach,
		next=3,
		ospin=false,
		freshLimit=15,
		bg="glow",bgm="reason",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		setFont(70)
		local R=100-P.stat.row
		mStr(R>=0 and R or 0,69,335)
	end,
	score=function(P)return{min(P.stat.row,100),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		if L>=100 then
			local T=P.stat.time
			return
			T<=65 and 5 or
			T<=100 and 4 or
			T<=145 and 3 or
			T<=220 and 2 or
			1
		else
			return
			L>=50 and 1 or
			L>=10 and 0
		end
	end,
}