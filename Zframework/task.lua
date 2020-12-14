local rem=table.remove
local ct=coroutine
local assert=assert
local tasks={}

local TASK={
	netTaskCount=0,
}
function TASK.getCount()
	return #tasks
end
function TASK.update()
	for i=#tasks,1,-1 do
		local T=tasks[i]
		assert(ct.resume(T.thread))
		if ct.status(T.thread)=="dead"then
			if T.net then
				TASK.netTaskCount=TASK.netTaskCount-1
			end
			rem(tasks,i)
		end
	end
end
function TASK.new(code,...)
	local thread=ct.create(code)
	if ...~=nil then ct.resume(thread,...)end
	if ct.status(thread)~="dead"then
		tasks[#tasks+1]={
			thread=thread,
			code=code,
		}
	end
end
function TASK.newNet(code,...)
	local thread=ct.create(code)
	if ...~=nil then ct.resume(thread,...)end
	if ct.status(thread)~="dead"then
		tasks[#tasks+1]={
			thread=thread,
			code=code,
			net=true,
		}
	end
end
function TASK.changeCode(c1,c2)
	for i=#tasks,1,-1 do
		if tasks[i].thread==c1 then
			tasks[i].thread=c2
		end
	end
end
function TASK.removeTask_code(code)
	for i=#tasks,1,-1 do
		if tasks[i].code==code then
			rem(tasks,i)
		end
	end
end
function TASK.removeTask_data(data)
	for i=#tasks,1,-1 do
		if tasks[i].data==data then
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