return{
	color=COLOR.white,
	env={
		--TODO: ?
	},
	load=function(playerData)
		PLY.newPlayer(1)
		if playerData[1]then
			PLAYERS[1].subID=playerData[1].sid
		end
		for i=2,#playerData do
			PLY.newRemotePlayer(i,false,playerData[i])
		end
	end,
}