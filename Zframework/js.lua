__requestQueue = {}
_requestCount = 0
_Request = 
{
    command = "",
    currentTime = 0,
    timeOut = 2,
    id = '0'
}
local os = love.system.getOS()
local __defaultErrorFunction = nil
local isDebugActive = false

JS = {}

function JS.callJS(funcToCall)
    if(os == "Web") then
        print("callJavascriptFunction " .. funcToCall)
    end
end

--You can pass a set of commands here and, it is a syntactic sugar for executing many commands inside callJS, as it only calls a function
--If you pass arguments to the func beyond the string, it will perform automatically string.format
--Return statement is possible inside this structure
--This will return a string containing a function to be called by JS.callJS
local _unpack
if(_VERSION == "Lua 5.1" or _VERSION == "LuaJIT") then
    _unpack = unpack
else
    _unpack = table.unpack
end
function JS.stringFunc(str, ...)
    str = "(function(){"..str.."})()"
    if(#arg > 0) then
        str = str:format(_unpack(arg))
    end
    str = str:gsub("[\n\t]", "")
    return str
end

--The call will store in the webDB the return value from the function passed
--it timeouts
local function retrieveJS(funcToCall, id)
    --Used for retrieveData function
    JS.callJS("FS.writeFile('"..love.filesystem.getSaveDirectory().."/__temp"..id.."', "..funcToCall..");")
end

--Call JS.newRequest instead
function _Request:new(isPromise, command, onDataLoaded, onError, timeout, id)
    local obj = {}
    setmetatable(obj, self)
    obj.command = command
    obj.onError = onError or __defaultErrorFunction
    if not isPromise then
        retrieveJS(command, id) 
    else
        JS.callJS(command)
    end
    obj.onDataLoaded = onDataLoaded
    obj.timeOut = (timeout == nil) and obj.timeOut or timeout
    obj.id = id


    function obj:getData()
        --Try to read from webdb
        return love.filesystem.read("__temp"..self.id)
    end

    function obj:purgeData()
        --Data must be purged for not allowing old data to be retrieved
        love.filesystem.remove("__temp"..self.id)
    end

    function obj:update(dt)
        self.timeOut = self.timeOut - dt
        local retData = self:getData()

        if((retData ~= nil and retData ~= "nil") or self.timeOut <= 0) then
            if(retData ~= nil and retData:match("ERROR") == nil) then
                if isDebugActive then
                    print("Data has been retrieved "..retData)
                end
                self.onDataLoaded(retData)
            else
                self.onError(self.id, retData)
            end
            self:purgeData()
            return false
        else
            return true
        end
    end
    return obj
end

--Place this function on love.update and set it to return if it returns false (This API is synchronous)
function JS.retrieveData(dt)
    local isRetrieving = #__requestQueue ~= 0
    local deadRequests = {}
    for i = 1, #__requestQueue do
        local isUpdating =__requestQueue[i]:update(dt)
        if not isUpdating then
            table.insert(deadRequests, i)
        end
    end
    for i = 1, #deadRequests do
        if(isDebugActive) then
            print("Request died: "..deadRequests[i])
        end
        table.remove(__requestQueue, deadRequests[i])
    end
    return isRetrieving
end

--May only be used for functions that don't return a promise
function JS.newRequest(funcToCall, onDataLoaded, onError, timeout, optionalId)
    if(os ~= "Web") then
        return
    end
    table.insert(__requestQueue, _Request:new(false, funcToCall, onDataLoaded, onError, timeout or 5, optionalId or _requestCount))
end

--This function can be handled manually (in JS code)
    --How to: add the function call when your events resolve: FS.writeFile("Put love.filesystem.getSaveDirectory here", "Pass a string here (NUMBER DONT WORK"))
--Or it can be handled by Lua, it auto sets your data if you write the following command:
    -- _$_(yourStringOrFunctionHere)
function JS.newPromiseRequest(funcToCall, onDataLoaded, onError, timeout, optionalId)
    if(os ~= "Web") then
        return
    end
    optionalId = optionalId or _requestCount
    funcToCall = funcToCall:gsub("_$_%(", "FS.writeFile('"..love.filesystem.getSaveDirectory().."/__temp"..optionalId.."', ")
    table.insert(__requestQueue, _Request:new(true, funcToCall, onDataLoaded, onError, timeout or 5, optionalId))
end


--It receives the ID from ther request
--Don't try printing the request.command, as it will execute the javascript command
function JS.setDefaultErrorFunction(func)
    __defaultErrorFunction = func
end

JS.setDefaultErrorFunction(function(id, error)
    if( isDebugActive ) then
        local msg = "Data could not be loaded for id:'"..id.."'"
        if(error)then
            msg = msg.."\nError: "..error
        end
        print(msg)
    end
end)


JS.callJS(JS.stringFunc(
    [[
        __getWebDB("%s");
    ]]
, "__LuaJSDB"))
