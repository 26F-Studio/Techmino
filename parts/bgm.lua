local rem=table.remove

local BGM={
	--nowPlay=[str:playing ID]
	--suspend=[str:pausing ID]
	--playing=[src:playing SRC]
}
BGM.list={
	"blank","way","race","newera","push","reason","infinite",
	"secret7th","secret8th",
	"shining terminal","oxygen","distortion","far",
	"rockblock","cruelty","final","8-bit happiness","end",
}
BGM.len=#BGM.list
function BGM.loadOne(N)
	N=BGM.list[N]
	local file="/BGM/"..N..".ogg"
	if love.filesystem.getInfo(file)then
		BGM.list[N]=love.audio.newSource(file,"stream")
		BGM.list[N]:setLooping(true)
		BGM.list[N]:setVolume(0)
	end
end
function BGM.loadAll()
	for i=1,#BGM.list do
		BGM.loadOne(i)
	end
end
function BGM.play(s)
	if setting.bgm==0 then
		BGM.playing=BGM.list[s]
		BGM.suspend,BGM.nowPlay=s
		return
	elseif not s or not BGM.list[s]then
		return
	end
	if BGM.nowPlay~=s then
		if BGM.nowPlay then TASK.new(tickEvent.bgmFadeOut,nil,BGM.nowPlay)end
		TASK.changeCode(tickEvent.bgmFadeIn,tickEvent.bgmFadeOut)
		TASK.removeTask_data(s)

		BGM.nowPlay,BGM.suspend=s
		TASK.new(tickEvent.bgmFadeIn,nil,s)
		BGM.playing=BGM.list[s]
		BGM.playing:play()
	end
end
function BGM.freshVolume()
	if BGM.playing then
		local v=setting.bgm*.1
		if v>0 then
			BGM.playing:setVolume(v)
			if BGM.suspend then
				BGM.playing:play()
				BGM.nowPlay,BGM.suspend=BGM.suspend
			end
		else
			BGM.playing:setVolume(0)
			BGM.playing:pause()
			BGM.suspend,BGM.nowPlay=BGM.nowPlay
		end
	end
end
function BGM.stop()
	if BGM.nowPlay then
		TASK.new(tickEvent.bgmFadeOut,nil,BGM.nowPlay)
	end
	TASK.changeCode(tickEvent.bgmFadeIn,tickEvent.bgmFadeOut)
	BGM.playing,BGM.nowPlay=nil
end
return BGM