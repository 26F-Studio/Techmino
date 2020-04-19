local gc=love.graphics
local int,ceil,rnd,abs=math.floor,math.ceil,math.random,math.abs
local max,min,sin,cos=math.max,math.min,math.sin,math.cos

local scr=scr

local BGinit,BGresize,BGupdate,BGdraw,BGdiscard={},{},{},{},{}
local BGvars={_G=_G}

function BGdraw.none()
	gc.clear(.15,.15,.15)
end

function BGdraw.grey()
	gc.clear(.3,.3,.3)
end

function BGinit.glow()
	t=0
end
function BGupdate.glow(dt)
	t=t+dt
end
function BGdraw.glow()
	local t=(sin(t*.5)+sin(t*.7)+sin(t*.9+1)+sin(t*1.5)+sin(t*2+10))*.08
	gc.clear(t,t,t)
end

function BGinit.rgb()
	t=0
end
function BGupdate.rgb(dt)
	t=t+dt
end
function BGdraw.rgb()
	gc.clear(
		sin(t*1.2)*.15+.2,
		sin(t*1.5)*.15+.2,
		sin(t*1.9)*.15+.2
	)
end

function BGinit.strap()
	t=0
	img=_G.IMG.gameBG2
end
function BGupdate.strap(dt)
	t=t+dt
end
function BGdraw.strap()
	gc.setColor(.5,.5,.5)
	local x=t%16*-64
	::L::
	gc.draw(img,x,0,nil,8,scr.h)
	x=x+1024--image width*8
	if x<scr.w then goto L end
end

function BGinit.flink()
	t=0
end
function BGupdate.flink(dt)
	t=t+dt
end
function BGdraw.flink()
	local t=.13-t%3%1.7
	if t<.2 then gc.clear(t,t,t)
	else gc.clear(0,0,0)
	end
end

function BGinit.game1()
	t=0
	img=_G.IMG.gameBG1
end
function BGupdate.game1(dt)
	t=t+dt
end
function BGdraw.game1()
	gc.setColor(.5,.5,.5)
	gc.draw(img,scr.w*.5,scr.h*.5,t*.15,scr.rad*.0625,nil,16,16)
end--Rainbow

function BGinit.game2()
	t=0
	img=_G.IMG.gameBG1
end
function BGupdate.game2(dt)
	t=t+dt
end
function BGdraw.game2()
	gc.setColor(.5,.26,.26)
	gc.draw(img,scr.w*.5,scr.h*.5,t*.15,scr.rad*.0625,nil,16,16)
end--Red rainbow

function BGinit.game3()
	t=0
	img=_G.IMG.gameBG1
end
function BGupdate.game3(dt)
	t=t+dt
end
function BGdraw.game3()
	gc.setColor(.4,.4,.8)
	gc.draw(img,scr.w*.5,scr.h*.5,t*.15,scr.rad*.0625,nil,16,16)
end--Blue rainbow

function BGinit.game4()
	t=0
	img=_G.IMG.gameBG2
end
function BGupdate.game4(dt)
	t=t+dt
end
function BGdraw.game4()
	gc.setColor(.05,.4,.4)
	local x=t%8*-128
	::L::
	gc.draw(img,x,0,nil,8,scr.h)
	x=x+1024--image width*8
	if x<scr.w then goto L end
end--Fast strap

function BGinit.game5()
	t=0
end
function BGupdate.game5(dt)
	t=t+dt
end
function BGdraw.game5()
	local t=2.5-t%20%6%2.5
	if t<.3 then gc.clear(t,t,t)
	else gc.clear(0,0,0)
	end
end--Lightning

function BGinit.game6()
	t=0
	colorLib=_G.skin.libColor
	colorSet=_G.setting.skin
	miniBlock=_G.miniBlock
end
function BGupdate.game6(dt)
	t=t+dt
end
local blocks=require("parts/mino")
local scs=require("parts/spinCenters")
function BGdraw.game6()
	local t=1.2-t%10%3%1.2
	if t<.3 then gc.clear(t,t,t)
	else gc.clear(0,0,0)
	end
	local R=7-int(t*.5)%7
	local _=colorLib[colorSet[R]]
	gc.setColor(_[1],_[2],_[3],.1)
	gc.draw(miniBlock[R],640,360,t%3.1416*6,400,400,scs[R][0][2]-.5,#blocks[R][0]-scs[R][0][1]+.5)
end--Fast lightning&spining tetromino

local matrixT={}for i=1,50 do matrixT[i]={}for j=1,50 do matrixT[i][j]=love.math.noise(i,j)+2 end end
function BGinit.matrix()
	t=0
end
function BGupdate.matrix(dt)
	t=t+dt
end
function BGdraw.matrix()
	gc.scale(scr.k)
	gc.clear(.15,.15,.15)
	local _=ceil(scr.h/80)
	for i=1,ceil(scr.w/80)do
		for j=1,_ do
			gc.setColor(1,1,1,sin(matrixT[i][j]*t)*.1+.1)
			gc.rectangle("fill",80*i,80*j,-80,-80)
		end
	end
	gc.scale(1/scr.k)
end


function BGinit.space()
	stars={}
	for i=1,2600,5 do
		local s=0.75*2^(rnd()*1.5)
		stars[i]=s					--size
		stars[i+1]=rnd(W)			--x
		stars[i+2]=rnd(H)			--y
		stars[i+3]=(rnd()-.5)*.01*s	--vx
		stars[i+4]=(rnd()-.5)*.01*s	--vy
	end--800 var
end
function BGresize.space(w,h)
	W,H=w+100,h+100
end
function BGupdate.space(dt)
	for i=1,2600,5 do
		stars[i+1]=(stars[i+1]+stars[i+3])%W
		stars[i+2]=(stars[i+2]+stars[i+4])%H
	end--star moving
end

function BGdraw.space()
	gc.clear(.2,.2,.2)
	if not stars[1]then return end
	gc.translate(-50,-50)
	gc.setColor(.8,.8,.8)
	for i=1,2600,5 do
		local x,y=stars[i+1],stars[i+2]
		gc.circle("fill",x,y,stars[i])
	end
	gc.translate(50,50)
end
function BGdiscard.space()
	stars={}
end

for k in next,BGdraw do
	if BGinit[k]then 	setfenv(BGinit[k],		BGvars)end
	if BGresize[k]then 	setfenv(BGresize[k],	BGvars)end
	if BGupdate[k]then 	setfenv(BGupdate[k],	BGvars)end
	if BGdraw[k]then 	setfenv(BGdraw[k],		BGvars)end
	if BGdiscard[k]then setfenv(BGdiscard[k],	BGvars)end
end

local BG={
	cur="none",
	resize=NULL,
	update=NULL,
	draw=BGdraw.none,
}
function BG.set(bg)
	if bg==BG.cur or not setting.bg then return end
	BG.cur=bg
	local _=BGdiscard[BG.cur]if _ then _()collectgarbage()end
	BG.resize=BGresize[bg]or NULL;BG.resize(scr.w,scr.h)
	_=BGinit[bg]if _ then _()end
	BG.update=BGupdate[bg]or NULL
	BG.draw=BGdraw[bg]
end

return BG