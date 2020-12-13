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
		local loaded=0
		for k,v in next,list do
			IMG[k]=love.graphics.newImage("media/image/"..v)
			loaded=loaded+1
			if not skip and loaded~=count then
				coroutine.yield()
			end
		end
		IMG.loadOne=nil
	end

	IMG.loadOne=coroutine.wrap(load)
	function IMG.loadAll()load(true)end
end
return IMG