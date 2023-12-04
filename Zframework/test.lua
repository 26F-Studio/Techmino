local yield=coroutine.yield
local TEST={}

-- Wait for the scene swapping animation to finish
function TEST.yieldUntilNextScene()
    while SCN.swapping do yield() end
end

function TEST.yieldN(frames)
    for _=1,frames do yield() end
end

function TEST.yieldT(timeout)
    local t=0
    repeat t=t+yield() until t>=timeout
end

return TEST
