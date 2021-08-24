local level={0,0,.01,.016,.023,.03,.04,.05,.06,.07,.08,.09,.12,.15}
local vib=love.system.vibrate
return function(t)
    local L=SETTING.vib
    if L>0 then
        vib(level[L+t])
    end
end