return{
	color=COLOR.white,
	env={
		drop=30,
		freshLimit=15,
		pushSpeed=5,
		garbageSpeed=2,
		allowMod=false,
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