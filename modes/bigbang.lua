local format=string.format
local function getField()
	local F={}
	return F
end
local function newField(P)
	
end
return{
	name={
		"大爆炸",
		"大爆炸",
		"Big Bang",
	},
	level={
		"简单",
		"简单",
		"EASY",
	},
	info={
		"All-spin 入门教程",
		"All-spin 入门教程",
		"All-spin Tutorial!",
	},
	color=color.grey,
	env={
		drop=1e99,lock=1e99,
		hold=false,
		dropPiece=Event.lose,
		task=nil,
		bg="game1",bgm="newera",
	},
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(60)
		for i=1,5 do
			mStr("UNFINISHED",120+10*i,100+50*i)
		end
	end,
	score=function(P)return{P.modeData.event,P.stat.extraRate}end,
	scoreDisp=function(D)return D[1].."Stage "..format("%.2f",D[2]).."%"end,
	comp=function(a,b)return a[1]>b[1]end,
	getRank=function(P)
		local W=P.modeData.event
		return
		W>=150 and 5 or
		W>=100 and 4 or
		W>=70 and 3 or
		W>=40 and 2 or
		W>=20 and 1 or
		1
	end,
}