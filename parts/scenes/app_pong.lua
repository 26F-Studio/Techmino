local gc=love.graphics
local kb=love.keyboard

local abs=math.abs
local max,min=math.max,math.min
local rnd=math.random

local scene={}

local state
local bx,by=640,360-- Ball posotion
local vx,vy=0,0-- Ball velocity
local ry=0-- Rotation Y

local p1,p2-- Player data

function scene.enter()
    BG.set('none')
    BGM.play('way')
    state=0

    bx,by=640,360
    vx,vy=0,0
    ry=0

    p1={
        score=0,
        y=360,
        vy=0,
        y0=false,
    }
    p2={
        score=0,
        y=360,
        vy=0,
        y0=false,
    }
end

local function start()
    state=1
    vx=MATH.coin(6,-6)
    vy=rnd()*6-3
end
function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='space' then
        if state==0 then
            start()
        end
    elseif key=='r' then
        state=0
        bx,by=640,360
        vx,vy=0,0
        ry=0
        p1.score,p2.score=0,0
        SFX.play('hold')
    elseif key=='w' or key=='s' then
        p1.y0=false
    elseif key=='up' or key=='down' then
        p2.y0=false
    elseif key=='escape' then
        SCN.back()
    end
end
function scene.touchDown(x,y)
    scene.touchMove(x,y)
    if state==0 then start() end
end
function scene.touchMove(x,y)(x<640 and p1 or p2).y0=y end
function scene.mouseMove(x,y)(x<640 and p1 or p2).y0=y end

-- Rect Area X:150~1130 Y:20~700
function scene.update()
    -- Update pads
    local P=p1
    while P do
        if P.y0 then
            if P.y>P.y0 then
                P.y=max(P.y-8,P.y0,70)
                P.vy=-10
            elseif P.y<P.y0 then
                P.y=min(P.y+8,P.y0,650)
                P.vy=10
            else
                P.vy=P.vy*.5
            end
        else
            if kb.isDown(P==p1 and 'w' or 'up') then
                P.vy=max(P.vy-1,-8)
            end
            if kb.isDown(P==p1 and 's' or 'down') then
                P.vy=min(P.vy+1,8)
            end
            P.y=P.y+P.vy
            P.vy=P.vy*.9
            if P.y>650 then
                P.vy=-P.vy*.5
                P.y=650
            elseif P.y<70 then
                P.vy=-P.vy*.5
                P.y=70
            end
        end
        P=P==p1 and p2
    end

    -- Update ball
    bx,by=bx+vx,by+vy
    if ry~=0 then
        if ry>0 then
            ry=max(ry-.1,0)
            vy=vy-.1
        else
            ry=min(ry+.1,0)
            vy=vy+.1
        end
    end
    if state==1 then-- Playing
        if bx<160 or bx>1120 then
            P=bx<160 and p1 or p2
            local d=by-P.y
            if abs(d)<60 then
                vx=-vx-(vx>0 and .05 or -.5)
                vy=vy+d*.08+P.vy*.5
                ry=P.vy
                SFX.play('collect')
            else
                state=2
            end
        end
        if by<30 or by>690 then
            by=by<30 and 30 or 690
            vy,ry=-vy,-ry
            SFX.play('collect')
        end
    elseif state==2 then-- Game over
        if bx<-120 or bx>1400 or by<-40 or by>760 then
            P=bx>640 and p1 or p2
            P.score=P.score+1
            TEXT.show("+1",P==p1 and 470 or 810,226,50,'score')
            SFX.play('reach')

            state=0
            bx,by=640,360
            vx,vy=0,0
        end
    end
    bx,by,vx,vy,ry=bx,by,vx,vy,ry
end

function scene.draw()
    -- Draw score
    gc.setColor(.4,.4,.4)
    FONT.set(100)
    GC.mStr(p1.score,470,20)
    GC.mStr(p2.score,810,20)

    -- Draw boundary
    gc.setColor(COLOR.Z)
    gc.setLineWidth(4)
    gc.line(134,20,1146,20)
    gc.line(134,700,1146,700)

    -- Draw ball & speed line
    gc.setColor(1,1,1-abs(ry)*.16)
    gc.circle('fill',bx,by,10)
    gc.setColor(1,1,1,.1)
    gc.line(bx+vx*22,by+vy*22,bx+vx*30,by+vy*30)

    -- Draw pads
    gc.setColor(1,.8,.8)
    gc.rectangle('fill',134,p1.y-50,16,100)
    gc.setColor(.8,.8,1)
    gc.rectangle('fill',1130,p2.y-50,16,100)
end

scene.widgetList={
    WIDGET.newKey{name='reset',x=640,y=45,w=150,h=50,font=35,fText=CHAR.icon.retry_spin,code=pressKey'r'},
    WIDGET.newKey{name='back',x=640,y=675,w=150,h=50,font=40,sound='back',fText=CHAR.icon.back,code=backScene},
}

return scene
