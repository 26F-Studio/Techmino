local int,rnd=math.floor,math.random
return{
	name={
		"进攻",
		"进攻",
		"Attacker",
	},
	level={
		"极限",
		"极限",
		"ULTIMATE",
	},
	info={
		"进攻练习",
		"进攻练习",
		"Attacking better then defending",
	},
	color=color.lightYellow,
	env={
		drop=5,lock=60,
		fall=8,
		freshLimit=15,
		task=function(P)
			if not P.control then return end
			if P.atkBuffer.sum<2 then
				local p=#P.atkBuffer+1
				local B,D=P.atkBuffer,P.modeData
				local s,t
				if D.event<10 then
					t=1000-20*D.event--1000~800
					B[p]=	{pos=rnd(5,6),amount=10,countdown=t,cd0=t,time=0,sent=false,lv=3}
					B[p+1]=	{pos=rnd(4,7),amount=12,countdown=t,cd0=t,time=0,sent=false,lv=4}
					s=22
				elseif D.event<20 then
					t=800-20*(D.event-15)--800~600
					B[p]=	{pos=rnd(3,8),amount=11,countdown=t,cd0=t,time=0,sent=false,lv=4}
					B[p+1]=	{pos=rnd(4,7),amount=14,countdown=t,cd0=t,time=0,sent=false,lv=5}
					s=25
				else
					t=600-15*(D.event-30)--600~450
					B[p]=	{pos=rnd(2)*9-8,amount=12,countdown=t,cd0=t,time=0,sent=false,lv=5}
					B[p+1]=	{pos=rnd(3,8),amount=16,countdown=t,cd0=t,time=0,sent=false,lv=5}
					s=28
				end
				B.sum=B.sum+s
				P.stat.recv=P.stat.recv+s
				if D.event<45 then
					D.event=D.event+1
					D.point=int(s*36e3/t)*.1
					if 	D.event==10 then
						P:showText(text.great,0,-140,100,"appear",.6)
						P.gameEnv.pushSpeed=4
					elseif D.event==20 then
						P:showText(text.awesome,0,-140,100,"appear",.6)
						P.gameEnv.pushSpeed=5
					elseif D.event==30 then
						P:showText(text.maxspeed,0,-140,100,"appear",.6)
					end
				end
			end
		end,
		bg="game4",bgm="shining terminal",
},
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(55)
		mStr(P.modeData.event,-82,200)
		mStr(
			P.modeData.event<10 and 22
			or P.modeData.event<20 and 25
			or 28
		,-82,320)
		mDraw(drawableText.wave,-82,260)
		mDraw(drawableText.nextWave,-82,380)
	end,
	score=function(P)return{P.modeData.event,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Waves   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modedata.event
		return W>40 and 4 or W>=30 and 3 or W>=20 and 2 or W>=10 and 1 or W>=5 and 0
	end,
}