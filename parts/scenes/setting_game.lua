local gc=love.graphics
local Timer=love.timer.getTime

local int=math.floor

function sceneInit.setting_game()
	BG.set("space")
end
function sceneBack.setting_game()
	FILE.saveSetting()
end

function Pnt.setting_game()
	gc.setColor(1,1,1)
	gc.draw(blockSkin[int(Timer()*2)%16+1],590,540,Timer()%6.28319,2,nil,15,15)
end