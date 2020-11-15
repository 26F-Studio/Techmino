local rem=table.remove

local SFX={}
function SFX.set(L)
	SFX.list=L
	SFX.len=#L
end
function SFX.loadOne(_)
	_,SFX.list[_]=SFX.list[_]
	local N="/SFX/".._..".ogg"
	if love.filesystem.getInfo(N)then
		SFX.list[_]={love.audio.newSource(N,"static")}
	else
		LOG.print("No SFX file: "..N,5,COLOR.orange)
	end
end
function SFX.loadAll()
	for i=1,#SFX.list do
		SFX.loadOne(i)
	end
end
function SFX.fieldPlay(s,v,P)
	SFX.play(s,v,(P.curX+P.sc[2]-5.5)*.15)
end
function SFX.play(s,vol,pos)
	if SETTING.sfx==0 then return end
	local S=SFX.list[s]--Source list
	if not S then return end
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
			pos=pos*SETTING.stereo
			S:setPosition(pos,1-pos^2,0)
		else
			S:setPosition(0,0,0)
		end
	end
	S:setVolume(((vol or 1)*SETTING.sfx)^1.626)
	S:play()
end
function SFX.fplay(s,vol,pos)
	local S=SFX.list[s]--Source list
	if not S then return end
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
			pos=pos*SETTING.stereo
			S:setPosition(pos,1-pos^2,0)
		else
			S:setPosition(0,0,0)
		end
	end
	S:setVolume(vol^1.626)
	S:play()
end
function SFX.reset()
	for _,L in next,SFX.list do
		if type(L)=="table"then
			for i=#L,1,-1 do
				if not L[i]:isPlaying()then
					rem(L,i)
				end
			end
		end
	end
end
return SFX