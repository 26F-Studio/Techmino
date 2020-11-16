local max=math.max
return{
	color=COLOR.lYellow,
	env={
		drop=10,lock=30,
		freshLimit=15,
		task=function(P)
			if not(P.control and SCN.cur=="play")then return end
			local D=P.modeData
			D.counter=D.counter+1
			if D.counter>=max(30,80-.3*D.event)then
				P:garbageRise(20+D.event%5,1,P:getHolePos())
				P.stat.recv=P.stat.recv+1
				D.counter=0
				D.event=D.event+1
			end
		end,
		bg="bg2",bgm="down",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		setFont(65)
		mStr(P.modeData.event,69,380)
		mText(drawableText.wave,69,445)
	end,
	score=function(P)return{P.modeData.event,P.stat.row}end,
	scoreDisp=function(D)return D[1].." Waves   "..D[2].." Lines"end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modeData.event
		return
		W>=150 and 5 or
		W>=110 and 4 or
		W>=80 and 3 or
		W>=50 and 2 or
		W>=20 and 1 or
		P.stat.row>=5 and 0
	end,
}