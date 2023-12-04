local clock=os.clock

local profile={}

local _labeled={} -- function labels
local _defined={} -- function definitions
local _tcalled={} -- time of last call
local _telapsed={}-- total execution time
local _ncalls={}  -- number of calls
local _internal={}-- list of internal profiler functions

local getInfo=debug.getinfo
function profile.hooker(event,line,info)
    info=info or getInfo(2,'fnS')
    local f=info.func
    if _internal[f] then return end-- ignore the profiler itself
    if info.name then _labeled[f]=info.name end-- get the function name if available
    -- find the line definition
    if not _defined[f] then
        _defined[f]=info.short_src..":"..info.linedefined
        _ncalls[f]=0
        _telapsed[f]=0
    end
    if _tcalled[f] then
        local dt=clock()-_tcalled[f]
        _telapsed[f]=_telapsed[f]+dt
        _tcalled[f]=nil
    end
    if event=='tail call' then
        local prev=getInfo(3,'fnS')
        profile.hooker('return',line,prev)
        profile.hooker('call',line,info)
    elseif event=='call' then
        _tcalled[f]=clock()
    else
        _ncalls[f]=_ncalls[f]+1
    end
end

--- Starts collecting data.
function profile.start()
    if jit then
        jit.off()
        jit.flush()
    end
    debug.sethook(profile.hooker,'cr')
end

--- Stops collecting data.
function profile.stop()
    debug.sethook()
    for f in next,_tcalled do
        local dt=clock()-_tcalled[f]
        _telapsed[f]=_telapsed[f]+dt
        _tcalled[f]=nil
    end
    -- merge closures
    local lookup={}
    for f,d in next,_defined do
        local id=(_labeled[f] or "?")..d
        local f2=lookup[id]
        if f2 then
            _ncalls[f2]=_ncalls[f2]+(_ncalls[f] or 0)
            _telapsed[f2]=_telapsed[f2]+(_telapsed[f] or 0)
            _defined[f],_labeled[f]=nil,nil
            _ncalls[f],_telapsed[f]=nil,nil
        else
            lookup[id]=f
        end
    end
    collectgarbage()
end

--- Resets all collected data.
function profile.reset()
    for f in next,_ncalls do
        _ncalls[f]=0
        _telapsed[f]=0
        _tcalled[f]=nil
    end
    collectgarbage()
end

local function _comp(a,b)
    local dt=_telapsed[b]-_telapsed[a]
    return dt==0 and _ncalls[b]<_ncalls[a] or dt<0
end

--- Iterates all functions that have been called since the profile was started.
function profile.query(limit)
    local t={}
    for f,n in next,_ncalls do
        if n>0 then
            t[#t+1]=f
        end
    end
    table.sort(t,_comp)

    if limit then while #t>limit do table.remove(t) end end

    for i,f in ipairs(t) do
        local dt=0
        if _tcalled[f] then
            dt=clock()-_tcalled[f]
        end
        t[i]={i,_labeled[f] or "?",math.floor((_telapsed[f]+dt)*1e6)/1e6,_ncalls[f],_defined[f]}
    end
    return t
end

local cols={3,20,8,6,32}
function profile.report(n)
    local out={}
    local report=profile.query(n)
    for i,row in ipairs(report) do
        for j=1,5 do
            local s=tostring(row[j])
            local l1,l2=#s,cols[j]
            if l1<l2 then
                s=s..(" "):rep(l2-l1)
            elseif l1>l2 then
                s=s:sub(l1-l2+1,l1)
            end
            row[j]=s
        end
        out[i]=table.concat(row," | ")
    end

    local row=" +-----+----------------------+----------+--------+----------------------------------+ \n"
    local col=" | #   | Function             | Time     | Calls  | Code                             | \n"
    local sz=row..col..row
    if #out>0 then
        sz=sz.." | "..table.concat(out," | \n | ").." | \n"
    end
    return "\n"..sz..row
end

local switch=false
function profile.switch()
    switch=not switch
    if not switch then
        profile.stop()
        love.system.setClipboardText(profile.report())
        profile.reset()
        return false
    else
        profile.start()
        return true
    end
end

-- store all internal profiler functions
for _,v in next,profile do
    _internal[v]=type(v)=='function'
end

return profile
