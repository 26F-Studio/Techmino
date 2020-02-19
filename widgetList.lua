local mobile=system=="Android"or system=="iOS"
local langName={"中文","全中文","English"}
local virtualkeySet={
	{
		{1,	80,			720-200,	80},--moveLeft
		{2,	320,		720-200,	80},--moveRight
		{3,	1280-80,	720-200,	80},--rotRight
		{4,	1280-200,	720-80,		80},--rotLeft
		{5,	1280-200,	720-320,	80},--rotFlip
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
		{5,	200,		720-320,	80},--rotFlip
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
		{5,	1280-240,	720-240,	80},--rotFlip
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
		{5,	240,		720-240,	80},--rotFlip
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
		{5,	310,	50,30},--rotFlip
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
local function useDefaultSet(n)
	for i=1,#customSet[n]do
		customSel[i]=customSet[n][i]
	end
	curBG=customRange.bg[customSel[12]]
	BGM(customRange.bgm[customSel[13]])
end

--λFuncs for widgets
local function SETdisp(k)
	return function()
		return setting[k]
	end
end
local function SETsto(k)
	return function(i)setting[k]=i end
end
local function SETrev(k)
	return function()
		setting[k]=not setting[k]
	end
end
local function pressKey(k)
	return function()
		love.keypressed(k)
	end
end
local function setPen(i)
	return function()
		sceneTemp.pen=i
	end
end
local function VKAdisp(n)
	return function()
		return VK_org[n].ava
	end
end
local function VKAcode(n)
	return function()
		VK_org[n].ava=not VK_org[n].ava
	end
end
local C=color
local skinName={
	"Normal(MrZ)",
	"Jelly(Miya)",
	"Plastic(MrZ)",
	"Glow(MrZ)",
	"Pure(MrZ)",
	"Text Bone(MrZ)",
	"Colored Bone(MrZ)",
	"white Bone(MrZ)",
}
local Widget={
	load={},intro={},quit={},
	main={
		play=	newButton(150,280,200,160,C.lightRed,		55,function()scene.push()scene.swapTo("mode")end,			nil,"setting"),
		setting=newButton(370,280,200,160,C.lightBlue,		45,function()scene.push()scene.swapTo("setting_game")end,	nil,"music"),
		music=	newButton(590,280,200,160,C.lightPurple,	32,function()scene.push()scene.swapTo("music")end,			nil,"help"),
		help=	newButton(150,460,200,160,C.lightYellow,	50,function()scene.push()scene.swapTo("help")end,			nil,"stat"),
		stat=	newButton(370,460,200,160,C.lightCyan,		43,function()scene.push()scene.swapTo("stat")end,			nil,"qplay"),
		qplay=	newButton(590,460,200,160,C.lightOrange,	43,function()scene.push()loadGame(mapCam.lastPlay)end,		nil,"lang"),
		lang=	newButton(150,610,160,100,C.lightGreen,		45,function()
			setting.lang=setting.lang%#langName+1
			changeLanguage(setting.lang)
			TEXT(text.lang,370,610,50,"appear",1.6)
			end,nil,"quit"),
		quit=	newButton(590,610,160,100,C.lightGrey,		45,function()VOICE("bye")scene.swapTo("quit","slowFade")end,nil,"play"),
	},
	mode={
		draw=	newButton(1100,	440,220,90,C.lightYellow,	40,function()scene.push()scene.swapTo("draw")end,function()return mapCam.sel~=71 and mapCam.sel~=72 end),
		setting=newButton(1100,	540,220,90,C.lightGreen,	40,function()scene.push()scene.swapTo("custom")end,function()return mapCam.sel~=71 and mapCam.sel~=72 end),
		start=	newButton(1040,	655,180,80,C.lightGrey,		40,function()scene.push()loadGame(mapCam.sel)end,function()return not mapCam.sel end),
		back=	newButton(1200,	655,120,80,C.white,			40,scene.back),
		--function()scene.push()scene.swapTo("custom")end
	},
	music={
		bgm=	newSlider(760,	80,400,10,35,nil,SETdisp("bgm"),function(i)setting.bgm=i;BGM(bgmPlaying)end),
		up=		newButton(1100,	200,120,120,C.white,55,pressKey("up")),
		play=	newButton(1100,	340,120,120,C.white,35,pressKey("space"),function()return setting.bgm==0 end),
		down=	newButton(1100,	480,120,120,C.white,55,pressKey("down")),
		back=	newButton(640,	630,230,90,	C.white,40,scene.back),
	},
	custom={
		up=		newButton(1000,	360,100,100,C.white,		45,function()sceneTemp=(sceneTemp-2)%#customID+1 end),
		down=	newButton(1000,	600,100,100,C.white,		45,function()sceneTemp=sceneTemp%#customID+1 end),
		left=	newButton(880,	480,100,100,C.white,		45,pressKey("left")),
		right=	newButton(1120,	480,100,100,C.white,		45,pressKey("right")),
		set1=	newButton(640,	160,240,75,	C.lightYellow,	35,function()useDefaultSet(1)end),
		set2=	newButton(640,	250,240,75,	C.lightYellow,	35,function()useDefaultSet(2)end),
		set3=	newButton(640,	340,240,75,	C.lightYellow,	35,function()useDefaultSet(3)end),
		set4=	newButton(640,	430,240,75,	C.lightYellow,	35,function()useDefaultSet(4)end),
		set5=	newButton(640,	520,240,75,	C.lightYellow,	35,function()useDefaultSet(5)end),
		back=	newButton(640,	630,180,60,	C.white,		35,scene.back),
	},
	draw={
		block1=	newButton(920,	80,	120,120,C.red,			60,setPen(1)),
		block2=	newButton(1060,	80,	120,120,C.green,		60,setPen(2)),
		block3=	newButton(1200,	80,	120,120,C.orange,		60,setPen(3)),
		block4=	newButton(920,	220,120,120,C.blue,			60,setPen(4)),
		block5=	newButton(1060,	220,120,120,C.magenta,		60,setPen(5)),
		block6=	newButton(1200,	220,120,120,C.yellow,		60,setPen(6)),
		block7=	newButton(920,	360,120,120,C.cyan,			60,setPen(7)),
		gb1=	newButton(1060,	360,120,120,C.darkGrey,		60,setPen(9)),
		gb2=	newButton(1200,	360,120,120,C.grey,			60,setPen(10)),
		gb3=	newButton(920,	500,120,120,C.darkPurple,	60,setPen(11)),
		gb4=	newButton(1060,	500,120,120,C.darkRed,		60,setPen(12)),
		gb5=	newButton(1200,	500,120,120,C.darkGreen,	60,setPen(13)),
		clear=	newButton(780,	80,	120,120,C.white,		40,pressKey("delete")),
		any=	newButton(780,	220,120,120,C.lightGrey,	40,setPen(0)),
		space=	newButton(780,	360,120,120,C.grey,			65,setPen(-1)),
		demo=	newSwitch(755,	640,30,function()return sceneTemp.demo end,function()sceneTemp.demo=not sceneTemp.demo end),
		copy=	newButton(920,	640,120,120,C.lightRed,		35,copyBoard),
		paste=	newButton(1060,	640,120,120,C.lightBlue,	35,pasteBoard),
		back=	newButton(1200,	640,120,120,C.white,		35,scene.back),
	},
	play={
		pause=	newButton(1235,45,80,80,C.white,25,pauseGame),
	},
	pause={
		resume=	newButton(640,290,240,100,C.white,45,resumeGame),
		restart=newButton(640,445,240,100,C.white,45,function()
			clearTask("play")
			updateStat()
			resetGameData()
			scene.swapTo("play","none")
			end),
		sfx=	newSlider(950,60,280,10,35,function()SFX("blip_1")end,				SETdisp("sfx"),SETsto("sfx")),
		bgm=	newSlider(950,120,280,10,35,function()BGM(bgmPlaying or"blank")end,	SETdisp("bgm"),SETsto("bgm")),
		quit=	newButton(640,600,240,100,C.white,45,scene.back),
	},
	setting_game={
		graphic=newButton(200,80,240,80,C.lightCyan,35,function()scene.swapTo("setting_graphic")end,nil,"sound"),
		sound=	newButton(1080,80,240,80,C.lightCyan,35,function()scene.swapTo("setting_sound")end,	nil,"dasD"),
		dasD=	newButton(180,230,50,50,C.white,40,function()
			setting.das=(setting.das-1)%31
			if setting.arr>setting.das then
				setting.arr=setting.das
				Widget.setting_game.arrD:FX()
				SFX("blip_1",.4)
			end
			end,nil,"dasU"),
		dasU=	newButton(400,230,50,50,C.white,40,function()
			setting.das=(setting.das+1)%31
			if setting.arr>setting.das then
				setting.das=setting.arr
				Widget.setting_game.arrD:FX()
				SFX("blip_1",.4)
			end
			end,nil,"arrD"),
		arrD=	newButton(500,230,50,50,C.white,40,function()
			setting.arr=(setting.arr-1)%16
			if setting.arr>setting.das then
				setting.das=setting.arr
				Widget.setting_game.dasU:FX()
				SFX("blip_1",.4)
			end
			end,nil,"arrU"),
		arrU=	newButton(720,230,50,50,C.white,40,function()
			setting.arr=(setting.arr+1)%16
			if setting.arr>setting.das then
				setting.das=setting.arr
				Widget.setting_game.dasU:FX()
				SFX("blip_1",.4)
			end
			end,nil,"sddasD"),
		sddasD=	newButton(180,340,50,50,C.white,40,	function()setting.sddas=(setting.sddas-1)%11 end,		nil,"sddasU"),
		sddasU=	newButton(400,340,50,50,C.white,40,	function()setting.sddas=(setting.sddas+1)%11 end,		nil,"sdarrD"),
		sdarrD=	newButton(500,340,50,50,C.white,40,	function()setting.sdarr=(setting.sdarr-1)%4 end,		nil,"sdarrU"),
		sdarrU=	newButton(720,340,50,50,C.white,40,	function()setting.sdarr=(setting.sdarr+1)%4 end,		nil,"reTime"),
		reTime=	newSlider(350,430,300,10,30,nil,	SETdisp("reTime"),		SETsto("reTime"),				nil,"maxNext"),
		maxNext=newSlider(350,510,300,6,30,nil,		SETdisp("maxNext"),		SETsto("maxNext"),				nil,"quickR"),
		quickR=	newSwitch(1000,430,35,				SETdisp("quickR"),		SETrev("quickR"),				nil,"swap"),
		swap=	newSwitch(1000,510,19,				SETdisp("swap"),		SETrev("swap"),					nil,"fine"),
		fine=	newSwitch(1000,590,20,				SETdisp("fine"),		SETrev("fine"),					nil,"ctrl"),
		ctrl=	newButton(1020,230,320,80,C.white,35,function()scene.push()scene.swapTo("setting_key")end,	nil,"touch"),
		touch=	newButton(1020,340,320,80,C.white,35,function()scene.push()scene.swapTo("setting_touch")end,nil,"back"),
		back=	newButton(1160,600,160,160,C.white,50,scene.back,											nil,"graphic"),
	},
	setting_graphic={
		sound=	newButton(200,80,240,80,C.lightCyan,35,function()scene.swapTo("setting_sound")end,	nil,"game"),
		game=	newButton(1080,80,240,80,C.lightCyan,35,function()scene.swapTo("setting_game")end,	nil,"ghost"),
		ghost=	newSwitch(310,180,35,SETdisp("ghost"),						SETrev("ghost"),		nil,"center"),
		center=	newSwitch(580,180,35,SETdisp("center"),						SETrev("center"),		nil,"smo"),
		smo=	newSwitch(310,260,25,SETdisp("smo"),						SETrev("smo"),			nil,"grid"),
		grid=	newSwitch(580,260,30,SETdisp("grid"),						SETrev("grid"),			nil,"dropFX"),
		dropFX=	newSlider(310,350,373,5,35,nil,SETdisp("dropFX"),			SETsto("dropFX"),		nil,"shakeFX"),
		shakeFX=newSlider(310,430,373,5,35,nil,SETdisp("shakeFX"),			SETsto("shakeFX"),		nil,"atkFX"),
		atkFX=	newSlider(310,510,373,5,35,nil,SETdisp("atkFX"),			SETsto("atkFX"),		nil,"frame"),
		frame=	newSlider(310,590,373,10,35,nil,function()return setting.frameMul>35 and setting.frameMul/10 or setting.frameMul/5-4 end,function(i)setting.frameMul=i<5 and 5*i+20 or 10*i end,nil,"fullscreen"),
		fullscreen=newSwitch(990,180,40,SETdisp("fullscreen"),function()
			setting.fullscreen=not setting.fullscreen
			love.window.setFullscreen(setting.fullscreen)
			if not setting.fullscreen then
			love.resize(love.graphics.getWidth(),love.graphics.getHeight())
			end
			end,nil,"bg"),
		bg=		newSwitch(990,250,35,SETdisp("bg"),SETrev("bg"),nil,"bgspace"),
		bgspace=newSwitch(990,330,35,SETdisp("bgspace"),function()
			setting.bgspace=not setting.bgspace
			if setting.bgspace then
				space.new()
			else
				space.discard()
			end
			end,nil,"skin"),
		skin=	newButton(810,420,120,60,C.white,35,function()
			local _=setting.skin%8+1
			setting.skin=_
			changeBlockSkin(_)
			TEXT(skinName[_],850,475,28,"appear")
			end,nil,"back"),
		back=	newButton(1160,600,160,160,C.white,50,scene.back,nil,"sound"),
		},
	setting_sound={
		game=	newButton(200,80,240,80,C.lightCyan,35,function()scene.swapTo("setting_game")end,							nil,"graphic"),
		graphic=newButton(1080,80,240,80,C.lightCyan,35,function()scene.swapTo("setting_graphic")end,						nil,"sfx"),
		sfx=	newSlider(180,250,400,10,35,function()SFX("blip_1")end,						SETdisp("sfx"),		SETsto("sfx"),	nil,"bgm"),
		bgm=	newSlider(750,250,400,10,35,function()BGM(bgmPlaying or"blank")end,			SETdisp("bgm"),		SETsto("bgm"),	nil,"vib"),
		vib=	newSlider(180,440,400,5	,35,function()VIB(1)end,							SETdisp("vib"),		SETsto("vib"),	nil,"voc"),
		voc=	newSlider(750,440,400,10,35,function()VOICE("nya")end,						SETdisp("voc"),		SETsto("voc"),	nil,"stereo"),
		stereo=	newSlider(180,630,400,10,35,function()SFX("move",1,-1)SFX("lock",1,1)end,	SETdisp("stereo"),	SETsto("stereo"),function()return setting.sfx==0 end,"back"),
		back=newButton(1160,600,160,160,C.white,50,scene.back,nil,"game"),
	},
	setting_key={
		back=newButton(1140,650,200,80,C.white,45,scene.back),
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
			scene.push()
			scene.swapTo("setting_touchSwitch")
			end),
		back=	newButton(760,180,170,80,C.white,40,scene.back),
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
		hide=	newSwitch(1170,200,40,SETdisp("VKSwitch"),SETrev("VKSwitch")),
		track=	newSwitch(1170,300,35,SETdisp("VKTrack"),SETrev("VKTrack")),
		icon=	newSwitch(850,300,40,SETdisp("VKIcon"),SETrev("VKIcon")),
		tkset=	newButton(1120,400,240,80,C.white,32,function()
			scene.push()
			scene.swapTo("setting_trackSetting")
			end,function()return not setting.VKTrack end),
		alpha=	newSlider(840,490,400,10,40,nil,SETdisp("VKAlpha"),SETsto("VKAlpha")),
		back=	newButton(1100,600,240,80,C.white,45,scene.back),
	},
	setting_trackSetting={
		VKDodge=newSwitch(400,200,	35,SETdisp("VKDodge"),SETrev("VKDodge")),
		VKTchW=	newSlider(140,310,1000,10,35,nil,SETdisp("VKTchW"),function(i)setting.VKTchW=i;setting.VKCurW=math.max(setting.VKCurW,i)end),
		VKCurW=	newSlider(140,370,1000,10,35,nil,SETdisp("VKCurW"),function(i)setting.VKCurW=i;setting.VKTchW=math.min(setting.VKTchW,i)end),
		back=	newButton(1080,600,240,80,C.white,45,scene.back),
	},
	help={
		his=	newButton(1050,520,230,60,C.white,35,function()scene.push()scene.swapTo("history")end,nil,"back"),
		qq=		newButton(1050,600,230,60,C.white,35,function()love.system.openURL("tencent://message/?uin=1046101471&Site=&Menu=yes")end,	function()return mobile end,"his"),
		back=	newButton(640,	600,180,60,C.white,35,scene.back,nil,"qq"),
	},
	history={
		prev=	newButton(1155,170,180,180,C.white,65,pressKey("up"),function()return sceneTemp[2]==1 end),
		next=	newButton(1155,400,180,180,C.white,65,pressKey("down"),function()return sceneTemp[2]==#sceneTemp[1]-22 end),
		back=	newButton(1155,600,180,90,C.white,35,scene.back),
	},
	stat={
		path=	newButton(980,620,250,60,C.white,25,function()love.system.openURL(love.filesystem.getSaveDirectory())end,function()return mobile end,"back"),
		back=	newButton(640,620,180,60,C.white,35,scene.back,nil,"path"),
	},
}
for _,L in next,Widget do
	for _,W in next,L do
		if W.next then
			W.next,L[W.next].prev=L[W.next],W
		end
	end
end
return Widget