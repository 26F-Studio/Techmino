local gc=love.graphics
local hsv=COLOR.hsv
local circle,push,pop,rot,translate,setColor=gc.circle,gc.push,gc.pop,gc.rotate,gc.translate,gc.setColor
local rnd,sin,cos,log=math.random,math.sin,math.cos,math.log
local back={}

local qX,qY,qdX,qdY={},{},{},{} -- quark data in SoA [size, X, Y, dx, dy, color]

local ptcclr={{1,0,0,.5},{0,1,0,.5},{0,0,1,.5}}
local apcclr={{0,1,1,.5},{1,0,1,.5},{1,1,0,.5}}

local blasts={} -- data about annihilation blasts from particles and antiparticles colliding
local ptc={} -- particle-antiparticle data (antiparticle is a mirror of particle)
local nextpair

local W,H,size
local quarkCount=400

local function spawnQuarkRandom(i)
    qX[i]=rnd(W)-10         -- X
    qY[i]=rnd(H)-10         -- Y
    local theta=rnd()*MATH.tau
    qdX[i]=cos(theta)*300   -- dx
    qdY[i]=sin(theta)*300   -- dy
end
local function spawnQuarkEdge(i)
    local side=rnd(4)
    if side==1 then -- Up edge of screen
        qX[i]=rnd(SCR.x-10,SCR.ex+10)
        qY[i]=SCR.y-10
    elseif side==2 then -- Right edge of screen
        qX[i]=SCR.ex+10
        qY[i]=rnd(SCR.y-10,SCR.ey+10)
    elseif side==3 then -- Down edge of screen
        qX[i]=rnd(SCR.x-10,SCR.ex+10)
        qY[i]=SCR.ey+10
    elseif side==4 then -- Left edge of screen
        qX[i]=SCR.x-10
        qY[i]=rnd(SCR.y-10,SCR.ey+10)
    end
    local theta=rnd()*MATH.tau
    qdX[i]=cos(theta)*300 -- dx
    qdY[i]=sin(theta)*300 -- dy
end
local function spawnParticlePair()
    ptc[#ptc+1]={
        x=rnd(W)-10,
        y=rnd(H)-10,
        dist=0,
        theta=rnd()*MATH.tau,
        v=500,
        c=rnd(3),
    }
end
local function spawnBlast(_x,_y)
    blasts[#blasts+1]={x=_x,y=_y,t=0}
end

function back.init()
    qX,qY,qdX,qdY={},{},{},{}
    blasts={}
    ptc={}
    nextpair=0
    BG.resize(SCR.w,SCR.h)
end
function back.resize(w,h)
    W,H=w+20,h+20
    for i=1,quarkCount do spawnQuarkRandom(i) end
    size=2.6*SCR.k
end
function back.update(dt)
    -- Move far-away quarks
    for i=1,quarkCount do
        qX[i]=qX[i]+qdX[i]*dt
        qY[i]=qY[i]+qdY[i]*dt
        if qX[i]<SCR.x-26 or qX[i]>SCR.ex+26 or qY[i]<SCR.y-26 or qY[i]>SCR.ey+26 then
            spawnQuarkEdge(i)
        end
    end

    -- Particle pair attraction & destruction
    for i=#ptc,1,-1 do
        local p=ptc[i]
        if p then
            p.dist=p.dist+p.v*dt
            p.v=p.v-p.dist^2*dt

            -- Destroy colliding particle pairs
            if p.dist<=10 and p.v<=0 then
                spawnBlast(p.x,p.y)
                table.remove(ptc,i)
            end
        end
    end

    -- Age blasts, delete old blasts
    for i=#blasts,1,-1 do
        if blasts[i] then
            blasts[i].t=blasts[i].t+dt
            if blasts[i].t>=1 then
                table.remove(blasts,i)
            end
        end
    end

    -- Spawn particle pairs
    nextpair=nextpair-dt
    if nextpair<=0 then
        spawnParticlePair()
        nextpair=rnd()*4
    end
end
function back.draw()
    gc.clear(.08,.04,.01)
    translate(-10,-10)

    -- Draw quarks in R/G/B
    setColor(1,0,0,.5) for i=1,                           math.floor(quarkCount/3)   do circle('fill',qX[i],qY[i],size) end
    setColor(0,1,0,.5) for i=math.floor(quarkCount/3)+1,  math.floor(quarkCount*2/3) do circle('fill',qX[i],qY[i],size) end
    setColor(0,0,1,.5) for i=math.floor(quarkCount*2/3)+1,quarkCount                 do circle('fill',qX[i],qY[i],size) end

    for i=1,#ptc do
        local p=ptc[i]
        push()
            translate(p.x,p.y)
            rot(p.theta)

            setColor(ptcclr[p.c])
            circle('fill', p.dist,0,4*size)
            setColor(apcclr[p.c])
            circle('fill',-p.dist,0,4*size)
        pop()
    end
    for i=1,#blasts do
        local t=blasts[i].t
        setColor(hsv(-80*t,1-1.7*log(5*t,10),1,1-t))
        circle('fill',blasts[i].x,blasts[i].y,62*t^.3)
    end
end
function back.discard()
    qX,qY,qdX,qdY,qC=nil
    ptc,blasts=nil
    collectgarbage()
end
return back
