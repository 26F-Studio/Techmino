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
			SFX.play("reach")
		end
	end
end

return{
	color=color.lightBlue,
	env={
		noFly=true,
		das=16,arr=6,sddas=2,sdarr=2,
		ghost=false,center=false,
		drop=3,lock=3,wait=10,fall=25,
		next=1,hold=false,
		sequence="rnd",
		freshLimit=0,
		face={0,0,2,2,2,0,0},
		target=10,dropPiece=check_LVup,
		bg="rgb",bgm="rockblock",
	},
	slowMark=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(75)
		local r=P.gameEnv.target*.1
		mStr(r<11 and 18 or r<22 and r+8 or r==22 and"00"or r==23 and"0a"or format("%x",r*10-220),-81,210)
		mText(drawableText.speedLV,-81,290)
		setFont(45)
		mStr(P.stat.row,-81,320)
		mStr(P.gameEnv.target,-81,370)
		gc.rectangle("fill",-125,375,90,4)
	end,
	score=function(P)return{P.stat.score,P.stat.row}end,
	scoreDisp=function(D)return D[1].."   "..D[2].." Lines"end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		return
		L>=200 and 5 or
		L>=191 and 4 or
		L>=110 and 3 or
		L>=50 and 2 or
		L>=5 and 1 or
		L>=1 and 0
	end,
}