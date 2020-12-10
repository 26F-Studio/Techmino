local SFX={
	getCount=function()return 0 end,
	fieldPlay=NULL,
	play=NULL,
	fplay=NULL,
	reset=NULL,
	reload=NULL,
}
function SFX.init(list)
	SFX.init=nil
	local rem=table.remove
	local Sources={}

	local count=#list function SFX.getCount()return count end
	local function load(skip)
		for i=1,count do
			local N="media/SFX/"..list[i]..".ogg"
			if love.filesystem.getInfo(N)then
				Sources[list[i]]={love.audio.newSource(N,"static")}
			else
				LOG.print("No SFX file: "..N,5,COLOR.orange)
			end
			if not skip and i~=count then
				coroutine.yield()
			end
		end
		SFX.loadOne=nil

		function SFX.fieldPlay(s,v,P)
			SFX.play(s,v,(P.curX+P.sc[2]-5.5)*.15)
		end
		function SFX.play(s,vol,pos)
			if SETTING.sfx==0 then return end
			local S=Sources[s]--Source list
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
			local S=Sources[s]--Source list
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
			for _,L in next,Sources do
				if type(L)=="table"then
					for i=#L,1,-1 do
						if not L[i]:isPlaying()then
							rem(L,i)
						end
					end
				end
			end
		end
	end

	SFX.loadOne=coroutine.wrap(load)
	function SFX.loadAll()load(true)end
end
return SFX