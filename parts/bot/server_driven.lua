local yield=coroutine.yield
local bot_serverDriven={}
function bot_serverDriven.thread() while true do yield() end end
bot_serverDriven.update=NULL
bot_serverDriven.lockWrongPlace=NULL
return bot_serverDriven