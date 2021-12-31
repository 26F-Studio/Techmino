local rnd=math.random
local find=string.find
local rem=table.remove
local next,type=next,type
local TABLE={}

--Get a new filled table
function TABLE.new(val,count)
    local L={}
    for i=1,count do
        L[i]=val
    end
    return L
end

--Get a copy of [1~#] elements
function TABLE.shift(org,depth)
    if not depth then depth=1e99 end
    local L={}
    for i=1,#org do
        if type(org[i])=='table'and depth>0 then
            L[i]=TABLE.shift(org[i],depth-1)
        else
            L[i]=org[i]
        end
    end
    return L
end

--Get a full copy of a table, depth = how many layers will be recreate, default to inf
function TABLE.copy(org,depth)
    if not depth then depth=1e99 end
    local L={}
    for k,v in next,org do
        if type(v)=='table'and depth>0 then
            L[k]=TABLE.copy(v,depth-1)
        else
            L[k]=v
        end
    end
    return L
end

--For all things in new, push to old
function TABLE.cover(new,old)
    for k,v in next,new do
        old[k]=v
    end
end

--For all things in new, push to old
function TABLE.coverR(new,old)
    for k,v in next,new do
        if type(v)=='table'and type(old[k])=='table'then
            TABLE.coverR(v,old[k])
        else
            old[k]=v
        end
    end
end

--For all things in new if same type in old, push to old
function TABLE.update(new,old)
    for k,v in next,new do
        if type(v)==type(old[k])then
            if type(v)=='table'then
                TABLE.update(v,old[k])
            else
                old[k]=v
            end
        end
    end
end

--For all things in new if no val in old, push to old
function TABLE.complete(new,old)
    for k,v in next,new do
        if type(v)=='table'then
            if old[k]==nil then old[k]={}end
            TABLE.complete(v,old[k])
        elseif old[k]==nil then
            old[k]=v
        end
    end
end

--------------------------

--Pop & return random [1~#] of table
function TABLE.popRandom(t)
    local l=#t
    if l>0 then
        local r=rnd(l)
        r,t[r]=t[r],t[l]
        t[l]=nil
        return r
    end
end

--Remove [1~#] of table
function TABLE.cut(G)
    for i=1,#G do
        G[i]=nil
    end
end

--Clear table
function TABLE.clear(G)
    for k in next,G do
        G[k]=nil
    end
end

--------------------------

--Remove duplicated value of [1~#]
function TABLE.trimDuplicate(org)
    local cache={}
    for i=1,#org,-1 do
        if cache[org[i]]then
            rem(org,i)
        else
            cache[org[i]]=true
        end
    end
end

--Discard duplicated value
function TABLE.remDuplicate(org)
    local cache={}
    for k,v in next,org do
        if cache[v]then
            org[k]=nil
        else
            cache[v]=true
        end
    end
end

--------------------------

--Reverse [1~#]
function TABLE.reverse(org)
    local l=#org
    for i=1,math.floor(l/2)do
        org[i],org[l+1-i]=org[l+1-i],org[i]
    end
end

--------------------------

--Find value in [1~#]
function TABLE.find(t,val)
    for i=1,#t do if t[i]==val then return i end end
end

--Return next value of [1~#] (by value)
function TABLE.next(t,val)
    for i=1,#t do if t[i]==val then return t[i%#t+1]end end
end

--------------------------

--Find value in whole table
function TABLE.search(t,val)
    for k,v in next,t do if v==val then return k end end
end

--Re-index string value of a table
function TABLE.reIndex(org)
    for k,v in next,org do
        if type(v)=='string'then
            org[k]=org[v]
        end
    end
end

--------------------------

--Dump a simple lua table
do--function TABLE.dump(L,t)
    local tabs={
        [0]="",
        "\t",
        "\t\t",
        "\t\t\t",
        "\t\t\t\t",
        "\t\t\t\t\t",
    }
    local function dump(L,t)
        local s
        if t then
            s="{\n"
        else
            s="return{\n"
            t=1
            if type(L)~='table'then
                return
            end
        end
        local count=1
        for k,v in next,L do
            local T=type(k)
            if T=='number'then
                if k==count then
                    k=""
                    count=count+1
                else
                    k="["..k.."]="
                end
            elseif T=='string'then
                if find(k,"[^0-9a-zA-Z_]")then
                    k="[\""..k.."\"]="
                else
                    k=k.."="
                end
            elseif T=='boolean'then k="["..k.."]="
            else error("Error key type!")
            end
            T=type(v)
            if T=='number'then v=tostring(v)
            elseif T=='string'then v="\""..v.."\""
            elseif T=='table'then v=dump(v,t+1)
            elseif T=='boolean'then v=tostring(v)
            else error("Error data type!")
            end
            s=s..tabs[t]..k..v..",\n"
        end
        return s..tabs[t-1].."}"
    end
    TABLE.dump=dump
end

--Dump a simple lua table (no whitespaces)
do--function TABLE.dumpDeflate(L,t)
    local function dump(L)
        local s="return{"
        if type(L)~='table'then return end
        local count=1
        for k,v in next,L do
            local T=type(k)
            if T=='number'then
                if k==count then
                    k=""
                    count=count+1
                else
                    k="["..k.."]="
                end
            elseif T=='string'then
                if find(k,"[^0-9a-zA-Z_]")then
                    k="[\""..k.."\"]="
                else
                    k=k.."="
                end
            elseif T=='boolean'then k="["..k.."]="
            else error("Error key type!")
            end
            T=type(v)
            if T=='number'then v=tostring(v)
            elseif T=='string'then v="\""..v.."\""
            elseif T=='table'then v=dump(v)
            elseif T=='boolean'then v=tostring(v)
            else error("Error data type!")
            end
        end
        return s.."}"
    end
    TABLE.dumpDeflate=dump
end

return TABLE
