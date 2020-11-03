--Bad Apple!! (128x96, 10fps, 2192f)
local gc=love.graphics
local int=math.floor
local back={}

local bAnd,bRshift=bit.band,bit.rshift
local t
local video
local X,Y,K
function back.init()
	if not video then
		video=love.data.decompress("string","zlib",love.filesystem.read("Zframework/badapple.dat"))
	end
	t=0
	BG.resize()
end
function back.resize()
	local W,H=SCR.w,SCR.h
	if H/W>=96/128 then
		K=W/128
		X,Y=0,(H-W*96/128)*.5
	else
		K=H/96
		X,Y=(W-H*128/96)*.5,0
	end
end
function back.update()
	t=t+1
	if t==13146 then
		t=0
	end
end
function back.draw()
	gc.clear(.2,.2,.2)
	gc.push("transform")
	gc.origin()
	gc.translate(X,Y)
	gc.scale(K)
	gc.setColor(.4,.4,.4)
	local t1=1536*int(t/6)+1
	for i=0,1535 do
		local B=video:byte(t1+i)
		for j=7,0,-1 do
			local p=8*i+j
			if bAnd(B,1)==0 then
				gc.rectangle("fill",p%128,int(p/128),1,1)
			end
			B=bRshift(B,1)
		end
	end
	gc.pop()
end
function back.discard()
	video=nil
end
return back