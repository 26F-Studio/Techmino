local getCHN=love.thread.getChannel('CLIP_get')
local setCHN=love.thread.getChannel('CLIP_set')
local trigCHN=love.thread.getChannel('CLIP_trig')

JS=require'Zframework.js'
local sleep=require'love.timer'.sleep

local retrieving=false
while true do
    if trigCHN:getCount()>0 then
        local dt = trigCHN:pop()
        if setCHN:getCount()>0 then
            while setCHN:getCount()>1 do setCHN:pop() end
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
                    while getCHN:getCount()>0 do getCHN:pop() end
                    getCHN:push(data)
                    retrieving=false
                end,
                function() retrieving=false end,
                1,
                'getClipboardText'
            )
            retrieving=true
        end
        JS.retrieveData(dt)
    end
    sleep(.001)
end
