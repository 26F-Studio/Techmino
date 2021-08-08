return{
	color=COLOR.cyan,
	env={
		drop=30,lock=45,
		freshLimit=10,
		task=function(P)
			while true do
				YIELD()
				if P.control then
					local D=P.modeData
					D.timer=D.timer+1
					if D.timer>=math.max(60,150-2*D.wave)and P.atkBufferSum<4 then
						table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=1,countdown=30,cd0=30,time=0,sent=false,lv=1})
						P.atkBufferSum=P.atkBufferSum+1
						P.stat.recv=P.stat.recv+1
						if D.wave==45 then P:showTextF(text.maxspeed,0,-140,100,'appear',.6)end
						D.timer=0
						D.wave=D.wave+1
					end
				end
			end
		end,
		bg='glow',bgm='new era',
	},
	mesDisp=function(P)
		setFont(65)
		mStr(P.modeData.wave,63,310)
		mText(drawableText.wave,63,375)
	end,
	score=function(P)return{P.modeData.wave,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Waves   "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modeData.wave
		return
		W>=100 and 5 or
		W>=60 and 4 or
		W>=45 and 3 or
		W>=30 and 2 or
		W>=15 and 1 or
		W>=5 and 0
	end,
}