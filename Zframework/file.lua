local fs=love.filesystem
local FILE={}
function FILE.load(name,args)
    if not args then args=''end
    if fs.getInfo(name)then
        local F=fs.newFile(name)
        assert(F:open'r','open error')
        local s=F:read()F:close()
        local mode=
            args:sArg'-luaon'and'luaon'or
            args:sArg'-lua'and'lua'or
            args:sArg'-json'and'json'or
            args:sArg'-string'and'string'or
            s:sub(1,6)=='return{'and'luaon'or
            (s:sub(1,1)=='['and s:sub(-1)==']'or s:sub(1,1)=='{'and s:sub(-1)=='}')and'json'or
            'string'
        if mode=='luaon'then
            local func,err_mes=loadstring(s)
            if func then
                setfenv(func,{})
                local res=func()
                return assert(res,'decode error')
            else
                error('decode error: '..err_mes)
            end
        elseif mode=='lua'then
            local func,err_mes=loadstring(s)
            if func then
                local res=func()
                return assert(res,'run error')
            else
                error('compile error: '..err_mes)
            end
        elseif mode=='json'then
            local res=JSON.decode(s)
            if res then
                return res
            end
            error('decode error')
        elseif mode=='string'then
            return s
        else
            error('unknown mode')
        end
    else
        error('no file')
    end
end
function FILE.save(data,name,args)
    if not args then args=''end
    if args:sArg'-d'and fs.getInfo(name)then
        error('duplicate')
    end

    if type(data)=='table'then
        if args:sArg'-luaon'then
            data=TABLE.dump(data)
            if not data then
                error('encode error')
            end
        else
            data=JSON.encode(data)
            if not data then
                error('encode error')
            end
        end
    else
        data=tostring(data)
    end

    local F=fs.newFile(name)
    assert(F:open('w'),'open error')
    F:write(data)F:flush()F:close()
end
function FILE.clear(path)
    if fs.getRealDirectory(path)==SAVEDIR and fs.getInfo(path).type=='directory'then
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
end
function FILE.clear_s(path)
    if path==''or(fs.getRealDirectory(path)==SAVEDIR and fs.getInfo(path).type=='directory')then
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
end
return FILE
