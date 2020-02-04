local N=gc.newImage
function C(x,y)
	c=gc.newCanvas(x,y)
	gc.setCanvas(c)
	return c
end

gc.setDefaultFilter("nearest","nearest")

local blockImg=N("/image/block/1.png")
blockSkin,blockSkinmini={},{}
for i=1,13 do
	C(30,30)
	gc.draw(blockImg,30-30*i,0)
	blockSkin[i]=c
	C(6,6)
	gc.draw(blockImg,6-6*i,0,nil,.2)
	blockSkinmini[i]=c
end
for i=1,13 do
end
blockImg:release()

RCPB={10,33,200,33,105,5,105,60}
do royaleCtrlPad=C(300,100)
	gc.setColor(1,1,1)
	setFont(25)
	gc.setLineWidth(2)
	for i=1,4 do
		gc.rectangle("line",RCPB[2*i-1],RCPB[2*i],90,35,8,4)
		mStr(atkModeName[i],RCPB[2*i-1]+45,RCPB[2*i]+3)
	end
end

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
PTC.attack[1]=gc.newParticleSystem(N("/image/mess/atk1.png"),200)
PTC.attack[1]:setParticleLifetime(.25)
PTC.attack[1]:setEmissionRate(0)
PTC.attack[1]:setSpin(10)
PTC.attack[1]:setColors(1,1,1,.7,1,1,1,0)

PTC.attack[2]=gc.newParticleSystem(N("/image/mess/atk2.png"),200)
PTC.attack[2]:setParticleLifetime(.3)
PTC.attack[2]:setEmissionRate(0)
PTC.attack[2]:setSpin(8)
PTC.attack[2]:setColors(1,1,1,.7,1,1,1,0)

PTC.attack[3]=gc.newParticleSystem(N("/image/mess/atk3.png"),200)
PTC.attack[3]:setParticleLifetime(.4)
PTC.attack[3]:setEmissionRate(0)
PTC.attack[3]:setSpin(6)
PTC.attack[3]:setColors(1,1,1,.7,1,1,1,0)
--Attack particles

gc.setDefaultFilter("linear","linear")
titleImage=N("/image/mess/title.png")
dialCircle=N("/image/mess/dialCircle.png")
dialNeedle=N("/image/mess/dialNeedle.png")
badgeIcon=N("/image/mess/badge.png")
spinCenter=N("/image/mess/spinCenter.png")
background1=N("/image/BG/bg1.jpg")
background2=N("/image/BG/bg2.png")

c=nil
gc.setCanvas()

sceneInit={
	load=function()
		curBG="none"
		keeprun=true
		loading=1--Loading mode
		loadnum=1--Loading counter
		loadprogress=0--Loading bar(0~1)
	end,
	intro=function()
		curBG="none"
		count=0
		keeprun=true
	end,
	main=function()
		curBG="none"
		keeprun=true
		collectgarbage()
	end,
	mode=function()
		saveData()
		modeSel=modeSel or 1
		levelSel=levelSel or 3
		curBG="none"
		keeprun=true
	end,
	custom=function()
		optSel=optSel or 1
		curBG="matrix"
		keeprun=true
	end,
	play=function()
		keeprun=false
		resetGameData()
		sysSFX("ready")
		mouseShow=false
	end,
	setting=function()
		curBG="none"
		keeprun=true
	end,
	setting2=function()
		curBG="none"
		keeprun=true
			curBoard=1
			keyboardSet=1
			joystickSet=1
			keyboardSetting=false
			joystickSetting=false
	end,--Control settings
	setting3=function()
		curBG="game1"
		keeprun=true
		defaultSel=1
		sel=nil
		snapLevel=1
	end,--Touch setting
	help=function()
		curBG="none"
		keeprun=true
	end,
	stat=function()
		curBG="none"
		keeprun=true
	end,
	quit=function()
		love.event.quit()
	end,
}