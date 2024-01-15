package.cpath=package.cpath..';'..love.filesystem.getSaveDirectory()..'/lib/?.so;'..'?.dylib'
local loaded={}
local errorCount={}
return function(libName)
    local require=require
    local arch='unknown'
    local success,res
    if SYSTEM=='Web' then
        return
    end
    if SYSTEM=='macOS' then
        require=package.loadlib(libName..'.dylib','luaopen_'..libName)
        success,res=pcall(require)
    else
        if SYSTEM=='Android' and not loaded[libName] then
            local platform=(function()
                local p=io.popen('uname -m')
                arch=p:read('*a'):lower()
                p:close()
                if arch:find('v8') and not arch:find('v8l') or arch:find('64') then
                    return 'arm64-v8a'
                else
                    return 'armeabi-v7a'
                end
            end)()
            local data=love.filesystem.read('data','libAndroid/'..platform..'/'..libName..'.so')
            if data then
                love.filesystem.write('lib/'..libName..'.so',data)
            end
            loaded[libName]=true
        end
        success,res=pcall(require,libName)
    end
    if success and res then
        return res
    else
        if not next(errorCount) then
            MES.new('info',"Architecture: "..arch)
        end
        errorCount[libName]=(errorCount[libName] or 0)+1
        if errorCount[libName]==1 then
            MES.new('error',"Cannot load "..libName..": "..tostring(res):gsub('[\128-\255]+','??'))
        else
            MES.new('error',("Cannot load %s (x%d)"):format(libName,errorCount[libName]))
        end
    end
end
