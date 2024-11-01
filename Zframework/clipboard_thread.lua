local getCHN,setCHN,triggerCHN=...

local CHN_demand,CHN_getCount=triggerCHN.demand,triggerCHN.getCount
local CHN_push,CHN_pop=triggerCHN.push,triggerCHN.pop

print("2");
JS=require'Zframework.js'
print("3");

local yield=coroutine.yield
local setThread=coroutine.wrap(function()
    while true do
        JS.callJS(JS.stringFunc(
            [[
                window.navigator.clipboard
                    .writeText('%s')
                    .then(() => console.log('Copied to clipboard'))
                    .catch((e) => console.warn(e));
            ]],
            CHN_pop(setCHN)
        ))
        yield()
    end
end)

local getThread=coroutine.wrap(function()
    while true do
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
            function(data) 
                while getCHN:getCount()>0 do
                    CHN_pop(getCHN)
                end
                CHN_push(getCHN, data)
            end,
            function(id, error) print(id, error) end,
            2,
            'getClipboardText'
        )
        yield()
    end
end)

local success,err

while true do-- Running
    CHN_demand(triggerCHN)
    if CHN_getCount(setCHN)>0 then
        while CHN_getCount(setCHN)>1 do
            CHN_pop(setCHN)
        end
        print('Running setThread')
        setThread()
    end
    print('Running getThread')
    getThread()
end
