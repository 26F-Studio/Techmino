--Utils for testing
local testing={}

--Wait for the scene swapping animation to finish
function testing.switchSCN()
    while SCN.swapping do YIELD()end
end

function testing.sleep(frames)
    for _=1,frames do YIELD()end
end

return testing
