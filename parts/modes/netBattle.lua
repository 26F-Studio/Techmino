return{
	color=COLOR.white,
	env={
		drop=30,
		freshLimit=15,
		noMod=true,
	},
	load=function(playerData)
		PLY.newPlayer(1)
		local N=2
		for i=1,#playerData do
			if playerData[i].id==tostring(USER.id)then
				PLAYERS[1].subID=playerData[1].sid
			else
				PLY.newRemotePlayer(N,false,playerData[i])
				N=N+1
			end
		end
	end,
}