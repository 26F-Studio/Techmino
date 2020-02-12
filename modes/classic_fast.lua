local gc=love.graphics
local function check_LVup(P)
	if P.stat.row>=P.gameEnv.target then
		P.gameEnv.target=P.gameEnv.target+10
		if P.gameEnv.target==110 then
			P.gameEnv.drop,P.gameEnv.lock=2,2
		elseif P.gameEnv.target==200 then
			P.gameEnv.drop,P.gameEnv.lock=1,1
		end
		if P.gameEnv.target>100 then
			SFX("reach")
		end
	end
end
	
return{
	name={
		"高速经典",
		"高速经典",
		"Classic",
	},
	level={
		"CTWC",
		"锦标赛",
		"CTWC",
	},
	info={
		"高速经典",
		"高速经典",
		"Vintage car drag racing",
	},
	color=color.lightBlue,
	env={
		das=16,arr=6,sddas=2,sdarr=2,
		ghost=false,center=false,
		drop=3,lock=3,wait=10,fall=25,
		next=1,hold=false,
		sequence="rnd",
		freshLimit=0,
		target=10,dropPiece=check_LVup,
		bg="rgb",bgm="rockblock",
	},
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(75)
		local r=P.gameEnv.target*.1
		mStr(r<11 and 18 or r<22 and r+8 or r==22 and"00"or r==23 and"0a"or format("%x",r*10-220),-82,210)
		mDraw(drawableText.speedLV,-82,290)
		setFont(45)
		mStr(P.stat.row,-82,320)
		mStr(P.gameEnv.target,-82,370)
		gc.rectangle("fill",-125,375,90,4)
	end,
	score=function(P)return{P.stat.row,P.stat.score}end,
	scoreDisp=function(D)return D[1].." Rows   "..D[2]end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]>b[2]end,
	getRank=function(P)
		local L=P.stat.row
		return
		L>=200 and 5 or
		L>=191 and 4 or
		L>=110 and 3 or
		L>=50 and 2 or
		L>=2 and 1
	end,
}