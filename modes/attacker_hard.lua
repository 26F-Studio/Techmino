local int,rnd=math.floor,math.random
return{
	color=color.magenta,
	env={
		drop=30,lock=60,
		fall=12,
		freshLimit=15,
		pushSpeed=2,
		task=function(P)
			if not(P.control and SCN.cur=="play")then return end
			if P.atkBuffer.sum==0 then
				local p=#P.atkBuffer+1
				local B,D=P.atkBuffer,P.modeData
				local t
				if D.event<20 then
					t=1500-30*D.event--1500~900
					B[p]=	{pos=rnd(4,7),amount=12,countdown=t,cd0=t,time=0,sent=false,lv=3}
					B[p+1]=	{pos=rnd(3,8),amount=10,countdown=t,cd0=t,time=0,sent=false,lv=4}
				else
					t=900-10*(D.event-20)--900~600
					B[p]=	{pos=rnd(10),amount=14,countdown=t,cd0=t,time=0,sent=false,lv=4}
					B[p+1]=	{pos=rnd(4,7),amount=8,countdown=t,cd0=t,time=0,sent=false,lv=5}
				end
				B.sum=B.sum+22
				P.stat.recv=P.stat.recv+22
				if D.event<50 then
					D.event=D.event+1
					D.point=int(72e4/t)*.1
					if D.event==20 then
						P:showTextF(text.great,0,-140,100,"appear",.6)
						P.gameEnv.pushSpeed=3
					elseif D.event==50 then
						P:showTextF(text.maxspeed,0,-140,100,"appear",.6)
					end
				end
			end
		end,
		bg="game3",bgm="push",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(55)
		mStr(P.modeData.event,-81,200)
		mStr("24",-81,320)
		mText(drawableText.wave,-81,260)
		mText(drawableText.nextWave,-81,380)
	end,
	score=function(P)return{P.modeData.event,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Waves   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modeData.event
		return
		W>=100 and 5 or
		W>=80 and 4 or
		W>=60 and 3 or
		W>=40 and 2 or
		W>=20 and 1 or
		W>=5 and 0
	end,
}