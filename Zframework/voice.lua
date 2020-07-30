local rnd=math.random
local rem=table.remove
local voiceQueue={free=0}
local bank={}--{{SRC1s},{SRC2s},...}
local VOC={}
VOC.name={
	"zspin","sspin","lspin","jspin","tspin","ospin","ispin",
	"single","double","triple","techrash",
	"mini","b2b","b3b","pc",
	"win","lose",
	"bye",
	"nya",
	"happy",
	"doubt",
	"sad",
	"egg",
	"welcome"
}
VOC.list={
	zspin={"zspin_1","zspin_2","zspin_3"},
	sspin={"sspin_1","sspin_2","sspin_3","sspin_4","sspin_5","sspin_6"},
	lspin={"lspin_1","lspin_2"},
	jspin={"jspin_1","jspin_2","jspin_3","jspin_4"},
	tspin={"tspin_1","tspin_2","tspin_3","tspin_4","tspin_5","tspin_6"},
	ospin={"ospin_1","ospin_2","ospin_3"},
	ispin={"ispin_1","ispin_2","ispin_3"},

	single={"single_1","single_2","single_3","single_4","single_5","single_6","single_7"},
	double={"double_1","double_2","double_3","double_4","double_5"},
	triple={"triple_1","triple_2","triple_3","triple_4","triple_5","triple_6","triple_7"},
	techrash={"techrash_1","techrash_2","techrash_3","techrash_4"},

	mini={"mini_1","mini_2","mini_3"},
	b2b={"b2b_1","b2b_2","b2b_3"},
	b3b={"b3b_1","b3b_2"},
	pc={"clear_1","clear_2"},
	win={"win_1","win_2","win_3","win_4","win_5","win_6","win_6","win_7"},
	lose={"lose_1","lose_2","lose_3"},
	bye={"bye_1","bye_2"},
	nya={"nya_1","nya_2","nya_3","nya_4"},
	happy={"nya_happy_1","nya_happy_2","nya_happy_3","nya_happy_4"},
	doubt={"nya_doubt_1","nya_doubt_2"},
	sad={"nya_sad_1"},
	egg={"egg_1","egg_2"},
	welcome={"welcome_voc"},
}

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
function VOC.loadOne(_)
	local N=VOC.name[_]
	for i=1,#VOC.list[N]do
		local V=VOC.list[N][i]
		bank[V]={love.audio.newSource("VOICE/"..V..".ogg","static")}
	end
end
function VOC.loadAll()
	for i=1,#VOC.list do
		VOC.loadOne(i)
	end
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
		if Q.s==0 then--Free channel, auto delete when >3
			if i>3 then
				rem(voiceQueue,i)
			end
		elseif Q.s==1 then--Waiting load source
			Q[1]=getVoice(Q[1])
			Q[1]:setVolume(setting.voc*.1)
			Q[1]:play()
			Q.s=Q[2]and 2 or 4
		elseif Q.s==2 then--Playing 1,ready 2
			if Q[1]:getDuration()-Q[1]:tell()<.08 then
				Q[2]=getVoice(Q[2])
				Q[2]:setVolume(setting.voc*.1)
				Q[2]:play()
				Q.s=3
			end
		elseif Q.s==3 then--Playing 12 same time
			if not Q[1]:isPlaying()then
				for i=1,#Q do
					Q[i]=Q[i+1]
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
	if setting.voc>0 then
		if chn then
			local L=voiceQueue[chn]
			local _=VOC.list[s]
			if not _ then print("no VOC called:"..s)return end
			L[#L+1]=_[rnd(#_)]
			L.s=1
			--Add to queue[chn]
		else
			voiceQueue[VOC.getFreeChannel()]={s=1,VOC.list[s][rnd(#VOC.list[s])]}
			--Create new channel & play
		end
	end
end
return VOC