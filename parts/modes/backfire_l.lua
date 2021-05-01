return{
	color=COLOR.red,
	env={
		drop=5,lock=45,
		freshLimit=15,
		dropPiece=function(P)
			if P.lastPiece.atk>0 then
				P:receive(nil,P.lastPiece.atk,30,generateLine(P:RND(10)))
			end
			if P.stat.atk>=100 then
				P:win('finish')
			end
		end,
		bg='blackhole',bgm='echo',
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(65)
		mStr(P.stat.atk,69,310)
		mText(drawableText.atk,69,380)
	end,
	score=function(P)return{math.min(math.floor(P.stat.atk),100),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Attack  "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.atk
		if L>=100 then
			local T=P.stat.time
			return
			T<55 and 5 or
			T<70 and 4 or
			T<110 and 3 or
			T<150 and 2 or
			1
		else
			return
			L>=50 and 0
		end
	end,
}