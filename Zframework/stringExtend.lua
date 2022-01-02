local data=love.data
local STRING={}
local assert,tostring,tonumber=assert,tostring,tonumber
local int,format=math.floor,string.format
local find,sub,gsub=string.find,string.sub,string.gsub
local rep,upper=string.rep,string.upper
local char,byte=string.char,string.byte

--"Replace dollars", replace all $n with ...
function STRING.repD(str,...)
    local l={...}
    for i=#l,1,-1 do
        str=gsub(str,'$'..i,l[i])
    end
    return str
end

--"Scan arg", scan if str has the arg (format of str is like "-json -q", arg is like "-q")
function STRING.sArg(str,switch)
    if find(str.." ",switch.." ")then
        return true
    end
end

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
        return format("%.3f″",t)
    elseif t<3600 then
        return format("%d′%05.2f″",int(t/60),int(t%60*100)/100)
    else
        return format("%d:%.2d′%05.2f″",int(t/3600),int(t/60%60),int(t%60*100)/100)
    end
end

function STRING.UTF8(n)--Simple utf8 coding
    assert(type(n)=='number',"Wrong type ("..type(n)..")")
    assert(n>=0 and n<2^31,"Out of range ("..n..")")
    if n<2^7 then return char(n)
    elseif n<2^11 then return char(192+int(n/2^06),128+n%2^6)
    elseif n<2^16 then return char(224+int(n/2^12),128+int(n/2^06)%2^6,128+n%2^6)
    elseif n<2^21 then return char(240+int(n/2^18),128+int(n/2^12)%2^6,128+int(n/2^06)%2^6,128+n%2^6)
    elseif n<2^26 then return char(248+int(n/2^24),128+int(n/2^18)%2^6,128+int(n/2^12)%2^6,128+int(n/2^06)%2^6,128+n%2^6)
    elseif n<2^31 then return char(252+int(n/2^30),128+int(n/2^24)%2^6,128+int(n/2^18)%2^6,128+int(n/2^12)%2^6,128+int(n/2^06)%2^6,128+n%2^6)
    end
end

do--function STRING.bigInt(t)
    local lg=math.log10
    local units={"","K","M","B","T","Qa","Qt","Sx","Sp","Oc","No"}
    local preUnits={"","U","D","T","Qa","Qt","Sx","Sp","O","N"}
    local secUnits={"Dc","Vg","Tg","Qd","Qi","Se","St","Og","Nn","Ce"}--Ce is next-level unit, but DcCe is not used so used here
    for _,preU in next,preUnits do for _,secU in next,secUnits do table.insert(units,preU..secU)end end
    function STRING.bigInt(t)
        if t<1000 then
            return tostring(t)
        elseif t~=1e999 then
            local e=int(lg(t)/3)
            return(t/10^(e*3))..units[e+1]
        else
            return"INF"
        end
    end
end

do--function STRING.toBin, STRING.toOct, STRING.toHex(n,len)
    function STRING.toBin(n,len)
        local s=""
        while n>0 do
            s=(n%2)..s
            n=int(n/2)
        end
        if len then
            return rep("0",len-#s)..s
        else
            return s
        end
    end
    function STRING.toOct(n,len)
        local s=""
        while n>0 do
            s=(n%8)..s
            n=int(n/8)
        end
        if len then
            return rep("0",len-#s)..s
        else
            return s
        end
    end
    local b16={[0]='0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}
    function STRING.toHex(n,len)
        local s=""
        while n>0 do
            s=b16[n%16]..s
            n=int(n/16)
        end
        if len then
            return rep("0",len-#s)..s
        else
            return s
        end
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
function STRING.digezt(text)--Not powerful hash, just protect the original text
    local out={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    local seed=26
    for i=1,#text do
        local c=byte(text,i)
        seed=(seed+c)%26
        c=c+seed
        local pos=c*i%16
        local step=(c+i)%4+1
        local times=2+(c%6)
        for _=1,times do
            out[pos+1]=(out[pos+1]+c)%256
            pos=(pos+step)%16
        end
    end
    local result=""
    for i=1,16 do result=result..char(out[i])end
    return result
end

function STRING.readLine(str)
    local p=str:find("\n")
    if p then
        return str:sub(1,p-1),str:sub(p+1)
    else
        return str,""
    end
end
function STRING.readChars(str,n)
    return sub(str,1,n),sub(str,n+1)
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
