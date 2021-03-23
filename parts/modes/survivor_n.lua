return{
	color=COLOR.green,
	env={
		drop=30,lock=60,
		freshLimit=10,
		task=function(P)
			while true do
				YIELD()
				if P.control and SCN.cur=="play"then
					local D=P.modeData
					D.timer=D.timer+1
					if D.timer>=math.max(90,180-2*D.wave)and P.atkBuffer.sum<8 then
						local d=D.wave+1
						P.atkBuffer[#P.atkBuffer+1]=
							d%4==0 and{line=generateLine(P:RND(10)),amount=1,countdown=60,cd0=60,time=0,sent=false,lv=1}or
							d%4==1 and{line=generateLine(P:RND(10)),amount=2,countdown=70,cd0=70,time=0,sent=false,lv=1}or
							d%4==2 and{line=generateLine(P:RND(10)),amount=3,countdown=80,cd0=80,time=0,sent=false,lv=2}or
							d%4==3 and{line=generateLine(P:RND(10)),amount=4,countdown=90,cd0=90,time=0,sent=false,lv=3}
						P.atkBuffer.sum=P.atkBuffer.sum+d%4+1
						P.stat.recv=P.stat.recv+d%4+1
						if D.wave==45 then P:showTextF(text.maxspeed,0,-140,100,"appear",.6)end
						D.timer=0
						D.wave=d
					end
				end
			end
		end,
		bg="glow",bgm="secret8th",
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
	scoreDisp=function(D)return D[1].." Waves   "..TIMESTR(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modeData.wave
		return
		W>=80 and 5 or
		W>=55 and 4 or
		W>=45 and 3 or
		W>=30 and 2 or
		W>=15 and 1 or
		W>=5 and 0
	end,
}