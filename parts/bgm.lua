local rem=table.remove

local BGM={}
-- BGM.nowPlay=[str:playing ID]
-- BGM.suspend=[str:pausing ID]
-- BGM.playing=[src:playing SRC]
BGM.list={
	"blank","way","race","newera","push",
	"reason","infinite","secret7th","secret8th",
	"shining terminal","oxygen","distortion",
	"rockblock","cruelty","final","8-bit happiness","end",
}
BGM.len=#BGM.list
function BGM.loadOne(_)
	local _=BGM.list[_]
	BGM.list[_]=love.audio.newSource("/BGM/".._..".ogg","stream")
	BGM.list[_]:setLooping(true)
	BGM.list[_]:setVolume(0)
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
	elseif not s then
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