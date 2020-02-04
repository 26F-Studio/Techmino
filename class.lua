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

local button={type="button"}
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
function button:isAbove(x,y)
	return x>self.x and x<self.x+self.w and y>self.y and y<self.y+self.h
end
function button:FX()
	sysFX[#sysFX+1]={0,0,10,self.x,self.y,self.w,self.h}
	--[0=ripple],timer,duration,x,y,w,h
end
function button:draw()
	local C=self.color
	gc.setColor(C)
	gc.setLineWidth(3)gc.rectangle("line",self.x,self.y,self.w,self.h,4)
	gc.setColor(C[1],C[2],C[3],.4)
	gc.setLineWidth(5)gc.rectangle("line",self.x,self.y,self.w,self.h,4)
	if self==widget_sel then
		gc.rectangle("fill",self.x,self.y,self.w,self.h,4)
	end--Highlight when Selected
	local t=self.text
	if t then
		if type(t)=="function"then t=t()end
		setFont(self.font)
		local y0=self.y+self.h*.5-self.font*.7
		gc.printf(t,self.x-2,y0-1,self.w,"center")
		gc.setColor(C)
		gc.printf(t,self.x,y0,self.w,"center")
	end
end
function button:getInfo()
	print(format("x=%d,y=%d,w=%d,h=%d,font=%d",self.x+self.w*.5,self.y+self.h*.5,self.w,self.h,self.font))
end

local switch={type="switch"}
function newSwitch(x,y,font,disp,code,hide,N)
	local _={
		x=x,y=y,font=font,
		disp=disp,
		code=code,
		hide=hide,
		next=N,
	}for k,v in next,switch do _[k]=v end return _
end
function switch:isAbove(x,y)
	return x>self.x and x<self.x+100 and y>self.y-20 and y<self.y+20
end
function switch:FX()
	sysFX[#sysFX+1]=self.disp()and
	{1,0,15,1,.4,.4,self.x,self.y-20,50,40,0}--Switched on
	or{1,0,15,.4,1,.4,self.x+50,self.y-20,50,40,0}--Switched off
	--[1=square fade],timer,duration,r,g,b,x,y,w,h
end
function switch:draw()
	local x,y=self.x,self.y-20
	if self.disp()then
		gc.setColor(.6,1,.6)
		gc.rectangle("fill",x+50,y,50,40,3)
		--ON
	else
		gc.setColor(1,.6,.6)
		gc.rectangle("fill",x,y,50,40,3)
		--OFF
	end--switch
	gc.setColor(1,1,1,self==widget_sel and 1 or .6)
	gc.setLineWidth(3)gc.rectangle("line",x-3,y-3,106,46,5)
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

local slider={type="slider"}
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
function slider:isAbove(x,y)
	return x>self.x-10 and x<self.x+self.w+10 and y>self.y-20 and y<self.y+20
end
function slider:FX(pos)
	sysFX[#sysFX+1]={1,0,10,1,1,1,self.x+self.w*pos/self.unit-8,self.y-15,17,30}
	--[1=square fade],timer,duration,r,g,b,x,y,w,h
end
function slider:draw()
	local S=self==widget_sel
	gc.setColor(1,1,1,S and 1 or .5)
	gc.setLineWidth(2)
	local x1,x2=self.x,self.x+self.w
	for p=0,self.unit do
		local x=x1+(x2-x1)*p/self.unit
		gc.line(x,self.y+7,x,self.y-7)
	end
	--units
	gc.setLineWidth(5)
	gc.line(x1,self.y,x2,self.y)
	--axis
	gc.setColor(1,1,1)
	gc.rectangle("fill",x1+(x2-x1)*self.disp()/self.unit-8,self.y-15,17,30)
	--block
	local t=self.text
	if t then
		gc.setColor(1,1,1)
		setFont(self.font)
		gc.printf(t,self.x-312,self.y-self.font*.7,300,"right")
	end
end
function slider:getInfo()
	print(format("x=%d,y=%d,w=%d",self.x,self.y,self.w))
end