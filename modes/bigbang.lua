local format=string.format
return{
	color=COLOR.lGrey,
	env={
		drop=1e99,lock=1e99,
		hold=false,
		dropPiece=function(P)P:lose()end,
		task=nil,
		bg="bg1",bgm="newera",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	score=function(P)return{P.modeData.event,P.stat.finesseRate*25/P.stat.piece}end,
	scoreDisp=function(D)return D[1].."Stage "..format("%.2f",D[2]).."%"end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]>b[2]end,
	getRank=function(P)
		local W=P.modeData.event
		return
		W>=150 and 5 or
		W>=100 and 4 or
		W>=70 and 3 or
		W>=40 and 2 or
		W>=20 and 1 or
		1
	end,
}