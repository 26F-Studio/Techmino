swapDeck_data={
	{4,0,1,1},{6,0,15,1},{5,0,9,1},{6,0,6,1},
	{1,0,3,1},{3,0,12,1},{1,1,8,1},{2,1,4,2},
	{3,2,13,2},{4,1,12,2},{5,2,1,2},{7,1,11,2},
	{2,1,9,3},{3,0,6,3},{4,2,14,3},{1,0,4,4},
	{7,1,1,4},{6,0,2,4},{5,2,6,4},{6,0,14,5},
	{3,3,15,5},{4,0,7,6},{7,1,10,5},{5,0,2,6},
	{2,1,1,7},{1,0,4,6},{4,1,13,5},{1,1,6,7},
	{5,3,11,5},{3,2,11,7},{6,0,8,7},{4,2,12,8},
	{7,0,8,9},{1,0,2,8},{5,2,4,8},{6,0,15,8},
}--Block id [ZSLJTOI] ,dir,x,y
swap={
	none={2,1,d=function()end},
	flash={8,1,d=function()gc.clear(1,1,1)end},
	deck={50,8,d=function()
		local t=sceneSwaping.time
		gc.setColor(1,1,1)
		if t>8 then
			local t=max(t,15)
			for i=1,51-t do
				local bn=swapDeck_data[i][1]
				local b=blocks[bn][swapDeck_data[i][2]]
				local cx,cy=swapDeck_data[i][3],swapDeck_data[i][4]
				for y=1,#b do for x=1,#b[1]do
					if b[y][x]>0 then
						gc.draw(blockSkin[bn],80*(cx+x-2),80*(10-cy-y),nil,8/3)
					end
				end end
			end
		end
		if t<17 then
			gc.setColor(1,1,1,(8-abs(t-8))*.125)
			gc.rectangle("fill",0,0,1280,720)
		end
	end
},
}--Scene swapping animations
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
			local k=t.t^.5*.2+1
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

function updateButton()
	for i=1,#Buttons[scene]do
		local B=Buttons[scene][i]
		local t=i==Buttons.sel and .4 or 0
		B.alpha=abs(B.alpha-t)>.02 and(B.alpha+(B.alpha<t and .02 or -.02))or t
		if B.alpha>t then B.alpha=B.alpha-.02 elseif B.alpha<t then B.alpha=B.alpha+.02 end
	end
end
function drawButton()
	for i=1,#Buttons[scene]do
		local B=Buttons[scene][i]
		if not(B.hide and B.hide())then
			local C=B.rgb or color.white
			gc.setColor(C[1],C[2],C[3],B.alpha)
			gc.rectangle("fill",B.x-B.w*.5,B.y-B.h*.5,B.w,B.h)
			gc.setColor(C[1],C[2],C[3],.3)
			gc.setLineWidth(5)gc.rectangle("line",B.x-B.w*.5,B.y-B.h*.5,B.w,B.h)
			local t=B.t
			local y0
			if t then
				if type(t)=="function"then t=t()end
				setFont(B.f or 40)
				y0=B.y-7-currentFont*.5
				mStr(t,B.x-1,y0)
				mStr(t,B.x+1,y0)
				mStr(t,B.x-1,y0+2)
				mStr(t,B.x+1,y0+2)
			end
			gc.setColor(C)
			if t then
				mStr(t,B.x,y0+1)
			end
			gc.setLineWidth(3)gc.rectangle("line",B.x-B.w*.5,B.y-B.h*.5,B.w,B.h,4)
		end
	end
end
function drawDial(x,y,speed)
	gc.setColor(1,1,1)
	mStr(int(speed),x,y-18)
	gc.draw(dialCircle,x,y,nil,nil,nil,32,32)
	gc.setColor(1,1,1,.6)
	gc.draw(dialNeedle,x,y,2.094+(speed<=175 and .02094*speed or 4.712-52.36/(speed-125)),nil,nil,5,4)
end
function drawPixel(y,x,id,alpha)
	gc.setColor(1,1,1,alpha)
	gc.draw(blockSkin[id],30*x-30,600-30*y)
end
function drawAtkPointer(x,y)
	gc.setColor(0,.6,1,.35+sin(Timer()*20)*.2)
	gc.circle("fill",x,y,25,6)
	local a=Timer()*3%1*.8
	gc.setColor(0,.6,1,.8-a)
	gc.circle("line",x,y,25*(1+a),6)
end

function VirtualkeyPreview()
	for i=1,#virtualkey do
		gc.setColor(1,sel==i and .5 or 1,sel==i and .5 or 1,setting.virtualkeyAlpha*.2)
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
		local p,b=virtualkeyDown[i],virtualkey[i]
		if p then gc.setColor(.75,.75,.75,a)
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

Pnt={}
Pnt.BG={
	none=function()
		gc.clear(.2,.2,.2)
	end,
	glow=function()
		local t=((sin(Timer()*.5)+sin(Timer()*.7)+sin(Timer()*.9+1)+sin(Timer()*1.5)+sin(Timer()*2+3))+5)*.05
		gc.clear(t,t,t)
	end,
	game1=function()
		gc.setColor(1,1,1)
		gc.draw(background1,640,360,Timer()*.15,12,nil,64,64)
	end,
	game2=function()
		gc.setColor(1,.5,.5)
		gc.draw(background1,640,360,Timer()*.2,12,nil,64,64)
	end,
	game3=function()
		gc.setColor(.6,.6,1)
		gc.draw(background1,640,360,Timer()*.25,12,nil,64,64)
	end,
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
		for i=0,15 do
			for j=0,8 do
				-- local t=sin(Timer()*((2.468*i-1.357*j)%3))*.3
				local t=(sin((mt.noise(i,j)+2)*Timer())+1)*.2
				gc.setColor(t,t,t)
				gc.rectangle("fill",80*i,80*j,80,80)
			end
		end
	end,
}

function Pnt.load()
	gc.setLineWidth(4)
	gc.setColor(1,1,1,.5)
	gc.rectangle("fill",300,330,loadprogress*680,60)
	gc.setColor(1,1,1)
	gc.rectangle("line",300,330,680,60)
	setFont(40)
	mStr(text.load[loading],640,335)
	setFont(25)
	mStr(text.loadTip,640,400)
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
		gc.setColor(1,1,1)
		gc.setColor(1,1,1,.125)
		for i=19,5,-2 do
			gc.setLineWidth(i)
			gc.line(250+(count-80)*25,150,(count-80)*25-150,570)
		end
	gc.setStencilTest()
end
function Pnt.main()
	gc.setColor(1,1,1)
	setFont(30)
	gc.print("Alpha V0.7.9",370,140)
	gc.print(system,530,110)
	gc.draw(titleImage,30,30)
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
	setFont(80)
	gc.setColor(color.lightGrey)
	gc.print(text.custom,20,20)
	gc.setColor(color.white)
	gc.print(text.custom,22,23)
	setFont(40)
	for i=1,#customID do
		local k=customID[i]
		local y=90+40*i
		gc.print(customOption[k],50,y)
		if customVal[k]then
			gc.print(customVal[k][customSel[k]],350,y)
		else
			gc.print(customRange[k][customSel[k]],350,y)
		end
	end
	gc.print("→",10,90+40*optSel)
end
function Pnt.play()
	for p=1,#players do
		P=players[p]
		if P.small then
			gc.push("transform")
			gc.translate(P.x,P.y)gc.scale(P.size)--Scale
			gc.setColor(0,0,0,.4)gc.rectangle("fill",0,0,60,120)--Black Background
			gc.stencil(stencil_field_small,"replace",1)
			gc.translate(0,P.fieldBeneath*.2)
			gc.setStencilTest("equal",1)
			gc.setColor(1,1,1,P.result and max(20-P.endCounter,0)*.05 or 1)
			for j=int(P.fieldBeneath/30+1),#P.field do
				if P.falling<=0 or without(P.clearing,j)then
					for i=1,10 do
						if P.field[j][i]>0 then
							gc.draw(blockSkinmini[P.field[j][i]],6*i-6,120-6*j)
						end
					end
				end
			end
			gc.setStencilTest()--In-playField mask
			gc.translate(0,-P.fieldBeneath*.2)
			gc.setLineWidth(2)
			gc.setColor(frameColor[P.strength])gc.rectangle("line",-1,-1,62,122)--Draw boarder
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
			gc.translate(P.x,P.y)gc.scale(P.size)
			gc.setColor(0,0,0,.6)gc.rectangle("fill",0,0,600,690)--Black Background
			gc.setLineWidth(7)
			gc.setColor(frameColor[P.strength])gc.rectangle("line",0,0,600,690)--Big frame
			gc.stencil(stencil_field,"replace", 1)
			gc.translate(150,70+P.fieldBeneath)
			gc.setStencilTest("equal",1)
				for j=int(P.fieldBeneath/30+1),#P.field do
					if P.falling<=0 or without(P.clearing,j)then
						for i=1,10 do
							if P.field[j][i]>0 then
								drawPixel(j,i,P.field[j][i],min(P.visTime[j][i],20)*.05)
							end
						end
					else
						gc.setColor(1,1,1,P.falling/P.gameEnv.fall)
						gc.rectangle("fill",0,600-30*j,320,30)
					end
				end--Field
				if P.waiting<=0 then
					if P.gameEnv.ghost then
						for i=1,P.r do for j=1,P.c do
							if P.cb[i][j]>0 then
								drawPixel(i+P.y_img-1,j+P.cx-1,P.bc,.3)
							end
						end end
					end--Ghost
					gc.setColor(1,1,1,P.lockDelay/P.gameEnv.lock)
					for i=1,P.r do for j=1,P.c do
						if P.cb[i][j]>0 then
							gc.rectangle("fill",30*(j+P.cx-1)-34,596-30*(i+P.cy-1),38,38)
						end
					end end--BlockShade(lockdelay indicator)
					for i=1,P.r do for j=1,P.c do
						if P.cb[i][j]>0 then
							drawPixel(i+P.cy-1,j+P.cx-1,P.bc,1)
						end
					end end--Block
					if P.gameEnv.center then
						local x=30*(P.cx+P.sc[2]-1)-30+15
						gc.draw(spinCenter,x,600-30*(P.cy+P.sc[1]-1)+15,nil,nil,nil,4,4)
						gc.setColor(1,1,1,.5)
						gc.draw(spinCenter,x,600-30*(P.y_img+P.sc[1]-1)+15,nil,nil,nil,4,4)
					end--Rotate center
				end
				gc.setColor(1,1,1)
				gc.draw(PTC.dust[p])--Draw game field
			gc.setStencilTest()--In-playField mask
			gc.translate(0,-P.fieldBeneath)
			gc.setLineWidth(3)
			gc.setColor(1,1,1)gc.rectangle("line",-1,-11,302,612)--Draw boarder

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
						gc.rectangle("fill",304,600-h,12,-bar+3)
						gc.setColor(attackColor[a.lv][2])
						gc.rectangle("fill",304,600-h+(-bar+3),12,-(-bar+3)*(1-a.countdown/a.cd0))
						--Timing
					else
						attackColor.animate[a.lv]((sin((Timer()-i)*20)+1)*.5)
						gc.rectangle("fill",304,600-h,12,-bar+3)
						--Warning
					end
				else
					gc.setColor(attackColor[a.lv][1])
					bar=bar*(20-a.time)*.05
					gc.rectangle("fill",304,600-h,12,-bar+2)
					--Disappear
				end
				h=h+bar
			end--Buffer line

			gc.setColor(P.b2b<40 and color.white or P.b2b<=480 and color.lightRed or color.lightBlue)
			gc.rectangle("fill",-13,600,10,-P.b2b1)
			gc.setColor(color.red)
			gc.rectangle("fill",-19,600-40,16,5)
			gc.setColor(color.blue)
			gc.rectangle("fill",-19,600-480,16,5)
			--B2B bar

			setFont(40)
			gc.setColor(1,1,1)
			if P.gameEnv.hold then
				gc.print("Hold",-115,-10)
				for i=1,#P.hb do
					for j=1,#P.hb[1] do
						if P.hb[i][j]>0 then
							drawPixel(i+17.5-#P.hb*.5,j-2.5-#P.hb[1]*.5,P.holded and 13 or P.hid,1)
						end
					end
				end
			end--Hold
			gc.print("Next",336,-10)
			for N=1,P.gameEnv.next do
				local b=P.nb[N]
				for i=1,#b do
					for j=1,#b[1] do
						if b[i][j]>0 then
							drawPixel(i+20-2.4*N-#b*.5,j+12.5-#b[1]*.5,P.nxt[N],1)
						end
					end
				end
			end--Next
			setFont(30)
			gc.setColor(.8,.8,.8)
			gc.print(curMode.modeName,-135,-65)
			gc.printf(curMode.levelName,240,-65,200,"right")
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
			mStr(format("%.2f",P.time),-75,520)--Draw time
			if mesDisp[curMode.id]then mesDisp[curMode.id]()end--Draw other message

			gc.setColor(1,1,1)
			setFont(15)
			gc.print("BPM",390,490)
			gc.print("KPM",350,583)
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
	for i=1,3 do
		gc.draw(PTC.attack[i])
	end
	if setting.virtualkeySwitch then
		drawVirtualkey()
	end
	if modeEnv.royaleMode then
		for i=1,#FX.badge do
			local b=FX.badge[i]
			local t=b.t<10 and 0 or b.t<50 and(sin(1.5*(b.t/20-1.5))+1)*.5 or 1
			gc.setColor(1,1,1,b.t<10 and b.t*.1 or b.t<50 and 1 or(60-b.t)*.1)
			gc.draw(badgeIcon,b[1]+(b[3]-b[1])*t,b[2]+(b[4]-b[2])*t,nil,b.size,nil,14,14)
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
end
function Pnt.setting()
	gc.setColor(1,1,1)
	setFont(35)
	mStr("DAS:"..setting.das,288,158)
	mStr("ARR:"..setting.arr,503,158)
	setFont(18)
	mStr(text.softdropdas..setting.sddas,288,249)
	mStr(text.softdroparr..setting.sdarr,503,249)
end
function Pnt.setting2()
	if keyboardSetting then
		gc.setColor(1,.5,.5,.2+(sin(Timer()*15)+1)*.1)
	else
		gc.setColor(.9,.9,.9,.2+(sin(Timer()*15)+1)*.1)
	end
	gc.rectangle("fill",240,40*keyboardSet-10,200,40)
	if joystickSetting then
		gc.setColor(1,.5,.5,.2+(sin(Timer()*15)+1)*.1)
	else
		gc.setColor(.9,.9,.9,.2+(sin(Timer()*15)+1)*.1)
	end
	gc.rectangle("fill",440,40*joystickSet-10,200,40)

	gc.setColor(1,1,1)
	setFont(25)
	for y=1,13 do
		mStr(text.actName[y],150,40*y)
		for x=1,2 do
			mStr(setting.keyMap[curBoard+x*8-8][y],200*x+140,40*y-3)
		end
		gc.line(40,40*y-10,640,40*y-10)
	end
	for x=1,4 do
		gc.line(200*x-160,30,200*x-160,550)
	end
	gc.line(40,550,640,550)
	gc.print(text.keyboard,335,1)
	gc.print(text.joystick,420,1)
	gc.print(text.setting2Help,50,620)
	setFont(40)
	gc.print("< P"..curBoard.."/P8 >",430,570)
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
end
function Pnt.stat()
	setFont(35)
	gc.setColor(1,1,1)
	for i=1,10 do
		gc.print(text.stat[i],350,20+40*i)
	end

	gc.print(stat.run,650,60)
	gc.print(stat.game,650,100)
	gc.print(format("%0.2f",stat.gametime).."s",650,140)
	gc.print(stat.piece,650,180)
	gc.print(stat.row,650,220)
	gc.print(stat.atk,650,260)
	gc.print(stat.key,650,300)
	gc.print(stat.rotate,650,340)
	gc.print(stat.hold,650,380)
	gc.print(stat.spin,650,420)

	gc.draw(titleImage,260,570,.2+.07*sin(Timer()*3),.8,nil,250,60)
end