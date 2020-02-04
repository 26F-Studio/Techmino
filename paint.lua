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

function drawButton()
	for i=1,#Buttons[scene]do
		local B=Buttons[scene][i]
		if not(B.hide and B.hide())then
			local t=B==Buttons.sel and .3 or 0
			B.alpha=abs(B.alpha-t)>.02 and(B.alpha+(B.alpha<t and .02 or -.02))or t
			if B.alpha>t then B.alpha=B.alpha-.02 elseif B.alpha<t then B.alpha=B.alpha+.02 end
			gc.setColor(B.rgb[1],B.rgb[2],B.rgb[3],B.alpha)
			gc.rectangle("fill",B.x-B.w*.5,B.y-B.h*.5,B.w,B.h)
			local t=B.t
				if type(t)=="function"then t=t()
				end
			gc.setColor(B.rgb[1],B.rgb[2],B.rgb[3],.3)
			gc.setLineWidth(5)gc.rectangle("line",B.x-B.w*.5,B.y-B.h*.5,B.w,B.h)
			mStr(t,B.x-1,B.y-1-currentFont*.5)
			mStr(t,B.x-1,B.y+1-currentFont*.5)
			mStr(t,B.x+1,B.y-1-currentFont*.5)
			mStr(t,B.x+1,B.y+1-currentFont*.5)
			gc.setColor(B.rgb)
			gc.setLineWidth(3)gc.rectangle("line",B.x-B.w*.5,B.y-B.h*.5,B.w,B.h)
			mStr(t,B.x,B.y-currentFont*.5)
		end
	end
end
function drawDial(x,y,speed)
	gc.push("transform")
		gc.translate(x,y)
		gc.setColor(1,1,1)
		mStr(int(speed),0,-14)
		gc.setColor(.6,.6,.6)gc.setLineWidth(5)
		gc.circle("line",0,0,30)
		gc.setColor(1,1,1)gc.setLineWidth(2)
		gc.circle("line",0,0,30)
		gc.rotate(2.0944+(speed<=175 and .020944*speed or 4.712389-52.35988/(speed-125)))
		gc.setColor(.4,.4,.4,.5)gc.setLineWidth(5)
		gc.line(0,0,22,0)
		gc.setColor(.6,.6,.6,.5)gc.setLineWidth(3)
		gc.line(0,0,22,0)
	gc.pop()
end
function drawPixel(y,x,id,alpha)
	gc.setColor(1,1,1,alpha)
	gc.draw(blockSkin[id],30*x-30,600-30*y)
end

Pnt={BG={}}
function Pnt.BG.none()
	gc.clear(.1,.1,.1)
end
function Pnt.BG.game1()
	gc.setColor(1,1,1)
	gc.draw(background[1],640,360,Timer()*.15,nil,nil,768,768)
end
function Pnt.BG.game2()
	gc.setColor(1,.5,.5)
	gc.draw(background[1],640,360,Timer()*.15,nil,nil,768,768)
end
function Pnt.BG.game3()
	gc.setColor(.6,.6,1)
	gc.draw(background[1],640,360,Timer()*.15,nil,nil,768,768)
end

function Pnt.load()
	if loadprogress then
		gc.setLineWidth(4)
		gc.setColor(.8,.8,.8)
		gc.rectangle("fill",340,340,loadprogress*640,40)
		gc.setColor(1,1,1)
		gc.rectangle("line",340,340,640,40)
		setFont(30)
		mStr("Loading...",640,345)
	end
end
function Pnt.main()
	gc.setColor(1,1,1)
	setFont(30)
	gc.print("Alpha 0.0.19726",370,150)
	gc.draw(img.title[setting.lang],30,30)
end
function Pnt.play()
	for p=1,#players do
		P=players[p]
		setmetatable(_G,P.index)
		gc.push("transform")
		gc.translate(x,y)gc.scale(size)--Scale
		gc.setColor(0,0,0,.8)gc.rectangle("fill",0,0,600,690)--Black Background
		gc.setLineWidth(3)
		gc.setColor(1,1,1)gc.rectangle("line",0,0,600,690)--Big frame
		gc.translate(150,70)
		gc.stencil(stencil_field, "replace", 1)
		gc.translate(0,fieldBeneath)
		love.graphics.setStencilTest("equal",1)
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
					gc.circle("fill",x,600-30*(cy+sc[1]-1)+15,4)
					gc.setColor(1,1,1,.5)
					gc.circle("fill",x,600-30*(y_img+sc[1]-1)+15,4)
				end--Rotate center
			end
			gc.setColor(1,1,1)
			gc.draw(PTC.dust[p])--Draw game field
		love.graphics.setStencilTest()--In-playField mask
		gc.translate(0,-fieldBeneath)
		gc.setColor(1,1,1)gc.rectangle("line",-1,-1,300,600)--Draw boarder

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
					gc.setColor(1,0,0)
					gc.rectangle("fill",302,600-h,8,-bar+5)
					gc.setColor(1,1,0)
					gc.rectangle("fill",302,600-h+(-bar+5),8,-(-bar+5)*(1-a.countdown/a.cd0))
					--Timing
				else
					gc.setColor(1,(sin((Timer()-i)*20)+1)*.5,0)
					gc.rectangle("fill",302,600-h,8,-bar+5)
					--Warning
				end
			else
				gc.setColor(1,0,0)
				bar=bar*(20-a.time)*.05
				gc.rectangle("fill",302,600-h,8,-bar+5)
				--Disappear
			end
			h=h+bar
			if h>600 then break end
		end--Buffer line

		setFont(40)
		if gameEnv.hold then
			gc.setColor(1,1,1)
			gc.print("Hold",-113,0)
			for i=1,#hb do
				for j=1,#hb[1] do
					if hb[i][j]>0 then
						drawPixel(i+17.5-#hb*.5,j-2.5-#hb[1]*.5,holded and 13 or hn,1)
					end
				end
			end
		end--Hold
		for N=1,gameEnv.next do
			gc.setColor(1,1,1)
			gc.print("Next",336,0)
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
			bonus[i]:draw()
		end--Effects

		gc.setColor(1,1,1)
		setFont(40)
		gc.print(format("%0.2f",time),-125,530)--Draw time
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
	end--Draw players
	gc.setLineWidth(3)
	for i=1,#FX.beam do
		local b=FX.beam[i]
		local t=b.t/30
		if t<.25 then
			t=t*4
			gc.setColor(1,1,1,4*t)
			gc.line(b[1],b[2],b[1]+t*(b[3]-b[1]),b[2]+t*(b[4]-b[2]))
		elseif t<.75 then
			gc.setColor(1,1,1)
			gc.line(b[1],b[2],b[3],b[4])
		else
			t=4*t-3
			gc.setColor(1,1,1,4-4*t)
			gc.line(b[1]+t*(b[3]-b[1]),b[2]+t*(b[4]-b[2]),b[3],b[4])
		end
	end
	setmetatable(_G,nil)
end
function Pnt.setting2()
	setFont(35)
	gc.setColor(1,1,1)
	mStr("DAS:"..setting.das,330,72)
	mStr("ARR:"..setting.arr,545,72)
	gc.setColor(1,1,1)
	for i=1,9 do
		gc.printf(actName_show[i]..":",100,60*i-8,200,"right")
	end
	if keysetting then
		setFont(35)
		gc.print("<<",550,60*keysetting-10)
	end
end
function Pnt.help()
	setFont(32)
	gc.setColor(1,1,1)
	for i=1,11 do
		mStr(Text.help[i],640,15+43*i)
	end
	gc.draw(img.title[setting.lang],180,600,.2,.7+.05*sin(Timer()*2),nil,140,100)
end
function Pnt.stat()
	setFont(30)
	gc.setColor(1,1,1)
	for i=1,6 do
		gc.print(Text.stat[i],250,20+40*i)
	end

	gc.print(stat.run,600,60)
	gc.print(stat.game,600,100)
	gc.print(format("%0.2f",stat.gametime).."s",600,140)
	gc.print(stat.piece,600,180)
	gc.print(stat.row,600,220)
	gc.print(stat.atk,600,260)
	gc.draw(img.title[setting.lang],180,600,.2,.7+.05*sin(Timer()*2),nil,140,100)
end