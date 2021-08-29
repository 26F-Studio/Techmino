local gc=love.graphics
local newFont=gc.setNewFont
local setNewFont=gc.setFont
local fontCache,currentFontSize={}
if
    love.filesystem.getInfo('font/barlowCond.ttf')and
    love.filesystem.getInfo('font/puhui.ttf')
then
    local fontData=love.filesystem.newFile('font/barlowCond.ttf')
    local fallback=love.filesystem.newFile('font/puhui.ttf')
    function setFont(s)
        if s~=currentFontSize then
            if not fontCache[s]then
                fontCache[s]=newFont(fontData,s,'light',gc.getDPIScale()*SCR.k*2)
                fontCache[s]:setFallbacks(newFont(fallback,s,'light',gc.getDPIScale()*SCR.k*2))
            end
            setNewFont(fontCache[s])
            currentFontSize=s
        end
    end
    function getFont(s)
        if not fontCache[s]then
            fontCache[s]=newFont(fontData,s,'light',gc.getDPIScale()*SCR.k*2)
            fontCache[s]:setFallbacks(newFont(fallback,s,'light',gc.getDPIScale()*SCR.k*2))
        end
        return fontCache[s]
    end
    function resetFont()
        for s in next,fontCache do
            fontCache[s]=newFont(fontData,s,'light',gc.getDPIScale()*SCR.k*2)
            fontCache[s]:setFallbacks(newFont(fallback,s,'light',gc.getDPIScale()*SCR.k*2))
        end
    end
else
    function setFont(s)
        if s~=currentFontSize then
            if not fontCache[s]then
                fontCache[s]=newFont(s,'light',gc.getDPIScale()*SCR.k*2)
            end
            setNewFont(fontCache[s])
            currentFontSize=s
        end
    end
    function getFont(s)
        if not fontCache[s]then
            fontCache[s]=newFont(s,'light',gc.getDPIScale()*SCR.k*2)
        end
        return fontCache[s]
    end
    function resetFont()
        for s in next,fontCache do
            fontCache[s]=newFont(s,'light',gc.getDPIScale()*SCR.k*2)
        end
    end
end
