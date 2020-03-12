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
local skin={}
skin.lib={}
skin.libMini={}
skin.libColor={
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
	color.darkGreen,
	color.grey,
	color.lightGrey,
	color.darkPurple,
	color.darkRed,
	color.darkGreen,
}
function skin.load()
	gc.push()
	gc.origin()
	gc.setDefaultFilter("nearest","nearest")
	gc.setColor(1,1,1)
	for i=1,#list do
		local I=gc.newImage("/image/skin/"..list[i]..".png")
		skin.lib[i],skin.libMini[i]={},{}--30/6
		for j=1,11 do
			skin.lib[i][j]=C(30,30)
			gc.draw(I,30-30*j,0)

			skin.libMini[i][j]=C(6,6)
			gc.draw(I,6-6*j,0,nil,.2)
		end
		for j=1,6 do
			skin.lib[i][11+j]=C(30,30)
			gc.draw(I,30-30*j,-30)

			skin.libMini[i][11+j]=C(6,6)
			gc.draw(I,6-6*j,-6,nil,.2)
		end
		I:release()
	end
	skin.change(setting.skinSet)
	puzzleMark={}
	gc.setLineWidth(3)
	for i=1,11 do
		puzzleMark[i]=C(30,30)
		local _=blockColor[i]
		gc.setColor(_[1],_[2],_[3],.6)
		gc.rectangle("line",5,5,20,20)
		gc.rectangle("line",10,10,10,10)
	end
	for i=12,17 do
		puzzleMark[i]=C(30,30)
		gc.setColor(blockColor[i])
		gc.rectangle("line",7,7,16,16)
	end
	local _=C(30,30)
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
function skin.prevSet()--prev skin_set
	local _=(setting.skinSet-2)%L+1
	setting.skinSet=_
	skin.change(_)
	_=list[_]
	TEXT(_,1100,100,int(300/#_)+5,"fly")
end
function skin.nextSet()--next skin_set
	local _=setting.skinSet%L+1
	setting.skinSet=_
	skin.change(_)
	_=list[_]
	TEXT(_,1100,100,int(300/#_)+5,"fly")
end
function skin.prev(i)--prev skin for [i]
	local _=setting.skin
	_[i]=(_[i]-2)%11+1
	skin.adjust(i,_[i])
end
function skin.next(i)--next skin for [i]
	local _=setting.skin
	_[i]=_[i]%11+1
	skin.adjust(i,_[i])
end
function skin.rotate(i)--change direction of [i]
	setting.face[i]=(setting.face[i]+1)%4
	SFX.play("rotate")
end
function skin.change(i)--change to skin_set[i]
	for _=1,7 do
		skin.adjust(_,setting.skin[_])
	end
	for _=8,13 do
		blockSkin[_]=skin.lib[i][_+4]
		blockSkinMini[_]=skin.libMini[i][_+4]
	end
end
function skin.adjust(i,id)--load color/image/image_mini of [i] from lib
	local S=setting.skinSet
	blockSkin[i]=skin.lib[S][id]
	blockSkinMini[i]=skin.libMini[S][id]
	blockColor[i]=skin.libColor[id]
end
return skin