local Protocol={version=1}
function Protocol.integer(value,min,max)
    return type(value)=='number' and value==value and value%1==0 and value>=min and value<=max
end
function Protocol.id(value)
    return type(value)=='string' and #value==36 and value:match('^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$')~=nil
end
function Protocol.string(value,max)
    return type(value)=='string' and #value<=max and not value:find('%z')
end
local phases={lobby=true,countdown=true,playing=true,settling=true,closed=true}
function Protocol.settings(value)
    return type(value)=='table' and type(value.pauseOnDisconnect)=='boolean' and type(value.pauseOnAbsence)=='boolean' and (value.pauseLimitSeconds==5 or value.pauseLimitSeconds==10 or value.pauseLimitSeconds==30) and type(value.spectators)=='boolean'
end
function Protocol.tuning(value)
    if type(value)~='table' then return false end
    local limits={das=60,arr=30,dascut=60,irscut=30,dropcut=30,sddas=60,sdarr=30}
    for key,item in pairs(value) do
        if limits[key] then
            if not Protocol.integer(item,0,limits[key]) then return false end
        elseif key=='ihs' or key=='irs' or key=='ims' then
            if type(item)~='boolean' then return false end
        else return false end
    end
    return true
end
function Protocol.room(value)
    if type(value)~='table' or not Protocol.id(value.id) or not Protocol.string(value.name,128) or not Protocol.integer(value.revision,0,9007199254740991) or not phases[value.phase] or not Protocol.id(value.hostId) or (value.track~='authoritative' and value.track~='relay') or not Protocol.settings(value.settings) or type(value.members)~='table' or #value.members>30 then return false end
    local seen,players,spectators={},0,0
    for _,member in ipairs(value.members) do
        if type(member)~='table' or not Protocol.id(member.id) or seen[member.id] or not Protocol.string(member.name,128) or (member.role~='player' and member.role~='spectator') or not Protocol.integer(member.team,0,6) or type(member.ready)~='boolean' or type(member.connected)~='boolean' then return false end
        seen[member.id]=true
        if member.role=='player' then players=players+1 else spectators=spectators+1 end
    end
    return players<=10 and spectators<=20
end
function Protocol.match(value)
    if type(value)~='table' or not Protocol.id(value.matchId) or not Protocol.id(value.roomId) or not Protocol.integer(value.seed,0,4294967295) or not Protocol.integer(value.frame,0,54000) or not Protocol.string(value.rulesetVersion,128) or (value.track~='authoritative' and value.track~='relay') or value.authoritative~=(value.track=='authoritative') or type(value.participants)~='table' or #value.participants<2 or #value.participants>10 or value.inputBufferFrames~=6 or value.readyFrames~=180 then return false end
    local seen={}
    for index,member in ipairs(value.participants) do
        if type(member)~='table' or not Protocol.id(member.accountId) or seen[member.accountId] or not Protocol.string(member.name,128) or member.slot~=index or not Protocol.integer(member.team,0,6) or not Protocol.tuning(member.tuning) then return false end
        seen[member.accountId]=true
    end
    return true
end
function Protocol.input(value,slotCount)
    return type(value)=='table' and Protocol.integer(value.seq,1,4294967295) and Protocol.integer(value.frame,1,54012) and (
        ((value.kind==0 or value.kind==1) and Protocol.integer(value.action,1,20) and value.value==0)
        or (value.kind==2 and value.action==0 and Protocol.integer(value.value,1,slotCount))
    )
end
local function u16(value) return string.char(value%256,math.floor(value/256)%256) end
local function u32(value) return u16(value%65536)..u16(math.floor(value/65536)) end
local function uuidBytes(id)
    return (id:gsub('-',''):gsub('%x%x',function(hex) return string.char(tonumber(hex,16)) end))
end
function Protocol.encodeInput(matchId,firstSeq,events)
    if not Protocol.id(matchId) or not Protocol.integer(firstSeq,1,4294967295) or type(events)~='table' or #events<1 or #events>64 or firstSeq+#events-1>4294967295 then return nil,'Invalid input batch' end
    local baseFrame=events[1].frame
    if not Protocol.integer(baseFrame,1,54012) then return nil,'Invalid input frame' end
    local out={'TCM1',string.char(1,0),u16(#events),uuidBytes(matchId),u32(firstSeq),u32(baseFrame)}
    local previous=baseFrame
    for index,event in ipairs(events) do
        if not Protocol.input({seq=firstSeq+index-1,frame=event.frame,kind=event.kind,action=event.action,value=event.value},10) or event.frame<previous or event.frame-baseFrame>65535 then return nil,'Invalid input event' end
        out[#out+1]=u16(event.frame-baseFrame)..string.char(event.kind,event.action)..u16(event.value)..u16(0)
        previous=event.frame
    end
    return table.concat(out)
end
return Protocol
