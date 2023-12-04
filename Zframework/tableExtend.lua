local rnd=math.random
local min,max=math.min,math.max
local find=string.find
local ins,rem=table.insert,table.remove
local next,type=next,type
local TABLE={}

-----------------------[Making Tables]------------------------
-- Get a new filled table
function TABLE.new(val,count)
    local L={}
    for i=1,count do
        L[i]=val
    end
    return L
end

-- Get a copy of [1~#] elements
function TABLE.shift(org,depth)
    if not depth then depth=1e99 end
    local L={}
    for i=1,#org do
        if type(org[i])=='table' and depth>0 then
            L[i]=TABLE.shift(org[i],depth-1)
        else
            L[i]=org[i]
        end
    end
    return L
end

-- Get a full copy of a table, depth=how many layers will be recreate, default to inf
function TABLE.copy(org,depth)
    if not depth then depth=1e99 end
    local L={}
    for k,v in next,org do
        if type(v)=='table' and depth>0 then
            L[k]=TABLE.copy(v,depth-1)
        else
            L[k]=v
        end
    end
    return L
end

-- Connect [1~#] elements of new to the end of org
function TABLE.connect(org,new)
    local l0=#org
    for i=1,#new do
        org[l0+i]=new[i]
    end
    return org
end

-- Get a table of two lists connected
function TABLE.combine(L1,L2)
    local l={}
    local l0=#L1
    for i=1,l0 do l[i]=L1[i] end
    for i=1,#L2 do l[l0+i]=L2[i] end
    return l
end

----------------------[Modifying Tables]----------------------

-- For all things in new, push to old
function TABLE.cover(new,old)
    for k,v in next,new do
        old[k]=v
    end
end

-- For all things in new, push to old
function TABLE.coverR(new,old)
    for k,v in next,new do
        if type(v)=='table' and type(old[k])=='table' then
            TABLE.coverR(v,old[k])
        else
            old[k]=v
        end
    end
end

-- For all things in org, delete them if it's in sub
function TABLE.subtract(org,sub)
    for _,v in next,sub do
        while true do
            local p=TABLE.search(org,v)
            if p then
                rem(org,p)
            else
                break
            end
        end
    end
end

-- For all things in new if same type in old, push to old
function TABLE.update(new,old)
    for k,v in next,new do
        if type(v)==type(old[k]) then
            if type(v)=='table' then
                TABLE.update(v,old[k])
            else
                old[k]=v
            end
        end
    end
end

-- For all things in new if no val in old, push to old
function TABLE.complete(new,old)
    for k,v in next,new do
        if type(v)=='table' then
            if old[k]==nil then old[k]={} end
            TABLE.complete(v,old[k])
        elseif old[k]==nil then
            old[k]=v
        end
    end
end

-------------------[Removing Table Values]--------------------

-- Pop & return random [1~#] of table
function TABLE.popRandom(t)
    local l=#t
    if l>0 then
        local r=rnd(l)
        r,t[r]=t[r],t[l]
        t[l]=nil
        return r
    end
end

-- Remove [1~#] of table
function TABLE.cut(G)
    for i=1,#G do
        G[i]=nil
    end
end

-- Clear table
function TABLE.clear(G)
    for k in next,G do
        G[k]=nil
    end
end

--------------------[Handling duplicates]---------------------

-- Remove duplicated value of [1~#]
function TABLE.trimDuplicate(org)
    local cache={}
    for i=1,#org,-1 do
        if cache[org[i]] then
            rem(org,i)
        else
            cache[org[i]]=true
        end
    end
end

-- Discard duplicated value
function TABLE.remDuplicate(org)
    local cache={}
    for k,v in next,org do
        if cache[v] then
            org[k]=nil
        else
            cache[v]=true
        end
    end
end

--[[
    Run length encoder. Input must be a list containing non-nil value(s).
    Example:
    - Input: {1, 1, 2, 2, 2, 1}
    - Output: {{1, 2}, {2, 3}, {1, 1}}
    - This means: "Two 1's in a row", "Three 2's in a row", "One 1 in a row"
]]
function TABLE.RLE(org)
    local output={}
    local cur=nil
    local count=0

    for i=1,#org do
        local item=org[i]

        if item==cur then
            count=count+1
        else
            if cur then
                ins(output,{cur,count})
            end
            cur=item
            count=1
        end
    end

    if cur then
        ins(output,{cur,count})
    end

    return output
end

----------------------[Reversing Tables]----------------------

-- Reverse [1~#]
function TABLE.reverse(org)
    local l=#org
    for i=1,math.floor(l/2) do
        org[i],org[l+1-i]=org[l+1-i],org[i]
    end
end

----------------------[Table Comparison]----------------------

-- Check if tow list have same elements
function TABLE.compare(a,b)
    if #a~=#b then return false end
    if a==b then return true end
    for i=1,#a do
        if a[i]~=b[i] then return false end
    end
    return true
end

-- Check if tow table have same elements
function TABLE.equal(a,b)
    if #a~=#b then return false end
    if a==b then return true end
    for k,v in next,a do
        if b[k]~=v then return false end
    end
    return true
end

----------------------[Table Operations]----------------------

-- Find value in [1~#], like string.find
function TABLE.find(t,val,start)
    for i=start or 1,#t do if t[i]==val then return i end end
end

-- Get subset of table, like string.sub
function TABLE.sub(t,i,j)
    local subTable={}
    for k=max(i,1),(j and min(j,#t) or #t) do
        subTable[k-i+1]=t[k]
    end
    return subTable
end

-- Replace value in [1~#], like string.gsub
function TABLE.gsub(t,v_old,v_new,count,start)
    if not start then start=1 end
    if not count then count=1e99 end
    while t[start] and count>0 do
        if t[start]==v_old then
            t[start]=v_new
            count=count-1
        end
    end
end

-- Return next value of [1~#] (by value)
function TABLE.next(t,val)
    for i=1,#t do if t[i]==val then return t[i%#t+1] end end
end

-- Find value in whole table
function TABLE.search(t,val)
    for k,v in next,t do if v==val then return k end end
end

-- Replace all value in t
function TABLE.replace(t,v_old,v_new)
    for k,v in next,t do
        if v==v_old then
            t[k]=v_new
        end
    end
end

-- Re-index string value of a table
function TABLE.reIndex(org)
    for k,v in next,org do
        if type(v)=='string' then
            org[k]=org[v]
        end
    end
end

-- Return table where keys and values are swapped (useful for hashmap)
function TABLE.kvSwap(t)
    local output={}
    for k,v in next,t do output[v]=k end
    return output
end

--[[
    Extracts a value from each sub-table in table.
    Example input: ({{name='A'},{name='B'},{name='C'}}, 'name')
    Output: {'A','B'}
]]
function TABLE.extract(t,keyName)
    local output={}
    for k,v in next,t do output[k]=v[keyName] end
    return output
end

-- Get element count of table
function TABLE.getSize(t)
    local size=0
    for _ in next,t do size=size+1 end
    return size
end

-----------------------[Table Rotation]-----------------------

-- Copy a rotated matrix table
function TABLE.rotate(cb,dir)
    local icb={}
    if dir=='R' then-- Rotate CW
        for y=1,#cb[1] do
            icb[y]={}
            for x=1,#cb do
                icb[y][x]=cb[x][#cb[1]-y+1]
            end
        end
    elseif dir=='L' then-- Rotate CCW
        for y=1,#cb[1] do
            icb[y]={}
            for x=1,#cb do
                icb[y][x]=cb[#cb-x+1][y]
            end
        end
    elseif dir=='F' then-- Rotate 180 degree
        for y=1,#cb do
            icb[y]={}
            for x=1,#cb[1] do
                icb[y][x]=cb[#cb-y+1][#cb[1]-x+1]
            end
        end
    end
    return icb
end

----------------------[Table Functions]-----------------------

-- Return a function that return a value of table
function TABLE.func_getVal(t,k)
    return function() return t[k] end
end

-- Return a function that reverse a value of table
function TABLE.func_revVal(t,k)
    return function() t[k]=not t[k] end
end

-- Return a function that set a value of table
function TABLE.func_setVal(t,k)
    return function(v) t[k]=v end
end

-------------------------[Table Dump]-------------------------

-- Dump a simple lua table (no whitespaces)
do-- function TABLE.dumpDeflate(L,t)
    local function dump(L)
        if type(L)~='table' then return end
        local s='{'
        local count=1
        for k,v in next,L do
            local T=type(k)
            if T=='number' then
                if k==count then
                    k=''
                    count=count+1
                else
                    k='['..k..']='
                end
            elseif T=='string' then
                if find(k,'[^0-9a-zA-Z_]') then
                    k='[\''..k..'\']='
                else
                    k=k..'='
                end
            elseif T=='boolean' then k='['..k..']='
            else error("Error key type!")
            end
            T=type(v)
            if T=='number' then v=tostring(v)
            elseif T=='string' then v='\''..v..'\''
            elseif T=='table' then v=dump(v)
            elseif T=='boolean' then v=tostring(v)
            else v='*'..tostring(v)
            end
            s=s..k..v..','
        end
        return s..'}'
    end
    TABLE.dumpDeflate=dump
end

-- Dump a simple lua table
do-- function TABLE.dump(L,t)
    local tabs=setmetatable({
        [0]='',
        '\t',
    },{__index=function(self,k)
        if k>=626 then error("Too many tabs!") end
        for i=#self+1,k do
            self[i]=self[i-1]..'\t'
        end
        return self[k]
    end})
    local function dump(L,t)
        local s='{\n'
        if not t then
            s='return {\n'
            t=1
            if type(L)~='table' then
                return
            end
        end
        local count=1
        for k,v in next,L do
            local T=type(k)
            if T=='number' then
                if k==count then
                    k=''
                    count=count+1
                else
                    k='['..k..']='
                end
            elseif T=='string' then
                if find(k,'[^0-9a-zA-Z_]') then
                    k='[\''..k..'\']='
                else
                    k=k..'='
                end
            elseif T=='boolean' then k='['..k..']='
            else k='[\'*'..tostring(k)..'\']='
            end
            T=type(v)
            if T=='number' then v=tostring(v)
            elseif T=='string' then v='\''..v..'\''
            elseif T=='table' then v=dump(v,t+1)
            elseif T=='boolean' then v=tostring(v)
            else v='*'..tostring(v)
            end
            s=s..tabs[t]..k..v..',\n'
        end
        return s..tabs[t-1]..'}'
    end
    TABLE.dump=dump
end

return TABLE
