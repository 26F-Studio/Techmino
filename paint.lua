local gc=love.graphics
local mt=love.math
local setFont=setFont
local Timer=love.timer.getTime

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
	["HARD+"]=color.darkMagenta,
	LUNATIC=color.red,
	EXTRA=color.lightMagenta,
	ULTIMATE=color.lightYellow,

	MESS=color.lightGrey,
	GM=color.blue,
	DEATH=color.lightRed,
	CTWC=color.lightBlue,
	["10L"]=color.cyan,
	["20L"]=color.lightBlue,
	["40L"]=color.green,
	["100L"]=color.orange,
	["400L"]=color.red,
	["1000L"]=color.darkRed,
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
	beam={},--Attack beam
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

function drawDial(x,y,speed)
	gc.setColor(1,1,1)
	mStr(int(speed),x,y-18)
	gc.draw(dialCircle,x,y,nil,nil,nil,32,32)
	gc.setColor(1,1,1,.6)
	gc.draw(dialNeedle,x,y,2.094+(speed<=175 and .02094*speed or 4.712-52.36/(speed-125)),nil,nil,5,4)
end
function drawPixel(y,x,id)
	gc.draw(blockSkin[id],30*x-30,600-30*y)
end
function drawAtkPointer(x,y)
	local t=sin(Timer()*20)
	gc.setColor(.2,.7+t*.2,1,.6+t*.4)
	gc.circle("fill",x,y,25,6)
	local a=Timer()*3%1*.8
	gc.setColor(0,.6,1,.8-a)
	gc.circle("line",x,y,30*(1+a),6)
end

function VirtualkeyPreview()
	for i=1,#virtualkey do
		local c=sel==i and .8 or 1
		gc.setColor(c,c,c,setting.virtualkeyAlpha*.2)
		local b=virtualkey[i]
		gc.setLineWidth(b[4]*.07)
		gc.circle("line",b[1],b[2],b[4]-5)
		if setting.virtualkeyIcon then gc.draw(virtualkeyIcon[i],b[1],b[2],nil,b[4]*.025,nil,18,18)end
	end
end
function drawVirtualkey()
	local a=setting.virtualkeyAlpha*.2
	local P=players[1]
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

Pnt={BG={}}
function Pnt.BG.none()
	gc.clear(.15,.15,.15)
end
function Pnt.BG.grey()
	gc.clear(.3,.3,.3)
end
function Pnt.BG.glow()
	local t=((sin(Timer()*.5)+sin(Timer()*.7)+sin(Timer()*.9+1)+sin(Timer()*1.5)+sin(Timer()*2+3))+5)*.05
	gc.clear(t,t,t)
end
function Pnt.BG.game1()
	gc.setColor(1,1,1)
	gc.draw(background1,640,360,Timer()*.15,12,nil,64,64)
end
function Pnt.BG.game2()
	gc.setColor(1,.5,.5)
	gc.draw(background1,640,360,Timer()*.2,12,nil,64,64)
end
function Pnt.BG.game3()
	gc.setColor(.6,.6,1)
	gc.draw(background1,640,360,Timer()*.25,12,nil,64,64)
end
function Pnt.BG.game4()
	gc.setColor(.1,.5,.5)
	local x=Timer()%4*320
	gc.draw(background2,x,0,nil,10)
	gc.draw(background2,x-1280,0,nil,10)
end
function Pnt.BG.game5()
	local t=2.5-Timer()%20%6%2.5
	if t<.5 then gc.clear(t,t,t)
	else gc.clear(0,0,0)
	end
end
local scs={{1,2},nil,nil,nil,nil,{1.5,1.5},{0.5,2.5}}for i=2,5 do scs[i]=scs[1]end
function Pnt.BG.game6()
	local t=1.2-Timer()%10%3%1.2
	if t<.5 then gc.clear(t,t,t)
	else gc.clear(0,0,0)
	end
	gc.setColor(.3,.3,.3)
	local r=7-int(Timer()*.5)%7
	gc.draw(mouseBlock[r],640,360,Timer()%pi*6,400,400,scs[r][2]-.5,#blocks[r][0]-scs[r][1]+.5)
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
local matrixT={}for i=0,15 do matrixT[i]={}for j=0,8 do matrixT[i][j]=mt.noise(i,j)+2 end end
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
	gc.draw(titleImage,300,30)
	setFont(30)
	gc.print("Alpha V0.7.18",290,140)
	gc.print(system,800,110)
end
function Pnt.mode()
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
function Pnt.custom()
	gc.setColor(1,1,1,.3+sin(Timer()*8)*.2)
	gc.rectangle("fill",25,95+40*optSel,465,40)
	gc.setColor(.8,.8,.8)gc.draw(drawableText.custom,20,20)
	gc.setColor(1,1,1)gc.draw(drawableText.custom,22,23)
	setFont(40)
	for i=1,#customID do
		local k=customID[i]
		local y=90+40*i
		gc.printf(text.customOption[k],30,y,320,"right")
		if text.customVal[k]then
			gc.print(text.customVal[k][customSel[k]],350,y)
		else
			gc.print(customRange[k][customSel[k]],350,y)
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
	for y=1,20 do for x=1,10 do
		if preField[y][x]>0 then
			drawPixel(y,x,preField[y][x])
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
	else
		gc.setColor(.8,.8,.8)
		gc.draw(drawableText.x,950,560)
	end
end
function Pnt.play()
	for p=1,#players do
		P=players[p]
		if P.small then
			gc.push("transform")
			gc.translate(P.x,P.y)gc.scale(P.size)--Position
			gc.setColor(0,0,0,.4)gc.rectangle("fill",0,0,60,120)--Background
			gc.translate(0,P.fieldBeneath*.2)
			gc.setScissor(scr.x+P.x*scr.k,scr.y+P.y*scr.k,60*P.size*scr.k,120*P.size*scr.k)
			gc.setColor(1,1,1,P.result and max(20-P.endCounter,0)*.05 or 1)
			local h=#P.clearing
			for j=int(P.fieldBeneath/30+1),#P.field do
				if j==P.clearing[h]and P.falling>-1 then
					h=h-1
				else
					for i=1,10 do
						if P.field[j][i]>0 then
							gc.draw(blockSkinmini[P.field[j][i]],6*i-6,120-6*j)
						end
					end
				end
			end--Field
			gc.setScissor()
			gc.translate(0,-P.fieldBeneath*.2)
			if P.alive then
				gc.setLineWidth(2)
				gc.setColor(frameColor[P.strength])gc.rectangle("line",-1,-1,62,122)
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
				if P.killMark then
					gc.setLineWidth(4)
					gc.setColor(1,0,0,min(P.endCounter,25)*.04)
					gc.circle("line",31,60,84-2*min(P.endCounter,30))
				end
			end
			gc.pop()
		else
			gc.push("transform")
			gc.translate(P.x,P.y)gc.scale(P.size)--Position
			gc.setColor(0,0,0,.6)gc.rectangle("fill",0,0,600,690)--Background
			gc.setLineWidth(7)
			gc.setColor(frameColor[P.strength])gc.rectangle("line",0,0,600,690,3)--Big frame
			gc.translate(150,70)
			if P.gameEnv.grid then
				gc.setLineWidth(1)
				gc.setColor(1,1,1,.2)
				for x=1,9 do gc.line(30*x,-10,30*x,600)end
				for y=0,19 do gc.line(0,30*y,300,30*y)end
			end--Grid lines
			gc.translate(0,P.fieldBeneath)
			gc.setScissor(scr.x+P.absFieldPos[1]*scr.k,scr.y+P.absFieldPos[2]*scr.k,300*P.size*scr.k,610*P.size*scr.k)
				local h=#P.clearing
				for j=int(P.fieldBeneath/30+1),#P.field do
					if j==P.clearing[h]and P.falling>-1 then
						h=h-1
						gc.setColor(1,1,1,P.falling/P.gameEnv.fall)
						gc.rectangle("fill",0,600-30*j,320,30)
					else
						for i=1,10 do
							if P.field[j][i]>0 then
								gc.setColor(1,1,1,min(P.visTime[j][i]*.05,1))
								drawPixel(j,i,P.field[j][i])
							end
						end
					end
				end--Field
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
					if P.gameEnv.block then
						gc.setColor(1,1,1,P.lockDelay/P.gameEnv.lock)
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
						gc.setColor(1,1,1)
						local x=30*(P.curX+P.sc[2]-1)-30+15
						gc.draw(spinCenter,x,600-30*(P.curY+P.sc[1]-1)+15,nil,nil,nil,4,4)
						gc.setColor(1,1,1,.5)
						gc.draw(spinCenter,x,600-30*(P.y_img+P.sc[1]-1)+15,nil,nil,nil,4,4)
					end--Rotate center
				end
				gc.setColor(1,1,1)
				gc.draw(PTC.dust[p])
				--Draw game field
			gc.setScissor()--In-playField mask
			gc.translate(0,-P.fieldBeneath)
			gc.setLineWidth(3)
			gc.setColor(1,1,1)
			gc.rectangle("line",-1,-11,302,612)--Draw boarder

			gc.setLineWidth(2)
			gc.rectangle("line",301,0,16,601.5)--Draw atkBuffer boarder
			local h=0
			for i=1,#P.atkBuffer do
				local a=P.atkBuffer[i]
				local bar=a.amount*30
				if h+bar>600 then bar=600-h end
				if not a.sent then
					if a.time<20 then
						bar=bar*(20*a.time)^.5*.05
						--Appear
					end
					if a.countdown>0 then
						gc.setColor(attackColor[a.lv][1])
						gc.rectangle("fill",304,599-h,11,-bar+3)
						gc.setColor(attackColor[a.lv][2])
						gc.rectangle("fill",304,599-h+(-bar+3),11,-(-bar+3)*(1-a.countdown/a.cd0))
						--Timing
					else
						local t=sin((Timer()-i)*30)*.5+.5
						local c1,c2=attackColor[a.lv][1],attackColor[a.lv][2]
						gc.setColor(c1[1]*t+c2[1]*(1-t),c1[2]*t+c2[2]*(1-t),c1[3]*t+c2[3]*(1-t))
						gc.rectangle("fill",304,599-h,11,-bar+3)
						--Warning
					end
				else
					gc.setColor(attackColor[a.lv][1])
					bar=bar*(20-a.time)*.05
					gc.rectangle("fill",304,599-h,11,-bar+2)
					--Disappear
				end
				h=h+bar
			end--Buffer line
			local a,b=P.b2b,P.b2b1 if a>b then a,b=b,a end
			gc.setColor(.8,1,.2)
			gc.rectangle("fill",-15,599.5,11,-b*.5)
			gc.setColor(P.b2b<40 and color.white or P.b2b<=1e3 and color.lightRed or color.lightBlue)
			gc.rectangle("fill",-15,599.5,11,-a*.5)
			gc.setColor(1,1,1,.5+sin(Timer()*30)*.5)
			gc.rectangle("fill",-16,b<40 and 578.5 or 98.5,13,3)
			gc.setColor(1,1,1)
			gc.rectangle("line",-17,-3,16,604.5)--Draw b2b bar boarder
			--B2B indictator

			if P.gameEnv.hold then
				gc.setColor(1,1,1)
				mDraw(drawableText.hold,-82,-10)
				for i=1,#P.hold.bk do
					for j=1,#P.hold.bk[1] do
						if P.hold.bk[i][j]then
							drawPixel(i+17.5-#P.hold.bk*.5,j-2.7-#P.hold.bk[1]*.5,P.holded and 9 or P.hold.color)
						end
					end
				end
			end--Hold
			mDraw(drawableText.next,381,-10)
			local N=1
			::L::
				local b,c=P.next[N].bk,P.next[N].color
				gc.setColor(1,1,1)
				for i=1,#b do for j=1,#b[1] do
					if b[i][j]then
						drawPixel(i+20-2.4*N-#b*.5,j+12.7-#b[1]*.5,c)
					end
				end end
				N=N+1
			if N<=P.gameEnv.next and P.next[N]then goto L end
			--Next
			gc.setColor(.8,.8,.8)
			gc.draw(drawableText.modeName,-135,-65)
			gc.draw(drawableText.levelName,437-drawableText.levelName:getWidth(),-65)
			if frame<180 then
				local count=179-frame
				gc.push("transform")
					gc.translate(155,220)
					gc.setColor(1,1,1)
					setFont(100)
					if count%60>45 then gc.scale(1+(count%60-45)^2*.01,1)end
					mStr(int(count/60+1),0,0)
				gc.pop()
			end--Draw starting counter
			for i=1,#P.bonus do
				P.bonus[i]:draw(min((30-abs(P.bonus[i].t-30))*.05,1)*(not P.bonus[i].inf and #P.field>(9-P.bonus[i].dy*.0333)and .7 or 1))
			end--Effects

			gc.setColor(1,1,1)
			setFont(35)
			mStr(format("%.2f",P.stat.time),-82,520)--Draw time
			if mesDisp[curMode.id]then mesDisp[curMode.id]()end--Draw other message

			gc.setColor(1,1,1)
			gc.draw(drawableText.bpm,390,490)
			gc.draw(drawableText.kpm,350,583)
			setFont(30)
			drawDial(360,520,P.dropSpeed)
			drawDial(405,575,P.keySpeed)
			--Speed dials
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
	gc.setColor(1,1,1)
	gc.draw(PTC.attack[1])
	gc.draw(PTC.attack[2])
	gc.draw(PTC.attack[3])
	if setting.virtualkeySwitch then drawVirtualkey()end
	if modeEnv.royaleMode then
		for i=1,#FX.badge do
			local b=FX.badge[i]
			local t=b.t<10 and 0 or b.t<50 and .5+sin(1.5*(b.t/20-1.5))*.5 or 1
			gc.setColor(1,1,1,b.t<10 and b.t*.1 or b.t<50 and 1 or(60-b.t)*.1)
			gc.draw(badgeIcon,b[1]+(b[3]-b[1])*t,b[2]+(b[4]-b[2])*t,nil,nil,nil,14,14)
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
		mStr(text.space.."/"..text.enter,640,300)
		gc.print("ESC",610,598)
	end
	mDraw(gamefinished and drawableText.finish or drawableText.pause,640,140-12*(5-pauseTimer*.1)^2)
end
function Pnt.setting()
	gc.setColor(1,1,1)
	setFont(35)
	mStr("DAS:"..setting.das,290,278)
	mStr("ARR:"..setting.arr,506,278)
	setFont(18)
	mStr(text.softdropdas..setting.sddas,290,361)
	mStr(text.softdroparr..setting.sdarr,506,361)
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
	gc.draw(titleImage,180,600,.2,.7+.05*sin(Timer()*2),nil,140,100)
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
	gc.draw(titleImage,260,570,.2+.07*sin(Timer()*3),.8,nil,250,60)
end