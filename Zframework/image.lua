local IMG={}
function IMG.init(list)
	IMG.init=nil
	local count=0
	for k,v in next,list do
		count=count+1
		IMG[k]=v
	end
	function IMG.getCount()return count end

	IMG.loadOne=coroutine.wrap(function()
		IMG.loadAll=nil
		for k,v in next,list do
			IMG[k]=love.graphics.newImage("media/image/"..v)
			coroutine.yield()
		end
		IMG.loadOne=nil
	end)

	function IMG.loadAll()
		for i=1,count do
			IMG.loadOne(i)
		end
	end
end
return IMG