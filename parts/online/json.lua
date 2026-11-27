local base=JSON
local Json={}
local arrays={VK_ORG=true,vkSave1=true,vkSave2=true,customBoards=true,customBoard=true,customMissions=true,customSequence=true,skin=true,face=true,clear=true,spin=true}
local function encode(value,stack,depth,key)
    if depth>16 then error('JSON nesting limit exceeded') end
    if type(value)~='table' then
        if type(value)=='number' and (value~=value or value==math.huge or value==-math.huge) then error('Non-finite JSON number') end
        if type(value)~='string' and type(value)~='number' and type(value)~='boolean' and value~=nil then error('JSON values must be primitive data') end
        local result=base.encode(value)
        if not result then error('Invalid JSON primitive') end
        return result
    end
    if stack[value] then error('Circular JSON value') end
    stack[value]=true
    local result={}
    local isArray=rawget(value,1)~=nil or arrays[key]
    if isArray then
        local count=0
        for index in pairs(value) do
            if type(index)~='number' or index%1~=0 or index<1 then error('Mixed JSON array') end
            count=count+1
        end
        if count~=#value then error('Sparse JSON array') end
        for index=1,#value do result[index]=encode(value[index],stack,depth+1,key=='customBoards' and 'customBoard' or nil) end
    else
        for name,item in pairs(value) do
            if type(name)~='string' then error('Invalid JSON object key') end
            result[#result+1]=encode(name,stack,depth+1)..':'..encode(item,stack,depth+1,name)
        end
    end
    stack[value]=nil
    return (isArray and '[' or '{')..table.concat(result,',')..(isArray and ']' or '}')
end
function Json.encode(value,rootArray)
    local ok,result=pcall(encode,value,{},0,rootArray and 'customBoard' or nil)
    if ok then return result end
end
function Json.decode(bytes)
    if type(bytes)~='string' or #bytes>1100000 then return end
    local depth,inString,escaped=0,false,false
    for index=1,#bytes do
        local byte=bytes:byte(index)
        if inString then
            if escaped then escaped=false elseif byte==92 then escaped=true elseif byte==34 then inString=false end
        elseif byte==34 then inString=true
        elseif byte==123 or byte==91 then depth=depth+1 if depth>16 then return end
        elseif byte==125 or byte==93 then depth=depth-1 if depth<0 then return end end
    end
    if inString or depth~=0 then return end
    local ok,result=pcall(base.decode,bytes)
    if ok then return result end
end
return Json
