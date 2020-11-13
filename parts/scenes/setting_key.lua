local gc=love.graphics
local Timer=love.timer.getTime

local mStr=mStr

local int,sin=math.floor,math.sin

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
	local S=sceneTemp
	if key=="escape"then
		if S.kS then
			S.kS=false
			SFX.play("finesseError",.5)
		else
			SCN.back()
		end
	elseif S.kS then
		if key~="\\"then
			for y=1,20 do
				if keyMap[1][y]==key then keyMap[1][y]=""break end
				if keyMap[2][y]==key then keyMap[2][y]=""break end
			end
			keyMap[S.board][S.kb]=key
			S.kS=false
			SFX.play("reach",.5)
		end
	elseif key=="return"or key=="space"then
		S.kS=true
		SFX.play("lock",.5)
	elseif key=="up"or key=="w"then
		if S.kb>1 then
			S.kb=S.kb-1
			SFX.play("move",.5)
		end
	elseif key=="down"or key=="s"then
		if S.kb<20 then
			S.kb=S.kb+1
			SFX.play("move",.5)
		end
	elseif key=="left"or key=="a"or key=="right"or key=="d"then
		S.board=3-S.board
		SFX.play("rotate",.5)
	end
end
function gamepadDown.setting_key(key)
	local S=sceneTemp
	if key=="back"then
		if S.jS then
			S.jS=false
			SFX.play("finesseError",.5)
		else
			SCN.back()
		end
	elseif S.jS then
		for y=1,20 do
			if keyMap[3][y]==key then keyMap[3][y]=""break end
			if keyMap[4][y]==key then keyMap[4][y]=""break end
		end
		keyMap[2+S.board][S.js]=key
		SFX.play("reach",.5)
		S.jS=false
	elseif key=="start"then
		S.jS=true
		SFX.play("lock",.5)
	elseif key=="dpup"then
		if S.js>1 then
			S.js=S.js-1
			SFX.play("move",.5)
		end
	elseif key=="dpdown"then
		if S.js<20 then
			S.js=S.js+1
			SFX.play("move",.5)
		end
	elseif key=="dpleft"or key=="dpright"then
		S.board=3-S.board
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
	gc.print(text.page..S.board,280,570)
end

WIDGET.init("setting_key",{
	WIDGET.newText({name="keyboard",	x=340,y=30,font=25,color="lRed"}),
	WIDGET.newText({name="keyboard",	x=940,y=30,font=25,color="lRed"}),
	WIDGET.newText({name="joystick",	x=540,y=30,font=25,color="lBlue"}),
	WIDGET.newText({name="joystick",	x=1140,y=30,font=25,color="lBlue"}),
	WIDGET.newText({name="help",		x=50,y=650,font=30,align="L"}),
	WIDGET.newButton({name="back",		x=1140,y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK}),
})