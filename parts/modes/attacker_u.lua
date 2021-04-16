return{
	color=COLOR.lYellow,
	env={
		drop=5,lock=60,
		fall=8,
		freshLimit=15,
		task=function(P)
			while true do
				YIELD()
				if P.control and P.atkBuffer.sum<4 then
					local p=#P.atkBuffer+1
					local B,D=P.atkBuffer,P.modeData
					local s
					local t=800-10*D.wave--800~700~600~500
					if D.wave<10 then
						B[p]=	{line=generateLine(P:RND(5,6)),amount=9,countdown=t,cd0=t,time=0,sent=false,lv=3}
						B[p+1]=	{line=generateLine(P:RND(4,7)),amount=11,countdown=t,cd0=t+62,time=0,sent=false,lv=4}
						s=20
					elseif D.wave<20 then
						B[p]=	{line=generateLine(P:RND(3,8)),amount=11,countdown=t,cd0=t,time=0,sent=false,lv=4}
						B[p+1]=	{line=generateLine(P:RND(4,7)),amount=13,countdown=t,cd0=t+62,time=0,sent=false,lv=5}
						s=24
					else
						B[p]=	{line=generateLine(P:RND(2)*9-8),amount=14,countdown=t,cd0=t,time=0,sent=false,lv=5}
						B[p+1]=	{line=generateLine(P:RND(3,8)),amount=14,countdown=t+62,cd0=t,time=0,sent=false,lv=5}
						s=28
					end
					B.sum=B.sum+s
					P.stat.recv=P.stat.recv+s
					D.wave=D.wave+1
					if D.wave%10==0 then
						if D.wave==10 then
							P:showTextF(text.great,0,-140,100,"appear",.6)
							P.gameEnv.pushSpeed=4
						elseif D.wave==20 then
							P:showTextF(text.awesome,0,-140,100,"appear",.6)
							P.gameEnv.pushSpeed=5
						elseif D.wave==30 then
							P:showTextF(text.maxspeed,0,-140,100,"appear",.6)
						end
					end
				end
			end
		end,
		bg="rainbow2",bgm="shining terminal",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(55)
		mStr(P.modeData.wave,69,200)
		mStr(20+4*math.min(math.floor(P.modeData.wave/10),2),69,320)
		mText(drawableText.wave,69,260)
		mText(drawableText.nextWave,69,380)
	end,
	score=function(P)return{P.modeData.wave,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Waves   "..TIMESTR(D[2])end,
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