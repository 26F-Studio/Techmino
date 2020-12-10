local IMG={
	getCount=function()return 0 end,
}
function IMG.init(list)
	IMG.init=nil
	local count=0
	for k,v in next,list do
		count=count+1
		IMG[k]=v
	end
	function IMG.getCount()return count end
	local function load(skip)
		for k,v in next,list do
			IMG[k]=love.graphics.newImage("media/image/"..v)
			if not skip and i~=count then
				coroutine.yield()
			end
		end
		IMG.loadOne=nil
	end

	IMG.loadOne=coroutine.wrap(load)
	function IMG.loadAll()load(true)end
end
return IMG