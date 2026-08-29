local ccDir
if SYSTEM=='Linux' then
    ccDir='ColdClear/Linux'
elseif SYSTEM=='Windows' then
    local arch=jit and jit.arch or 'x64'
    ccDir='ColdClear/Windows/'..(arch=='x64' and 'x64' or 'x86')
end
package.cpath=package.cpath
    ..';'..love.filesystem.getSaveDirectory()..'/lib/?.so'
    ..';?.dylib'
    ..(ccDir and ';'..ccDir..'/?.'..(SYSTEM=='Windows' and 'dll' or 'so') or '')
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
        local a,b,c=package.loadlib(libName..'.dylib','luaopen_'..libName)
        require=a

        if require then
            success,res=pcall(require)
        else
            success,res=false,'package.loadlib returned nil, along with:\n[2]:\n'..b..'[3]:\n'..c
        end
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
            local data=love.filesystem.read('data','ColdClear/Android/'..platform..'/'..libName..'.so')
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
            MES.new('error',("Cannot load %s (x%d)"):format(libName,errorCount[libName]),1)
        end
    end
end
