local rnd=math.random
local rem=table.remove
local voiceQueue={free=0}
local VOC={}

local function getVoice(str)
	local L=voiceBank[str]
	local n=1
	while L[n]:isPlaying()do
		n=n+1
		if not L[n]then
			L[n]=L[1]:clone()
			L[n]:seek(0)
			break
		end
	end
	return L[n]
	--load voice with string
end
function VOC.getFreeChannel()
	local i=#voiceQueue
	for i=1,i do
		if #voiceQueue[i]==0 then return i end
	end
	voiceQueue[i+1]={s=0}
	return i+1
end
function VOC.getCount()
	return #voiceQueue
end
function VOC.update()
	for i=#voiceQueue,1,-1 do
		local Q=voiceQueue[i]
		if Q.s==0 then--闲置轨，自动删除多余
			if i>3 then
				rem(voiceQueue,i)
			end
		elseif Q.s==1 then--等待转换
			Q[1]=getVoice(Q[1])
			Q[1]:setVolume(setting.voc*.1)
			Q[1]:play()
			Q.s=Q[2]and 2 or 4
		elseif Q.s==2 then--播放1,准备2
			if Q[1]:getDuration()-Q[1]:tell()<.08 then
				Q[2]=getVoice(Q[2])
				Q[2]:setVolume(setting.voc*.1)
				Q[2]:play()
				Q.s=3
			end
		elseif Q.s==3 then--12同时播放
			if not Q[1]:isPlaying()then
				for i=1,#Q do
					Q[i]=Q[i+1]
				end
				Q.s=Q[2]and 2 or 4
			end
		elseif Q.s==4 then--最后播放
			if not Q[1].isPlaying(Q[1])then
				Q[1]=nil
				Q.s=0
			end
		end
	end
end
function VOC.play(s,chn)
	if setting.voc>0 then
		if chn then
			local L=voiceQueue[chn]
			local _=voiceList[s]
			L[#L+1]=_[rnd(#_)]
			L.s=1
			--添加到queue[chn]
		else
			voiceQueue[VOC.getFreeChannel()]={s=1,voiceList[s][rnd(#voiceList[s])]}
			--自动创建空轨/播放
		end
	end
end
return VOC