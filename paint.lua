local gc=love.graphics
local setFont=setFont
local int,ceil,rnd,abs=math.floor,math.ceil,math.random,math.abs
local max,min,sin,cos=math.max,math.min,math.sin,math.cos
local format=string.format

local Timer=love.timer.getTime
local mStr=mStr
local scr=scr
local scs=require("parts/spinCenters")
local modeRankColor={
	color.bronze,		--Rank1
	color.lightGrey,	--Rank2
	color.lightYellow,	--Rank3
	color.lightPurple,	--Rank4
	color.lightCyan,	--Rank5
	color.purple,		--Special
}
local rankString={
	"D","C","B","A","S",
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
	local _
	if setting.VKIcon then
		for i=1,#V do
			if V[i].ava then
				local B=V[i]
				gc.setColor(1,1,1,a)
				gc.setLineWidth(B.r*.07)
				gc.circle("line",B.x,B.y,B.r,10)--Button outline
				_=V[i].pressTime
				gc.draw(VKIcon[i],B.x,B.y,nil,B.r*.026+_*.08,nil,18,18)--icon
				if _>0 then
					gc.setColor(1,1,1,a*_*.08)
					gc.circle("fill",B.x,B.y,B.r*.94,10)--Glow
					gc.circle("line",B.x,B.y,B.r*(1.4-_*.04),10)--Ripple
				end
			end
		end
	else
		for i=1,#V do
			if V[i].ava then
				local B=V[i]
				gc.setColor(1,1,1,a)
				gc.setLineWidth(B.r*.07)
				gc.circle("line",B.x,B.y,B.r,10)
				_=V[i].pressTime
				if _>0 then
					gc.setColor(1,1,1,a*_*.08)
					gc.circle("fill",B.x,B.y,B.r*.94,10)
					gc.circle("line",B.x,B.y,B.r*(1.4-_*.04),10)
				end
			end
		end
	end
end

local Pnt={}

function Pnt.load()
	local S=sceneTemp
	gc.setLineWidth(4)
	gc.setColor(1,1,1,.5)
	gc.rectangle("fill",300,330,S.cur/S.tar*680,60,5)
	gc.setColor(1,1,1)
	gc.rectangle("line",300,330,680,60,5)
	setFont(35)
	gc.print(text.load[S.phase],340,335)
	if S.phase~=0 then
		gc.printf(S.cur.."/"..S.tar,795,335,150,"right")
	end
	setFont(25)
	mStr(S.tip,640,400)
end
function Pnt.intro()
	local T=sceneTemp
	gc.stencil(stencil_miniTitle,"replace",1)
	gc.setStencilTest("equal",1)
		gc.setColor(1,1,1,min(T,80)*.005)
		gc.push("transform")
			gc.translate(250,150)
			gc.scale(30)
			gc.rectangle("fill",0,0,26,14)
		gc.pop()
		gc.setColor(1,1,1,.06)
		for i=41,5,-2 do
			gc.setLineWidth(i)
			gc.line(200+(T-80)*25,130,(T-80)*25,590)
		end
	gc.setStencilTest()
	if T>=80 then
		gc.setColor(1,1,1,.5+sin((T-95)/30*3.142)*.5)
		mText(drawableText.anykey,640,615+sin(Timer()*3)*5)
	end
end
function Pnt.main()
	gc.setColor(1,1,1)
	gc.draw(IMG.coloredTitleImage,60,30,nil,1.3)
	setFont(30)
	gc.print(gameVersion,70,125)
	gc.print(system,610,100)
	players[1]:draw()
end
function Pnt.mode()
	local _
	local cam=mapCam
	gc.push("transform")
	gc.translate(640,360)
	gc.scale(cam.zoomK)
	gc.translate(-cam.x1,-cam.y1)
	gc.scale(cam.k1)
	local MM=modes
	local R=modeRanks
	local sel=cam.sel
	setFont(30)
	for _=1,#MM do
		local M=MM[_]
		if R[_]then
			gc.setLineWidth(8)
			gc.setColor(1,1,1,.2)
			for _=1,#M.unlock do
				local m=M.unlock[_]
				m=MM[m]
				gc.line(M.x,M.y,m.x,m.y)
			end

			local S=M.size
			local d=((M.x-(cam.x1+(sel and -180 or 0))/cam.k1)^2+(M.y-cam.y1/cam.k1)^2)^.55
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
				if sel==_ then
					gc.setColor(1,1,1)
					gc.setLineWidth(10)
					gc.rectangle("line",M.x-S+5,M.y-S+5,2*S-10,2*S-10)
				end
			elseif M.shape==2 then--diamond
				gc.circle("fill",M.x,M.y,S+5,4)
				if sel==_ then
					gc.setColor(1,1,1)
					gc.setLineWidth(10)
					gc.circle("line",M.x,M.y,S+5,4)
				end
			elseif M.shape==3 then--Octagon
				gc.circle("fill",M.x,M.y,S,8)
				if sel==_ then
					gc.setColor(1,1,1)
					gc.setLineWidth(10)
					gc.circle("line",M.x,M.y,S,8)
				end
			end
			_=drawableText[rankString[modeRanks[M.id]]]
			if _ then
				local dx,dy=6.26*sin(Timer()*1.26+M.id),12.6*sin(Timer()+M.id)
				gc.setColor(0,0,0,.5)
				mDraw(_,M.x+dx*1.5,M.y+dy*1.5)
				gc.setColor(1,1,1,.8)
				mDraw(_,M.x+dx,M.y+dy)
			end
			--[[
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
			]]
		end
	end
	gc.pop()
	if sel then
		local M=MM[sel]
		local lang=setting.lang
		gc.setColor(.7,.7,.7,.5)
		gc.rectangle("fill",920,0,360,720)--Info board
		gc.setColor(M.color)
		setFont(40)mStr(text.modes[sel][1],1100,5)
		setFont(30)mStr(text.modes[sel][2],1100,50)
		gc.setColor(1,1,1)
		setFont(28)gc.printf(text.modes[sel][3],920,110,360,"center")
		if M.slowMark then
			gc.draw(IMG.ctrlSpeedLimit,1230,50,nil,.4)
		end
		if M.score then
			mText(drawableText.highScore,1100,240)
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
					_=L[i].date
					if _ then gc.print(_,1155,284+25*i)end
				end
			else
				mText(drawableText.noScore,1100,370)
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
	for i=1,BGM.len do
		gc.print(BGM.list[i],50,90+30*i)
	end
	gc.draw(IMG.titleImage,640,310,nil,1.5,nil,206,35)
	if BGM.nowPlay then
		setFont(45)
		gc.setColor(sin(Timer()*.5)*.2+.8,sin(Timer()*.7)*.2+.8,sin(Timer())*.2+.8)
		mStr(BGM.nowPlay,630,460)
		local t=-Timer()%2.3/2
		if t<1 then
			gc.setColor(1,1,1,t)
			gc.draw(IMG.coloredTitleImage,640,310,nil,1.5+.1-.1*t,1.5+.3-.3*t,206,35)
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
		gc.setColor(SKIN.libColor[pen])
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
	local _
	for i=1,7 do
		_=setting.skin[i]
		gc.setColor(SKIN.libColor[_])
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
				gc.draw(IMG.badgeIcon,b[1]-14,b[2]-14)
			elseif b.t<50 then
				local t=((b.t-10)*.025)t=(3-2*t)*t*t
				gc.draw(IMG.badgeIcon,b[1]*(1-t)+b[3]*t-14,b[2]*(1-t)+b[4]*t-14)
			else
				gc.draw(IMG.badgeIcon,b[3]-14,b[4]-14)
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
local hexList={1,0,.5,1.732*.5,-.5,1.732*.5}for i=1,6 do hexList[i]=hexList[i]*150 end
local textPos={90,131,-90,131,-200,-25,-90,-181,90,-181,200,-25}
local dataPos={90,143,-90,143,-200,-13,-90,-169,90,-169,200,-13}

function Pnt.pause()
	local S=sceneTemp
	local T=S.timer*.02
	if T<1 or game.result then Pnt.play()end
	--Dark BG
	local _=T
	if game.result then _=_*.7 end
	gc.setColor(.15,.15,.15,_)
	gc.push("transform")
		gc.origin()
		gc.rectangle("fill",0,0,scr.w,scr.h)
	gc.pop()

	--Pause Info
	setFont(25)
	if game.pauseCount>0 then
		gc.setColor(1,.4,.4,T)
		gc.print(text.pauseCount..":["..game.pauseCount.."] "..format("%.2f",game.pauseTime).."s",70,100)
	end

	gc.setColor(1,1,1,T)

	--Mode Info
	_=drawableText.modeName
	gc.draw(_,40,180)
	gc.draw(drawableText.levelName,60+_:getWidth(),180)

	--Result Text
	setFont(35)
	mText(game.result and drawableText[game.result]or drawableText.pause,640,50-10*(5-sceneTemp.timer*.1)^1.5)

	--Infos
	if frame>180 then
		_=S.list
		setFont(26)
		for i=1,10 do
			gc.print(text.pauseStat[i],40,210+40*i)
			gc.printf(_[i],245,210+40*i,250,"right")
		end
	end

	--Radar Chart
	if T>.5 and frame>180 then
		T=T*2-1
		gc.setLineWidth(2)
		gc.push("transform")
			gc.translate(1026,400)

			--axes
			gc.setColor(1,1,1,T)
			for i=1,3 do
				local x,y=hexList[2*i-1],hexList[2*i]
				gc.line(-x,-y,x,y)
			end

			local C
			_=Timer()%6.2832
			if _>3.1416 then
				gc.setColor(1,1,1,-T*sin(_))
				setFont(35)
				C,_=text.radar,textPos
			else
				gc.setColor(1,1,1,T*sin(_))
				setFont(18)
				C,_=S.radar,dataPos
			end
			for i=1,6 do
				mStr(C[i],_[2*i-1],_[2*i])
			end
			gc.scale((3-2*T)*T)
			gc.setColor(1,1,1,T*(.5+.3*sin(Timer()*6.26)))gc.polygon("line",S.standard)
			_=S.color
			gc.setColor(_[1],_[2],_[3],T)
			_=S.val
			for i=1,9,2 do
				gc.polygon("fill",0,0,_[i],_[i+1],_[i+2],_[i+3])
			end
			gc.polygon("fill",0,0,_[11],_[12],_[1],_[2])
			gc.setColor(1,1,1,T)gc.polygon("line",S.val)
		gc.pop()
	end
end
function Pnt.setting_game()
	gc.setColor(1,1,1)
	mText(drawableText.setting_game,640,15)
	gc.draw(blockSkin[int(Timer()*2)%11+1],720,540,Timer()%6.28319,2,nil,15,15)
end
function Pnt.setting_video()
	gc.setColor(1,1,1)
	mText(drawableText.setting_video,640,15)
end
function Pnt.setting_sound()
	gc.setColor(1,1,1,.8)
	mText(drawableText.setting_sound,640,15)
	local t=Timer()
	local _=sceneTemp.jump
	local x,y=800,340+10*sin(t*.5)+(_-10)*_*.3
	gc.translate(x,y)
	gc.draw(IMG.miyaCH,0,0)
	gc.setColor(1,1,1,.7)
	gc.draw(IMG.miyaF1,4,47+4*sin(t*.9))
	gc.draw(IMG.miyaF2,42,107+5*sin(t))
	gc.draw(IMG.miyaF3,93,126+3*sin(t*.7))
	gc.draw(IMG.miyaF4,129,98+3*sin(t*.7))
	gc.translate(-x,-y)
end
local function timeConv(t)
	return t.."F "..int(t*16.67).."ms"
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
	mStr(timeConv(_.das),226+35*_.das,145)
	mStr(timeConv(_.arr),226+35*_.arr,235)
	mStr(timeConv(_.sddas),226+35*_.sddas,325)
	mStr(timeConv(_.sdarr),226+35*_.sdarr,415)

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
	mText(drawableText.keyboard,340,30)
	mText(drawableText.keyboard,940,30)
	gc.setColor(.3,.3,1)
	mText(drawableText.joystick,540,30)
	mText(drawableText.joystick,1140,30)

	gc.setColor(1,1,1)
	setFont(26)
	local b1,b2=keyMap[s.board],keyMap[s.board+2]
	for N=1,20 do
		if N<11 then
			gc.printf(text.acts[N],47,45*N+22,180,"right")
			mStr(b1[N],340,45*N+22)
			mStr(b2[N],540,45*N+22)
		else
			gc.printf(text.acts[N],647,45*N-428,180,"right")
			mStr(b1[N],940,45*N-428)
			mStr(b2[N],1040,45*N-428)
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
	gc.print(text.page..s.board,280,590)
	gc.draw(drawableText.ctrlSetHelp,50,650)
end
function Pnt.setting_skin()
	gc.setColor(1,1,1)
	for N=1,7 do
		local face=setting.face[N]
		local B=blocks[N][face]
		local x,y=-25+140*N-scs[N][face][2]*30,325+scs[N][face][1]*30
		local col=#B[1]
		for i=1,#B do for j=1,col do
			if B[i][j]then
				gc.draw(blockSkin[setting.skin[N]],x+30*j,y-30*i)
			end
		end end
		gc.circle("fill",-10+140*N,340,sin(Timer()*10)+5)
	end
	for i=1,6 do
		gc.draw(blockSkin[11+i],1110,100+60*i,nil,2)
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
	mText(drawableText.VKTchW,140+50*setting.VKTchW,260)
	mText(drawableText.VKOrgW,140+50*setting.VKTchW+50*setting.VKCurW,320)
	mText(drawableText.VKCurW,640+50*setting.VKCurW,380)
end
function Pnt.help()
	setFont(20)
	gc.setColor(1,1,1)
	for i=1,#text.help do
		gc.printf(text.help[i],150,30*i-10,1000,"center")
	end
	setFont(19)
	gc.print(text.used,30,330)
	gc.draw(IMG.titleImage,280,610,.1,1+.05*sin(Timer()*2.6),nil,206,35)
	gc.setLineWidth(3)
	gc.rectangle("line",18,18,263,263)
	gc.rectangle("line",1012,18,250,250)
	gc.draw(IMG.pay1,20,20)
	gc.draw(IMG.pay2,1014,20)
	setFont(20)
	mStr(text.group,640,490)
	gc.setColor(1,1,1,sin(Timer()*20)*.3+.6)
	setFont(30)
	mStr(text.support,150+sin(Timer()*4)*20,283)
	mStr(text.support,1138-sin(Timer()*4)*20,270)
end
function Pnt.stat()
	local chart=sceneTemp.chart
	setFont(24)
	local _,__=SKIN.libColor,setting.skin
	local A,B=chart.A1,chart.A2
	for x=1,7 do
		gc.setColor(_[__[x]])
		mStr(text.block[x],80*x,40)
		mStr(text.block[x],80*x,280)
		for y=1,4 do
			mStr(A[x][y],80*x,40+40*y)
			mStr(B[x][y],80*x,280+40*y)
		end
		mStr(chart.Y1[x],80*x,240)
		mStr(chart.Y2[x],80*x,480)
	end
	gc.setColor(1,1,1)
	A,B=chart.X1,chart.X2
	mStr(text.stat.spin,650,45)
	mStr(text.stat.clear,650,285)
	for y=1,4 do
		mStr(A[y],650,40+40*y)
		mStr(B[y],650,280+40*y)
	end

	setFont(22)
	for i=1,11 do
		gc.print(sceneTemp.item[i],740,40*i+10)
	end

	gc.setLineWidth(4)
	for x=1,8 do
		x=80*x-40
		gc.line(x,80,x,240)
		gc.line(x,320,x,480)
	end
	for y=2,6 do
		gc.line(40,40*y,600,40*y)
		gc.line(40,240+40*y,600,240+40*y)
	end

	gc.draw(IMG.titleImage,260,615,.2+.04*sin(Timer()*3),nil,nil,206,35)
end
function Pnt.history()
	gc.setColor(.2,.2,.2,.7)
	gc.rectangle("fill",30,45,1000,632)
	gc.setColor(1,1,1)
	gc.setLineWidth(4)
	gc.rectangle("line",30,45,1000,632)
	setFont(20)
	local _=sceneTemp
	gc.print(_[1][_[2]],40,50)
end
return Pnt