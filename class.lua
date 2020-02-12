local gc=love.graphics
local rem=table.remove
local format=string.format
Task={}
function newTask(code,P,data)
	Task[#Task+1]={
		code=code,
		P=P,
		data=data,
	}
end
function clearTask(opt)
	if opt=="all"then
		local i=#Task
		while i>0 do
			Task[i]=nil
			i=i-1
		end
	elseif opt=="play"then
		for i=#Task,1,-1 do
			if Task[i].P then
				rem(Task,i)
			end
		end
	else--Player table
		for i=#Task,1,-1 do
			if Task[i].P==opt then
				rem(Task,i)
			end
		end
	end
end

local button={
	type="button",
	ATV=0,--activating time(0~8)
}
function newButton(x,y,w,h,color,font,code,hide,N)
	local _={
		x=x-w*.5,y=y-h*.5,
		w=w,h=h,
		color=color,
		font=font,
		code=code,
		hide=hide,
		next=N,
	}for k,v in next,button do _[k]=v end return _
end
function button:reset()
	self.ATV=0
end
function button:isAbove(x,y)
	return x>self.x-self.ATV and x<self.x+self.w+2*self.ATV and y>self.y-self.ATV and y<self.y+self.h+2*self.ATV
end
function button:FX()
	sysFX[#sysFX+1]={0,0,10,self.x-self.ATV,self.y-self.ATV,self.w+2*self.ATV,self.h+2*self.ATV}
	--0[ripple],timer,duration,x,y,w,h
end
function button:update()
	if widget_sel==self then
		if self.ATV<8 then self.ATV=self.ATV+1 end
	else
		if self.ATV>0 then self.ATV=self.ATV-1 end
	end
end
function button:draw()
	local x,y,w,h=self.x,self.y,self.w,self.h
	local r,g,b=unpack(self.color)
	gc.setColor(.2+r*.8,.2+g*.8,.2+b*.8,.7)
	gc.rectangle("fill",x-self.ATV,y-self.ATV,w+2*self.ATV,h+2*self.ATV)
	if self.ATV>0 then
		gc.setLineWidth(4)
		gc.setColor(1,1,1,self.ATV*.125)
		gc.rectangle("line",x-self.ATV+2,y-self.ATV+2,w+2*self.ATV-4,h+2*self.ATV-4)
	end
	local t=self.text
	if t then
		if type(t)=="function"then t=t()end
		setFont(self.font)
		local y0=y+h*.5-self.font*.7
		gc.setColor(1,1,1,.3)
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
	ATV=0,--activating time(0~8)
	CHK=0,--check alpha(0~6)
}
function newSwitch(x,y,font,disp,code,hide,N)
	local _={
		x=x,y=y,font=font,
		disp=disp,
		code=code,
		hide=hide,
		next=N,
	}for k,v in next,switch do _[k]=v end return _
end
function switch:reset()
	self.ATV=0
	self.CHK=0
end
function switch:isAbove(x,y)
	return x>self.x and x<self.x+50 and y>self.y-25 and y<self.y+25
end
function switch:update()
	local _=self.ATV
	if widget_sel==self then if _<8 then self.ATV=_+1 end
	else if _>0 then self.ATV=_-1 end
	end
	_=self.CHK
	if self:disp()then if _<6 then self.CHK=_+1 end
	else if _>0 then self.CHK=_-1 end
	end
end
function switch:draw()
	local x,y=self.x,self.y-25
	if self.ATV>0 then
		gc.setColor(1,1,1,self.ATV*.08)
		gc.rectangle("fill",x,y,50,50)
	end
	if self.CHK>0 then
		gc.setColor(.9,1,.9,self.CHK/6)
		gc.setLineWidth(6)
		gc.line(x+5,y+25,x+18,y+38,x+45,y+11)
	end
	--checked
	gc.setLineWidth(4)
	gc.setColor(1,1,1,.6+self.ATV*.05)
	gc.rectangle("line",x,y,50,50)
	--frame
	local t=self.text
	if t then
		gc.setColor(1,1,1)
		setFont(self.font)
		gc.printf(t,x-412,y+20-self.font*.7,400,"right")
	end
end
function switch:getInfo()
	print(format("x=%d,y=%d,font=%d",self.x,self.y,self.font))
end

local slider={
	type="slider",
	ATV=0,--activating time(0~8)
	pos=0,--position shown
}
function newSlider(x,y,w,unit,font,change,disp,code,hide,N)
	local _={
		x=x,y=y,
		w=w,unit=unit,
		font=font,
		change=change,
		disp=disp,
		code=code,
		hide=hide,
		next=N,
	}for k,v in next,slider do _[k]=v end return _
end
function slider:reset()
	self.ATV=0
	self.pos=0
end
function slider:isAbove(x,y)
	return x>self.x-10 and x<self.x+self.w+10 and y>self.y-20 and y<self.y+20
end
function slider:update()
	if widget_sel==self then
		if self.ATV<6 then self.ATV=self.ATV+1 end
	else
		if self.ATV>0 then self.ATV=self.ATV-1 end
	end
	if not(self.hide and self.hide())then
		self.pos=self.pos*.7+self.disp()*.3
	end
end
function slider:draw()
	local x,y=self.x,self.y
	gc.setColor(1,1,1,.5+self.ATV*.06)
	gc.setLineWidth(2)
	local x1,x2=x,x+self.w
	for p=0,self.unit do
		local x=x1+(x2-x1)*p/self.unit
		gc.line(x,y+7,x,y-7)
	end
	--units
	gc.setLineWidth(4)
	gc.line(x1,y,x2,y)
	--axis
	local t=self.text
	if t then
		gc.setColor(1,1,1)
		setFont(self.font)
		gc.printf(t,x-312,y-self.font*.7,300,"right")
	end
	--text
	local x,y,w,h=x1+(x2-x1)*self.pos/self.unit-10-self.ATV*.5,y-16-self.ATV,20+self.ATV,32+2*self.ATV
	gc.setColor(.8,.8,.8)
	gc.rectangle("fill",x,y,w,h)
	if self.ATV>0 then
		gc.setLineWidth(2)
		gc.setColor(1,1,1,self.ATV*.16)
		gc.rectangle("line",x+1,y+1,w-2,h-2)
	end
	--block
end
function slider:getInfo()
	print(format("x=%d,y=%d,w=%d",self.x,self.y,self.w))
end