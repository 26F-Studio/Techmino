local format=string.format
local function check_rise(P)
	local L=P.garbageBeneath
	if #P.clearedRow==0 then
		if L>0 then
			if L<3 then
				P:showTextF(text.almost,0,-120,80,"beat",.8)
			elseif L<5 then
				P:showTextF(text.great,0,-120,80,"fly",.8)
			end
		end
		for _=1,8-L do
			P:garbageRise(13,1,P:RND(10))
		end
	else
		if L==0 then
			P:showTextF(text.awesome,0,-120,80,"beat",.6)
			SFX.play("clear")
			BG.send(26)
			for _=1,8 do
				P:garbageRise(13,1,P:RND(10))
			end
		else
			BG.send(#P.clearedRow)
		end
	end
end

return{
	color=COLOR.white,
	env={
		drop=1e99,lock=1e99,
		oncehold=false,
		dropPiece=check_rise,
		pushSpeed=1.2,
		bg="wing",bgm="infinite",
	},
	load=function()
		PLY.newPlayer(1,340,15)
		local P=PLAYERS[1]
		for _=1,8 do
			P:garbageRise(13,1,P:RND(10))
		end
		P.fieldBeneath=0
	end,
	mesDisp=function(P)
		setFont(45)
		mStr(P.stat.dig,69,260)
		mStr(P.stat.atk,69,380)
		mStr(format("%.2f",P.stat.atk/P.stat.row),69,490)
		mText(drawableText.line,69,313)
		mText(drawableText.atk,69,433)
		mText(drawableText.eff,69,545)
	end,
}