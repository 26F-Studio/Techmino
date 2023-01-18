local gc=love.graphics
local rnd,int,max=math.random,math.floor,math.max
local setFont,mStr=FONT.set,GC.mStr

-- This mini-game is written for TI-nSpire CX CAS many years ago.
-- Deliberately, some grammar mistakes and typos in the 'great' list remained.
-- So no need to correct them.

local perfect={"Perfect!","Excellent!","Nice!","Good!","Great!","Just!","300"}
local great={"Pay attention!","Be carefully!","Teacher behind you!","Feel tired?","You are in danger!","Do your homework!","A good game!","Minecraft!","y=ax^2+bx+c!","No music?","Internet unavailable.","It's raining!","Too hard!","Shorter?","Higher!","English messages!","Hi!","^_^","Drop!","Colorful!",":)","100$","~~~wave~~~","★★★","中文!","NOW!!!!!","Also try the TEN!","I'm a programer!","Also try minesweeperZ!","This si Dropper!","Hold your calculatoor!","Look! UFO!","Bonjour!","[string]","Author:MrZ","Boom!","PvZ!","China!","TI-nspire!","I love LUA!"}
local miss={"Oops!","Uh-oh","Ouch!","Oh no."}

local scene={}

local highScore,highFloor=0,0
local move,base
local state,message
local speed
local score,floor,camY
local color1,color2={},{}

local function restart()
    move={x=0,y=260,l=500}
    base={x=40,y=690,l=1200}
    message="Welcome"
    speed=10
    score=0
    floor=0
    camY=0
    for i=1,3 do
        color1[i]=rnd()
        color2[i]=rnd()
    end
end

function scene.enter()
    restart()
    state='menu'
    BGM.play('hang out')
    BG.set('space')
end

function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='space' or key=='return' then
        if state=='move' then
            if floor>0 then
                if move.x<base.x then
                    move.x=move.x+10
                elseif move.x>base.x then
                    move.x=move.x-10
                end
            end
            SFX.play('hold')
            state='drop'
        elseif state=='dead' then
            move.x,move.y,move.l=1e99,0,0
            base.x,base.y,base.l=1e99,0,0
            state='scroll'
        elseif state=='menu' then
            restart()
            state='move'
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
    if state=='move' then
        move.x=move.x+speed
        if speed<0 and move.x<=0 or speed>0 and move.x+move.l>=1280 then
            SFX.play('lock')
            speed=-speed
        end
    elseif state=='drop' then
        move.y=move.y+18
        if move.y>=660 then
            if move.x>base.x+base.l or move.x+move.l<base.x then
                message=miss[rnd(1,4)]
                state='die'
            else
                move.y=660
                SFX.play('clear_1')
                if floor>0 and move.x==base.x then
                    SFX.play('ren_mega')
                end
                state='shorten'
            end
        end
    elseif state=='shorten' then
        if move.x>base.x+base.l or move.x+move.l<base.x then
            state='die'
        elseif move.x<base.x then
            move.x=move.x+5
            move.l=move.l-5
        elseif move.x+move.l>base.x+base.l then
            move.l=move.l-5
        else
            state='climb'
        end
    elseif state=='climb' then
        if base.y<720 then
            move.y=move.y+3
            base.y=base.y+3
            camY=camY+3
        else
            if move.x==base.x and move.x+move.l==base.x+base.l and floor~=0 then
                score=score+2
                message=perfect[rnd(1,3)]
            else
                score=score+1
                message=great[rnd(1,table.maxn(great))]
            end
            for i=1,3 do
                color2[i]=color1[i]
                color1[i]=rnd()
            end
            base.x=move.x
            base.y=690
            base.l=move.l
            floor=floor+1
            if rnd()<.5 then
                move.x=-move.l
                speed=10
            else
                move.x=1280
                speed=-10
            end
            move.y=rnd(max(260-floor*4,60),max(420-floor*5,100))
            state='move'
        end
    elseif state=='die' then
        move.y=move.y+18
        if move.y>1000 then
            highScore=max(score,highScore)
            highFloor=max(floor,floor)
            state='dead'
        end
    elseif state=='scroll' then
        camY=camY-floor/4
        if camY<1000 then camY=camY-1 end
        if camY<500 then camY=camY-1 end
        if camY<0 then
            restart()
            state='move'
        end
    end
end

local backColor={
    {.71,1,.71},
    {.47,.86,1},
    {.63,.78,1},
    {.71,.71,.71},
    {.59,.55,.55},
    {.43,.43,.43,.9},
    {.34,.34,.34,.8},
    {.26,.26,.26,.7},
}
backColor.__index=function(t,lv)
    local a=backColor[#backColor][4]-.1
    t[lv]={.26,.26,.26,a}
    return t[lv]
end
setmetatable(backColor,backColor)
function scene.draw()
    -- Background
    local lv,height=int(camY/700),camY%700
    gc.setColor(backColor[lv+1] or COLOR.D)
    gc.rectangle('fill',0,720,1280,height-700)
    gc.setColor(backColor[lv+2] or COLOR.D)
    gc.rectangle('fill',0,height+20,1280,-height-20)
    if height-680>0 then
        gc.setColor(backColor[lv+3] or COLOR.D)
        gc.rectangle('fill',0,height-680,1280,680-height)
    end

    if state=='menu' or state=='dead' then
        setFont(100)
        gc.setColor(COLOR.rainbow_light(TIME()*2.6))
        mStr("DROPPER",640,120)

        gc.setColor(COLOR.rainbow_gray(TIME()*1.626))
        setFont(55)
        mStr("Score - "..score,640,290)
        mStr("High Score - "..highScore,640,370)
        mStr("High Floor - "..highFloor,640,450)

        gc.setColor(COLOR.D)
        setFont(35)
        mStr(MOBILE and "Touch to Start" or "Press space to Start",640,570)
        setFont(20)
        gc.print("Original CX-CAS version by MrZ",740,235)
        gc.print("Ported / Rewritten / Balanced by MrZ",740,260)
    end
    if state~='menu' then
        -- High floor
        gc.setColor(COLOR.Z)
        gc.setLineWidth(2)
        local y=690+camY-30*highFloor
        gc.line(0,y,1280,y)

        gc.setLineWidth(6)
        gc.rectangle('line',move.x-3,move.y-3,move.l+6,36)
        gc.rectangle('line',base.x-3,base.y-3,base.l+6,36)

        setFont(45)
        gc.print(floor+1,move.x+move.l+15,move.y-18)
        gc.print(floor,base.x+base.l+15,base.y-18)

        gc.setColor(COLOR.Z)
        mStr(message,640,0)
        gc.setColor(COLOR.D)
        mStr(message,643,2)

        setFont(70)
        gc.setColor(COLOR.Z)
        gc.print(score,60,40)
        gc.setColor(COLOR.D)
        gc.print(score,64,43)

        gc.setColor(color1)gc.rectangle('fill',move.x,move.y,move.l,30)
        gc.setColor(color2)gc.rectangle('fill',base.x,base.y,base.l,30)
    end
end

scene.widgetList={
    WIDGET.newButton{name='back',x=1140,y=60,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
