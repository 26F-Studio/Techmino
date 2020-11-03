local gc=love.graphics
local int=math.floor
local function C(x,y)
	local _=gc.newCanvas(x,y)
	gc.setCanvas(_)
	return _
end
local TEXTURE={}

gc.setDefaultFilter("nearest","nearest")
gc.setColor(1,1,1)
local VKI=gc.newImage("/image/virtualkey.png")
TEXTURE.VKIcon={}
for i=1,20 do
	TEXTURE.VKIcon[i]=C(36,36)
	gc.draw(VKI,(i-1)%5*-36,int((i-1)*.2)*-36)
end

TEXTURE.miniBlock={}
for i=1,25 do
	local b=BLOCKS[i][0]
	TEXTURE.miniBlock[i]=C(#b[1],#b)
	for y=1,#b do for x=1,#b[1]do
		if b[y][x]then
			gc.rectangle("fill",x-1,#b-y,1,1)
		end
	end end
end

TEXTURE.mapCross=C(40,40)
gc.setColor(1,1,1)
gc.setLineWidth(4)
gc.line(0,20,40,20)
gc.line(20,0,20,40)

gc.setDefaultFilter("linear","linear")
gc.setCanvas()
return TEXTURE