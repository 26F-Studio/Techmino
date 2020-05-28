local int,max,min=math.floor,math.max,math.min
local sectionName={"M7","M8","M9","M","MK","MV","MO","MM","GM"}
local function score(P)
	local F=false
	if P.modeData.point<70 then--if Less then MM
		local R=#P.clearedRow
		if R==0 then return end
		if R==4 then R=10 end
		P.modeData.point=P.modeData.point+R
		P.modeData.event=sectionName[int(P.modeData.point*.1)+1]
	end
end

return{
	color=color.lightBlue,
	env={
		noFly=true,
		minarr=1,
		_20G=true,
		drop=0,lock=15,
		wait=15,fall=6,
		next=3,
		visible="fast",
		freshLimit=15,
		dropPiece=score,
		task=function(P)
			if P.stat.time>=53.5 then
				P.modeData.point=min(P.modeData.point+16,80)
				P.modeData.event=sectionName[int(P.modeData.point*.1)+1]
				P:win("finish")
			end
		end,
		bg="aura",bgm="far",
	},
	slowMark=true,
	load=function()
		PLY.newPlayer(1,340,15)
		players[1].modeData.event="M7"
	end,
	mesDisp=function(P,dx,dy)
		mText(drawableText.line,-81,300)
		mText(drawableText.techrash,-81,420)
		mText(drawableText.grade,-81,170)
		setFont(55)
		mStr(P.modeData.event,-81,110)
		setFont(75)
		mStr(P.stat.row,-81,220)
		mStr(P.stat.clear_S[4],-81,340)
	end,
	score=function(P)return{P.modeData.point,P.stat.score}end,
	scoreDisp=function(D)return sectionName[int(D[1]*.1)+1].."   "..D[2]end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]>b[2]end,
	getRank=function(P)
		local P=P.modeData.point
		return P==80 and 5 or P>=70 and 4 or P>=60 and 3 or P>=40 and 2 or P>=20 and 1 or P>=5 and 0
	end,
}