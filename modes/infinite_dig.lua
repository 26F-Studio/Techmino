local format,rnd=string.format,math.random
local function check_rise(P)
	if #P.clearedRow==0 then
		for i=1,8-P.garbageBeneath do
			P:garbageRise(13,1,rnd(10))
		end
	end
end

return{
	color=color.white,
	env={
		drop=1e99,lock=1e99,
		oncehold=false,
		dropPiece=check_rise,
		pushSpeed=1,
		bg="glow",bgm="infinite",
	},
	load=function()
		PLY.newPlayer(1,340,15)
		for _=1,8 do
			players[1]:garbageRise(13,1,rnd(10))
		end
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		mStr(P.stat.dig,-81,190)
		mStr(P.stat.atk,-81,310)
		mStr(format("%.2f",P.stat.atk/P.stat.row),-81,420)
		mText(drawableText.line,-81,243)
		mText(drawableText.atk,-81,363)
		mText(drawableText.eff,-81,475)
	end,
	score=function(P)return{P.stat.dig}end,
	scoreDisp=function(D)return D[1].." Lines"end,
	comp=function(a,b)return a[1]>b[1]end,
	getRank=function(P)
		local L=P.stat.dig
		return
		L>=626 and 5 or
		L>=400 and 4 or
		L>=200 and 3 or
		L>=100 and 2 or
		L>=40 and 1 or
		L>=5 and 0
	end,
}