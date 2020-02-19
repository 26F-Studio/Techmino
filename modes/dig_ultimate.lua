local max,rnd=math.max,math.random
return{
	name={
		"挖掘",
		"挖掘",
		"Dig",
	},
	level={
		"极限",
		"极限",
		"ULTIMATE",
	},
	info={
		"挖掘练习",
		"挖掘练习",
		"Downstack!",
	},
	color=color.lightYellow,
	env={
		drop=10,lock=30,
		freshLimit=15,
		task=function(P)
			if not P.control then return end
			P.modeData.counter=P.modeData.counter+1
			if P.modeData.counter>=max(45,80-.3*P.modeData.event)then
				P.modeData.counter=0
				P:garbageRise(11+P.modeData.event%3,1,rnd(10))
				P.modeData.event=P.modeData.event+1
			end
		end,
		bg="game2",bgm="secret7th",
	},
	pauseLimit=true,
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(65)
		mStr(P.modeData.event,-82,310)
		mDraw(drawableText.wave,-82,375)
	end,
	score=function(P)return{P.modeData.event,P.stat.row}end,
	scoreDisp=function(D)return D[1].." Waves   "..D[2].." Lines"end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modeData.event
		return
		W>=120 and 5 or
		W>=100 and 4 or
		W>=80 and 3 or
		W>=50 and 2 or
		W>=20 and 1 or
		L>=5 and 0
	end,
}