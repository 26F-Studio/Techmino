local gc=love.graphics
local rush_lock={20,18,16,15,14}
local rush_wait={12,10,9,8,7}
local rush_fall={18,16,14,13,12}
local function score(P)
	local c=#P.clearedRow
	if c==0 and P.modeData.point%100==99 then return end
	local s=c<3 and c+1 or c==3 and 5 or 7
	if P.combo>7 then s=s+2
	elseif P.combo>3 then s=s+1
	end
	P.modeData.point=P.modeData.point+s
	if P.modeData.point%100==99 then
		SFX.play("blip_1")
	elseif P.modeData.point>=100*(P.modeData.event+1)then
		local s=P.modeData.event+1;P.modeData.event=s--level up!
		local E=P.gameEnv
		BG.set(s==1 and"game1"or s==2 and"game2"or s==3 and"game3"or "game4")
		E.lock=rush_lock[s]
		E.wait=rush_wait[s]
		E.fall=rush_fall[s]
		E.das=10-s
		if s==2 then
			P.gameEnv.arr=2
		elseif s==4 then
			P.gameEnv.bone=true
		end

		if s==5 then
			P.modeData.point,P.modeData.event=500,4
			P:win("finish")
		else
			P:showTextF(text.stage(s),0,-120,80,"fly")
		end
		SFX.play("reach")
	end
end

return{
	color=color.red,
	env={
		noFly=true,
		das=9,arr=3,
		_20G=true,
		lock=rush_lock[1],
		wait=rush_wait[1],
		fall=rush_fall[1],
		dropPiece=score,
		freshLimit=15,
		bg="strap",bgm="secret8th",
	},
	slowMark=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		mStr(P.modeData.point,-81,320)
		mStr((P.modeData.event+1)*100,-81,370)
		gc.rectangle("fill",-125,375,90,4)
	end,
	score=function(P)return{P.modeData.point,P.stat.row,P.stat.time}end,
	scoreDisp=function(D)return D[1].."P   "..D[2].."L   "..toTime(D[3])end,
	comp=function(a,b)
		return a[1]>b[1]or(a[1]==b[1]and(a[2]<b[2]or a[2]==b[2]and a[3]<b[3]))
	end,
	getRank=function(P)
		local S=P.modeData.point
		if S==500 then
			local L=P.stat.clear_S[4]
			return
			L>=30 and 5 or
			L>=25 and 4 or
			3
		else
			return
			S>=420 and 3 or
			S>=250 and 2 or
			S>=120 and 1 or
			S>=30 and 0
		end
	end,
}