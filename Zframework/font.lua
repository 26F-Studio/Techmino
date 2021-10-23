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
function FONT.get(s)
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

function FONT.load(mainFont,secFont)
    assert(love.filesystem.getInfo(mainFont),"Font file '"..mainFont.."' not exist!")
    mainFont=love.filesystem.newFile(mainFont)
    if secFont and love.filesystem.getInfo(secFont)then
        secFont=love.filesystem.newFile(secFont)
    else
        secFont=false
    end
    function FONT.set(s)
        if s~=currentFontSize then
            if not fontCache[s]then
                fontCache[s]=gc.setNewFont(mainFont,s,'light',gc.getDPIScale()*SCR.k*2)
                if secFont then
                    fontCache[s]:setFallbacks(gc.setNewFont(secFont,s,'light',gc.getDPIScale()*SCR.k*2))
                end
            end
            set(fontCache[s])
            currentFontSize=s
        end
    end
    function FONT.get(s)
        if not fontCache[s]then
            fontCache[s]=gc.setNewFont(mainFont,s,'light',gc.getDPIScale()*SCR.k*2)
            if secFont then
                fontCache[s]:setFallbacks(gc.setNewFont(secFont,s,'light',gc.getDPIScale()*SCR.k*2))
            end
        end
        return fontCache[s]
    end
    function FONT.reset()
        for s in next,fontCache do
            fontCache[s]=gc.setNewFont(mainFont,s,'light',gc.getDPIScale()*SCR.k*2)
            if secFont then
                fontCache[s]:setFallbacks(gc.setNewFont(secFont,s,'light',gc.getDPIScale()*SCR.k*2))
            end
        end
    end
    FONT.reset()
end
return FONT
