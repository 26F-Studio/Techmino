Task={}
metatable_task={__index=Task}
function newTask(code,P,data)
	local obj={
		code=code,
		P=P,
		data=data,
	}
	setmetatable(obj,metatable_task)
	ins(Task,obj)
end
function clearTask(opt)
	if opt=="all"then
		while Task[1]do
			rem(Task,i)
		end
	elseif opt=="play"then
		for i=#Task,1,-1 do
			if Task[i].P then
				rem(Task,i)
			end
		end
	else--Player table
		for i=#Task,1,-1 do
			if Task[i].P==P then
				rem(Task,i)
			end
		end
	end
end
function Task:update()
	if(not self.P or self.P and scene=="play")and self.code(self.P,self.data)then
		self:destroy()
		return nil
	end
end
function Task:destroy()
	for i=#Task,1,-1 do
		if Task[i]==self then
			rem(Task,i)
			return nil
		end
	end
end