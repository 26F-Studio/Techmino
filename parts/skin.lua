local function C(x,y)
    local canvas=GC.newCanvas(x,y)
    GC.setCanvas(canvas)
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

function SKIN.loadUser(dir)
    local ok,_=pcall(love.filesystem.createDirectory,dir)
    if not ok then return end
    local success,items=pcall(love.filesystem.getDirectoryItems,dir)
    if not success or not items then return end
    for _,name in next,items do
        if name:sub(-4):lower()=='.png' then
            local skinName='[User] '..name:sub(1,-5)
            local path=dir..'/'..name
            if not Skins[skinName] then
                table.insert(skinList,skinName)
                Skins[skinName]=path
            end
        end
    end
end

function SKIN.reloadUser(dir)
    for i=#skinList,1,-1 do
        local name=skinList[i]
        if name:sub(1,7)=='[User] ' then
            table.remove(skinList,i)
            Skins[name]=nil
            SKIN.lib[name]=nil
            SKIN.libMini[name]=nil
        end
    end
    SKIN.loadUser(dir)
end

function SKIN.getList() return skinList end

local skinMeta={__index=function(self,name)
    GC.push()
    GC.origin()
    GC.setDefaultFilter('nearest','nearest')
    local I
    local N=Skins[name]
    if N and love.filesystem.getInfo(N) then
        I=GC.newImage(N)
    else
        MES.new('warn',"[no skin] "..name)
    end

    SKIN.lib[name],SKIN.libMini[name]={},{}
    GC.setColor(1,1,1)
    for y=0,2 do
        for x=1,8 do
            SKIN.lib[name][8*y+x]=C(30,30)
            if I then
                GC.draw(I,30-30*x,-30*y)
            end

            SKIN.libMini[name][8*y+x]=C(6,6)
            if I then
                GC.draw(I,6-6*x,-6*y,nil,.2)
            end
        end
    end
    GC.setDefaultFilter('linear','linear')
    GC.setCanvas()
    GC.pop()
    return self[name]
end}
setmetatable(SKIN.lib,skinMeta)
setmetatable(SKIN.libMini,skinMeta)

return SKIN
