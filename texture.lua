local N=gc.newImage
function C(x,y)
	c=gc.newCanvas(x,y)
	gc.setCanvas(c)
end
titleImage=N("/image/mess/title.png")
mouseIcon=N("/image/mess/mouseIcon.png")
spinCenter=N("/image/mess/spinCenter.png")
dialCircle=N("/image/mess/dialCircle.png")
dialNeedle=N("/image/mess/dialNeedle.png")
badgeIcon=N("/image/mess/badge.png")

blockSkin={}
local img=N("/image/block/1.png")
for i=1,13 do
	C(30,30)
	gc.draw(img,30-30*i,0)
	blockSkin[i]=c
end
img:release()

background={}
gc.setColor(1,1,1)
background={
	N("/image/BG/bg1.jpg"),
	N("/image/BG/bg2.png"),
}
virtualkeyIcon={}
for i=1,9 do
	virtualkeyIcon[i]=N("/image/virtualkey/"..actName[i]..".png")
end


PTC={dust={}}--Particle systems
C(6,6)
gc.clear(1,1,1)
PTC.dust[0]=gc.newParticleSystem(c,1000)
PTC.dust[0]:setParticleLifetime(.2,.3)
PTC.dust[0]:setEmissionRate(0)
PTC.dust[0]:setLinearAcceleration(-1500,-200,1500,200)
PTC.dust[0]:setColors(1,1,1,.5,1,1,1,0)
c:release()
--Dust particles

PTC.attack={}
PTC.attack[1]=gc.newParticleSystem(gc.newImage("/image/mess/atk1.png"),200)
PTC.attack[1]:setParticleLifetime(.25)
PTC.attack[1]:setEmissionRate(0)
PTC.attack[1]:setSpin(10)
PTC.attack[1]:setColors(1,1,1,.7,1,1,1,0)

PTC.attack[2]=gc.newParticleSystem(gc.newImage("/image/mess/atk2.png"),200)
PTC.attack[2]:setParticleLifetime(.3)
PTC.attack[2]:setEmissionRate(0)
PTC.attack[2]:setSpin(8)
PTC.attack[2]:setColors(1,1,1,.7,1,1,1,0)

PTC.attack[3]=gc.newParticleSystem(gc.newImage("/image/mess/atk3.png"),200)
PTC.attack[3]:setParticleLifetime(.4)
PTC.attack[3]:setEmissionRate(0)
PTC.attack[3]:setSpin(6)
PTC.attack[3]:setColors(1,1,1,.7,1,1,1,0)
--Attack particles

gc.setCanvas()
c=nil