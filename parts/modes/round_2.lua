local function update_round(P)
	if #PLAYERS.alive>1 then
		P.control=false
		local ID=P.id
		repeat
			ID=ID+1
			if not PLAYERS[ID]then ID=1 end
		until PLAYERS[ID].alive or ID==P.id
		PLAYERS[ID].control=true
	end
end

return{
	color=COLOR.green,
	env={
		drop=300,lock=300,
		infHold=true,
		dropPiece=update_round,
		bg="rainbow",bgm="push",
	},
	load=function()
		PLY.newPlayer(1,340,15)
		PLY.newAIPlayer(2,965,360,.5,AIBUILDER("CC",10,1,true,13000))
		GAME.garbageSpeed=1e99
	end,
	score=function(P)return{P.stat.piece,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Pieces   "..toTime(D[2])end,
	comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		if P.result=="WIN"then
			local T=P.stat.piece
			return
			T<=23 and 5 or
			T<=26 and 4 or
			T<=40 and 3 or
			T<=60 and 2 or
			1
		end
	end,
}