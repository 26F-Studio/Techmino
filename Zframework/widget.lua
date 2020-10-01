local gc=love.graphics
local kb=love.keyboard
local int,abs=math.floor,math.abs
local max,min=math.max,math.min
local format=string.format
local color=color
local setFont=setFont
local Timer=love.timer.getTime

local text={
	type="text",
}
function text:reset()
	if type(self.text)=="string"then
		self.text=gc.newText(setFont(self.font or 30),self.text)
	end
end
function text:draw()
	gc.setColor(self.color)
	gc.draw(self.text,self.x,self.y)
end

local image={
	type="image",
}
function image:reset()
	if type(self.img)=="string"then
		self.img=IMG[self.img]
	end
end
function image:draw()
	gc.setColor(1,1,1,self.alpha)
	gc.draw(self.img,self.x,self.y,self.ang,self.kx,self.ky,self.ox,self.oy)
end

local button={
	type="button",
	ATV=0,--Activating time(0~8)
}
function button:reset()
	self.ATV=0
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
function button:FX()
	local ATV=self.ATV
	sysFX.newRectRipple(
		.16,
		self.x-ATV,
		self.y-ATV,
		self.w+2*ATV,
		self.h+2*ATV
		,5
	)
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
	local r,g,b=unpack(self.color)
	gc.setColor(.2+r*.8,.2+g*.8,.2+b*.8,.7)
	gc.rectangle("fill",x-ATV,y-ATV,w+2*ATV,h+2*ATV)
	if ATV>0 then
		gc.setLineWidth(4)
		gc.setColor(1,1,1,ATV*.125)
		gc.rectangle("line",x-ATV+2,y-ATV+2,w+2*ATV-4,h+2*ATV-4)
	end
	local t=self.text
	if t then
		if type(t)=="function"then t=t()end
		setFont(self.font)
		local y0=y+h*.5-self.font*.7-ATV*.5
		gc.setColor(1,1,1,.2+ATV*.05)
		gc.printf(t,x-2,y0-2,w,"center")
		gc.printf(t,x-2,y0+2,w,"center")
		gc.printf(t,x+2,y0-2,w,"center")
		gc.printf(t,x+2,y0+2,w,"center")
		gc.setColor(r*.5,g*.5,b*.5)
		gc.printf(t,x,y0,w,"center")
	end
end
function button:getInfo()
	return format("x=%d,y=%d,w=%d,h=%d,font=%d",self.x+self.w*.5,self.y+self.h*.5,self.w,self.h,self.font)
end

local key={
	type="key",
	ATV=0,--Activating time(0~4)
}
function key:reset()
	self.ATV=0
end
function key:isAbove(x,y)
	local ATV=self.ATV
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
	local r,g,b=unpack(self.color)

	gc.setColor(1,1,1,ATV*.125)
	gc.rectangle("fill",x,y,w,h)

	gc.setColor(.2+r*.8,.2+g*.8,.2+b*.8,.7)
	gc.setLineWidth(4)
	gc.rectangle("line",x,y,w,h)

	local t=self.text
	if t then
		if type(t)=="function"then t=t()end
		setFont(self.font)
		gc.setColor(r,g,b,1.2)
		gc.printf(t,x,y+h*.5-self.font*.7,w,"center")
	end
end
function key:getInfo()
	return format("x=%d,y=%d,w=%d,h=%d,font=%d",self.x+self.w*.5,self.y+self.h*.5,self.w,self.h,self.font)
end

local switch={
	type="switch",
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
	chk=self.CHK
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
		gc.rectangle("fill",x,y,50,50)
	end
	if self.CHK>0 then
		gc.setColor(.9,1,.9,self.CHK/6)
		gc.setLineWidth(6)
		gc.line(x+5,y+25,x+18,y+38,x+45,y+11)
	end

	--Frame
	gc.setLineWidth(4)
	gc.setColor(1,1,1,.6+ATV*.05)
	gc.rectangle("line",x,y,50,50)

	--Text
	local t=self.text
	if t then
		gc.setColor(1,1,1)
		setFont(self.font)
		gc.printf(t,x-412-ATV,y+20-self.font*.7,400,"right")
	end
end
function switch:getInfo()
	return format("x=%d,y=%d,font=%d",self.x,self.y,self.font)
end

local slider={
	type="slider",
	ATV=0,--Activating time(0~8)
	TAT=0,--Text activating time(0~180)
	pos=0,--Position shown
}
local sliderShowFunc={
	none=NULL,
	int=function(S)
		return S.disp()
	end,
	float=function(S)
		return int(S.disp()*100)*.01
	end,
	percent=function(S)
		return int(S.disp()*100).."%"
	end,
	frame_time=function(S)
		S=S.disp()
		return S.."F "..int(S*16.67).."ms"
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
	if not(self.hide and self.hide())then
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
			local x=x+(x2-x)*p/self.unit
			gc.line(x,y+7,x,y-7)
		end
	end

	--Axis
	gc.setLineWidth(4)
	gc.line(x,y,x2,y)

	--Block
	local cx=x+(x2-x)*self.pos/self.unit
	local bx,by,bw,bh=cx-10-ATV*.5,y-16-ATV,20+ATV,32+2*ATV
	gc.setColor(.8,.8,.8)
	gc.rectangle("fill",bx,by,bw,bh)

	local t
	if ATV>0 then
		gc.setLineWidth(2)
		gc.setColor(1,1,1,ATV*.16)
		gc.rectangle("line",bx+1,by+1,bw-2,bh-2)
	end
	if self.TAT>0 and self.show then
		setFont(25)
		gc.setColor(1,1,1,self.TAT/180)
		mStr(self:show(),cx,by-30)
	end

	--Text
	t=self.text
	if t then
		gc.setColor(1,1,1)
		setFont(self.font)
		gc.printf(t,x-312-ATV,y-self.font*.7,300,"right")
	end
end
function slider:getInfo()
	return format("x=%d,y=%d,w=%d",self.x,self.y,self.w)
end

local selector={
	type="selector",
	ATV=8,--Activating time(0~4)
	select=0,--Selected item ID
	selText=nil,--Selected item name
}
function selector:reset()
	self.ATV=0
	local V=self.disp()
	local L=self.list
	for i=1,#L do
		if L[i]==V then
			self.select=i
			self.selText=self.list[i]
			break
		end
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
	local r,g,b=unpack(self.color)
	local w=self.w
	local ATV=self.ATV

	gc.setColor(1,1,1,.6+ATV*.1)
	gc.setLineWidth(3)
	gc.rectangle("line",x,y,w,60)

	gc.setColor(1,1,1,.2+ATV*.1)
	local t=(Timer()%.5)^.5
	if self.select>1 then
		gc.draw(drawableText.small,x+6,y+20)
		if ATV>0 then
			gc.setColor(1,1,1,ATV*.4*(.5-t))
			gc.draw(drawableText.small,x+6-t*40,y+20)
			gc.setColor(1,1,1,.2+ATV*.1)
		end
	end
	if self.select<#self.list then
		gc.draw(drawableText.large,x+w-24,y+20)
		if ATV>0 then
			gc.setColor(1,1,1,ATV*.4*(.5-t))
			gc.draw(drawableText.large,x+w-24+t*40,y+20)
		end
	end

	setFont(28)
	t=self.text
	if t then
		if type(t)=="function"then t=t()end
		gc.setColor(r,g,b)
		mStr(self.text,x+w*.5,y+17-21)
	end
	gc.setColor(1,1,1)
	mStr(self.selText,x+w*.5,y+43-21)
end
function selector:getInfo()
	return format("x=%d,y=%d,w=%d",self.x,self.y,self.w)
end

local keyboardNames={--15*5 keys
	"ESC","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12","","Del",
	"1","2","3","4","5","6","7","8","9","0","-","=","","<X","<X",
	"Q","W","E","R","T","Y","U","I","O","P","[","]","Rtn","Rtn","PgUp",
	"A","S","D","F","G","H","J","K","L","",";","'","/","↑","PgDn",
	"","Z","X","C","V","B","N","M","___","___",",",".","←","↓","→",
}
local keyboardKeys={
	"escape","f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12",nil,"delete",
	"1","2","3","4","5","6","7","8","9","0","-","=",nil,"backspace","backspace",
	"q","w","e","r","t","y","u","i","o","p","[","]","return","return","pgup",
	"a","s","d","f","g","h","j","k","l",nil,";","'","/","up","pgdown",
	nil,"z","x","c","v","b","n","m","space","space",",",".","left","down","right",
}
local keyboard={
	type="keyboard",
}
function keyboard:reset()end
function keyboard:isAbove(x,y)
	return
		x>self.x and
		x<self.x+self.w and
		y>self.y and
		y<self.y+self.h
end
function keyboard:getCenter()
	return self.x+self.w*.5,self.y+self.h*.5
end
function keyboard:update()end
function keyboard:draw()
	local x,y,w,h=self.x,self.y,self.w,self.h
	gc.translate(x,y)

	gc.setColor(0,0,0,.4)
	gc.rectangle("fill",0,0,w,h)

	gc.setColor(1,1,1)
	gc.setLineWidth(3)
	for x=0,w,w/15 do
		gc.line(x,0,x,h)
	end
	for y=0,h,h/5 do
		gc.line(0,y,w,y)
	end

	local mStr=mStr
	for i=0,4 do
		for j=1,15 do
			local s=keyboardNames[15*i+j]
			local f=int((55-7*#s)*w/1200)
			setFont(f)
			mStr(s,(j-.5)*w/15,(i+.5)*h/5-f*.7)
		end
	end

	gc.translate(-x,-y)
end
function keyboard:getInfo()
	return format("x=%d,y=%d,w=%d,h=%d",self.x,self.y,self.w,self.h)
end

local WIDGET={}
WIDGET.active={}--Table contains all active widgets
WIDGET.sel=nil--Selected widget
function WIDGET.set(L)
	WIDGET.sel=nil
	WIDGET.active=L or{}

	--Reset all widgets
	if L then
		for _,W in next,L do
			if W.reset then W:reset()end
		end
	end
end

local widgetMetatable={
	__tostring=function(self)
		return self:getInfo()
	end,
}
function WIDGET.newText(D)
	local _={
		name=	D.name,
		x=		D.x,
		y=		D.y,
		color=	D.color and(color[D.color]or D.color)or color.white,
		hide=	D.hide,
	}
	for k,v in next,text do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end
function WIDGET.newImage(D)
	local _={
		name=	D.name,
		img=	D.img,
		alpha=	D.alpha or 1,
		x=		D.x,
		y=		D.y,
		ang=	D.ang,
		kx=		D.kx,
		ky=		D.ky,
		ox=		D.ox,
		oy=		D.oy,
		hide=	D.hide,
	}
	for k,v in next,image do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end
function WIDGET.newButton(D)
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

		color=	D.color and(color[D.color]or D.color)or color.white,
		font=	D.font or 30,
		code=	D.code,
		hide=	D.hide,
	}
	for k,v in next,button do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end
function WIDGET.newKey(D)
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

		color=	D.color and(color[D.color]or D.color)or color.white,
		font=	D.font or 30,
		code=	D.code,
		hide=	D.hide,
	}
	for k,v in next,key do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end
function WIDGET.newSwitch(D)
	local _={
		name=	D.name,

		x=		D.x,
		y=		D.y,

		resCtr={
			D.x+25,D.y,
		},

		font=	D.font or 30,
		disp=	D.disp,
		code=	D.code,
		hide=	D.hide,
	}
	for k,v in next,switch do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end
function WIDGET.newSlider(D)
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

		unit=	D.unit or 1,
		--smooth=nil,
		font=	D.font or 30,
		change=	D.change,
		disp=	D.disp,
		code=	D.code,
		hide=	D.hide,
		--show=	nil,

		lastTime=0,
	}
	if D.smooth~=nil then
		_.smooth=D.smooth
	else
		_.smooth=_.unit<=1
	end
	if D.show then
		if type(D.show)=="function"then
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
function WIDGET.newSelector(D)
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

		color=	D.color and(color[D.color]or D.color)or color.white,
		list=	D.list,
		disp=	D.disp,
		code=	D.code,
		hide=	D.hide,
	}
	for k,v in next,selector do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end
function WIDGET.newKeyboard(D)
	local _={
		x=		D.x,
		y=		D.y,
		w=		D.w,
		h=		D.h,
		hide=	D.hide,

		resCtr={},
	}
	for k,v in next,keyboard do _[k]=v end
	setmetatable(_,widgetMetatable)
	return _
end

function WIDGET.moveCursor(x,y)
	WIDGET.sel=nil
	for _,W in next,WIDGET.active do
		if not(W.hide and W.hide())and W.resCtr and W:isAbove(x,y)then
			WIDGET.sel=W
			return
		end
	end
end
function WIDGET.press(x,y)
	local W=WIDGET.sel
	if not W then return end
	if W.type=="button"then
		W.code()
		W:FX()
		SFX.play("button")
	elseif W.type=="key"then
		W.code()
		SFX.play("lock")
	elseif W.type=="switch"then
		W.code()
		SFX.play("move")
	elseif W.type=="slider"then
		WIDGET.drag(x,y)
	elseif W.type=="selector"then
		if x then
			local s=W.select
			if x<W.x+W.w*.5 then
				if s>1 then
					s=s-1
					sysFX.newShade(.3,1,1,1,W.x,W.y,W.w*.5,60)
				end
			else
				if s<#W.list then
					s=s+1
					sysFX.newShade(.3,1,1,1,W.x+W.w*.5,W.y,W.w*.5,60)
				end
			end
			if W.select~=s then
				W.code(W.list[s])
				W.select=s
				W.selText=W.list[s]
				SFX.play("prerotate")
			end
		end
	elseif W.type=="keyboard"then
		if x then
			x,y=int((x-W.x)/W.w*15)+1,int((y-W.y)/W.h*5)
			local k=keyboardKeys[15*y+x]
			if k then
				sysFX.newShade(.4,1,1,1,W.x+(x-1)/15*W.w,W.y+y/5*W.h,W.w/15,W.h/5)
				love.keypressed(k)
			end
		end
	end
	if W.hide and W.hide()then WIDGET.sel=nil end
end
function WIDGET.drag(x,y,dx,dy)
	local W=WIDGET.sel
	if not W then return end
	if W.type=="slider"then
		if not x then return end
		x=x-W.x
		local p=W.disp()
		local P=x<0 and 0 or x>W.w and W.unit or x/W.w*W.unit
		if not W.smooth then
			P=int(P+.5)
		end
		if p~=P then
			W.code(P)
		end
		if W.change and Timer()-W.lastTime>.18 then
			W.lastTime=Timer()
			W.change()
		end
	elseif not W:isAbove(x,y)then
		WIDGET.sel=nil
	end
end
function WIDGET.release(x,y)
	local W=WIDGET.sel
	if not W then return end
	if W.type=="slider"then
		W.lastTime=0
		WIDGET.drag(x,y)
	end
	WIDGET.sel=nil
end
function WIDGET.keyPressed(i)
	if i=="space"or i=="return"then
		if WIDGET.sel then
			WIDGET.press()
		end
	elseif kb.isDown("lshift","lalt","lctrl")then
					--When hold [↑], control slider with left/right
		if i=="left"or i=="right"then
			local W=WIDGET.sel
			if W then
				if W.type=="slider"then
					local p=W.disp()
					local u=(W.smooth and .01 or 1)
					local P=i=="left"and max(p-u,0)or min(p+u,W.unit)
					if p==P or not P then return end
					W.code(P)
					if W.change and Timer()-W.lastTime>.18 then
						W.lastTime=Timer()
						W.change()
					end
				elseif W.type=="selector"then
					print(1)
					local s=W.select
					if i=="left"then
						if s>1 then
							s=s-1
							sysFX.newShade(.3,1,1,1,W.x,W.y,W.w*.5,60)
						end
					else
						if s<#W.list then
							s=s+1
							sysFX.newShade(.3,1,1,1,W.x+W.w*.5,W.y,W.w*.5,60)
						end
					end
					if W.select~=s then
						W.code(W.list[s])
						W.select=s
						W.selText=W.list[s]
						SFX.play("prerotate")
					end
				end
			end
		end
	elseif i=="up"or i=="down"or i=="left"or i=="right"then
		if WIDGET.sel then
			local W=WIDGET.sel
			if W.getCenter then
				local WX,WY=W:getCenter()
				local dir=(i=="right"or i=="down")and 1 or -1
				local tar
				local minDist=1e99
				if i=="left"or i=="right"then
					for i=1,#WIDGET.active do
						local W1=WIDGET.active[i]
						if W~=W1 and W1.resCtr then
							local L=W1.resCtr
							for j=1,#L,2 do
								local x,y=L[j],L[j+1]
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
				else
					for i=1,#WIDGET.active do
						local W1=WIDGET.active[i]
						if W~=W1 and W1.resCtr then
							local L=W1.resCtr
							for j=1,#L,2 do
								local x,y=L[j],L[j+1]
								local dist=(y-WY)*dir
								if dist>10 then
									dist=dist+abs(x-WX)*6.26
									if dist<minDist then
										minDist=dist
										tar=W1
									end
								end
							end
						end
					end
				end
				if tar then
					WIDGET.sel=tar
				end
			end
		else
			WIDGET.sel=WIDGET.active[1]
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
		if WIDGET.sel then
			WIDGET.press()
		end
	elseif i=="a"or i=="b"then
		local W=WIDGET.sel
		if W then
			if W.type=="button"or W.type=="key"then
				WIDGET.press()
			elseif W.type=="slider"then
				local p=W.disp()
				local P=i=="left"and(p>0 and p-1)or p<W.unit and p+1
				if p==P or not P then return end
				W.code(P)
				if W.change and Timer()-W.lastTime>.18 then
					W.lastTime=Timer()
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
		if W.update then W:update()end
	end
end
function WIDGET.draw()
	for _,W in next,WIDGET.active do
		if not(W.hide and W.hide())then
			W:draw()
		end
	end
end

return WIDGET