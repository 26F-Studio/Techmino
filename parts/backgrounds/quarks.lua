local gc=love.graphics
local hsv=COLOR.hsv
local circle,push,pop,rot,translate,setColor=gc.circle,gc.push,gc.pop,gc.rotate,gc.translate,gc.setColor
local rnd,sin,cos,twopi,pow,log,ceil=math.random,math.sin,math.cos,2*math.pi,math.pow,math.log,math.ceil
local back={}

local qX,qY,qdX,qdY={},{},{},{} -- quark data in SoA [size, X, Y, dx, dy, color]
local colors={{1,0,0,.8},{0,1,0,.8},{0,0,1,.8}}

local ptcclr={{1,0,0},{0,1,0},{0,0,1}}
local apcclr={{0,1,1},{1,0,1},{1,1,0}}

local blasts={} -- data about annihilation blasts from particles and antiparticles colliding
local ptc={} -- particle-antiparticle data (antiparticle is a mirror of particle)
local nextpair=math.huge

local W,H,size
local quarkCount=400

local theta,side,x,y,t,p,cutoff -- temp vars for optimization
local function spawnQuarkRandom(i)
    qX[i]=rnd(W)-10             -- X
    qY[i]=rnd(H)-10             -- Y
    theta=rnd()*twopi
    qdX[i]=cos(theta)*300   -- dx
    qdY[i]=sin(theta)*300   -- dy
end
local function spawnQuarkEdge(i)
    side=rnd(4)
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
    theta=rnd()*twopi
    qdX[i]=cos(theta)*300   -- dx
    qdY[i]=sin(theta)*300   -- dy
end
local function spawnParticlePair()
    x,y=rnd(W)-10,rnd(H)-10
    theta=rnd()*twopi
    ptc[#ptc+1]={x=x,y=y,dist=0,theta=theta,v=500, c=rnd(3)}
end
local function spawnBlast(_x,_y)blasts[#blasts+1]={x=_x,y=_y,t=0}end

function back.init()
    qX,qY,qdX,qdY={},{},{},{}
    blasts={}
    ptc={}
    cutoff={ceil(quarkCount/3),ceil(2*quarkCount/3)}
    BG.resize(SCR.w,SCR.h)
end
function back.resize(w,h)
    W,H=w+20,h+20
    for i=1,quarkCount do spawnQuarkRandom(i)end
    size=2.6*SCR.k
end
function back.update(dt)
    local debug_dt=TIME()
    --Move far-away quarks
    for i=1,quarkCount do
        qX[i]=qX[i]+qdX[i]*dt
        qY[i]=qY[i]+qdY[i]*dt
        if qX[i]<SCR.x-26 or qX[i]>SCR.ex+26 or qY[i]<SCR.y-26 or qY[i]>SCR.ey+26 then spawnQuarkEdge(i)end
    end

    --Particle pair attraction & destruction
    for i=1,#ptc do
        p=ptc[i]
        if not p then goto continue end
        p.dist=p.dist+p.v*dt

        p.v=p.v-pow(p.dist,2)*dt

        --Destroy colliding particle pairs
        if p.dist<=10 and p.v<=0 then
            spawnBlast(p.x,p.y)
            for j=i,#ptc do ptc[j]=ptc[j+1]end
            i=i-1
        end
        ::continue::
    end

    --Age blasts, delete old blasts
    for i=1,#blasts do
        if not blasts[i]then goto continue end
        blasts[i].t=blasts[i].t+dt

        if blasts[i].t>=1 then
            for j=i,#blasts do
                blasts[j]=blasts[j+1]
            end
            i=i-1
        end
        ::continue::
    end

    --Spawn particle pairs
    nextpair=nextpair-dt
    if nextpair==math.huge then
        nextpair=rnd()+rnd(0,3)
    elseif nextpair<=0 then
        spawnParticlePair()
        nextpair=rnd()+rnd(0,3)
    end
end
function back.draw()
    local debug_dt=TIME()
    gc.clear(0.08,0.04,0.01)
    translate(-10,-10)
    setColor(1,0,0,.8)
    for i=1,cutoff[1]do circle('fill',qX[i],qY[i],size)end -- draw red quarks
    setColor(0,1,0,.8)
    for i=cutoff[1]+1,cutoff[2]do circle('fill',qX[i],qY[i],size)end -- draw green quarks
    setColor(0,0,1,.8)
    for i=cutoff[2]+1,quarkCount do circle('fill',qX[i],qY[i],size) end -- draw blue quarks
    for i=1,#ptc do
        p=ptc[i]
        push()
            translate(p.x,p.y)rot(p.theta)

            setColor(ptcclr[p.c])
            circle('fill', p.dist,0,4*size)
            setColor(apcclr[p.c])
            circle('fill',-p.dist,0,4*size)
        pop()
    end
    for i=1,#blasts do
        t=blasts[i].t
        setColor(hsv(-80*t,1-1.7*log(5*t,10),1,1-t))
        circle('fill',blasts[i].x,blasts[i].y,40*log(3*t+1.7,3))
    end
    translate(10,10)
end
function back.discard()
    qX,qY,qdX,qdY,qC=nil,nil,nil,nil,nil
    blasts=nil
    ptc=nil
    nextpair=math.huge
    collectgarbage('collect')
end
return back
