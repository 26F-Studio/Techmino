local gc=love.graphics

local int,rnd=math.floor,math.random

local scene={}

local board,cx,cy
local startTime,time
local move,push,state

local color,invis='color1'
local slide,pathVis,revKB

local function ifGaming() return state==1 end
local colorSelector=WIDGET.newSelector{name='color',x=150,y=240,w=200,list={'color1','rainbow','color2','gray','black'},color='lY',disp=function() return color end,code=function(v) if state~=1 then color=v end end,hideF=ifGaming}

function scene.enter()
    BG.set('rainbow2')
    BGM.play('push')
    board={{1,2,3,4},{5,6,7,8},{9,10,11,12},{13,14,15,16}}
    cx,cy=4,4
    startTime=0
    time=0
    move,push=0,0
    state=2

    color='color1'
    invis=false
    slide=true
    pathVis=true
    revKB=false
end

local function moveU(x,y)
    if y<4 then
        board[y][x],board[y+1][x]=board[y+1][x],board[y][x]
        cy=cy+1
    end
end
local function moveD(x,y)
    if y>1 then
        board[y][x],board[y-1][x]=board[y-1][x],board[y][x]
        cy=cy-1
    end
end
local function moveL(x,y)
    if x<4 then
        board[y][x],board[y][x+1]=board[y][x+1],board[y][x]
        cx=cx+1
    end
end
local function moveR(x,y)
    if x>1 then
        board[y][x],board[y][x-1]=board[y][x-1],board[y][x]
        cx=cx-1
    end
end
local function shuffleBoard()
    for i=1,300 do
        i=rnd()
        if i<.25 then moveU(cx,cy)
        elseif i<.5 then moveD(cx,cy)
        elseif i<.75 then moveL(cx,cy)
        else moveR(cx,cy)
        end
    end
end
local function checkBoard(b)
    for i=4,1,-1 do
        for j=1,4 do
            if b[i][j]~=4*i+j-4 then
                return false
            end
        end
    end
    return true
end
local function tapBoard(x,y,key)
    if state<2 then
        if not key then
            if pathVis then
                SYSFX.newShade(6,x-5,y-5,11,11,1,1,1)
            end
            x,y=int((x-320)/160)+1,int((y-40)/160)+1
        end
        local b=board
        local moves=0
        if cx==x then
            if y>cy and y<5 then
                for i=cy,y-1 do
                    moveU(x,i)
                    moves=moves+1
                end
            elseif y<cy and y>0 then
                for i=cy,y+1,-1 do
                    moveD(x,i)
                    moves=moves+1
                end
            end
        elseif cy==y then
            if x>cx and x<5 then
                for i=cx,x-1 do
                    moveL(i,y)
                    moves=moves+1
                end
            elseif x<cx and x>0 then
                for i=cx,x+1,-1 do
                    moveR(i,y)
                    moves=moves+1
                end
            end
        end
        if moves>0 then
            push=push+1
            move=move+moves
            if state==0 then
                state=1
                startTime=TIME()
            end
            if checkBoard(b) then
                state=2
                time=TIME()-startTime
                SFX.play('win')
                return
            end
            SFX.play('touch')
        end
    end
end
function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='up' then
        tapBoard(cx,cy-(revKB and 1 or -1),true)
    elseif key=='down' then
        tapBoard(cx,cy+(revKB and 1 or -1),true)
    elseif key=='left' then
        tapBoard(cx-(revKB and 1 or -1),cy,true)
    elseif key=='right' then
        tapBoard(cx+(revKB and 1 or -1),cy,true)
    elseif key=='space' then
        shuffleBoard()
        state=0
        time=0
        move,push=0,0
    elseif key=='q' then
        if state~=1 then
            colorSelector:scroll(love.keyboard.isDown('lshift','rshift') and -1 or 1)
        end
    elseif key=='w' then
        if state==0 then
            invis=not invis
        end
    elseif key=='e' then
        if state==0 then
            slide=not slide
            if not slide then
                pathVis=false
            end
        end
    elseif key=='r' then
        if state==0 and slide then
            pathVis=not pathVis
        end
    elseif key=='t' then
        if state==0 then
            revKB=not revKB
        end
    elseif key=='escape' then
        SCN.back()
    end
end
function scene.mouseDown(x,y)
    tapBoard(x,y)
end
function scene.mouseMove(x,y)
    if slide then
        tapBoard(x,y)
    end
end
function scene.touchDown(x,y)
    tapBoard(x,y)
end
function scene.touchMove(x,y)
    if slide then
        tapBoard(x,y)
    end
end

function scene.update()
    if state==1 then
        time=TIME()-startTime
    end
end

local frontColor={
    color1={
        COLOR.lR,COLOR.lR,COLOR.lR,COLOR.lR,
        COLOR.lG,COLOR.lB,COLOR.lB,COLOR.lB,
        COLOR.lG,COLOR.lY,COLOR.lV,COLOR.lV,
        COLOR.lG,COLOR.lY,COLOR.lV,COLOR.lV,
    },-- Colored(rank)
    rainbow={
        COLOR.lR,COLOR.lR,COLOR.lR,COLOR.lR,
        COLOR.lO,COLOR.lY,COLOR.lY,COLOR.lY,
        COLOR.lO,COLOR.lG,COLOR.lB,COLOR.lB,
        COLOR.lO,COLOR.lG,COLOR.lB,COLOR.lB,
    },-- Rainbow(rank)
    color2={
        COLOR.lR,COLOR.lR,COLOR.lR,COLOR.lR,
        COLOR.lB,COLOR.lB,COLOR.lB,COLOR.lB,
        COLOR.lG,COLOR.lY,COLOR.lV,COLOR.lV,
        COLOR.lG,COLOR.lY,COLOR.lV,COLOR.lV,
    },-- Colored(row)
    gray={
        COLOR.Z,COLOR.Z,COLOR.Z,COLOR.Z,
        COLOR.Z,COLOR.Z,COLOR.Z,COLOR.Z,
        COLOR.Z,COLOR.Z,COLOR.Z,COLOR.Z,
        COLOR.Z,COLOR.Z,COLOR.Z,COLOR.Z,
    },-- Gray
    black={
        COLOR.Z,COLOR.Z,COLOR.Z,COLOR.Z,
        COLOR.Z,COLOR.Z,COLOR.Z,COLOR.Z,
        COLOR.Z,COLOR.Z,COLOR.Z,COLOR.Z,
        COLOR.Z,COLOR.Z,COLOR.Z,COLOR.Z,
    },-- Black
}
local backColor={
    color1={
        COLOR.dR,COLOR.dR,COLOR.dR,COLOR.dR,
        COLOR.dG,COLOR.dB,COLOR.dB,COLOR.dB,
        COLOR.dG,COLOR.dY,COLOR.dP,COLOR.dP,
        COLOR.dG,COLOR.dY,COLOR.dP,COLOR.dP,
    },-- Colored(rank)
    rainbow={
        COLOR.dR,COLOR.dR,COLOR.dR,COLOR.dR,
        COLOR.dO,COLOR.dY,COLOR.dY,COLOR.dY,
        COLOR.dO,COLOR.dG,COLOR.dB,COLOR.dB,
        COLOR.dO,COLOR.dG,COLOR.dB,COLOR.dB,
    },-- Rainbow(rank)
    color2={
        COLOR.dR,COLOR.dR,COLOR.dR,COLOR.dR,
        COLOR.dB,COLOR.dB,COLOR.dB,COLOR.dB,
        COLOR.dG,COLOR.dY,COLOR.dP,COLOR.dP,
        COLOR.dG,COLOR.dY,COLOR.dP,COLOR.dP,
    },-- Colored(row)
    gray={
        COLOR.dH,COLOR.dH,COLOR.dH,COLOR.dH,
        COLOR.dH,COLOR.dH,COLOR.dH,COLOR.dH,
        COLOR.dH,COLOR.dH,COLOR.dH,COLOR.dH,
        COLOR.dH,COLOR.dH,COLOR.dH,COLOR.dH,
    },-- Gray
    black={
        COLOR.D,COLOR.D,COLOR.D,COLOR.D,
        COLOR.D,COLOR.D,COLOR.D,COLOR.D,
        COLOR.D,COLOR.D,COLOR.D,COLOR.D,
        COLOR.D,COLOR.D,COLOR.D,COLOR.D,
    },-- Black
}
function scene.draw()
    FONT.set(40)
    gc.setColor(COLOR.Z)
    gc.print(("%.3f"):format(time),1026,80)
    gc.setColor(1,.8,.8)
    gc.print(move,1026,130)
    gc.setColor(.8,.8,1)
    gc.print(push,1026,180)

    if state==2 then
        -- Draw no-setting area
        gc.setColor(1,0,0,.3)
        gc.rectangle('fill',15,295,285,340)

        gc.setColor(.9,.9,0)-- win
    elseif state==1 then
        gc.setColor(.9,.9,.9)-- game
    elseif state==0 then
        gc.setColor(.2,.8,.2)-- ready
    end
    gc.setLineWidth(10)
    gc.rectangle('line',313,33,654,654,18)

    gc.setLineWidth(4)
    local mono=invis and state==1
    FONT.set(80)
    for i=1,4 do
        for j=1,4 do
            if cx~=j or cy~=i then
                local N=board[i][j]
                local C=mono and 'gray' or color

                gc.setColor(backColor[C][N])
                gc.rectangle('fill',j*160+163,i*160-117,154,154,8)
                gc.setColor(frontColor[C][N])
                gc.rectangle('line',j*160+163,i*160-117,154,154,8)
                if not mono then
                    gc.setColor(.1,.1,.1)
                    GC.mStr(N,j*160+240,i*160-96)
                    GC.mStr(N,j*160+242,i*160-98)
                    gc.setColor(COLOR.Z)
                    GC.mStr(N,j*160+243,i*160-95)
                end
            end
        end
    end
    gc.setColor(COLOR.dX)
    gc.setLineWidth(10)
    gc.rectangle('line',cx*160+173,cy*160-107,134,134,50)
end

scene.widgetList={
    WIDGET.newButton{name='reset',  x=160, y=100,w=180,h=100,color='lG',font=50,fText=CHAR.icon.retry_spin,code=pressKey'space'},
    colorSelector,
    WIDGET.newSwitch{name='invis',  x=240, y=330,lim=200,font=40,disp=function() return invis end,  code=pressKey'w',hideF=ifGaming},
    WIDGET.newSwitch{name='slide',  x=240, y=420,lim=200,font=40,disp=function() return slide end,  code=pressKey'e',hideF=ifGaming},
    WIDGET.newSwitch{name='pathVis',x=240, y=510,lim=200,font=40,disp=function() return pathVis end,code=pressKey'r',hideF=function() return state==1 or not slide end},
    WIDGET.newSwitch{name='revKB',  x=240, y=600,lim=200,font=40,disp=function() return revKB end,  code=pressKey't',hideF=ifGaming},
    WIDGET.newButton{name='back',   x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
