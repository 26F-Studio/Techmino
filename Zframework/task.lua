local rem=table.remove
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
		if T.code(T.data)then
			if T.data.net then
				TASK.netTaskCount=TASK.netTaskCount-1
			end
			rem(tasks,i)
		end
	end
end
function TASK.new(code,data)
	tasks[#tasks+1]={
		code=code,
		data=data,
	}
end
function TASK.changeCode(c1,c2)
	for i=#tasks,1,-1 do
		if tasks[i].code==c1 then
			tasks[i].code=c2
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