local int=math.floor

function sceneInit.sound()
	sceneTemp={
		mini=false,
		b2b=false,
		b3b=false,
		pc=false,
	}
end

local blockName={"z","s","j","l","t","o","i"}
local lineCount={
	"single",
	"double",
	"triple",
}
function keyDown.sound(key)
	local S=sceneTemp
	if key=="1"then
		S.mini=not S.mini
	elseif key=="2"then
		S.b2b=not S.b2b
		if S.b2b then S.b3b=false end
	elseif key=="3"then
		S.b3b=not S.b3b
		if S.b3b then S.b2b=false end
	elseif key=="4"then
		S.pc=not S.pc
	elseif type(key)=="number"then
		local CHN=VOC.getFreeChannel()
		if S.mini then VOC.play("mini",CHN)end
		if S.b2b then VOC.play("b2b",CHN)
		elseif S.b3b then VOC.play("b3b",CHN)
		end
		VOC.play(blockName[int(key/10)].."spin",CHN)
		if key%10>0 then VOC.play(lineCount[key%10],CHN)end
		if S.pc then VOC.play("perfect_clear",CHN)end
	elseif key=="escape"then
		SCN.back()
	end
end