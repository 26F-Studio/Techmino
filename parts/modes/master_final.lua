local gc=love.graphics
local function score(P)
	local D=P.modeData

	local c=#P.clearedRow
	if c==0 and D.pt%100==99 then return end
	local s=c<3 and c+1 or c==3 and 5 or 7
	if P.combo>7 then s=s+2
	elseif P.combo>3 then s=s+1
	end
	D.pt=D.pt+s

	if D.pt%100==99 then
		SFX.play("blip_1")
	elseif D.pt>=D.target then--Level up!
		s=D.target/100
		local E=P.gameEnv
		if s<4 then
			P:showTextF(text.stage:gsub("$1",s),0,-120,80,"fly")
			--First 300
			if s~=1 then E.lock=E.lock-1 end
			if s~=2 then E.wait=E.wait-1 end
			if s~=3 then E.fall=E.fall-1 end
			D.target=D.target+100
		elseif s<10 then
			P:showTextF(text.stage:gsub("$1",s),0,-120,60,"fly",1.26)
			if s==4 or s==7 then E.das=E.das-1 end
			s=s%3
			if s==0 then E.lock=E.lock-1
			elseif s==1 then E.wait=E.wait-1
			elseif s==2 then E.fall=E.fall-1
			end
			D.target=D.target+100
		else
			D.pt=1000
			P:win("finish")
		end
		SFX.play("reach")
	end
end

return{
	color=COLOR.lGray,
	env={
		noTele=true,
		das=5,arr=1,
		drop=0,lock=12,
		wait=10,fall=10,
		dropPiece=score,
		task=function(P)
			P.modeData.pt=0
			P.modeData.target=100
		end,
		freshLimit=15,
		easyFresh=false,bone=true,
		bg="lightning",bgm="distortion",
	},
	slowMark=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(45)
		mStr(P.modeData.pt,69,320)
		mStr(P.modeData.target,69,370)
		gc.rectangle("fill",25,375,90,4)
	end,
	score=function(P)return{P.modeData.pt,P.stat.time}end,
	scoreDisp=function(D)return D[1].."P   "..TIMESTR(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local S=P.modeData.pt
		return
		S>=1000 and 5 or
		S>=800 and 4 or
		S>=600 and 3 or
		S>=400 and 2 or
		S>=200 and 1 or
		S>=50 and 0
	end,
}