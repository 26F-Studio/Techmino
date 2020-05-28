local gc=love.graphics
local int=math.floor
local function score(P)
	local c=#P.clearedRow
	if c==0 and P.modeData.point%100==99 then return end
	local s=c<3 and c+1 or c==3 and 5 or 7
	if P.combo>7 then s=s+2
	elseif P.combo>3 then s=s+1
	end
	local MD=P.modeData
	MD.point=MD.point+s
	if MD.point%100==99 then SFX.play("blip_1")end
	if int(MD.point*.01)>MD.event then
		local s=MD.event+1;MD.event=s--level up!
		P:showTextF(text.stage(s),0,-120,80,"fly")
		local E=P.gameEnv
		if s<4 then--first 300
			if s~=1 then E.lock=E.lock-1 end
			if s~=2 then E.wait=E.wait-1 end
			if s~=3 then E.fall=E.fall-1 end
		elseif s<10 then
			if s==4 or s==7 then E.das=E.das-1 end
			s=s%3
			if s==0 then E.lock=E.lock-1
			elseif s==1 then E.wait=E.wait-1
			elseif s==2 then E.fall=E.fall-1
			end
		else
			MD.point,MD.event=1000,9
			P:win("finish")
		end
		SFX.play("reach")
	end
end

return{
	color=color.lightGrey,
	env={
		noFly=true,
		mindas=5,minarr=1,
		_20G=true,lock=12,
		wait=10,fall=10,
		dropPiece=score,
		freshLimit=15,
		easyFresh=false,bone=true,
		bg="none",bgm="distortion",
	},
	slowMark=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		local MD=P.modeData
		mStr(MD.point,-81,320)
		mStr((MD.event+1)*100,-81,370)
		gc.rectangle("fill",-125,375,90,4)
	end,
	score=function(P)return{P.modeData.point,P.stat.time}end,
	scoreDisp=function(D)return D[1].."P   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local S=P.modeData.point
		return
		S>=1000 and 5 or
		S>=800 and 4 or
		S>=600 and 3 or
		S>=400 and 2 or
		S>=200 and 1 or
		S>=50 and 0
	end,
}