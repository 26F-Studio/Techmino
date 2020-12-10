local BGM={
	getList={},
	getCount=function()return 0 end,
	play=NULL,
	freshVolume=NULL,
	stop=NULL,
	reload=NULL,
	--nowPlay=[str:playing ID]
	--playing=[src:playing SRC]
}
function BGM.init(list)
	BGM.init=nil
	local min=math.min
	local Sources={}function BGM.getList()return list end

	local count=#list function BGM.getCount()return count end
	local function fadeOut(src)
		while true do
			coroutine.yield()
			local v=src:getVolume()-.025*SETTING.bgm
			src:setVolume(v>0 and v or 0)
			if v<=0 then
				src:stop()
				return true
			end
		end
	end
	local function fadeIn(src)
		while true do
			coroutine.yield()
			local v=SETTING.bgm
			v=min(v,src:getVolume()+.025*v)
			src:setVolume(v)
			if v>=SETTING.bgm then
				return true
			end
		end
	end
	local function removeCurFadeOut(task,code,src)
		return task.code==code and task.args[1]==src
	end
	local function load(skip)
		for i=1,count do
			local file="media/BGM/"..list[i]..".ogg"
			if love.filesystem.getInfo(file)then
				Sources[list[i]]=love.audio.newSource(file,"stream")
				Sources[list[i]]:setLooping(true)
				Sources[list[i]]:setVolume(0)
			else
				LOG.print("No BGM file: "..list[i],5,COLOR.orange)
			end
			if not skip and i~=count then
				coroutine.yield()
			end
		end
		BGM.loadOne=nil

		function BGM.play(s)
			if SETTING.bgm==0 then
				BGM.nowPlay=s
				BGM.playing=Sources[s]
				return
			end
			if s and Sources[s]and BGM.nowPlay~=s then
				if BGM.nowPlay then TASK.new(fadeOut,BGM.playing)end
				TASK.removeTask_iterate(removeCurFadeOut,fadeOut,Sources[s])
				TASK.removeTask_code(fadeIn)

				TASK.new(fadeIn,Sources[s])
				BGM.nowPlay=s
				BGM.playing=Sources[s]
				BGM.playing:play()
			end
		end
		function BGM.freshVolume()
			if BGM.playing then
				local v=SETTING.bgm
				if v>0 then
					BGM.playing:setVolume(v)
					BGM.playing:play()
				elseif BGM.nowPlay then
					BGM.playing:pause()
				end
			end
		end
		function BGM.stop()
			TASK.removeTask_code(fadeIn)
			if BGM.nowPlay then TASK.new(fadeOut,BGM.playing)end
			BGM.nowPlay,BGM.playing=nil
		end
	end

	BGM.loadOne=coroutine.wrap(load)
	function BGM.loadAll()load(true)end
end
return BGM