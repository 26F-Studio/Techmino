return function(name,libName)
	if SYSTEM=="Windows"or SYSTEM=="Linux"then
		local r1,r2,r3=pcall(require,libName[SYSTEM])
		if r1 and r2 then
			return r2
		else
			LOG.print("Cannot load "..name..": "..(r2 or r3),'warn')
		end
	elseif SYSTEM=="Android"then
		local fs=love.filesystem
		local platform={'arm64-v8a','armeabi-v7a'}

		for i=1,#platform do
			local soFile,_,_,mes1=fs.read('data',"libAndroid/"..platform[i].."/"..libName.Android)
			if soFile then
				local success,mes2=fs.write("lib/"..libName.Android,soFile)
				if success then
					libFunc,mes2=package.loadlib(SAVEDIR.."/lib/"..libName.Android,libName.libFunc)
					if libFunc then
						LOG.print(name.." lib loaded",'message')
						break
					else
						LOG.print("Cannot load "..name..": "..mes2,'error')
					end
				else
					LOG.print(("Write %s-%s to saving failed: %s"):format(name,platform[i],mes2),'error')
				end
			else
				LOG.print(("Read %s-%s to saving failed: %s"):format(name,platform[i],mes1),'error')
			end
		end
		if not libFunc then
			LOG.print("Cannot load "..name,'error')
			return
		end
		return libFunc()
	else
		LOG.print("No "..name.." for "..SYSTEM,'error')
		return
	end
	return true
end