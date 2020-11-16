local int=math.floor
return{
	color=COLOR.green,
	env={
		drop=30,lock=60,
		fall=10,
		next=3,
		freshLimit=15,
		pushSpeed=1,
		task=function(P)
			if not(P.control and SCN.cur=="play")then return end
			P.modeData.counter=P.modeData.counter+1
			local t=360-P.modeData.event*2
			if P.modeData.counter>=t then
				P.modeData.counter=0
				for _=1,3 do
					P.atkBuffer[#P.atkBuffer+1]={pos=P:RND(2,9),amount=1,countdown=2*t,cd0=2*t,time=0,sent=false,lv=1}
				end
				P.atkBuffer.sum=P.atkBuffer.sum+3
				P.stat.recv=P.stat.recv+3
				local D=P.modeData
				if D.event<90 then
					D.event=D.event+1
					D.point=int(108e3/(360-D.event*2))*.1
					if D.event==25 then
						P:showTextF(text.great,0,-140,100,"appear",.6)
						P.gameEnv.pushSpeed=2
						P.dropDelay,P.gameEnv.drop=20,20
					elseif D.event==50 then
						P:showTextF(text.awesome,0,-140,100,"appear",.6)
						P.gameEnv.pushSpeed=3
						P.dropDelay,P.gameEnv.drop=10,10
					elseif D.event==90 then
						P.dropDelay,P.gameEnv.drop=5,5
						P:showTextF(text.maxspeed,0,-140,100,"appear",.6)
					end
				end
			end
		end,
		bg="rainbow2",bgm="storm",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		setFont(55)
		mStr(P.modeData.event,69,270)
		mStr(P.modeData.point,69,390)
		mText(drawableText.wave,69,330)
		mText(drawableText.rpm,69,450)
	end,
	score=function(P)return{P.modeData.event,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Waves   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modeData.event
		return
		W>=120 and 5 or
		W>=100 and 4 or
		W>=70 and 3 or
		W>=40 and 2 or
		W>=10 and 1 or
		W>=3 and 0
	end,
}