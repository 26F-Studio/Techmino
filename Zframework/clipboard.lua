local function _sanitize(content)
    if type(content)=='boolean' then
        content=content and 'true' or 'false'
    end
    if type(content)=='nil' then
        content=''
    end
    if type(content)=='number' then
        content=tostring(content)
    end
    if type(content)~='string' then
        MES.new('error',"Invalid content type!")
        MES.traceback()
        return ''
    end
    return content
end

if SYSTEM~='Web' then
    local get = love.system.getClipboardText
    local set = love.system.setClipboardText
    return {
        get=function() return get() or '' end,
        set=function(content) set(_sanitize(content)) end,
        _update=NULL,
    }
end

local clipboard_thread=love.thread.newThread('Zframework/clipboard_thread.lua')
local getCHN=love.thread.newChannel()
local setCHN=love.thread.newChannel()
local triggerCHN=love.thread.newChannel()

TASK.new(function() TEST.yieldN(26); print("1"); clipboard_thread:start(getCHN,setCHN,triggerCHN) end)

local clipboard={}

function clipboard.get()
    return getCHN:peek() or ''
end

function clipboard.set(content)
    setCHN:push(_sanitize(content))
end

function clipboard._update()
    triggerCHN:push(0)
    local error = clipboard_thread:getError()
    if error then
        MES.new('error',error)
        MES.traceback()
        clipboard._update=NULL
    end
end

return clipboard