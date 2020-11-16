local max=math.max
return{
	color=COLOR.red,
	env={
		drop=30,lock=45,
		freshLimit=10,
		task=function(P)
			if not(P.control and SCN.cur=="play")then return end
			P.modeData.counter=P.modeData.counter+1
			if P.modeData.counter>=max(60,150-P.modeData.event)and P.atkBuffer.sum<20 then
				local t=max(60,90-P.modeData.event)
				P.atkBuffer[#P.atkBuffer+1]={pos=P:RND(10),amount=4,countdown=t,cd0=t,time=0,sent=false,lv=3}
				P.atkBuffer.sum=P.atkBuffer.sum+4
				P.stat.recv=P.stat.recv+4
				if P.modeData.event==60 then P:showTextF(text.maxspeed,0,-140,100,"appear",.6)end
				P.modeData.counter=0
				P.modeData.event=P.modeData.event+1
			end
		end,
		bg="glow",bgm="storm",
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
		W>=110 and 5 or
		W>=80 and 4 or
		W>=55 and 3 or
		W>=30 and 2 or
		W>=15 and 1 or
		W>=5 and 0
	end,
}