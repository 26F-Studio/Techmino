return function(name,libName)
	if SYSTEM=='Android'then
		local fs=love.filesystem
		local platform=(function()
			local p=io.popen('uname -m')
			local arch=p:read('*a'):lower()
			p:close()
			if arch=='aarch64'or arch=='arm64'then
				return'arm64-v8a'
			else
				return'armeabi-v7a'
			end
		end)()
		fs.write('lib/libCCloader.so',fs.read('data','libAndroid/'..platform..'/libCCloader.so'))
		package.cpath=SAVEDIR..'/lib/lib?.so;'..package.cpath
	elseif SYSTEM=='OS X' then
		package.cpath='?.dylib;'..package.cpath
	end
	local r1,r2,r3=pcall(require,'CCloader')
	if r1 and r2 then
		return r2
	else
		MES.new('error',"Cannot load "..name..": "..(r2 or r3))
	end
end