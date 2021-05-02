local floatWheel=0
return function(y,key1,key2)
	if y>0 then
		if floatWheel<0 then floatWheel=0 end
		floatWheel=floatWheel+y^1.2
	elseif y<0 then
		if floatWheel>0 then floatWheel=0 end
		floatWheel=floatWheel-(-y)^1.2
	end
	while floatWheel>=1 do
		love.keypressed(key1 or"up")
		floatWheel=floatWheel-1
	end
	while floatWheel<=-1 do
		love.keypressed(key2 or"down")
		floatWheel=floatWheel+1
	end
end