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
		local N=2
		for i=1,#PLY_NET do
			if PLY_NET[i].uid==USER.uid then
				PLAYERS[1].sid=PLY_NET[1].sid
			else
				PLY.newRemotePlayer(N,false,PLY_NET[i])
				N=N+1
			end
		end
	end,
}