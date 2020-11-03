local max=math.max
return{
	color=COLOR.lYellow,
	env={
		drop=5,lock=60,
		fall=10,
		freshLimit=15,
		pushSpeed=2,
		task=function(P)
			if not(P.control and SCN.cur=="play")then return end
			P.modeData.counter=P.modeData.counter+1
			if P.modeData.counter>=max(300,600-10*P.modeData.event)and P.atkBuffer.sum<20 then
				local t=max(300,480-12*P.modeData.event)
				local p=#P.atkBuffer+1
					P.atkBuffer[p]	={pos=P:RND(10),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=2}
					P.atkBuffer[p+1]={pos=P:RND(10),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=3}
					P.atkBuffer[p+2]={pos=P:RND(10),amount=6,countdown=1.2*t,cd0=1.2*t,time=0,sent=false,lv=4}
					P.atkBuffer[p+3]={pos=P:RND(10),amount=6,countdown=1.5*t,cd0=1.5*t,time=0,sent=false,lv=5}
				P.atkBuffer.sum=P.atkBuffer.sum+20
				P.stat.recv=P.stat.recv+20
				if P.modeData.event==31 then P:showTextF(text.maxspeed,0,-140,100,"appear",.6)end
				P.modeData.counter=0
				P.modeData.event=P.modeData.event+1
			end
		end,
		bg="welcome",bgm="storm",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		setFont(65)
		mStr(P.modeData.event,69,380)
		mText(drawableText.wave,69,445)
	end,
	score=function(P)return{P.modeData.event,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Waves   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modeData.event
		return
		W>=35 and 5 or
		W>=26 and 4 or
		W>=20 and 3 or
		W>=10 and 2 or
		W>=5 and 1 or
		W>=1 and 0
	end,
}