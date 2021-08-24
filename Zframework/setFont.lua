local gc=love.graphics
local newFont=gc.setNewFont
local setNewFont=gc.setFont
local fontCache,currentFontSize={}
if love.filesystem.getInfo('font.ttf')then
    local fontData=love.filesystem.newFile('font.ttf')
    function setFont(s)
        if s~=currentFontSize then
            if not fontCache[s]then
                fontCache[s]=newFont(fontData,s)
            end
            setNewFont(fontCache[s])
            currentFontSize=s
        end
    end
    function getFont(s)
        if not fontCache[s]then
            fontCache[s]=newFont(fontData,s)
        end
        return fontCache[s]
    end
else
    function setFont(s)
        if s~=currentFontSize then
            if not fontCache[s]then
                fontCache[s]=newFont(s)
            end
            setNewFont(fontCache[s])
            currentFontSize=s
        end
    end
    function getFont(s)
        if not fontCache[s]then
            fontCache[s]=newFont(s)
        end
        return fontCache[s]
    end
end