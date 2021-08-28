local gc=love.graphics

local function NSC(x,y)--New & Set Canvas
    local _=gc.newCanvas(x,y)
    gc.setCanvas(_)
    return _
end
local TEXTURE={}

gc.origin()
gc.setDefaultFilter('nearest','nearest')

--Mini blocks
gc.setColor(1,1,1)
TEXTURE.miniBlock={}
for i=1,29 do
    local b=BLOCKS[i][0]
    TEXTURE.miniBlock[i]=NSC(#b[1],#b)
    for y=1,#b do for x=1,#b[1]do
        if b[y][x]then
            gc.rectangle('fill',x-1,#b-y,1,1)
        end
    end end
end

--Texture of puzzle mode
gc.setLineWidth(2)
TEXTURE.puzzleMark={}
for i=1,17 do
    TEXTURE.puzzleMark[i]=GC.DO{30,30,
        {'setLW',2},
        {'setCL',minoColor[i][1],minoColor[i][2],minoColor[i][3],.7},
        {'dRect',5,5,20,20},
        {'dRect',10,10,10,10},
    }
end
for i=18,24 do
    TEXTURE.puzzleMark[i]=GC.DO{30,30,
        {'setCL',minoColor[i]},
        {'dRect',7,7,16,16},
    }
end
TEXTURE.puzzleMark[-1]=GC.DO{30,30,
    {'setCL',1,1,1,.8},
    {'draw',GC.DO{30,30,
        {'setLW',3},
        {'line',5,5,25,25},
        {'line',5,25,25,5},
    }}
}

--A simple pixel font
TEXTURE.pixelNum={}
for i=0,9 do
    TEXTURE.pixelNum[i]=GC.DO{5,9,
        {('1011011111'):byte(i+1)>48,'fRect',1,0,3,1},--up
        {('0011111011'):byte(i+1)>48,'fRect',1,4,3,1},--middle
        {('1011011011'):byte(i+1)>48,'fRect',1,8,3,1},--down
        {('1000111011'):byte(i+1)>48,'fRect',0,1,1,3},--up-left
        {('1111100111'):byte(i+1)>48,'fRect',4,1,1,3},--up-right
        {('1010001010'):byte(i+1)>48,'fRect',0,5,1,3},--down-left
        {('1101111111'):byte(i+1)>48,'fRect',4,5,1,3},--down-right
    }
end

gc.setDefaultFilter('linear','linear')

--Title image
local titleTriangles={}
for i=1,8 do titleTriangles[i]=love.math.triangulate(title[i])end
TEXTURE.title=NSC(1160,236)--Middle: 580,118
for i=1,8 do
    gc.translate(12*i,i==1 and 8 or 14)

    gc.setLineWidth(16)
    gc.setColor(COLOR.Z)
    gc.polygon('line',title[i])

    gc.setColor(.2,.2,.2)
    for j=1,#titleTriangles[i]do
        gc.polygon('fill',titleTriangles[i][j])
    end

    gc.translate(-12*i,i==1 and -8 or -14)
end
local titleColor={COLOR.lP,COLOR.lC,COLOR.lB,COLOR.lO,COLOR.lF,COLOR.lM,COLOR.lG,COLOR.lY}
TEXTURE.title_color=NSC(1160,236)
for i=1,8 do
    gc.translate(12*i,i==1 and 8 or 14)

    gc.setLineWidth(16)
    gc.setColor(COLOR.Z)
    gc.polygon('line',title[i])

    gc.setLineWidth(4)
    gc.setColor(COLOR.D)
    for j=1,#titleTriangles[i]do
        gc.polygon('fill',titleTriangles[i][j])
    end

    gc.setColor(.2+.8*titleColor[i][1],.2+.8*titleColor[i][2],.2+.8*titleColor[i][3],.5)
    gc.translate(-4,-4)
    for j=1,#titleTriangles[i]do
        gc.polygon('fill',titleTriangles[i][j])
    end
    gc.translate(4,4)

    gc.translate(-12*i,i==1 and -8 or -14)
end

--Sure mark
TEXTURE.sure=GC.DO{48,64,
    {'fRect',0,0,10,27},
    {'fRect',0,0,48,10},
    {'fRect',38,10,10,15},
    {'fRect',19,25,29,9},
    {'fRect',19,25,9,22},
    {'fRect',18,53,11,11},
}

--Setting icon
TEXTURE.setting=GC.DO{64,64,
    {'setLW',8},
    {'dCirc',32,32,18},
    {'setLW',10},
    {'line',52,32,64,32},
    {'line',32,52,32,64},
    {'line',12,32,0,32},
    {'line',32,12,32,0},
    {'line',45,45,55,55},
    {'line',19,45,9,55},
    {'line',19,19,9,9},
    {'line',45,19,55,9},
}

--Music mark
TEXTURE.music=GC.DO{64,64,
    {'setLW',6},
    {'line',19,9,60,7},
    {'setLW',2},
    {'line',20,9,20,49},
    {'line',59,7,59,47},
    {'fElps',11,49,11,8},
    {'fElps',50,47,11,8},
}

--Mute mark
TEXTURE.mute=GC.DO{64,64,
    {'mDraw',TEXTURE.music,32,32,0,.9},
    {'setLW',4},
    {'line',6,6,57,57},
}

--Language mark
TEXTURE.language=GC.DO{64,64,
    {'setLW',2},
    {'dCirc',32,32,30},
    {'line',2,31,62,31},
    {'line',31,2,31,62},
    {'dArc',10,31,40,-.8,.8},
    {'dArc',53,31,40,2.3,3.9},
}

--Info. mark
TEXTURE.info=GC.DO{50,50,
    {'setLW',3},
    {'dCirc',25,25,22},
    {'fRect',22,11,6,6},
    {'fRect',22,20,6,20},
}

--Question mark
TEXTURE.question=GC.DO{50,50,
    {'setLW',3},
    {'dCirc',25,25,22},
    {'setFT',40},
    {'print','?',17,-2},
}

--More mark
TEXTURE.more=GC.DO{60,15,
    {'fCirc',10,7,6},
    {'fCirc',30,7,6},
    {'fCirc',50,7,6},
}

--Back mark
TEXTURE.back=GC.DO{60,55,
    {'setLW',6},
    {'line',11,10,40,10},
    {'line',10,40,40,40},
    {'dArc',40,25,15,-1.6,1.6},
    {'setLW',4},
    {'line',20,50,10,40,20,30},
}

--Quit mark
TEXTURE.quit=GC.DO{50,50,
    {'setCL',1,1,1},
    {'draw',GC.DO{50,50,
        {'setLW',7},
        {'line',5,5,45,45},
        {'line',5,45,45,5},
    }}
}

--Quit mark (small)
TEXTURE.quit_small=GC.DO{30,30,
    {'setCL',1,1,1},
    {'draw',GC.DO{30,30,
        {'setLW',4},
        {'line',2,2,28,28},
        {'line',2,28,28,2},
    }}
}

TEXTURE.game={
    restart=GC.DO{32,32,{'setLW',3},{'dArc',16,16,11,.7,5.5},{'setLW',2.5},{'line',21,.7,24,8,16,11}},
    pause=GC.DO{18,23,{'fRect',0,0,3,23},{'fRect',15,0,3,23}},
}

--Replay speed buttons
TEXTURE.rep={
    rep0=GC.DO{50,50,{'fRect',11,8,8,34},{'fRect',31,8,8,34}},
    repP8=GC.DO{50,50,{'setFT',15},{'print',"0.125x",0,15}},
    repP2=GC.DO{50,50,{'setFT',25},{'print',"0.5x",0,8}},
    rep1=GC.DO{50,50,{'setFT',30},{'print',"1x",7,3}},
    rep2=GC.DO{50,50,{'setFT',30},{'print',"2x",7,3}},
    rep5=GC.DO{50,50,{'setFT',30},{'print',"5x",7,3}},
    step=GC.DO{50,50,{'setFT',30},{'fRect',12,7,4,36},{'setLW',4},{'line',25,14,41,25,25,36}},
}

gc.setCanvas()
return TEXTURE
