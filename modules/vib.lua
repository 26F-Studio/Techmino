local level={0,0,.015,.02,.03,.04,.05,.06,.07,.08}
local _=love.system.vibrate
return function(t)
    local L=setting.vib
	if L>0 then
		_(level[L+t])
	end
end