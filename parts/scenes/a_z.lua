local gc=love.graphics
local Timer=love.timer.getTime
local rnd=math.random
local format=string.format

local mStr=mStr

local levels={
	A_Z="ABCDEFGHIJKLMNOPQRSTUVWXYZ",
	Z_A="ZYXWVUTSRQPONMLKJIHGFEDCBA",
	Tech1="TECHMINOHAOWAN",
	Tech2="TECHMINOISFUN",
	KeyTest1="THEQUICKBROWNFOXJUMPSOVERALAZYDOG",
	KeyTest2="THEFIVEBOXINGWIZARDSJUMPQUICKLY",
	hello="HELLOWORLD",
	zzz="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",
	zxzx="ZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZX",
	stair="ZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCV",
	bpw="OHOOOOOOOOOAAAAEAAIAUJOOOOOOOOOOOAAEOAAUUAEEEEEEEEEAAAAEAEIEAJOOOOOOOOOOEEEEOAAAAAAA",
}

function sceneInit.AtoZ()
	BG.set("bg2")
	BGM.play("way")
	sceneTemp={
		level="A_Z",
		target=levels.A_Z,
		count=1,
		error=0,
		startTime=0,
		time=0,
		state=0,
	}
end

function keyDown.AtoZ(key)
	local S=sceneTemp
	if #key==1 then
		if S.state<2 then
			if key:upper():byte()==S.target:byte(S.count)then
				S.count=S.count+1
				TEXT.show(key:upper(),rnd(320,960),rnd(100,240),90,"score",2.6)
				SFX.play("move")
				if S.count==2 then
					S.state=1
					S.startTime=Timer()
				elseif S.count>#S.target then
					S.time=Timer()-S.startTime
					S.state=2
					SFX.play("reach")
				end
			elseif S.count>1 then
				S.error=S.error+1
				SFX.play("finesseError")
			end
		end
	elseif key=="space"then
		S.count=1
		S.error=0
		S.time=0
		S.state=0
	elseif key=="escape"then
		SCN.back()
	end
end

function Tmr.AtoZ()
	local S=sceneTemp
	if S.state==1 then
		S.time=Timer()-S.startTime
	end
end

function Pnt.AtoZ()
	local S=sceneTemp

	setFont(40)
	gc.setColor(1,1,1)
	gc.print(format("%.3f",S.time),1026,80)
	gc.print(S.error,1026,150)

	if S.state>0 then
		gc.print(format("%.3f/s",(S.count-1)/S.time),1026,220)
	end

	if S.state==2 then
		gc.setColor(.9,.9,0)--win
	elseif S.state==1 then
		gc.setColor(.9,.9,.9)--game
	elseif S.state==0 then
		gc.setColor(.2,.8,.2)--ready
	end

	setFont(100)
	mStr(S.state==1 and #S.target-S.count+1 or S.state==0 and"Ready"or S.state==2 and"Win",640,200)

	gc.setColor(1,1,1)
	gc.print(S.target:sub(S.count,S.count),120,280,0,2)
	gc.print(S.target:sub(S.count+1),310,380)

	gc.setColor(1,1,1,.7)
	setFont(40)
	gc.print(S.target,120,520)
end

WIDGET.init("AtoZ",{
	WIDGET.newSelector({name="level",x=640,y=640,w=200,list={"A_Z","Z_A","Tech1","Tech2","KeyTest1","KeyTest2","hello","zzz","zxzx","stair"},disp=WIDGET.lnk_STPval("level"),code=function(i)sceneTemp.level=i;sceneTemp.target=levels[i]end,hide=function()return sceneTemp.state>0 end}),
	WIDGET.newButton({name="reset",x=160,y=100,w=180,h=100,color="lGreen",font=40,code=WIDGET.lnk_pressKey("space")}),
	WIDGET.newButton({name="back",x=1140,y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK}),
})