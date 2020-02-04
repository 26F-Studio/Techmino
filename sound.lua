local rnd=math.random
local rem=table.remove
local vibrateLevel={0,.015,.02,.03,.04,.05,.06,.07,.08,.09}
function VIB(t)
	if setting.vib>0 then
		love.system.vibrate(vibrateLevel[setting.vib+t])
	end
end
function SFX(s,v,pos)
	if setting.sfx>0 then
		local S=sfx[s]--AU_Queue
		local n=1
		while S[n]:isPlaying()do
			n=n+1
			if not S[n]then
				S[n]=S[n-1]:clone()
				S[n]:seek(0)
				break
			end
		end
		S=S[n]--AU_SRC
		if S:getChannelCount()==1 then
			if pos then
				pos=pos*setting.stereo*.1
				S:setPosition(pos,1-pos^2,0)
			else
				S:setPosition(0,0,0)
			end
		end
		S:setVolume((v or 1)*setting.sfx*.1)
		S:play()
	end
end
function getFreeVoiceChannel()
	local i=#voiceQueue
	for i=1,i do
		if #voiceQueue[i]==0 then return i end
	end
	voiceQueue[i+1]={}
	return i+1
end
function VOICE(s,chn)
	if setting.voc>0 then
		if chn then
			voiceQueue[chn][#voiceQueue[chn]+1]=voiceList[s][rnd(#voiceList[s])]
			--添加到[chn]
		else
			voiceQueue[getFreeVoiceChannel()]={voiceList[s][rnd(#voiceList[s])]}
			--自动查找/创建空轨
		end
	end
end
function BGM(s)
	if setting.bgm>0 then
		if bgmPlaying~=s then
			if bgmPlaying then newTask(Event_task.bgmFadeOut,nil,bgmPlaying)end
			for i=#Task,1,-1 do
				local T=Task[i]
				if T.code==Event_task.bgmFadeIn then
					T.code=Event_task.bgmFadeOut
				elseif T.code==Event_task.bgmFadeOut and T.data==s then
					rem(Task,i)
				end
			end
			if s then
				newTask(Event_task.bgmFadeIn,nil,s)
				bgm[s]:play()
			end
			bgmPlaying=s
		else
			if bgmPlaying then
				local v=setting.bgm*.1
				bgm[bgmPlaying]:setVolume(v)
				if v>0 then
					bgm[bgmPlaying]:play()
				else
					bgm[bgmPlaying]:pause()
				end
			end
		end
	elseif bgmPlaying then
		bgm[bgmPlaying]:pause()
		bgmPlaying=nil
	end
end