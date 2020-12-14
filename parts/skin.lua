local gc=love.graphics
local int=math.floor
local function C(x,y)
	local _=gc.newCanvas(x,y)
	gc.setCanvas(_)
	return _
end
local list={
	"normal(mrz)",
	"smooth(mrz)",
	"contrast(mrz)",
	"glow(mrz)",
	"plastic(mrz)",
	"jelly(miya)",
	"steel(kulumi)",
	"pure(mrz)",
	"ball(shaw)",
	"paper(mrz)",
	"gem(notypey)",
	"classic(_)",
	"brick(notypey)",
	"brick_light(notypey)",
	"cartoon_cup(earety)",
	"crack(earety)",
	"retro(notypey)",
	"retro_grey(notypey)",
	"text_bone(mrz)",
	"colored_bone(mrz)",
	"white_bone(mrz)",
	"WTF",
}
local count=#list
local SKIN={}
SKIN.lib={}
SKIN.libMini={}
SKIN.libColor={
	COLOR.red,
	COLOR.fire,
	COLOR.orange,
	COLOR.yellow,
	COLOR.lame,
	COLOR.grass,
	COLOR.green,
	COLOR.water,
	COLOR.cyan,
	COLOR.sky,
	COLOR.sea,
	COLOR.blue,
	COLOR.purple,
	COLOR.grape,
	COLOR.magenta,
	COLOR.pink,
	COLOR.dGrey,
	COLOR.black,
	COLOR.lYellow,
	COLOR.grey,
	COLOR.lGrey,
	COLOR.dPurple,
	COLOR.dRed,
	COLOR.dGreen,
}
function SKIN.getCount()
	return count
end
function SKIN.loadOne(_)
	gc.push()
	gc.origin()
	gc.setDefaultFilter("nearest","nearest")
	gc.setColor(1,1,1)
	SKIN.lib[_],SKIN.libMini[_]={},{}
	local N="media/image/skin/"..list[_]..".png"
	local I
	if love.filesystem.getInfo(N)then
		I=gc.newImage(N)
	else
		I=gc.newImage("media/image/skin/"..list[1]..".png")
		LOG.print("No skin file: "..list[_],"warn")
	end
	for i=0,2 do
		for j=1,8 do
			SKIN.lib[_][8*i+j]=C(30,30)
			gc.draw(I,30-30*j,-30*i)

			SKIN.libMini[_][8*i+j]=C(6,6)
			gc.draw(I,6-6*j,-6*i,nil,.2)
		end
	end
	I:release()
	gc.setCanvas()
	gc.pop()
end
function SKIN.loadAll()
	for i=1,count do
		SFX.loadOne(i)
	end
end
function SKIN.prevSet()--Prev skin_set
	local _=(SETTING.skinSet-2)%count+1
	SETTING.skinSet=_
	SKIN.change(_)
	_=list[_]
	TEXT.show(_,1100,100,int(300/#_)+5,"fly")
end
function SKIN.nextSet()--Next skin_set
	local _=SETTING.skinSet%count+1
	SETTING.skinSet=_
	SKIN.change(_)
	_=list[_]
	TEXT.show(_,1100,100,int(300/#_)+5,"fly")
end
function SKIN.prev(i)--Prev skin for [i]
	local _=SETTING.skin
	_[i]=(_[i]-2)%16+1
end
function SKIN.next(i)--Next skin for [i]
	local _=SETTING.skin
	_[i]=_[i]%16+1
end
function SKIN.rotate(i)--Change direction of [i]
	SETTING.face[i]=(SETTING.face[i]+1)%4
	SFX.play("rotate")
end
function SKIN.change(i)--Change to skin_set[i]
	SKIN.curText=SKIN.lib[i]
	SKIN.curTextMini=SKIN.libMini[i]
end
return SKIN