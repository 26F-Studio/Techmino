local gc=love.graphics
local int=math.floor
local death_lock={12,11,10,9,8}
local death_wait={10,9,8,7,6}
local death_fall={10,9,8,7,6}
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
		BG.set(s==1 and"game3"or s==2 and"game4"or s==3 and"game5"or s==4 and"game6"or"game5")
		E.lock=death_lock[s]
		E.wait=death_wait[s]
		E.fall=death_fall[s]
		E.das=int(6.9-s*.4)
		if s==3 then P.gameEnv.bone=true end
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
		mindas=6,minarr=1,
		_20G=true,
		lock=death_lock[1],
		wait=death_wait[1],
		fall=death_fall[1],
		dropPiece=score,
		freshLimit=15,
		bg="game2",bgm="secret7th",
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
			S>=426 and 3 or
			S>=326 and 2 or
			S>=226 and 1 or
			S>=50 and 0
		end
	end,
}