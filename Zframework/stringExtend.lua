local data=love.data
local STRING={}
local int,format=math.floor,string.format
local find,sub,upper=string.find,string.sub,string.upper
local char,byte=string.char,string.byte

do--function STRING.shiftChar(c)
    local shiftMap={
        ['1']='!',['2']='@',['3']='#',['4']='$',['5']='%',
        ['6']='^',['7']='&',['8']='*',['9']='(',['0']=')',
        ['`']='~',['-']='_',['=']='+',
        ['[']='{',[']']='}',['\\']='|',
        [';']=':',['\'']='"',
        [',']='<',['.']='>',['/']='?',
    }
    function STRING.shiftChar(c)
        return shiftMap[c]or upper(c)
    end
end

function STRING.trim(s)
    if not s:find("%S")then return""end
    s=s:sub((s:find("%S"))):reverse()
    return s:sub((s:find("%S"))):reverse()
end

function STRING.split(s,sep,regex)
    local L={}
    local p1,p2=1--start,target
    if regex then
        while p1<=#s do
            p2=find(s,sep,p1)or #s+1
            L[#L+1]=sub(s,p1,p2-1)
            p1=p2+#sep
        end
    else
        while p1<=#s do
            p2=find(s,sep,p1,true)or #s+1
            L[#L+1]=sub(s,p1,p2-1)
            p1=p2+#sep
        end
    end
    return L
end

function STRING.simpEmailCheck(e)
    e=STRING.split(e,"@")
    if #e~=2 then return false end
    if e[1]:sub(-1)=="."or e[2]:sub(-1)=="."then return false end
    local e1,e2=STRING.split(e[1],"."),STRING.split(e[2],".")
    if #e1*#e2==0 then return false end
    for _,v in next,e1 do if #v==0 then return false end end
    for _,v in next,e2 do if #v==0 then return false end end
    return true
end

function STRING.time_simp(t)
    return format("%02d:%02d",int(t/60),int(t%60))
end

function STRING.time(t)
    if t<60 then
        return format("%.3f\"",t)
    elseif t<3600 then
        return format("%d'%05.2f\"",int(t/60),int(t%60))
    else
        return format("%d:%.2d'%05.2f\"",int(t/3600),int(t/60%60),int(t%60))
    end
end

function STRING.hexColor(str)--[LOW PERFORMENCE]
    assert(type(str)=='string')
    if str:sub(1,1)=="#"then str=str:sub(2)end
    assert(#str<=8)
    local r=(tonumber(str:sub(1,2),16)or 0)/255
    local g=(tonumber(str:sub(3,4),16)or 0)/255
    local b=(tonumber(str:sub(5,6),16)or 0)/255
    local a=(tonumber(str:sub(7,8),16)or 255)/255
    return r,g,b,a
end

do--function STRING.urlEncode(s)
    local rshift=bit.rshift
    local b16={[0]='0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
    function STRING.urlEncode(s)
        local out=""
        for i=1,#s do
            if s:sub(i,i):match("[a-zA-Z0-9]")then
                out=out..s:sub(i,i)
            else
                local b=s:byte(i)
                out=out.."%"..b16[rshift(b,4)]..b16[b%16]
            end
        end
        return out
    end
end

function STRING.vcsEncrypt(text,key)
    local keyLen=#key
    local result=""
    local buffer=""
    for i=0,#text-1 do
        buffer=buffer..char((byte(text,i+1)-32+byte(key,i%keyLen+1))%95+32)
        if #buffer==26 then
            result=result..buffer
            buffer=""
        end
    end
    return result..buffer
end
function STRING.vcsDecrypt(text,key)
    local keyLen=#key
    local result=""
    local buffer=""
    for i=0,#text-1 do
        buffer=buffer..char((byte(text,i+1)-32-byte(key,i%keyLen+1))%95+32)
        if #buffer==26 then
            result=result..buffer
            buffer=""
        end
    end
    return result..buffer
end

function STRING.readLine(str)
    local p=str:find("\n")
    if p then
        return str:sub(1,p-1),str:sub(p+1)
    else
        return str,""
    end
end

function STRING.packBin(s)
    return data.encode('string','base64',data.compress('string','zlib',s))
end
function STRING.unpackBin(str)
    local res
    res,str=pcall(data.decode,'string','base64',str)
    if not res then return end
    res,str=pcall(data.decompress,'string','zlib',str)
    if res then return str end
end
function STRING.packText(s)
    return data.encode('string','base64',data.compress('string','gzip',s))
end
function STRING.unpackText(str)
    local res
    res,str=pcall(data.decode,'string','base64',str)
    if not res then return end
    res,str=pcall(data.decompress,'string','gzip',str)
    if res then return str end
end
function STRING.packTable(t)
    return STRING.packText(JSON.encode(t))
end
function STRING.unpackTable(t)
    return JSON.decode(STRING.unpackText(t))
end

return STRING