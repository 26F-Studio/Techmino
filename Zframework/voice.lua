local VOC={
	getCount=function()return 0 end,
	getQueueCount=function()return 0 end,
	getFreeChannel=NULL,
	play=NULL,
	update=NULL,
	reload=NULL,
}
function VOC.init(list)
	VOC.init=nil
	local rnd=math.random
	local rem=table.remove
	local voiceQueue={free=0}
	local bank={}--{vocName1={SRC1s},vocName2={SRC2s},...}
	local Source={}

	local count=#list function VOC.getCount()return count end
	local function loadVoiceFile(N,vocName)
		local fileName="media/VOICE/"..SETTING.cv.."/"..vocName..".ogg"
		if love.filesystem.getInfo(fileName)then
			bank[vocName]={love.audio.newSource(fileName,"static")}
			table.insert(Source[N],vocName)
			return true
		end
	end
	local function getVoice(str)
		local L=bank[str]
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
		--Load voice with string
	end
	local function load(skip)
		for i=1,count do
			Source[list[i]]={}

			local n=0
			repeat n=n+1 until not loadVoiceFile(list[i],list[i].."_"..n)

			if n==1 then
				if not loadVoiceFile(list[i],list[i])then
					LOG.print("No VOICE file: "..list[i],5,COLOR.orange)
				end
			end
			if not Source[list[i]][1]then Source[list[i]]=nil end
			if not skip and i~=count then
				coroutine.yield()
			end
		end
		VOC.loadOne=nil

		function VOC.getQueueCount()
			return #voiceQueue
		end
		function VOC.getFreeChannel()
			local l=#voiceQueue
			for i=1,l do
				if #voiceQueue[i]==0 then return i end
			end
			voiceQueue[l+1]={s=0}
			return l+1
		end

		function VOC.play(s,chn)
			if SETTING.voc>0 then
				local _=Source[s]
				if not _ then return end
				if chn then
					local L=voiceQueue[chn]
					L[#L+1]=_[rnd(#_)]
					L.s=1
					--Add to queue[chn]
				else
					voiceQueue[VOC.getFreeChannel()]={s=1,_[rnd(#_)]}
					--Create new channel & play
				end
			end
		end
		function VOC.update()
			for i=#voiceQueue,1,-1 do
				local Q=voiceQueue[i]
				if Q.s==0 then--Free channel, auto delete when >3
					if i>3 then
						rem(voiceQueue,i)
					end
				elseif Q.s==1 then--Waiting load source
					Q[1]=getVoice(Q[1])
					Q[1]:setVolume(SETTING.voc)
					Q[1]:play()
					Q.s=Q[2]and 2 or 4
				elseif Q.s==2 then--Playing 1,ready 2
					if Q[1]:getDuration()-Q[1]:tell()<.08 then
						Q[2]=getVoice(Q[2])
						Q[2]:setVolume(SETTING.voc)
						Q[2]:play()
						Q.s=3
					end
				elseif Q.s==3 then--Playing 12 same time
					if not Q[1]:isPlaying()then
						for j=1,#Q do
							Q[j]=Q[j+1]
						end
						Q.s=Q[2]and 2 or 4
					end
				elseif Q.s==4 then--Playing last
					if not Q[1].isPlaying(Q[1])then
						Q[1]=nil
						Q.s=0
					end
				end
			end
		end
	end

	VOC.loadOne=coroutine.wrap(load)
	function VOC.loadAll()load(true)end
end
return VOC