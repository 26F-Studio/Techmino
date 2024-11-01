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

if WEB_COMPAT_MODE then
    local _clipboardBuffer=''
    return {
        get=function ()
            JS.newPromiseRequest(
                JS.stringFunc(
                    [[
                        window.navigator.clipboard
                            .readText()
                            .then((text) => _$_(text))
                            .catch((e) => {
                                console.warn(e);
                                _$_('');
                            });
                    ]]
                ),
                function(data) _clipboardBuffer=data end,
                function(id, error) print(id, error) end,
                3,
                'getClipboardText'
            )
            return _clipboardBuffer
        end,
        set=function (str)
            JS.callJS(JS.stringFunc(
                [[
                    window.navigator.clipboard
                        .writeText('%s')
                        .then(() => console.log('Copied to clipboard'))
                        .catch((e) => console.warn(e));
                ]],
                _sanitize(str)
            ))
        end,
        _update=NULL,
    }
end

local clipboard_thread=love.thread.newThread('Zframework/clipboard_thread.lua')
local getCHN=love.thread.newChannel()
local setCHN=love.thread.newChannel()
local triggerCHN=love.thread.newChannel()

clipboard_thread:start(getCHN,setCHN,triggerCHN)

return{
    get=function() return getCHN:peek() or '' end,
    set=function(content) setCHN:push(_sanitize(content)) end,
    _update=function()
        triggerCHN:push(0)
        local error = clipboard_thread:getError()
        if error then
            MES.new('error',error)
            MES.traceback()
        end
    end,
}
