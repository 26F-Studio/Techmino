local int=math.floor
return{
	color=COLOR.red,
	env={
		drop=5,lock=60,
		fall=6,
		next=3,
		freshLimit=15,
		pushSpeed=2,
		task=function(P)
			if not(P.control and SCN.cur=="play")then return end
			P.modeData.counter=P.modeData.counter+1
			local t=240-2*P.modeData.event
			if P.modeData.counter>=t then
				P.modeData.counter=0
				for _=1,4 do
					P.atkBuffer[#P.atkBuffer+1]={pos=P:RND(10),amount=1,countdown=5*t,cd0=5*t,time=0,sent=false,lv=2}
				end
				P.atkBuffer.sum=P.atkBuffer.sum+4
				P.stat.recv=P.stat.recv+4
				local D=P.modeData
				if D.event<75 then
					D.event=D.event+1
					D.point=int(144e3/(240-2*D.event))*.1
					if D.event==25 then
						P:showTextF(text.great,0,-140,100,"appear",.6)
						P.gameEnv.pushSpeed=3
						P.dropDelay,P.gameEnv.drop=4,4
					elseif D.event==50 then
						P:showTextF(text.awesome,0,-140,100,"appear",.6)
						P.gameEnv.pushSpeed=4
						P.dropDelay,P.gameEnv.drop=3,3
					elseif D.event==75 then
						P:showTextF(text.maxspeed,0,-140,100,"appear",.6)
						P.dropDelay,P.gameEnv.drop=2,2
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
		W>=100 and 5 or
		W>=80 and 4 or
		W>=55 and 3 or
		W>=30 and 2 or
		W>=20 and 1 or
		W>=5 and 0
	end,
}