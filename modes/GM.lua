local int,max,min=math.floor,math.max,math.min
local sectionName={"M7","M8","M9","M","MK","MV","MO","MM","GM"}
local function score(P)
	local F=false
	if P.modeData.point<70 then--if Less then MM
		local R=#P.cleared
		if R==0 then return end
		if R==4 then R=10 end
		P.modeData.point=P.modeData.point+R
		P.modeData.event=sectionName[int(P.modeData.point*.1)+1]
	end
end

return{
	name={
		"宗师",
		"宗师",
		"GrandMaster",
	},
	level={
		"GM",
		"GM",
		"GM",
	},
	info={
		"成为方块大师",
		"成为方块大师",
		"To be Grand Master",
	},
	color=color.lightBlue,
	env={
		_20G=true,
		drop=0,lock=15,
		wait=10,fall=15,
		next=3,
		visible="fast",
		freshLimit=15,
		dropPiece=score,
		task=function(P)
			if P.stat.time>=53.5 then
				P.modeData.point=min(P.modeData.point+16,80)
				P.modeData.event=sectionName[int(P.modeData.point*.1)+1]
				Event.win(P,"finish")
			end
		end,
		minarr=1,
		bg="game3",bgm="shining terminal",
},
	load=function()
		newPlayer(1,340,15)
		players[1].modeData.event="M7"
	end,
	mesDisp=function(P,dx,dy)
		mDraw(drawableText.line,-82,300)
		mDraw(drawableText.techrash,-82,420)
		mDraw(drawableText.grade,-82,170)
		setFont(55)
		mStr(P.modeData.event,-82,110)
		setFont(75)
		mStr(P.stat.row,-82,220)
		mStr(P.stat.clear_4,-82,340)
	end,
	score=function(P)return{P.modeData.point,P.stat.score}end,
	scoreDisp=function(D)return sectionName[int(D[1]*.1)+1].."   "..D[2]end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]>b[2]end,
	getRank=function(P)
		local P=P.modeData.point
		return P==80 and 5 or P>=70 and 4 or P>=60 and 3 or P>=40 and 2 or P>=20 and 1 or P>=5 and 0
	end,
}