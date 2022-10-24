local gc=love.graphics
local gc_draw,gc_setColor,gc_setLineWidth=gc.draw,gc.setColor,gc.setLineWidth

local max=math.max
local next=next

local SETTING,TIME=SETTING,TIME
local VK_ORG=VK_ORG

local skin=1
local buttonImages={
    GC.DO{200,200,{'setLW',4},{'dCirc',100,100,98},{'dCirc',100,100,90}},
    GC.DO{200,200,{'setLW',4},{'dCirc',100,100,98,8},{'dCirc',100,100,90,8}},
    GC.DO{200,200,{'setLW',4},{'dCirc',100,100,98,6},{'dCirc',100,100,90,6}},
    GC.DO{200,200,{'setLW',4},{'dCirc',100,100,98,4},{'dCirc',100,100,89,4}},
    GC.DO{200,200,{'setLW',4},{'dRect',31,31,138,138},{'dRect',39,39,122,122}},
}
local rippleImages={
    GC.DO{200,200,{'setLW',4},{'dCirc',100,100,98}},
    GC.DO{200,200,{'setLW',4},{'dCirc',100,100,98,8}},
    GC.DO{200,200,{'setLW',4},{'dCirc',100,100,98,6}},
    GC.DO{200,200,{'setLW',4},{'dCirc',100,100,98,4}},
    GC.DO{200,200,{'setLW',4},{'dRect',31,31,138,138}},
}
local holdImages={
    GC.DO{200,200,{'fCirc',100,100,86}},
    GC.DO{200,200,{'fCirc',100,100,86,8}},
    GC.DO{200,200,{'fCirc',100,100,85,6}},
    GC.DO{200,200,{'fCirc',100,100,83,4}},
    GC.DO{200,200,{'fRect',43,43,114,114}},
}

local virtualkeySet={
    {
        {id=1,  x=80,   y=-200, r=80},-- moveLeft
        {id=2,  x=320,  y=-200, r=80},-- moveRight
        {id=3,  x=-80,  y=-200, r=80},-- rotRight
        {id=4,  x=-200, y=-80,  r=80},-- rotLeft
        {id=5,  x=-200, y=-320, r=80},-- rot180
        {id=6,  x=200,  y=-320, r=80},-- hardDrop
        {id=7,  x=200,  y=-80,  r=80},-- softDrop
        {id=8,  x=-320, y=-200, r=80},-- hold
        {id=9,  x=80,   y=280,  r=80},-- func1
        {id=10, x=-80,  y=280,  r=80},-- func2
    },-- Farter's tetr.js set
    {
        {id=1,  x=-320, y=-200, r=80},-- moveLeft
        {id=2,  x=-80,  y=-200, r=80},-- moveRight
        {id=3,  x=200,  y=-80,  r=80},-- rotRight
        {id=4,  x=80,   y=-200, r=80},-- rotLeft
        {id=5,  x=200,  y=-320, r=80},-- rot180
        {id=6,  x=-200, y=-320, r=80},-- hardDrop
        {id=7,  x=-200, y=-80,  r=80},-- softDrop
        {id=8,  x=320,  y=-200, r=80},-- hold
        {id=9,  x=-80,  y=280,  r=80},-- func1
        {id=10, x=80,   y=280,  r=80},-- func2
    },-- Mirrored tetr.js set
    {
        {id=1,  x=80,   y=-80,  r=80},-- moveLeft
        {id=2,  x=240,  y=-80,  r=80},-- moveRight
        {id=3,  x=-240, y=-80,  r=80},-- rotRight
        {id=4,  x=-400, y=-80,  r=80},-- rotLeft
        {id=5,  x=-240, y=-240, r=80},-- rot180
        {id=6,  x=-80,  y=-80,  r=80},-- hardDrop
        {id=7,  x=-80,  y=-240, r=80},-- softDrop
        {id=8,  x=-80,  y=-400, r=80},-- hold
        {id=9,  x=80,   y=-240, r=80},-- func1
        {id=10, x=240,  y=-240, r=80},-- func2
    },-- Author's set, not recommend
    {
        {id=1,  x=-400, y=-80,  r=80},-- moveLeft
        {id=2,  x=-80,  y=-80,  r=80},-- moveRight
        {id=3,  x=240,  y=-80,  r=80},-- rotRight
        {id=4,  x=80,   y=-80,  r=80},-- rotLeft
        {id=5,  x=240,  y=-240, r=80},-- rot180
        {id=6,  x=-240, y=-240, r=80},-- hardDrop
        {id=7,  x=-240, y=-80,  r=80},-- softDrop
        {id=8,  x=400,  y=-80,  r=80},-- hold
        {id=9,  x=80,   y=-240, r=80},-- func1
        {id=10, x=80,   y=-400, r=80},-- func2
    },-- Keyboard set
    {
        {id=9,  x=70,   y=50,   r=30},-- func1
        {id=10, x=130,  y=50,   r=30},-- func2
        {id=4,  x=190,  y=50,   r=30},-- rotLeft
        {id=3,  x=250,  y=50,   r=30},-- rotRight
        {id=5,  x=310,  y=50,   r=30},-- rot180
        {id=1,  x=370,  y=50,   r=30},-- moveLeft
        {id=2,  x=430,  y=50,   r=30},-- moveRight
        {id=8,  x=490,  y=50,   r=30},-- hold
        {id=7,  x=550,  y=50,   r=30},-- softDrop
        {id=6,  x=610,  y=50,   r=30},-- hardDrop
        {id=11, x=670,  y=50,   r=30},-- insLeft
        {id=12, x=730,  y=50,   r=30},-- insRight
        {id=13, x=790,  y=50,   r=30},-- insDown
        {id=14, x=850,  y=50,   r=30},-- down1
        {id=15, x=910,  y=50,   r=30},-- down4
        {id=16, x=970,  y=50,   r=30},-- down10
        {id=17, x=1030, y=50,   r=30},-- dropLeft
        {id=18, x=1090, y=50,   r=30},-- dropRight
        {id=19, x=1150, y=50,   r=30},-- zangiLeft
        {id=20, x=1210, y=50,   r=30},-- zangiRight
    },-- PC key feedback(top&in a row)
}
for _,set in next,virtualkeySet do
    for _,key in next,set do
        if key.x<0 then key.x=1280+key.x end
        if key.y<0 then key.y=720+key.y end
    end
end
-- Virtualkey icons
local VKIcon={}
local VKI=gc.newImage("media/image/virtualkey.png")
for i=1,20 do VKIcon[i]=GC.DO{90,90,{'draw',VKI,(i-1)%5*-90,math.floor((i-1)*.2)*-90}} end
VKI:release()

-- In-game virtualkey layout data
local keys={} for i=1,#VK_ORG do keys[i]={} end

local VK={keys=keys}


function VK.on(x,y)
    local dist,nearest=1e10
    for id,B in next,keys do
        if B.ava then
            local d1=(x-B.x)^2+(y-B.y)^2
            if d1<B.r^2 then
                if d1<dist then
                    nearest,dist=id,d1
                end
            end
        end
    end
    return nearest
end

function VK.touch(id,x,y)
    local B=keys[id]
    B.isDown=true
    B.pressTime=10
    SFX.play('virtualKey',SETTING.VKSFX)
    if SETTING.vib>0 then VIB(SETTING.vib+SETTING.VKVIB) end

    if SETTING.VKTrack then
        -- Auto follow
        local O=VK_ORG[id]
        local _FW,_CW=SETTING.VKTchW,1-SETTING.VKCurW
        local _OW=1-_FW-_CW
        -- (finger+current+origin)
        B.x=x*_FW+B.x*_CW+O.x*_OW
        B.y=y*_FW+B.y*_CW+O.y*_OW

        -- Button collision (not accurate)
        if SETTING.VKDodge then
            for _,b in next,keys do
                local d=B.r+b.r-((B.x-b.x)^2+(B.y-b.y)^2)^.5-- Hit depth(Neg means distance)
                if d>0 then
                    b.x=b.x+(b.x-B.x)*d*b.r*2.6e-5
                    b.y=b.y+(b.y-B.y)*d*b.r*2.6e-5
                end
            end
        end
    end
end

function VK.press(id)
    keys[id].isDown=true
    keys[id].pressTime=10
end

function VK.release(id)
    keys[id].isDown=false
end

function VK.setShape(s)
    skin=s
end
function VK.nextShape()
    skin=skin%#buttonImages+1
    return skin
end

function VK.switchKey(id,on)
    keys[id].ava=on
end

function VK.restore()
    for i=1,#VK_ORG do
        local B,O=keys[i],VK_ORG[i]
        B.ava=O.ava
        B.x=O.x
        B.y=O.y
        B.r=O.r
        B.isDown=false
        B.pressTime=0
    end
    for id,v in next,PLAYERS[1].keyAvailable do
        if not v then
            keys[id].ava=false
        end
    end
end

function VK.changeSet(id)
    local set=virtualkeySet[id]
    for i=1,#VK_ORG do VK_ORG[i].ava=false end
    for n=1,#set do
        local vk=set[n]
        local B=VK_ORG[vk.id]
        B.ava,B.x,B.y,B.r=true,vk.x,vk.y,vk.r
    end
end

function VK.update(dt)
    if SETTING.VKSwitch then
        for _,B in next,keys do
            if B.pressTime>0 then
                B.pressTime=max(B.pressTime-dt*60,0)
            end
        end
    end
end

function VK.draw()
    if not SETTING.VKSwitch then return end
    local a=SETTING.VKAlpha
    local buttonImage=buttonImages[skin]
    local rippleImage=rippleImages[skin]
    local holdImage=holdImages[skin]
    if SETTING.VKIcon then
        for i,B in next,keys do
            if B.ava then
                local r=B.r
                -- Button outline
                gc_setColor(1,1,1,a)
                gc_setLineWidth(r*.07)
                gc_draw(buttonImage,B.x,B.y,nil,r*.01,nil,100,100)

                -- Icon
                local _=B.pressTime
                gc_setColor(1,1,1,a)
                gc_draw(VKIcon[i],B.x,B.y,nil,r*.01+_*.024,nil,45,45)

                -- Ripple
                if _>0 then
                    gc_setColor(1,1,1,a*_*.08)
                    local d=r*(1.4-_*.04)
                    gc_draw(rippleImage,B.x,B.y,nil,d*.01,nil,100,100)
                end

                -- Glow when press
                if B.isDown then
                    gc_setColor(1,1,1,a*.4)
                    gc_draw(holdImage,B.x,B.y,nil,r*.01,nil,100,100)
                end
            end
        end
    else
        for _,B in next,keys do
            if B.ava then
                local r=B.r
                gc_setColor(1,1,1,a)
                gc_setLineWidth(r*.07)
                gc_draw(buttonImage,B.x,B.y,nil,r*.01,nil,100,100)
                local _=B.pressTime
                if _>0 then
                    gc_setColor(1,1,1,a*_*.08)
                    gc_draw(holdImage,B.x,B.y,nil,r*.01,nil,100,100)
                    local d=r*(1.4-_*.04)
                    gc_draw(rippleImage,B.x,B.y,nil,d*.01,nil,100,100)
                end
            end
        end
    end
end
function VK.preview(selected)
    if not SETTING.VKSwitch then return end
    local buttonImage=buttonImages[skin]
    local holdImage=holdImages[skin]
    for i,B in next,VK_ORG do
        if B.ava then
            local r=B.r
            gc_setColor(1,1,1,SETTING.VKAlpha)
            gc_setLineWidth(r*.07)
            gc_draw(buttonImage,B.x,B.y,nil,r*.01,nil,100,100)
            if selected==i and TIME()%.26<.13 then
                gc_setColor(1,1,1,SETTING.VKAlpha*.62)
                gc_draw(holdImage,B.x,B.y,nil,r*.01,nil,100,100)
            end
            if SETTING.VKIcon then
                gc_setColor(1,1,1,SETTING.VKAlpha)
                gc_draw(VKIcon[i],B.x,B.y,nil,r*.01,nil,45,45)
            end
        end
    end
end

return VK
