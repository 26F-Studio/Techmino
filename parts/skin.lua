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
	color.red,
	color.orange,
	color.yellow,
	color.grass,
	color.green,
	color.water,
	color.cyan,
	color.blue,
	color.purple,
	color.magenta,
	color.pink,
	color.dGrey,
	color.grey,
	color.lGrey,
	color.dPurple,
	color.dRed,
	color.dGreen,
}
function SKIN.getCount()
	return count
end
function SKIN.loadOne(_)
	gc.push()
	gc.origin()
	gc.setDefaultFilter("nearest","nearest")
	gc.setColor(1,1,1)
	SKIN.lib[_],SKIN.libMini[_]={},{}--30/6
	local N="/image/skin/"..list[_]..".png"
	local I
	if love.filesystem.getInfo(N)then
		I=gc.newImage(N)
	else
		I=gc.newImage("/image/skin/"..list[1]..".png")
		LOG.print("No skin file: "..list[_],"warn")
	end
	for j=1,11 do
		SKIN.lib[_][j]=C(30,30)
		gc.draw(I,30-30*j,0)

		SKIN.libMini[_][j]=C(6,6)
		gc.draw(I,6-6*j,0,nil,.2)
	end
	for j=1,6 do
		SKIN.lib[_][11+j]=C(30,30)
		gc.draw(I,30-30*j,-30)

		SKIN.libMini[_][11+j]=C(6,6)
		gc.draw(I,6-6*j,-6,nil,.2)
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
	_[i]=(_[i]-2)%11+1
end
function SKIN.next(i)--Next skin for [i]
	local _=SETTING.skin
	_[i]=_[i]%11+1
end
function SKIN.rotate(i)--Change direction of [i]
	SETTING.face[i]=(SETTING.face[i]+1)%4
	SFX.play("rotate")
end
function SKIN.change(i)--Change to skin_set[i]
	blockSkin=SKIN.lib[i]
	blockSkinMini=SKIN.libMini[i]
end
return SKIN