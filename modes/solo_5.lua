return{
	name={
		"单挑",
		"单挑",
		"Battle",
	},
	level={
		"极限",
		"极限",
		"ULTIMATE",
	},
	info={
		"打败AI",
		"打败AI",
		"Beat AI",
	},
	color=color.lightYellow,
	env={
		drop=60,lock=60,
		freshLimit=15,
		bg="game2",bgm="race",
	},
	pauseLimit=true,
	load=function()
		newPlayer(1,340,15)
		newPlayer(2,965,360,.5,AITemplate("9S",9))
	end,
	mesDisp=function(P,dx,dy)
	end,
	score=function(P)return{P.stat.time}end,
	scoreDisp=function(D)return toTime(D[1])end,
	comp=function(a,b)return a[1]<b[1]end,
	getRank=function(P)
		if P.result=="WIN"then
			local T=P.stat.time
			return
			T<=20 and 5 or
			T<=30 and 4 or
			T<=45 and 3 or
			T<=60 and 2 or
			1
		end
	end,
}