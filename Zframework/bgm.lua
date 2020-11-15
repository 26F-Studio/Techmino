local min=math.min

local function fadeOut(id)
	local src=BGM.list[id]
	local v=src:getVolume()-.025*SETTING.bgm
	src:setVolume(v>0 and v or 0)
	if v<=0 then
		src:stop()
		return true
	end
end
local function fadeIn(id)
	local src=BGM.list[id]
	local v=SETTING.bgm
	v=min(v,src:getVolume()+.025*v)
	src:setVolume(v)
	if v>=SETTING.bgm then return true end
end

local BGM={
	--nowPlay=[str:playing ID]
	--suspend=[str:pausing ID]
	--playing=[src:playing SRC]
}
function BGM.set(L)
	BGM.list=L
	BGM.len=#L
end
function BGM.loadOne(N)
	N=BGM.list[N]
	local file="/BGM/"..N..".ogg"
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
		BGM.playing=BGM.list[s]
		BGM.suspend,BGM.nowPlay=s
		return
	elseif not(s and BGM.list[s])then
		return
	end
	if BGM.nowPlay~=s then
		if BGM.nowPlay then TASK.new(fadeOut,BGM.nowPlay)end
		TASK.changeCode(fadeIn,fadeOut)
		TASK.removeTask_data(s)

		BGM.nowPlay,BGM.suspend=s
		TASK.new(fadeIn,s)
		BGM.playing=BGM.list[s]
		BGM.playing:play()
	end
end
function BGM.freshVolume()
	if BGM.playing then
		local v=SETTING.bgm
		if v>0 then
			BGM.playing:setVolume(v)
			if BGM.suspend then
				BGM.playing:play()
				BGM.nowPlay,BGM.suspend=BGM.suspend
			end
		else
			if BGM.nowPlay then
				BGM.playing:pause()
				BGM.suspend,BGM.nowPlay=BGM.nowPlay
			end
		end
	end
end
function BGM.stop()
	if BGM.nowPlay then
		TASK.new(fadeOut,BGM.nowPlay)
	end
	TASK.changeCode(fadeIn,fadeOut)
	BGM.playing,BGM.nowPlay=nil
end
return BGM