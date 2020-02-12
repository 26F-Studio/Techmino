local function update_round(P)
	if #players.alive>1 then
		P.control=false
		local ID=P.id
		repeat
			ID=ID+1
			if not players[ID]then ID=1 end
		until players[ID].alive or ID==P.id
		players[ID].control=true
	end
end

return{
	name={
		"回合制",
		"回合制",
		"Turn-Base",
	},
	level={
		"疯狂",
		"疯狂",
		"LUNATIC",
	},
	info={
		"下棋模式",
		"下棋模式",
		"Chess?",
	},
	color=color.red,
	env={
		drop=60,lock=60,
		oncehold=false,
		dropPiece=update_round,
		bg="game2",bgm="push",
	},
	load=function()
		newPlayer(1,340,15)
		newPlayer(2,965,360,.5,AITemplate("9S",10))
	end,
	mesDisp=function(P,dx,dy)
	end,
	score=function(P)return{P.stat.piece,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Pieces   "..toTime(D[2])end,
	comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		if P.result=="WIN"then
			local T=P.stat.piece
			return
			T<=40 and 5 or
			T<=50 and 4 or
			T<=75 and 3 or
			T<=100 and 2 or
			1
		end
	end,
}