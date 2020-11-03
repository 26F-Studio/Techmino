local min=math.min
return{
	color=COLOR.lYellow,
	env={
		drop=5,lock=60,
		fall=8,
		freshLimit=15,
		task=function(P)
			if not(P.control and SCN.cur=="play")then return end
			if P.atkBuffer.sum<4 then
				local p=#P.atkBuffer+1
				local B,D=P.atkBuffer,P.modeData
				local s,t
				if D.event<10 then
					t=800-10*D.event--800~700
					B[p]=	{pos=P:RND(5,6),amount=9,countdown=t,cd0=t,time=0,sent=false,lv=3}
					B[p+1]=	{pos=P:RND(4,7),amount=11,countdown=t,cd0=t+62,time=0,sent=false,lv=4}
					s=20
				elseif D.event<20 then
					t=800-10*D.event--700~600
					B[p]=	{pos=P:RND(3,8),amount=11,countdown=t,cd0=t,time=0,sent=false,lv=4}
					B[p+1]=	{pos=P:RND(4,7),amount=13,countdown=t,cd0=t+62,time=0,sent=false,lv=5}
					s=24
				else
					t=600-15*(min(D.event-20,10))--600~450
					B[p]=	{pos=P:RND(2)*9-8,amount=14,countdown=t,cd0=t,time=0,sent=false,lv=5}
					B[p+1]=	{pos=P:RND(3,8),amount=14,countdown=t+62,cd0=t,time=0,sent=false,lv=5}
					s=28
				end
				B.sum=B.sum+s
				P.stat.recv=P.stat.recv+s
				D.event=D.event+1
				if D.event%10==0 then
					if D.event==10 then
						P:showTextF(text.great,0,-140,100,"appear",.6)
						P.gameEnv.pushSpeed=4
					elseif D.event==20 then
						P:showTextF(text.awesome,0,-140,100,"appear",.6)
						P.gameEnv.pushSpeed=5
					elseif D.event==30 then
						P:showTextF(text.maxspeed,0,-140,100,"appear",.6)
					end
				end
			end
		end,
		bg="rainbow2",bgm="shining terminal",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		setFont(55)
		mStr(P.modeData.event,69,270)
		mStr(
			P.modeData.event<10 and 20
			or P.modeData.event<20 and 24
			or 28
		,69,390)
		mText(drawableText.wave,69,330)
		mText(drawableText.nextWave,69,450)
	end,
	score=function(P)return{P.modeData.event,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Waves   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modeData.event
		return
		W>=50 and 5 or
		W>=40 and 4 or
		W>=30 and 3 or
		W>=20 and 2 or
		W>=10 and 1 or
		W>=5 and 0
	end,
}