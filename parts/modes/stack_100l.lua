local function getHoleCount(P)
	local hole=0
	for x=1,10 do
		for y=1,98 do
			if not P:solid(x,y)then
				holes=holes+1
			end
		end
	end
	return hole
end
return{
	color=COLOR.cyan,
	env={
		drop=60,lock=120,
		freshLimit=15,
		fieldH=100,
		highCam=true,
		fillClear=false,
		seqData={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25},
		bg='blockrain',bgm='there',
	},
	mesDisp=function(P)
		setFont(60)
		mStr(P.stat.piece,63,280)
		mText(drawableText.piece,63,350)
	end,
	score=function(P)return{getHoleCount(P),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Holes".."   "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local H=getHoleCount(P)
		return
		H<=2 and 5 or
		H<=5 and 4 or
		H<=10 and 3 or
		H<=15 and 2 or
		H<=20 and 1 or
		H<=26 and 0
	end,
}