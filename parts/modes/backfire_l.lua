local format=string.format
return{
	color=COLOR.lGrey,
	env={
		drop=30,lock=60,
		dropPiece=function(P)
			if P.lastPiece.atk>0 then
				P:receive(nil,P.lastPiece.atk,30,generateLine(P:RND(10)))
				if P.stat.atk>=200 then
					P:win("finish")
				end
			end
		end,
		bg="blackhole",bgm="echo",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(45)
		mStr(format("%.1f",P.stat.atk),69,247)
		mText(drawableText.atk,69,300)
	end,
	score=function(P)return{P.stat.atk<=200 and math.floor(P.stat.atk)or 200,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Attack  "..TIMESTR(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.atk
		if L>=200 then
			local T=P.stat.time
			return
			T<120 and 5 or
			T<150 and 4 or
			T<200 and 3 or
			2
		else
			return
			L>=126 and 1 or
			L>=30 and 0
		end
	end,
}