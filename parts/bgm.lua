local rem=table.remove

local BGM={}
BGM.nowPlay=nil
BGM.playing=nil--last loaded source
BGM.playingID=nil--last loaded ID
BGM.list={
	"blank",
	"way",
	"race",
	"newera",
	"push",
	"reason",
	"infinite",
	"cruelty",
	"final",
	"secret7th",
	"secret8th",
	"rockblock",
	"8-bit happiness",
	"shining terminal",
	"oxygen",
	"distortion",
	"end",
}
function BGM.loadOne(_)
	_,BGM.list[_]=BGM.list[_]
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
	if setting.bgm==0 or not s then return end
	if BGM.nowPlay~=s then
		if BGM.nowPlay then newTask(Event_task.bgmFadeOut,nil,BGM.nowPlay)end
		for i=#Task,1,-1 do
			local T=Task[i]
			if T.code==Event_task.bgmFadeIn then
				T.code=Event_task.bgmFadeOut
			elseif T.code==Event_task.bgmFadeOut and T.data==s then
				rem(Task,i)
			end
		end
		if s then
			BGM.playingID=s
		end
		BGM.nowPlay=s
		newTask(Event_task.bgmFadeIn,nil,s)
		BGM.playing=BGM.list[s]
		BGM.playing:play()
	end
end
function BGM.freshVolume()
	if BGM.playing then
		local v=setting.bgm*.1
		if v>0 then
			BGM.playing:setVolume(v)
			if not BGM.nowPlay then
				BGM.playing:play()
				BGM.nowPlay=BGM.playingID
			end
		else
			BGM.playing:pause()
			BGM.playing:setVolume(0)
			BGM.nowPlay=nil
		end
	end
end
function BGM.stop()
	if BGM.nowPlay then
		for i=1,#Task do
			local T=Task[i]
			if T.code==Event_task.bgmFadeIn and T.data==BGM.nowPlay then
				T.code=Event_task.bgmFadeOut
				goto L
			end
		end
		BGM.list[BGM.nowPlay]:stop()
		::L::
		BGM.nowPlay=nil
	end
end
return BGM