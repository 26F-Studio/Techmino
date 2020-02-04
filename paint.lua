local gc=love.graphics
local setFont=setFont
local int,abs,rnd,max,min,sin=math.floor,math.abs,math.random,math.max,math.min,math.sin
local format=string.format

local Timer=love.timer.getTime
local scr=scr
local modeLevelColor={
	EASY=color.cyan,
	NORMAL=color.green,
	HARD=color.magenta,
	LUNATIC=color.red,
	EXTRA=color.lightMagenta,
	ULTIMATE=color.lightYellow,
	FINAL=color.lightGrey,
	["EASY+"]=color.darkCyan,
	["NORMAL+"]=color.darkGreen,
	["HARD+"]=color.darkMagenta,
	["LUNATIC+"]=color.darkRed,

	MESS=color.lightGrey,
	GM=color.blue,
	DEATH=color.lightRed,
	CTWC=color.lightBlue,
	["10L"]=color.cyan,
	["20L"]=color.lightBlue,
	["40L"]=color.green,
	["100L"]=color.orange,
	["400L"]=color.red,
	["1000L"]=color.lightGrey,
}
local dataOptL={"key","rotate","hold",nil,nil,nil,"send","recv","pend"}
local function dataOpt(i)
	local stat=players[1].stat
	if i==4 then
		return stat.piece.."  "..(int(stat.piece/stat.time*100)*.01).."PPS"
	elseif i==5 then
		return stat.row.."  "..(int(stat.row/stat.time*600)*.1).."LPM"
	elseif i==6 then
		return stat.atk.."  "..(int(stat.atk/stat.time*600)*.1).."APM"
	elseif i<10 then
		return stat[dataOptL[i]]
	elseif i==10 then
		return stat.clear_1.."/"..stat.clear_2.."/"..stat.clear_3.."/"..stat.clear_4
	elseif i==11 then
		return "["..stat.spin_0.."]/"..stat.spin_1.."/"..stat.spin_2.."/"..stat.spin_3
	elseif i==12 then
		return stat.b2b.."[+"..stat.b3b.."]"
	elseif i==13 then
		return stat.pc
	elseif i==14 then
		return format("%0.2f",stat.atk/stat.row)
	elseif i==15 then
		return stat.extraPiece.."["..(int(stat.extraRate/stat.piece*10000)*.01).."%]"
	end
end
local statOptL={
	"run","game",nil,
	"key","rotate","hold","piece","row",
	"atk","send","recv","pend",
}
local function statOpt(i)
	if i<13 and i~=3 then
		return stat[statOptL[i]]
	elseif i==3 then
		return format("%0.1fHr",stat.time*2.78e-4)
	elseif i==13 then
		return stat.clear_1.."/"..stat.clear_2.."/"..stat.clear_3.."/"..stat.clear_4
	elseif i==14 then
		return "["..stat.spin_0.."]/"..stat.spin_1.."/"..stat.spin_2.."/"..stat.spin_3
	elseif i==15 then
		return stat.b2b.."[+"..stat.b3b.."]"
	elseif i==16 then
		return stat.pc
	elseif i==17 then
		return format("%0.2f",stat.atk/stat.row)
	elseif i==18 then
		return stat.extraPiece.."["..(int(stat.extraRate/stat.piece*10000)*.01).."%]"
	end
end
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

FX_BGblock={tm=150,next=7,ct=0,list={{v=0},{v=0},{v=0},{v=0},{v=0},{v=0},{v=0},{v=0},{v=0},{v=0},{v=0},{v=0},{v=0},{v=0},{v=0},{v=0},}}--Falling tetrominos on background
FX_attack={}--Attack beam
FX_badge={}--Badge thrown
sysFX={}
FX_ripple={}--Ripple&SqrShade
textFX={
	appear=function(t,a)
		setFont(t.font)
		gc.setColor(1,1,1,a)
		mStr(t.text,150,250-t.font*.5+t.dy)
	end,
	fly=function(t,a)
		setFont(t.font)
		gc.setColor(1,1,1,a)
		mStr(t.text,150+(t.t-15)^3*.005,250-t.font*.5+t.dy)
	end,
	stretch=function(t,a)
		gc.push("transform")
			setFont(t.font)
			gc.translate(150,250+t.dy)
			if t.t<20 then gc.scale((20-t.t)*.015+1,1)end
			gc.setColor(1,1,1,a)
			mStr(t.text,0,-t.font*.5)
		gc.pop()
	end,
	drive=function(t,a)
		gc.push("transform")
			setFont(t.font)
			gc.translate(150,290+t.dy)
			if t.t<20 then gc.shear((20-t.t)*.05,0)end
			gc.setColor(1,1,1,a)
			mStr(t.text,0,-t.font*.5-15)
		gc.pop()
	end,
	spin=function(t,a)
		gc.push("transform")
			setFont(t.font)
			gc.translate(150,250+t.dy)
			if t.t<20 then
				gc.rotate((20-t.t)^2*.0015)
			end
			gc.setColor(1,1,1,a)
			mStr(t.text,0,-t.font*.5-8)
		gc.pop()
	end,
	flicker=function(t,a)
		setFont(t.font)
		gc.setColor(1,1,1,a*(rnd()+.5))
		mStr(t.text,150,225-t.font*.5+t.dy)
	end,
	zoomout=function(t,a)
		gc.push("transform")
			setFont(t.font)
			local k=t.t^.5*.1+1
			gc.translate(150,290+t.dy)
			gc.scale(k,k)
			gc.setColor(1,1,1,a)
			mStr(t.text,0,-t.font*.5-5)
		gc.pop()
	end,
	beat=function(t,a)
		gc.push("transform")
			setFont(t.font)
			gc.translate(150,290+t.dy)
			if t.t<20 then
				local k=.2*(5+(25-t.t)^.5)-.45
				gc.scale(k,k)
			end
			gc.setColor(1,1,1,a)
			mStr(t.text,0,-t.font*.5-5)
		gc.pop()
	end,
}
local function drawAtkPointer(x,y)
	local t=sin(Timer()*20)
	gc.setColor(.2,.7+t*.2,1,.6+t*.4)
	gc.circle("fill",x,y,25,6)
	local a=Timer()*3%1*.8
	gc.setColor(0,.6,1,.8-a)
	gc.circle("line",x,y,30*(1+a),6)
end
local function VirtualkeyPreview()
	for i=1,#virtualkey do
		local c=sel==i and .8 or 1
		gc.setColor(c,c,c,setting.virtualkeyAlpha*.1)
		local b=virtualkey[i]
		gc.setLineWidth(b[4]*.07)
		gc.circle("line",b[1],b[2],b[4]-5)
		if setting.virtualkeyIcon then gc.draw(virtualkeyIcon[i],b[1],b[2],nil,b[4]*.025,nil,18,18)end
	end
end
local function drawVirtualkey()
	local a=setting.virtualkeyAlpha*.1
	for i=1,#virtualkey do
		if i~=9 or modeEnv.Fkey then
			local p,b=virtualkeyDown[i],virtualkey[i]
			if p then gc.setColor(.7,.7,.7,a)
			else gc.setColor(1,1,1,a)
			end
			gc.setLineWidth(b[4]*.07)
			gc.circle("line",b[1],b[2]+virtualkeyPressTime[i],b[4]-5)
			if setting.virtualkeyIcon then gc.draw(virtualkeyIcon[i],b[1],b[2]+virtualkeyPressTime[i],nil,b[4]*.025,nil,18,18)end
			if virtualkeyPressTime[i]>0 then
				gc.setColor(1,1,1,a*virtualkeyPressTime[i]*.1)
				gc.circle("line",b[1],b[2],b[4]*(1.4-virtualkeyPressTime[i]*.04))
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
function Pnt.BG.lightGrey()
	gc.clear(.5,.5,.5)
end
function Pnt.BG.glow()
	local t=((sin(Timer()*.5)+sin(Timer()*.7)+sin(Timer()*.9+1)+sin(Timer()*1.5)+sin(Timer()*2+3))+5)*.05
	gc.clear(t,t,t)
end
function Pnt.BG.rgb()
	gc.clear(
		sin(Timer()*1.2)*.15+.5,
		sin(Timer()*1.5)*.15+.5,
		sin(Timer()*1.9)*.15+.5
	)
end
function Pnt.BG.strap()
	gc.setColor(1,1,1)
	local x=Timer()%32*40
	gc.draw(background2,x,0,nil,10)
	gc.draw(background2,x-1280,0,nil,10)
end
function Pnt.BG.flink()
	local t=.13-Timer()%3%1.7
	if t<.25 then
		gc.clear(t,t,t)
	else
		gc.clear(0,0,0)
	end
end
function Pnt.BG.game1()
	gc.setColor(1,1,1)
	gc.draw(background1,640,360,Timer()*.15,12,nil,64,64)
end--Rainbow
function Pnt.BG.game2()
	gc.setColor(1,.5,.5)
	gc.draw(background1,640,360,Timer()*.2,12,nil,64,64)
end--Red rainbow
function Pnt.BG.game3()
	gc.setColor(.6,.6,1)
	gc.draw(background1,640,360,Timer()*.25,12,nil,64,64)
end--Blue rainbow
function Pnt.BG.game4()
	gc.setColor(.1,.5,.5)
	local x=Timer()%4*320
	gc.draw(background2,x,0,nil,10)
	gc.draw(background2,x-1280,0,nil,10)
end--Fast strap
function Pnt.BG.game5()
	local t=2.5-Timer()%20%6%2.5
	if t<.5 then gc.clear(t,t,t)
	else gc.clear(0,0,0)
	end
end--Lightning
local scs={1,2,1,2,1,2,1,2,1,2,1.5,1.5,.5,2.5}
function Pnt.BG.game6()
	local t=1.2-Timer()%10%3%1.2
	if t<.5 then gc.clear(t,t,t)
	else gc.clear(0,0,0)
	end
	gc.setColor(.3,.3,.3)
	local r=7-int(Timer()*.5)%7
	gc.draw(mouseBlock[r],640,360,Timer()%3.1416*6,400,400,scs[2*r]-.5,#blocks[r][0]-scs[2*r-1]+.5)
end--Fast lightning&spining tetromino
local matrixT={}for i=0,15 do matrixT[i]={}for j=0,8 do matrixT[i][j]=love.math.noise(i,j)+2 end end
function Pnt.BG.matrix()
	gc.clear(.15,.15,.15)
	for i=0,15 do
		for j=0,8 do
			local t=sin(matrixT[i][j]*Timer())*.2+.2
			gc.setColor(1,1,1,t)
			gc.rectangle("fill",80*i,80*j,80,80)
		end
	end
end

function Pnt.load()
	gc.setLineWidth(4)
	gc.setColor(1,1,1,.5)
	gc.rectangle("fill",300,330,loadprogress*680,60,5)
	gc.setColor(1,1,1)
	gc.rectangle("line",300,330,680,60,5)
	setFont(40)
	mStr(text.load[loading],640,335)
	setFont(30)
	mStr(loadTip,640,400)
end
function Pnt.intro()
	gc.stencil(stencil_miniTitle,"replace",1)
	gc.setStencilTest("equal",1)
		gc.setColor(1,1,1,min(count,80)*.005)
		gc.push("transform")
			gc.translate(250,150)
			gc.scale(30)
			gc.rectangle("fill",0,0,26,14)
		gc.pop()
		gc.setColor(1,1,1,.06)
		for i=41,5,-2 do
			gc.setLineWidth(i)
			gc.line(200+(count-80)*25,130,(count-80)*25,590)
		end
	gc.setStencilTest()
end
function Pnt.main()
	gc.setColor(1,1,1)
	gc.draw(coloredTitleImage,60,30,nil,1.3)
	gc.draw(drawableText.warning,595-drawableText.warning:getWidth(),128)
	setFont(35)
	gc.print(gameVersion,70,125)
	gc.print(system,610,100)
	gc.print(modeLevel[modeID[modeSel]][levelSel],600,373)
	setFont(30)
	gc.print(text.modeName[modeSel],600,414)
	players[1]:demoDraw()
end
function Pnt.mode()
	gc.setColor(1,1,1)
	gc.draw(titleImage,830,30)
	setFont(40)
	gc.setColor(modeLevelColor[modeLevel[modeID[modeSel]][levelSel]]or color.white)
	mStr(modeLevel[modeID[modeSel]][levelSel],270,215)
	setFont(30)
	gc.setColor(color.white)
	mStr(text.modeInfo[modeID[modeSel]],270,255)
	setFont(80)
	gc.setColor(color.grey)
	mStr(text.modeName[modeSel],643,273)
	for i=modeSel-2,modeSel+2 do
		if i>=1 and i<=#modeID then
			local f=80-abs(i-modeSel)*20
			gc.setColor(i==modeSel and color.white or abs(i-modeSel)==1 and color.grey or color.darkGrey)
			setFont(f)
			mStr(text.modeName[i],640,310+70*(i-modeSel)-f*.5)
		end
	end
end
function Pnt.music()
	gc.setColor(1,1,1,.3+sin(Timer()*5)*.2)
	gc.rectangle("fill",45,98+30*sel,250,30)
	gc.setColor(.8,.8,.8)
	gc.draw(drawableText.musicRoom,20,20)
	gc.setColor(1,1,1)
	gc.draw(drawableText.musicRoom,22,23)
	gc.draw(drawableText.nowPlaying,490,390)
	setFont(35)
	for i=1,#musicID do
		gc.print(musicID[i],50,90+30*i)
	end
	gc.draw(titleImage,640,310,nil,1.5,nil,206,35)
	if bgmPlaying then
		setFont(50)
		gc.setColor(sin(Timer()*.5)*.2+.8,sin(Timer()*.7)*.2+.8,sin(Timer())*.2+.8)
		mStr(bgmPlaying or"",630,460)
		local t=-Timer()%2.3/2
		if t<1 then
			gc.setColor(1,1,1,t)
			gc.draw(coloredTitleImage,640,310,nil,1.5+.1-.1*t,1.5+.3-.3*t,206,35)
		end
	end
end
function Pnt.custom()
	gc.setColor(1,1,1,.3+sin(Timer()*8)*.2)
	gc.rectangle("fill",25,95+40*sel,480,40)
	gc.setColor(.8,.8,.8)gc.draw(drawableText.custom,20,20)
	gc.setColor(1,1,1)gc.draw(drawableText.custom,22,23)
	setFont(40)
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
	gc.translate(200,60)
	gc.setColor(1,1,1,.2)
	gc.setLineWidth(1)
	for x=1,9 do gc.line(30*x,0,30*x,600)end
	for y=0,19 do gc.line(0,30*y,300,30*y)end
	gc.setColor(1,1,1)
	gc.setLineWidth(3)
	gc.rectangle("line",-2,-2,304,604)
	gc.setLineWidth(2)
	for y=1,20 do for x=1,10 do
		local B=preField[y][x]
		if B>0 then
			gc.draw(blockSkin[B],30*x-30,600-30*y)
		elseif B==-1 then
			gc.line(30*x-25,605-30*y,30*x-5,625-30*y)
			gc.line(30*x-25,625-30*y,30*x-5,605-30*y)
		end
	end end
	if sx and sy then
		gc.setLineWidth(2)
		gc.rectangle("line",30*sx-30,600-30*sy,30,30)
	end
	gc.translate(-200,-60)
	if clearSureTime>0 then
		gc.setColor(1,1,1,clearSureTime*.02)
		gc.draw(drawableText.question,1100,570)
	end
	if pen>0 then
		gc.setLineWidth(13)
		gc.setColor(blockColor[pen])
		gc.rectangle("line",945,605,70,70)
	elseif pen==-1 then
		gc.setLineWidth(5)
		gc.setColor(.9,.9,.9)
		gc.line(960,620,1000,660)
		gc.line(960,660,1000,620)
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
			local a=A.t<10 and A.a*A.t*.05 or A.t>50 and A.a*(6-A.t*.1)or A.a
			gc.setColor(A.r,A.g,A.b,a*.5)
			gc.circle("line",0,0,A.rad,A.corner)
			local L=A.drag
			for i=1,#L,2 do
				gc.setColor(A.r,A.g,A.b,a*i*.05)
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
	if setting.virtualkeySwitch then drawVirtualkey()end
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
			gc.line(p.centerX,p.centerY,P.centerX,P.centerY)
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
		gc.setColor(0,0,0,restartCount/20)
		gc.rectangle("fill",0,0,1280,720)
	end
end
function Pnt.pause()
	Pnt.play()
	gc.setColor(0,0,0,pauseTimer*.015)
	gc.rectangle("fill",0,0,1280,720)
	gc.setColor(1,1,1,pauseTimer*.02)
	setFont(30)
	if pauseCount>0 then
		gc.print(text.pauseCount..":["..pauseCount.."] "..format("%0.2f",pauseTime).."s",110,150)
	end
	for i=1,8 do
		gc.print(text.stat[i+3],110,30*i+270)
		gc.print(dataOpt(i),305,30*i+270)
	end
	for i=9,15 do
		gc.print(text.stat[i+3],860,30*i+30)
		gc.print(dataOpt(i),1000,30*i+30)
	end
	setFont(40)
	if system~="Android"then
		mStr(text.space.."/"..text.enter,640,190)
		mStr("Ctrl+R",640,351)
		gc.print("ESC",610,506)
	end
	mDraw(gamefinished and drawableText.finish or drawableText.pause,640,60-10*(5-pauseTimer*.1)^1.5)
end
function Pnt.setting_game()
	gc.setColor(1,1,1)
	mDraw(drawableText.setting_game,640,15)
	setFont(40)
	mStr("DAS:"..setting.das,290,205)
	mStr("ARR:"..setting.arr,610,205)
	setFont(28)
	mStr(text.softdropdas..setting.sddas,290,323)
	mStr(text.softdroparr..setting.sdarr,610,323)
end
function Pnt.setting_graphic()
	gc.setColor(1,1,1)
	mDraw(drawableText.setting_graphic,640,15)
	gc.draw(blockSkin[7-int(Timer()*2)%7],940,440,nil,2)
end
function Pnt.setting_sound()
	gc.setColor(1,1,1)
	mDraw(drawableText.setting_sound,640,15)
end
function Pnt.setting_control()
	local a=.3+sin(Timer()*15)*.1
	if keyboardSetting then
		gc.setColor(1,.5,.5,a)
	else
		gc.setColor(.9,.9,.9,a)
	end
	gc.rectangle("fill",240,40*keyboardSet-10,200,40)
	if joystickSetting then
		gc.setColor(1,.5,.5,a)
	else
		gc.setColor(.9,.9,.9,a)
	end
	gc.rectangle("fill",440,40*joystickSet-10,200,40)

	gc.setColor(1,1,1)
	setFont(25)
	for y=1,13 do
		mStr(text.actName[y],150,40*y-5)
		for x=1,2 do
			mStr(setting.keyMap[curBoard+x*8-8][y],200*x+140,40*y-3)
		end
		gc.line(40,40*y-10,640,40*y-10)
	end
	for x=1,4 do
		gc.line(200*x-160,30,200*x-160,550)
	end
	gc.line(40,550,640,550)
	mDraw(drawableText.keyboard,340,0)
	mDraw(drawableText.joystick,540,0)
	gc.draw(drawableText.ctrlSetHelp,50,620)
	setFont(40)
	gc.print("P"..int(curBoard*.5+.5).."/P4",420,560)
	gc.print(curBoard.."/8",580,560)
end
function Pnt.setting_touch()
	VirtualkeyPreview()
	local d=snapLevelValue[snapLevel]
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
function Pnt.help()
	setFont(30)
	gc.setColor(1,1,1)
	for i=1,#text.help do
		gc.printf(text.help[i],140,10+40*i,1000,"center")
	end
	setFont(24)
	gc.print(text.used,30,330)
	gc.draw(titleImage,280,620,.1,1+.05*sin(Timer()*2),nil,206,35)
	gc.setLineWidth(5)
	gc.rectangle("line",17,17,260,260)
	gc.rectangle("line",1077,17,186,186)
	gc.draw(payCode,20,20)
	gc.draw(groupCode,1080,20)
	gc.setColor(1,1,1,sin(Timer()*10)*.5+.5)
	setFont(35)
	mStr(text.support,150,283)
	setFont(25)
	mStr(text.group,1170,210)
end
function Pnt.stat()
	setFont(28)
	gc.setColor(1,1,1)
	for i=1,18 do
		gc.print(text.stat[i],400,30*i-5)
		gc.print(statOpt(i),720,30*i-5)
	end
	gc.draw(titleImage,260,600,.2+.07*sin(Timer()*3),nil,nil,206,35)
end
function Pnt.history()
	gc.setColor(.2,.2,.2,.7)
	gc.rectangle("fill",30,45,1000,632)
	gc.setColor(1,1,1)
	gc.setLineWidth(4)
	gc.rectangle("line",30,45,1000,632)
	setFont(25)
	for i=0,min(22,#updateLog-sel)do
		gc.print(updateLog[sel+i],40,50+27*(i))
	end
end
return Pnt