local level={0,0,.01,.015,.02,.03,.04,.05,.06,.07}
local vib=love.system.vibrate
return function(t)
	local L=SETTING.vib
	if L>0 then
		vib(level[L+t])
	end
end