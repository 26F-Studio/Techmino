return{
	color=COLOR.white,
	env={
		--TODO: ?
	},
	load=function(playerData)
		PLY.newPlayer(1)
		local N=2
		for i=1,#playerData do
			PLY.newRemotePlayer(N,false,playerData[i])
			N=N+1
		end
	end,
}