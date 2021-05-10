return{
	color=COLOR.red,
	env={
		drop=5,lock=60,
		fall=6,
		nextCount=3,
		freshLimit=15,
		pushSpeed=2,
		task=function(P)
			while true do
				YIELD()
				if P.control then
					local D=P.modeData
					D.counter=D.counter+1
					local t=math.max(240-2*D.wave,40)
					if D.counter>=t then
						D.counter=0
						for _=1,4 do
							table.insert(P.atkBuffer,{line=generateLine(P:RND(10)),amount=1,countdown=5*t,cd0=5*t,time=0,sent=false,lv=2})
						end
						P.atkBufferSum=P.atkBufferSum+4
						P.stat.recv=P.stat.recv+4
						D.wave=D.wave+1
						if D.wave<=75 then
							D.rpm=math.floor(144e3/t)*.1
							if D.wave==25 then
								P:showTextF(text.great,0,-140,100,'appear',.6)
								P.gameEnv.pushSpeed=3
								P.dropDelay,P.gameEnv.drop=4,4
							elseif D.wave==50 then
								P:showTextF(text.awesome,0,-140,100,'appear',.6)
								P.gameEnv.pushSpeed=4
								P.dropDelay,P.gameEnv.drop=3,3
							elseif D.wave==75 then
								P:showTextF(text.maxspeed,0,-140,100,'appear',.6)
								P.dropDelay,P.gameEnv.drop=2,2
							end
						end
					end
				end
			end
		end,
		bg='rainbow2',bgm='storm',
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(55)
		mStr(P.modeData.wave,69,200)
		mStr(P.modeData.rpm,69,320)
		mText(drawableText.wave,69,260)
		mText(drawableText.rpm,69,380)
	end,
	score=function(P)return{P.modeData.wave,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Waves   "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modeData.wave
		return
		W>=100 and 5 or
		W>=80 and 4 or
		W>=55 and 3 or
		W>=30 and 2 or
		W>=20 and 1 or
		W>=5 and 0
	end,
}