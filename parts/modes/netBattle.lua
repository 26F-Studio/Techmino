local yield=YIELD
return{
	color=COLOR.white,
	env={
		drop=30,
		freshLimit=15,
		pushSpeed=5,
		garbageSpeed=2,
		allowMod=false,
		task=function(P)
			local S=P.stat
			while true do yield()if S.time>60 then P.strength=1 break end end
			while true do yield()if S.time>120 then P.strength=2 break end end
			while true do yield()if S.time>180 then P.strength=3 break end end
			while true do yield()if S.time>240 then P.strength=4 break end end
		end,
		bgm={'battle','cruelty','distortion','far','final','hope','magicblock','new era','push','race','rockblock','secret7th','secret8th','shining terminal','storm','super7th','warped','waterfall'},
	},
	load=function()
		PLY.newPlayer(1)
		PLAYERS[1].sid=netPLY.getSID(USER.uid)
		for i=2,netPLY.getCount()do
			PLY.newRemotePlayer(i,false,netPLY.getPLY(i))
		end
	end,
}