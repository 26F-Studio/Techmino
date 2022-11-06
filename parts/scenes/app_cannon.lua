local gc=love.graphics
local int,rnd,abs,sin,cos=math.floor,math.random,math.abs,math.sin,math.cos

local pow,ang
local state,timer,score,combo
local x,y,vx,vy,ex,ey

local scene={}
function scene.enter()
    pow,ang=0,0
    state=0
    timer=0
    score,combo=0,0
    x,y=160,500
    ex,ey=626,260
    BG.set('matrix')
    BGM.play('hang out')
end

function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='space' or key=='return' then
        if state==0 then
            state=1
        elseif state==1 then
            state=2
            vx=pow*cos(ang)/2.6
            vy=pow*sin(ang)/2.6
        end
    elseif key=='escape' then
        if tryBack() then
            SCN.back()
        end
    end
end
function scene.mouseDown(_,_,k)
    if k==1 then
        scene.keyDown('space')
    end
end
function scene.touchDown()
    scene.keyDown('space')
end

function scene.update()
    timer=timer+1
    if state==0 then
        pow=abs(100-TIME()*200%200)
    elseif state==1 then
        ang=(abs(110-TIME()*120%220)-30)/180*3.141592653589793
    else
        x,y=x+vx,y-vy
        vy=vy-.62
        local e
        if (x-ex)^2+(y-ey)^2<900 then
            score=math.min(score+4+combo*2,626)
            combo=combo+1
            ex,ey=rnd(626,1100),rnd(26,700)
            SFX.play('reach')
            e=true
        end
        if x>1280 or y>720 then
            if score>0 then
                score=score-int(score/10)
            end
            SFX.play('finesseError')
            combo=0
            e=true
        end
        if e then
            x,y=rnd(100,260),rnd(160,700)
            state=0
        end
    end
end

local scoreColor={
    'Z',-- 0
    'A',-- 20
    'N',-- 40
    'B',-- 60
    'P',-- 80
    'W',-- 100
    'R','F','O','Y','lA',-- 200
    'lN','lB','lP','lW','lR',-- 300
    'lF','lO','lY','dA','dN',-- 400
    'dB','dP','dW','dR','dF',-- 500
    'dY','lH','H','dH',-- before 600, black after
}
function scene.draw()
    -- Spawn area
    gc.setColor(1,1,1,.2)
    gc.rectangle('fill',85,0,190,720)

    -- Power & Angle
    gc.setColor(COLOR.Z)
    if state~=2 then
        gc.setLineWidth(2)
        gc.rectangle('fill',x-80,y+20,pow*1.6,16)
        gc.rectangle('line',x-80,y+20,160,15)
        if state==1 then
            gc.setLineWidth(5)
            gc.line(x,y,x+(20+2*pow)*cos(ang),y-(20+2*pow)*sin(ang))
        end
    end

    -- Info
    FONT.set(40)
    if combo>1 then
        gc.setColor(1,1,.6)
        gc.print("x"..combo,300,80)
    end
    gc.setColor(COLOR[scoreColor[int(score/20)+1] or 'D'])
    gc.print(score,300,30)

    -- Cannon ball
    gc.circle('fill',x,y,15)

    -- Arrow
    if y<-15 then
        gc.print("↑",x-20.5,0)
    end

    -- Target
    gc.setColor(1,1,.4)
    gc.circle('fill',ex,ey,15)
end

scene.widgetList={
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
