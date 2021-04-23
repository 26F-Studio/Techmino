return function(name,libName)
	if SYSTEM=="Windows"or SYSTEM=="Linux"then
		local r1,r2,r3=pcall(require,libName[SYSTEM])
		if r1 and r2 then
			return r2
		else
			LOG.print("Cannot load "..name..": "..(r2 or r3),"warn",COLOR.R)
		end
	elseif SYSTEM=="Android"then
		local fs=love.filesystem
		local platform={"arm64-v8a","armeabi-v7a"}

		local libFunc=package.loadlib(SAVEDIR.."/lib/"..libName.Android,libName.libFunc)
		if libFunc then
			LOG.print(name.." lib loaded","warn",COLOR.G)
		else
			for i=1,#platform do
				local soFile=fs.read("data","libAndroid/"..platform[i].."/"..libName.Android)
				if soFile then
					local success,message=fs.write("lib/"..libName.Android,soFile)
					if success then
						libFunc,message=package.loadlib(SAVEDIR.."/lib/"..libName.Android,libName.libFunc)
						if libFunc then
							LOG.print(name.." lib loaded","warn",COLOR.G)
							break
						else
							LOG.print("Cannot load "..name..": "..message,"warn",COLOR.R)
						end
					else
						LOG.print("Write "..name.."-"..platform[i].." to saving failed: "..message,"warn",COLOR.R)
					end
				else
					LOG.print("Read "..name.."-"..platform[i].." failed","warn",COLOR.R)
				end
			end
			if not libFunc then
				LOG.print("Cannot load "..name,"warn",COLOR.R)
				return
			end
		end
		return libFunc()
	else
		LOG.print("No "..name.." for "..SYSTEM,"warn",COLOR.R)
		return
	end
	return true
end