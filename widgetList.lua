local mobile=system=="Android"or system=="iOS"
local langName={"中文","全中文","English"}
local virtualkeySet={
	{
		{1,	80,			720-200,	80},--moveLeft
		{2,	320,		720-200,	80},--moveRight
		{3,	1280-80,	720-200,	80},--rotRight
		{4,	1280-200,	720-80,		80},--rotLeft
		{5,	1280-200,	720-320,	80},--rot180
		{6,	200,		720-320,	80},--hardDrop
		{7,	200,		720-80,		80},--softDrop
		{8,	1280-320,	720-200,	80},--hold
		{9,	1280-80,	280,		80},--func
		{10,80,			280,		80},--restart
	},--Farter's set,thanks
	{
		{1,	1280-320,	720-200,	80},--moveLeft
		{2,	1280-80,	720-200,	80},--moveRight
		{3,	200,		720-80,		80},--rotRight
		{4,	80,			720-200,	80},--rotLeft
		{5,	200,		720-320,	80},--rot180
		{6,	1280-200,	720-320,	80},--hardDrop
		{7,	1280-200,	720-80,		80},--softDrop
		{8,	320,		720-200,	80},--hold
		{9,	80,			280,		80},--func
		{10,1280-80,	280,		80},--restart
	},--Mirrored farter's set,sknaht
	{
		{1,	80,			720-80,		80},--moveLeft
		{2,	240,		720-80,		80},--moveRight
		{3,	1280-240,	720-80,		80},--rotRight
		{4,	1280-400,	720-80,		80},--rotLeft
		{5,	1280-240,	720-240,	80},--rot180
		{6,	1280-80,	720-80,		80},--hardDrop
		{7,	1280-80,	720-240,	80},--softDrop
		{8,	1280-80,	720-400,	80},--hold
		{9,	80,			360,		80},--func
		{10,80,			80,			80},--restart
	},--Author's set,not recommend
	{
		{1,	1280-400,	720-80,		80},--moveLeft
		{2,	1280-80,	720-80,		80},--moveRight
		{3,	240,		720-80,		80},--rotRight
		{4,	80,			720-80,		80},--rotLeft
		{5,	240,		720-240,	80},--rot180
		{6,	1280-240,	720-240,	80},--hardDrop
		{7,	1280-240,	720-80,		80},--softDrop
		{8,	1280-80,	720-240,	80},--hold
		{9,	80,			720-240,	80},--func
		{10,80,			320,		80},--restart
	},--Keyboard set
	{
		{10,70,		50,30},--restart
		{9,	130,	50,30},--func
		{4,	190,	50,30},--rotLeft
		{3,	250,	50,30},--rotRight
		{5,	310,	50,30},--rot180
		{1,	370,	50,30},--moveLeft
		{2,	430,	50,30},--moveRight
		{8,	490,	50,30},--hold
		{7,	550,	50,30},--softDrop1
		{6,	610,	50,30},--hardDrop
		{11,670,	50,30},--insLeft
		{12,730,	50,30},--insRight
		{13,790,	50,30},--insDown
		{14,850,	50,30},--down1
		{15,910,	50,30},--down4
		{16,970,	50,30},--down10
		{17,1030,	50,30},--dropLeft
		{18,1090,	50,30},--dropRight
		{19,1150,	50,30},--addLeft
		{20,1210,	50,30},--addRight
	},--PC key feedback(top&in a row)
}
local customSet={
	{3,20,1,1,7,1,1,1,3,4,1,2,3},
	{5,20,1,1,7,1,1,1,8,3,8,3,3},
	{1,22,1,1,7,3,1,1,8,4,1,7,7},
	{3,20,1,1,7,1,1,3,8,3,1,7,8},
	{25,11,8,11,4,1,2,1,8,3,1,4,9},
}
--λFuncs for widgets,delete at file end
function defSet(n)
	return function()
		for i=1,#customSet[n]do
			customSel[i]=customSet[n][i]
		end
		BG.set(customRange.bg[customSel[12]])
		BGM.play(customRange.bgm[customSel[13]])
	end
end
function SETval(k)	return function()return setting[k]					end end
function SETsto(k)	return function(i)setting[k]=i						end end
function SETrev(k)	return function()setting[k]=not setting[k]			end end
function pressKey(k)return function()love.keypressed(k)					end end
function setPen(i)	return function()sceneTemp.pen=i					end end
function prevSkin(n)return function()skin.prev(n)						end end
function nextSkin(n)return function()skin.next(n)						end end
function nextDir(n)	return function()skin.rotate(n)						end end
function VKAdisp(n)	return function()return VK_org[n].ava				end end
function VKAcode(n)	return function()VK_org[n].ava=not VK_org[n].ava 	end end

local C=color
local Widget={
	load={},intro={},quit={},
	main={
		play=	newButton(150,280,200,160,C.lightRed,		55,function()SCN.push()SCN.swapTo("mode")end,			nil,"setting"),
		setting=newButton(370,280,200,160,C.lightBlue,		45,function()SCN.push()SCN.swapTo("setting_game")end,	nil,"music"),
		music=	newButton(590,280,200,160,C.lightPurple,	32,function()SCN.push()SCN.swapTo("music")end,			nil,"help"),
		help=	newButton(150,460,200,160,C.lightYellow,	50,function()SCN.push()SCN.swapTo("help")end,			nil,"stat"),
		stat=	newButton(370,460,200,160,C.lightCyan,		43,function()SCN.push()SCN.swapTo("stat")end,			nil,"qplay"),
		qplay=	newButton(590,460,200,160,C.lightOrange,	43,function()SCN.push()loadGame(stat.lastPlay)end,		nil,"lang"),
		lang=	newButton(150,610,160,100,C.lightGreen,		45,function()
			setting.lang=setting.lang%#langName+1
			changeLanguage(setting.lang)
			TEXT.show(text.lang,370,610,50,"appear",1.6)
			end,nil,"quit"),
		quit=	newButton(590,610,160,100,C.lightGrey,		45,function()VOC.play("bye")SCN.swapTo("quit","slowFade")end,nil,"play"),
	},
	mode={
		draw=	newButton(1100,	440,220,90,C.lightYellow,	40,function()SCN.push()SCN.swapTo("draw")end,function()return mapCam.sel~=71 and mapCam.sel~=72 end),
		custom=newButton(1100,	540,220,90,C.lightGreen,	40,function()SCN.push()SCN.swapTo("custom")end,function()return mapCam.sel~=71 and mapCam.sel~=72 end),
		start=	newButton(1040,	655,180,80,C.lightGrey,		40,function()if mapCam.sel then SCN.push()loadGame(mapCam.sel)end end,function()return not mapCam.sel end),
		back=	newButton(1200,	655,120,80,C.white,			40,SCN.back),
		--function()SCN.push()SCN.swapTo("custom")end
	},
	music={
		bgm=	newSlider(760,	80,400,10,35,function()BGM.freshVolume()end,SETval("bgm"),SETsto("bgm")),
		up=		newButton(1100,	200,120,120,C.white,55,pressKey("up")),
		play=	newButton(1100,	340,120,120,C.white,35,pressKey("space"),function()return setting.bgm==0 end),
		down=	newButton(1100,	480,120,120,C.white,55,pressKey("down")),
		back=	newButton(640,	630,230,90,	C.white,40,SCN.back),
	},
	custom={
		up=		newButton(1000,	360,100,100,C.white,		45,function()sceneTemp=(sceneTemp-2)%#customID+1 end),
		down=	newButton(1000,	600,100,100,C.white,		45,function()sceneTemp=sceneTemp%#customID+1 end),
		left=	newButton(880,	480,100,100,C.white,		45,pressKey("left")),
		right=	newButton(1120,	480,100,100,C.white,		45,pressKey("right")),
		set1=	newButton(640,	160,240,75,	C.lightYellow,	35,defSet(1)),
		set2=	newButton(640,	250,240,75,	C.lightYellow,	35,defSet(2)),
		set3=	newButton(640,	340,240,75,	C.lightYellow,	35,defSet(3)),
		set4=	newButton(640,	430,240,75,	C.lightYellow,	35,defSet(4)),
		set5=	newButton(640,	520,240,75,	C.lightYellow,	35,defSet(5)),
		back=	newButton(640,	630,180,60,	C.white,		35,SCN.back),
	},
	draw={
		b1=		newButton(500+65*1,	150,58,58,C.red,		30,setPen(1)),--B1
		b2=		newButton(500+65*2,	150,58,58,C.orange,		30,setPen(2)),--B2
		b3=		newButton(500+65*3,	150,58,58,C.yellow,		30,setPen(3)),--B3
		b4=		newButton(500+65*4,	150,58,58,C.grass,		30,setPen(4)),--B4
		b5=		newButton(500+65*5,	150,58,58,C.green,		30,setPen(5)),--B5
		b6=		newButton(500+65*6,	150,58,58,C.water,		30,setPen(6)),--B6
		b7=		newButton(500+65*7,	150,58,58,C.cyan,		30,setPen(7)),--B7
		b8=		newButton(500+65*8,	150,58,58,C.blue,		30,setPen(8)),--B8
		b9=		newButton(500+65*9,	150,58,58,C.purple,		30,setPen(9)),--B9
		b10=	newButton(500+65*10,150,58,58,C.magenta,	30,setPen(10)),--B10
		b11=	newButton(500+65*11,150,58,58,C.pink,		30,setPen(11)),--B11

		b12=	newButton(500+65*1,	230,58,58,C.darkGrey,	30,setPen(12)),--Bone
		b13=	newButton(500+65*2,	230,58,58,C.grey,		30,setPen(13)),--GB1
		b14=	newButton(500+65*3,	230,58,58,C.lightGrey,	30,setPen(14)),--GB2
		b15=	newButton(500+65*4,	230,58,58,C.darkPurple,	30,setPen(15)),--GB3
		b16=	newButton(500+65*5,	230,58,58,C.darkRed,	30,setPen(16)),--GB4
		b17=	newButton(500+65*6,	230,58,58,C.darkGreen,	30,setPen(17)),--GB5

		any=	newButton(600,	360,120,120,C.lightGrey,	40,setPen(0)),
		space=	newButton(730,	360,120,120,C.grey,			65,setPen(-1)),
		clear=	newButton(1200,	500,120,120,C.white,		40,pressKey("delete")),
		demo=	newSwitch(755,	640,30,function()return sceneTemp.demo end,function()sceneTemp.demo=not sceneTemp.demo end),
		copy=	newButton(920,	640,120,120,C.lightRed,		35,copyBoard),
		paste=	newButton(1060,	640,120,120,C.lightBlue,	35,pasteBoard),
		back=	newButton(1200,	640,120,120,C.white,		35,SCN.back),
	},
	play={
		pause=	newButton(1235,45,80,80,C.white,25,pauseGame),
	},
	pause={
		resume=	newButton(640,290,240,100,C.white,30,resumeGame),
		restart=newButton(640,445,240,100,C.white,33,function()
			TASK.clear("play")
			mergeStat(stat,players[1].stat)
			resetGameData()
			SCN.swapTo("play","none")
			end),
		setting=newButton(1130,70,180,90,C.lightBlue,35,function()
			SCN.push()SCN.swapTo("setting_sound")
			end),
		quit=	newButton(640,600,240,100,C.white,35,SCN.back),
	},
	setting_game={
		graphic=newButton(200,80,240,80,C.lightCyan,35,function()SCN.swapTo("setting_graphic")end,				nil,"sound"),
		sound=	newButton(1080,80,240,80,C.lightCyan,35,function()SCN.swapTo("setting_sound")end,					nil,"ctrl"),
		ctrl=	newButton(290,220,320,80,C.lightYellow,35,function()SCN.push()SCN.swapTo("setting_control")end,	nil,"key"),
		key=	newButton(640,220,320,80,C.lightGreen,35,function()SCN.push()SCN.swapTo("setting_key")end,		nil,"touch"),
		touch=	newButton(990,220,320,80,C.lightBlue,35,function()SCN.push()SCN.swapTo("setting_touch")end,		nil,"reTime"),
		reTime=	newSlider(350,340,300,10,30,nil,	SETval("reTime"),		SETsto("reTime"),						nil,"maxNext"),
		maxNext=newSlider(350,440,300,6,30,nil,		SETval("maxNext"),		SETsto("maxNext"),						nil,"autoPause"),
		autoPause=newSwitch(350,540,20,				SETval("autoPause"),	SETrev("autoPause"),					nil,"layout"),
		layout=	newButton(590,540,140,70,C.white,35,function()
			SCN.push()
			SCN.swapTo("setting_skin")
			end,nil,"quickR"),
		quickR=	newSwitch(1050,340,35,				SETval("quickR"),		SETrev("quickR"),				nil,"swap"),
		swap=	newSwitch(1050,440,19,				SETval("swap"),			SETrev("swap"),					nil,"fine"),
		fine=	newSwitch(1050,540,20,				SETval("fine"),			SETrev("fine"),					nil,"back"),
		back=	newButton(1140,650,200,80,C.white,40,SCN.back,											nil,"graphic"),
	},
	setting_graphic={
		sound=	newButton(200,80,240,80,C.lightCyan,35,function()SCN.swapTo("setting_sound")end,	nil,"game"),
		game=	newButton(1080,80,240,80,C.lightCyan,35,function()SCN.swapTo("setting_game")end,	nil,"ghost"),
		ghost=	newSwitch(310,180,35,				SETval("ghost"),		SETrev("ghost"),		nil,"center"),
		center=	newSwitch(580,180,35,				SETval("center"),		SETrev("center"),		nil,"smooth"),
		smooth=	newSwitch(310,260,25,				SETval("smooth"),		SETrev("smooth"),			nil,"grid"),
		grid=	newSwitch(580,260,30,				SETval("grid"),			SETrev("grid"),			nil,"lockFX"),
		lockFX=	newSlider(310,340,373,3,35,nil,		SETval("lockFX"),		SETsto("lockFX"),		nil,"dropFX"),
		dropFX=	newSlider(310,410,373,5,35,nil,		SETval("dropFX"),		SETsto("dropFX"),		nil,"shakeFX"),
		shakeFX=newSlider(310,480,373,5,35,nil,		SETval("shakeFX"),		SETsto("shakeFX"),		nil,"atkFX"),
		atkFX=	newSlider(310,550,373,5,35,nil,		SETval("atkFX"),		SETsto("atkFX"),		nil,"frame"),
		frame=	newSlider(310,620,373,10,35,nil,function()return setting.frameMul>35 and setting.frameMul/10 or setting.frameMul/5-4 end,function(i)setting.frameMul=i<5 and 5*i+20 or 10*i end,nil,"text"),
		text=	newSwitch(990,180,35,SETval("text"),SETrev("text"),nil,"fullscreen"),
		fullscreen=newSwitch(990,260,35,SETval("fullscreen"),function()
			setting.fullscreen=not setting.fullscreen
			love.window.setFullscreen(setting.fullscreen)
			love.resize(love.graphics.getWidth(),love.graphics.getHeight())
			end,nil,"bg"),
		bg=		newSwitch(990,330,35,SETval("bg"),function()
			BG.set("none")
			setting.bg=not setting.bg
			BG.set("space")
		end,nil,"back"),
		back=	newButton(1140,650,200,80,C.white,40,SCN.back,nil,"sound"),
	},
	setting_sound={
		game=	newButton(200,80,240,80,C.lightCyan,35,function()SCN.swapTo("setting_game")end,						nil,"graphic"),
		graphic=newButton(1080,80,240,80,C.lightCyan,35,function()SCN.swapTo("setting_graphic")end,					nil,"sfx"),
		sfx=	newSlider(180,250,400,10,35,function()SFX.play("blip_1")end,	SETval("sfx"),		SETsto("sfx"),		nil,"bgm"),
		bgm=	newSlider(750,250,400,10,35,function()BGM.freshVolume()end,		SETval("bgm"),		SETsto("bgm"),		nil,"vib"),
		vib=	newSlider(180,440,400,5	,28,function()VIB(1)end,				SETval("vib"),		SETsto("vib"),		nil,"voc"),
		voc=	newSlider(750,440,400,10,32,function()VOC.play("nya")end,		SETval("voc"),		SETsto("voc"),		nil,"stereo"),
		stereo=	newSlider(180,630,400,10,35,function()SFX.play("move",1,-1)SFX.play("lock",1,1)end,	SETval("stereo"),	SETsto("stereo"),function()return setting.sfx==0 end,"back"),
		back=	newButton(1140,650,200,80,C.white,40,SCN.back,nil,"game"),
	},
	setting_control={
		das=	newSlider(226,200,910,	26,	30,nil,SETval("das"),	SETsto("das"),	nil,"arr"),
		arr=	newSlider(226,290,525,	15,	30,nil,SETval("arr"),	SETsto("arr"),	nil,"sddas"),
		sddas=	newSlider(226,380,350,	10,	30,nil,SETval("sddas"),	SETsto("sddas"),nil,"sdarr"),
		sdarr=	newSlider(226,470,140,	4,	30,nil,SETval("sdarr"),	SETsto("sdarr"),nil,"ihs"),
		ihs=	newSwitch(1100,290,30,	SETval("ihs"),	SETrev("ihs"),nil,"irs"),
		irs=	newSwitch(1100,380,30,	SETval("irs"),	SETrev("irs"),nil,"ihs"),
		ims=	newSwitch(1100,470,30,	SETval("ims"),	SETrev("ims"),nil,"reset"),
		reset=	newButton(160,580,200,	100,C.lightRed,40,function()
			local _=setting
			_.das,_.arr=10,2
			_.sddas,_.sdarr=0,2
			_.ihs,_.irs,_.ims=false,false,false
			end,nil,"back"),
		back=	newButton(1140,650,200,80,C.white,40,SCN.back,nil,"das"),
	},
	setting_key={
		back=newButton(1140,650,200,80,C.white,45,SCN.back),
	},
	setting_skin={
		prev=	newButton(700,100,140,100,C.white,50,function()skin.prevSet()end),
		next=	newButton(860,100,140,100,C.white,50,function()skin.nextSet()end),
		prev1=	newButton(130,230,90,65,C.white,30,prevSkin(1)),
		prev2=	newButton(270,230,90,65,C.white,30,prevSkin(2)),
		prev3=	newButton(410,230,90,65,C.white,30,prevSkin(3)),
		prev4=	newButton(550,230,90,65,C.white,30,prevSkin(4)),
		prev5=	newButton(690,230,90,65,C.white,30,prevSkin(5)),
		prev6=	newButton(830,230,90,65,C.white,30,prevSkin(6)),
		prev7=	newButton(970,230,90,65,C.white,30,prevSkin(7)),

		next1=	newButton(130,450,90,65,C.white,30,nextSkin(1)),
		next2=	newButton(270,450,90,65,C.white,30,nextSkin(2)),
		next3=	newButton(410,450,90,65,C.white,30,nextSkin(3)),
		next4=	newButton(550,450,90,65,C.white,30,nextSkin(4)),
		next5=	newButton(690,450,90,65,C.white,30,nextSkin(5)),
		next6=	newButton(830,450,90,65,C.white,30,nextSkin(6)),
		next7=	newButton(970,450,90,65,C.white,30,nextSkin(7)),

		spin1=	newButton(130,540,90,65,C.white,30,nextDir(1)),
		spin2=	newButton(270,540,90,65,C.white,30,nextDir(2)),
		spin3=	newButton(410,540,90,65,C.white,30,nextDir(3)),
		spin4=	newButton(550,540,90,65,C.white,30,nextDir(4)),
		spin5=	newButton(690,540,90,65,C.white,30,nextDir(5)),
		--spin6=newButton(825,540,90,65,C.white,30,nextDir(6)),--cannot rotate O
		spin7=	newButton(970,540,90,65,C.white,30,nextDir(7)),

		skinR=	newButton(200,640,220,80,C.lightPurple,35,function()setting.skin={1,5,2,8,10,3,7}SFX.play("rotate")end),
		faceR=	newButton(480,640,220,80,C.lightRed,35,function()setting.face={0,0,0,0,0,0,0}SFX.play("hold")end),
		back=	newButton(1140,650,200,80,C.white,40,SCN.back),
	},
	setting_touch={
		default=newButton(520,80,170,80,C.white,35,function()
			local D=virtualkeySet[sceneTemp.default]
			for i=1,#VK_org do
				VK_org[i].ava=false
			end
			for n=1,#D do
				local T=D[n]
				if T[1]then
					local B=VK_org[n]
					B.ava=true
					B.x,B.y,B.r=T[2],T[3],T[4]
				end
			end--Replace keys
			sceneTemp.default=sceneTemp.default%5+1
			sceneTemp.sel=nil
			end),
		snap=	newButton(760,80,170,80,C.white,35,function()
			sceneTemp.snap=sceneTemp.snap%6+1
			end),
		option=	newButton(520,180,170,80,C.white,40,function()
			SCN.push()
			SCN.swapTo("setting_touchSwitch")
			end),
		back=	newButton(760,180,170,80,C.white,40,SCN.back),
		size=	newSlider(450,265,460,14,40,nil,function()
			return VK_org[sceneTemp.sel].r/10-1
		end,
		function(v)
			if sceneTemp.sel then
				VK_org[sceneTemp.sel].r=10+v*10
			end
			end,
		function()return not sceneTemp.sel end),
	},
	setting_touchSwitch={
		b1=		newSwitch(280,80,	35,VKAdisp(1),VKAcode(1)),
		b2=		newSwitch(280,140,	35,VKAdisp(2),VKAcode(2)),
		b3=		newSwitch(280,200,	35,VKAdisp(3),VKAcode(3)),
		b4=		newSwitch(280,260,	35,VKAdisp(4),VKAcode(4)),
		b5=		newSwitch(280,320,	35,VKAdisp(5),VKAcode(5)),
		b6=		newSwitch(280,380,	35,VKAdisp(6),VKAcode(6)),
		b7=		newSwitch(280,440,	35,VKAdisp(7),VKAcode(7)),
		b8=		newSwitch(280,500,	35,VKAdisp(8),VKAcode(8)),
		b9=		newSwitch(280,560,	35,VKAdisp(9),VKAcode(9)),
		b10=	newSwitch(280,620,	35,VKAdisp(10),VKAcode(10)),
		b11=	newSwitch(620,80,	35,VKAdisp(11),VKAcode(11)),
		b12=	newSwitch(620,140,	35,VKAdisp(12),VKAcode(12)),
		b13=	newSwitch(620,200,	35,VKAdisp(13),VKAcode(13)),
		b14=	newSwitch(620,260,	35,VKAdisp(14),VKAcode(14)),
		b15=	newSwitch(620,320,	35,VKAdisp(15),VKAcode(15)),
		b16=	newSwitch(620,380,	35,VKAdisp(16),VKAcode(16)),
		b17=	newSwitch(620,440,	35,VKAdisp(17),VKAcode(17)),
		b18=	newSwitch(620,500,	35,VKAdisp(18),VKAcode(18)),
		b19=	newSwitch(620,560,	35,VKAdisp(19),VKAcode(19)),
		b20=	newSwitch(620,620,	35,VKAdisp(20),VKAcode(20)),
		norm=	newButton(840,100,240,80,C.white,45,function()for i=1,20 do VK_org[i].ava=i<11 end end),
		pro=	newButton(1120,100,240,80,C.white,35,function()for i=1,20 do VK_org[i].ava=true end end),
		hide=	newSwitch(1170,200,40,SETval("VKSwitch"),SETrev("VKSwitch")),
		track=	newSwitch(1170,300,35,SETval("VKTrack"),SETrev("VKTrack")),
		icon=	newSwitch(850,300,40,SETval("VKIcon"),SETrev("VKIcon")),
		tkset=	newButton(1120,400,240,80,C.white,32,function()
			SCN.push()
			SCN.swapTo("setting_trackSetting")
			end,function()return not setting.VKTrack end),
		alpha=	newSlider(840,490,400,10,40,nil,SETval("VKAlpha"),SETsto("VKAlpha")),
		back=	newButton(1100,600,240,80,C.white,45,SCN.back),
	},
	setting_trackSetting={
		VKDodge=newSwitch(400,200,	35,SETval("VKDodge"),SETrev("VKDodge")),
		VKTchW=	newSlider(140,310,1000,10,35,nil,SETval("VKTchW"),function(i)setting.VKTchW=i;setting.VKCurW=math.max(setting.VKCurW,i)end),
		VKCurW=	newSlider(140,370,1000,10,35,nil,SETval("VKCurW"),function(i)setting.VKCurW=i;setting.VKTchW=math.min(setting.VKTchW,i)end),
		back=	newButton(1080,600,240,80,C.white,45,SCN.back),
	},
	help={
		his=	newButton(1050,500,250,80,C.white,35,function()SCN.push()SCN.swapTo("history")end,nil,"back"),
		qq=		newButton(1050,600,250,80,C.white,35,function()love.system.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,function()return mobile end,"his"),
		back=	newButton(640,	600,200,80,C.white,40,SCN.back,nil,"qq"),
	},
	history={
		prev=	newButton(1155,170,180,180,C.white,65,pressKey("up"),function()return sceneTemp[2]==1 end),
		next=	newButton(1155,400,180,180,C.white,65,pressKey("down"),function()return sceneTemp[2]==#sceneTemp[1]-22 end),
		back=	newButton(1155,600,180,90,C.white,40,SCN.back),
	},
	stat={
		path=	newButton(980,620,250,80,C.white,25,function()love.system.openURL(love.filesystem.getSaveDirectory())end,function()return mobile end,"back"),
		back=	newButton(640,620,200,80,C.white,40,SCN.back,nil,"path"),
	},
}
defSet,SETval,SETsto,SETrev,pressKey,setPen,prevSkin,nextSkin,nextDir,VKAdisp,VKAcode=nil
for _,L in next,Widget do
	for _,W in next,L do
		if W.next then
			W.next,L[W.next].prev=L[W.next],W
		end
	end
end
return Widget