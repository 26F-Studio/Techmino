package.cpath=package.cpath..';'..SAVEDIR..'/lib/lib?.so;'..'?.dylib'
local loaded={}
return function(libName)
    local require=require
    if love.system.getOS()=='OS X'then
        require=package.loadlib(libName..'.dylib','luaopen_'..libName)
        libname=nil
    elseif love.system.getOS()=='Android'then
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
    local success,res=pcall(require,libName)
    if success and res then
        return res
    else
        MES.new('error',"Cannot load "..libName..": "..res)
    end
end
