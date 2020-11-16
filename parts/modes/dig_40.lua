local function check_rise(P)
	for _=1,math.min(8,40-P.stat.dig)-P.garbageBeneath do
		P:garbageRise(21,1,P:getHolePos())
	end
	if P.stat.dig==40 then
		P:win("finish")
	end
end

return{
	color=COLOR.lBlue,
	env={
		pushSpeed=6,
		dropPiece=check_rise,
		bg="bg1",bgm="way",
	},
	load=function()
		PLY.newPlayer(1,340,15)
		local P=PLAYERS[1]
		for _=1,10 do
			P:garbageRise(21,1,P:getHolePos())
		end
		P.fieldBeneath=0
	end,
	mesDisp=function(P)
		setFont(55)
		mStr(40-P.stat.dig,69,335)
	end,
	score=function(P)return{P.stat.time,P.stat.piece}end,
	scoreDisp=function(D)return toTime(D[1]).."   "..D[2].." Pieces"end,
	comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		if P.stat.dig<40 then return end
		local T=P.stat.time
		return
		T<=50 and 5 or
		T<=70 and 4 or
		T<=90 and 3 or
		T<=120 and 2 or
		T<=180 and 1 or
		0
	end,
}