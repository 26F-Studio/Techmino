local rnd,min=math.random,math.min
local function check_c4w(P)
	for i=1,#P.clearedRow do
		P.field[#P.field+1]=freeRow.get(13)
		P.visTime[#P.visTime+1]=freeRow.get(20)
		for i=4,7 do P.field[#P.field][i]=0 end
	end
	if #P.clearedRow>0 then
		if P.combo>P.modeData.point then
			P.modeData.point=P.combo
		end
		if P.stat.row>=100 then
			P:win("finish")
		end
	end
end

return{
	color=color.green,
	env={
		drop=30,lock=60,oncehold=false,
		dropPiece=check_c4w,
		freshLimit=15,ospin=false,
		bg="rgb",bgm="oxygen",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
		local P=players[1]
		local F=P.field
		for i=1,24 do
			F[i]=freeRow.get(13)
			P.visTime[i]=freeRow.get(20)
			for x=4,7 do F[i][x]=0 end
		end
		local r=rnd(6)
		if r==1 then	 F[1][5],F[1][4],F[2][4]=13,13,13
		elseif r==2 then F[1][6],F[1][7],F[2][7]=13,13,13
		elseif r==3 then F[1][4],F[2][4],F[2][5]=13,13,13
		elseif r==4 then F[1][7],F[2][7],F[2][6]=13,13,13
		elseif r==5 then F[1][4],F[1][5],F[1][6]=13,13,13
		elseif r==6 then F[1][7],F[1][6],F[1][5]=13,13,13
		end
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		mStr(P.combo,-81,310)
		mStr(P.modeData.point,-81,400)
		mText(drawableText.combo,-81,358)
		mText(drawableText.mxcmb,-81,450)
	end,
	score=function(P)return{min(P.modeData.point,100),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Combo   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		if L==100 then
			local T=P.stat.time
			return
			T<=30 and 5 or
			T<=50 and 4 or
			T<=80 and 3 or
			2
		else
			return
			L>=60 and 2 or
			L>=30 and 1 or
			L>=10 and 0
		end
	end,
}