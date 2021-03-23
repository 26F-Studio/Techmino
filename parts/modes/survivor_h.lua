return{
	color=COLOR.magenta,
	env={
		drop=30,lock=60,
		freshLimit=10,
		task=function(P)
			while true do
				YIELD()
				if P.control and SCN.cur=="play"then
					local D=P.modeData
					D.timer=D.timer+1
					local B=P.atkBuffer
					if D.timer>=math.max(60,180-2*D.wave)and B.sum<15 then
						B[#B+1]=
							D.wave%3<2 and
								{line=generateLine(P:RND(10)),amount=1,countdown=0,cd0=0,time=0,sent=false,lv=1}
							or
								{line=generateLine(P:RND(10)),amount=3,countdown=60,cd0=60,time=0,sent=false,lv=2}
						local R=(D.wave%3<2 and 1 or 3)
						B.sum=B.sum+R
						P.stat.recv=P.stat.recv+R
						if D.wave==60 then P:showTextF(text.maxspeed,0,-140,100,"appear",.6)end
						D.timer=0
						D.wave=D.wave+1
					end
				end
			end
		end,
		bg="glow",bgm="secret7th",
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
		W>=90 and 5 or
		W>=60 and 4 or
		W>=45 and 3 or
		W>=30 and 2 or
		W>=15 and 1 or
		W>=5 and 0
	end,
}