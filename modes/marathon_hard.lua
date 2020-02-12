local gc=love.graphics
local function check(P)
	if P.stat.row>=200 then
		Event.win(P,"finish")
	end
end

return{
	name={
		"马拉松",
		"马拉松",
		"Marathon",
	},
	level={
		"困难",
		"困难",
		"HARD",
	},
	info={
		"200行20G马拉松",
		"200行20G马拉松",
		"200L marathon in 20G",
	},
	color=color.magenta,
	env={
		_20G=true,fall=15,
		dropPiece=check,
		bg="strap",bgm="race",
	},
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		mStr(P.stat.row,-82,320)
		mStr(200,-82,370)
		gc.rectangle("fill",-125,375,90,4)
	end,
	score=function(P)return{P.stat.row<=200 and P.stat.row or 200,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Rows   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		if L==200 then
			local T=P.stat.time
			return
			T<=200 and 5 or
			T<=260 and 4 or
			3
		else
			return
			L>=100 and 2 or
			L>=50 and 1
		end
	end,
}