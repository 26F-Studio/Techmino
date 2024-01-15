local set=GC.setFont
local fontFiles,fontCache={},{}
local defaultFont,defaultFallBack
local curFont=false-- Current using font object

local FONT={}
function FONT.setDefault(name) defaultFont=name end
function FONT.setFallback(name) defaultFallBack=name end
function FONT.rawget(s)
    if not fontCache[s] then
        fontCache[s]=GC.setNewFont(s,'light',GC.getDPIScale()*SCR.k*2)
    end
    return fontCache[s]
end
function FONT.rawset(s)
    set(fontCache[s] or FONT.rawget(s))
end
function FONT.load(fonts)
    for name,path in next,fonts do
        assert(love.filesystem.getInfo(path),STRING.repD("Font file $1($2) not exist!",name,path))
        fontFiles[name]=love.filesystem.newFile(path)
        fontCache[name]={}
    end
    FONT.reset()
end
function FONT.get(size,name)
    if not name then name=defaultFont end
    local f=fontCache[name][size]
    if not f then
        f=GC.setNewFont(fontFiles[name],size,'light',GC.getDPIScale()*SCR.k*2)
        if defaultFallBack and name~=defaultFallBack then
            f:setFallbacks(FONT.get(size,defaultFallBack))
        end
        fontCache[name][size]=f
    end
    return f
end
function FONT.set(size,name)
    if not name then name=defaultFont end

    local f=fontCache[name][size]
    if f~=curFont then
        curFont=f or FONT.get(size,name)
        set(curFont)
    end
end
function FONT.reset()
    for name,cache in next,fontCache do
        if type(cache)=='table' then
            for size in next,cache do
                cache[size]=FONT.get(size,name)
            end
        else
            fontCache[name]=FONT.rawget(name)
        end
    end
end

return FONT
