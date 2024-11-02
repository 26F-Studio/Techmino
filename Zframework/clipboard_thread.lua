local getCHN=love.thread.getChannel('CLIP_get')
local setCHN=love.thread.getChannel('CLIP_set')
local trigCHN=love.thread.getChannel('CLIP_trig')

JS=require'Zframework.js'
love.timer=require'love.timer'

local retrieving=false
while true do
    if trigCHN:getCount()>0 then
        trigCHN:pop()
        if setCHN:getCount()>0 then
            repeat setCHN:pop() until setCHN:getCount()==1
            -- Set Clipboard
            JS.callJS(JS.stringFunc(
                [[
                    window.navigator.clipboard
                        .writeText('%s')
                        .then(() => console.log('Copied to clipboard'))
                        .catch((e) => console.warn(e));
                ]],
                setCHN:pop()
            ))
        end
        -- Get Clipboard
        if not retrieving then
            JS.newPromiseRequest(
                JS.stringFunc[[
                    window.navigator.clipboard
                        .readText()
                        .then((text) => _$_(text))
                        .catch((e)=>{});
                ]],
                function(data)
                    while getCHN:getCount()>0 do print('getCHN count:', getCHN:getCount()); getCHN:pop() end
                    print('Clipboard:', data)
                    getCHN:push(data)
                    retrieving=false
                end,
                function(id,error) print(id, error) end,
                2,
                'getClipboardText'
            )
            retrieving=true
        end
        JS.retrieveData(.0626)
    end
    love.timer.sleep(.0626)
end
