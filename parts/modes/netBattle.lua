return{
	color=COLOR.white,
	env={
		drop=30,
		freshLimit=15,
		noMod=true,
		bg="space",
	},
	load=function()
		PLY.newPlayer(1)
		local N=2
		for i=1,#PLY_NET do
			if PLY_NET[i].uid==USER.uid then
				PLAYERS[1].subID=PLY_NET[1].sid
			else
				PLY.newRemotePlayer(N,false,PLY_NET[i])
				N=N+1
			end
		end
	end,
}