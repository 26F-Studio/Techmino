local gc,sys=love.graphics,love.system
local ms,kb,tc=love.mouse,love.keyboard,love.touch
local Timer=love.timer.getTime

local setFont=setFont
local mStr=mStr

local int,ceil,rnd,abs=math.floor,math.ceil,math.random,math.abs
local max,min,sin,cos=math.max,math.min,math.sin,math.cos
local log,rnd=math.log,math.random
local format=string.format
local ins,rem=table.insert,table.remove
local byte=string.byte

local scr=scr

local floatWheel=0
local function wheelScroll(y)
	if y>0 then
		if floatWheel<0 then floatWheel=0 end
		floatWheel=floatWheel+y^1.2
	elseif y<0 then
		if floatWheel>0 then floatWheel=0 end
		floatWheel=floatWheel-(-y)^1.2
	end
	while floatWheel>=1 do
		love.keypressed("up")
		floatWheel=floatWheel-1
	end
	while floatWheel<=-1 do
		love.keypressed("down")
		floatWheel=floatWheel+1
	end
end

--ALL SCENES & FUNCTIONS
do--calculator
	function sceneInit.calculator()
		sceneTemp={
			reg=false,
			val=0,
			sym=false,
			pass=false,
			tip=require("parts/getTip"),
		}
	end

	function keyDown.calculator(k)
		local S=sceneTemp
		if byte(k)>=48 and byte(k)<=57 then
			if S.sym=="="then
				S.val=tonumber(k)
				S.sym=false
			elseif S.sym then
				if not S.reg then
					S.reg=S.val
					S.val=tonumber(k)
				elseif S.val<1e13 then
					S.val=S.val*10+tonumber(k)
				end
			else
				if S.val<1e13 then
					S.val=S.val*10+tonumber(k)
				end
			end
		elseif k=="backspace"then
			if S.val>0 then
				S.val=int(S.val/10)
			end
		elseif k=="+"or k=="="and kb.isDown("rshift","lshift")then
			S.sym="+"
		elseif k=="-"then
			S.sym="-"
		elseif k=="*"or k=="8"and kb.isDown("rshift","lshift")then
			S.sym="*"
		elseif k=="/"then
			S.sym="/"
		elseif k=="return"then
			if S.val then
				if S.sym and S.reg then
					S.val=
						S.sym=="+"and S.reg+S.val or
						S.sym=="-"and S.reg-S.val or
						S.sym=="*"and S.reg*S.val or
						S.sym=="/"and S.reg/S.val or
						-1
				end
				S.sym="="
				S.reg=false
				if S.val==600+20+6 then
					S.pass=true
				elseif S.val==196000+022 then
					S.pass=true
					marking=nil
					LOG.print("\68\69\86\58\87\97\116\101\114\109\97\114\107\32\82\101\109\111\118\101\100","warn",color.lBlue)
					SFX.play("clear")
				elseif S.val==72943816 then
					S.pass=true
					for name,M in next,Modes do
						if not modeRanks[name]then
							modeRanks[name]=M.score and 0 or 6
						end
					end
					FILE.saveUnlock()
					LOG.print("\68\69\86\58\85\78\76\79\67\75\65\76\76","warn",color.lBlue)
					SFX.play("clear_2")
				elseif S.val==1379e8+2626e4+1379 then
					S.pass=true
					SCN.go("debug")
				elseif S.val==34494 then
					error("This is an error testing message.")
				elseif S.val==114 then
					S.reg=514
				elseif S.val==114514 then
					S.reg=1919810
				elseif S.val==1145141919810 then
					error("小鬼自裁请")
				elseif S.val==123456789 then
					S.reg=123456789
					S.val=987654321
				end
			end
		elseif k=="escape"then
			S.val,S.reg,S.sym=0
		elseif k=="delete"then
			S.val=0
		elseif k=="space"and S.pass then
			SCN.swapTo("intro")
		end
	end

	function Pnt.calculator()
		local S=sceneTemp
		gc.setColor(1,1,1)
		gc.setLineWidth(4)
		gc.rectangle("line",100,80,650,150)
		setFont(45)
		if S.reg then gc.printf(S.reg,0,100,720,"right")end
		if S.val then gc.printf(S.val,0,150,720,"right")end

		if S.sym then setFont(50)gc.print(S.sym,126,150)end
		if S.pass then setFont(30)mStr(S.tip,640,10)end
	end
end
do--minigame
	function sceneInit.minigame()
		BG.set("space")
		BGM.stop()
	end
end
do--p15
	function sceneInit.p15()
		BG.set("rainbow")
		BGM.play("push")
		sceneTemp={
			board={{1,2,3,4},{5,6,7,8},{9,10,11,12},{13,14,15,16}},
			x=4,y=4,
			startTime=0,
			time=0,
			move=0,
			state=2,

			color=0,
			blind=false,
			slide=true,
			pathVis=true,
			revKB=false,
		}
	end

	local function moveU(S,b,x,y)
		if y<4 then
			b[y][x],b[y+1][x]=b[y+1][x],b[y][x]
			S.y=y+1
		end
	end
	local function moveD(S,b,x,y)
		if y>1 then
			b[y][x],b[y-1][x]=b[y-1][x],b[y][x]
			S.y=y-1
		end
	end
	local function moveL(S,b,x,y)
		if x<4 then
			b[y][x],b[y][x+1]=b[y][x+1],b[y][x]
			S.x=x+1
		end
	end
	local function moveR(S,b,x,y)
		if x>1 then
			b[y][x],b[y][x-1]=b[y][x-1],b[y][x]
			S.x=x-1
		end
	end
	local function shuffleBoard(S,b)
		for i=1,300 do
			i=rnd()
			if i<.25 then moveU(S,b,S.x,S.y)
			elseif i<.5 then moveD(S,b,S.x,S.y)
			elseif i<.75 then moveL(S,b,S.x,S.y)
			else moveR(S,b,S.x,S.y)
			end
		end
	end
	local function checkBoard(b)
		for i=4,1,-1 do
			for j=1,4 do
				if b[i][j]~=4*i+j-4 then return false end
			end
		end
		return true
	end
	local function tapBoard(x,y,key)
		local S=sceneTemp
		if S.state<2 then
			if not key then
				if S.pathVis then
					sysFX.newRipple(.16,x,y,10)
				end
				x,y=int((x-320)/160)+1,int((y-40)/160)+1
			end
			local b=S.board
			local moves=0
			if S.x==x then
				if y>S.y and y<5 then
					for i=S.y,y-1 do
						moveU(S,b,x,i)
						moves=moves+1
					end
				elseif y<S.y and y>0 then
					for i=S.y,y+1,-1 do
						moveD(S,b,x,i)
						moves=moves+1
					end
				end
			elseif S.y==y then
				if x>S.x and x<5 then
					for i=S.x,x-1 do
						moveL(S,b,i,y)
						moves=moves+1
					end
				elseif x<S.x and x>0 then
					for i=S.x,x+1,-1 do
						moveR(S,b,i,y)
						moves=moves+1
					end
				end
			end
			if moves>0 then
				SFX.play("move")
				S.move=S.move+moves
				if S.state==0 then
					S.state=1
					S.startTime=Timer()
				end
				if checkBoard(b)then
					S.state=2
					S.time=Timer()-S.startTime
					if S.time<1 then		LOG.print("不是人",color.lBlue)
					elseif S.time<2 then	LOG.print("还是人",color.lBlue)
					elseif S.time<3 then	LOG.print("神仙",color.lBlue)
					elseif S.time<5 then	LOG.print("太强了",color.lBlue)
					elseif S.time<7.5 then	LOG.print("很强",color.lBlue)
					elseif S.time<10 then	LOG.print("可以的",color.lBlue)
					elseif S.time<20 then	LOG.print("马上入门了",color.lBlue)
					elseif S.time<30 then	LOG.print("入门不远了",color.lBlue)
					elseif S.time<60 then	LOG.print("多加练习",color.lBlue)
					else					LOG.print("第一次玩?加油",color.lBlue)
					end
					SFX.play("win")
				end
			end
		end
	end
	function keyDown.p15(k)
		local S=sceneTemp
		local b=S.board
		if k=="up"then
			tapBoard(S.x,S.y-(S.revKB and 1 or -1),true)
		elseif k=="down"then
			tapBoard(S.x,S.y+(S.revKB and 1 or -1),true)
		elseif k=="left"then
			tapBoard(S.x-(S.revKB and 1 or -1),S.y,true)
		elseif k=="right"then
			tapBoard(S.x+(S.revKB and 1 or -1),S.y,true)
		elseif k=="space"then
			shuffleBoard(S,b)
			S.state=0
			S.time=0
			S.move=0
		elseif k=="c"then
			if S.state==2 then
				S.color=(S.color+1)%5
			end
		elseif k=="r"then
			if S.state==0 then
				S.revKB=not S.revKB
			end
		elseif k=="s"then
			if S.state==0 then
				S.slide=not S.slide
				if not S.slide then
					S.pathVis=false
				end
			end
		elseif k=="p"then
			if S.state==0 and S.slide then
				S.pathVis=not S.pathVis
			end
		elseif k=="b"then
			if S.state==0 then
				S.blind=not S.blind
			end
		elseif k=="escape"then
			SCN.back()
		end
	end
	function mouseDown.p15(x,y,k)
		tapBoard(x,y)
	end
	function mouseMove.p15(x,y)
		if sceneTemp.slide then
			tapBoard(x,y)
		end
	end
	function touchDown.p15(id,x,y)
		tapBoard(x,y)
	end
	function touchMove.p15(id,x,y,dx,dy)
		if sceneTemp.slide then
			tapBoard(x,y)
		end
	end

	function Tmr.p15()
		local S=sceneTemp
		if S.state==1 then
			S.time=Timer()-S.startTime
		end
	end

	local frontColor={
		[0]={
			color.lRed,color.lRed,color.lRed,color.lRed,
			color.lGreen,color.lBlue,color.lBlue,color.lBlue,
			color.lGreen,color.lYellow,color.lPurple,color.lPurple,
			color.lGreen,color.lYellow,color.lPurple,color.lPurple,
		},--Colored(rank)
		{
			color.lRed,color.lRed,color.lRed,color.lRed,
			color.lOrange,color.lYellow,color.lYellow,color.lYellow,
			color.lOrange,color.lGreen,color.lBlue,color.lBlue,
			color.lOrange,color.lGreen,color.lBlue,color.lBlue,
		},--Rainbow(rank)
		{
			color.lRed,color.lRed,color.lRed,color.lRed,
			color.lBlue,color.lBlue,color.lBlue,color.lBlue,
			color.lGreen,color.lYellow,color.lPurple,color.lPurple,
			color.lGreen,color.lYellow,color.lPurple,color.lPurple,
		},--Colored(row)
		{
			color.white,color.white,color.white,color.white,
			color.white,color.white,color.white,color.white,
			color.white,color.white,color.white,color.white,
			color.white,color.white,color.white,color.white,
		},--Grey
		{
			color.white,color.white,color.white,color.white,
			color.white,color.white,color.white,color.white,
			color.white,color.white,color.white,color.white,
			color.white,color.white,color.white,color.white,
		},--Black
	}
	local backColor={
		[0]={
			color.dRed,color.dRed,color.dRed,color.dRed,
			color.dGreen,color.dBlue,color.dBlue,color.dBlue,
			color.dGreen,color.dYellow,color.dPurple,color.dPurple,
			color.dGreen,color.dYellow,color.dPurple,color.dPurple,
		},--Colored(rank)
		{
			color.dRed,color.dRed,color.dRed,color.dRed,
			color.dOrange,color.dYellow,color.dYellow,color.dYellow,
			color.dOrange,color.dGreen,color.dBlue,color.dBlue,
			color.dOrange,color.dGreen,color.dBlue,color.dBlue,
		},--Rainbow(rank)
		{
			color.dRed,color.dRed,color.dRed,color.dRed,
			color.dBlue,color.dBlue,color.dBlue,color.dBlue,
			color.dGreen,color.dYellow,color.dPurple,color.dPurple,
			color.dGreen,color.dYellow,color.dPurple,color.dPurple,
		},--Colored(row)
		{
			color.dGrey,color.dGrey,color.dGrey,color.dGrey,
			color.dGrey,color.dGrey,color.dGrey,color.dGrey,
			color.dGrey,color.dGrey,color.dGrey,color.dGrey,
			color.dGrey,color.dGrey,color.dGrey,color.dGrey,
		},--Grey
		{
			color.black,color.black,color.black,color.black,
			color.black,color.black,color.black,color.black,
			color.black,color.black,color.black,color.black,
			color.black,color.black,color.black,color.black,
		},--Black
	}
	function Pnt.p15()
		local S=sceneTemp

		setFont(40)
		gc.setColor(1,1,1)
		gc.print(format("%.3f",S.time),1026,80)
		gc.print(S.move,1026,150)

		if S.state==2 then gc.setColor(.9,.9,0)		--win
		elseif S.state==1 then gc.setColor(.9,.9,.9)--game
		elseif S.state==0 then gc.setColor(.2,.8,.2)--ready
		end
		gc.setLineWidth(10)
		gc.rectangle("line",313,33,654,654,18)

		gc.setLineWidth(4)
		local x,y=S.x,S.y
		local blind=S.blind and S.state==1
		setFont(80)
		for i=1,4 do
			for j=1,4 do
				if x~=j or y~=i then
					local N=S.board[i][j]

					local C=blind and 1 or S.color
					local backColor=backColor[C]
					local frontColor=frontColor[C]

					gc.setColor(backColor[N])
					gc.rectangle("fill",j*160+163,i*160-117,154,154,8)
					gc.setColor(frontColor[N])
					gc.rectangle("line",j*160+163,i*160-117,154,154,8)
					if not blind then
						gc.setColor(.1,.1,.1)
						mStr(N,j*160+240,i*160-96)
						mStr(N,j*160+242,i*160-98)
						gc.setColor(1,1,1)
						mStr(N,j*160+243,i*160-95)
					end
				end
			end
		end
		gc.setColor(0,0,0,.3)
		gc.setLineWidth(10)
		gc.rectangle("line",x*160+173,y*160-107,134,134,50)
	end
end
do--schulte_G
	function sceneInit.schulte_G()
		BGM.play("way")
		sceneTemp={
			board={},
			rank=3,
			blind=false,
			disappear=false,

			startTime=0,
			time=0,
			error=0,
			state=0,
			target=0,
		}
	end

	local function newBoard()
		local S=sceneTemp
		local L={}
		for i=1,S.rank^2 do
			L[i]=i
		end
		for i=1,S.rank^2 do
			S.board[i]=rem(L,rnd(#L))
		end
	end
	local function tapBoard(x,y)
		local S=sceneTemp
		if x>320 and x<960 and y>40 and y<680 then
			if S.state==0 then
				newBoard()
				S.state=1
				S.startTime=Timer()
				S.target=1
			elseif S.state==1 then
				x=S.rank*(int((y-40)/640*S.rank))+int((x-320)/640*S.rank)+1
				if S.board[x]==S.target then
					S.target=S.target+1
					if S.target<=S.rank^2 then
						SFX.play("lock")
					else
						S.time=Timer()-S.startTime+S.error
						S.state=2
						SFX.play("reach")
					end
				else
					SFX.play("finesseError")
					S.error=S.error+1
				end
			end
		end
	end

	function mouseDown.schulte_G(x,y,k)
		tapBoard(x,y)
	end
	function touchDown.schulte_G(id,x,y)
		tapBoard(x,y)
	end
	function keyDown.schulte_G(key)
		local S=sceneTemp
		if key=="space"or key=="r"then
			if sceneTemp.state>0 then
				S.board={}
				S.time=0
				S.error=0
				S.state=0
				S.target=0
			end
		elseif key=="z"or key=="x"then
			tapBoard(ms.getPosition())
		elseif key=="b"then
			if S.state==0 then
				S.blind=not S.blind
			end
		elseif key=="d"then
			if S.state==0 then
				S.disappear=not S.disappear
			end
		elseif key=="3"or key=="4"or key=="5"or key=="6"then
			if S.state==0 then
				S.rank=tonumber(key)
			end
		elseif key=="escape"then
			SCN.back()
		end
	end

	function Tmr.schulte_G()
		local S=sceneTemp
		if S.state==1 then
			S.time=Timer()-S.startTime+S.error
		end
	end

	local fontSize={nil,nil,120,100,80,60}
	function Pnt.schulte_G()
		local S=sceneTemp

		setFont(40)
		gc.setColor(1,1,1)
		gc.print(format("%.3f",S.time),1026,80)
		gc.print(S.error,1026,150)

		setFont(70)
		mStr(S.state==1 and S.target or S.state==0 and"Ready"or S.state==2 and"Win",1130,300)

		if S.state==1 then gc.setColor(.9,.9,.9)	--game
		elseif S.state==0 then gc.setColor(.2,.8,.2)--ready
		elseif S.state==2 then gc.setColor(.9,.9,0)	--win
		end
		gc.setLineWidth(10)
		gc.rectangle("line",310,30,660,660)

		local rank=S.rank
		local width=640/rank
		local blind=S.state==0 or S.blind and(S.state==2 or S.target>1)
		gc.setLineWidth(4)
		local f=fontSize[rank]
		setFont(f)
		for i=1,rank do
			for j=1,rank do
				local N=S.board[rank*(i-1)+j]
				if not(S.state==1 and S.disappear and N<S.target)then
					gc.setColor(.6,.4,.4)
					gc.rectangle("fill",320+(j-1)*width,(i-1)*width+40,width,width)
					gc.setColor(1,1,1)
					gc.rectangle("line",320+(j-1)*width,(i-1)*width+40,width,width)
					if not blind then
						local x,y=320+(j-.5)*width,40+(i-.5)*width-f*.67
						gc.setColor(.1,.1,.1)
						mStr(N,x-3,y-1)
						mStr(N,x-1,y-3)
						gc.setColor(1,1,1)
						mStr(N,x,y)
					end
				end
			end
		end
	end
end
do--load
	function sceneInit.load()
		sceneTemp={
			phase=1,--Loading stage
			cur=1,--Counter
			tar=#VOC.name,--Loading bar length(current)
			tip=setting.appLock or require("parts/getTip"),
			list={
				#VOC.name,
				#BGM.list,
				#SFX.list,
				IMG.getCount(),
				#Modes,
				1,
			},
			skip=false,--If skipped
		}
	end
	function sceneBack.load()
		love.event.quit()
	end

	function keyDown.load(k)
		if k=="a"then
			sceneTemp.skip=true
		elseif k=="s"then
			marking=nil
			sceneTemp.skip=true
		elseif k=="escape"then
			SCN.back()
		end
	end
	function touchDown.load(id,x,y)
		if #tc.getTouches()==2 then
			sceneTemp.skip=true
		end
	end

	function Tmr.load()
		local t=Timer()
		local S=sceneTemp
		repeat
			if S.phase==1 then
				VOC.loadOne(S.cur)
			elseif S.phase==2 then
				BGM.loadOne(S.cur)
			elseif S.phase==3 then
				SFX.loadOne(S.cur)
			elseif S.phase==4 then
				IMG.loadOne(S.cur)
			elseif S.phase==5 then
				local m=Modes[S.cur]--Mode template
				local M=require("modes/"..m.name)--Mode file
				Modes[m.name],Modes[S.cur]=M
				for k,v in next,m do
					M[k]=v
				end
				M.records=FILE.loadRecord(m.name)or M.score and{}
				if M.score then
					if modeRanks[M.name]==6 then
						modeRanks[M.name]=0
					end
				else
					modeRanks[M.name]=6
				end
				-- M.icon=gc.newImage("image/modeIcon/"..m.icon..".png")
				-- M.icon=gc.newImage("image/modeIcon/custom.png")
			elseif S.phase==6 then
				--------------------------Loading other little things here
				SKIN.load()
				stat.run=stat.run+1
				--------------------------
				if not setting.appLock then
					SFX.play("welcome_sfx")
					VOC.play("welcome")
				end
			else
				S.cur=S.cur+1
				S.tar=S.cur
				if S.cur>62.6 then
					SCN.swapTo(setting.appLock and "calculator"or"intro","none")
				end
				loadingFinished=true
				return
			end
			S.cur=S.cur+1
			if S.cur>S.tar then
				S.phase=S.phase+1
				S.cur=1
				S.tar=S.list[S.phase]
				if not S.tar then
					S.phase=0
					S.tar=1
				end
			end
		until not S.skip and Timer()-t>.01
	end

	function Pnt.load()
		local S=sceneTemp
		gc.setLineWidth(4)
		gc.setColor(1,1,1,.5)
		gc.rectangle("fill",300,330,S.cur/S.tar*680,60,5)
		gc.setColor(1,1,1)
		gc.rectangle("line",300,330,680,60,5)
		if not setting.appLock then
			setFont(35)
			gc.print(text.load[S.phase],340,335)
			if S.phase~=0 then
				gc.printf(S.cur.."/"..S.tar,795,335,150,"right")
			end
			setFont(25)
			mStr(S.tip,640,400)
		end
	end
end
do--intro
	function sceneInit.intro()
		BG.set("space")
		sceneTemp={
			t1=0,--Timer 1
			t2=0,--Timer 2
			r={},--Random animation type
		}
		for i=1,8 do
			sceneTemp.r[i]=rnd(5)
		end
		BGM.play("blank")
	end

	function mouseDown.intro(x,y,k)
		if k==2 then
			VOC.play("bye")
			SCN.back()
		elseif NOGAME=="delCC"then
			LOG.print("Please quit the game, then delete CCloader.dll(21KB) in saving folder!",600,color.yellow)
			LOG.print("请关闭游戏,然后删除存档文件夹内的 CCloader.dll(21KB) !",600,color.yellow)
			TASK.new(function(S)
				S[1]=S[1]-1
				if S[1]==0 then
					love.system.openURL(love.filesystem.getSaveDirectory())
					return true
				end
			end,{60})
		else
			if newVersionLaunch then
				SCN.push("main","fade")
				SCN.swapTo("history","fade")
				LOG.print(text.newVersion,"warn",color.lBlue)
			else
				SCN.go("main")
			end
		end
	end
	function touchDown.intro(id,x,y)
		mouseDown.intro()
	end
	function keyDown.intro(key)
		if key=="escape"then
			mouseDown.intro(nil,nil,2)
		else
			mouseDown.intro()
		end
	end

	function Tmr.intro()
		local S=sceneTemp
		S.t1=S.t1+1
		S.t2=S.t2+1
	end

	local titleTransform={
		function(t)
			gc.translate(0,max(50-t,0)^2/25)
		end,
		function(t)
			gc.translate(0,-max(50-t,0)^2/25)
		end,
		function(t,i)
			local d=max(50-t,0)
			gc.translate(sin(Timer()*3+626*i)*d,cos(Timer()*3+626*i)*d)
		end,
		function(t,i)
			local d=max(50-t,0)
			gc.translate(sin(Timer()*3+626*i)*d,-cos(Timer()*3+626*i)*d)
		end,
		function(t)
			gc.setColor(1,1,1,min(t*.02,1)+rnd()*.2)
		end,
	}
	function Pnt.intro()
		local S=sceneTemp
		local t=S.t1
		local T=(t+110)%300
		if T<30 then
			gc.setLineWidth(4+(30-T)^1.626/62)
		else
			gc.setLineWidth(4)
		end
		local L=title
		gc.push("transform")
		gc.translate(126,226)
		for i=1,8 do
			local T=t-i*15
			if T>0 then
				gc.push("transform")
					gc.setColor(1,1,1,min(T*.025,1))
					titleTransform[S.r[i]](T,i)
					local dt=(t+62-5*i)%300
					if dt<20 then
						gc.translate(0,abs(10-dt)-10)
					end
					gc.polygon("line",L[i])
				gc.pop()
			end
		end
		gc.pop()
		t=S.t2
		if t>=80 then
			gc.setColor(1,1,1,.6+sin((t-80)*.0626)*.3)
			mText(drawableText.anykey,640,615+sin(Timer()*3)*5)
		end
	end
end
do--main
	function sceneInit.main()
		BG.set("space")
		BGM.play("blank")

		modeEnv={}
		--Create demo player
		destroyPlayers()
		PLY.newDemoPlayer(1,900,35,1.1)
	end

	function Tmr.main(dt)
		players[1]:update(dt)
	end

	function Pnt.main()
		gc.setColor(1,1,1)
		gc.draw(IMG.title_color,60,30,nil,1.3)
		setFont(30)
		gc.print(gameVersion,70,125)
		gc.print(system,610,100)
		local L=text.modes[stat.lastPlay]
		setFont(25)
		gc.print(L[1],700,470)
		gc.print(L[2],700,500)
		players[1]:draw()
	end
end
do--mode
	local touchDist=nil
	function sceneInit.mode(org)
		BG.set("space")
		BGM.play("blank")
		destroyPlayers()
		local cam=mapCam
		cam.zoomK=org=="main"and 5 or 1
		if cam.sel then
			local M=Modes[cam.sel]
			cam.x,cam.y=M.x*cam.k+180,M.y*cam.k
			cam.x1,cam.y1=cam.x,cam.y
		end
	end

	local function onMode(x,y)
		local cam=mapCam
		x=(cam.x1-640+x)/cam.k1
		y=(cam.y1-360+y)/cam.k1
		for name,M in next,Modes do
			if modeRanks[name]then
				local s=M.size
				if M.shape==1 then
					if x>M.x-s and x<M.x+s and y>M.y-s and y<M.y+s then return name end
				elseif M.shape==2 then
					if abs(x-M.x)+abs(y-M.y)<s then return name end
				elseif M.shape==3 then
					if(x-M.x)^2+(y-M.y)^2<s^2 then return name end
				end
			end
		end
	end
	function wheelMoved.mode(x,y)
		local cam=mapCam
		local t=cam.k
		local k=t+y*.1
		if k>1.5 then k=1.5
		elseif k<.3 then k=.3
		end
		t=k/t
		if cam.sel then
			cam.x=(cam.x-180)*t+180
			cam.y=cam.y*t
		else
			cam.x=cam.x*t
			cam.y=cam.y*t
		end
		cam.k=k
		cam.keyCtrl=false
	end
	function mouseMove.mode(x,y,dx,dy)
		if ms.isDown(1)then
			mapCam.x,mapCam.y=mapCam.x-dx,mapCam.y-dy
		end
		mapCam.keyCtrl=false
	end
	function mouseClick.mode(x,y,k)
		local cam=mapCam
		local _=cam.sel
		if not _ or x<920 then
			local SEL=onMode(x,y)
			if _~=SEL then
				if SEL then
					SFX.play("click")
					cam.moving=true
					_=Modes[SEL]
					cam.x=_.x*cam.k+180
					cam.y=_.y*cam.k
					cam.sel=SEL
				else
					cam.sel=nil
					cam.x=cam.x-180
				end
			elseif _ then
				keyDown.mode("return")
			end
		end
		cam.keyCtrl=false
	end
	function touchDown.mode(id,x,y)
		touchDist=nil
	end
	function touchMove.mode(id,x,y,dx,dy)
		local L=tc.getTouches()
		if not L[2]then
			mapCam.x,mapCam.y=mapCam.x-dx,mapCam.y-dy
		elseif not L[3]then
			x,y=xOy:inverseTransformPoint(tc.getPosition(L[1]))
			dx,dy=xOy:inverseTransformPoint(tc.getPosition(L[2]))--Not delta!!!
			local d=(x-dx)^2+(y-dy)^2
			if d>100 then
				d=d^.5
				if touchDist then
					wheelMoved.mode(nil,(d-touchDist)*.02)
				end
				touchDist=d
			end
		end
		mapCam.keyCtrl=false
	end
	function touchClick.mode(x,y,id)
		mouseClick.mode(x,y,1)
	end
	function keyDown.mode(key)
		if key=="return"then
			if mapCam.sel then
				if mapCam.sel=="custom_clear"or mapCam.sel=="custom_puzzle"then
					if customSel[11]>1 then
						if customSel[7]==5 then
							LOG.print(text.ai_fixed,"warn",color.red)
							return
						elseif #preBag>0 then
							LOG.print(text.ai_prebag,"warn",color.red)
							return
						end
					end
				end
				mapCam.keyCtrl=false
				SCN.push()
				loadGame(mapCam.sel)
			end
		elseif key=="escape"then
			if mapCam.sel then
				mapCam.sel=nil
			else
				SCN.back()
			end
		elseif mapCam.sel=="custom_clear" or mapCam.sel=="custom_puzzle" then
			if key=="e"then
				SCN.go("custom")
			end
		end
	end

	function Tmr.mode(dt)
		local cam=mapCam
		local x,y,k=cam.x,cam.y,cam.k
		local F
		if not SCN.swapping then
			if kb.isDown("up",	"w")then	y=y-10*k F=true end
			if kb.isDown("down","s")then	y=y+10*k F=true end
			if kb.isDown("left","a")then	x=x-10*k F=true end
			if kb.isDown("right","d")then	x=x+10*k F=true end
			local js1=joysticks[1]
			if js1 then
				local k=js1:getAxis(1)
				if k~="c"then
					if k=="u"or k=="ul"or k=="ur"then y=y-10*k F=true end
					if k=="d"or k=="dl"or k=="dl"then y=y+10*k F=true end
					if k=="l"or k=="ul"or k=="dl"then x=x-10*k F=true end
					if k=="r"or k=="ur"or k=="dr"then x=x+10*k F=true end
				end
			end
		end
		if F or cam.keyCtrl and(x-cam.x1)^2+(y-cam.y1)^2>2.6 then
			if F then
				cam.keyCtrl=true
			end
			local x,y=(cam.x1-180)/cam.k1,cam.y1/cam.k1
			for name,M in next,Modes do
				if modeRanks[name]then
					local SEL
					local s=M.size
					if M.shape==1 then
						if x>M.x-s and x<M.x+s and y>M.y-s and y<M.y+s then SEL=name end
					elseif M.shape==2 then
						if abs(x-M.x)+abs(y-M.y)<s then SEL=name end
					elseif M.shape==3 then
						if(x-M.x)^2+(y-M.y)^2<s^2 then SEL=name end
					end
					if SEL and cam.sel~=SEL then
						cam.sel=SEL
						SFX.play("click")
					end
				end
			end
		end

		if x>1850*k then x=1850*k
		elseif x<-1000*k then x=-1000*k
		end
		if y>500*k then y=500*k
		elseif y<-1900*k then y=-1900*k
		end
		cam.x,cam.y=x,y
		--Keyboard controlling

		cam.x1=cam.x1*.85+x*.15
		cam.y1=cam.y1*.85+y*.15
		cam.k1=cam.k1*.85+k*.15
		local _=SCN.stat.tar
		cam.zoomMethod=_=="play"and 1 or _=="mode"and 2
		if cam.zoomMethod==1 then
			if cam.sel then
				local M=Modes[cam.sel]
				cam.x=cam.x*.8+M.x*cam.k*.2
				cam.y=cam.y*.8+M.y*cam.k*.2
			end
			_=cam.zoomK
			if _<.8 then _=_*1.05 end
			if _<1.1 then _=_*1.05 end
			cam.zoomK=_*1.05
		elseif cam.zoomMethod==2 then
			cam.zoomK=cam.zoomK^.9
		end
	end

	local rankString={
		"D","C","B","A","S",
	}
	local modeRankColor={
		color.dRed,		--D
		color.dOrange,	--C
		color.lYellow,	--B
		color.lBlue,	--A
		color.lCyan,	--S
		color.lGreen,	--Special
	}
	function Pnt.mode()
		local _
		local cam=mapCam
		gc.push("transform")
		gc.translate(640,360)
		gc.scale(cam.zoomK)
		gc.translate(-cam.x1,-cam.y1)
		gc.scale(cam.k1)
		local R=modeRanks
		local sel=cam.sel
		setFont(30)

		--Draw lines connecting modes
		gc.setLineWidth(8)
		gc.setColor(1,1,1,.2)
		for name,M in next,Modes do
			if R[name]then
				for _=1,#M.unlock do
					local m=Modes[M.unlock[_]]
					gc.line(M.x,M.y,m.x,m.y)
				end
			end
		end

		for name,M in next,Modes do
			if R[name]then
				local S=M.size
				local d=((M.x-(cam.x1+(sel and -180 or 0))/cam.k1)^2+(M.y-cam.y1/cam.k1)^2)^.55
				if d<500 then S=S*(1.25-d*0.0005) end
				local c=modeRankColor[R[M.name]]
				if c then
					gc.setColor(c)
				else
					c=.5+sin(Timer()*6.26)*.2
					S=S*(.9+c*.4)
					gc.setColor(c,c,c)
				end
				if M.shape==1 then--Rectangle
					gc.rectangle("fill",M.x-S,M.y-S,2*S,2*S)
					if sel==name then
						gc.setColor(1,1,1)
						gc.setLineWidth(10)
						gc.rectangle("line",M.x-S+5,M.y-S+5,2*S-10,2*S-10)
					end
				elseif M.shape==2 then--Diamond
					gc.circle("fill",M.x,M.y,S+5,4)
					if sel==name then
						gc.setColor(1,1,1)
						gc.setLineWidth(10)
						gc.circle("line",M.x,M.y,S+5,4)
					end
				elseif M.shape==3 then--Octagon
					gc.circle("fill",M.x,M.y,S,8)
					if sel==name then
						gc.setColor(1,1,1)
						gc.setLineWidth(10)
						gc.circle("line",M.x,M.y,S,8)
					end
				end
				name=drawableText[rankString[R[M.name]]]
				if name then
					gc.setColor(0,0,0,.26)
					mDraw(name,M.x,M.y)
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
			local M=Modes[sel]
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
			gc.draw(TEXTURE.mapCross,460-20,360-20)
		end
	end
end
do--music
	function sceneInit.music()
		if BGM.nowPlay then
			for i=1,BGM.len do
				if BGM.list[i]==BGM.nowPlay then
					sceneTemp=i--Music selected
					return
				end
			end
		else
			sceneTemp=1
		end
	end

	function wheelMoved.music(x,y)
		wheelScroll(y)
	end
	function keyDown.music(key)
		local S=sceneTemp
		if key=="down"then
			if S<BGM.len then
				sceneTemp=S+1
				SFX.play("move",.7)
			end
		elseif key=="up"then
			if S>1 then
				sceneTemp=S-1
				SFX.play("move",.7)
			end
		elseif key=="return"or key=="space"then
			if BGM.nowPlay~=BGM.list[S]then
				if setting.bgm>0 then
					SFX.play("click")
					BGM.play(BGM.list[S])
				end
			else
				BGM.stop()
			end
		elseif key=="escape"then
			SCN.back()
		end
	end

	function Pnt.music()
		gc.setColor(.7,.7,.7)
		gc.draw(drawableText.musicRoom,20,20)
		gc.setColor(1,1,1)
		gc.draw(drawableText.musicRoom,22,23)

		gc.draw(drawableText.right,270,350+10)
		setFont(50)
		gc.print(BGM.list[sceneTemp],320,350+5)
		setFont(35)
		if sceneTemp>1 then			gc.print(BGM.list[sceneTemp-1],320,350-30)end
		if sceneTemp<BGM.len then	gc.print(BGM.list[sceneTemp+1],320,350+65)end
		setFont(20)
		if sceneTemp>2 then			gc.print(BGM.list[sceneTemp-2],320,350-50)end
		if sceneTemp<BGM.len-1 then	gc.print(BGM.list[sceneTemp+2],320,350+110)end

		gc.draw(IMG.title,840,220,nil,1.5,nil,206,35)
		if BGM.nowPlay then
			gc.draw(drawableText.nowPlaying,700-drawableText.nowPlaying:getWidth(),500)
			setFont(50)
			gc.setColor(sin(Timer()*.5)*.2+.8,sin(Timer()*.7)*.2+.8,sin(Timer())*.2+.8)
			gc.print(BGM.nowPlay,710,500)

			local t=-Timer()%2.3/2
			if t<1 then
				gc.setColor(1,1,1,t)
				gc.draw(IMG.title_color,840,220,nil,1.5+.1-.1*t,1.5+.3-.3*t,206,35)
			end
		end
	end
end
do--custom
	function sceneInit.custom()
		sceneTemp=1--Option selected
		destroyPlayers()
		BG.set(customRange.bg[customSel[12]])
		BGM.play(customRange.bgm[customSel[13]])
	end

	local customSet={
		{3,20,1,1,7,1,1,1,3,4,1,2,3},
		{5,20,1,1,7,1,1,1,8,3,8,3,3},
		{1,22,1,1,7,3,1,1,8,4,1,6,7},
		{3,20,1,1,7,1,1,3,8,3,1,6,8},
		{25,11,8,11,4,1,2,1,8,3,1,4,9},
	}
	function keyDown.custom(key)
		local sel=sceneTemp
		if key=="up"or key=="w"then
			sceneTemp=(sel-2)%#customID+1
		elseif key=="down"or key=="s"then
			sceneTemp=sel%#customID+1
		elseif key=="left"or key=="a"then
			customSel[sel]=(customSel[sel]-2)%#customRange[customID[sel]]+1
			if sel==12 then
				BG.set(customRange.bg[customSel[12]])
			elseif sel==13 then
				BGM.play(customRange.bgm[customSel[13]])
			end
		elseif key=="right"or key=="d"then
			customSel[sel]=customSel[sel]%#customRange[customID[sel]]+1
			if sel==12 then
				BG.set(customRange.bg[customSel[sel]])
			elseif sel==13 then
				BGM.play(customRange.bgm[customSel[sel]])
			end
		elseif key=="q"then
			SCN.go("sequence")
		elseif key=="e"then
			SCN.swapTo("draw","swipeL")
		elseif #key==1 then
			local T=tonumber(key)
			if T and T>=1 and T<=5 then
				for i=1,#customSet[T]do
					customSel[i]=customSet[T][i]
				end
				BG.set(customRange.bg[customSel[12]])
				BGM.play(customRange.bgm[customSel[13]])
			end
		elseif key=="escape"then
			SCN.back()
		end
	end

	function Pnt.custom()
		gc.setColor(1,1,1,.3+sin(Timer()*8)*.2)
		gc.rectangle("fill",100,115+40*sceneTemp,570,40)
		gc.setColor(.7,.7,.7)gc.draw(drawableText.custom,360,20)
		gc.setColor(1,1,1)gc.draw(drawableText.custom,362,23)
		setFont(35)
		for i=1,#customID do
			local k=customID[i]
			local y=110+40*i
			gc.printf(text.customOption[k],100,y,320,"right")
			if text.customVal[k]then
				gc.print(text.customVal[k][customSel[i]],440,y)
			else
				gc.print(customRange[k][customSel[i]],440,y)
			end
		end
	end
end
do--sequence
	function sceneInit.sequence()
		sceneTemp={cur=#preBag,sure=0}
	end

	local minoKey={
		["1"]=1,["2"]=2,["3"]=3,["4"]=4,["5"]=5,["6"]=6,["7"]=7,
		z=1,s=2,j=3,l=4,t=5,o=6,i=7,
		p=10,q=11,f=12,e=13,u=15,
		v=16,w=17,x=18,r=21,y=22,n=23,h=24,
	}
	local minoKey2={
		["1"]=8,["2"]=9,["3"]=19,["4"]=20,["5"]=14,["7"]=25,
		z=8,s=9,t=14,j=19,l=20,i=25
	}
	function keyDown.sequence(key)
		local s=sceneTemp
		if type(key)=="number"then
			local C=s.cur+1
			ins(preBag,C,key)
			s.cur=C
		elseif key=="c"and kb.isDown("lctrl","rctrl")or key=="cC"then
			if #preBag>0 then
				sys.setClipboardText("Techmino SEQ:"..copySequence())
				LOG.print(text.copySuccess,color.green)
			end
		elseif key=="v"and kb.isDown("lctrl","rctrl")or key=="cV"then
			local str=sys.getClipboardText()
			local p=string.find(str,":")--ptr*
			if p then str=string.sub(str,p+1)end
			if not pasteSequence(str)then
				LOG.print(text.dataCorrupted,color.red)
			end
		elseif #key==1 then
			local i=(kb.isDown("lshift","lalt","rshift","ralt")and minoKey2 or minoKey)[key]
			if i then
				local C=s.cur+1
				ins(preBag,C,i)
				s.cur=C
			end
		else
			if key=="left"then
				if s.cur>0 then s.cur=s.cur-1 end
			elseif key=="right"then
				if s.cur<#preBag then s.cur=s.cur+1 end
			elseif key=="backspace"then
				local C=s.cur
				if C>0 then
					rem(preBag,C)
					s.cur=C-1
				end
			elseif key=="escape"then
				SCN.back()
			elseif key=="delete"then
				if sceneTemp.sure>20 then
					preBag={}
					sceneTemp.cur=0
					sceneTemp.sure=0
					SFX.play("finesseError",.7)
				else
					sceneTemp.sure=50
				end
			end
		end
	end

	function Tmr.sequence()
		if sceneTemp.sure>0 then sceneTemp.sure=sceneTemp.sure-1 end
	end

	function Pnt.sequence()
		local S=sceneTemp
		gc.setColor(.7,.7,.7)gc.draw(drawableText.sequence,120,-15)
		gc.setColor(1,1,1)gc.draw(drawableText.sequence,122,-12)
		gc.setLineWidth(4)
		gc.rectangle("line",100,100,1080,260)
		setFont(30)
		local bag=preBag
		local len=#bag

		setFont(40)
		gc.print(len,120,300)

		local L=TEXTURE.miniBlock
		local lib=SKIN.libColor
		local set=setting.skin

		local x,y=120,126
		local cx,cy=120,126
		for i=1,len do
			local B=L[bag[i]]
			gc.setColor(lib[set[bag[i]]])
			gc.draw(B,x,y,nil,15,15,0,B:getHeight()*.5)
			x=x+B:getWidth()*15+10
			if x>1126 then
				x,y=120,y+50
			end
			if i==S.cur then
				cx,cy=x,y
			end
		end

		gc.setColor(.5,1,.5,.6+.4*sin(Timer()*6.26))
		gc.line(cx-5,cy-20,cx-5,cy+20)

		--Confirm reset
		if S.sure>0 then
			gc.setColor(1,1,1,S.sure*.02)
			gc.draw(drawableText.question,980,470)
		end
	end
end
do--draw
	function sceneInit.draw()
		BG.set("space")
		sceneTemp={
			sure=0,
			pen=1,
			x=1,y=1,
			demo=false,
		}
	end

	local penKey={
		q=1,w=2,e=3,r=4,t=5,y=6,u=7,i=8,o=9,p=10,["["]=11,
		a=12,s=13,d=14,f=15,g=16,h=17,
		z=0,x=-1,
	}
	function mouseDown.draw(x,y,k)
		mouseMove.draw(x,y)
	end
	function mouseMove.draw(x,y,dx,dy)
		local sx,sy=int((x-200)/30)+1,20-int((y-60)/30)
		if sx<1 or sx>10 then sx=nil end
		if sy<1 or sy>20 then sy=nil end
		sceneTemp.x,sceneTemp.y=sx,sy
		if sx and sy and ms.isDown(1,2,3)then
			preField[sy][sx]=ms.isDown(1)and sceneTemp.pen or ms.isDown(2)and -1 or 0
		end
	end
	function wheelMoved.draw(x,y)
		local pen=sceneTemp.pen
		if y<0 then
			pen=pen+1
			if pen==8 then pen=9 elseif pen==14 then pen=0 end
		else
			pen=pen-1
			if pen==8 then pen=7 elseif pen==-1 then pen=13 end
		end
		sceneTemp.pen=pen
	end
	function touchDown.draw(id,x,y)
		mouseMove.draw(x,y)
	end
	function touchMove.draw(id,x,y,dx,dy)
		local sx,sy=int((x-200)/30)+1,20-int((y-60)/30)
		if sx<1 or sx>10 then sx=nil end
		if sy<1 or sy>20 then sy=nil end
		sceneTemp.x,sceneTemp.y=sx,sy
		if sx and sy then
			preField[sy][sx]=sceneTemp.pen
		end
	end
	function keyDown.draw(key)
		local sx,sy,pen=sceneTemp.x,sceneTemp.y,sceneTemp.pen
		if key=="up"or key=="down"or key=="left"or key=="right"then
			if not sx then sx=1 end
			if not sy then sy=1 end
			if key=="up"and sy<20 then sy=sy+1
			elseif key=="down"and sy>1 then sy=sy-1
			elseif key=="left"and sx>1 then sx=sx-1
			elseif key=="right"and sx<10 then sx=sx+1
			end
			if kb.isDown("space")then
				preField[sy][sx]=pen
			end
		elseif key=="delete"then
			if sceneTemp.sure>20 then
				for y=1,20 do for x=1,10 do preField[y][x]=0 end end
				sceneTemp.sure=0
				SFX.play("finesseError",.7)
			else
				sceneTemp.sure=50
			end
		elseif key=="space"then
			if sx and sy then
				preField[sy][sx]=pen
			end
		elseif key=="e"then
			SCN.swapTo("custom","swipeL")
		elseif key=="escape"then
			SCN.back()
		elseif key=="k"then
			ins(preField,1,{14,14,14,14,14,14,14,14,14,14})
			preField[21]=nil
			SFX.play("blip")
		elseif key=="l"then
			local F=preField
			for i=20,1,-1 do
				for j=1,10 do
					if F[i][j]<=0 then goto L end
				end
				sysFX.newShade(.3,1,1,1,200,660-30*i,300,30)
				sysFX.newRectRipple(.3,200,660-30*i,300,30)
				rem(F,i)
				::L::
			end
			if #F~=20 then
				repeat
					F[#F+1]={0,0,0,0,0,0,0,0,0,0}
				until#F==20
				SFX.play("clear_4",.8)
				SFX.play("fall",.8)
			end
		elseif key=="c"and kb.isDown("lctrl","rctrl")or key=="cC"then
			sys.setClipboardText("Techmino Field:"..copyBoard())
			LOG.print(text.copySuccess,color.green)
		elseif key=="v"and kb.isDown("lctrl","rctrl")or key=="cV"then
			local str=sys.getClipboardText()
			local p=string.find(str,":")--ptr*
			if p then str=string.sub(str,p+1)end
			if not pasteBoard(str)then
				LOG.print(text.dataCorrupted,color.red)
			end
		else
			pen=penKey[key]or pen
		end
		sceneTemp.x,sceneTemp.y,sceneTemp.pen=sx,sy,pen
	end

	function Tmr.draw()
		if sceneTemp.sure>0 then sceneTemp.sure=sceneTemp.sure-1 end
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

		--Pen
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

		--Confirm reset
		if sceneTemp.sure>0 then
			gc.setColor(1,1,1,sceneTemp.sure*.02)
			gc.draw(drawableText.question,1180,290)
		end

		--Block name
		setFont(40)
		local _
		for i=1,7 do
			_=setting.skin[i]
			gc.setColor(SKIN.libColor[_])
			mStr(text.block[i],500+65*_,65)
		end
	end
end
do--play
	local function onVirtualkey(x,y)
		local dist,nearest=1e10
		for K=1,#virtualkey do
			local b=virtualkey[K]
			if b.ava then
				local d1=(x-b.x)^2+(y-b.y)^2
				if d1<b.r^2 then
					if d1<dist then
						nearest,dist=K,d1
					end
				end
			end
		end
		return nearest
	end

	function sceneInit.play()
		love.keyboard.setKeyRepeat(false)
		restartCount=0
		if needResetGameData then
			resetGameData()
			needResetGameData=nil
		end
		BG.set(modeEnv.bg)
	end

	function touchDown.play(id,x,y)
		if not setting.VKSwitch or game.replaying then return end

		local t=onVirtualkey(x,y)
		if t then
			players[1]:pressKey(t)
			if setting.VKSFX>0 then
				SFX.play("virtualKey",setting.VKSFX)
			end
			virtualkey[t].isDown=true
			virtualkey[t].pressTime=10
			if setting.VKTrack then
				local B=virtualkey[t]
				if setting.VKDodge then--Button collision (not accurate)
				for i=1,#virtualkey do
						local b=virtualkey[i]
						local d=B.r+b.r-((B.x-b.x)^2+(B.y-b.y)^2)^.5--Hit depth(Neg means distance)
						if d>0 then
							b.x=b.x+(b.x-B.x)*d*b.r*5e-4
							b.y=b.y+(b.y-B.y)*d*b.r*5e-4
						end
					end
				end
				local O=VK_org[t]
				local _FW,_CW=setting.VKTchW*.1,1-setting.VKCurW*.1
				local _OW=1-_FW-_CW

				--Auto follow: finger, current, origin (weight from setting)
				B.x,B.y=x*_FW+B.x*_CW+O.x*_OW,y*_FW+B.y*_CW+O.y*_OW
			end
			VIB(setting.VKVIB)
		end
	end
	function touchUp.play(id,x,y)
		if not setting.VKSwitch or game.replaying then return end

		local t=onVirtualkey(x,y)
		if t then
			players[1]:releaseKey(t)
		end
	end
	function touchMove.play(id,x,y,dx,dy)
		if not setting.VKSwitch or game.replaying then return end

		local l=tc.getTouches()
		for n=1,#virtualkey do
			local B=virtualkey[n]
			for i=1,#l do
				local x,y=xOy:inverseTransformPoint(tc.getPosition(l[i]))
				if(x-B.x)^2+(y-B.y)^2<=B.r^2 then
					goto next
				end
			end
			players[1]:releaseKey(n)
			::next::
		end
	end
	function keyDown.play(key)
		if key=="escape"then
			pauseGame()
			return
		end
		if game.replaying then return end
		local m=keyMap
		for k=1,20 do
			if key==m[1][k]or key==m[2][k]then
				players[1]:pressKey(k)
				virtualkey[k].isDown=true
				virtualkey[k].pressTime=10
				return
			end
		end
	end
	function keyUp.play(key)
		if game.replaying then return end
		local m=keyMap
		for k=1,20 do
			if key==m[1][k]or key==m[2][k]then
				players[1]:releaseKey(k)
				virtualkey[k].isDown=false
				return
			end
		end
	end
	function gamepadDown.play(key)
		if key=="back"then SCN.back()return end
		if game.replaying then return end

		local m=keyMap
		for k=1,20 do
			if key==m[3][k]or key==m[4][k]then
				players[1]:pressKey(k)
				virtualkey[k].isDown=true
				virtualkey[k].pressTime=10
				return
			end
		end
	end
	function gamepadUp.play(key)
		if game.replaying then return end

		local m=keyMap
		for k=1,20 do
			if key==m[3][k]or key==m[4][k]then
				players[1]:releaseKey(k)
				virtualkey[k].isDown=false
				return
			end
		end
	end

	function Tmr.play(dt)
		local _
		game.frame=game.frame+1
		stat.time=stat.time+dt

		--Update virtualkey animation
		if setting.VKSwitch then
			for i=1,#virtualkey do
				_=virtualkey[i]
				if _.pressTime>0 then
					_.pressTime=_.pressTime-1
				end
			end
		end

		local P1=players[1]

		--Replay
		if game.replaying then
			_=game.replaying
			local L=game.rec
			while game.frame==L[_]do
				local k=L[_+1]
				if k>0 then
					P1:pressKey(k)
					virtualkey[k].isDown=true
					virtualkey[k].pressTime=10
				else
					virtualkey[-k].isDown=false
					P1:releaseKey(-k)
				end
				_=_+2
			end
			game.replaying=_
		end
		--Counting,include pre-das,directy RETURN,or restart counting
		if game.frame<180 then
			if game.frame==179 then
				gameStart()
			elseif game.frame==60 or game.frame==120 then
				SFX.play("ready")
			end
			for p=1,#players do
				local P=players[p]
				if P.movDir~=0 then
					if P.moving<P.gameEnv.das then
						P.moving=P.moving+1
					end
				else
					P.moving=0
				end
			end
			if restartCount>0 then restartCount=restartCount-1 end
			return
		elseif P1.keyPressing[10]then
			restartCount=restartCount+1
			if restartCount>20 then
				TASK.clear("play")
				resetPartGameData()
				return
			end
		elseif restartCount>0 then
			restartCount=restartCount>2 and restartCount-2 or 0
		end

		--Update players
		for p=1,#players do
			local P=players[p]
			P:update(dt)
		end

		--Fresh royale target
		if game.frame%120==0 then
			if modeEnv.royaleMode then freshMostDangerous()end
		end

		--Warning check
		if P1.alive then
			if game.frame%26==0 and setting.warn then
				local F=P1.field
				local height=0--Max height of row 4~7
				for x=4,7 do
					for y=#F,1,-1 do
						if F[y][x]>0 then
							if y>height then
								height=y
							end
							break
						end
					end
				end
				game.warnLVL0=log(height-15+P1.atkBuffer.sum*.8)
			end
			_=game.warnLVL
			if _<game.warnLVL0 then
				_=_*.95+game.warnLVL0*.05
			elseif _>0 then
				_=max(_-.026,0)
			end
			game.warnLVL=_
		elseif game.warnLVL>0 then
			game.warnLVL=max(game.warnLVL-.026,0)
		end
	end

	local function drawAtkPointer(x,y)
		local t=sin(Timer()*20)
		gc.setColor(.2,.7+t*.2,1,.6+t*.4)
		gc.circle("fill",x,y,25,6)
		local a=Timer()*3%1*.8
		gc.setColor(0,.6,1,.8-a)
		gc.circle("line",x,y,30*(1+a),6)
	end
	local function drawVirtualkey()
		local V=virtualkey
		local a=setting.VKAlpha
		local _
		if setting.VKIcon then
			local icons=TEXTURE.VKIcon
			for i=1,#V do
				if V[i].ava then
					local B=V[i]
					gc.setColor(1,1,1,a)
					gc.setLineWidth(B.r*.07)
					gc.circle("line",B.x,B.y,B.r,10)--Button outline
					_=V[i].pressTime
					gc.draw(icons[i],B.x,B.y,nil,B.r*.026+_*.08,nil,18,18)--Icon
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
	function Pnt.play()
		if marking then
			setFont(26)
			local t=Timer()
			gc.setColor(1,1,1,.2+.1*(sin(3*t)+sin(2.6*t)))
			mStr(text.marking,190,60+26*sin(t))
		end
		for p=1,#players do
			players[p]:draw()
		end

		gc.setColor(1,1,1)
		if setting.VKSwitch then drawVirtualkey()end

		if modeEnv.royaleMode then
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

		--Mode info
		gc.setColor(1,1,1,.8)
		gc.draw(drawableText.modeName,485,10)
		gc.draw(drawableText.levelName,511+drawableText.modeName:getWidth(),10)

		--Replaying
		if game.replaying then
			gc.setColor(1,1,Timer()%1>.5 and 1 or 0)
			mText(drawableText.replaying,410,17)
		end

		--Warning
		gc.push("transform")
		gc.origin()
		if game.warnLVL>0 then
			gc.setColor(0,0,0,0)
			SHADER.warning:send("level",game.warnLVL)
			gc.setShader(SHADER.warning)
			gc.rectangle("fill",0,0,scr.w,scr.h)
			gc.setShader()
		end
		if restartCount>0 then
			gc.setColor(0,0,0,restartCount*.05)
			gc.rectangle("fill",0,0,scr.w,scr.h)
		end
		gc.pop()
	end
end
do--pause
	function sceneInit.pause(org)
		if
			org=="setting_game"or
			org=="setting_video"or
			org=="setting_sound"
		then
			TEXT.show(text.needRestart,640,440,50,"fly",.6)
		end
		local S=players[1].stat
		sceneTemp={
			timer=org=="play"and 0 or 50,
			list={
				toTime(S.time),
				format("%d/%d/%d",S.key,S.rotate,S.hold),
				format("%d  %.2fPPS",S.piece,S.piece/S.time),
				format("%d(%d)  %.2fLPM",S.row,S.dig,S.row/S.time*60),
				format("%d(%d)  %.2fAPM",S.atk,S.digatk,S.atk/S.time*60),
				format("%d(%d-%d)",S.pend,S.recv,S.recv-S.pend),
				format("%d/%d/%d/%d",S.clears[1],S.clears[2],S.clears[3],S.clears[4]),
				format("(%d)/%d/%d/%d",S.spins[1],S.spins[2],S.spins[3],S.spins[4]),
				format("%d/%d ; %d/%d",S.b2b,S.b3b,S.pc,S.hpc),
				format("%d [%.2f%%]",S.extraPiece,100*max(1-S.extraRate/S.piece,0)),
			},

			--From right-down, 60 degree each
			radar={
				(S.off+S.dig)/S.time*60,--DefPM
				(S.send+S.dig)/S.time*60,--ADPM
				S.atk/S.time*60,		--AtkPM
				S.send/S.time*60,		--SendPM
				S.piece/S.time*24,		--LinePM
				S.dig/S.time*60,		--DigPM
			},
			val={1/80,1/80,1/80,1/60,1/100,1/40},
			timing=org=="play",
		}
		local _=sceneTemp
		local A,B=_.radar,_.val

		--Normalize Values
		for i=1,6 do
			B[i]=B[i]*A[i]if B[i]>1.26 then B[i]=1.26+log(B[i]-.26,10)end
		end

		for i=1,6 do
			A[i]=format("%.2f",A[i])..text.radarData[i]
		end
		local f=1
		for i=1,6 do
			if B[i]>.5 then f=2 end
			if B[i]>1 then f=3 break end
		end
		if f==1 then	 _.color,f={.4,.9,.5},1.25	--Vegetable
		elseif f==2 then _.color,f={.4,.7,.9},1		--Normal
		elseif f==3 then _.color,f={1,.3,.3},.626	--Diao
		end
		A={
			120*.5*f,	120*3^.5*.5*f,
			120*-.5*f,	120*3^.5*.5*f,
			120*-1*f,	120*0*f,
			120*-.5*f,	120*-3^.5*.5*f,
			120*.5*f,	120*-3^.5*.5*f,
			120*1*f,	120*0*f,
		}
		_.scale=f
		_.standard=A

		for i=6,1,-1 do
			B[2*i-1],B[2*i]=B[i]*A[2*i-1],B[i]*A[2*i]
		end
		_.val=B
	end
	function sceneBack.pause()
		love.keyboard.setKeyRepeat(true)
		if not game.replaying then
			mergeStat(stat,players[1].stat)
		end
		FILE.saveData()
		TASK.clear("play")
	end

	function keyDown.pause(key)
		if key=="q"then
			SCN.back()
		elseif key=="escape"then
			resumeGame()
		elseif key=="s"then
			SCN.go("setting_sound")
		elseif key=="r"then
			TASK.clear("play")
			resetGameData()
			SCN.swapTo("play","none")
		elseif key=="p"and(game.result or game.replaying)then
			TASK.removeTask_code(TICK.autoPause)
			resetPartGameData(true)
			SCN.swapTo("play","none")
		end
	end

	function Tmr.pause(dt)
		if not game.result then
			game.pauseTime=game.pauseTime+dt
		end
		if sceneTemp.timer<50 then
			sceneTemp.timer=sceneTemp.timer+1
		end
	end

	local hexList={1,0,.5,1.732*.5,-.5,1.732*.5}
	for i=1,6 do hexList[i]=hexList[i]*150 end
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
		gc.draw(_,40,170)
		gc.draw(drawableText.levelName,60+_:getWidth(),170)

		--Result Text
		setFont(35)
		mText(game.result and drawableText[game.result]or drawableText.pause,640,50-10*(5-sceneTemp.timer*.1)^1.5)

		--Infos
		if game.frame>180 then
			_=S.list
			setFont(26)
			for i=1,10 do
				gc.print(text.pauseStat[i],40,210+40*i)
				gc.printf(_[i],195,210+40*i,300,"right")
			end
		end

		--Radar Chart
		if T>.5 and game.frame>180 then
			T=T*2-1
			gc.setLineWidth(2)
			gc.push("transform")
				gc.translate(1026,400)

				--Polygon
				gc.push("transform")
					gc.scale((3-2*T)*T)
					gc.setColor(1,1,1,T*(.5+.3*sin(Timer()*6.26)))gc.polygon("line",S.standard)
					_=S.color
					gc.setColor(_[1],_[2],_[3],T*.626)
					_=S.val
					for i=1,9,2 do
						gc.polygon("fill",0,0,_[i],_[i+1],_[i+2],_[i+3])
					end
					gc.polygon("fill",0,0,_[11],_[12],_[1],_[2])
					gc.setColor(1,1,1,T)gc.polygon("line",S.val)
				gc.pop()

				--Axes
				gc.setColor(1,1,1,T)
				for i=1,3 do
					local x,y=hexList[2*i-1],hexList[2*i]
					gc.line(-x,-y,x,y)
				end

				--Texts
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
			gc.pop()
		end
	end
end
do--setting_game
	function sceneInit.setting_game()
		BG.set("space")
	end
	function sceneBack.setting_game()
		FILE.saveSetting()
	end

	function Pnt.setting_game()
		gc.setColor(1,1,1)
		mText(drawableText.setting_game,640,15)
		gc.draw(blockSkin[int(Timer()*2)%11+1],590,540,Timer()%6.28319,2,nil,15,15)
	end
end
do--setting_video
	function sceneInit.setting_video()
		BG.set("space")
	end
	function sceneBack.setting_video()
		FILE.saveSetting()
	end

	function Pnt.setting_video()
		gc.setColor(1,1,1)
		mText(drawableText.setting_video,640,15)
	end
end
do--setting_sound
	function sceneInit.setting_sound()
		sceneTemp={
			last=0,--Last sound time
			jump=0,--Animation timer(10 to 0)
		}
		BG.set("space")
	end
	function sceneBack.setting_sound()
		FILE.saveSetting()
	end

	function mouseDown.setting_sound(x,y,k)
		local s=sceneTemp
		if x>780 and x<980 and y>470 and s.jump==0 then
			s.jump=10
			local t=Timer()-s.last
			if t>1 then
				VOC.play((t<1.5 or t>15)and"doubt"or rnd()<.8 and"happy"or"egg")
				s.last=Timer()
			end
		end
	end
	function touchDown.setting_sound(id,x,y)
		mouseDown.setting_sound(x,y)
	end

	function Tmr.setting_sound()
		local t=sceneTemp.jump
		if t>0 then
			sceneTemp.jump=t-1
		end
	end

	function Pnt.setting_sound()
		gc.setColor(1,1,1)
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
end
do--setting_control
	function sceneInit.setting_control()
		sceneTemp={
			das=setting.das,
			arr=setting.arr,
			pos=0,
			dir=1,
			wait=30,
		}
		BG.set("bg1")
	end

	function Tmr.setting_control()
		local T=sceneTemp
		if T.wait>0 then
			T.wait=T.wait-1
			if T.wait==0 then
				T.pos=T.pos+T.dir
			else
				return
			end
		end
		if T.das>0 then
			T.das=T.das-1
			if T.das==0 then
				if T.arr==0 then
					T.pos=T.pos+7*T.dir
					T.das=setting.das+1
					T.arr=setting.arr
					T.dir=-T.dir
					T.wait=26
				else
					T.pos=T.pos+T.dir
				end
			end
		else
			T.arr=T.arr-1
			if T.arr==0 then
				T.pos=T.pos+T.dir
				T.arr=setting.arr
			elseif T.arr==-1 then
				T.pos=T.dir>0 and 8 or 0
				T.arr=setting.arr
			end
			if T.pos%8==0 then
				T.dir=-T.dir
				T.wait=26
				T.das=setting.das
			end
		end
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
		gc.setColor(.7,.7,.7)gc.draw(drawableText.setting_control,80,50)
		gc.setColor(1,1,1)gc.draw(drawableText.setting_control,80,50)
		setFont(50)
		gc.printf(text.preview,320,540,200,"right")

		--Testing O mino
		_=blockSkin[setting.skin[6]]
		local x=550+40*sceneTemp.pos
		gc.draw(_,x,540,nil,40/30)
		gc.draw(_,x,580,nil,40/30)
		gc.draw(_,x+40,540,nil,40/30)
		gc.draw(_,x+40,580,nil,40/30)
	end
end
do--setting_key
	function sceneInit.setting_key()
		sceneTemp={
			board=1,
			kb=1,js=1,
			kS=false,jS=false,
		}
	end
	function sceneBack.setting_key()
		FILE.saveKeyMap()
	end

	function keyDown.setting_key(key)
		local s=sceneTemp
		if key=="escape"then
			if s.kS then
				s.kS=false
				SFX.play("finesseError",.5)
			else
				SCN.back()
			end
		elseif s.kS then
			for y=1,20 do
				if keyMap[1][y]==key then keyMap[1][y]=""break end
				if keyMap[2][y]==key then keyMap[2][y]=""break end
			end
			keyMap[s.board][s.kb]=key
			SFX.play("reach",.5)
			s.kS=false
		elseif key=="return"or key=="space"then
			s.kS=true
			SFX.play("lock",.5)
		elseif key=="up"or key=="w"then
			if s.kb>1 then
				s.kb=s.kb-1
				SFX.play("move",.5)
			end
		elseif key=="down"or key=="s"then
			if s.kb<20 then
				s.kb=s.kb+1
				SFX.play("move",.5)
			end
		elseif key=="left"or key=="a"or key=="right"or key=="d"then
			s.board=3-s.board
			SFX.play("rotate",.5)
		end
	end
	function gamepadDown.setting_key(key)
		local s=sceneTemp
		if key=="back"then
			if s.jS then
				s.jS=false
				SFX.play("finesseError",.5)
			else
				SCN.back()
			end
		elseif s.jS then
			for y=1,20 do
				if keyMap[3][y]==key then keyMap[3][y]=""break end
				if keyMap[4][y]==key then keyMap[4][y]=""break end
			end
			keyMap[2+s.board][s.js]=key
			SFX.play("reach",.5)
			s.jS=false
		elseif key=="start"then
			s.jS=true
			SFX.play("lock",.5)
		elseif key=="dpup"then
			if s.js>1 then
				s.js=s.js-1
				SFX.play("move",.5)
			end
		elseif key=="dpdown"then
			if s.js<20 then
				s.js=s.js+1
				SFX.play("move",.5)
			end
		elseif key=="dpleft"or key=="dpright"then
			s.board=3-s.board
			SFX.play("rotate",.5)
		end
	end

	function Pnt.setting_key()
		local S=sceneTemp
		local a=.3+sin(Timer()*15)*.1
		if S.kS then gc.setColor(1,.3,.3,a)else gc.setColor(1,.7,.7,a)end
		gc.rectangle("fill",
			S.kb<11 and 240 or 840,
			45*S.kb+20-450*int(S.kb/11),
			200,45
		)
		if S.jS then gc.setColor(.3,.3,.1,a)else gc.setColor(.7,.7,1,a)end
		gc.rectangle("fill",
			S.js<11 and 440 or 1040,
			45*S.js+20-450*int(S.js/11),
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
		local b1,b2=keyMap[S.board],keyMap[S.board+2]
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
		gc.print(text.page..S.board,280,590)
		gc.draw(drawableText.ctrlSetHelp,50,650)
	end
end
do--setting_skin
	local scs=require("parts/spinCenters")
	function Pnt.setting_skin()
		gc.setColor(.7,.7,.7)gc.draw(drawableText.setting_skin,80,50)
		gc.setColor(1,1,1)gc.draw(drawableText.setting_skin,80,50)
		for N=1,7 do
			local face=setting.face[N]
			local B=blocks[N][face]
			local x,y=-55+140*N-scs[N][face][2]*30,355+scs[N][face][1]*30
			local col=#B[1]
			for i=1,#B do for j=1,col do
				if B[i][j]then
					gc.draw(blockSkin[setting.skin[N]],x+30*j,y-30*i)
				end
			end end
			gc.circle("fill",-10+140*N,340,sin(Timer()*10)+5)
		end
		for i=1,6 do
			gc.draw(blockSkin[11+i],570+60*i,610,nil,2)
		end
	end
end
do--setting_touch

	function sceneInit.setting_touch()
		BG.set("rainbow")
		sceneTemp={
			default=1,
			snap=1,
			sel=nil,
		}
	end
	function sceneBack.setting_touch()
		FILE.saveVK()
	end

	local function onVK_org(x,y)
		local dist,nearest=1e10
		for K=1,#VK_org do
			local b=VK_org[K]
			if b.ava then
				local d1=(x-b.x)^2+(y-b.y)^2
				if d1<b.r^2 then
					if d1<dist then
						nearest,dist=K,d1
					end
				end
			end
		end
		return nearest
	end
	function mouseDown.setting_touch(x,y,k)
		if k==2 then SCN.back()end
		sceneTemp.sel=onVK_org(x,y)or sceneTemp.sel
	end
	function mouseMove.setting_touch(x,y,dx,dy)
		if sceneTemp.sel and ms.isDown(1)and not WIDGET.sel then
			local B=VK_org[sceneTemp.sel]
			B.x,B.y=B.x+dx,B.y+dy
		end
	end
	function mouseUp.setting_touch(x,y,k)
		if sceneTemp.sel then
			local B=VK_org[sceneTemp.sel]
			local k=snapLevelValue[sceneTemp.snap]
			B.x,B.y=int(B.x/k+.5)*k,int(B.y/k+.5)*k
		end
	end
	function touchDown.setting_touch(id,x,y)
		sceneTemp.sel=onVK_org(x,y)or sceneTemp.sel
	end
	function touchUp.setting_touch(id,x,y)
		if sceneTemp.sel then
			local B=VK_org[sceneTemp.sel]
			local k=snapLevelValue[sceneTemp.snap]
			B.x,B.y=int(B.x/k+.5)*k,int(B.y/k+.5)*k
		end
	end
	function touchMove.setting_touch(id,x,y,dx,dy)
		if sceneTemp.sel and not WIDGET.sel then
			local B=VK_org[sceneTemp.sel]
			B.x,B.y=B.x+dx,B.y+dy
		end
	end

	local function VirtualkeyPreview()
		if setting.VKSwitch then
			for i=1,#VK_org do
				local B=VK_org[i]
				if B.ava then
					local c=sceneTemp.sel==i and .6 or 1
					gc.setColor(c,1,c,setting.VKAlpha)
					gc.setLineWidth(B.r*.07)
					gc.circle("line",B.x,B.y,B.r,10)
					if setting.VKIcon then gc.draw(TEXTURE.VKIcon[i],B.x,B.y,nil,B.r*.025,nil,18,18)end
				end
			end
		end
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
end
do--setting_trackSetting
	function Pnt.setting_trackSetting()
		gc.setColor(1,1,1)
		mText(drawableText.VKTchW,140+50*setting.VKTchW,260)
		mText(drawableText.VKOrgW,140+50*setting.VKTchW+50*setting.VKCurW,320)
		mText(drawableText.VKCurW,640+50*setting.VKCurW,380)
	end
end
do--setting_touchSwitch
	function sceneInit.setting_touchSwitch()
		BG.set("matrix")
	end
end
do--setting_lang
	function sceneBack.setting_lang()
		FILE.saveSetting()
	end
end
do--help
	function sceneInit.help()
		BG.set("space")
	end

	function Pnt.help()
		setFont(20)
		gc.setColor(1,1,1)
		for i=1,#text.help do
			gc.printf(text.help[i],150,35*i+40,1000,"center")
		end
		setFont(19)
		gc.print(text.used,30,330)
		gc.draw(IMG.title,280,610,.1,1+.05*sin(Timer()*2.6),nil,206,35)
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
end
do--staff
	function sceneInit.staff()
		sceneTemp={
			time=0,
			v=1,
		}
		BG.set("space")
	end

	function Tmr.staff(dt)
		local S=sceneTemp
		if kb.isDown("space","return")and S.v<6.26 then
			S.v=S.v+.26
		elseif S.v>1 then
			S.v=S.v-.26
		end
		S.time=S.time+S.v*dt
		if S.time>45 then
			S.time=45
		end
	end

	function Pnt.staff()
		local L=text.staff
		local t=sceneTemp.time
		setFont(40)
		for i=1,#L do
			mStr(L[i],640,800+80*i-t*40)
		end
		mDraw(IMG.title_color,640,800-t*40,nil,2)
		mDraw(IMG.title_color,640,2160-t*40,nil,2)
	end
end
do--stat
	function sceneInit.stat()
		local S=stat
		local X1,X2,Y1,Y2={0,0,0,0},{0,0,0,0},{},{}
		for i=1,7 do
			local S,C=S.spin[i],S.clear[i]
			Y1[i]=S[1]+S[2]+S[3]+S[4]
			Y2[i]=C[1]+C[2]+C[3]+C[4]
			for j=1,4 do
				X1[j]=X1[j]+S[j]
				X2[j]=X2[j]+C[j]
			end
		end
		sceneTemp={
			chart={
				A1=S.spin,A2=S.clear,
				X1=X1,X2=X2,
				Y1=Y1,Y2=Y2,
			},
			item={
				S.run,
				S.game,
				toTime(S.time),
				S.key.."  "..S.rotate.."  "..S.hold,
				S.piece.."  "..S.row.."  "..int(S.atk),
				S.recv.."  "..S.off.."  "..S.pend,
				S.dig.."  "..int(S.digatk),
				format("%.2f  %.2f",S.atk/S.row,S.digatk/S.dig),
				format("%d/%.3f%%",S.extraPiece,100*max(1-S.extraRate/S.piece,0)),
				S.b2b.."  "..S.b3b,
				S.pc.."  "..S.hpc,
			},
		}
		for i=1,11 do
			sceneTemp.item[i]=text.stat[i].."\t"..sceneTemp.item[i]
		end
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

		gc.draw(IMG.title,260,615,.2+.04*sin(Timer()*3),nil,nil,206,35)
	end
end
do--history
	function sceneInit.history()
		BG.set("rainbow")
		sceneTemp={
			text=require("parts/updateLog"),--Text list
			pos=1,--Scroll pos
		}
		if newVersionLaunch then
			newVersionLaunch=nil
			sceneTemp.pos=4
		end
	end

	function wheelMoved.history(x,y)
		wheelScroll(y)
	end
	function keyDown.history(key)
		if key=="up"then
			sceneTemp.pos=max(sceneTemp.pos-1,1)
		elseif key=="down"then
			sceneTemp.pos=min(sceneTemp.pos+1,#sceneTemp.text)
		elseif key=="escape"then
			SCN.back()
		end
	end

	function Pnt.history()
		gc.setColor(.2,.2,.2,.7)
		gc.rectangle("fill",30,45,1000,632)
		gc.setColor(1,1,1)
		gc.setLineWidth(4)
		gc.rectangle("line",30,45,1000,632)
		setFont(20)
		local S=sceneTemp
		gc.print(S.text[S.pos],40,50)
	end
end
do--debug
	function sceneInit.debug()
		sceneTemp={
			reset=false,
		}
	end
end
do--quit
	function sceneInit.quit()
		if rnd()>.000626 then
			love.timer.sleep(.3)
			love.event.quit()
		else
			error("So lucky! 0.0626 precent to get this!!!   You can quit the game now.")
		end
	end
end