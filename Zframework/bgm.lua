local min=math.min

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

local BGM={
	--nowPlay=[str:playing ID]
	--playing=[src:playing SRC]
}
function BGM.set(L)
	BGM.list=L
	BGM.len=#L
end
function BGM.loadOne(N)
	N=BGM.list[N]
	local file="media/BGM/"..N..".ogg"
	if love.filesystem.getInfo(file)then
		BGM.list[N]=love.audio.newSource(file,"stream")
		BGM.list[N]:setLooping(true)
		BGM.list[N]:setVolume(0)
	else
		LOG.print("No BGM file: "..N,5,COLOR.orange)
	end
end
function BGM.loadAll()
	for i=1,#BGM.list do
		BGM.loadOne(i)
	end
end
function BGM.play(s)
	if SETTING.bgm==0 then
		BGM.nowPlay=s
		BGM.playing=BGM.list[s]
		return
	end
	if s and BGM.list[s]and BGM.nowPlay~=s then
		if BGM.nowPlay then TASK.new(fadeOut,BGM.playing)end
		TASK.removeTask_iterate(removeCurFadeOut,fadeOut,BGM.list[s])
		TASK.removeTask_code(fadeIn)

		TASK.new(fadeIn,BGM.list[s])
		BGM.nowPlay=s
		BGM.playing=BGM.list[s]
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
	if BGM.nowPlay then TASK.new(fadeOut,BGM.nowPlay)end
	BGM.nowPlay,BGM.playing=nil
end
return BGM