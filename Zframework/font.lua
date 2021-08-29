local gc=love.graphics
local set=gc.setFont
local fontCache={}
local currentFontSize

local FONT={}
function FONT.set(s)
    if s~=currentFontSize then
        if not fontCache[s]then
            fontCache[s]=gc.setNewFont(s,'light',gc.getDPIScale()*SCR.k*2)
        end
        set(fontCache[s])
        currentFontSize=s
    end
end
function FONT.get(s)print(1)
    if not fontCache[s]then
        fontCache[s]=gc.setNewFont(s,'light',gc.getDPIScale()*SCR.k*2)
    end
    return fontCache[s]
end
function FONT.reset()
    for s in next,fontCache do
        fontCache[s]=gc.setNewFont(s,'light',gc.getDPIScale()*SCR.k*2)
    end
end

function FONT.init(mainFont,secFont)
    mainFont=love.filesystem.newFile(mainFont)
    secFont=love.filesystem.newFile(secFont)
    function FONT.set(s)
        if s~=currentFontSize then
            if not fontCache[s]then
                fontCache[s]=gc.setNewFont(mainFont,s,'light',gc.getDPIScale()*SCR.k*2)
                fontCache[s]:setFallbacks(gc.setNewFont(secFont,s,'light',gc.getDPIScale()*SCR.k*2))
            end
            set(fontCache[s])
            currentFontSize=s
        end
    end
    function FONT.get(s)
        if not fontCache[s]then
            fontCache[s]=gc.setNewFont(mainFont,s,'light',gc.getDPIScale()*SCR.k*2)
            fontCache[s]:setFallbacks(gc.setNewFont(secFont,s,'light',gc.getDPIScale()*SCR.k*2))
        end
        return fontCache[s]
    end
    function FONT.reset()
        for s in next,fontCache do
            fontCache[s]=gc.setNewFont(mainFont,s,'light',gc.getDPIScale()*SCR.k*2)
            fontCache[s]:setFallbacks(gc.setNewFont(secFont,s,'light',gc.getDPIScale()*SCR.k*2))
        end
    end
    FONT.reset()
end
return FONT
