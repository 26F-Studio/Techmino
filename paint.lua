local gc=love.graphics
local mt=love.math
local gmatch=string.gmatch
local setFont=setFont
local int,abs,rnd,max,min,sin=math.floor,math.abs,math.random,math.max,math.min,math.sin
local format=string.format

local Timer=love.timer.getTime
local scr=scr
local attackColor={
	{color.darkGrey,color.white},
	{color.grey,color.white},
	{color.lightPurple,color.white},
	{color.lightRed,color.white},
	{color.darkGreen,color.cyan},
}
local frameColor={
	[0]=color.white,
	color.lightGreen,
	color.lightBlue,
	color.lightPurple,
	color.lightOrange,
}
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
		gc.rectangle("fill",unpack(miniTitle_rect[i]))
	end
end

FX={
	flash=0,--Black screen(frame)
	shake=0,--Screen shake(frame)
	attack={},--Attack beam
	badge={},--badge thrown

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

local function drawDial(x,y,speed)
	gc.setColor(1,1,1)
	mStr(int(speed),x,y-18)
	gc.draw(dialCircle,x,y,nil,nil,nil,32,32)
	gc.setColor(1,1,1,.6)
	gc.draw(dialNeedle,x,y,2.094+(speed<=175 and .02094*speed or 4.712-52.36/(speed-125)),nil,nil,5,4)
end
local function drawPixel(y,x,id)
	gc.draw(blockSkin[id],30*x-30,600-30*y)
end
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

local scs={{1,2},nil,nil,nil,nil,{1.5,1.5},{0.5,2.5}}for i=2,5 do scs[i]=scs[1]end
local matrixT={}for i=0,15 do matrixT[i]={}for j=0,8 do matrixT[i][j]=mt.noise(i,j)+2 end end
local Pnt={}
Pnt.BG={
none=function()
	gc.clear(.15,.15,.15)
end,
grey=function()
	gc.clear(.3,.3,.3)
end,
lightGrey=function()
	gc.clear(.5,.5,.5)
end,
glow=function()
	local t=((sin(Timer()*.5)+sin(Timer()*.7)+sin(Timer()*.9+1)+sin(Timer()*1.5)+sin(Timer()*2+3))+5)*.05
	gc.clear(t,t,t)
end,
game1=function()
	gc.setColor(1,1,1)
	gc.draw(background1,640,360,Timer()*.15,12,nil,64,64)
end,--Rainbow
game2=function()
	gc.setColor(1,.5,.5)
	gc.draw(background1,640,360,Timer()*.2,12,nil,64,64)
end,--Red rainbow
game3=function()
	gc.setColor(.6,.6,1)
	gc.draw(background1,640,360,Timer()*.25,12,nil,64,64)
end,--Blue rainbow
game4=function()
	gc.setColor(.1,.5,.5)
	local x=Timer()%4*320
	gc.draw(background2,x,0,nil,10)
	gc.draw(background2,x-1280,0,nil,10)
end,--Fast strap
game5=function()
	local t=2.5-Timer()%20%6%2.5
	if t<.5 then gc.clear(t,t,t)
	else gc.clear(0,0,0)
	end
end,--Lightning
game6=function()
	local t=1.2-Timer()%10%3%1.2
	if t<.5 then gc.clear(t,t,t)
	else gc.clear(0,0,0)
	end
	gc.setColor(.3,.3,.3)
	local r=7-int(Timer()*.5)%7
	gc.draw(mouseBlock[r],640,360,Timer()%3.1416*6,400,400,scs[r][2]-.5,#blocks[r][0]-scs[r][1]+.5)
end,--Fast lightning&spining tetromino
rgb=function()
	gc.clear(
		sin(Timer()*1.2)*.15+.5,
		sin(Timer()*1.5)*.15+.5,
		sin(Timer()*1.9)*.15+.5
	)
end,
strap=function()
	gc.setColor(1,1,1)
	local x=Timer()%32*40
	gc.draw(background2,x,0,nil,10)
	gc.draw(background2,x-1280,0,nil,10)
end,
matrix=function()
	gc.clear(.15,.15,.15)
	for i=0,15 do
		for j=0,8 do
			local t=sin(matrixT[i][j]*Timer())*.2+.2
			gc.setColor(1,1,1,t)
			gc.rectangle("fill",80*i,80*j,80,80)
		end
	end
end,
}

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
	gc.push()
		gc.translate(250,150)
		gc.scale(30)
		gc.stencil(stencil_miniTitle,"replace",1)
	gc.setStencilTest("equal",1)
		gc.setColor(1,1,1,min(count,80)*.005)
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
	gc.draw(titleImage,280,30,nil,1.3)
	setFont(30)
	gc.print(gameVersion,290,125)
	gc.print(system,845,95)
	setFont(35)
	mStr(modeLevel[modeID[modeSel]][levelSel],160,180)
	mStr(text.modeName[modeSel],160,380)
end
function Pnt.mode()
	gc.setColor(1,1,1)
	gc.draw(titleImage,810,30)
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
	gc.draw(drawableText.nowPlaying,490,110)
	setFont(35)
	for i=1,#musicID do
		gc.print(musicID[i],50,90+30*i)
	end
	setFont(50)
	gc.setColor(sin(Timer()*.5)*.2+.8,sin(Timer()*.7)*.2+.8,sin(Timer())*.2+.8)
	mStr(bgmPlaying or"",630,180)
end
function Pnt.custom()
	gc.setColor(1,1,1,.3+sin(Timer()*8)*.2)
	gc.rectangle("fill",25,95+40*sel,465,40)
	gc.setColor(.8,.8,.8)gc.draw(drawableText.custom,20,20)
	gc.setColor(1,1,1)gc.draw(drawableText.custom,22,23)
	setFont(40)
	for i=1,#customID do
		local k=customID[i]
		local y=90+40*i
		gc.printf(text.customOption[k],30,y,320,"right")
		if text.customVal[k]then
			gc.print(text.customVal[k][customSel[i]],350,y)
		else
			gc.print(customRange[k][customSel[i]],350,y)
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
			drawPixel(y,x,B)
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
		P=players[p]
		if P.small then
			P.frameWait=P.frameWait-1
			if P.frameWait==0 then
				P.frameWait=8
				gc.setCanvas(P.canvas)
				gc.clear(0,0,0,.4)
				gc.push("transform")
				gc.origin()
				gc.setColor(1,1,1,P.result and max(20-P.endCounter,0)*.05 or 1)
				local F=P.field
				for j=1,#F do
					for i=1,10 do if F[j][i]>0 then
						gc.draw(blockSkinmini[F[j][i]],6*i-6,120-6*j)
					end end
				end--Field
				if P.alive then
					gc.setLineWidth(2)
					gc.setColor(frameColor[P.strength])gc.rectangle("line",1,1,58,118)
				end--Draw boarder
				if modeEnv.royaleMode then
					gc.setColor(1,1,1)
					for i=1,P.strength do
						gc.draw(badgeIcon,12*i-7,4,nil,.5)
					end
				end
				if P.result then
					gc.setColor(1,1,1,min(P.endCounter,60)*.01)
					setFont(22)mStr(P.result,32,47)
					setFont(20)mStr(P.rank,30,82)
				end
				gc.pop()
				gc.setCanvas()
				--draw content
			end
			gc.setColor(1,1,1)
			gc.draw(P.canvas,P.x,P.y,nil,P.size*10)
			if P.killMark then
				gc.setLineWidth(3)
				gc.setColor(1,0,0,min(P.endCounter,25)*.04)
				gc.circle("line",P.centerX,P.centerY,(840-20*min(P.endCounter,30))*P.size)
			end
			--draw Canvas
		else
			gc.push("transform")
			gc.translate(P.x,P.y)gc.scale(P.size)--Position
			gc.setColor(0,0,0,.6)gc.rectangle("fill",0,0,600,690)--Background
			gc.setLineWidth(7)
			gc.setColor(frameColor[P.strength])gc.rectangle("line",0,0,600,690,3)--Big frame
			gc.translate(150+P.fieldOffX,70+P.fieldOffY)
			if P.gameEnv.grid then
				gc.setLineWidth(1)
				gc.setColor(1,1,1,.2)
				for x=1,9 do gc.line(30*x,-10,30*x,600)end
				for y=0,19 do
					y=30*(y-int(P.fieldBeneath/30))+P.fieldBeneath
					gc.line(0,y,300,y)
				end
			end--Grid lines
			gc.translate(0,P.fieldBeneath)
			gc.setScissor(scr.x+P.absFieldX*scr.k,scr.y+P.absFieldY*scr.k,300*P.size*scr.k,610*P.size*scr.k)
				local dy,stepY=0,setting.smo and(P.falling/(P.gameEnv.fall+1))^2.5*30 or 30
				local h=1
				for j=int(P.fieldBeneath/30+1),#P.field do
					while j==P.clearing[h]and P.falling>-1 do
						h=h+1
						dy=dy+stepY
						gc.translate(0,-stepY)
						gc.setColor(1,1,1,P.falling/P.gameEnv.fall)
						gc.rectangle("fill",0,630-30*j,320,stepY)
					end
					for i=1,10 do
						if P.field[j][i]>0 then
							gc.setColor(1,1,1,min(P.visTime[j][i]*.05,1))
							drawPixel(j,i,P.field[j][i])
						end
					end
				end--Field
				gc.translate(0,dy)
				for i=1,#P.shade do
					local S=P.shade[i]
					gc.setColor(1,1,1,S[1]*.12)
					for x=S[3],S[5]do
						for y=S[6],S[4]do
							drawPixel(y,x,S[2])
						end
					end
				end--shade FX
				if P.waiting==-1 then
					if P.gameEnv.ghost then
						gc.setColor(1,1,1,.3)
						for i=1,P.r do for j=1,P.c do
							if P.cur.bk[i][j]then
								drawPixel(i+P.y_img-1,j+P.curX-1,P.cur.color)
							end
						end end
					end--Ghost
					-- local dy=setting.smo and(P.y_img~=P.curY and  or 1)^4*30 or 0
					local dy
					if setting.smo then
						if P.y_img~=P.curY then
							dy=(min(P.dropDelay,1e99)/P.gameEnv.drop-1)*30
						else
							dy=0
						end
						--[[
						if P.y_img~=P.curY then
							dy=(min(P.dropDelay,8e98)/P.gameEnv.drop)^4*30
						else
							dy=(min(P.lockDelay,8e98)/P.gameEnv.lock)^(P.gameEnv._20G and 3 or 7)*30
						end
						]]
					else
						dy=0
					end
					gc.translate(0,-dy)
					local trans=P.lockDelay/P.gameEnv.lock
					if P.gameEnv.block then
						gc.setColor(1,1,1,trans)
						for i=1,P.r do for j=1,P.c do
							if P.cur.bk[i][j]then
								gc.rectangle("fill",30*(j+P.curX-1)-33,597-30*(i+P.curY-1),36,36)
							end
						end end--BlockShade(lockdelay indicator)
						gc.setColor(1,1,1)
						for i=1,P.r do for j=1,P.c do
							if P.cur.bk[i][j]then
								drawPixel(i+P.curY-1,j+P.curX-1,P.cur.color)
							end
						end end--Block
					end
					if P.gameEnv.center then
						gc.setColor(1,1,1,trans)
						local x=30*(P.curX+P.sc[2]-1)-30+15
						gc.draw(spinCenter,x,600-30*(P.curY+P.sc[1]-1)+15,nil,nil,nil,4,4)
						gc.translate(0,dy)
						gc.setColor(1,1,1,.5)
						gc.draw(spinCenter,x,600-30*(P.y_img+P.sc[1]-1)+15,nil,nil,nil,4,4)
						goto E
					end--Rotate center
					gc.translate(0,dy)
				end
			::E::
			gc.setScissor()--In-playField things
			gc.setColor(1,1,1)
			gc.draw(PTC.dust[p])
			gc.translate(0,-P.fieldBeneath)
			gc.setBlendMode("replace","alphamultiply")--SPEED UPUP(?)
				gc.setLineWidth(2)
				gc.rectangle("line",-1,-11,302,612)--Draw boarder
				gc.rectangle("line",301,0,15,601)--Draw atkBuffer boarder
				local h=0
				for i=1,#P.atkBuffer do
					local A=P.atkBuffer[i]
					local bar=A.amount*30
					if h+bar>600 then bar=600-h end
					if not A.sent then
						if A.time<20 then
							bar=bar*(20*A.time)^.5*.05
							--Appear
						end
						if A.countdown>0 then
							gc.setColor(attackColor[A.lv][1])
							gc.rectangle("fill",303,599-h,11,-bar+3)
							gc.setColor(attackColor[A.lv][2])
							gc.rectangle("fill",303,599-h+(-bar+3),11,-(-bar+3)*(1-A.countdown/A.cd0))
							--Timing
						else
							local t=sin((Timer()-i)*30)*.5+.5
							local c1,c2=attackColor[A.lv][1],attackColor[A.lv][2]
							gc.setColor(c1[1]*t+c2[1]*(1-t),c1[2]*t+c2[2]*(1-t),c1[3]*t+c2[3]*(1-t))
							gc.rectangle("fill",303,599-h,11,-bar+3)
							--Warning
						end
					else
						gc.setColor(attackColor[A.lv][1])
						bar=bar*(20-A.time)*.05
						gc.rectangle("fill",303,599-h,11,-bar+2)
						--Disappear
					end
					h=h+bar
				end--Buffer line
				local a,b=P.b2b,P.b2b1 if a>b then a,b=b,a end
				gc.setColor(.8,1,.2)
				gc.rectangle("fill",-14,599,11,-b*.5)
				gc.setColor(P.b2b<40 and color.white or P.b2b<=1e3 and color.lightRed or color.lightBlue)
				gc.rectangle("fill",-14,599,11,-a*.5)
				if Timer()%1<.5 then
					gc.rectangle("fill",-15,b<40 and 578.5 or 98.5,13,3)
				end
				gc.setColor(1,1,1)
				gc.rectangle("line",-16,-3,15,604)--Draw b2b bar boarder
				--B2B indictator
				gc.translate(-P.fieldOffX,-P.fieldOffY)
			gc.setBlendMode("alpha")

			if P.gameEnv.hold then
				mDraw(drawableText.hold,-82,-10)
				if P.holded then gc.setColor(.6,.6,.6)end
				for i=1,#P.hold.bk do
					local B=P.hold.bk
					for j=1,#B[1]do
						if B[i][j]then
							drawPixel(i+17.5-#B*.5,j-2.7-#B[1]*.5,P.hold.color)
						end
					end
				end
			end--Hold
			gc.setColor(1,1,1)
			mDraw(drawableText.next,381,-10)
			local N=1
			::L::
			if N<=P.gameEnv.next and P.next[N]then
				local b,c=P.next[N].bk,P.next[N].color
				for i=1,#b do for j=1,#b[1] do
					if b[i][j]then
						drawPixel(i+20-2.4*N-#b*.5,j+12.7-#b[1]*.5,c)
					end
				end end
				N=N+1
				goto L
			end
			--Next
			gc.setColor(.8,.8,.8)
			gc.draw(drawableText.modeName,-135,-65)
			gc.draw(drawableText.levelName,437-drawableText.levelName:getWidth(),-65)
			gc.setColor(1,1,1)
			if frame<180 then
				local count=179-frame
				gc.push("transform")
					gc.translate(155,220)
					setFont(100)
					if count%60>45 then gc.scale(1+(count%60-45)^2*.01,1)end
					mStr(int(count/60+1),0,0)
				gc.pop()
			end--Draw starting counter
			for i=1,#P.bonus do
				P.bonus[i]:draw(min((30-abs(P.bonus[i].t-30))*.05,1)*(not P.bonus[i].inf and #P.field>(9-P.bonus[i].dy*.0333)and .7 or 1))
			end--Effects
			setFont(30)
			gc.setColor(1,1,1)
			mStr(format("%.2f",P.stat.time),-82,518)--Time
			mStr(P.score1,-82,560)--Score
			gc.draw(drawableText.bpm,390,490)
			gc.draw(drawableText.kpm,350,583)
			setFont(30)
			drawDial(360,520,P.dropSpeed)
			drawDial(405,575,P.keySpeed)
			--Speed dials
			gc.setColor(1,1,1)
			if mesDisp[curMode.id]then mesDisp[curMode.id]()end--Other messages
			if modeEnv.royaleMode then
				if P.atkMode then
					gc.setColor(1,.8,0,P.swappingAtkMode*.02)
					gc.rectangle("fill",RCPB[2*P.atkMode-1],RCPB[2*P.atkMode],90,35,8,4)
				end
				gc.setColor(1,1,1,P.swappingAtkMode*.025)
				gc.draw(royaleCtrlPad)
			end
			gc.pop()
		end
	end--Draw players
	gc.setLineWidth(5)
	for i=1,#FX.attack do
		local A=FX.attack[i]
		gc.push("transform")
			local a=A.a
			if A.t<20 then
				gc.translate(A.x1,A.y1)
				a=a*A.t*.05
			elseif A.t<80 then
				local t=((A.t-20)*.016667)t=(3-2*t)*t*t
				gc.translate(A.x1*(1-t)+A.x2*t,A.y1*(1-t)+A.y2*t)
			else
				gc.translate(A.x2,A.y2)
				a=a*(5-A.t*.05)
			end
			gc.rotate(A.t*.1)
			gc.setColor(A.r,A.g,A.b,a*.5)
			gc.circle("line",0,0,A.rad,A.corner)
			gc.setColor(A.r,A.g,A.b,a)
			gc.circle("fill",0,0,A.rad,A.corner)
		gc.pop()
	end
	gc.setColor(1,1,1)
	if setting.virtualkeySwitch then drawVirtualkey()end
	if modeEnv.royaleMode then
		for i=1,#FX.badge do
			local b=FX.badge[i]
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
		P=players[1]
		gc.setLineWidth(5)
		gc.setColor(.8,1,0,.2)
		for i=1,#players[1].atker do
			local p=players[1].atker[i]
			gc.line(p.centerX,p.centerY,P.centerX,P.centerY)
		end
		if P.atkMode~=4 then
			if P.atking then drawAtkPointer(P.atking.centerX,P.atking.centerY)end
		else
			for i=1,#players[1].atker do
				local p=players[1].atker[i]
				drawAtkPointer(p.centerX,p.centerY)
			end
		end
	end
	if restartCount>0 then
		gc.setColor(1,.7,.7,.5+restartCount*.02)
		gc.arc("fill",640,360,735,-1.5708,restartCount*0.3696-1.5708)
		gc.setColor(0,0,0,restartCount/17)
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
		gc.print(text.pauseTime..":["..pauseCount.."] "..format("%0.2f",pauseTime).."s",110,150)
	end
	for i=1,7 do
		gc.print(text.stat[i+3],110,30*i+270)
		gc.print(dataOpt(i),305,30*i+270)
	end
	for i=8,14 do
		gc.print(text.stat[i+3],860,30*i+60)
		gc.print(dataOpt(i),1000,30*i+60)
	end
	setFont(40)
	if system~="Android"then
		mStr(text.space.."/"..text.enter,640,335)
		gc.print("ESC",610,509)
	end
	mDraw(gamefinished and drawableText.finish or drawableText.pause,640,60-10*(5-pauseTimer*.1)^1.5)
end
function Pnt.setting()
	gc.setColor(1,1,1)
	setFont(35)
	mStr("DAS:"..setting.das,290,278)
	mStr("ARR:"..setting.arr,506,278)
	setFont(21)
	mStr(text.softdropdas..setting.sddas,290,357)
	mStr(text.softdroparr..setting.sdarr,506,357)
	gc.draw(blockSkin[7-int(Timer()*2)%7],820,480,nil,2)
end
function Pnt.setting2()
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
	gc.draw(drawableText.setting2Help,50,620)
	setFont(40)
	gc.print("P"..int(curBoard*.5+.5).."/P4",420,560)
	gc.print(curBoard.."/8",580,560)
end
function Pnt.setting3()
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
	setFont(32)
	gc.setColor(1,1,1)
	for i=1,11 do
		gc.printf(text.help[i],140,15+43*i,1000,"center")
	end
	gc.draw(titleImage,250,600,.2,1+.05*sin(Timer()*2),nil,212,35)
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
	for i=1,17 do
		gc.print(text.stat[i],400,30*i-5)
		gc.print(statOpt(i),720,30*i-5)
	end
	gc.draw(titleImage,260,600,.2+.07*sin(Timer()*3),nil,nil,212,35)
end
function Pnt.history()
	gc.setColor(.2,.2,.2,.7)
	gc.rectangle("fill",150,35,980,530)
	gc.setColor(1,1,1)
	gc.setLineWidth(4)
	gc.rectangle("line",150,35,980,530)
	setFont(25)
	gc.print(updateLog[sel],160,40)
end
return Pnt