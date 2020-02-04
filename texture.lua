local N=gc.newImage
function C(x,y)
	c=gc.newCanvas(x,y)
	gc.setCanvas(c)
	return c
end

gc.setDefaultFilter("nearest","nearest")
	miniTitle=C(26,14)
	gc.setColor(1,1,1)
	for i=1,#miniTitle_pixel do
		gc.rectangle("fill",unpack(miniTitle_pixel[i]))
	end
gc.setDefaultFilter("linear","linear")
	titleImage=N("/image/mess/title.png")
	spinCenter=N("/image/mess/spinCenter.png")
	dialCircle=N("/image/mess/dialCircle.png")
	dialNeedle=N("/image/mess/dialNeedle.png")
	badgeIcon=N("/image/mess/badge.png")


RCPB={10,33,200,33,105,5,105,60}
do royaleCtrlPad=C(300,100)
	gc.setColor(1,1,1)
	setFont(25)
	gc.setLineWidth(2)
	for i=1,4 do
		gc.rectangle("line",RCPB[2*i-1],RCPB[2*i],90,35,8,4)
		mStr(atkModeName[i],RCPB[2*i-1]+45,RCPB[2*i]+6)
	end
end

do local img=N("/image/block/1.png")
	blockSkin,blockSkinmini={},{}
	for i=1,13 do
		C(30,30)
		gc.draw(img,30-30*i,0)
		blockSkin[i]=c
		C(12,12)
		gc.draw(img,12-12*i,0,nil,.4)
		blockSkinmini[i]=c
	end
	img:release()
end

background={
	N("/image/BG/bg1.jpg"),
	N("/image/BG/bg2.png"),
}
gc.setDefaultFilter("nearest","nearest")

virtualkeyIcon={}
for i=1,10 do
	virtualkeyIcon[i]=N("/image/virtualkey/"..actName[i]..".png")
end

gc.setColor(1,1,1)
mouseBlock={}
for i=1,7 do
	local b=blocks[i][0]
	mouseBlock[i]=C(#b[1],#b)
	gc.setColor(blockColor[i])
	for x=1,#b[1]do for y=1,#b do
		if b[y][x]==1 then
			gc.rectangle("fill",x-1,#b-y,1,1)
		end
	end end
end

PTC={dust={}}--Particle systems
C(6,6)
gc.clear(1,1,1)
PTC.dust0=gc.newParticleSystem(c,1000)
PTC.dust0:setParticleLifetime(.2,.3)
PTC.dust0:setEmissionRate(0)
PTC.dust0:setLinearAcceleration(-1500,-200,1500,200)
PTC.dust0:setColors(1,1,1,.5,1,1,1,0)
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

c=nil
gc.setCanvas()
gc.setDefaultFilter("linear","linear")