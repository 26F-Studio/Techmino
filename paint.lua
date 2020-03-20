local gc=love.graphics
local setFont=setFont
local int,ceil,rnd,abs=math.floor,math.ceil,math.random,math.abs
local max,min,sin=math.max,math.min,math.sin
local format=string.format

local Timer=love.timer.getTime
local mStr=mStr
local scr=scr
local scs=require("parts/spinCenters")
local modeRankColor={
	color.bronze,		--Rank1
	color.lightGrey,	--Rank2
	color.lightYellow,	--Rank3
	color.lightMagenta,	--Rank4
	color.lightCyan,	--Rank5
	color.purple,		--Special
}
local miniTitle_rect={
	{2,0,5,1},{4,1,1,6},
	{9,0,4,1},{9,3,4,1},{9,6,4,1},{8,0,1,7},
	{15,0,3,1},{15,6,3,1},{14,0,1,7},
	{19,0,1,7},{23,0,1,7},{20,3,3,1},
	{0,8,1,6},{6,8,1,6},{1,9,1,1},{2,10,1,1},{3,11,1,1},{4,10,1,1},{5,9,1,1},
	{8,8,5,1},{8,13,5,1},{10,9,1,4},
	{14,8,1,6},{19,8,1,6},{15,9,1,1},{16,10,1,1},{17,11,1,1},{18,12,1,1},
	{21,8,5,1},{21,13,5,1},{21,9,1,4},{25,9,1,4},
}
local function stencil_miniTitle()
	for i=1,#miniTitle_rect do
		local a,b,c,d=unpack(miniTitle_rect[i])
		gc.rectangle("fill",250+a*30,150+b*30,c*30,d*30)
	end
end

FX_attack={}--Attack beam
FX_badge={}--Badge thrown
sysFX={}
local function drawAtkPointer(x,y)
	local t=sin(Timer()*20)
	gc.setColor(.2,.7+t*.2,1,.6+t*.4)
	gc.circle("fill",x,y,25,6)
	local a=Timer()*3%1*.8
	gc.setColor(0,.6,1,.8-a)
	gc.circle("line",x,y,30*(1+a),6)
end
local function VirtualkeyPreview()
	if setting.VKSwitch then
		for i=1,#VK_org do
			local B=VK_org[i]
			if B.ava then
				local c=sceneTemp.sel==i and .6 or 1
				gc.setColor(c,1,c,setting.VKAlpha*.1)
				gc.setLineWidth(B.r*.07)
				gc.circle("line",B.x,B.y,B.r)
				if setting.VKIcon then gc.draw(VKIcon[i],B.x,B.y,nil,B.r*.025,nil,18,18)end
			end
		end
	end
end
local function drawVirtualkey()
	local V=virtualkey
	local a=setting.VKAlpha*.1
	if setting.VKIcon then
		for i=1,#V do
			if V[i].ava then
				local B=V[i]
				gc.setColor(1,1,1,a)
				gc.setLineWidth(B.r*.07)
				gc.circle("line",B.x,B.y,B.r)--Button outline
				local _=V[i].pressTime
				gc.draw(VKIcon[i],B.x,B.y,nil,B.r*.026+_*.08,nil,18,18)--icon
				if _>0 then
					gc.setColor(1,1,1,a*_*.08)
					gc.circle("fill",B.x,B.y,B.r*.94)--Glow
					gc.circle("line",B.x,B.y,B.r*(1.4-_*.04))--Ripple
				end
			end
		end
	else
		for i=1,#V do
			if V[i].ava then
				local B=V[i]
				gc.setColor(1,1,1,a)
				gc.setLineWidth(B.r*.07)
				gc.circle("line",B.x,B.y,B.r)
				local _=V[i].pressTime
				if _>0 then
					gc.setColor(1,1,1,a*_*.08)
					gc.circle("fill",B.x,B.y,B.r*.94)
					gc.circle("line",B.x,B.y,B.r*(1.4-_*.04))
				end
			end
		end
	end
end

local Pnt={BG={}}
function Pnt.BG.none()
	gc.clear(.15,.15,.15)
end
function Pnt.BG.grey()
	gc.clear(.3,.3,.3)
end
function Pnt.BG.glow()
	local t=(sin(Timer()*.5)+sin(Timer()*.7)+sin(Timer()*.9+1)+sin(Timer()*1.5)+sin(Timer()*2+10))*.1
	gc.clear(t,t,t)
end
function Pnt.BG.rgb()
	gc.clear(
		sin(Timer()*1.2)*.15+.2,
		sin(Timer()*1.5)*.15+.2,
		sin(Timer()*1.9)*.15+.2
	)
end
function Pnt.BG.strap()
	gc.setColor(.5,.5,.5)
	local x=Timer()%16*-64
	::L::
	gc.draw(background2,x,0,nil,8,scr.h)
	x=x+1024--image width*8
	if x<scr.w then goto L end
end
function Pnt.BG.flink()
	local t=.13-Timer()%3%1.7
	if t<.2 then gc.clear(t,t,t)
	else gc.clear(0,0,0)
	end
end
function Pnt.BG.game1()
	gc.setColor(.5,.5,.5)
	gc.draw(background1,scr.w*.5,scr.h*.5,Timer()*.15,scr.rad*.0625,nil,16,16)
end--Rainbow
function Pnt.BG.game2()
	gc.setColor(.5,.26,.26)
	gc.draw(background1,scr.w*.5,scr.h*.5,Timer()*.15,scr.rad*.0625,nil,16,16)
end--Red rainbow
function Pnt.BG.game3()
	gc.setColor(.4,.4,.8)
	gc.draw(background1,scr.w*.5,scr.h*.5,Timer()*.15,scr.rad*.0625,nil,16,16)
end--Blue rainbow
function Pnt.BG.game4()
	gc.setColor(.05,.4,.4)
	local x=Timer()%8*-128
	::L::
	gc.draw(background2,x,0,nil,8,scr.h)
	x=x+1024--image width*8
	if x<scr.w then goto L end
end--Fast strap
function Pnt.BG.game5()
	local t=2.5-Timer()%20%6%2.5
	if t<.3 then gc.clear(t,t,t)
	else gc.clear(0,0,0)
	end
end--Lightning
local miniBlockColor={}
function Pnt.BG.game6()
	local t=1.2-Timer()%10%3%1.2
	if t<.3 then gc.clear(t,t,t)
	else gc.clear(0,0,0)
	end
	local R=7-int(Timer()*.5)%7
	local _=miniBlockColor[R]
	gc.setColor(_[1],_[2],_[3],.1)
	gc.draw(miniBlock[R],640,360,Timer()%3.1416*6,400,400,scs[R][0][2]-.5,#blocks[R][0]-scs[R][0][1]+.5)
end--Fast lightning&spining tetromino
local matrixT={}for i=1,50 do matrixT[i]={}for j=1,50 do matrixT[i][j]=love.math.noise(i,j)+2 end end
function Pnt.BG.matrix()
	gc.scale(scr.k)
	gc.clear(.15,.15,.15)
	local _=ceil(scr.h/80)
	for i=1,ceil(scr.w/80)do
		for j=1,_ do
			gc.setColor(1,1,1,sin(matrixT[i][j]*Timer())*.1+.1)
			gc.rectangle("fill",80*i,80*j,-80,-80)
		end
	end
	gc.scale(1/scr.k)
end

function Pnt.load()
	local L=sceneTemp
	gc.setLineWidth(4)
	gc.setColor(1,1,1,.5)
	gc.rectangle("fill",300,330,L[2]/L[3]*680,60,5)
	gc.setColor(1,1,1)
	gc.rectangle("line",300,330,680,60,5)
	setFont(35)
	gc.print(text.load[L[1]],340,335)
	if sceneTemp[1]~=0 then
		gc.printf(sceneTemp[2].."/"..sceneTemp[3],795,335,150,"right")
	end
	setFont(25)
	mStr(L[4],640,400)
end
function Pnt.intro()
	gc.stencil(stencil_miniTitle,"replace",1)
	gc.setStencilTest("equal",1)
		gc.setColor(1,1,1,min(sceneTemp,80)*.005)
		gc.push("transform")
			gc.translate(250,150)
			gc.scale(30)
			gc.rectangle("fill",0,0,26,14)
		gc.pop()
		gc.setColor(1,1,1,.06)
		for i=41,5,-2 do
			gc.setLineWidth(i)
			gc.line(200+(sceneTemp-80)*25,130,(sceneTemp-80)*25,590)
		end
	gc.setStencilTest()
end
function Pnt.main()
	gc.setColor(1,1,1)
	gc.draw(coloredTitleImage,60,30,nil,1.3)
	setFont(30)
	gc.print(gameVersion,70,125)
	gc.print(system,610,100)
	players[1]:draw()
end
function Pnt.mode()
	local cam=mapCam
	gc.push("transform")
	gc.translate(640,360)
	gc.scale(cam.zoomK)
	gc.translate(-cam.x1,-cam.y1)
	gc.scale(cam.k1)
	local MM=modes
	local R=modeRanks
	setFont(30)
	for _=1,#MM do
		local M=MM[_]
		if R[_]then
			gc.setLineWidth(8)
			gc.setColor(1,1,1,.2)
			for _=1,#M.unlock do
				local m=M.unlock[_]
				if R[m]then
					m=MM[m]
					gc.line(M.x,M.y,m.x,m.y)
				end
			end

			local S=M.size
			local d=((M.x-(cam.x1+(cam.sel and -180 or 0))/cam.k1)^2+(M.y-cam.y1/cam.k1)^2)^.55
			if d<500 then S=S*(1.25-d*0.0005) end
			local c=modeRankColor[modeRanks[M.id]]
			if c then
				gc.setColor(c)
			else
				c=.5+sin(Timer()*6.26-_)*.2
				S=S*(.9+c*.4)
				gc.setColor(c,c,c)
			end
			if M.shape==1 then--Rectangle
				gc.rectangle("fill",M.x-S,M.y-S,2*S,2*S)
				if cam.sel==_ then
					gc.setColor(1,1,1)
					gc.setLineWidth(10)
					gc.rectangle("line",M.x-S+5,M.y-S+5,2*S-10,2*S-10)
				end
			elseif M.shape==2 then--diamond
				gc.circle("fill",M.x,M.y,S+5,4)
				if cam.sel==_ then
					gc.setColor(1,1,1)
					gc.setLineWidth(10)
					gc.circle("line",M.x,M.y,S+5,4)
				end
			elseif M.shape==3 then--Octagon
				gc.circle("fill",M.x,M.y,S,8)
				if cam.sel==_ then
					gc.setColor(1,1,1)
					gc.setLineWidth(10)
					gc.circle("line",M.x,M.y,S,8)
				end
			end
			if M.icon then
				local i=M.icon
				local l=i:getWidth()*.5
				local k=S/l*.8
				gc.setColor(0,0,0,2)
				gc.draw(i,M.x-1,M.y-1,nil,k,nil,l,l)
				gc.draw(i,M.x-1,M.y+1,nil,k,nil,l,l)
				gc.draw(i,M.x+1,M.y-1,nil,k,nil,l,l)
				gc.draw(i,M.x+1,M.y+1,nil,k,nil,l,l)
				gc.setColor(1,1,1)
				gc.draw(i,M.x,M.y,nil,k,nil,l,l)
			end
		end
	end
	gc.pop()
	if cam.sel then
		local M=MM[cam.sel]
		local lang=setting.lang
		gc.setColor(.7,.7,.7,.5)
		gc.rectangle("fill",920,0,360,720)--Info board
		gc.setColor(M.color)
		setFont(40)mStr(M.name[lang],1100,5)
		setFont(30)mStr(M.level[lang],1100,50)
		gc.setColor(1,1,1)
		setFont(28)gc.printf(M.info[lang],920,110,360,"center")
		if M.slowMark then
			gc.draw(ctrlSpeedLimit,1230,50,nil,.4)
		end
		if M.score then
			mDraw(drawableText.highScore,1100,240)
			gc.setColor(.4,.4,.4,.8)
			gc.rectangle("fill",940,290,320,280)--Highscore board
			local L=M.records
			gc.setColor(1,1,1)
			if L[1]then
				for i=1,#L do
					local t=M.scoreDisp(L[i])
					local s=#t
					local dy
					if s<15 then		dy=0
					elseif s<25 then	dy=2
					else				dy=4
					end
					setFont(int(26-s*.4))
					gc.print(t,955,275+dy+25*i)
					setFont(10)
					local _=L[i].date
					if _ then gc.print(_,1155,284+25*i)end
				end
			else
				mDraw(drawableText.noScore,1100,370)
			end
		end
	end
	if cam.keyCtrl then
		gc.setColor(1,1,1)
		gc.draw(mapCross,460-20,360-20)
	end
end
function Pnt.music()
	gc.setColor(1,1,1,.3+sin(Timer()*5)*.2)
	gc.rectangle("fill",45,98+30*sceneTemp,250,30)
	gc.setColor(.7,.7,.7)
	gc.draw(drawableText.musicRoom,20,20)
	gc.setColor(1,1,1)
	gc.draw(drawableText.musicRoom,22,23)
	gc.draw(drawableText.nowPlaying,490,390)
	setFont(30)
	for i=1,#musicID do
		gc.print(musicID[i],50,90+30*i)
	end
	gc.draw(titleImage,640,310,nil,1.5,nil,206,35)
	if BGM.nowPlay then
		setFont(45)
		gc.setColor(sin(Timer()*.5)*.2+.8,sin(Timer()*.7)*.2+.8,sin(Timer())*.2+.8)
		mStr(BGM.nowPlay,630,460)
		local t=-Timer()%2.3/2
		if t<1 then
			gc.setColor(1,1,1,t)
			gc.draw(coloredTitleImage,640,310,nil,1.5+.1-.1*t,1.5+.3-.3*t,206,35)
		end
	end
end
function Pnt.custom()
	gc.setColor(1,1,1,.3+sin(Timer()*8)*.2)
	gc.rectangle("fill",25,95+40*sceneTemp,480,40)
	gc.setColor(.7,.7,.7)gc.draw(drawableText.custom,20,20)
	gc.setColor(1,1,1)gc.draw(drawableText.custom,22,23)
	setFont(35)
	for i=1,#customID do
		local k=customID[i]
		local y=90+40*i
		gc.printf(text.customOption[k],15,y,320,"right")
		if text.customVal[k]then
			gc.print(text.customVal[k][customSel[i]],335,y)
		else
			gc.print(customRange[k][customSel[i]],335,y)
		end
	end
end
function Pnt.draw()
	local sx,sy=sceneTemp.x,sceneTemp.y
	gc.translate(200,60)
	gc.setColor(1,1,1,.2)
	gc.setLineWidth(1)
	for x=1,9 do gc.line(30*x,0,30*x,600)end
	for y=0,19 do gc.line(0,30*y,300,30*y)end
	gc.setColor(1,1,1)
	gc.setLineWidth(3)
	gc.rectangle("line",-2,-2,304,604)
	gc.setLineWidth(2)
	local cross=puzzleMark[-1]
	for y=1,20 do for x=1,10 do
		local B=preField[y][x]
		if B>0 then
			gc.draw(blockSkin[B],30*x-30,600-30*y)
		elseif B==-1 and not sceneTemp.demo then
			gc.draw(cross,30*x-30,600-30*y)
		end
	end end
	if sx and sy then
		gc.setLineWidth(2)
		gc.rectangle("line",30*sx-30,600-30*sy,30,30)
	end
	gc.translate(-200,-60)
	local pen=sceneTemp.pen
	if pen>0 then
		gc.setLineWidth(13)
		gc.setColor(skin.libColor[pen])
		gc.rectangle("line",565,460,70,70)
	elseif pen==-1 then
		gc.setLineWidth(5)
		gc.setColor(.9,.9,.9)
		gc.line(575,470,625,520)
		gc.line(575,520,625,470)
	end
	if sceneTemp.sure>0 then
		gc.setColor(1,1,1,sceneTemp.sure*.02)
		gc.draw(drawableText.question,1040,430)
	end
	setFont(40)
	for i=1,7 do
		local _=setting.skin[i]
		gc.setColor(skin.libColor[_])
		mStr(text.block[i],500+65*_,65)
	end
end
function Pnt.play()
	for p=1,#players do
		players[p]:draw()
	end
	gc.setLineWidth(5)
	for i=1,#FX_attack do
		local A=FX_attack[i]
		gc.push("transform")
			local a=(A.t<10 and A.t*.05 or A.t>50 and 6-A.t*.1 or 1)*A.a
			gc.setColor(A.r,A.g,A.b,a*.5)
			gc.circle("line",0,0,A.rad,A.corner)
			local L=A.drag
			local len=#L
			for i=1,len,2 do
				gc.setColor(A.r,A.g,A.b,.4*a*i/len)
				gc.translate(L[i],L[i+1])
				gc.rotate(A.t*.1)
				gc.circle("fill",0,0,A.rad,A.corner)
				gc.rotate(-A.t*.1)
				gc.translate(-L[i],-L[i+1])
			end
			gc.setColor(A.r,A.g,A.b,a)
			gc.translate(A.x,A.y)
			gc.rotate(A.t*.1)
			gc.circle("fill",0,0,A.rad,A.corner)
		gc.pop()
	end--FX animation
	gc.setColor(1,1,1)
	if setting.VKSwitch then drawVirtualkey()end
	if modeEnv.royaleMode then
		for i=1,#FX_badge do
			local b=FX_badge[i]
			gc.setColor(1,1,1,b.t<10 and b.t*.1 or b.t<50 and 1 or(60-b.t)*.1)
			if b.t<10 then
				gc.draw(badgeIcon,b[1]-14,b[2]-14)
			elseif b.t<50 then
				local t=((b.t-10)*.025)t=(3-2*t)*t*t
				gc.draw(badgeIcon,b[1]*(1-t)+b[3]*t-14,b[2]*(1-t)+b[4]*t-14)
			else
				gc.draw(badgeIcon,b[3]-14,b[4]-14)
			end
		end
		local P=players[1]
		gc.setLineWidth(5)
		gc.setColor(.8,1,0,.2)
		for i=1,#P.atker do
			local p=P.atker[i]
			gc.line(p.centerX,p.centerY,P.x+300*P.size,P.y+670*P.size)
		end
		if P.atkMode~=4 then
			if P.atking then drawAtkPointer(P.atking.centerX,P.atking.centerY)end
		else
			for i=1,#P.atker do
				local p=P.atker[i]
				drawAtkPointer(p.centerX,p.centerY)
			end
		end
	end
	if restartCount>0 then
		gc.setColor(0,0,0,restartCount*.05)
		gc.push("transform")
			gc.origin()
			gc.rectangle("fill",0,0,scr.w,scr.h)
		gc.pop()
	end
end
function Pnt.pause()
	Pnt.play()
	local T=sceneTemp.timer*.02
	local t=T
	if gameResult then t=t*.6 end
	gc.setColor(.15,.15,.15,t)
	gc.push("transform")
		gc.origin()
		gc.rectangle("fill",0,0,scr.w,scr.h)
	gc.pop()
	setFont(25)
	gc.setColor(1,1,1,T)
	if pauseCount>0 then
		t=curMode.pauseLimit and pauseTime>30
		if t then gc.setColor(1,.4,.4,T)end
		gc.print(text.pauseCount..":["..pauseCount.."] "..format("%.2f",pauseTime).."s",110,150)
		if t then gc.setColor(1,1,1,T)end
	end
	for i=1,7 do
		gc.print(text.pauseStat[i],95,30*i+310)
		gc.print(sceneTemp[i],305,30*i+310)
	end
	for i=8,14 do
		gc.print(text.pauseStat[i],845,30*i+100)
		gc.print(sceneTemp[i],1050,30*i+100)
	end
	_=drawableText.modeName
	gc.draw(_,100,230)
	gc.draw(drawableText.levelName,135+_:getWidth(),230)
	setFont(35)
	mDraw(gameResult and drawableText[gameResult]or drawableText.pause,640,50-10*(5-sceneTemp.timer*.1)^1.5)
end
function Pnt.setting_game()
	gc.setColor(1,1,1)
	mDraw(drawableText.setting_game,640,15)
	gc.draw(blockSkin[int(Timer()*2)%11+1],720,540,Timer()%6.28319,2,nil,15,15)
end
function Pnt.setting_graphic()
	gc.setColor(1,1,1)
	mDraw(drawableText.setting_graphic,640,15)
end
function Pnt.setting_sound()
	gc.setColor(1,1,1,.8)
	mDraw(drawableText.setting_sound,640,15)
	local t=Timer()
	local _=sceneTemp.jump
	local x,y=800,340+10*sin(t*.5)+(_-10)*_*.3
	gc.translate(x,y)
	gc.draw(miya.ch,0,0)
	gc.setColor(1,1,1,.7)
	gc.draw(miya.f1,4,47+4*sin(t*.9))
	gc.draw(miya.f2,42,107+5*sin(t))
	gc.draw(miya.f3,93,126+3*sin(t*.7))
	gc.draw(miya.f4,129,98+3*sin(t*.7))
	gc.translate(-x,-y)
end
function Pnt.setting_control()
	--Testing grid line
	gc.setLineWidth(4)
	gc.setColor(1,1,1,.4)
	gc.line(550,540,950,540)
	gc.line(550,580,950,580)
	gc.line(550,620,950,620)
	for x=590,910,40 do
		gc.line(x,530,x,630)
	end
	gc.setColor(1,1,1)
	gc.line(550,530,550,630)
	gc.line(950,530,950,630)

	--Texts
	gc.draw(drawableText.setting_control,80,50)
	setFont(50)
	gc.printf(text.preview,320,540,200,"right")
	
	--Floating number
	setFont(30)
	local _=setting
	mStr(_.das,226+35*_.das,150)
	mStr(_.arr,226+35*_.arr,240)
	mStr(_.sddas,226+35*_.sddas,330)
	mStr(_.sdarr,226+35*_.sdarr,420)

	--Testing O mino
	_=blockSkin[setting.skin[6]]
	local x=550+40*sceneTemp.pos
	gc.draw(_,x,540,nil,40/30)
	gc.draw(_,x,580,nil,40/30)
	gc.draw(_,x+40,540,nil,40/30)
	gc.draw(_,x+40,580,nil,40/30)
end
function Pnt.setting_key()
	local s=sceneTemp
	local a=.3+sin(Timer()*15)*.1
	if s.kS then gc.setColor(1,.3,.3,a)else gc.setColor(1,.7,.7,a)end
	gc.rectangle("fill",
		s.kb<11 and 240 or 840,
		45*s.kb+20-450*int(s.kb/11),
		200,45
	)
	if s.jS then gc.setColor(.3,.3,.1,a)else gc.setColor(.7,.7,1,a)end
	gc.rectangle("fill",
		s.js<11 and 440 or 1040,
		45*s.js+20-450*int(s.js/11),
		200,45
	)
	--Selection rect

	gc.setColor(1,.3,.3)
	mDraw(drawableText.keyboard,340,30)
	mDraw(drawableText.keyboard,940,30)
	gc.setColor(.3,.3,1)
	mDraw(drawableText.joystick,540,30)
	mDraw(drawableText.joystick,1140,30)

	gc.setColor(1,1,1)
	setFont(26)
	local board=s.board
	for N=1,20 do
		if N<11 then
			gc.printf(text.actName[N],47,45*N+22,180,"right")
			mStr(keyMap[board][N],340,45*N+22)
			mStr(keyMap[board+8][N],540,45*N+22)
		else
			gc.printf(text.actName[N],647,45*N-428,180,"right")
			mStr(keyMap[board][N],940,45*N-428)
			mStr(keyMap[board+8][N],1040,45*N-428)
		end
	end
	gc.setLineWidth(2)
	for x=40,1240,200 do
		gc.line(x,65,x,515)
	end
	for y=65,515,45 do
		gc.line(40,y,1240,y)
	end
	setFont(35)
	gc.print("Player:",170,590)
	gc.print(int(board*.5+.5),300,590)
	gc.print(board.."/8",580,590)
	gc.draw(drawableText.ctrlSetHelp,50,650)
end
function Pnt.setting_skin()
	gc.setColor(1,1,1)
	for N=1,7 do
		local face=setting.face[N]
		local B=blocks[N][face]
		local x,y=-30+140*N-scs[N][face][2]*30,335+scs[N][face][1]*30
		local col=#B[1]
		for i=1,#B do for j=1,col do
			if B[i][j]then
				gc.draw(blockSkin[setting.skin[N]],x+30*j,y-30*i)
			end
		end end
		gc.circle("fill",-15+140*N,350,sin(Timer()*10)+5)
	end
	for i=1,5 do
		gc.draw(blockSkin[12+i],1110,140+60*i,nil,2)
	end
	gc.draw(drawableText.setting_skin,80,50)
end
function Pnt.setting_touch()
	gc.setColor(1,1,1)
	gc.setLineWidth(7)gc.rectangle("line",340,15,600,690)
	gc.setLineWidth(3)gc.rectangle("line",490,85,300,600)
	VirtualkeyPreview()
	local d=snapLevelValue[sceneTemp.snap]
	if d>=10 then
		gc.setLineWidth(3)
		gc.setColor(1,1,1,sin(Timer()*4)*.1+.1)
		for i=1,1280/d-1 do
			gc.line(d*i,0,d*i,720)
		end
		for i=1,720/d-1 do
			gc.line(0,d*i,1280,d*i)
		end
	end
end
function Pnt.setting_trackSetting()
	gc.setColor(1,1,1)
	mDraw(drawableText.VKTchW,140+50*setting.VKTchW,260)
	mDraw(drawableText.VKOrgW,140+50*setting.VKTchW+50*setting.VKCurW,320)
	mDraw(drawableText.VKCurW,640+50*setting.VKCurW,380)
end
function Pnt.help()
	setFont(22)
	gc.setColor(1,1,1)
	for i=1,#text.help do
		gc.printf(text.help[i],200,30*i-10,1000,"center")
	end
	setFont(19)
	gc.print(text.used,30,330)
	gc.draw(titleImage,280,610,.1,1+.05*sin(Timer()*2),nil,206,35)
	gc.setLineWidth(5)
	gc.rectangle("line",17,17,260,260)
	gc.rectangle("line",1077,17,186,186)
	gc.draw(payCode,20,20)
	gc.draw(groupCode,1080,20)
	gc.setColor(1,1,1,sin(Timer()*10)*.5+.5)
	setFont(30)
	mStr(text.support,150,283)
	setFont(20)
	mStr(text.group,1170,210)
end
function Pnt.stat()
	setFont(23)
	gc.setColor(1,1,1)
	for i=1,16 do
		gc.print(text.stat[i],400,30*i+10)
		gc.print(sceneTemp[i],720,30*i+10)
	end
	gc.draw(titleImage,260,570,.2+.07*sin(Timer()*3),nil,nil,206,35)
end
function Pnt.history()
	gc.setColor(.2,.2,.2,.7)
	gc.rectangle("fill",30,45,1000,632)
	gc.setColor(1,1,1)
	gc.setLineWidth(4)
	gc.rectangle("line",30,45,1000,632)
	setFont(20)
	local _=sceneTemp
	for i=0,min(22,#_[1]-_[2])do
		gc.print(_[1][_[2]+i],40,50+27*(i))
	end
end
return Pnt