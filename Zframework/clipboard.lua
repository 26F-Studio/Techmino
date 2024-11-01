if SYSTEM~='Web' then
    return {
        get=function () return CLIPBOARD.get() or '' end,
        set=love.system.setClipboardText,
        _update=NULL,
    }
end

local clipboard_thread=love.thread.newThread('Zframework/clipboard_thread.lua')
local getCHN=love.thread.newChannel()
local setCHN=love.thread.newChannel()
local triggerCHN=love.thread.newChannel()

clipboard_thread:start(getCHN,setCHN,triggerCHN)

local clipboard={}

function clipboard.get()
    return getCHN:peek()
end

function clipboard.set(content)
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
    end
    setCHN:push(content)
end

function clipboard._update()
    triggerCHN:push(0)
end

return clipboard