local gc=love.graphics
local death_lock={12,11,10,9,8,  7,7,7,7,6}
local death_wait={10,9, 8, 7,6,  6,6,5,5,4}
local death_fall={10,9, 8, 7,6,  6,5,5,4,4}
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
		SFX.play('blip_1')
	elseif D.pt>=D.target then--Level up!
		s=D.target/100
		local E=P.gameEnv
		E.lock=death_lock[s]
		E.wait=death_wait[s]
		E.fall=death_fall[s]
		if s==2 then
			E.das=5
			BG.set('rainbow')
		elseif s==4 then
			E.das=4
			BG.set('rainbow2')
		elseif s==5 then
			if P.stat.frame>183*60 then
				D.pt=500
				P:win('finish')
				return
			else
				E.bone=true
				P.gameEnv.freshLimit=10
				BG.set('glow')
				BGM.play('secret7th remix')
			end
		elseif s==6 then
			E.das=3
			BG.set('lightning')
		elseif s==7 then
			E.bone=true
		elseif s==10 then
			D.pt=1000
			P:win('finish')
			return
		end
		D.target=D.target+100
		P:showTextF(text.stage:gsub("$1",s),0,-120,80,'beat')
		SFX.play('reach')
	end
end

return{
	color=COLOR.red,
	env={
		noTele=true,
		das=6,arr=1,
		drop=0,
		lock=death_lock[1],
		wait=death_wait[1],
		fall=death_fall[1],
		dropPiece=score,
		task=function(P)
			P.modeData.pt=0
			P.modeData.target=100
		end,
		freshLimit=15,
		noInitSZO=true,
		bg='bg2',bgm='secret7th',
	},
	slowMark=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(45)
		mStr(P.modeData.pt,69,320)
		mStr(P.modeData.target,69,370)
		gc.rectangle('fill',25,375,90,4)
	end,
	score=function(P)return{P.modeData.pt,P.stat.time}end,
	scoreDisp=function(D)return D[1].."P   "..STRING.time(D[2])end,
	comp=function(a,b)
		return a[1]>b[1]or(a[1]==b[1]and a[2]<b[2])
	end,
	getRank=function(P)
		local S=P.modeData.pt
		return
			S>=1000 and 5 or
			S>=800 and 4 or
			S>=500 and 3 or
			S>=300 and 2 or
			S>=100 and 1 or
			S>=60 and 0
	end,
}