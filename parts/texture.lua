local gc=love.graphics
local ins=table.insert

local function NSC(x,y)--New & Set Canvas
	local _=gc.newCanvas(x,y)
	gc.setCanvas(_)
	return _
end
local TEXTURE={}


gc.setDefaultFilter("nearest","nearest")



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
gc.setLineWidth(2)
TEXTURE.puzzleMark={}
for i=1,17 do
	TEXTURE.puzzleMark[i]=DOGC{30,30,
		{"setCL",minoColor[i][1],minoColor[i][2],minoColor[i][3],.6},
		{"dRect",5,5,20,20},
		{"dRect",10,10,10,10},
	}
end
for i=18,24 do
	TEXTURE.puzzleMark[i]=DOGC{30,30,
		{"setCL",minoColor[i]},
		{"dRect",7,7,16,16},
	}
end
TEXTURE.puzzleMark[-1]=DOGC{30,30,
	{"setCL",1,1,1,.8},
	{"draw",DOGC{30,30,
		{"setLW",3},
		{"dLine",5,5,25,25},
		{"dLine",5,25,25,5},
	}}
}

--A simple pixel font
TEXTURE.pixelNum={}
for i=0,9 do
	TEXTURE.pixelNum[i]=DOGC{5,9,
		{("1011011111"):byte(i+1)==49,"fRect",1,0,3,1},--up
		{("0011111011"):byte(i+1)==49,"fRect",1,4,3,1},--middle
		{("1011011011"):byte(i+1)==49,"fRect",1,8,3,1},--down
		{("1000111011"):byte(i+1)==49,"fRect",0,1,1,3},--up-left
		{("1111100111"):byte(i+1)==49,"fRect",4,1,1,3},--up-right
		{("1010001010"):byte(i+1)==49,"fRect",0,5,1,3},--down-left
		{("1101111111"):byte(i+1)==49,"fRect",4,5,1,3},--down-right
	}
end

--Cursor
TEXTURE.cursor=DOGC{16,16,
	{"fCirc",8,8,4},
	{"setCL",1,1,1,.7},
	{"fCirc",8,8,6},
}

--Cursor while hold
TEXTURE.cursor_hold=DOGC{16,16,
	{"setLW",2},
	{"dCirc",8,8,7},
	{"fCirc",8,8,3},
}

--Level icons
TEXTURE.lvIcon=setmetatable({},{__index=function(self,lv)
	local img={25,25}

	ins(img,{"clear",0,0,0})
	ins(img,{"setLW",4})
	ins(img,{"setCL",.5,.8,1})
	ins(img,{"dRect",2,2,21,21})
	--TODO: draw with lv

	img=DOGC(img)
	rawset(self,lv,img)
	return img
end})

--Setting icon
TEXTURE.setting=DOGC{64,64,
	{"setLW",8},
	{"dCirc",32,32,18},
	{"setLW",10},
	{"dLine",52,32,64,32},
	{"dLine",32,52,32,64},
	{"dLine",12,32,0,32},
	{"dLine",32,12,32,0},
	{"dLine",45,45,55,55},
	{"dLine",19,45,9,55},
	{"dLine",19,19,9,9},
	{"dLine",45,19,55,9},
}


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
local titleColor={COLOR.lP,COLOR.lC,COLOR.lB,COLOR.lO,COLOR.lF,COLOR.lM,COLOR.lG,COLOR.lY}
TEXTURE.title_color=NSC(1160,236)
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
TEXTURE.ws_dead=DOGC{20,20,
	{"setCL",1,.3,.3},
	{"print","X",3,-4},
}
TEXTURE.ws_connecting=DOGC{20,20,
	{"setLW",3},
	{"dArc",11.5,10,6.26,1,5.28},
}
TEXTURE.ws_running=DOGC{20,20,
	{"setCL",.5,1,0},
	{"print","R",3,-4},
}


gc.setCanvas()
return TEXTURE