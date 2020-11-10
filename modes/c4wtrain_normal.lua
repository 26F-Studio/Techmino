local min=math.min
local function check_c4w(P)
	if #P.lastPiece.row>0 then
		for _=1,#P.clearedRow do
			P.field[#P.field+1]=FREEROW.get(13)
			P.visTime[#P.visTime+1]=FREEROW.get(20)
			for i=4,7 do P.field[#P.field][i]=0 end
		end
		if P.combo>P.modeData.point then
			P.modeData.point=P.combo
		end
		if P.stat.row>=100 then
			P:win("finish")
		end
	end
end

return{
	color=COLOR.green,
	env={
		drop=30,lock=60,oncehold=false,
		dropPiece=check_c4w,
		freshLimit=15,ospin=false,
		bg="rgb",bgm="oxygen",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
		local P=PLAYERS[1]
		local F=P.field
		for i=1,24 do
			F[i]=FREEROW.get(13)
			P.visTime[i]=FREEROW.get(20)
			for x=4,7 do F[i][x]=0 end
		end
		local r=P:RND(6)
		if r==1 then	 F[1][5],F[1][4],F[2][4]=13,13,13
		elseif r==2 then F[1][6],F[1][7],F[2][7]=13,13,13
		elseif r==3 then F[1][4],F[2][4],F[2][5]=13,13,13
		elseif r==4 then F[1][7],F[2][7],F[2][6]=13,13,13
		elseif r==5 then F[1][4],F[1][5],F[1][6]=13,13,13
		elseif r==6 then F[1][7],F[1][6],F[1][5]=13,13,13
		end
	end,
	mesDisp=function(P)
		setFont(45)
		mStr(P.combo,69,380)
		mStr(P.modeData.point,69,470)
		mText(drawableText.combo,69,428)
		mText(drawableText.maxcmb,69,520)
	end,
	score=function(P)return{min(P.modeData.point,100),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Combo   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		if L==100 then
			local T=P.stat.time
			return
			T<=32 and 5 or
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