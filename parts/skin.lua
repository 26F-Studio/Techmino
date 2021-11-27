local gc=love.graphics
local function C(x,y)
    local canvas=gc.newCanvas(x,y)
    gc.setCanvas(canvas)
    return canvas
end

local Skins={}
local skinList={}

local SKIN={
    lib={},
    libMini={},
}

function SKIN.load(list)
    for i=1,#list do
        table.insert(skinList,list[i].name)
        Skins[list[i].name]=list[i].path
    end
end

function SKIN.getList()return skinList end

local skinMeta={__index=function(self,name)
    gc.push()
    gc.origin()
    gc.setDefaultFilter('nearest','nearest')
    local I
    local N=Skins[name]
    if N and love.filesystem.getInfo(N)then
        I=gc.newImage(N)
    else
        MES.new('warn',"[no skin] "..name)
    end

    SKIN.lib[name],SKIN.libMini[name]={},{}
    gc.setColor(1,1,1)
    for y=0,2 do
        for x=1,8 do
            SKIN.lib[name][8*y+x]=C(30,30)
            if I then
                gc.draw(I,30-30*x,-30*y)
            end

            SKIN.libMini[name][8*y+x]=C(6,6)
            if I then
                gc.draw(I,6-6*x,-6*y,nil,.2)
            end
        end
    end
    gc.setDefaultFilter('linear','linear')
    gc.setCanvas()
    gc.pop()
    return self[name]
end}
setmetatable(SKIN.lib,skinMeta)
setmetatable(SKIN.libMini,skinMeta)

return SKIN
