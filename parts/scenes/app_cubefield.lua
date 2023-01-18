local gc,kb,tc=love.graphics,love.keyboard,love.touch
local rnd,int,abs=math.random,math.floor,math.abs
local max,min=math.max,math.min
local setFont,mStr=FONT.set,GC.mStr

local cubeColor={
    {.88,.75,.00},
    {.50,.50,.97},
    {.50,.50,.50},
    {.50,.97,.00},
    {.94,.94,.94},
    {.40,.40,.40},
    {.31,.88,.97},
    {.97,.97,.50},
    {.91,.50,.97},
    {.97,.63,.31},
    {0,0,0},
}

local cubesX,cubesY
local lastCube
local player,moveDir
local life,life1,inv
local level,speed
local menu,ct,play
local score
local sunH,color,rot

local function near(o,t)
    return o>t and max(o-.01,t) or o<t and min(o+.01,t) or o
end
local function hurt(i)
    life=life-i
    if life<0 then
        life=-100
        menu,play=1,false
        speed=speed*.5
        moveDir=0
        score=int(score)
        SFX.play('clear_4')
    else
        SFX.play('clear_2')
    end
end

local scene={}

function scene.enter()
    cubesX={} for i=1,40 do cubesX[i]=rnd()*16-8 end
    cubesY={} for i=1,40 do cubesY[i]=i/40*9 end
    lastCube=1
    player,moveDir=0,0
    life,life1,inv=0,0,false
    level,speed=1,1
    menu,ct,play=false,60,false
    score=0
    sunH,color,rot=0,{.878,.752,0},0

    gc.setLineJoin('bevel')
    BGM.play('push')
    BG.set('none')
end

function scene.touchDown(x)
    if play then
        if x<640 then
            moveDir=-1
        else
            moveDir=1
        end
    end
end
function scene.touchUp(x)
    if play then
        local L=tc.getTouches()
        if x<640 then
            for i=1,#L do
                if tc.getPosition(L[i])>640 then
                    moveDir=1
                    return
                end
            end
        else
            for i=1,#L do
                if tc.getPosition(L[i])<640 then
                    moveDir=-1
                    return
                end
            end
        end
        moveDir=0
    else
        scene.keyDown('space')
    end
end
function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='escape' then
        SCN.back()
    elseif play then
        if key=='left' or key=='a' then
            moveDir=-1
        elseif key=='right' or key=='d' then
            moveDir=1
        end
    else
        if key=='space' and ct==60 then
            menu=-1
            speed=1
            level=1
        end
    end
end
function scene.keyUp(key)
    if play then
        if key=='left' or key=='a' then
            moveDir=kb.isDown('right','d') and 1 or 0
        elseif key=='right' or key=='d' then
            moveDir=kb.isDown('left','a') and -1 or 0
        end
    end
end

function scene.update(dt)
    if dt>.06 then dt=.06 end
    dt=dt*600

    -- Update cubes' position
    local cy=cubesY
    local step=speed*dt*.005
    for i=1,40 do
        cy[i]=cy[i]+step
        if cy[i]>10 then
            if score%1000<820 then
                cubesX[i]=rnd()*16-8+player
            else
                cubesX[i]=player+i%2*6-3
            end
            cy[i]=cy[i]-9
            lastCube=(lastCube-2)%40+1
        end
    end

    -- Collision detect
    if play then
        for j=1,40 do
            local i=(j+lastCube-2)%40+1
            local Y=cubesY[i]
            if Y<8.8 then
                local size=100/(10-Y)
                local x=(cubesX[i]-player)/(10-Y)*200-size*.5
                local y=5/(10-Y)*150-50
                if y>420 and y<480 and x<8 and x+size>-8 and inv==0 then
                    cubesX[i]=cubesX[i]-3
                    hurt(650)
                    inv=40
                end
            end
        end
    end

    -- Screen rotation
    if moveDir~=0 then
        player=player+moveDir*dt*.003*speed^.8
        if abs(rot)<.16 or moveDir*rot>0 then
            rot=rot-moveDir*dt*.0003*speed
        end
    elseif rot~=0 then
        local d=dt*.0002*speed
        if rot>0 then
            rot=max(rot-d,0)
        else
            rot=min(rot+d,0)
        end
    end

    life1=MATH.expApproach(life1,life,dt*16)

    if play then
        if inv>0 then
            inv=inv-1
        end
        score=score+dt*.04+life*.0004
        life=min(life+dt*.04,1000)
        if score>1000*level then
            if speed<3 then
                speed=speed+.2
            end
            level=level+1
            SFX.play('warn_1')
        end
        sunH=sunH+.01
    elseif menu==1 then
        ct=ct+1
        if ct==60 then
            menu=false
        end
    elseif menu==-1 then
        for i=1,3 do color[i]=near(color[i],cubeColor[1][i]) end
        for i=1,40 do cubesY[i]=cubesY[i]-(70-ct)*.003 end
        if sunH>0 then
            sunH=max(sunH*.85-1,0)
        end
        ct=ct-1
        if ct==0 then
            local t=love.system.getClipboardText()
            if type(t)=='string' then
                t=t:lower():match("^s=(%d+)$")
                t=t and tonumber(t) and tonumber(t)>0 and tonumber(t)<=8000 and int(tonumber(t))
            end
            score=type(t)=='number' and t or 0
            life=1000
            play,menu=true,false
            inv=90
        end
    end
end

local function _sunStencil()
    gc.rectangle('fill',-60,-440,120,120)
end
function scene.draw()
    -- Health bar
    if life1>0 then
        gc.setColor(1,0,0)
        gc.rectangle('fill',640-life1*.64,710,life1*1.28,10)
    end

    -- Draw player
    if play and inv%8<4 then
        gc.setColor(COLOR.Z)
        gc.rectangle('fill',620,670,40,40)
    end

    -- Set screen rotation
    gc.push('transform')
    gc.translate(640,690)
    gc.rotate(rot)

    -- Draw sun
    gc.setStencilTest('notequal',1)
    gc.stencil(_sunStencil)
    gc.setColor(.7,.5,.3)
    gc.circle('fill',0,-380-sunH,60)
    gc.setStencilTest()

    -- Draw direction
    if play then
        gc.setLineWidth(3)
        gc.setColor(1,1,1,.1)
        gc.polygon('fill',-15,30,0,-440,15,30)
    end

    -- Draw Horizon/Direction
    gc.setColor(COLOR.Z)
    gc.line(-942,-440,942,-440)

    -- Draw cubes
    for j=1,40 do
        local i=(j+lastCube-2)%40+1
        local Y=cubesY[i]
        if Y<8.8 then
            local size=100/(10-Y)
            local x=(cubesX[i]-player)/(10-Y)*200-size*.5
            local y=5/(10-Y)*150-50
            if Y>1 then
                gc.setColor(color)
                gc.rectangle('fill',x,y-485,size,size)
                gc.setLineWidth(size*.05)
                gc.setColor(COLOR.Z)
                gc.rectangle('line',x,y-485,size,size)
            end
        end
    end

    -- Draw menu
    if play then
        setFont(60)
        mStr(int(score),-300,-640)
        mStr(int(score),300,-640)
        if score%1000>920 then
            gc.setColor(1,1,1,abs(score%1000-970)*8)
            setFont(70)
            if level<11 then
                mStr("++SPEED++",0,-650)
                for i=1,3 do
                    color[i]=near(color[i],cubeColor[level+1][i])
                end
            else
                mStr("!!MAXSPEED!!",0,-650)
            end
        end
    else
        gc.setColor(COLOR.Z)
        gc.rectangle('fill',-20,-20+ct,40,40)

        gc.setColor(1,1,1,(1-ct/60)*.1)
        gc.polygon('fill',-15,30,0,-440,15,30)

        gc.setColor(1,1,1,ct/60)

        setFont(90)
        mStr("CubeField",0,-650)

        setFont(20)
        gc.print("Original game by Max Abernethy",40,-550)
        gc.print("Original CX-CAS version by Loïc Pujet",40,-525)
        gc.print("Ported / Rewritten / Balanced by MrZ",40,-500)

        setFont(45)
        if score>0 then
            mStr("Score : "..score,0,-350)
        end

        mStr(MOBILE and "Touch to Start" or "Press space to Start",0,-160)
    end
    gc.pop()
end

scene.widgetList={
    WIDGET.newKey{name='back',x=1140,y=80,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
