local gc=love.graphics
local kb=love.keyboard
local int,abs=math.floor,math.abs
local format=string.format
local color=color
local setFont=setFont

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
	sysFX.new(
		"ripple",
		.16,
		self.x-ATV,
		self.y-ATV,
		self.w+2*ATV,
		self.h+2*ATV
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
	print(format("x=%d,y=%d,w=%d,h=%d,font=%d",self.x+self.w*.5,self.y+self.h*.5,self.w,self.h,self.font))
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
	local _=self.ATV
	if WIDGET.sel==self then if _<8 then self.ATV=_+1 end
	else if _>0 then self.ATV=_-.5 end
	end
	_=self.CHK
	if self:disp()then if _<6 then self.CHK=_+1 end
	else if _>0 then self.CHK=_-1 end
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
		gc.printf(t,x-412-ATV,y+20-self.font*.7-ATV*.5,400,"right")
	end
end
function switch:getInfo()
	print(format("x=%d,y=%d,font=%d",self.x,self.y,self.font))
end

local slider={
	type="slider",
	ATV=0,--Activating time(0~8)
	pos=0,--Position shown
}
function slider:reset()
	self.ATV=0
	self.pos=0
end
function slider:isAbove(x,y)
	return x>self.x-10 and x<self.x+self.w+10 and y>self.y-20 and y<self.y+20
end
function slider:getCenter()
	return self.x+self.w*(self.pos/self.unit),self.y
end
function slider:update()
	local _=self.ATV
	if WIDGET.sel==self then
		if _<6 then self.ATV=_+1 end
	else
		if _>0 then self.ATV=_-.5 end
	end
	if not(self.hide and self.hide())then
		self.pos=self.pos*.7+self.disp()*.3
	end
end
function slider:draw()
	local x,y=self.x,self.y
	local ATV=self.ATV

	--Units
	gc.setColor(1,1,1,.5+ATV*.06)
	gc.setLineWidth(2)
	local x1,x2=x,x+self.w
	for p=0,self.unit do
		local x=x1+(x2-x1)*p/self.unit
		gc.line(x,y+7,x,y-7)
	end

	--Axis
	gc.setLineWidth(4)
	gc.line(x1,y,x2,y)

	--Block
	local bx,by,bw,bh=x1+(x2-x1)*self.pos/self.unit-10-ATV*.5,y-16-ATV,20+ATV,32+2*ATV
	gc.setColor(.8,.8,.8)
	gc.rectangle("fill",bx,by,bw,bh)
	if ATV>0 then
		gc.setLineWidth(2)
		gc.setColor(1,1,1,ATV*.16)
		gc.rectangle("line",bx+1,by+1,bw-2,bh-2)
	end

	--Text
	local t=self.text
	if t then
		gc.setColor(1,1,1)
		setFont(self.font)
		gc.printf(t,x-312-ATV,y-self.font*.7-ATV*.5,300,"right")
	end
end
function slider:getInfo()
	print(format("x=%d,y=%d,w=%d",self.x,self.y,self.w))
end

local WIDGET={}
WIDGET.active={}--Table, contains all active widgets
WIDGET.sel=nil--Selected widget
function WIDGET.set(L)
	WIDGET.sel=nil
	WIDGET.active=L or{}
	if L then
		for _,W in next,L do
			W:reset()
		end--Reset all widgets
	end
end

WIDGET.new={}
function WIDGET.newText(D)
	local _={
		name=	D.name,
		x=		D.x,
		y=		D.y,
		align=	D.align,
		color=	color[D.color]or D.color,
		font=	D.font,
		hide=	D.hide,
	}for k,v in next,button do _[k]=v end return _
end
function WIDGET.newImage(D)
	local _={
		name=	D.name,
		x=		D.x-w*.5,
		y=		D.y-h*.5,
		w=		D.w,
		h=		D.h,
		color=	color[D.color]or D.color,
		font=	D.font,
		code=	D.code,
		hide=	D.hide,
	}for k,v in next,button do _[k]=v end return _
end
function WIDGET.newButton(D)
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

		color=	color[D.color]or D.color,
		font=	D.font,
		code=	D.code,
		hide=	D.hide,
	}for k,v in next,button do _[k]=v end return _
end
function WIDGET.newSwitch(D)
	local _={
		name=	D.name,

		x=		D.x,
		y=		D.y,

		cx=		D.x+25,
		cy=		D.y,
		resCtr={
			D.x+25,D.y,
		},

		font=	D.font,
		disp=	D.disp,
		code=	D.code,
		hide=	D.hide,
	}for k,v in next,switch do _[k]=v end return _
end
function WIDGET.newSlider(D)
	local _={
		name=	D.name,

		x=		D.x,
		y=		D.y,
		w=		D.w,

		cx=		D.x+D.w*.5,
		cy=		D.y,
		resCtr={
			D.x,D.y,
			D.x+D.w*.25,D.y,
			D.x+D.w*.5,D.y,
			D.x+D.w*.75,D.y,
			D.x+D.w,D.y,
		},

		unit=	D.unit,
		font=	D.font,
		change=	D.change,
		disp=	D.disp,
		code=	D.code,
		hide=	D.hide,
	}for k,v in next,slider do _[k]=v end return _
end

function WIDGET.moveCursor(x,y)
	WIDGET.sel=nil
	for _,W in next,WIDGET.active do
		if not(W.hide and W.hide())and W:isAbove(x,y)then
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
		VOC.play("nya")
	elseif W.type=="switch"then
		W.code()
		SFX.play("move",.6)
	elseif W.type=="slider"then
		if not x then return end
		local p,P=W.disp(),x<W.x and 0 or x>W.x+W.w and W.unit or int((x-W.x)*W.unit/W.w+.5)
		if p==P then return end
		W.code(P)
		if W.change then W.change()end
	end
	if W.hide and W.hide()then WIDGET.sel=nil end
end
function WIDGET.drag(x,y,dx,dy)
	local W=WIDGET.sel
	if not W then return end
	if W.type=="slider"then
		local p,P=W.disp(),x<W.x and 0 or x>W.x+W.w and W.unit or int((x-W.x)*W.unit/W.w+.5)
		if p==P then return end
		W.code(P)
		if W.change then W.change()end
	elseif not W:isAbove(x,y)then
		WIDGET.sel=nil
	end
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
					local P=i=="left"and(p>0 and p-1)or p<W.unit and p+1
					if p==P or not P then return end
					W.code(P)
					if W.change then W.change()end
				end
			end
		end
	elseif i=="up"or i=="down"or i=="left"or i=="right"then
		if WIDGET.sel then
			local W=WIDGET.sel
			local WX,WY=W:getCenter()
			local dir=(i=="right"or i=="down")and 1 or -1
			local tar
			local minDist=1e99
			if i=="left"or i=="right"then
				for i=1,#WIDGET.active do
					local W1=WIDGET.active[i]
					if W~=W1 then
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
					if W~=W1 then
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
			if W.type=="button"then
				WIDGET.press()
			elseif W.type=="slider"then
				local p=W.disp()
				local P=i=="left"and(p>0 and p-1)or p<W.unit and p+1
				if p==P or not P then return end
				W.code(P)
				if W.change then W.change()end
			end
		end
	elseif i=="dpup"or i=="dpdown"or i=="dpleft"or i=="dpright"then
		WIDGET.keyPressed(keyMirror[i])
	end
end

function WIDGET.update()
	for _,W in next,WIDGET.active do
		W:update()
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