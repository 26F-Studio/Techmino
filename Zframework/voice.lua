local rnd=math.random
local rem=table.remove
local voiceQueue={free=0}
local bank={}--{vocName1={SRC1s},vocName2={SRC2s},...}
local VOC={}
VOC.name={
	"zspin","sspin","lspin","jspin","tspin","ospin","ispin",
	"single","double","triple","techrash",
	"mini","b2b","b3b",
	"perfect_clear","half_clear",
	"win","lose","bye",
	"test","happy","doubt","sad","egg",
	"welcome_voc"
}
VOC.list={}

local function loadVoiceFile(N,vocName)
	local fileName="VOICE/"..vocName..".ogg"
	if love.filesystem.getInfo(fileName)then
		bank[vocName]={love.audio.newSource(fileName,"static")}
		table.insert(VOC.list[N],vocName)
		return true
	end
end
function VOC.loadOne(_)
	local N=VOC.name[_]
	VOC.list[N]={}
	local i=1
	while true do
		if not loadVoiceFile(N,N.."_"..i)then
			break
		end
		i=i+1
	end
	if i==1 then
		if not loadVoiceFile(N,N)then
			LOG.print("No VOICE file: "..N,5,color.orange)
		end
	end
	if not VOC.list[N][1]then VOC.list[N]=nil end
end
function VOC.loadAll()
	for i=1,#VOC.name do
		VOC.loadOne(i)
	end
end

function VOC.getFreeChannel()
	local l=#voiceQueue
	for i=1,l do
		if #voiceQueue[i]==0 then return i end
	end
	voiceQueue[l+1]={s=0}
	return l+1
end
function VOC.getCount()
	return #voiceQueue
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
function VOC.play(s,chn)
	if SETTING.voc>0 then
		local _=VOC.list[s]
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
return VOC