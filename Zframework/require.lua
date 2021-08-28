package.cpath=package.cpath..';'..SAVEDIR..'/lib/lib?.so;'..'?.dylib'
local loaded={}
return function(libName)
    if SYSTEM=='Android'then
        if not loaded[libName]then
            local platform=(function()
                local p=io.popen('uname -m')
                local arch=p:read('*a'):lower()
                p:close()
                if arch:find('v8')or arch:find('64')then
                    return'arm64-v8a'
                else
                    return'armeabi-v7a'
                end
            end)()
            love.filesystem.write(
                'lib/libCCloader.so',
                love.filesystem.read('data','libAndroid/'..platform..'/libCCloader.so')
            )
            loaded[libName]=true
        end
    end
    local r1,r2,r3=pcall(require,libName)
    if r1 and r2 then
        return r2
    else
        MES.new('error',"Cannot load "..libName..": "..(r2 or r3))
    end
end
