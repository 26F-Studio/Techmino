return{
	color=color.lYellow,
	env={
		life=2,
		drop=60,lock=60,
		freshLimit=15,
		bg="bg2",bgm="race",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
		PLY.newAIPlayer(2,965,360,.5,AITemplate("CC",7,3,true,50000))
	end,
	score=function(P)return{P.stat.time}end,
	scoreDisp=function(D)return toTime(D[1])end,
	comp=function(a,b)return a[1]<b[1]end,
	getRank=function(P)
		if P.result=="WIN"then
			local T=P.stat.time
			return
			T<=80 and 5 or
			T<=110 and 4 or
			T<=150 and 3 or
			T<=240 and 2 or
			1
		end
	end,
}