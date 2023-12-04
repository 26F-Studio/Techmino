local level={0,0,.01,.016,.023,.03,.04,.05,.06,.07,.08,.09,.12,.15}
local vib=love.system.vibrate
return SYSTEM=='iOS' and
    function(t)
        t=level[t]
        if t then vib(t<=.03 and 1 or t<=.09 and 2 or 3) end
    end
or
    function(t)
        t=level[t]
        if t then vib(t) end
    end