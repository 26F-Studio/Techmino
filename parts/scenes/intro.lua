local gc=love.graphics

local max,min,sin,cos=math.max,math.min,math.sin,math.cos
local rnd=math.random

local scene={}

local t1,t2,animeType

function scene.sceneInit()
	BG.set()
	t1,t2=0,0--Timer
	animeType={}for i=1,8 do animeType[i]=rnd(5)end--Random animation type
end

function scene.mouseDown()
	if newVersionLaunch then
		SCN.push(SETTING.simpMode and"main_simple"or"main")
		SCN.swapTo('history','fade')
		LOG.print(text.newVersion,'warn',COLOR.lB)
	else
		SCN.go(SETTING.simpMode and"main_simple"or"main")
	end
end
function scene.touchDown()
	scene.mouseDown()
end
function scene.keyDown(key)
	if key=="escape"then
		VOC.play('bye')
		SCN.swapTo('quit','slowFade')
	else
		scene.mouseDown()
	end
end

function scene.update()
	t1,t2=t1+1,t2+1
end

local titleTransform={
	function(t)gc.translate(0,max(50-t,0)^2/25)end,
	function(t)gc.translate(0,-max(50-t,0)^2/25)end,
	function(t,i)local d=max(50-t,0)gc.translate(sin(TIME()*3+626*i)*d,cos(TIME()*3+626*i)*d)end,
	function(t,i)local d=max(50-t,0)gc.translate(sin(TIME()*3+626*i)*d,-cos(TIME()*3+626*i)*d)end,
	function(t)gc.setColor(1,1,1,min(t*.02,1)+rnd()*.2)end,
}
function scene.draw()
	local T=(t1+110)%300
	if T<30 then
		gc.setLineWidth(4+(30-T)^1.626/62)
	else
		gc.setLineWidth(4)
	end
	local L=title
	gc.push('transform')
	gc.translate(126,226)
	for i=1,8 do
		local t=t1-i*15
		if t>0 then
			gc.push('transform')
				gc.setColor(1,1,1,min(t*.025,1))
				titleTransform[animeType[i]](t,i)
				local dt=(t1+62-5*i)%300
				if dt<20 then
					gc.translate(0,math.abs(10-dt)-10)
				end
				gc.polygon('line',L[i])
			gc.pop()
		end
	end
	gc.pop()
	if t2>=80 then
		gc.setColor(1,1,1,.6+sin((t2-80)*.0626)*.3)
		mText(drawableText.anykey,640,615+sin(TIME()*3)*5)
	end
end

return scene