local TEST={}

--Wait for the scene swapping animation to finish
function TEST.yieldUntilNextScene()
    while SCN.swapping do YIELD()end
end

function TEST.yieldN(frames)
    for _=1,frames do YIELD()end
end

return TEST
