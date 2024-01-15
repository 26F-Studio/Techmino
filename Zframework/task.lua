local rem=table.remove
local assert,resume,status=assert,coroutine.resume,coroutine.status
local rawset=rawset
local timer=love.timer.getTime

local TASK={}

-- Locks
local locks=setmetatable({},{
    __index=function(self,k) rawset(self,k,-1e99)return -1e99 end,
    __newindex=function(self,k) rawset(self,k,-1e99) end,
})
function TASK.lock(name,T)
    if timer()>=locks[name] then
        locks[name]=timer()+(T or 1e99)
        return true
    else
        return false
    end
end
function TASK.unlock(name)
    locks[name]=-1e99
end
function TASK.getLock(name)
    local v=locks[name]-timer()
    return v>0 and v
end
function TASK.clearLock()
    for k in next,locks do
        locks[k]=nil
    end
end

local tasks={}

function TASK.getCount()
    return #tasks
end
local trigFrame=0
function TASK.update(dt)
    trigFrame=trigFrame+dt*60
    for _=1,trigFrame do
        for i=#tasks,1,-1 do
            local T=tasks[i]
            if status(T.thread)=='dead' then
                rem(tasks,i)
            else
                assert(resume(T.thread,dt/trigFrame))
            end
        end
    end
    trigFrame=1
end
function TASK.new(code,...)
    local thread=coroutine.create(code)
    assert(resume(thread,...))
    if status(thread)~='dead' then
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
        if func(tasks[i],...) then
            rem(tasks,i)
        end
    end
end
function TASK.clear()
    TABLE.cut(tasks)
end

return TASK
