local gc=love.graphics
local function NSC(x,y)--New & Set Canvas
	local _=gc.newCanvas(x,y)
	gc.setCanvas(_)
	return _
end
local TEXTURE={}


gc.setDefaultFilter("nearest","nearest")


--Virtualkey icons
gc.setColor(1,1,1)
local VKI=gc.newImage("media/image/virtualkey.png")
TEXTURE.VKIcon={}
for i=1,20 do
	TEXTURE.VKIcon[i]=NSC(36,36)
	gc.draw(VKI,(i-1)%5*-36,math.floor((i-1)*.2)*-36)
end

--Mini blocks
gc.setColor(1,1,1)
TEXTURE.miniBlock={}
for i=1,29 do
	local b=BLOCKS[i][0]
	TEXTURE.miniBlock[i]=NSC(#b[1],#b)
	for y=1,#b do for x=1,#b[1]do
		if b[y][x]then
			gc.rectangle("fill",x-1,#b-y,1,1)
		end
	end end
end

--Texture of puzzle mode
TEXTURE.puzzleMark={}
gc.setLineWidth(3)
for i=1,17 do
	TEXTURE.puzzleMark[i]=NSC(30,30)
	local _=minoColor[i]
	gc.setColor(_[1],_[2],_[3],.6)
	gc.rectangle("line",5,5,20,20)
	gc.rectangle("line",10,10,10,10)
end
for i=18,24 do
	TEXTURE.puzzleMark[i]=NSC(30,30)
	gc.setColor(minoColor[i])
	gc.rectangle("line",7,7,16,16)
end
local _=NSC(30,30)
gc.setColor(1,1,1)
gc.line(5,5,25,25)
gc.line(5,25,25,5)
TEXTURE.puzzleMark[-1]=NSC(30,30)
gc.setColor(1,1,1,.8)
gc.draw(_)
_:release()
gc.setCanvas()

--A simple pixel font
TEXTURE.pixelNum={}
gc.setColor(1,1,1)
for i=0,9 do
	TEXTURE.pixelNum[i]=NSC(5,9)
	if("1011011111"):byte(i+1)==49 then gc.rectangle("fill",1,0,3,1)end--up
	if("0011111011"):byte(i+1)==49 then gc.rectangle("fill",1,4,3,1)end--middle
	if("1011011011"):byte(i+1)==49 then gc.rectangle("fill",1,8,3,1)end--down
	if("1000111011"):byte(i+1)==49 then gc.rectangle("fill",0,1,1,3)end--up-left
	if("1111100111"):byte(i+1)==49 then gc.rectangle("fill",4,1,1,3)end--up-right
	if("1010001010"):byte(i+1)==49 then gc.rectangle("fill",0,5,1,3)end--down-left
	if("1101111111"):byte(i+1)==49 then gc.rectangle("fill",4,5,1,3)end--down-right
end

--Cursor
TEXTURE.cursor=NSC(16,16)
gc.setColor(1,1,1,.7)
gc.circle("fill",8,8,6)
gc.setColor(1,1,1)
gc.circle("fill",8,8,4)

--Cursor while hold
TEXTURE.cursor_hold=NSC(16,16)
gc.setLineWidth(2)
gc.setColor(1,1,1)
gc.circle("line",8,8,7)
gc.circle("fill",8,8,3)


gc.setDefaultFilter("linear","linear")


--Title image
local titleTriangles={}
for i=1,8 do titleTriangles[i]=love.math.triangulate(title[i])end
TEXTURE.title=NSC(1160,236)--Middle: 580,118
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
TEXTURE.title_color=NSC(1160,236)
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

--WS icons
setFont(20)
TEXTURE.ws_dead=NSC(20,20)
gc.setColor(1,.3,.3)
gc.print("X",3,-4)
TEXTURE.ws_connecting=NSC(20,20)
gc.setLineWidth(3)
gc.setColor(1,1,1)
gc.arc("line","open",11.5,10,6.26,1,5.28)
TEXTURE.ws_running=NSC(20,20)
gc.setColor(.5,1,0)
gc.print("R",3,-4)


gc.setCanvas()
return TEXTURE