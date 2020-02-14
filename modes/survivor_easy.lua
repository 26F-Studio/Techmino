local max,rnd=math.max,math.random
return{
	name={
		"生存",
		"生存",
		"Survivor",
	},
	level={
		"简单",
		"简单",
		"EASY",
	},
	info={
		"你能存活多久?",
		"你能存活多久?",
		"Survive Longer!",
	},
	color=color.cyan,
	env={
		drop=30,lock=45,
		freshLimit=10,
		task=function(P)
			if not P.control then return end
			P.modeData.counter=P.modeData.counter+1
			if P.modeData.counter>=max(60,150-2*P.modeData.event)and P.atkBuffer.sum<4 then
				P.atkBuffer[#P.atkBuffer+1]={pos=rnd(10),amount=1,countdown=30,cd0=30,time=0,sent=false,lv=1}
				P.atkBuffer.sum=P.atkBuffer.sum+1
				P.stat.recv=P.stat.recv+1
				if P.modeData.event==45 then P:showText(text.maxspeed,0,-140,100,"appear",.6)end
				P.modeData.counter=0
				P.modeData.event=P.modeData.event+1
			end
		end,
		bg="glow",bgm="newera",
	},
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		mDraw(drawableText.line,-82,300)
		mDraw(drawableText.techrash,-82,420)
		setFont(75)
		mStr(P.stat.row,-82,220)
		mStr(P.stat.clear_4,-82,340)
	end,
	score=function(P)return{P.modeData.event,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Waves   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local W=P.modeData.event
		return
		W>=100 and 5 or
		W>=60 and 4 or
		W>=45 and 3 or
		W>=30 and 2 or
		W>=15 and 1 or
		W>=5 and 0
	end,
}