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
	"text_bone(mrz)",
	"colored_bone(mrz)",
	"white_bone(mrz)",
}
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
	color.darkGrey,
	color.grey,
	color.lightGrey,
	color.darkPurple,
	color.darkRed,
	color.darkGreen,
}
function SKIN.load()
	local _
	gc.push()
	gc.origin()
	gc.setDefaultFilter("nearest","nearest")
	gc.setColor(1,1,1)
	for i=1,#list do
		local I=gc.newImage("/image/skin/"..list[i]..".png")
		SKIN.lib[i],SKIN.libMini[i]={},{}--30/6
		for j=1,11 do
			SKIN.lib[i][j]=C(30,30)
			gc.draw(I,30-30*j,0)

			SKIN.libMini[i][j]=C(6,6)
			gc.draw(I,6-6*j,0,nil,.2)
		end
		for j=1,6 do
			SKIN.lib[i][11+j]=C(30,30)
			gc.draw(I,30-30*j,-30)

			SKIN.libMini[i][11+j]=C(6,6)
			gc.draw(I,6-6*j,-6,nil,.2)
		end
		I:release()
	end
	SKIN.change(setting.skinSet)
	puzzleMark={}
	gc.setLineWidth(3)
	for i=1,11 do
		puzzleMark[i]=C(30,30)
		_=SKIN.libColor[i]
		gc.setColor(_[1],_[2],_[3],.6)
		gc.rectangle("line",5,5,20,20)
		gc.rectangle("line",10,10,10,10)
	end
	for i=12,17 do
		puzzleMark[i]=C(30,30)
		gc.setColor(SKIN.libColor[i])
		gc.rectangle("line",7,7,16,16)
	end
	_=C(30,30)
	gc.setColor(1,1,1)
	gc.line(5,5,25,25)
	gc.line(5,25,25,5)
	puzzleMark[-1]=C(30,30)
	gc.setColor(1,1,1,.9)
	gc.draw(_)
	_:release()
	gc.setCanvas()
	gc.pop()
end
local L=#list
function SKIN.prevSet()--prev skin_set
	local _=(setting.skinSet-2)%L+1
	setting.skinSet=_
	SKIN.change(_)
	_=list[_]
	TEXT.show(_,1100,100,int(300/#_)+5,"fly")
end
function SKIN.nextSet()--next skin_set
	local _=setting.skinSet%L+1
	setting.skinSet=_
	SKIN.change(_)
	_=list[_]
	TEXT.show(_,1100,100,int(300/#_)+5,"fly")
end
function SKIN.prev(i)--prev skin for [i]
	local _=setting.skin
	_[i]=(_[i]-2)%11+1
end
function SKIN.next(i)--next skin for [i]
	local _=setting.skin
	_[i]=_[i]%11+1
end
function SKIN.rotate(i)--change direction of [i]
	setting.face[i]=(setting.face[i]+1)%4
	SFX.play("rotate")
end
function SKIN.change(i)--change to skin_set[i]
	blockSkin=SKIN.lib[i]
	blockSkinMini=SKIN.libMini[i]
end
return SKIN