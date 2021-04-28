local gc=love.graphics

return{
	color=COLOR.lBlue,
	env={
		smooth=false,
		noTele=true,keyCancel={5,6},
		das=16,arr=6,sddas=2,sdarr=2,
		irs=false,ims=false,
		center=0,ghost=0,
		drop=3,lock=3,wait=10,fall=25,
		nextCount=1,holdCount=false,
		sequence="rnd",
		RS="Classic",
		freshLimit=0,
		face={0,0,2,2,2,0,0},
		task=function(P)P.modeData.target=10 end,
		dropPiece=function(P)
			local D=P.modeData
			if P.stat.row>=D.target then
				D.target=D.target+10
				if D.target==110 then
					P.gameEnv.drop,P.gameEnv.lock=2,2
					SFX.play("blip_1")
				elseif D.target==200 then
					P.gameEnv.drop,P.gameEnv.lock=1,1
					SFX.play("blip_1")
				else
					SFX.play("reach")
				end
			end
		end,
		bg="rgb",bgm="magicblock",
	},
	slowMark=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(75)
		local r=P.modeData.target*.1
		mStr(r<11 and 18 or r<22 and r+8 or("%02x"):format(r*10-220),69,210)
		mText(drawableText.speedLV,69,290)
		setFont(45)
		mStr(P.stat.row,69,320)
		mStr(P.modeData.target,69,370)
		gc.rectangle("fill",25,375,90,4)
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