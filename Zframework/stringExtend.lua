local data=love.data
local STRING={}
local assert,tostring,tonumber=assert,tostring,tonumber
local floorint,format=math.floor,string.format
local find,sub,gsub=string.find,string.sub,string.gsub
local rep,upper=string.rep,string.upper
local char,byte=string.char,string.byte

-- "Replace dollars", replace all $n with ...
function STRING.repD(str,...)
    local l={...}
    for i=#l,1,-1 do
        str=gsub(str,'$'..i,l[i])
    end
    return str
end

-- "Scan arg", scan if str has the arg (format of str is like "-json -q", arg is like "-q")
function STRING.sArg(str,switch)
    if find(str.." ",switch.." ") then
        return true
    end
end

do-- function STRING.shiftChar(c)
    local shiftMap={
        ['1']='!',['2']='@',['3']='#',['4']='$',['5']='%',
        ['6']='^',['7']='&',['8']='*',['9']='(',['0']=')',
        ['`']='~',['-']='_',['=']='+',
        ['[']='{',[']']='}',['\\']='|',
        [';']=':',['\'']='"',
        [',']='<',['.']='>',['/']='?',
    }
    function STRING.shiftChar(c)
        return shiftMap[c] or upper(c)
    end
end

-- [LOW PERFORMANCE!]
local upperData,lowerData,diaData
function STRING.upperUTF8(str)
    for _,pair in next,upperData do
        str=str:gsub(pair[1],pair[2])
    end
    return str
end
function STRING.lowerUTF8(str)
    for _,pair in next,lowerData do
        str=str:gsub(pair[1],pair[2])
    end
    return str
end
function STRING.remDiacritics(str)
    for _,pair in next,diaData do
        str=str:gsub(pair[1],pair[2])
    end
    return str
end

function STRING.trim(s)
    if not s:find("%S") then return "" end
    s=s:sub((s:find("%S"))):reverse()
    return s:sub((s:find("%S"))):reverse()
end

function STRING.split(s,sep,regex)
    local L={}
    local p1,p2=1-- start,target
    if regex then
        while p1<=#s do
            p2=find(s,sep,p1) or #s+1
            L[#L+1]=sub(s,p1,p2-1)
            p1=p2+#sep
        end
    else
        while p1<=#s do
            p2=find(s,sep,p1,true) or #s+1
            L[#L+1]=sub(s,p1,p2-1)
            p1=p2+#sep
        end
    end
    return L
end

function STRING.simpEmailCheck(e)
    e=STRING.split(e,"@")
    if #e~=2 then return false end
    if e[1]:sub(-1)=="." or e[2]:sub(-1)=="." then return false end
    local e1,e2=STRING.split(e[1],"."),STRING.split(e[2],".")
    if #e1*#e2==0 then return false end
    for _,v in next,e1 do if #v==0 then return false end end
    for _,v in next,e2 do if #v==0 then return false end end
    return true
end

local MINUTE=60
local HOUR=3600
local DAY=86400
local YEAR=31536000 -- 365 days
local function convertSecondsToUnits(t) -- convert seconds to {seconds, minutes, hours, days, years}
    local years=floorint(t/YEAR)
    local remainder=t%YEAR

    local days=floorint(remainder/DAY)
    remainder=remainder%DAY

    local hours=floorint(remainder/HOUR)
    remainder=remainder%HOUR

    local minutes=floorint(remainder/MINUTE)
    local seconds=remainder%MINUTE
    return seconds,minutes,hours,days,years
end

-- MM:SS
function STRING.time_simp(t)
    return format("%02d:%02d",floorint(t/MINUTE),floorint(t%MINUTE))
end

local timeLetters={' y',' d',' h',' m',' s',' ms'}
-- Display 2 largest units of time.
function STRING.time_short(t)
    -- Early returns to prevent nil values
    if t<0 then return '-'..STRING.time_short(-t) end -- negative time
    if t<1 then return math.floor(t*1000)..timeLetters[6] end -- 123 ms
    if t<MINUTE then return math.floor(t)..timeLetters[5]..' '..math.floor((t%1)*1000)..timeLetters[6] end -- 12s 345ms

    local timeUnits={convertSecondsToUnits(t)}
    TABLE.reverse(timeUnits)

    -- floor seconds
    timeUnits[#timeUnits]=floorint(timeUnits[#timeUnits])

    for i=1,#timeUnits do
        if timeUnits[i]>0 then
            return timeUnits[i]..timeLetters[i]..' '..timeUnits[i+1]..timeLetters[i+1]
        end
    end
end

function STRING.time(t)
    local s,m,h,d,y=convertSecondsToUnits(t)
    if t<MINUTE then
        return format("%.3f″",t) -- example: 12.345″
    elseif t<HOUR then
        return format("%d′%05.2f″",m,s) -- 1′23.45″
    elseif t<DAY then
        return format("%d:%.2d′%04.1f″",h,m,s) -- 12:34′56.7″
    elseif t<YEAR then
        return format("%dd %d:%.2d′%.2d″",d,h,m,s) -- 123d 12:34′56″
    else
        return format("%dy %dd %d:%.2d′",y,d,h,m) -- 1y 234d 12:34′
    end
end

function STRING.time_ext(t)
    local s,m,h,d,y=convertSecondsToUnits(t)
    if t<MINUTE then
        return format("%.5f″",t) -- 12.34567″
    elseif t<HOUR then
        return format("%d′%06.3f″",m,s) -- 1′23.456″
    elseif t<DAY then
        return format("%d:%.2d′%05.2f″",h,m,s) -- 12:34′56.78″
    elseif t<YEAR then
        return format("%dd %d:%.2d′%04.1f″",d,h,m,s) -- 123d 12:34′56.7″
    else
        return format("%dy %dd %d:%.2d′%.2d″",y,d,h,m,s) -- 1y 234d 12:34′56″
    end
end

function STRING.UTF8(n)-- Simple utf8 coding
    assert(type(n)=='number',"Wrong type ("..type(n)..")")
    assert(n>=0 and n<2^31,"Out of range ("..n..")")
    if n<2^7 then return char(n)
    elseif n<2^11 then return char(192+floorint(n/2^06),128+n%2^6)
    elseif n<2^16 then return char(224+floorint(n/2^12),128+floorint(n/2^06)%2^6,128+n%2^6)
    elseif n<2^21 then return char(240+floorint(n/2^18),128+floorint(n/2^12)%2^6,128+floorint(n/2^06)%2^6,128+n%2^6)
    elseif n<2^26 then return char(248+floorint(n/2^24),128+floorint(n/2^18)%2^6,128+floorint(n/2^12)%2^6,128+floorint(n/2^06)%2^6,128+n%2^6)
    elseif n<2^31 then return char(252+floorint(n/2^30),128+floorint(n/2^24)%2^6,128+floorint(n/2^18)%2^6,128+floorint(n/2^12)%2^6,128+floorint(n/2^06)%2^6,128+n%2^6)
    end
end

do-- functions to shorted big numbers
    local lg=math.log10
    local units={"","K","M","B","T","Qa","Qt","Sx","Sp","Oc","No"}
    local preUnits={"","U","D","T","Qa","Qt","Sx","Sp","O","N"}
    local secUnits={"Dc","Vg","Tg","Qd","Qi","Se","St","Og","Nn","Ce"}-- Ce is next-level unit, but DcCe is not used so used here
    for _,preU in next,preUnits do for _,secU in next,secUnits do table.insert(units,preU..secU) end end
    function STRING.bigInt(t)
        if t<1000 then
            return tostring(t)
        elseif t~=1e999 then
            local e=floorint(lg(t)/3)
            return(t/10^(e*3))..units[e+1]
        else
            return "INF"
        end
    end

    local MIN_SI=-30 -- current lowest order of magnitude for SI units (quecto-; 10^-30)
    local MAX_SI=30 -- current highest order of magnitude for SI units (quetta-; 10^30)
    local SI_SHORT={
        [-30]='q',[-27]='r',[-24]='y',[-21]='z',[-18]='a',[-15]='f',[-12]='p',
        [-9]='n',[-6]='μ',[-3]='m',[0]='',[3]='k',[6]='M',[9]='G',
        [12]='T',[15]='P',[18]='E',[21]='Z',[24]='Y',[27]='R',[30]='Q'
    }
    local SI_LONG={
        [-30]='quecto',[-27]='ronto',[-24]='yocto',[-21]='zepto',[-18]='atto',[-15]='femto',[-12]='pico',
        [-9]='nano',[-6]='micro',[-3]='milli',[0]='',[3]='kilo',[6]='mega',[9]='giga',
        [12]='tera',[15]='peta',[18]='exa',[21]='zetta',[24]='yotta',[27]='ronna',[30]='quetta'
    }
    --[[
        Converts a number into SI notation with letter prefixes.
        NOTE: Only power-of-thousand prefixes; no deci-/centi-.
        Arguments:
        - num: The number to be converted to SI notation.
        - unit: [optional] The unit to be concatenated at the end.
        Example: STRING.SI(10^-9,"m") --> "1 nm"
    ]]
    function STRING.SI(num, unit)
        unit=unit or ''
        local order=MATH.clamp(3*math.floor(math.log10(num)/3),MIN_SI,MAX_SI)
        local prefix=SI_SHORT[order]
        local scaledNum=num/10^order
        local formattedNum=string.format('%.3f', scaledNum):gsub('%.?0+$','')
        return formattedNum.." "..prefix..unit
    end

    --[[
        Converts a number into SI notation with word prefixes.
        NOTE: Only power-of-thousand prefixes; no deci-/centi-.
        Arguments:
        - num: The number to be converted to SI notation.
        - unit: [optional] The unit to be concatenated at the end.
        Example: STRING.SI(10^9,"hertz") --> "1 megahertz"
    ]]
    function STRING.SILong(num, unit)
        unit=unit or ''
        local order=MATH.clamp(3*math.floor(math.log10(num)/3),MIN_SI,MAX_SI)
        local prefix=SI_LONG[order]
        local scaledNum=num/10^order
        local formattedNum=string.format('%.3f', scaledNum):gsub('%.?0+$','')
        return formattedNum.." "..prefix..unit
    end
end

do-- function STRING.toBin, STRING.toOct, STRING.toHex(n,len)
    function STRING.toBin(n,len)
        local s=""
        while n>0 do
            s=(n%2)..s
            n=floorint(n/2)
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
            n=floorint(n/8)
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
            n=floorint(n/16)
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
    if str:sub(1,1)=="#" then str=str:sub(2) end
    assert(#str<=8)
    local r=(tonumber(str:sub(1,2),16) or 0)/255
    local g=(tonumber(str:sub(3,4),16) or 0)/255
    local b=(tonumber(str:sub(5,6),16) or 0)/255
    local a=(tonumber(str:sub(7,8),16) or 255)/255
    return r,g,b,a
end

do-- function STRING.urlEncode(s)
    local rshift=bit.rshift
    local b16={[0]='0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
    function STRING.urlEncode(s)
        local out=""
        for i=1,#s do
            if s:sub(i,i):match("[a-zA-Z0-9]") then
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
function STRING.digezt(text)-- Not powerful hash, just protect the original text
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
    for i=1,16 do result=result..char(out[i]) end
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

do
    local function parseFile(fname)
        local d
        if love and love.filesystem and type(love.filesystem.read)=='function' then
            d=love.filesystem.read(fname)
        else
            local f=io.open(fname,'r')
            if f then
                d=f:read('a')
                f:close()
            end
        end

        if not d then
            print("ERROR: Failed to read the data from "..fname)
            return {}
        end
        d=STRING.split(gsub(d,'\n',','),',')
        for i=1,#d do
            d[i]=STRING.split(d[i],'=')
        end
        return d
    end
    upperData=parseFile('Zframework/upcaser.txt')
    lowerData=parseFile('Zframework/lowcaser.txt')
    diaData=parseFile('Zframework/diacritics.txt')
end

return STRING
