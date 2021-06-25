return{
	color=COLOR.lGray,
	env={
		drop=1e99,lock=1e99,
		holdCount=0,
		task=function(P)
			while not P.control do YIELD()end
			P:pressKey(6)
			P:lose()
		end,
		bg='bg1',bgm='new era',
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1)
	end,
	score=function(P)return{P.modeData.event,P.stat.finesseRate*.2/P.stat.piece}end,
	scoreDisp=function(D)return("%d Stage %.2f%%"):format(D[1],D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]>b[2]end,
	getRank=function()
		return 1
	end,
}