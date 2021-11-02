local TEST={}

--Wait for the scene swapping animation to finish
function TEST.switchSCN()
    while SCN.swapping do YIELD()end
end

function TEST.wait(frames)
    for _=1,frames do YIELD()end
end

return TEST
