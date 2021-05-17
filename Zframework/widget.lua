local kb=love.keyboard
local gc=love.graphics

local int,abs=math.floor,math.abs
local max,min=math.max,math.min
local sub=string.sub
local ins=table.insert
local setFont,mStr=setFont,mStr
local mDraw_X,mDraw_Y=ADRAW.simpX,ADRAW.simpY

local clearIcon=DOGC{40,40,
	{'setLW',6},
	{'line',11,11,29,29},
	{'line',11,29,29,11},
}
local sureIcon=DOGC{40,40,
	{'setFT',35},
	{'mText',"?",20,-6},
}
local smallerThen=DOGC{20,20,
	{'setLW',5},
	{'line',18,2,1,10,18,18},
}
local largerThen=DOGC{20,20,
	{'setLW',5},
	{'line',2,2,19,10,2,18},
}

local WIDGET={}
local widgetMetatable={
	__tostring=function(self)
		return self:getInfo()
	end,
}

local text={
	type='text',
	mustHaveText=true,
	alpha=0,
}

function text:reset()end
function text:update()
	if self.hideF and self.hideF()then
		if self.alpha>0 then
			self.alpha=self.alpha-.125
		end
	elseif self.alpha<1 then
		self.alpha=self.alpha+.125
	end
end
function text:draw()
	if self.alpha>0 then
		local c=self.color
		gc.setColor(c[1],c[2],c[3],self.alpha)
		if self.align=='M'then
			mDraw_X(self.obj,self.x,self.y)
		elseif self.align=='L'then
			gc.draw(self.obj,self.x,self.y)
		elseif self.align=='R'then
			gc.draw(self.obj,self.x-self.obj:getWidth(),self.y)
		end
	end
end
function WIDGET.newText(D)--name,x,y[,fText][,color][,font=30][,align='M'][,hideF][,hide]
	local _={
		name=	D.name,
		x=		D.x,
		y=		D.y,

		fText=	D.fText,
		color=	D.color and(COLOR[D.color]or D.color)or COLOR.Z,
		font=	D.font or 30,
		align=	D.align or'M',
		hideF=	D.hideF,
	}
	for k,v in next,text do _[k]=v end
	if not _.hideF then _.alpha=1 end
	setmetatable(_,widgetMetatable)
	return _
end

local image={
	type='image',
}
function image:reset()
	if type(self.img)=='string'then
		self.img=IMG[self.img]
	end
end
function image:draw()
	gc.setColor(1,1,1,self.alpha)
	gc.draw(self.img,self.x,self.y,self.ang,self.k)
end
function WIDGET.newImage(D)--name[,img(name)],x,y[,ang][,k][,hideF][,hide]
	local _={
		name=	D.name,
		img=	D.img or D.name,
		alpha=	D.alpha,
		x=		D.x,
		y=		D.y,
		ang=	D.ang,
		k=		D.k,
		hideF=	D.hideF,
		hide=	D.hide,
	}
	for k,v in next,image do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end

local button={
	type='button',
	mustHaveText=true,
	ATV=0,--Activating time(0~8)
}
function button:reset()
	self.ATV=0
end
function button:setObject(obj)
	if type(obj)=='string'or type(obj)=='number'then
		self.obj=gc.newText(getFont(self.font),obj)
	elseif obj then
		self.obj=obj
	end
end
function button:isAbove(x,y)
	local ATV=self.ATV
	return
		x>self.x-ATV and
		y>self.y-ATV and
		x<self.x+self.w+2*ATV and
		y<self.y+self.h+2*ATV
end
function button:getCenter()
	return self.x+self.w*.5,self.y+self.h*.5
end
function button:update()
	local ATV=self.ATV
	if WIDGET.sel==self then
		if ATV<8 then self.ATV=ATV+1 end
	else
		if ATV>0 then self.ATV=ATV-.5 end
	end
end
function button:draw()
	local x,y,w,h=self.x,self.y,self.w,self.h
	local ATV=self.ATV
	local c=self.color
	local r,g,b=c[1],c[2],c[3]
	gc.setColor(.2+r*.8,.2+g*.8,.2+b*.8,.7)
	gc.rectangle('fill',x-ATV,y-ATV,w+2*ATV,h+2*ATV)
	if ATV>0 then
		gc.setLineWidth(4)
		gc.setColor(1,1,1,ATV*.125)
		gc.rectangle('line',x-ATV+2,y-ATV+2,w+2*ATV-4,h+2*ATV-4)
	end
	local obj=self.obj
	local y0=y+h*.5-ATV*.5
	gc.setColor(1,1,1,.2+ATV*.05)
	if self.align=='M'then
		local x0=x+w*.5
		mDraw(obj,x0-1.5,y0-1.5)
		mDraw(obj,x0-1.5,y0+1.5)
		mDraw(obj,x0+1.5,y0-1.5)
		mDraw(obj,x0+1.5,y0+1.5)
		gc.setColor(r*.5,g*.5,b*.5)
		mDraw(obj,x0,y0)
	elseif self.align=='L'then
		local edge=self.edge
		mDraw_Y(obj,x+edge-1.5,y0-1.5)
		mDraw_Y(obj,x+edge-1.5,y0+1.5)
		mDraw_Y(obj,x+edge+1.5,y0-1.5)
		mDraw_Y(obj,x+edge+1.5,y0+1.5)
		gc.setColor(r*.5,g*.5,b*.5)
		mDraw_Y(obj,x+edge,y0)
	elseif self.align=='R'then
		local x0=x+w-self.edge-obj:getWidth()
		mDraw_Y(obj,x0-1.5,y0-1.5)
		mDraw_Y(obj,x0-1.5,y0+1.5)
		mDraw_Y(obj,x0+1.5,y0-1.5)
		mDraw_Y(obj,x0+1.5,y0+1.5)
		gc.setColor(r*.5,g*.5,b*.5)
		mDraw_Y(obj,x0,y0)
	end
end
function button:getInfo()
	return("x=%d,y=%d,w=%d,h=%d,font=%d"):format(self.x+self.w*.5,self.y+self.h*.5,self.w,self.h,self.font)
end
function button:press(_,_,k)
	self.code(k)
	local ATV=self.ATV
	SYSFX.newRectRipple(
		6,
		self.x-ATV,
		self.y-ATV,
		self.w+2*ATV,
		self.h+2*ATV
	)
	if self.sound then SFX.play('button')end
end
function WIDGET.newButton(D)--name,x,y,w[,h][,fText][,color][,font=30][,sound=true][,align='M'][,edge=0],code[,hideF][,hide]
	if not D.h then D.h=D.w end
	local _={
		name=	D.name,

		x=		D.x-D.w*.5,
		y=		D.y-D.h*.5,
		w=		D.w,
		h=		D.h,

		resCtr={
			D.x,D.y,
			D.x-D.w*.35,D.y-D.h*.35,
			D.x-D.w*.35,D.y+D.h*.35,
			D.x+D.w*.35,D.y-D.h*.35,
			D.x+D.w*.35,D.y+D.h*.35,
		},

		fText=	D.fText,
		color=	D.color and(COLOR[D.color]or D.color)or COLOR.Z,
		font=	D.font or 30,
		align=	D.align or'M',
		edge=	D.edge or 0,
		sound=	D.sound~=false,
		code=	D.code,
		hideF=	D.hideF,
		hide=	D.hide,
	}
	for k,v in next,button do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end

local key={
	type='key',
	mustHaveText=true,
	ATV=0,--Activating time(0~4)
}
function key:reset()
	self.ATV=0
end
function key:setObject(obj)
	if type(obj)=='string'or type(obj)=='number'then
		self.obj=gc.newText(getFont(self.font),obj)
	elseif obj then
		self.obj=obj
	end
end
function key:isAbove(x,y)
	return
		x>self.x and
		y>self.y and
		x<self.x+self.w and
		y<self.y+self.h
end
function key:getCenter()
	return self.x+self.w*.5,self.y+self.h*.5
end
function key:update()
	local ATV=self.ATV
	if WIDGET.sel==self then
		if ATV<4 then self.ATV=ATV+1 end
	else
		if ATV>0 then self.ATV=ATV-.5 end
	end
end
function key:draw()
	local x,y,w,h=self.x,self.y,self.w,self.h
	local ATV=self.ATV
	local c=self.color
	local r,g,b=c[1],c[2],c[3]

	gc.setColor(1,1,1,ATV*.1)
	gc.rectangle('fill',x,y,w,h)

	gc.setColor(.2+r*.8,.2+g*.8,.2+b*.8,.7)
	gc.setLineWidth(4)
	gc.rectangle('line',x,y,w,h)

	gc.setColor(r,g,b,1.2)
	if self.align=='M'then
		mDraw(self.obj,x+w*.5,y+h*.5)
	elseif self.align=='L'then
		mDraw_Y(self.obj,x+self.edge,y+h*.5)
	elseif self.align=='R'then
		mDraw_Y(self.obj,x+w-self.edge-self.obj:getWidth(),y+h*.5)
	end
end
function key:getInfo()
	return("x=%d,y=%d,w=%d,h=%d,font=%d"):format(self.x+self.w*.5,self.y+self.h*.5,self.w,self.h,self.font)
end
function key:press(_,_,k)
	self.code(k)
	if self.sound then SFX.play('key')end
end
function WIDGET.newKey(D)--name,x,y,w[,h][,fText][,color][,font=30][,sound=true][,align='M'][,edge=0],code[,hideF][,hide]
	if not D.h then D.h=D.w end
	local _={
		name=	D.name,

		x=		D.x-D.w*.5,
		y=		D.y-D.h*.5,
		w=		D.w,
		h=		D.h,

		resCtr={
			D.x,D.y,
			D.x-D.w*.35,D.y-D.h*.35,
			D.x-D.w*.35,D.y+D.h*.35,
			D.x+D.w*.35,D.y-D.h*.35,
			D.x+D.w*.35,D.y+D.h*.35,
		},

		fText=	D.fText,
		color=	D.color and(COLOR[D.color]or D.color)or COLOR.Z,
		font=	D.font or 30,
		sound=	D.sound~=false,
		align=	D.align or'M',
		edge=	D.edge or 0,
		code=	D.code,
		hideF=	D.hideF,
		hide=	D.hide,
	}
	for k,v in next,key do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end

local switch={
	type='switch',
	mustHaveText=true,
	ATV=0,--Activating time(0~8)
	CHK=0,--Check alpha(0~6)
}
function switch:reset()
	self.ATV=0
	self.CHK=0
end
function switch:isAbove(x,y)
	return x>self.x and x<self.x+50 and y>self.y-25 and y<self.y+25
end
function switch:getCenter()
	return self.x,self.y
end
function switch:update()
	local atv=self.ATV
	if WIDGET.sel==self then if atv<8 then self.ATV=atv+1 end
	else if atv>0 then self.ATV=atv-.5 end
	end
	local chk=self.CHK
	if self:disp()then if chk<6 then self.CHK=chk+1 end
	else if chk>0 then self.CHK=chk-1 end
	end
end
function switch:draw()
	local x,y=self.x,self.y-25
	local ATV=self.ATV

	--Checked
	if ATV>0 then
		gc.setColor(1,1,1,ATV*.08)
		gc.rectangle('fill',x,y,50,50)
	end
	if self.CHK>0 then
		gc.setColor(.9,1,.9,self.CHK/6)
		gc.setLineWidth(6)
		gc.line(x+5,y+25,x+18,y+38,x+45,y+11)
	end

	--Frame
	gc.setLineWidth(4)
	gc.setColor(1,1,1,.6+ATV*.05)
	gc.rectangle('line',x,y,50,50)

	--Drawable
	gc.setColor(self.color)
	mDraw_Y(self.obj,x-12-ATV-self.obj:getWidth(),y+25)
end
function switch:getInfo()
	return("x=%d,y=%d,font=%d"):format(self.x,self.y,self.font)
end
function switch:press()
	self.code()
	if self.sound then SFX.play('move')end
end
function WIDGET.newSwitch(D)--name,x,y[,fText][,color][,font=30][,sound=true][,disp],code,hide
	local _={
		name=	D.name,

		x=		D.x,
		y=		D.y,

		resCtr={
			D.x+25,D.y,
		},

		fText=	D.fText,
		color=	D.color and(COLOR[D.color]or D.color)or COLOR.Z,
		font=	D.font or 30,
		sound=	D.sound~=false,
		disp=	D.disp,
		code=	D.code,
		hideF=	D.hideF,
		hide=	D.hide,
	}
	for k,v in next,switch do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end

local slider={
	type='slider',
	ATV=0,--Activating time(0~8)
	TAT=0,--Text activating time(0~180)
	pos=0,--Position shown
	lastTime=0,--Last value changing time
}
local sliderShowFunc={
	int=function(S)
		return S.disp()
	end,
	float=function(S)
		return int(S.disp()*100)*.01
	end,
	percent=function(S)
		return int(S.disp()*100).."%"
	end,
}
function slider:reset()
	self.ATV=0
	self.TAT=180
	self.pos=0
end
function slider:isAbove(x,y)
	return x>self.x-10 and x<self.x+self.w+10 and y>self.y-25 and y<self.y+25
end
function slider:getCenter()
	return self.x+self.w*(self.pos/self.unit),self.y
end
function slider:update()
	local atv=self.ATV
	if self.TAT>0 then
		self.TAT=self.TAT-1
	end
	if WIDGET.sel==self then
		if atv<6 then
			atv=atv+1
			self.ATV=atv
		end
		self.TAT=180
	else
		if atv>0 then
			atv=atv-.5
			self.ATV=atv
		end
	end
	if not self.hide then
		self.pos=self.pos*.7+self.disp()*.3
	end
end
function slider:draw()
	local x,y=self.x,self.y
	local ATV=self.ATV
	local x2=x+self.w

	gc.setColor(1,1,1,.5+ATV*.06)

	--Units
	if not self.smooth then
		gc.setLineWidth(2)
		for p=0,self.unit do
			local X=x+(x2-x)*p/self.unit
			gc.line(X,y+7,X,y-7)
		end
	end

	--Axis
	gc.setLineWidth(4)
	gc.line(x,y,x2,y)

	--Block
	local cx=x+(x2-x)*self.pos/self.unit
	local bx,by,bw,bh=cx-10-ATV*.5,y-16-ATV,20+ATV,32+2*ATV
	gc.setColor(.8,.8,.8)
	gc.rectangle('fill',bx,by,bw,bh)

	if ATV>0 then
		gc.setLineWidth(2)
		gc.setColor(1,1,1,ATV*.16)
		gc.rectangle('line',bx+1,by+1,bw-2,bh-2)
	end
	if self.TAT>0 and self.show then
		setFont(25)
		gc.setColor(1,1,1,self.TAT/180)
		mStr(self:show(),cx,by-30)
	end

	--Drawable
	if self.obj then
		gc.setColor(self.color)
		mDraw_Y(self.obj,x-12-ATV-self.obj:getWidth(),y)
	end
end
function slider:getInfo()
	return("x=%d,y=%d,w=%d"):format(self.x,self.y,self.w)
end
function slider:press(x)
	self:drag(x)
end
function slider:drag(x)
	if not x then return end
	x=x-self.x
	local p=self.disp()
	local P=x<0 and 0 or x>self.w and self.unit or x/self.w*self.unit
	if not self.smooth then
		P=int(P+.5)
	end
	if p~=P then
		self.code(P)
	end
	if self.change and TIME()-self.lastTime>.18 then
		self.lastTime=TIME()
		self.change()
	end
end
function slider:release(x)
	self.lastTime=0
	self:drag(x)
end
function slider:arrowKey(isLeft)
	local p=self.disp()
	local u=(self.smooth and .01 or 1)
	local P=isLeft and max(p-u,0)or min(p+u,self.unit)
	if p==P or not P then return end
	self.code(P)
	if self.change and TIME()-self.lastTime>.18 then
		self.lastTime=TIME()
		self.change()
	end
end
function WIDGET.newSlider(D)--name,x,y,w[,fText][,color][,unit][,smooth][,font=30][,change],disp,code,hide
	local _={
		name=	D.name,

		x=		D.x,
		y=		D.y,
		w=		D.w,

		resCtr={
			D.x,D.y,
			D.x+D.w*.25,D.y,
			D.x+D.w*.5,D.y,
			D.x+D.w*.75,D.y,
			D.x+D.w,D.y,
		},

		fText=	D.fText,
		color=	D.color and(COLOR[D.color]or D.color)or COLOR.Z,
		unit=	D.unit or 1,
		smooth=	false,
		font=	D.font or 30,
		change=	D.change,
		disp=	D.disp,
		code=	D.code,
		hideF=	D.hideF,
		hide=	D.hide,
		show=	false,
	}
	if D.smooth~=nil then
		_.smooth=D.smooth
	else
		_.smooth=_.unit<=1
	end
	if D.show then
		if type(D.show)=='function'then
			_.show=D.show
		else
			_.show=sliderShowFunc[D.show]
		end
	elseif D.show~=false then
		if _.unit<=1 then
			_.show=sliderShowFunc.percent
		else
			_.show=sliderShowFunc.int
		end
	end
	for k,v in next,slider do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end

local selector={
	type='selector',
	mustHaveText=true,
	ATV=8,--Activating time(0~4)
	select=0,--Selected item ID
	selText=false,--Selected item name
}
function selector:reset()
	self.ATV=0
	local V,L=self.disp(),self.list
	local i=TABLE.find(L,V)
	if i then
		self.select=i
		self.selText=self.list[i]
	else
		self.hide=true
		LOG.print("Selector "..self.name.." dead, disp= "..tostring(V),'warn')
	end
end
function selector:isAbove(x,y)
	return
		x>self.x and
		x<self.x+self.w+2 and
		y>self.y and
		y<self.y+60
end
function selector:getCenter()
	return self.x+self.w*.5,self.y+30
end
function selector:update()
	local atv=self.ATV
	if WIDGET.sel==self then
		if atv<8 then
			self.ATV=atv+1
		end
	else
		if atv>0 then
			self.ATV=atv-.5
		end
	end
end
function selector:draw()
	local x,y=self.x,self.y
	local w=self.w
	local ATV=self.ATV

	gc.setColor(1,1,1,.6+ATV*.1)
	gc.setLineWidth(3)
	gc.rectangle('line',x,y,w,60)

	gc.setColor(1,1,1,.2+ATV*.1)
	local t=(TIME()%.5)^.5
	if self.select>1 then
		gc.draw(smallerThen,x+6,y+33)
		if ATV>0 then
			gc.setColor(1,1,1,ATV*.4*(.5-t))
			gc.draw(smallerThen,x+6-t*40,y+33)
			gc.setColor(1,1,1,.2+ATV*.1)
		end
	end
	if self.select<#self.list then
		gc.draw(largerThen,x+w-26,y+33)
		if ATV>0 then
			gc.setColor(1,1,1,ATV*.4*(.5-t))
			gc.draw(largerThen,x+w-26+t*40,y+33)
		end
	end

	--Drawable
	gc.setColor(self.color)
	ADRAW.simpX(self.obj,x+w*.5,y+17-21)
	gc.setColor(1,1,1)
	setFont(30)
	mStr(self.selText,x+w*.5,y+43-21)
end
function selector:getInfo()
	return("x=%d,y=%d,w=%d"):format(self.x+self.w*.5,self.y+30,self.w)
end
function selector:press(x)
	if x then
		local s=self.select
		if x<self.x+self.w*.5 then
			if s>1 then
				s=s-1
				SYSFX.newShade(3,self.x,self.y,self.w*.5,60)
			end
		else
			if s<#self.list then
				s=s+1
				SYSFX.newShade(3,self.x+self.w*.5,self.y,self.w*.5,60)
			end
		end
		if self.select~=s then
			self.code(self.list[s])
			self.select=s
			self.selText=self.list[s]
			if self.sound then SFX.play('prerotate')end
		end
	end
end
function selector:arrowKey(isLeft)
	local s=self.select
	if isLeft and s==1 or not isLeft and s==#self.list then return end
	if isLeft then
		s=s-1
		SYSFX.newShade(3,self.x,self.y,self.w*.5,60)
	else
		s=s+1
		SYSFX.newShade(3,self.x+self.w*.5,self.y,self.w*.5,60)
	end
	self.code(self.list[s])
	self.select=s
	self.selText=self.list[s]
	if self.sound then SFX.play('prerotate')end
end
function WIDGET.newSelector(D)--name,x,y,w[,fText][,color][,sound=true],list,disp,code,hide
	local _={
		name=	D.name,

		x=		D.x-D.w*.5,
		y=		D.y-30,
		w=		D.w,

		resCtr={
			D.x,D.y,
			D.x+D.w*.25,D.y,
			D.x+D.w*.5,D.y,
			D.x+D.w*.75,D.y,
			D.x+D.w,D.y,
		},

		fText=	D.fText,
		color=	D.color and(COLOR[D.color]or D.color)or COLOR.Z,
		sound=	D.sound~=false,
		font=	30,
		list=	D.list,
		disp=	D.disp,
		code=	D.code,
		hideF=	D.hideF,
		hide=	D.hide,
	}
	for k,v in next,selector do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end

local inputBox={
	type='inputBox',
	keepFocus=true,
	ATV=0,--Activating time(0~4)
	value="",--Text contained
}
function inputBox:reset()
	self.ATV=0
end
function inputBox:hasText()
	return #self.value>0
end
function inputBox:getText()
	return self.value
end
function inputBox:setText(str)
	if type(str)=='string'then
		self.value=str
	end
end
function inputBox:addText(str)
	if type(str)=='string'then
		self.value=self.value..str
	else
		LOG.print("inputBox "..self.name.." dead, addText("..type(str)..")",'warn')
	end
end
function inputBox:clear()
	self.value=""
end
function inputBox:isAbove(x,y)
	return
		x>self.x and
		y>self.y and
		x<self.x+self.w and
		y<self.y+self.h
end
function inputBox:getCenter()
	return self.x+self.w*.5,self.y
end
function inputBox:update()
	local ATV=self.ATV
	if WIDGET.sel==self then
		if ATV<3 then self.ATV=ATV+1 end
	else
		if ATV>0 then self.ATV=ATV-.25 end
	end
end
function inputBox:draw()
	local x,y,w,h=self.x,self.y,self.w,self.h
	local ATV=self.ATV

	gc.setColor(1,1,1,ATV*.1)
	gc.rectangle('fill',x,y,w,h)

	gc.setColor(1,1,1)
	gc.setLineWidth(4)
	gc.rectangle('line',x,y,w,h)

	--Drawable
	setFont(self.font)
	if self.obj then
		mDraw_Y(self.obj,x-12-self.obj:getWidth(),y+h*.5)
	end
	if self.secret then
		for i=1,#self.value do
			gc.print("*",x-5+self.font*.5*i,y+h*.5-self.font*.7)
		end
	else
		gc.printf(self.value,x+10,y,self.w)
		setFont(self.font-10)
		if WIDGET.sel==self then
			gc.print(EDITING,x+10,y+12-self.font*1.4)
		end
	end
end
function inputBox:getInfo()
	return("x=%d,y=%d,w=%d,h=%d"):format(self.x+self.w*.5,self.y+self.h*.5,self.w,self.h)
end
function inputBox:press()
	if MOBILE then
		local _,y1=SCR.xOy:transformPoint(0,self.y+self.h)
		kb.setTextInput(true,0,y1,1,1)
	end
end
function inputBox:keypress(k)
	local t=self.value
	if #t>0 and EDITING==""then
		if k=="backspace"then
			local p=#t
			while t:byte(p)>=128 and t:byte(p)<192 do
				p=p-1
			end
			t=sub(t,1,p-1)
			SFX.play('lock')
		elseif k=="delete"then
			t=""
			SFX.play('hold')
		end
		self.value=t
	end
end
function WIDGET.newInputBox(D)--name,x,y,w[,h][,font=30][,secret][,regex],hide
	local _={
		name=	D.name,

		x=		D.x,
		y=		D.y,
		w=		D.w,
		h=		D.h,

		resCtr={
			D.x+D.w*.2,D.y,
			D.x+D.w*.5,D.y,
			D.x+D.w*.8,D.y,
		},

		font=	D.font or int(D.h/7-1)*5,
		secret=	D.secret==true,
		regex=	D.regex,
		hideF=	D.hideF,
		hide=	D.hide,
	}
	for k,v in next,inputBox do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end

local textBox={
	type='textBox',
	scrollPos=0,--Which line display at bottom
	scrollPix=0,--Hidden wheel move value
	sure=0,--Sure-timer for clear history
	new=false,--If there is a new message
	-- texts={},
}
function textBox:reset()
	--haha nothing here, but techmino is fun!
end
function textBox:setTexts(t)
	self.texts=t
	self.scrollPos=min(#self.texts,self.capacity)
end
function textBox:isAbove(x,y)
	return
		x>self.x and
		y>self.y and
		x<self.x+self.w and
		y<self.y+self.h
end
function textBox:getCenter()
	return self.x+self.w*.5,self.y+self.w
end
function textBox:update()
	if self.sure>0 then
		self.sure=self.sure-1
	end
end
function textBox:push(t)
	ins(self.texts,t)
	if self.scrollPos==#self.texts-1 then
		self.scrollPos=#self.texts
	else
		self.new=true
	end
end
function textBox:press(x,y)
	if not(x and y)then return end
	self:drag(nil,nil,nil,0)
	if not self.fix and x>self.x+self.w-40 and y<self.y+40 then
		if self.sure>0 then
			self:clear()
			self.new=false
			self.sure=0
		else
			self.sure=60
		end
	end
end
function textBox:drag(_,_,_,dy)
	_=self.scrollPix+dy*SCR.dpi
	local sign=_>0 and 1 or -1
	while abs(_)>30 do
		_=_-30*sign
		self:scroll(-sign)
	end
	self.scrollPix=_
end
function textBox:scroll(n)
	if n<0 then
		self.scrollPos=max(self.scrollPos+n,min(#self.texts,self.capacity))
	else
		self.scrollPos=min(self.scrollPos+n,#self.texts)
	end
end
function textBox:clear()
	self.texts={}
	self.scrollPos=0
	self.new=false
	SFX.play('fall')
end
function textBox:draw()
	local x,y,w,h=self.x,self.y,self.w,self.h
	local texts=self.texts
	local scroll=self.scrollPos
	local cap=self.capacity

	--Update new message status, necessary when hide==true
	if self.scrollPos==#self.texts then
		self.new=false
	end

	--Background
	gc.setColor(0,0,0,.3)
	gc.rectangle('fill',x,y,w,h)

	--Frame
	gc.setLineWidth(4)
	gc.setColor(1,1,WIDGET.sel==self and 0 or 1)
	gc.rectangle('line',x,y,w,h)

	--Slider
	if #texts>cap then
		gc.setLineWidth(2)
		gc.rectangle('line',x-25,y,20,h)
		local len=max(h*cap/#texts,26)
		gc.rectangle('fill',x-22,y+(h-len-6)*(scroll-cap)/(#texts-cap)+3,14,len)
	end

	--Clear button
	gc.setColor(1,1,1)
	if not self.fix then
		gc.rectangle('line',x+w-40,y,40,40)
		gc.draw(self.sure==0 and clearIcon or sureIcon,x+w-40,y)
	end

	--Texts
	setFont(self.font)
	for i=max(scroll-cap+1,1),scroll do
		gc.printf(texts[i],x+8,y+h-10-self.lineH*(scroll-i+1),w)
	end

	--New message
	if self.new and self.scrollPos~=#texts then
		gc.setColor(1,TIME()%.4<.2 and 1 or 0,0)
		gc.print("v",x+w-25,y+h-40)
	end
end
function textBox:getInfo()
	return("x=%d,y=%d,w=%d,h=%d"):format(self.x+self.w*.5,self.y+self.h*.5,self.w,self.h)
end
function WIDGET.newTextBox(D)--name,x,y,w,h[,font=30][,lineH][,fix],hide
	local _={
		name=	D.name,

		resCtr={
			D.x+D.w*.5,D.y+D.h*.5,
			D.x+D.w*.5,D.y,
			D.x-D.w*.5,D.y,
			D.x,D.y+D.h*.5,
			D.x,D.y-D.h*.5,
			D.x,D.y,
			D.x+D.w,D.y,
			D.x,D.y+D.h,
			D.x+D.w,D.y+D.h,
		},

		x=		D.x,
		y=		D.y,
		w=		D.w,
		h=		D.h,

		font=	D.font or 30,
		fix=	D.fix,
		texts=	{},
		hideF=	D.hideF,
		hide=	D.hide,
	}
	_.lineH=D.lineH or _.font*7/5
	_.capacity=int((D.h-10)/_.lineH)

	for k,v in next,textBox do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end

WIDGET.active={}--Table contains all active widgets
WIDGET.sel=false--Selected widget

WIDGET.indexMeta={
	__index=function(L,k)
		for i=1,#L do
			if L[i].name==k then
				return L[i]
			end
		end
	end
}
function WIDGET.set(list)
	WIDGET.unFocus()
	WIDGET.active=list or NONE

	--Reset all widgets
	if list then
		for i=1,#list do
			list[i]:reset()
		end
		if SCN.cur~='custom_field'then
			local colorList=THEME.getThemeColor()
			if not colorList then return end
			local rnd=math.random
			for _,W in next,list do
				if W.color and not W.fText then
					W.color=colorList[rnd(#colorList)]
				end
			end
		end
	end
end
function WIDGET.setLang(widgetText)
	for S,L in next,SCN.scenes do
		if L.widgetList then
			for _,W in next,L.widgetList do
				local t=W.fText or widgetText[S][W.name]
				if not t and W.mustHaveText then
					t=W.name or"##"
					W.color=COLOR.dV
				end
				if type(t)=='string'and W.font then
					t=gc.newText(getFont(W.font),t)
				end
				W.obj=t
			end
		end
	end
end
function WIDGET.isFocus(W)
	return W==nil and WIDGET.sel or WIDGET.sel==W
end
function WIDGET.focus(W)
	if WIDGET.sel==W then return end
	if WIDGET.sel and WIDGET.sel.type=='inputBox'then kb.setTextInput(false)end
	WIDGET.sel=W
	if W and W.type=='inputBox'then
		local _,y1=SCR.xOy:transformPoint(0,W.y+W.h)
		kb.setTextInput(true,0,y1,1,1)
	end
end
function WIDGET.unFocus()
	if WIDGET.sel and WIDGET.sel.type=='inputBox'then kb.setTextInput(false)end
	WIDGET.sel=false
end

function WIDGET.cursorMove(x,y)
	for _,W in next,WIDGET.active do
		if not W.hide and W.resCtr and W:isAbove(x,y)then
			WIDGET.focus(W)
			return
		end
	end
	if WIDGET.sel and not WIDGET.sel.keepFocus then
		WIDGET.unFocus()
	end
end
function WIDGET.press(x,y,k)
	local W=WIDGET.sel
	if not W then return end
	W:press(x,y,k)
	if W.hide then WIDGET.unFocus()end
end
function WIDGET.drag(x,y,dx,dy)
	local W=WIDGET.sel
	if not W then return end
	if W.type=='slider'or W.type=='textBox'then
		W:drag(x,y,dx,dy)
	elseif not W:isAbove(x,y)and not WIDGET.sel.keepFocus then
		WIDGET.unFocus()
	end
end
function WIDGET.release(x,y)
	local W=WIDGET.sel
	if not W then return end
	if W.type=='slider'then
		W:release(x,y)
	end
end
function WIDGET.keyPressed(k)
	local W=WIDGET.sel
	if k=="space"or k=="return"then
		WIDGET.press()
	elseif kb.isDown("lshift","lalt","lctrl")and(k=="left"or k=="right")then
					--When hold [↑], control slider with left/right
		if W and W.type=='slider'or W.type=='selector'then
			W:arrowKey(k=="left")
		end
	elseif k=="up"or k=="down"or k=="left"or k=="right"then
		if not W then
			for _,w in next,WIDGET.active do
				if not w.hide and w.isAbove then
					WIDGET.focus(w)
					return
				end
			end
			return
		end
		if not W.getCenter then return end
		local WX,WY=W:getCenter()
		local dir=(k=="right"or k=="down")and 1 or -1
		local tar
		local minDist=1e99
		local swap_xy=k=="up"or k=="down"
		if swap_xy then WX,WY=WY,WX end -- note that we do not swap them back later
		for _,W1 in ipairs(WIDGET.active)do
			if W~=W1 and W1.resCtr and not W1.hide then
				local L=W1.resCtr
				for j=1,#L,2 do
					local x,y=L[j],L[j+1]
					if swap_xy then x,y=y,x end -- note that we do not swap them back later
					local dist=(x-WX)*dir
					if dist>10 then
						dist=dist+abs(y-WY)*6.26
						if dist<minDist then
							minDist=dist
							tar=W1
						end
					end
				end
			end
		end
		if tar then
			WIDGET.focus(tar)
		end
	else
		if W and W.type=='inputBox'then
			W:keypress(k)
		end
	end
end
function WIDGET.textinput(texts)
	local W=WIDGET.sel
	if W and W.type=='inputBox'then
		if not W.regex or texts:match(W.regex)then
			WIDGET.sel.value=WIDGET.sel.value..texts
			SFX.play('move')
		else
			SFX.play('finesseError',.3)
		end
	end
end
local keyMirror={
	dpup="up",
	dpdown="down",
	dpleft="left",
	dpright="right",
	start="return",
	back="escape",
}
function WIDGET.gamepadPressed(i)
	if i=="start"then
		WIDGET.press()
	elseif i=="a"or i=="b"then
		local W=WIDGET.sel
		if W then
			if W.type=='button'or W.type=='key'then
				WIDGET.press()
			elseif W.type=='slider'then
				local p=W.disp()
				local P=i=="left"and(p>0 and p-1)or p<W.unit and p+1
				if p==P or not P then return end
				W.code(P)
				if W.change and TIME()-W.lastTime>.18 then
					W.lastTime=TIME()
					W.change()
				end
			end
		end
	elseif i=="dpup"or i=="dpdown"or i=="dpleft"or i=="dpright"then
		WIDGET.keyPressed(keyMirror[i])
	end
end

function WIDGET.update()
	for _,W in next,WIDGET.active do
		if W.hideF then
			local h=W.hideF()
			if h~=W.hide then
				W.hide=h
			end
		end
		if W.update then W:update()end
	end
end
function WIDGET.draw()
	for _,W in next,WIDGET.active do
		if not W.hide then
			W:draw()
		end
	end
end

return WIDGET