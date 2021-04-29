--Large falling tetrominoes
local gc=love.graphics
local rnd=math.random
local ins,rem=table.insert,table.remove
local back={}

local t
local mino
function back.init()
	t=0
	mino={}
end
function back.update()
	t=t+1
	if t%26==0 then
		local r=rnd(7)
		local B=BLOCKS[r][rnd(0,3)]
		local k=(1+rnd()*2)*SCR.rad/1000
		ins(mino,{
			x=(SCR.w)*rnd()-15*#B[1],
			y=0,
			k=k,
			vy=k*2,
			block=B,
			texture=SKIN.curText[SETTING.skin[r]],
		})
	end
	for i=#mino,1,-1 do
		local M=mino[i]
		M.y=M.y+M.vy
		if M.y-M.k*#M.block*30>SCR.h then rem(mino,i)end
	end
end
function back.draw()
	gc.clear(.15,.15,.15)
	gc.push('transform')
	gc.origin()
	gc.setColor(1,1,1,.4)
	for i=1,#mino do
		local M=mino[i]
		local b=M.block
		for y=1,#b do
			for x=1,#b[1]do
				if b[y][x]then
					gc.draw(M.texture,M.x+(x-1)*30*M.k,M.y-y*30*M.k,nil,M.k)
				end
			end
		end
	end
	gc.pop()
end
function back.discard()
	mino=nil
end
return back