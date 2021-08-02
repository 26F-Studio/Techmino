return{
	color=COLOR.magenta,
	env={
		drop=60,lock=120,
		fall=20,
		freshLimit=15,
		task=function(P)
			while true do
				YIELD()
				if P.control then
					local D=P.modeData
					D.timer=D.timer+1
					if D.timer>=math.max(90,180-D.wave)then
						P:garbageRise(21,1,P:getHolePos())
						P.stat.recv=P.stat.recv+1
						D.timer=0
						D.wave=D.wave+1
					end
				end
			end
		end,
		bg='bg2',bgm='there',
	},
	mesDisp=function(P)
		setFont(65)
		mStr(P.modeData.wave,69,310)
		mText(drawableText.wave,69,375)
	end,
	score=function(P)return{P.modeData.wave,P.stat.row}end,
	scoreDisp=function(D)return D[1].." Waves   "..D[2].." Lines"end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modeData.wave
		return
		W>=150 and 5 or
		W>=110 and 4 or
		W>=80 and 3 or
		W>=50 and 2 or
		W>=20 and 1 or
		P.stat.row>=5 and 0
	end,
}