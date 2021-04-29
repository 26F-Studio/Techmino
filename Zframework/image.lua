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
			if type(v)=='string'then
				IMG[k]=love.graphics.newImage("media/image/"..v)
			else
				for i=1,#v do
					v[i]=love.graphics.newImage("media/image/"..v[i])
				end
				IMG[k]=v
			end
			loaded=loaded+1
			if not skip and loaded~=count then
				coroutine.yield()
			end
		end
		IMG.loadOne=nil
		IMG.loadAll=nil
	end

	IMG.loadOne=coroutine.wrap(load)
	function IMG.loadAll()load(true)end
end
return IMG