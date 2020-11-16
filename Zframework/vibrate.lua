local level={0,0,.015,.02,.03,.04,.05,.06,.07,.08}
local VIB=love.system.vibrate
return function(t)
	local L=SETTING.vib
	if L>0 then
		VIB(level[L+t])
	end
end