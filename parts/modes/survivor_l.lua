return{
	color=COLOR.red,
	env={
		drop=30,lock=60,
		freshLimit=5,
		task=function(P)
			while true do
				YIELD()
				if P.control then
					local D=P.modeData
					D.timer=D.timer+1
					if D.timer>=math.max(60,150-D.wave)and P.atkBufferSum<20 then
						local t=math.max(60,90-D.wave)
						table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=3})
						P.atkBufferSum=P.atkBufferSum+4
						P.stat.recv=P.stat.recv+4
						if D.wave==60 then P:showTextF(text.maxspeed,0,-140,100,'appear',.6)end
						D.timer=0
						D.wave=D.wave+1
					end
				end
			end
		end,
		bg='glow',bgm='shift',
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(65)
		mStr(P.modeData.wave,69,310)
		mText(drawableText.wave,69,375)
	end,
	score=function(P)return{P.modeData.wave,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Waves   "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modeData.wave
		return
		W>=110 and 5 or
		W>=80 and 4 or
		W>=55 and 3 or
		W>=30 and 2 or
		W>=15 and 1 or
		W>=5 and 0
	end,
}