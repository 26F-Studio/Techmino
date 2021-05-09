local sectionName={"D","C","B","A","A+","S-","S","S+","SS","SS","SS","U","U","U","X"}
local function score(P)
	--If Less then X
	if P.modeData.rankScore<130 then
		local R=#P.clearedRow
		if R>0 then
			if R==4 then R=10 end--Techrash bonus
			P.modeData.rankScore=math.min(P.modeData.rankScore+R,130)
			P.modeData.rankName=sectionName[math.floor(P.modeData.rankScore/10)+1]
		end
	end
end

return{
	color=COLOR.lBlue,
	env={
		noTele=true,
		minarr=1,
		drop=0,lock=15,
		wait=15,fall=6,
		nextCount=3,
		sequence='hisPool',
		visible='fast',
		freshLimit=15,
		dropPiece=score,
		task=function(P)
			P.modeData.rankScore=0
			P.modeData.rankName=sectionName[1]
			while true do
				YIELD()
				if P.stat.frame>=3600 then
					P.modeData.rankScore=math.min(P.modeData.rankScore+16,140)
					P.modeData.rankName=sectionName[math.floor(P.modeData.rankScore*.1)+1]
					P:win('finish')
					return
				end
			end
		end,
		bg='blockspace',bgm='hope',
	},
	slowMark=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		mText(drawableText.line,69,300)
		mText(drawableText.techrash,69,420)
		mText(drawableText.grade,69,170)
		setFont(55)
		mStr(P.modeData.rankName,69,110)
		setFont(75)
		mStr(P.stat.row,69,220)
		mStr(P.stat.clears[4],69,340)
	end,
	score=function(P)return{P.modeData.rankScore,P.stat.score}end,
	scoreDisp=function(D)return sectionName[math.floor(D[1]*.1)+1].."   "..D[2]end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]>b[2]end,
	getRank=function(P)
		P=P.modeData.rankScore
		return
			P==140 and 5 or
			P>=110 and 4 or
			P>=80 and 3 or
			P>=50 and 2 or
			P>=30 and 1 or
			P>=10 and 0
	end,
}