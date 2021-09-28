local gc=love.graphics

local function NSC(x,y)--New & Set Canvas
    local _=gc.newCanvas(x,y)
    gc.setCanvas(_)
    return _
end
local TEXTURE={}


gc.setDefaultFilter('nearest','nearest')


TEXTURE.miniBlock={}--29 mini blocks image
do
    gc.setColor(1,1,1)
    for i=1,29 do
        local b=BLOCKS[i][0]
        TEXTURE.miniBlock[i]=NSC(#b[1],#b)
        for y=1,#b do for x=1,#b[1]do
            if b[y][x]then
                gc.rectangle('fill',x-1,#b-y,1,1)
            end
        end end
    end
end

TEXTURE.puzzleMark={}--Texture for puzzle mode
do
    gc.setLineWidth(2)
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
end

TEXTURE.pixelNum={}--A simple pixel font
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


TEXTURE.title=NSC(1160,236)--Title image (Middle: 580,118)
do
    for i=1,8 do
        local triangles=love.math.triangulate(title[i])

        gc.translate(12*i,i==1 and 8 or 14)

        gc.setLineWidth(16)
        gc.setColor(COLOR.Z)
        gc.polygon('line',title[i])

        gc.setColor(.2,.2,.2)
        for j=1,#triangles do
            gc.polygon('fill',triangles[j])
        end

        gc.translate(-12*i,i==1 and -8 or -14)
    end
end

TEXTURE.title_color=NSC(1160,236)--Title image (colored)
do
    local titleColor={COLOR.P,COLOR.F,COLOR.V,COLOR.A,COLOR.M,COLOR.N,COLOR.W,COLOR.Y}

    for i=1,8 do
        local triangles=love.math.triangulate(title[i])

        gc.translate(12*i,i==1 and 8 or 14)

        gc.setLineWidth(16)
        gc.setColor(COLOR.Z)
        gc.polygon('line',title[i])

        gc.setLineWidth(4)
        gc.setColor(COLOR.D)
        for j=1,#triangles do
            gc.polygon('fill',triangles[j])
        end

        gc.setColor(.2+.8*titleColor[i][1],.2+.8*titleColor[i][2],.2+.8*titleColor[i][3],.3)
        gc.translate(-4,-4)
        for j=1,#triangles do
            gc.polygon('fill',triangles[j])
        end
        gc.translate(4,4)

        gc.translate(-12*i,i==1 and -8 or -14)
    end
end

TEXTURE.multiple=GC.DO{15,15,
    {'setLW',3},
    {'line',2,2,12,12},
    {'line',2,12,12,2},
}

TEXTURE.playerBorder=GC.DO{334,620,
    {'setLW',2},
    {'setCL',.97,.97,.97},
    {'dRect',16,1,302,618,5},
    {'fRect',17,612,300,2},
    {'dRect',318,10,15,604,3},
    {'dRect',1,10,15,604,3},
}

TEXTURE.gridLines=(function()
    local L={300,640,{'setLW',2}}
    for x=1,9 do table.insert(L,{'line',30*x,0,30*x,640})end
    for y=0,20 do table.insert(L,{'line',0,10+30*y,300,10+30*y})end
    return GC.DO(L)
end)()

TEXTURE.dial={
    frame=GC.DO{80,80,
        {'setLW',3},
        {'dCirc',40,40,38},
    },
    needle=GC.DO{32,3,
        {'setLW',3},
        {'fRect',0,0,32,3,2},
        {'setCL',1,.3,.3},
        {'fRect',0,0,12,3,2},
    }
}

TEXTURE.sure=GC.DO{48,64,
    {'fRect',0,0,10,27},
    {'fRect',0,0,48,10},
    {'fRect',38,10,10,15},
    {'fRect',19,25,29,9},
    {'fRect',19,25,9,22},
    {'fRect',18,53,11,11},
}

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

TEXTURE.music=GC.DO{64,64,
    {'setLW',6},
    {'line',19,9,60,7},
    {'setLW',2},
    {'line',20,9,20,49},
    {'line',59,7,59,47},
    {'fElps',11,49,11,8},
    {'fElps',50,47,11,8},
}

TEXTURE.mute=GC.DO{64,64,
    {'mDraw',TEXTURE.music,32,32,0,.9},
    {'setLW',4},
    {'line',6,6,57,57},
}

TEXTURE.language=GC.DO{64,64,
    {'setLW',2},
    {'dCirc',32,32,30},
    {'line',2,31,62,31},
    {'line',31,2,31,62},
    {'dArc',10,31,40,-.8,.8},
    {'dArc',53,31,40,2.3,3.9},
}

TEXTURE.info=GC.DO{50,50,
    {'setLW',3},
    {'dCirc',25,25,22},
    {'fRect',22,11,6,6},
    {'fRect',22,20,6,20},
}

TEXTURE.question=GC.DO{50,50,
    {'setLW',3},
    {'dCirc',25,25,22},
    {'setFT',40},
    {'mText','?',26,-1},
}

TEXTURE.more=GC.DO{60,15,
    {'fCirc',10,7,6},
    {'fCirc',30,7,6},
    {'fCirc',50,7,6},
}

TEXTURE.back=GC.DO{60,55,
    {'setLW',6},
    {'line',11,10,40,10},
    {'line',10,40,40,40},
    {'dArc',40,25,15,-1.6,1.6},
    {'setLW',4},
    {'line',20,50,10,40,20,30},
}

TEXTURE.quit=GC.DO{50,50,
    {'setCL',1,1,1},
    {'draw',GC.DO{50,50,
        {'setLW',7},
        {'line',5,5,45,45},
        {'line',5,45,45,5},
    }}
}

TEXTURE.quit_small=GC.DO{30,30,
    {'setCL',1,1,1},
    {'draw',GC.DO{30,30,
        {'setLW',4},
        {'line',2,2,28,28},
        {'line',2,28,28,2},
    }}
}

TEXTURE.game={--In-game icons
    restart=GC.DO{32,32,{'setLW',3},{'dArc',16,16,11,.7,5.5},{'setLW',2.5},{'line',21,.7,24,8,16,11}},
    pause=GC.DO{18,23,{'fRect',0,0,3,23},{'fRect',15,0,3,23}},
}

TEXTURE.rep={--Replay speed buttons
    rep0=GC.DO{50,50,{'fRect',11,8,8,34},{'fRect',31,8,8,34}},
    repP8=GC.DO{50,50,{'setFT',15},{'mText',"0.125x",25,15}},
    repP2=GC.DO{50,50,{'setFT',25},{'mText',"0.5x",25,8}},
    rep1=GC.DO{50,50,{'setFT',30},{'mText',"1x",25,3}},
    rep2=GC.DO{50,50,{'setFT',30},{'mText',"2x",25,3}},
    rep5=GC.DO{50,50,{'setFT',30},{'mText',"5x",25,3}},
    step=GC.DO{50,50,{'setFT',30},{'fRect',12,7,4,36},{'setLW',4},{'line',25,14,41,25,25,36}},
}

gc.setCanvas()
return TEXTURE
