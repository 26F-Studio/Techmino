local rem=table.remove

local SFX={}
SFX.list={
	"welcome_sfx",
	"click","enter",
	"finesseError","finesseError_long",
	--Stereo sfxs(cannot set position)

	"virtualKey",
	"button","swipe",
	"ready","start","win","fail","collect",
	"move","rotate","rotatekick","hold",
	"prerotate","prehold",
	"lock","drop","fall",
	"reach",
	"ren_1","ren_2","ren_3","ren_4","ren_5","ren_6","ren_7","ren_8","ren_9","ren_10","ren_11","ren_mega",
	"clear_1","clear_2","clear_3","clear_4",
	"spin_0","spin_1","spin_2","spin_3",
	"emit","blip_1","blip_2",
	"clear",

	"error",
	--Mono sfxs
}
function SFX.loadOne(_)
	_,SFX.list[_]=SFX.list[_]
	SFX.list[_]={love.audio.newSource("/SFX/".._..".ogg","static")}
end
function SFX.loadAll()
	for i=1,#SFX.list do
		SFX.loadOne(i)
	end
end
function SFX.fieldPlay(s,v,P)
	SFX.play(s,v,(P.curX+P.sc[2]-6.5)*.15)
end
function SFX.play(s,v,pos)
	if setting.sfx==0 then return end
	local S=SFX.list[s]--source list
	local n=1
	while S[n]:isPlaying()do
		n=n+1
		if not S[n]then
			S[n]=S[1]:clone()
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
function SFX.reset()
	for _,L in next,sfx do
		for i=#v,2,-1 do
			if not L[i]:isPlaying()then
				rem(L,i)
			end
		end
	end
end
return SFX