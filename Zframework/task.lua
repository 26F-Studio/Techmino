local rem=table.remove
local ct=coroutine
local assert=assert
local tasks={}

local TASK={}
function TASK.getCount()
	return #tasks
end
function TASK.update()
	for i=#tasks,1,-1 do
		local T=tasks[i]
		assert(ct.resume(T.thread))
		if ct.status(T.thread)=="dead"then
		rem(tasks,i)
		end
	end
end
function TASK.new(code,...)
	local thread=ct.create(code)
	ct.resume(thread,...)
	if ct.status(thread)~="dead"then
		tasks[#tasks+1]={
			thread=thread,
			code=code,
			args={...},
		}
	end
end
function TASK.removeTask_code(code)
	for i=#tasks,1,-1 do
		if tasks[i].code==code then
			rem(tasks,i)
		end
	end
end
function TASK.removeTask_iterate(func,...)
	for i=#tasks,1,-1 do
		if func(tasks[i],...)then
			rem(tasks,i)
		end
	end
end
function TASK.clear()
	local i=#tasks
	while i>0 do
		tasks[i]=nil
		i=i-1
	end
end
return TASK