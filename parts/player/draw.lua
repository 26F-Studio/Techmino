local gc=love.graphics
local Timer=love.timer.getTime
local int,ceil,rnd=math.floor,math.ceil,math.random
local max,min,sin=math.max,math.min,math.sin
local format=string.format
local SCR=SCR
local setFont=setFont

local frameColorList={
	[0]=COLOR.white,
	COLOR.lGreen,
	COLOR.lBlue,
	COLOR.lPurple,
	COLOR.lOrange,
}
--local function drawCell(y,x,id)gc.draw(SKIN.curText[id],30*x-30,-30*y)end
local function drawGrid(P)
	local FBN,FUP=P.fieldBeneath,P.fieldUp
	gc.setLineWidth(1)
	gc.setColor(1,1,1,.2)
	for x=1,9 do
		gc.line(30*x,-10,30*x,600)
	end
	for y=0,19 do
		y=30*(y-int((FBN+FUP)/30))+FBN+FUP
		gc.line(0,y,300,y)
	end
end
local function drawField(P)
	local V,F=P.visTime,P.field
	local start=int((P.fieldBeneath+P.fieldUp)/30+1)
	local rep=GAME.replaying
	local texture=SKIN.curText
	if P.falling==-1 then--Blocks only
		for j=start,min(start+21,#F)do
			for i=1,10 do
				if F[j][i]>0 then
					if V[j][i]>0 then
						gc.setColor(1,1,1,min(V[j][i]*.05,1))
						gc.draw(texture[F[j][i]],30*i-30,-30*j)-- drawCell(j,i,F[j][i])
					elseif rep then
						gc.setColor(1,1,1,.3+.08*sin(.5*(j-i)+Timer()*4))
						gc.rectangle("fill",30*i-30,-30*j,30,30)
					end
				end
			end
		end
	else--With falling animation
		local ENV=P.gameEnv
		local stepY=ENV.smooth and(P.falling/(ENV.fall+1))^2.5*30 or 30
		local A=P.falling/ENV.fall
		local h=1
		gc.push("transform")
			for j=start,min(start+21,#F)do
				while j==P.clearingRow[h]do
					h=h+1
					gc.translate(0,-stepY)
					gc.setColor(1,1,1,A)
					gc.rectangle("fill",0,30-30*j,300,stepY)
				end
				for i=1,10 do
					if F[j][i]>0 then
						if V[j][i]>0 then
							gc.setColor(1,1,1,min(V[j][i]*.05,1))
							gc.draw(texture[F[j][i]],30*i-30,-30*j)-- drawCell(j,i,F[j][i])
						elseif rep then
							gc.setColor(1,1,1,.2)
							gc.rectangle("fill",30*i-30,-30*j,30,30)
						end
					end
				end
			end
		gc.pop()
	end
end
local function drawFXs(P)
	--LockFX
	for i=1,#P.lockFX do
		local S=P.lockFX[i]
		if S[3]<.5 then
			gc.setColor(1,1,1,2*S[3])
			gc.rectangle("fill",S[1],S[2],60*S[3],30)
		else
			gc.setColor(1,1,1,2-2*S[3])
			gc.rectangle("fill",S[1]+30,S[2],60*S[3]-60,30)
		end
	end

	--DropFX
	for i=1,#P.dropFX do
		local S=P.dropFX[i]
		gc.setColor(1,1,1,.6-S[5]*.6)
		local w=30*S[3]*(1-S[5]*.5)
		gc.rectangle("fill",30*S[1]-30+15*S[3]-w*.5,-30*S[2],w,30*S[4])
	end

	--MoveFX
	local texture=SKIN.curText
	for i=1,#P.moveFX do
		local S=P.moveFX[i]
		gc.setColor(1,1,1,.6-S[4]*.6)
		gc.draw(texture[S[1]],30*S[2]-30,-30*S[3])-- drawCell(S[3],S[2],S[1])
	end

	--ClearFX
	for i=1,#P.clearFX do
		local S=P.clearFX[i]
		local t=S[2]
		local x=t<.3 and 1-(3.3333*t-1)^2 or 1
		local y=t<.2 and 5*t or 1-1.25*(t-.2)
		gc.setColor(1,1,1,y)
		gc.rectangle("fill",150-x*150,15-S[1]*30-y*15,300*x,y*30)
	end
end
local function drawGhost(P,clr)
	gc.setColor(1,1,1,P.gameEnv.ghost)
	local texture=SKIN.curText
	for i=1,P.r do for j=1,P.c do
		if P.cur.bk[i][j]then
			gc.draw(texture[clr],30*(j+P.curX-1)-30,-30*(i+P.imgY-1))-- drawCell(i+P.imgY-1,j+P.curX-1,clr)
		end
	end end
end
local function drawBlockOutline(P,texture,trans)
	SHADER.alpha:send("a",trans)
	gc.setShader(SHADER.alpha)
	for i=1,P.r do for j=1,P.c do
		if P.cur.bk[i][j]then
			local x=30*(j+P.curX)-60-3
			local y=30-30*(i+P.curY)-3
			gc.draw(texture,x,y)
			gc.draw(texture,x+6,y+6)
			gc.draw(texture,x+6,y)
			gc.draw(texture,x,y+6)
		end
	end end
	gc.setShader()
end
local function drawBlock(P,clr)
	gc.setColor(1,1,1)
	local texture=SKIN.curText
	for i=1,P.r do for j=1,P.c do
		if P.cur.bk[i][j]then
			gc.draw(texture[clr],30*(j+P.curX-1)-30,-30*(i+P.curY-1))-- drawCell(i+P.curY-1,j+P.curX-1,clr)
		end
	end end
end
local function drawNextPreview(P,B)
	gc.setColor(1,1,1,.8)
	local x=int(6-#B[1]*.5)
	local y=21+ceil(P.fieldBeneath/30)
	for i=1,#B do for j=1,#B[1]do
		if B[i][j]then
			gc.draw(puzzleMark[-1],30*(x+j-2),30*(1-y-i))
		end
	end end
end
local function drawHold(P,clr)
	local B=P.hd.bk
	local texture=SKIN.curText
	for i=1,#B do for j=1,#B[1]do
		if B[i][j]then
			gc.draw(texture[clr],30*(j+2.06-#B[1]*.5)-30,-30*(i+1.36-#B*.5))-- drawCell(i+1.36-#B*.5,j+2.06-#B[1]*.5,clr)
		end
	end end
end

local draw={}

function draw.drawTargetLine(P,r)
	if r<21+(P.fieldBeneath+P.fieldUp)/30 and r>0 then
		gc.setLineWidth(4)
		gc.setColor(1,r>10 and 0 or rnd(),.5)
		local dx,dy=150+P.fieldOff.x,70+P.fieldOff.y+P.fieldBeneath+P.fieldUp
		gc.line(dx,600-30*r+dy,300+dx,600-30*r+dy)
	end
end

local attackColor={
	{COLOR.dGrey,COLOR.white},
	{COLOR.grey,COLOR.white},
	{COLOR.lPurple,COLOR.white},
	{COLOR.lRed,COLOR.white},
	{COLOR.dGreen,COLOR.cyan},
}
local RCPB={10,33,200,33,105,5,105,60}
local function drawDial(x,y,speed)
	gc.setColor(1,1,1)
	mStr(int(speed),x,y-18)

	gc.setLineWidth(4)
	gc.setColor(1,1,1,.4)
	gc.circle("line",x,y,30,10)

	gc.setLineWidth(2)
	gc.setColor(1,1,1,.6)
	gc.circle("line",x,y,30,10)

	gc.setColor(1,1,1,.8)
	gc.draw(IMG.dialNeedle,x,y,2.094+(speed<=175 and .02094*speed or 4.712-52.36/(speed-125)),nil,nil,5,4)
end
function draw.norm(P)
	local _
	local ENV=P.gameEnv
	local FBN,FUP=P.fieldBeneath,P.fieldUp
	gc.push("transform")
		gc.translate(P.x,P.y)gc.scale(P.size)

		--Field-related things
		gc.push("transform")
			gc.translate(150,70)

			--Things shake with field
			gc.push("transform")
				gc.translate(P.fieldOff.x,P.fieldOff.y)

				--Fill field
				gc.setColor(0,0,0,.6)
				gc.rectangle("fill",0,-10,300,610)

				--Draw grid
				if ENV.grid then drawGrid(P)end

				--In-field things
				gc.push("transform")
					gc.translate(0,600+FBN+FUP)
					gc.setScissor(SCR.x+(P.absFieldX+P.fieldOff.x)*SCR.k,SCR.y+(P.absFieldY+P.fieldOff.y)*SCR.k,300*P.size*SCR.k,610*P.size*SCR.k)

					--Draw dangerous area
					gc.setColor(1,0,0,.3)
					gc.rectangle("fill",0,-600,300,-610-FUP-FBN)

					--Draw field
					drawField(P)

					--Draw spawn line
					gc.setColor(1,sin(Timer())*.4+.5,0,.5)
					gc.setLineWidth(4)
					gc.line(0,-600-FBN,300,-600-FBN)

					--Draw FXs
					drawFXs(P)

					--Draw current block
					if P.cur and P.waiting==-1 then
						local curColor=P.cur.color

						--Draw ghost
						if ENV.ghost then drawGhost(P,curColor)end

						local dy=ENV.smooth and P.imgY~=P.curY and(P.dropDelay/ENV.drop-1)*30 or 0
						gc.translate(0,-dy)
						local trans=P.lockDelay/ENV.lock

						--Draw block
						if ENV.block then
							drawBlockOutline(P,SKIN.curText[curColor],trans)
							drawBlock(P,curColor)
						end

						--Draw rotate center
						local x=30*(P.curX+P.sc[2])-15
						if ENV.center and ENV.block then
							gc.setColor(1,1,1,ENV.center)
							gc.draw(IMG.spinCenter,x,-30*(P.curY+P.sc[1])+15,nil,nil,nil,4,4)
						end
						gc.translate(0,dy)
						if ENV.center and ENV.ghost then
							gc.setColor(1,1,1,trans*ENV.center)
							gc.draw(IMG.spinCenter,x,-30*(P.imgY+P.sc[1])+15,nil,nil,nil,4,4)
						end
					end

					--Draw next preview
					if ENV.nextPos and P.next[1]then
						drawNextPreview(P,P.next[1].bk)
					end

					gc.setScissor()
				gc.pop()

				gc.setLineWidth(2)
				gc.setColor(frameColorList[P.frameColor])
				gc.rectangle("line",-1,-11,302,612)--Boarder
				gc.rectangle("line",301,-3,15,604)--AtkBuffer boarder
				gc.rectangle("line",-16,-3,15,604)--B2b bar boarder

				--Buffer line
				local h=0
				for i=1,#P.atkBuffer do
					local A=P.atkBuffer[i]
					local bar=A.amount*30
					if h+bar>600 then bar=600-h end
					if not A.sent then
						--Appear
						if A.time<20 then
							bar=bar*(20*A.time)^.5*.05
						end
						if A.countdown>0 then
							--Timing
							gc.setColor(attackColor[A.lv][1])
							gc.rectangle("fill",303,599-h,11,-bar)
							gc.setColor(attackColor[A.lv][2])
							gc.rectangle("fill",303,599-h-bar,11,bar*(1-A.countdown/A.cd0))
						else
							--Warning
							local t=math.sin((Timer()-i)*30)*.5+.5
							local c1,c2=attackColor[A.lv][1],attackColor[A.lv][2]
							gc.setColor(c1[1]*t+c2[1]*(1-t),c1[2]*t+c2[2]*(1-t),c1[3]*t+c2[3]*(1-t))
							gc.rectangle("fill",303,599-h,11,-bar)
						end
					else
						gc.setColor(attackColor[A.lv][1])
						bar=bar*(20-A.time)*.05
						gc.rectangle("fill",303,599-h,11,-bar)
						--Disappear
					end
					h=h+bar
				end

				--B2B indictator
				local a,b=P.b2b,P.b2b1 if a>b then a,b=b,a end
				gc.setColor(.8,1,.2)
				gc.rectangle("fill",-14,599,11,-b*.5)
				gc.setColor(P.b2b<40 and COLOR.white or P.b2b<=1e3 and COLOR.lRed or COLOR.lBlue)
				gc.rectangle("fill",-14,599,11,-a*.5)
				gc.setColor(1,1,1)
				if Timer()%.5<.3 then
					gc.rectangle("fill",-15,b<40 and 578.5 or 98.5,13,3)
				end

				--LockDelay indicator
				if ENV.easyFresh then
					gc.setColor(1,1,1)
				else
					gc.setColor(1,.26,.26)
				end
				if P.lockDelay>=0 then
					gc.rectangle("fill",0,602,300*P.lockDelay/ENV.lock,6)--Lock delay indicator
				end
				local x=3
				for _=1,min(ENV.freshLimit-P.freshTime,15)do
					gc.rectangle("fill",x,615,14,5)
					x=x+20
				end

				--Draw Hold
				if ENV.hold then
					gc.push("transform")
					gc.translate(-140,116)
						gc.setColor(0,0,0,.4)gc.rectangle("fill",0,-80,124,80)
						gc.setColor(1,1,1)gc.rectangle("line",0,-80,124,80)
						if P.holded then gc.setColor(.6,.4,.4)end
						mText(drawableText.hold,62,-131)
						if P.hd then drawHold(P,P.hd.color)end
					gc.pop()
				end

				--Draw Next(s)
				local N=ENV.next*72
				if ENV.next>0 then
					gc.setColor(0,0,0,.4)gc.rectangle("fill",316,36,124,N)
					gc.setColor(1,1,1)gc.rectangle("line",316,36,124,N)
					mText(drawableText.next,378,-15)
					N=1
					local texture=SKIN.curText
					while N<=ENV.next and P.next[N]do
						local bk,clr=P.next[N].bk,P.next[N].color
						for i=1,#bk do for j=1,#bk[1] do
							if bk[i][j]then
								gc.draw(texture[clr],30*(j+12.6-#bk[1]*.5)-30,-30*(i-2.4*N-#bk*.5))-- drawCell(i-2.4*N-#bk*.5,j+12.6-#bk[1]*.5,clr)
							end
						end end
						N=N+1
					end
				end

				--Draw Bagline(s)
				if ENV.bagLine then
					local L=ENV.bagLen
					local C=-P.pieceCount%L--Phase
					gc.setColor(.8,.5,.5)
					for i=C,N-1,L do
						local y=72*i+36
						gc.line(318+P.fieldOff.x,y,438,y)
					end
				end

				--Draw target selecting pad
				if modeEnv.royaleMode then
					if P.atkMode then
						gc.setColor(1,.8,0,P.swappingAtkMode*.02)
						gc.rectangle("fill",RCPB[2*P.atkMode-1],RCPB[2*P.atkMode],90,35,8,4)
					end
					gc.setColor(1,1,1,P.swappingAtkMode*.025)
					setFont(18)
					for i=1,4 do
						gc.rectangle("line",RCPB[2*i-1],RCPB[2*i],90,35,8,4)
						mStr(text.atkModeName[i],RCPB[2*i-1]+45,RCPB[2*i]+3)
					end
				end
			gc.pop()

			--Bonus texts
			TEXT.draw(P.bonus)

			--Display Ys
			-- gc.setLineWidth(6)
			-- if P.curY then	gc.setColor(1,.4,0,.42)gc.line(0,611-P.curY*30,300,611-P.curY*30)end
			-- if P.imgY then	gc.setColor(0,1,.4,.42)gc.line(0,615-P.imgY*30,300,615-P.imgY*30)end
			-- if P.minY then	gc.setColor(0,.4,1,.42)gc.line(0,619-P.minY*30,300,619-P.minY*30)end
			-- 				gc.setColor(0,.4,1,.42)gc.line(0,600-P.garbageBeneath*30,300,600-P.garbageBeneath*30)
		gc.pop()

		--Speed dials
		setFont(25)
		drawDial(510,580,P.dropSpeed)
		drawDial(555,635,P.keySpeed)
		gc.setColor(1,1,1)
		gc.draw(drawableText.bpm,540,550)
		gc.draw(drawableText.kpm,494,643)

		--Score & Time
		setFont(25)
		gc.setColor(0,0,0,.3)
		gc.print(P.score1,18,579)
		gc.print(format("%.2f",P.stat.time),18,609)

		gc.setColor(COLOR.lYellow)gc.print(P.score1,20,580)
		gc.setColor(COLOR.sky)gc.print(format("%.2f",P.stat.time),20,610)

		--FinesseCombo
		if P.finesseCombo>2 then
			_=P.finesseComboTime
			local T=P.finesseCombo.."x"
			if _>0 then
				gc.setColor(1,1,1,_*.2)
				gc.print(T,20,640)
				gc.setColor(1,1,1,1.2-_*.1)
				gc.push("transform")
				gc.translate(20,670)
				gc.scale(1+_*.08)
				gc.print(T,0,-30)
				gc.pop()
			else
				gc.setColor(1,1,1)
				gc.print(T,20,640)
			end
		end

		--Lives
		if P.life>0 then
			gc.setColor(1,1,1)
			if P.life<=3 then
				for i=1,P.life do
					gc.draw(IMG.lifeIcon,450+25*i,665,nil,.8)
				end
			else
				gc.draw(IMG.lifeIcon,475,665,nil,.8)
				setFont(20)
				gc.print("x",503,665)
				gc.print(P.life,517,665)
			end
		end

		--Other messages
		gc.setColor(1,1,1)
		if CURMODE.mesDisp then
			CURMODE.mesDisp(P)
		end

		--Missions
		if P.curMission then
			local missionEnum=missionEnum
			local L=ENV.mission

			--Draw current mission
			setFont(35)
			if ENV.missionKill then
				gc.setColor(1,.7+.2*sin(Timer()*6.26),.4)
			else
				gc.setColor(1,1,1)
			end
			gc.print(missionEnum[L[P.curMission]],85,180)

			--Draw next mission
			setFont(17)
			for i=1,3 do
				local t=L[P.curMission+i]
				if t then
					t=missionEnum[t]
					gc.print(t,87-26*i,187)
				else
					break
				end
			end
		end

		--Draw starting counter
		gc.setColor(1,1,1)
		if GAME.frame<180 then
			local count=179-GAME.frame
			gc.push("transform")
				gc.translate(305,290)
				setFont(95)
				if count%60>45 then gc.scale(1+(count%60-45)^2*.01,1)end
				mStr(int(count/60+1),0,0)
			gc.pop()
		end
	gc.pop()
end

function draw.small(P)
	--Draw content
	P.frameWait=P.frameWait-1
	if P.frameWait==0 then
		P.frameWait=10
		gc.setCanvas(P.canvas)
		gc.clear(0,0,0,.4)
		gc.push("transform")
		gc.origin()
		gc.setColor(1,1,1,P.result and max(20-P.endCounter,0)*.05 or 1)

		--Field
		local F=P.field
		local texture=SKIN.curTextMini
		for j=1,#F do
			for i=1,10 do if F[j][i]>0 then
				gc.draw(texture[F[j][i]],6*i-6,120-6*j)
			end end
		end

		--Draw boarder
		if P.alive then
			gc.setLineWidth(2)
			gc.setColor(frameColorList[P.frameColor])
			gc.rectangle("line",0,0,60,120)
		end

		--Draw badge
		if modeEnv.royaleMode then
			gc.setColor(1,1,1)
			for i=1,P.strength do
				gc.draw(IMG.badgeIcon,12*i-7,4,nil,.5)
			end
		end

		--Draw result
		if P.result then
			gc.setColor(1,1,1,min(P.endCounter,60)*.01)
			setFont(17)mStr(P.result,32,47)
			setFont(15)mStr(P.modeData.event,30,82)
		end
		gc.pop()
		gc.setCanvas()
	end

	--Draw Canvas
	gc.setColor(1,1,1)
	gc.draw(P.canvas,P.x,P.y,nil,P.size*10)
	if P.killMark then
		gc.setLineWidth(3)
		gc.setColor(1,0,0,min(P.endCounter,25)*.04)
		gc.circle("line",P.centerX,P.centerY,(840-20*min(P.endCounter,30))*P.size)
	end
	setFont(30)
end

function draw.demo(P)
	local _
	local ENV=P.gameEnv
	local curColor=P.cur.color

	--Camera
	gc.push("transform")
		gc.translate(P.x,P.y)gc.scale(P.size)
		gc.push("transform")
			gc.translate(P.fieldOff.x,P.fieldOff.y)

			--Frame
			gc.setColor(0,0,0,.6)
			gc.rectangle("fill",0,0,300,600)
			gc.setLineWidth(2)
			gc.setColor(1,1,1)
			gc.rectangle("line",-1,-1,302,602)

			gc.push("transform")
				gc.translate(0,600)
				drawField(P)
				drawFXs(P)
				if P.cur and P.waiting==-1 then
					if ENV.ghost then drawGhost(P,curColor)end
					if ENV.block then
						drawBlockOutline(P,SKIN.curText[curColor],P.lockDelay/ENV.lock)
						drawBlock(P,curColor)
					end
				end
			gc.pop()

			--Draw hold
			local blockImg=TEXTURE.miniBlock
			if P.hd then
				local id=P.hd.id
				_=P.color[id]
				gc.setColor(_[1],_[2],_[3],.3)
				_=blockImg[id]
				gc.draw(_,15,30,nil,16,nil,0,_:getHeight()*.5)
			end

			--Draw next
			local N=1
			while N<=ENV.next and P.next[N]do
				local id=P.next[N].id
				_=P.color[id]
				gc.setColor(_[1],_[2],_[3],.3)
				_=blockImg[id]
				gc.draw(_,285,40*N-10,nil,16,nil,_:getWidth(),_:getHeight()*.5)
				N=N+1
			end
		gc.pop()
		TEXT.draw(P.bonus)
	gc.pop()
end

return draw