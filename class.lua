local rem=table.remove
Task={}
function Task:update()
	if(not self.P or self.P and scene=="play")and self:code(self.P,self.data)then
		local e=#Task
		for i=1,e do
			if Task[i]==self then
				Task[e],Task[i]=nil,Task[e]
				return
			end
		end
	end
end
function newTask(code,P,data)
	Task[#Task+1]={
		update=Task.update,

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

function newButton(x,y,w,h,color,font,code,hide,up,down,left,right)
	return{
		type="button",
		x=x-w*.5,y=y-h*.5,w=w,h=h,
		color=color,font=font,
		code=code,hide=hide,
		up=up,down=down,left=left,right=right,
	}
end
function newSlider(x,y,w,unit,color,font,code,hide,up,down,left,right)
	return{
		type="slider",
		x=x,y=y,w=w,unit=unit,
		color=color,font=font,
		code=code,hide=hide,
		up=up,down=down,left=left,right=right,
	}
end