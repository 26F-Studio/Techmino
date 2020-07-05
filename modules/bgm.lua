local min=math.min
local rem=table.remove

local function fadeOut(_,id)
	local src=BGM.list[id]
	local v=src:getVolume()-.025*setting.bgm*.1
	src:setVolume(v>0 and v or 0)
	if v<=0 then
		src:stop()
		return true
	end
end
local function fadeIn(_,id)
	local src=BGM.list[id]
	local v=min(src:getVolume()+.025*setting.bgm*.1,setting.bgm*.1)
	src:setVolume(v)
	if v>=setting.bgm*.1 then return true end
end

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
	"hay what kind of feeling",
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
		if BGM.nowPlay then TASK.new(fadeOut,nil,BGM.nowPlay)end
		TASK.changeCode(fadeIn,fadeOut)
		TASK.removeTask_data(s)

		BGM.nowPlay,BGM.suspend=s
		TASK.new(fadeIn,nil,s)
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
		TASK.new(fadeOut,nil,BGM.nowPlay)
	end
	TASK.changeCode(fadeIn,fadeOut)
	BGM.playing,BGM.nowPlay=nil
end
return BGM