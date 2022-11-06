local gc=love.graphics
local rnd=math.random
local setFont,mStr=FONT.set,GC.mStr

local scene={}

local state
local ct
local s1,s2
local up,winner=true

local function reset()
    state=0
    ct=20
    s1,s2=0,0
end

function scene.enter()
    reset()
    BG.set('none')
end

function scene.keyDown(key,isRep)
    if isRep then return end
    if state==0 then
        if key=='space' then
            reset()
            state=1
            ct=60
        end
    elseif state==2 and #key==1 then
        key=("qapl"):find(key,nil,true)
        if key then
            -- BEAUTIFUL LOGIC BELOW:

            -- early = error, [UP-key]==[target is up] = correct sfx, else = wrong sfx
            SFX.play(ct>6 and 'finesseError' or key%2==1==up and 'reach' or 'fail')

            -- (early && P2-key || not early && [P1-key]==[target is up]) = P1 win, else P2 win
            if ct>6 and key>2 or ct<=6 and key%4<2==up then
                winner=1; s1=s1+1
            else
                winner=2; s2=s2+1
            end
            state=3
            ct=60
        end
    end
end
function scene.touchDown(x,y)
    scene.keyDown(
        state==0 and "space" or
        x<640 and
            (y<360 and "q" or "a") or
            (y<360 and "p" or "l")
    )
end
function scene.update()
    if state==0 then-- Menu
        if ct>0 then
            ct=ct-1
        elseif rnd()<.00626 then
            ct=30
        end
    elseif state==1 then-- Waiting
        ct=ct-1
        if ct==0 then
            ct=rnd(26,162)
            up=rnd()<.5
            state=2
        end
    elseif state==2 then-- Winking
        ct=ct-1
        if ct==0 then ct=6 end
    elseif state==3 then
        ct=ct-1
        if ct==0 then
            if s1==6 or s2==6 then
                state=0
            else
                state=1
            end
            ct=60
        end
    end
end
function scene.draw()
    -- Dividing line
    gc.setLineWidth(10)
    gc.setColor(1,1,1,.9)
    gc.line(640,0,640,720)
    gc.setColor(1,1,1,.3)
    gc.line(500,360,780,360)

    -- Help
    setFont(100)
    mStr("Q",80,100)
    mStr("A",80,480)
    mStr("P",1200,100)
    mStr("L",1200,480)

    -- Score
    setFont(80)
    gc.printf(s1,50,300,200)
    gc.printf(s2,1030,300,200,'right')

    if state==0 then
        setFont(40)
        mStr(MOBILE and "Touch to Start" or "Press space to Start",640,400)
        mStr("Press key on the same side when block appear!",640,500)
        if ct>0 then
            setFont(100)
            gc.setColor(1,1,1,ct/30)
            mStr("REFLECT",640,140)
        end
    elseif state==1 then
        gc.setColor(.2,.7,.4,math.min((60-ct)/10,ct/10)*.8)
        gc.arc('fill',640,360,260,-1.5708,-1.5708+(ct/60)*6.2832)
    elseif state==2 and ct<5 then
        gc.setColor(1,ct>2 and 1 or 0,0)
        gc.rectangle('fill',640-100,(up and 180 or 540)-100,200,200,10)
    elseif state==3 then
        local x=(60-ct)*62
        gc.setColor(.4,1,.4,ct/100)
        if winner==1 then
            gc.rectangle('fill',0,0,x,720)
        else
            gc.rectangle('fill',1280,0,-x,720)
        end
    end
end

scene.widgetList={
    WIDGET.newKey{name='back',x=640,y=675,w=150,h=50,font=40,sound='back',fText=CHAR.icon.back,code=backScene},
}

return scene
