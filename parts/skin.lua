local SKIN={
	getCount=function()return 0 end,
	prevSet=NULL,
	nextSet=NULL,
	prev=NULL,
	next=NULL,
	rotate=NULL,
	change=NULL,
}
function SKIN.init(list)
	local gc=love.graphics
	local int=math.floor
	local function C(x,y)
		local _=gc.newCanvas(x,y)
		gc.setCanvas(_)
		return _
	end
	local count=#list function SKIN.getCount()return count end
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

	local function load(skip)
		for i=1,count do
			gc.push()
			gc.origin()
			gc.setDefaultFilter("nearest","nearest")
			gc.setColor(1,1,1)
			SKIN.lib[i],SKIN.libMini[i]={},{}
			local N="media/image/skin/"..list[i]..".png"
			local I
			if love.filesystem.getInfo(N)then
				I=gc.newImage(N)
			else
				I=gc.newImage("media/image/skin/"..list[1]..".png")
				LOG.print("No skin file: "..list[i],"warn")
			end
			for y=0,2 do
				for x=1,8 do
					SKIN.lib[i][8*y+x]=C(30,30)
					gc.draw(I,30-30*x,-30*y)

					SKIN.libMini[i][8*y+x]=C(6,6)
					gc.draw(I,6-6*x,-6*y,nil,.2)
				end
			end
			I:release()
			gc.setCanvas()
			gc.pop()
			if not skip and i~=count then
				coroutine.yield()
			end
		end
		SKIN.loadOne=nil

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
	end

	SKIN.loadOne=coroutine.wrap(load)
	function SKIN.loadAll()load(true)end
end
return SKIN