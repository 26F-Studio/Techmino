local max=math.max
return{
	color=COLOR.magenta,
	env={
		drop=30,lock=45,
		freshLimit=10,
		task=function(P)
			if not(P.control and SCN.cur=="play")then return end
			P.modeData.counter=P.modeData.counter+1
			local B=P.atkBuffer
			if P.modeData.counter>=max(60,180-2*P.modeData.event)and B.sum<15 then
				B[#B+1]=
					P.modeData.event%3<2 and
						{pos=P:RND(10),amount=1,countdown=0,cd0=0,time=0,sent=false,lv=1}
					or
						{pos=P:RND(10),amount=3,countdown=60,cd0=60,time=0,sent=false,lv=2}
				local R=(P.modeData.event%3<2 and 1 or 3)
				B.sum=B.sum+R
				P.stat.recv=P.stat.recv+R
				if P.modeData.event==60 then P:showTextF(text.maxspeed,0,-140,100,"appear",.6)end
				P.modeData.counter=0
				P.modeData.event=P.modeData.event+1
			end
		end,
		bg="glow",bgm="secret7th",
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
		W>=90 and 5 or
		W>=60 and 4 or
		W>=45 and 3 or
		W>=30 and 2 or
		W>=15 and 1 or
		W>=5 and 0
	end,
}