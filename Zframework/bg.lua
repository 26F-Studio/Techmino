local gc=love.graphics
local int,ceil,rnd=math.floor,math.ceil,math.random
local max,min,sin=math.max,math.min,math.sin
local ins,rem=table.insert,table.remove

local function NULL(...)end
local SCR=SCR
local BGvars={_G=_G,SHADER=SHADER}
local BG
local back={}
back.none={
	draw=function()
		gc.clear(.15,.15,.15)
	end,
}
back.grey={
	draw=function()
		gc.clear(.3,.3,.3)
	end,
}
back.glow={
	init=function()
		t=rnd()*2600
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		local t=(sin(t*.5)+sin(t*.7)+sin(t*.9+1)+sin(t*1.5)+sin(t*2+10))*.08
		gc.clear(t,t,t)
	end,
}--Light-dark
back.rgb={
	init=function()
		t=rnd()*2600
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		gc.clear(
			sin(t*1.2)*.15+.2,
			sin(t*1.5)*.15+.2,
			sin(t*1.9)*.15+.2
		)
	end,
}--Changing pure color
back.flink={
	init=function()
		t=rnd()*2600
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		local t=.13-t%3%1.9
		if t<.2 then gc.clear(t,t,t)
		else gc.clear(0,0,0)
		end
	end,
}--Flash after random time

local wingColor={
	{0., .9, .9,.626},
	{.3, 1., .3,.626},
	{.9, .9, 0.,.626},
	{1., .5, 0.,.626},
	{1., .3, .3,.626},
	{.5, 0., 1.,.626},
	{.3, .3, 1.,.626},
	{0., .9, .9,.626},
}
back.wing={
	init=function()
		bar=gc.newCanvas(41,1)
		gc.setCanvas(bar)
		gc.push("transform")
		gc.origin()
		for x=0,20 do
			gc.setColor(1,1,1,x/11)
			gc.rectangle("fill",x,0,1,1)
			gc.rectangle("fill",41-x,0,1,1)
		end
		gc.pop()
		gc.setCanvas()
		BG.resize()
	end,
	resize=function()
		crystal={}
		W,H=SCR.w,SCR.h
		for i=1,16 do
			crystal[i]={
				x=i<9 and W*.05*i or W*.05*(28-i),
				y=H*.1,
				a=0,
				va=0,
				f=i<9 and .012-i*.0005 or .012-(17-i)*.0005
			}
		end
	end,
	update=function()
		for i=1,16 do
			local B=crystal[i]
			B.a=B.a+B.va
			B.va=B.va*.986-B.a*B.f
		end
	end,
	draw=function()
		gc.clear(.06,.06,.06)
		local sy=H*.8
		for i=1,8 do
			gc.setColor(wingColor[i])
			local B=crystal[i]
			gc.draw(bar,B.x,B.y,B.a,1,sy,20,0)
			B=crystal[17-i]
			gc.draw(bar,B.x,B.y,B.a,1,sy,20,0)
		end
	end,
	event=function(level)
		for i=1,8 do
			local B=crystal[i]
			B.va=B.va+.001*level*(1+rnd())
			B=crystal[17-i]
			B.va=B.va-.001*level*(1+rnd())
		end
	end,
	discard=function()
		bar,crystal=nil
	end,
}--Flandre's wing

back.fan={
	init=function()
		fan=_G.title_fan
		t=rnd(2600)
		petal={}
		BG.resize()
	end,
	resize=function()
		CX,CY=SCR.w/2,SCR.h/2
		W,H=SCR.w,SCR.h
	end,
	update=function()
		t=t+1
		if t%10==0 then
			ins(petal,{
				x=SCR.w*rnd(),
				y=0,
				vy=2+rnd()*2,
				vx=rnd()*2-.5,
				rx=4+rnd()*4,
				ry=4+rnd()*4,
			})
		end
		for i=#petal,1,-1 do
			local P=petal[i]
			P.y=P.y+P.vy
			if P.y>H then
				rem(petal,i)
			else
				P.x=P.x+P.vx
				P.vx=P.vx+rnd()*.01
				P.rx=max(min(P.rx+rnd()-.5,10),2)
				P.ry=max(min(P.ry+rnd()-.5,10),2)
			end
		end
	end,
	draw=function()
		gc.push("transform")
		gc.translate(CX,CY+20*sin(t*.02))
		gc.scale(SCR.k)
		gc.clear(.1,.1,.1)
		gc.setLineWidth(320)
		gc.setColor(.3,.2,.3)
		gc.arc("line","open",0,420,500,-.8*3.1416,-.2*3.1416)

		gc.setLineWidth(4)
		gc.setColor(.7,.5,.65)
		gc.arc("line","open",0,420,660,-.799*3.1416,-.201*3.1416)
		gc.arc("line","open",0,420,340,-.808*3.1416,-.192*3.1416)
		gc.line(-281,224,-530,30.5)
		gc.line(281,224,530,30.5)

		gc.setLineWidth(6)
		gc.setColor(.55,.5,.6)
		local F=fan
		for i=1,8 do
			gc.polygon("line",F[i])
		end

		gc.setLineWidth(2)
		gc.setColor(.6,.3,.5)
		gc.origin()
		for i=1,#petal do
			local P=petal[i]
			gc.ellipse("fill",P.x,P.y,P.rx,P.ry)
		end
		gc.pop()
	end,
	discard=function()
		petal=nil
	end,
}

local video
back.badapple={
	init=function()
		if not video then
			video=_G.love.data.decompress("string","zlib",_G.love.filesystem.read("Zframework/badapple.dat"))
		end
		t=0
		BG.resize()
	end,
	resize=function()
		local W,H=SCR.w,SCR.h
		if H/W>=20/27 then
			K=W/27
			X,Y=0,(H-W*20/27)*.5
		else
			K=H/20
			X,Y=(W-H*27/20)*.5,0
		end
	end,
	update=function()
		t=t+1
		if t==1404*6 then
			t=0
		end
	end,
	draw=function()
		gc.clear(.2,.2,.2)
		gc.push("transform")
		gc.origin()
		gc.translate(X,Y)
		gc.scale(K)
		gc.setColor(.4,.4,.4)
		local t=int(t/6)
		for i=0,539 do
			if video:byte(540*t+i+1)==48 then
				gc.rectangle("fill",(i%27),int(i/27),1,1)
			end
		end
		gc.pop()
	end,
	discard=function()
		video=nil
	end
}

back.welcome={
	init=function()
		t=rnd()*2600
		txt=gc.newText(_G.getFont(80),"Welcome To Techmino")
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		if -t%13.55<.1 then
			gc.clear(.2+.1*sin(t),.2+.1*sin(1.26*t),.2+.1*sin(1.626*t))
		else
			gc.clear(.1,.1,.1)
		end
		gc.push("transform")
		gc.replaceTransform(_G.xOy)
		gc.translate(640,360)
		if -t%18.26<1 then
			gc.scale(6.26)
			gc.translate(-t*400%800-400,0)
		else
			gc.scale(1.1626,1.26)
		end
		if -t%12.6<.1 then
			gc.translate(60*sin(t*.26),100*sin(t*.626))
		end
		if -t%16.26<.1 then
			gc.rotate(t+5*sin(.26*t)+5*sin(.626*t))
		end
		gc.setColor(.2,.3,.5)
		gc.draw(txt,-883*.5+4*sin(t*.7942),-110*.5+4*sin(t*.7355))
		gc.setColor(.4,.6,.8)
		gc.draw(txt,-883*.5+2*sin(t*.77023),-110*.5+2*sin(t*.7026))
		gc.setColor(.9,.9,.9)
		gc.draw(txt,-883*.5+3*sin(t*.7283),-110*.5+3*sin(t*.7626))
		gc.pop()
	end,
}

back.aura={
	init=function()
		t=rnd()*2600
		BG.resize(SCR.w,SCR.h)
	end,
	resize=function(_,h)
		SHADER.aura:send("w",SCR.W)
		SHADER.aura:send("h",h*SCR.dpi)
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		SHADER.aura:send("t",t)
		gc.setShader(SHADER.aura)
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
		gc.setShader()
	end,
}--Cool liquid background
back.bg1={
	init=function()
		t=rnd()*2600
		BG.resize()
	end,
	resize=function()
		SHADER.gradient1:send("w",SCR.W)
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		SHADER.gradient1:send("t",t)
		gc.setShader(SHADER.gradient1)
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
		gc.setShader()
	end,
}--Horizonal red-blue gradient
back.bg2={
	init=function()
		t=rnd()*2600
		BG.resize(nil,SCR.h)
	end,
	resize=function(_,h)
		SHADER.gradient2:send("h",h*SCR.dpi)
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		SHADER.gradient2:send("t",t)
		gc.setShader(SHADER.gradient2)
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
		gc.setShader()
	end,
}--Vertical red-green gradient
back.rainbow={
	init=function()
		t=rnd()*2600
		BG.resize(SCR.w,SCR.h)
	end,
	resize=function(_,h)
		SHADER.rgb1:send("w",SCR.W)
		SHADER.rgb1:send("h",h*SCR.dpi)
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		SHADER.rgb1:send("t",t)
		gc.setShader(SHADER.rgb1)
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
		gc.setShader()
	end,
}--Colorful RGB
back.rainbow2={
	init=function()
		t=rnd()*2600
		BG.resize(SCR.w,SCR.h)
	end,
	resize=function(_,h)
		SHADER.rgb2:send("w",SCR.W)
		SHADER.rgb2:send("h",h*SCR.dpi)
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		SHADER.rgb2:send("t",t)
		gc.setShader(SHADER.rgb2)
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
		gc.setShader()
	end,
}--Blue RGB
back.lightning={
	init=function()
		t=rnd()*2600
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		local t=2.5-t%20%6%2.5
		if t<.3 then gc.clear(t,t,t)
		else gc.clear(0,0,0)
		end
	end,
}--Lightning

local blocks=require("parts/mino")
back.lightning2={
	init=function()
		t=rnd()*2600
		colorLib=_G.SKIN.libColor
		colorSet=_G.SETTING.skin
		blockImg=_G.TEXTURE.miniBlock
		scs=_G.spinCenters
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		local R=7-int(t*.5%7)
		local T=1.2-t%10%3%1.2
		if T<.3 then gc.clear(T,T,T)
		else gc.clear(0,0,0)
		end
		local _=colorLib[colorSet[R]]
		gc.setColor(_[1],_[2],_[3],.12)
		gc.draw(blockImg[R],640,360,t%3.1416*6,400,400,scs[R][0][2]+.5,#blocks[R][0]-scs[R][0][1]-.5)
	end,
}--Fast lightning + spining tetromino

local matrixT={}for i=1,50 do matrixT[i]={}for j=1,50 do matrixT[i][j]=love.math.noise(i,j)+2 end end
back.matrix={
	init=function()
		t=rnd()*2600
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		gc.clear(.15,.15,.15)
		gc.push("transform")
			local k=SCR.k
			gc.scale(k)
			local Y=ceil(SCR.h/80/k)
			for x=1,ceil(SCR.w/80/k)do
				for y=1,Y do
					gc.setColor(1,1,1,sin(x+matrixT[x][y]*t)*.1+.1)
					gc.rectangle("fill",80*x,80*y,-80,-80)
				end
			end
		gc.pop()
	end,
}

back.space={
	init=function()
		stars={}
		W,H=SCR.w+20,SCR.h+20
		BG.resize(SCR.w,SCR.h)
	end,
	resize=function()
		local S=stars
		for i=1,1260,5 do
			local s=rnd(26,40)*.1
			S[i]=s*SCR.k			--Size
			S[i+1]=rnd(W)-10		--X
			S[i+2]=rnd(H)-10		--Y
			S[i+3]=(rnd()-.5)*.01*s	--Vx
			S[i+4]=(rnd()-.5)*.01*s	--Vy
		end
	end,
	update=function()
		local S=stars
		--Star moving
		for i=1,1260,5 do
			S[i+1]=(S[i+1]+S[i+3])%W
			S[i+2]=(S[i+2]+S[i+4])%H
		end
	end,
	draw=function()
		gc.clear(.2,.2,.2)
		if not stars[1]then return end
		gc.translate(-10,-10)
		gc.setColor(.8,.8,.8)
		for i=1,1260,5 do
			local s=stars
			local x,y=s[i+1],s[i+2]
			s=s[i]
			gc.rectangle("fill",x,y,s,s)
		end
		gc.translate(10,10)
	end,
	discard=function()
		stars=nil
	end,
}

--Make BG vars invisible
for _,bg in next,back do
	if bg.init then		setfenv(bg.init,	BGvars)else bg.init=NULL	end
	if bg.resize then	setfenv(bg.resize,	BGvars)else bg.resize=NULL	end
	if bg.update then	setfenv(bg.update,	BGvars)else bg.update=NULL	end
	if bg.draw then		setfenv(bg.draw,	BGvars)else bg.draw=NULL	end
	if bg.event then	setfenv(bg.event,	BGvars)else bg.event=NULL	end
	if bg.discard then	setfenv(bg.discard,	BGvars)else bg.discard=NULL	end
end

BG={
	cur="none",
	init=NULL,
	resize=NULL,
	update=NULL,
	draw=back.none.draw,
	event=NULL,
	discard=NULL,
}
function BG.send(data)
	if BG.event then
		BG.event(data)
	end
end
function BG.set(bg)
	if bg==BG.cur or not SETTING.bg then return end
	BG.discard()
	if not back[bg]then
		LOG.print("No BG called"..bg,"warn")
		return
	end
	BG.cur=bg
	bg=back[bg]

	BG.init=	bg.init
	BG.resize=	bg.resize
	BG.update=	bg.update
	BG.draw=	bg.draw
	BG.event=	bg.event
	BG.discard=	bg.discard
	BG.init()
end
return BG