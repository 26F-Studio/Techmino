local gc,sys=love.graphics,love.system
local Timer=love.timer.getTime

local abs=math.abs
local max,min,sin,cos=math.max,math.min,math.sin,math.cos
local rnd=math.random

function sceneInit.intro()
	BG.set("space")
	BGM.play("blank")
	sceneTemp={
		t1=0,--Timer 1
		t2=0,--Timer 2
		r={},--Random animation type
	}
	for i=1,8 do
		sceneTemp.r[i]=rnd(5)
	end
end

function mouseDown.intro(_,_,k)
	if k==2 then
		VOC.play("bye")
		SCN.back()
	elseif NOGAME=="delSetting"then
		LOG.print("检测到过老版本非法设置数据,设置已经全部重置,请重启游戏完成",600,COLOR.yellow)
		LOG.print("Old version detected, setting file deleted, please restart the game",600,COLOR.yellow)
	elseif NOGAME=="delCC"then
		LOG.print("请关闭游戏,然后删除存档文件夹内的 CCloader.dll(21KB) !",600,COLOR.yellow)
		LOG.print("Please quit the game, then delete CCloader.dll(21KB) in saving folder!",600,COLOR.yellow)
		TASK.new(function(S)
			S[1]=S[1]-1
			if S[1]==0 then
				sys.openURL(love.filesystem.getSaveDirectory())
				return true
			end
		end,{60})
	else
		if newVersionLaunch then
			SCN.push("main","fade")
			SCN.swapTo("history","fade")
			LOG.print(text.newVersion,"warn",COLOR.lBlue)
		else
			SCN.go("main")
		end
	end
end
function touchDown.intro()
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
	local T=(S.t1+110)%300
	if T<30 then
		gc.setLineWidth(4+(30-T)^1.626/62)
	else
		gc.setLineWidth(4)
	end
	local L=title
	gc.push("transform")
	gc.translate(126,226)
	for i=1,8 do
		local t=S.t1-i*15
		if t>0 then
			gc.push("transform")
				gc.setColor(1,1,1,min(t*.025,1))
				titleTransform[S.r[i]](t,i)
				local dt=(S.t1+62-5*i)%300
				if dt<20 then
					gc.translate(0,abs(10-dt)-10)
				end
				gc.polygon("line",L[i])
			gc.pop()
		end
	end
	gc.pop()
	if S.t2>=80 then
		gc.setColor(1,1,1,.6+sin((S.t2-80)*.0626)*.3)
		mText(drawableText.anykey,640,615+sin(Timer()*3)*5)
	end
end