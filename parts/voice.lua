local rnd=math.random

function getVoice(str)
	local L=voiceBank[str]
	local n=1
	while L[n]:isPlaying()do
		n=n+1
		if not L[n]then
			L[n]=L[n-1]:clone()
			L[n]:seek(0)
			break
		end
	end
	return L[n]
	--load voice with string
end
function getFreeVoiceChannel()
	local i=#voiceQueue
	for i=1,i do
		if #voiceQueue[i]==0 then return i end
	end
	voiceQueue[i+1]={s=0}
	return i+1
end
function VOICE(s,chn)
	if setting.voc>0 then
		if chn then
			local L=voiceQueue[chn]
			local _=voiceList[s]
			L[#L+1]=_[rnd(#_)]
			L.s=1
			--添加到queue[chn]
		else
			voiceQueue[getFreeVoiceChannel()]={s=1,voiceList[s][rnd(#voiceList[s])]}
			--自动创建空轨/播放
		end
	end
end