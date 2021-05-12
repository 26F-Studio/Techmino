return{
	color=COLOR.magenta,
	env={
		drop=30,lock=60,
		fall=12,
		freshLimit=15,
		pushSpeed=2,
		task=function(P)
			while true do
				YIELD()
				if P.control and P.atkBufferSum==0 then
					local D=P.modeData
					if D.wave<20 then
						local t=1500-30*D.wave--1500~900
						table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(4,7)),amount=12,countdown=t,cd0=t,time=0,sent=false,lv=3})
						table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(3,8)),amount=10,countdown=t,cd0=t,time=0,sent=false,lv=4})
					else
						local t=900-10*(D.wave-20)--900~600
						table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(10)),amount=14,countdown=t,cd0=t,time=0,sent=false,lv=4})
						table.insert(P.atkBuffer,{line=generateLine(P.holeRND:random(4,7)),amount=8,countdown=t,cd0=t,time=0,sent=false,lv=5})
					end
					P.atkBufferSum=P.atkBufferSum+22
					P.stat.recv=P.stat.recv+22
					D.wave=D.wave+1
					if D.wave%10==0 then
						if D.wave==20 then
							P:showTextF(text.great,0,-140,100,'appear',.6)
							P.gameEnv.pushSpeed=3
						elseif D.wave==50 then
							P:showTextF(text.maxspeed,0,-140,100,'appear',.6)
						end
					end
				end
			end
		end,
		bg='rainbow2',bgm='shining terminal',
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(55)
		mStr(P.modeData.wave,69,200)
		mStr("22",69,320)
		mText(drawableText.wave,69,260)
		mText(drawableText.nextWave,69,380)
	end,
	score=function(P)return{P.modeData.wave,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Waves   "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modeData.wave
		return
		W>=50 and 5 or
		W>=40 and 4 or
		W>=30 and 3 or
		W>=20 and 2 or
		W>=10 and 1 or
		W>=5 and 0
	end,
}