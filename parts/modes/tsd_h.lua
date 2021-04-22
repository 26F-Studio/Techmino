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
	color=COLOR.magenta,
	env={
		drop=60,lock=60,
		freshLimit=15,
		dropPiece=check_tsd,
		ospin=false,
		bg="matrix",bgm="vapor",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(65)
		mStr(P.modeData.tsd,69,250)
		mText(drawableText.tsd,69,315)
	end,
	score=function(P)return{P.modeData.tsd,P.stat.time}end,
	scoreDisp=function(D)return D[1].."TSD   "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local T=P.modeData.tsd
		return
		T>=21 and 5 or
		T>=19 and 4 or
		T>=16 and 3 or
		T>=13 and 2 or
		T>=10 and 1 or
		T>=1 and 0
	end,
}