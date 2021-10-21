if arg[1]=="-apkCode"then
    local code=require"version".apkCode
    print(code)
elseif arg[1]=="-code"then
    local str=require"version".code
    print(str)
elseif arg[1]=="-name"then
    local str=require"version".string:gsub("@DEV","")
    print(str)
elseif arg[1]=="-release"then
    local str=require"version".string:gsub("V","",1):gsub("@DEV","")
    print(str)
elseif arg[1]=="-updateTitle"then
    local note=require"parts.updateLog"
    local p1=note:find("\n%d")+1
    local p2=note:find("\n",p1)-1
    note=note:sub(p1,p2)
    print(note)
elseif arg[1]=="-updateNote"then
    local note=require"parts.updateLog"
    local p1=note:find("\n",note:find("\n%d")+1)+1
    local p2=note:find("\n%d",p1+1)
    note=note:sub(p1,p2-2)
        :gsub("                ","- ")
        :gsub("        ","# ")
    print(note)
end
