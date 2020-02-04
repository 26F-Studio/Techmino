Pnt={BG={}}
function Pnt.BG.none()
	gc.clear(.2,.2,.2)
end
function Pnt.BG.menu()
	gc.setLineWidth(40)
	gc.setColor(1,.9,.9)
	local t=(Timer()%1)*100
	for i=-6,9 do
		gc.line(t+100*i,-50,t+100*i+600,650)
	end
	gc.setLineWidth(2)
end
function Pnt.BG.game1()
	gc.setColor(1,1,1)
	gc.draw(background[1],500,300,Timer()*.15,nil,nil,600,600)
end
function Pnt.BG.game2()
	gc.setColor(1,.5,.5)
	gc.draw(background[1],500,300,Timer()*.15,nil,nil,600,600)
end
function Pnt.BG.game3()
	gc.push("transform")
	gc.translate(500,300)
	gc.scale(1,.6)
	gc.setColor(1,.9,.9)
	gc.setLineWidth(30)
	local t=(Timer()%1)*60
	for x=0,8 do
		local d=60*x+t
		gc.rectangle("line",-d,-d,2*d,2*d)
	end
	gc.setLineWidth(2)
	gc.pop()
end
function Pnt.BG.game4()
	local t=215+sin(Timer()*6)*40
	gc.setColor(255,t,t)
	gc.rectangle("fill",0,0,1000,600)
end
function Pnt.BG.game5()
	gc.setColor(1,.9,.9)
	local t=(Timer()%1)*50
	for x=0,20 do
		for y=0,12 do
			if(x+y)%2==0 then
				gc.rectangle("fill",50*x-t,50*y-t,50,50)
			end
		end
	end
end

function Pnt.load()
	if loadprogress then
		gc.setLineWidth(3)
		gc.setColor(.8,.8,.8)
		gc.rectangle("fill",200,280,loadprogress*600,40)
		gc.setColor(1,1,1)
		gc.rectangle("line",200,280,600,40)
		setFont(30)
		mStr("Loading...",500,285)
	end
end
function Pnt.intro()
	gc.setColor(1,1,1)
	gc.draw(img.title[setting.lang],500,300,nil,nil,nil,250,100)
end
function Pnt.main()
	gc.setColor(1,1,1)
	gc.draw(img.title[setting.lang],500,120,nil,nil,nil,250,60)
end
function Pnt.play()
	for p=1,#players do
		P=players[p]
		setmetatable(_G,P.index)
		gc.push("transform")
		gc.translate(x,y)gc.scale(size)--Scale
		gc.setColor(0,0,0,.7)gc.rectangle("fill",0,0,620,690)--Back
		gc.setLineWidth(3)
		gc.setColor(1,1,1)gc.rectangle("line",0,0,620,690)--Big frame
		gc.translate(160,70)
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
					gc.rectangle("fill",0,600-30*j,300,30)
				end
			end--Field
			if waiting<=0 then
				if gameEnv.ghost then
					for i=1,r do for j=1,c do
						if cb[i][j]>0 then
							drawPixel(i+y_img-1,j+cx-1,gameEnv.color[bn],.4)
						end
					end end
				end--Ghost
				for i=1,r do for j=1,c do
					if cb[i][j]>0 then
						drawPixel(i+cy-1,j+cx-1,gameEnv.color[bn],1)
					end
				end end--Block
			end
			gc.draw(PTC.dust[p])--Draw game field
		love.graphics.setStencilTest()--In-field mask
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
					--Time count
				else
					gc.setColor(1,(sin((Timer()-i)*20)+1)*.5,0)
					gc.rectangle("fill",302,600-h,8,-bar+5)
					--warning
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
						drawPixel(i+17.5-#hb*.5,j-2.5-#hb[1]*.5,holded and 13 or gameEnv.color[hn],1)
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
						drawPixel(i+20-2.4*N-#b*.5,j+12.5-#b[1]*.5,gameEnv.color[nxt[N]],1)
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
		mesDisp[gamemode]()--Draw message
		setFont(45)
		gc.translate(380,550)
			gc.setColor(1,1,1)
			mStr(int(dropSpeed),0,-21)
			gc.setColor(.6,.6,.6)gc.setLineWidth(5)
			gc.circle("line",0,0,50)
			gc.setColor(1,1,1)gc.setLineWidth(2)
			gc.circle("line",0,0,50)
		gc.rotate(2.0944+(dropSpeed<=175 and .020944*dropSpeed or 4.712389-52.35988/(dropSpeed-125)))
			gc.setColor(.4,.4,.4,.5)gc.setLineWidth(5)
			gc.line(0,0,40,0)
			gc.setColor(.6,.6,.6,.5)gc.setLineWidth(3)
			gc.line(0,0,40,0)
		--Speed dial
		
		gc.pop()
	end--Draw players
	gc.setLineWidth(3)
	for i=1,#FX.beam do
		local b=FX.beam[i]
		local t=b.t/45
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
function Pnt.setting()
	setFont(30)
	gc.setColor(1,1,1)
	mStr("DAS:"..setting.das,200,65)
	mStr("ARR:"..setting.arr,400,65)
end
function Pnt.setting2()
	setFont(30)
	gc.setColor(1,1,1)
	for i=1,8 do
		gc.printf(actName_[i]..":",80,5+50*i,150,"right")
	end
	if keysetting then
		setFont(35)
		gc.print("<<",470,50*keysetting)
	end
end
function Pnt.help()
	gc.setColor(1,1,1)
	gc.draw(img.title[setting.lang],60,420,.2,.5+.05*sin(Timer()*2))
end
function Pnt.stat()
	setFont(30)
	gc.setColor(1,1,1)
	gc.print(Text.stat[1],250,60)
	gc.print(Text.stat[2],250,100)
	gc.print(Text.stat[3],250,140)
	gc.print(Text.stat[4],250,180)
	
	gc.print(stat.game,600,60)
	gc.print(format("%0.2f",stat.gametime).."s",600,100)
	gc.print(stat.piece,600,140)
	gc.print(stat.row,600,180)
	gc.draw(img.title[setting.lang],60,420,.2,.5+.05*sin(Timer()*2))
end