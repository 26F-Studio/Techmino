return{
	color=COLOR.red,
	env={
		drop=20,lock=60,
		fall=10,
		dropPiece=function(P)
			if P.lastPiece.pc then
				P.gameEnv.heightLimit=4
				if P.stat.pc%5==0 then
					P.gameEnv.drop=math.max(P.gameEnv.drop-1,1)
				end
			else
				P.gameEnv.heightLimit=P.gameEnv.heightLimit-P.lastPiece.row
			end
			if #P.field>P.gameEnv.heightLimit then
				P:lose()
			end
		end,
		freshLimit=8,
		heightLimit=4,
		ospin=false,
		bg='rgb',bgm='moonbeam',
	},
	mesDisp=function(P)
		setFont(60)
		mStr(P.stat.pc,63,300)
		mText(drawableText.pc,63,370)
	end,
	score=function(P)return{P.stat.pc,P.stat.time}end,
	scoreDisp=function(D)return D[1].." PCs   "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.pc
		return
		L>=50 and 5 or
		L>=40 and 4 or
		L>=30 and 3 or
		L>=20 and 2 or
		L>=10 and 1 or
		L>=5 and 0
	end,
}