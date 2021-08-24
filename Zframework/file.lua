local fs=love.filesystem
local FILE={}
function FILE.load(name)
    if fs.getInfo(name)then
        local F=fs.newFile(name)
        if F:open'r'then
            local s=F:read()
            F:close()
            if s:sub(1,6)=="return"then
                s=loadstring(s)
                if s then
                    setfenv(s,{})
                    return s()
                end
            elseif s:sub(1,1)=="["or s:sub(1,1)=="{"then
                local res=JSON.decode(s)
                if res then
                    return res
                end
            else
                return s
            end
        end
        MES.new('error',name.." "..text.loadError)
    end
end
function FILE.save(data,name,mode)
    if not mode then mode=""end
    if type(data)=='table'then
        if mode:find'l'then
            data=TABLE.dump(data)
            if not data then
                MES.new('error',name.." "..text.saveError.."dump error")
                return
            end
        else
            data=JSON.encode(data)
            if not data then
                MES.new('error',name.." "..text.saveError.."json error")
                return
            end
        end
    else
        data=tostring(data)
    end

    if mode:find'd'and fs.getInfo(name)then
        MES.new('error',text.saveError_duplicate)
        return
    end
    local F=fs.newFile(name)
    F:open'w'
    local success,mes=F:write(data)
    F:flush()F:close()
    if success then
        return true
    else
        MES.new('error',text.saveError..(mes or"unknown error"))
        MES.traceback()
    end
end
function FILE.clear(path)
    if fs.getRealDirectory(path)~=SAVEDIR or fs.getInfo(path).type~='directory'then return end
    for _,name in next,fs.getDirectoryItems(path)do
        name=path..'/'..name
        if fs.getRealDirectory(name)==SAVEDIR then
            local t=fs.getInfo(name).type
            if t=='file'then
                fs.remove(name)
            end
        end
    end
end
function FILE.clear_s(path)
    if path~=''and(fs.getRealDirectory(path)~=SAVEDIR or fs.getInfo(path).type~='directory')then return end
    for _,name in next,fs.getDirectoryItems(path)do
        name=path..'/'..name
        if fs.getRealDirectory(name)==SAVEDIR then
            local t=fs.getInfo(name).type
            if t=='file'then
                fs.remove(name)
            elseif t=='directory'then
                FILE.clear_s(name)
                fs.remove(name)
            end
        end
    end
    fs.remove(path)
end
return FILE