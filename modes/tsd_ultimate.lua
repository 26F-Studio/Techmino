local function check_tsd(P)
	if #P.clearedRow>0 then
		local C=P.lastClear
		if C.id==5 and C.row==2 and C.spin then
			P.modeData.event=P.modeData.event+1
		else
			P:lose()
		end
	end
end

return{
	color=COLOR.lYellow,
	env={
		drop=60,lock=60,
		freshLimit=15,
		dropPiece=check_tsd,
		ospin=false,
		bg="matrix",bgm="push",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		setFont(65)
		mStr(P.modeData.event,69,320)
		mText(drawableText.tsd,69,385)
	end,
	score=function(P)return{P.modeData.event,P.stat.time}end,
	scoreDisp=function(D)return D[1].."TSD   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local T=P.modeData.event
		return
		T>=20 and 5 or
		T>=18 and 4 or
		T>=16 and 3 or
		T>=14 and 2 or
		T>=12 and 1 or
		T>=1 and 0
	end,
}