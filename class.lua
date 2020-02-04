Task={}
local rem=table.remove

metatable_task={__index=Task}
function newTask(code,P,data)
	local id=#Task+1
	local obj={
		code=code,
		P=P,
		data=data,
		id=id,
	}
	setmetatable(obj,metatable_task)
	Task[id]=obj
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