local function check_tsd(P)
	local C=P.lastPiece
	if C.row>0 then
		if C.id==5 and C.row==2 and C.spin then
			P.modeData.tsd=P.modeData.tsd+1
		else
			P:lose()
		end
	end
end

return{
	color=COLOR.green,
	env={
		drop=1e99,lock=1e99,
		infHold=true,
		dropPiece=check_tsd,
		ospin=false,
		bg='matrix',bgm='vapor',
	},
	mesDisp=function(P)
		setFont(65)
		mStr(P.modeData.tsd,63,250)
		mText(drawableText.tsd,63,315)
	end,
	score=function(P)return{P.modeData.tsd,P.stat.time}end,
	scoreDisp=function(D)return D[1].."TSD   "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local T=P.modeData.tsd
		return
		T>=20 and 5 or
		T>=18 and 4 or
		T>=15 and 3 or
		T>=10 and 2 or
		T>=4 and 1 or
		T>=1 and 0
	end,
}