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
	deck={42,1,d=function()
		local t=sceneSwaping.time
		gc.setColor(1,1,1)
		if t>6 then
			for i=1,43-t do
				local bn=swapDeck_data[i][1]
				local b=blocks[bn][swapDeck_data[i][2]]
				local cx,cy=swapDeck_data[i][3],swapDeck_data[i][4]
				for y=1,#b do for x=1,#b[1]do
					if b[y][x]>0 then
						gc.draw(blockSkin[bn],80*(cx+x-2),80*(10-cy-y),nil,8/3)
					end
				end end
			end
		else
			gc.clear(1,1,1)
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
			gc.setColor(1,1,1,a)
			if t.t<20 then gc.scale((20-t.t)*.015+1,1)end
			mStr(t.text,0,-t.font*.5)
		gc.pop()
	end,
	drive=function(t,a)
		gc.push("transform")
			setFont(t.font)
			gc.translate(150,290+t.dy)
			gc.setColor(1,1,1,a)
			if t.t<20 then gc.shear((20-t.t)*.05,0)end
			mStr(t.text,0,-t.font*.5)
		gc.pop()
	end,
	spin=function(t,a)
		gc.push("transform")
			setFont(t.font)
			gc.translate(150,250+t.dy)
			gc.setColor(1,1,1,a)
			if t.t<20 then
				gc.rotate((20-t.t)^2*.0015)
			end
			mStr(t.text,0,-t.font*.5)
		gc.pop()
	end,
	flicker=function(t,a)
		setFont(t.font)
		gc.setColor(1,1,1,a*(rnd()+.5))
		mStr(t.text,150,250-t.font*.5+t.dy)
	end,
	zoomout=function(t,a)
		gc.push("transform")
			setFont(t.font)
			gc.translate(150,290+t.dy)
			gc.setColor(1,1,1,a)
			local k=t.t^.5*.2+1
			gc.scale(k,k)
			mStr(t.text,0,-t.font*.5)
		gc.pop()
	end
}

function drawButton()
	for i=1,#Buttons[scene]do
		local B=Buttons[scene][i]
		if not(B.hide and B.hide())then
			local t=i==Buttons.sel and .3 or 0
			B.alpha=abs(B.alpha-t)>.02 and(B.alpha+(B.alpha<t and .02 or -.02))or t
			if B.alpha>t then B.alpha=B.alpha-.02 elseif B.alpha<t then B.alpha=B.alpha+.02 end
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
				y0=B.y-1-currentFont*.5
				mStr(t,B.x-1,y0)
				mStr(t,B.x+1,y0)
				mStr(t,B.x-1,y0+2)
				mStr(t,B.x+1,y0+2)
			end
			gc.setColor(C)
			if t then
				mStr(t,B.x,y0+1)
			end
			gc.setLineWidth(3)gc.rectangle("line",B.x-B.w*.5,B.y-B.h*.5,B.w,B.h)
		end
	end
end
function drawDial(x,y,speed)
	gc.push("transform")
		gc.translate(x,y)
		gc.setColor(1,1,1)
		mStr(int(speed),0,-14)
		gc.draw(dialCircle,0,0,nil,nil,nil,32,32)
		gc.setColor(1,1,1,.6)
		gc.draw(dialNeedle,0,0,2.0944+(speed<=175 and .020944*speed or 4.712389-52.35988/(speed-125)),nil,nil,5,4)
	gc.pop()
end
function drawPixel(y,x,id,alpha)
	gc.setColor(1,1,1,alpha)
	gc.draw(blockSkin[id],30*x-30,600-30*y)
end
function drawVirtualkey(s)
	gc.setLineWidth(10)
	if s then
		for i=1,#virtualkey do
			gc.setColor(1,s==i and 0 or 1,s==i and 0 or 1,setting.virtualkeyAlpha*.2)
			local b=virtualkey[i]
			gc.circle("line",b[1],b[2],b[4]-5)
			if setting.virtualkeyIcon then gc.draw(virtualkeyIcon[i],b[1],b[2],nil,2*b[4]*.0125,nil,18,18)end
		end
	else
		gc.setColor(1,1,1,setting.virtualkeyAlpha*.2)
		for i=1,#virtualkey do
			local b=virtualkey[i]
			gc.circle("line",b[1],b[2],b[4]-5)
			if setting.virtualkeyIcon then gc.draw(virtualkeyIcon[i],b[1],b[2],nil,2*b[4]*.0125,nil,18,18)end
		end
	end
end

Pnt={BG={}}
function Pnt.BG.none()
	gc.clear(.2,.2,.2)
end
function Pnt.BG.glow()
	local t=((sin(Timer()*.5)+sin(Timer()*.7)+sin(Timer()*.9+1)+sin(Timer()*1.5)+sin(Timer()*2+3))+5)*.05
	gc.clear(t,t,t)
end
function Pnt.BG.game1()
	gc.setColor(1,1,1)
	gc.draw(background[1],640,360,Timer()*.15,12,nil,64,64)
end
function Pnt.BG.game2()
	gc.setColor(1,.5,.5)
	gc.draw(background[1],640,360,Timer()*.2,12,nil,64,64)
end
function Pnt.BG.game3()
	gc.setColor(.6,.6,1)
	gc.draw(background[1],640,360,Timer()*.25,12,nil,64,64)
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
	gc.draw(background[2],x,0,nil,10)
	gc.draw(background[2],x-1280,0,nil,10)
end
function Pnt.BG.matrix()
	for i=0,15 do
		for j=0,8 do
			local t=sin(Timer()*((2.468*i-1.357*j)%3))*.3
			gc.setColor(t,t,t)
			gc.rectangle("fill",80*i,80*j,80,80)
		end
	end
end

function Pnt.load()
	gc.setLineWidth(4)
	gc.setColor(1,1,1,.5)
	gc.rectangle("fill",340,340,loadprogress*640,40)
	gc.setColor(1,1,1)
	gc.rectangle("line",340,340,640,40)
	setFont(30)
	mStr(Text.load[loading],640,346)
	setFont(20)
	mStr("not animation,real loading!",640,392)
end
function Pnt.main()
	gc.setColor(1,1,1)
	setFont(30)
	gc.print("Alpha V0.7.1",370,150)
	gc.print(system,530,110)
	gc.draw(titleImage,30,30)
end
function Pnt.mode()
	setFont(30)
	mStr(modeInfo[modeID[modeSel]],270,300)
	setFont(80)
	gc.setColor(color.grey)
	mStr(modeName[modeSel],643,283)
	for i=modeSel-2,modeSel+2 do
		if i>=1 and i<=#modeID then
			local f=80-abs(i-modeSel)*20
			gc.setColor(i==modeSel and color.white or abs(i-modeSel)==1 and color.grey or color.darkGrey)
			setFont(f)
			mStr(modeName[i],640,320+70*(i-modeSel)-f*.5)
		end
	end
end
function Pnt.custom()
	setFont(80)
	gc.setColor(color.lightGrey)
	gc.print("Custom Game",20,20)
	gc.setColor(color.white)
	gc.print("Custom Game",22,23)
	setFont(35)
	for i=1,#customID do
		local k=customID[i]
		local y=90+35*i
		gc.print(customOption[k],50,y)
		if customVal[k]then
			gc.print(customVal[k][customSel[k]],350,y)
		else
			gc.print(customRange[k][customSel[k]],350,y)
		end
	end
	gc.print("→",10,88+35*optSel)
end
function Pnt.play()
	for p=1,#players do
		P=players[p]
		setmetatable(_G,P.index)
		if P.small then
			gc.push("transform")
			gc.translate(x,y)gc.scale(size)--Scale
			gc.setColor(0,0,0,.5)gc.rectangle("fill",0,0,300,600)--Black Background
			gc.setLineWidth(13)
			gc.stencil(stencil_field_small, "replace",1)
			gc.translate(0,fieldBeneath)
			gc.setStencilTest("equal",1)
				for j=1,#field do
					if falling<=0 or without(clearing,j)then
						for i=1,10 do
							if field[j][i]>0 then
								drawPixel(j,i,field[j][i],min(visTime[j][i],20)*.05)
							end
						end
					end
				end--Field
				gc.setColor(1,1,1)
				gc.draw(PTC.dust[p])--Draw game field
			gc.setStencilTest()--In-playField mask
			gc.translate(0,-fieldBeneath)
			gc.setColor(frameColor[P.strength])gc.rectangle("line",-7,-7,314,614)--Draw boarder

			if P.result then
				gc.setColor(1,1,1,min(P.counter,60)*.01)
				setFont(100)
				mStr(P.result,150,250)
			else
				local h=0
				for i=1,#atkBuffer do
					local a=atkBuffer[i]
					local bar=a.amount*30
					if not a.sent then
						if a.countdown>0 then
							gc.setColor(attackColor[a.lv][1])
							gc.rectangle("fill",315,600-h,8,-bar+5)
							gc.setColor(attackColor[a.lv][2])
							gc.rectangle("fill",315,600-h+(-bar+5),8,-(-bar+5)*(1-a.countdown/a.cd0))
							--Timing
						else
							attackColor.animate[a.lv]((sin((Timer()-i)*20)+1)*.5)
							gc.rectangle("fill",315,600-h,8,-bar+5)
							--Warning
						end
					end
					h=h+bar
					if h>600 then break end
				end--Buffer line

				gc.setColor(b2b<100 and color.white or b2b<=480 and color.lightRed or color.lightBlue)
				gc.rectangle("fill",-15,600,10,-b2b)
				--B2B bar
			end
			gc.pop()
		else
			gc.push("transform")
			gc.translate(x,y)gc.scale(size)--Scale
			gc.setColor(0,0,0,.7)gc.rectangle("fill",0,0,600,690)--Black Background
			gc.setLineWidth(7)
			gc.setColor(frameColor[P.strength])gc.rectangle("line",0,0,600,690)--Big frame
			gc.translate(150,70)
			gc.stencil(stencil_field, "replace", 1)
			gc.translate(0,fieldBeneath)
			gc.setStencilTest("equal",1)
				for j=1,#field do
					if falling<=0 or without(clearing,j)then
						for i=1,10 do
							if field[j][i]>0 then
								drawPixel(j,i,field[j][i],min(visTime[j][i],20)*.05)
							end
						end
					else
						gc.setColor(1,1,1,falling/gameEnv.fall)
						gc.rectangle("fill",0,600-30*j,320,30)
					end
				end--Field
				if waiting<=0 then
					if gameEnv.ghost then
						for i=1,r do for j=1,c do
							if cb[i][j]>0 then
								drawPixel(i+y_img-1,j+cx-1,bn,.3)
							end
						end end
					end--Ghost
					gc.setColor(1,1,1,lockDelay/gameEnv.lock)
					for i=1,r do for j=1,c do
						if cb[i][j]>0 then
							gc.rectangle("fill",30*(j+cx-1)-34,596-30*(i+cy-1),38,38)
						end
					end end--BlockShade(lockdelay indicator)
					for i=1,r do for j=1,c do
						if cb[i][j]>0 then
							drawPixel(i+cy-1,j+cx-1,bn,1)
						end
					end end--Block
					if gameEnv.center then
						local x=30*(cx+sc[2]-1)-30+15
						gc.draw(spinCenter,x,600-30*(cy+sc[1]-1)+15,nil,nil,nil,4,4)
						gc.setColor(1,1,1,.5)
						gc.draw(spinCenter,x,600-30*(y_img+sc[1]-1)+15,nil,nil,nil,4,4)
					end--Rotate center
				end
				gc.setColor(1,1,1)
				gc.draw(PTC.dust[p])--Draw game field
			gc.setStencilTest()--In-playField mask
			gc.translate(0,-fieldBeneath)
			gc.setColor(1,1,1)gc.rectangle("line",-3,-13,306,616)--Draw boarder

			local h=0
			for i=1,#atkBuffer do
				local a=atkBuffer[i]
				local bar=a.amount*30
				if not a.sent then
					if a.time<20 then
						bar=bar*(20*a.time)^.5*.05
						--Appear
					end
					if a.countdown>0 then
						gc.setColor(attackColor[a.lv][1])
						gc.rectangle("fill",308,600-h,8,-bar+5)
						gc.setColor(attackColor[a.lv][2])
						gc.rectangle("fill",308,600-h+(-bar+5),8,-(-bar+5)*(1-a.countdown/a.cd0))
						--Timing
					else
						attackColor.animate[a.lv]((sin((Timer()-i)*20)+1)*.5)
						gc.rectangle("fill",308,600-h,8,-bar+5)
						--Warning
					end
				else
					gc.setColor(attackColor[a.lv][1])
					bar=bar*(20-a.time)*.05
					gc.rectangle("fill",308,600-h,8,-bar+5)
					--Disappear
				end
				h=h+bar
				if h>600 then break end
			end--Buffer line

			gc.setColor(b2b<100 and color.white or b2b<=500 and color.lightRed or color.lightBlue)
			gc.rectangle("fill",-17,600,10,-b2b1)
			gc.setColor(color.red)
			gc.rectangle("fill",-23,600-100,16,5)
			gc.setColor(color.blue)
			gc.rectangle("fill",-23,600-500,16,5)
			--B2B bar

			setFont(40)
			gc.setColor(1,1,1)
			if gameEnv.hold then
				gc.print("Hold",-113,0)
				for i=1,#hb do
					for j=1,#hb[1] do
						if hb[i][j]>0 then
							drawPixel(i+17.5-#hb*.5,j-2.5-#hb[1]*.5,holded and 13 or hn,1)
						end
					end
				end
			end--Hold
			gc.print("Next",336,0)
			for N=1,gameEnv.next do
				local b=nb[N]
				for i=1,#b do
					for j=1,#b[1] do
						if b[i][j]>0 then
							drawPixel(i+20-2.4*N-#b*.5,j+12.5-#b[1]*.5,nxt[N],1)
						end
					end
				end
			end--Next
			if count then
				gc.push("transform")
					gc.translate(155,220)
					gc.setColor(1,1,1)
					setFont(100)
					if count%60>45 then gc.scale(1+(count%60-45)^2*.01,1)end
					mStr(int(count/60+1),0,0)
				gc.pop()
			end--Draw starting counter
			for i=1,#bonus do
				bonus[i]:draw(min((30-abs(bonus[i].t-30))*.05,1)*(not bonus[i].solid and #field>(9-bonus[i].dy*.03333)and .7 or 1))
			end--Effects

			gc.setColor(1,1,1)
			setFont(40)
			gc.print(format("%.2f",time),-130,530)--Draw time
			if mesDisp[gamemode]then mesDisp[gamemode]()end--Draw other message

			setFont(15)
			gc.setColor(1,1,1)
			gc.print("BPM",380,490)
			gc.print("KPM",335,580)
			setFont(30)
			drawDial(350,520,dropSpeed)
			drawDial(400,570,keySpeed)
			--Speed dials
			gc.pop()
		end
	end--Draw players
	gc.setColor(1,1,1)
	for i=1,3 do
		gc.draw(PTC.attack[i])
	end
	for i=1,#FX.badge do
		local b=FX.badge[i]
		local t=b.t<10 and 0 or b.t<50 and(sin(1.5*(b.t/20-1.5))+1)*.5 or 1
		gc.setColor(1,1,1,b.t<10 and b.t*.1 or b.t<50 and 1 or(60-b.t)*.1)
		gc.draw(badgeIcon,b[1]+(b[3]-b[1])*t,b[2]+(b[4]-b[2])*t,nil,b.size,nil,14,14)
	end
	setmetatable(_G,nil)
	if setting.virtualkeySwitch then
		drawVirtualkey()
	end
end
function Pnt.setting()
	gc.setColor(1,1,1)
	setFont(35)
	mStr("DAS:"..setting.das,328,163)
	mStr("ARR:"..setting.arr,543,163)
	setFont(18)
	mStr("softdropDAS:"..setting.sddas,328,250)
	mStr("softdropARR:"..setting.sdarr,543,250)
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
	setFont(40)
	gc.print("< P"..curBoard.."/P8 >",430,530)
	setFont(25)
	for y=1,12 do
		mStr(actName_show[y],150,40*y)
		for x=1,2 do
			mStr(setting.keyMap[curBoard+x*8-8][y],200*x+140,40*y)
		end
		gc.line(40,40*y-10,640,40*y-10)
	end
	for x=1,4 do
		gc.line(200*x-160,30,200*x-160,510)
	end
	gc.line(40,510,640,510)
	gc.print("Keyboard | Joystick",330,3)
	gc.print("Arrowkey to select/change slot,Enter to change,Esc back",50,580)
end
function Pnt.setting3()
	drawVirtualkey(sel)
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
		mStr(Text.help[i],640,15+43*i)
	end
	gc.draw(titleImage,180,600,.2,.7+.05*sin(Timer()*2),nil,140,100)
end
function Pnt.stat()
	setFont(30)
	gc.setColor(1,1,1)
	for i=1,10 do
		gc.print(Text.stat[i],350,20+40*i)
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