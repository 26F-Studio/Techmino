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
local VKI=gc.newImage("media/image/virtualkey.png")
TEXTURE.VKIcon={}
for i=1,20 do
	TEXTURE.VKIcon[i]=C(36,36)
	gc.draw(VKI,(i-1)%5*-36,int((i-1)*.2)*-36)
end

TEXTURE.miniBlock={}
for i=1,29 do
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


local titleTriangles={}
for i=1,8 do titleTriangles[i]=love.math.triangulate(title[i])end

--Middle: 580,118
TEXTURE.title=C(1160,236)
for i=1,8 do
	gc.translate(12*i,i==1 and 8 or 14)

	gc.setLineWidth(16)
	gc.setColor(1,1,1)
	gc.polygon("line",title[i])

	gc.setColor(0,0,0)
	for j=1,#titleTriangles[i]do
		gc.polygon("fill",titleTriangles[i][j])
	end

	gc.translate(-12*i,i==1 and -8 or -14)
end
TEXTURE.title_color=C(1160,236)
local titleColor={
	COLOR.lGrape,
	COLOR.lCyan,
	COLOR.lBlue,
	COLOR.lOrange,
	COLOR.lFire,
	COLOR.lMagenta,
	COLOR.lGreen,
	COLOR.lYellow,
}
for i=1,8 do
	gc.translate(12*i,i==1 and 8 or 14)

	gc.setLineWidth(16)
	gc.setColor(1,1,1)
	gc.polygon("line",title[i])

	gc.setLineWidth(4)
	gc.setColor(0,0,0)
	for j=1,#titleTriangles[i]do
		gc.polygon("fill",titleTriangles[i][j])
	end

	gc.setColor(titleColor[i])
	gc.translate(-4,-4)
	for j=1,#titleTriangles[i]do
		gc.polygon("fill",titleTriangles[i][j])
	end
	gc.translate(4,4)

	gc.translate(-12*i,i==1 and -8 or -14)
end


gc.setCanvas()
return TEXTURE