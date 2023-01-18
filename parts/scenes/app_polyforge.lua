local gc=love.graphics
local rnd,sin,cos=math.random,math.sin,math.cos
local setFont,mStr=FONT.set,GC.mStr

local tau=math.pi*2

local state
local timer
local ang,pos
local hit,dist
local side,count
local needReset

local function new()
    if needReset then
        side=math.max(side-2,6)
        needReset=false
    else
        side=side+1
    end
    count=0
    for c=1,side do
        hit[c]=0
        dist[c]=rnd(80,270)+637.5
    end
end

local scene={}

function scene.enter()
    state=0
    ang,pos=0,-tau/4
    timer=50
    hit,dist={},{}
    side=rnd(3,6)*2
    needReset=true
    for c=1,side,2 do
        hit[c],hit[c+1]=rnd(2),rnd(2)
        dist[c],dist[c+1]=226,126
    end
    BG.set('none')
    BGM.play('dream')
end

function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='escape' then
        if tryBack() then
            SCN.back()
        end
    elseif key=='space' then
        if state==0 then-- main
            if timer==0 then
                state=1
            end
        elseif state==3 then-- play
            local c=(math.floor((pos-ang)*side/tau)-1)%side+1
            if hit[c]==0 then
                hit[c]=1
                count=count+1
                SFX.play(side<26 and 'ren_'..rnd(5) or 'ren_'..rnd(6,11))
                if count>=12 then
                    SFX.play('ren_mega',(count-11)/15)
                end
                if count==side then
                    state=1
                    SFX.play('spin_0')
                else
                    SFX.play('lock')
                end
            else
                hit[c]=2
                SFX.play('emit')
                needReset=true
                state=1
            end
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
    if state==0 then-- main
        ang=ang-.02
        if ang>0 then ang=ang-tau end
        if pos<ang then pos=pos+tau end
        if timer>0 then timer=timer-1 end
    elseif state==1 or state==2 then-- zoom
        ang=ang+.02+timer/260
        pos=pos-.016
        if ang>0 then ang=ang-tau end
        if pos<ang then pos=pos+tau end
        if state==1 then
            for c=1,side do
                dist[c]=dist[c]+timer/2
            end
            timer=timer+1
            if timer==50 then
                state=2
                new()
            end
        else
            for c=1,side do
                dist[c]=dist[c]-timer/2
            end
            timer=timer-1
            if timer==0 then
                state=3
            end
        end
    elseif state==3 then-- play
        ang=ang+.02
        pos=pos-.016
        if ang>0 then
            ang=ang-tau
        end
        if pos<ang then
            pos=pos+tau
        end
    end
end

function scene.draw()
    gc.clear(.9,.9,.9)
    gc.setColor(0,0,0,1-timer/50)
    setFont(80)
    mStr(side,640,300)
    gc.polygon('fill',
        640+cos(pos-.03)*300,360+sin(pos-.03)*300,
        640+cos(pos)*285,360+sin(pos)*285,
        640+cos(pos+.03)*300,360+sin(pos+.03)*300
    )
    gc.setLineWidth(4)
    for i=1,side do
        local dx=cos(ang+tau*i/side)*dist[i]
        local dy=sin(ang+tau*i/side)*dist[i]
        local dX=cos(ang+tau*(i%side+1)/side)*dist[i%side+1]
        local dY=sin(ang+tau*(i%side+1)/side)*dist[i%side+1]
        gc.setColor(0,0,0,.12)
        gc.line(640,360,640+dx,360+dy)
        if hit[i]==0 then gc.setColor(0,0,0,.3)
        elseif hit[i]==1 then gc.setColor(.8,0,0)
        elseif hit[i]==2 then gc.setColor(.4,0,.8)
        end
        gc.line(640+dx,360+dy,640+dX,360+dY)
    end
    if state==0 then
        gc.setColor(0,0,0,1-timer/50)
        setFont(30)
        mStr(MOBILE and "Touch to Start" or "Press space to Start",640,630)
    else
        gc.setColor(0,0,0,timer/50)
        gc.print("POLYFORGE",20,620)
        setFont(30)
        gc.printf("Idea by ImpactBlue Studios",0,630,1260,'right')
        gc.printf("n-Spire ver. & ported & improved by MrZ",0,670,1260,'right')
    end
end

scene.widgetList={
    WIDGET.newKey{name='back',x=1140,y=60,w=170,h=80,color='D',sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
