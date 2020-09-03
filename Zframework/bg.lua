local gc=love.graphics
local int,ceil,rnd,abs=math.floor,math.ceil,math.random,math.abs
local max,min,sin,cos=math.max,math.min,math.sin,math.cos
local ins,rem=table.insert,table.remove

local BG
local scr=scr
local BGvars={_G=_G,SHADER=SHADER}

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
		t=0
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
		t=0
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
		t=0
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		local t=.13-t%3%1.7
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
		gc.setDefaultFilter("linear","linear")
		bar=gc.newCanvas(41,1)
		gc.push("transform")
			gc.origin()
			gc.setCanvas(bar)
			for x=0,20 do
				gc.setColor(1,1,1,x/11)
				gc.rectangle("fill",x,0,1,1)
				gc.rectangle("fill",41-x,0,1,1)
			end
			gc.setCanvas()
		gc.pop()
		BG.resize()
	end,
	resize=function()
		crystal={}
		W,H=scr.w,scr.h
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

local _
back.fan={
	init=function()
		fan=_G.title_fan
		t=0
		petal={}
		BG.resize()
	end,
	resize=function()
		CX,CY=scr.w/2,scr.h/2
		W,H=scr.w,scr.h
	end,
	update=function()
		t=t+1
		if t%10==0 then
			ins(petal,{
				x=scr.w*rnd(),
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
		gc.scale(scr.k)
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

back.aura={
	init=function()
		t=rnd()*3600
		BG.resize(scr.w,scr.h)
	end,
	resize=function(w,h)
		SHADER.aura:send("w",scr.W)
		SHADER.aura:send("h",h*scr.dpi)
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		SHADER.aura:send("t",t)
		gc.setShader(SHADER.aura)
		gc.rectangle("fill",0,0,scr.w,scr.h)
		gc.setShader()
	end,
}--Cool liquid background
back.bg1={
	init=function()
		t=0
		BG.resize(scr.w)
	end,
	resize=function(w)
		SHADER.gradient1:send("w",scr.W)
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		SHADER.gradient1:send("t",t)
		gc.setShader(SHADER.gradient1)
		gc.rectangle("fill",0,0,scr.w,scr.h)
		gc.setShader()
	end,
}--Horizonal red-blue gradient
back.bg2={
	init=function()
		t=0
		BG.resize(nil,scr.h)
	end,
	resize=function(w,h)
		SHADER.gradient2:send("h",h*scr.dpi)
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		SHADER.gradient2:send("t",t)
		gc.setShader(SHADER.gradient2)
		gc.rectangle("fill",0,0,scr.w,scr.h)
		gc.setShader()
	end,
}--Vertical red-green gradient
back.rainbow={
	init=function()
		t=0
		BG.resize(scr.w,scr.h)
	end,
	resize=function(w,h)
		SHADER.rgb1:send("w",scr.W)
		SHADER.rgb1:send("h",h*scr.dpi)
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		SHADER.rgb1:send("t",t)
		gc.setShader(SHADER.rgb1)
		gc.rectangle("fill",0,0,scr.w,scr.h)
		gc.setShader()
	end,
}--Colorful RGB
back.rainbow2={
	init=function()
		t=0
		BG.resize(scr.w,scr.h)
	end,
	resize=function(w,h)
		SHADER.rgb2:send("w",scr.W)
		SHADER.rgb2:send("h",h*scr.dpi)
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		SHADER.rgb2:send("t",t)
		gc.setShader(SHADER.rgb2)
		gc.rectangle("fill",0,0,scr.w,scr.h)
		gc.setShader()
	end,
}--Blue RGB
back.lightning={
	init=function()
		t=0
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
local scs=require("parts/spinCenters")
back.lightning2={
	init=function()
		t=0
		colorLib=_G.SKIN.libColor
		colorSet=_G.setting.skin
		blockImg=_G.TEXTURE.miniBlock
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		local t=1.2-t%10%3%1.2
		if t<.3 then gc.clear(t,t,t)
		else gc.clear(0,0,0)
		end
		local R=7-int(t*.5)%7
		local _=colorLib[colorSet[R]]
		gc.setColor(_[1],_[2],_[3],.1)
		gc.draw(blockImg[R],640,360,t%3.1416*6,400,400,scs[R][0][2]-.5,#blocks[R][0]-scs[R][0][1]+.5)
	end,
}--Fast lightning + spining tetromino

local matrixT={}for i=1,50 do matrixT[i]={}for j=1,50 do matrixT[i][j]=love.math.noise(i,j)+2 end end
back.matrix={
	init=function()
		t=rnd()*3600
	end,
	update=function(dt)
		t=t+dt
	end,
	draw=function()
		gc.clear(.15,.15,.15)
		gc.push("transform")
			local k=scr.k
			gc.scale(k)
			local Y=ceil(scr.h/80/k)
			for x=1,ceil(scr.w/80/k)do
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
		W,H=scr.w+20,scr.h+20
		BG.resize(scr.w,scr.h)
	end,
	resize=function(w,h)
		local S=stars
		for i=1,1260,5 do
			local s=rnd(26,40)*.1
			S[i]=s*scr.k			--Size
			S[i+1]=rnd(W)-10		--X
			S[i+2]=rnd(H)-10		--Y
			S[i+3]=(rnd()-.5)*.01*s	--Vx
			S[i+4]=(rnd()-.5)*.01*s	--Vy
		end
	end,
	update=function(dt)
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
	if not bg.init		then bg.init=	NULL end setfenv(bg.init	,BGvars)
	if not bg.resize	then bg.resize=	NULL end setfenv(bg.resize	,BGvars)
	if not bg.update	then bg.update=	NULL end setfenv(bg.update	,BGvars)
	if not bg.draw		then bg.draw=	NULL end setfenv(bg.draw	,BGvars)
	if not bg.event		then bg.event=	NULL end setfenv(bg.event	,BGvars)
	if not bg.discard	then bg.discard=NULL end setfenv(bg.discard	,BGvars)
end

BG={
	cur="none",
	resize=NULL,
	update=NULL,
	draw=back.none.draw,
}
function BG.send(data)
	if BG.event then
		BG.event(data)
	end
end
function BG.set(bg,data)
	if bg==BG.cur or not setting.bg then return end
	if BG.discard then
		BG.discard()
		collectgarbage()
	end
	BG.cur=bg
	bg=back[bg]

	BG.init=bg.init or NULL
	BG.resize=bg.resize or NULL
	BG.update=bg.update or NULL
	BG.draw=bg.draw or NULL
	BG.event=bg.event or NULL
	BG.discard=bg.discard or NULL
	BG.init()
end
return BG