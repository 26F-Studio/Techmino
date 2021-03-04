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

TEXTURE.puzzleMark={}
gc.setLineWidth(3)
for i=1,17 do
	TEXTURE.puzzleMark[i]=C(30,30)
	local _=SKIN.libColor[i]
	gc.setColor(_[1],_[2],_[3],.6)
	gc.rectangle("line",5,5,20,20)
	gc.rectangle("line",10,10,10,10)
end
for i=18,24 do
	TEXTURE.puzzleMark[i]=C(30,30)
	gc.setColor(SKIN.libColor[i])
	gc.rectangle("line",7,7,16,16)
end
local _=C(30,30)
gc.setColor(1,1,1)
gc.line(5,5,25,25)
gc.line(5,25,25,5)
TEXTURE.puzzleMark[-1]=C(30,30)
gc.setColor(1,1,1,.8)
gc.draw(_)
_:release()
gc.setCanvas()

TEXTURE.mapCross=C(40,40)
gc.setColor(1,1,1)
gc.setLineWidth(4)
gc.line(0,20,40,20)
gc.line(20,0,20,40)


TEXTURE.cursor=C(12,12)
gc.setColor(1,1,1,.7)
gc.circle("fill",6,6,6)
gc.setColor(1,1,1)
gc.circle("fill",6,6,3)


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

setFont(20)
TEXTURE.ws_dead=C(20,20)
gc.setColor(1,.4,.3)
gc.print("X",3,-4)
TEXTURE.ws_connecting=C(20,20)
gc.setLineWidth(3)
gc.setColor(1,1,1)
gc.arc("line","open",11.5,10,6.26,1,5.28)
TEXTURE.ws_running=C(20,20)
gc.setColor(0,.9,0)
gc.print("R",3,-4)


gc.setCanvas()
return TEXTURE