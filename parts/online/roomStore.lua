local Protocol=require'parts.online.protocol'
local RoomStore={}
RoomStore.__index=RoomStore
function RoomStore.new(report)
    return setmetatable({snapshot=false,rooms={},chat={},serial=0,listSerial=0,listPending=false,report=report},RoomStore)
end
function RoomStore:apply(snapshot)
    if not Protocol.room(snapshot) then self.report('INVALID_ROOM','The server returned an invalid room snapshot.') return false end
    if self.snapshot and self.snapshot.id==snapshot.id and snapshot.revision<self.snapshot.revision then return true end
    self.snapshot=snapshot
    self.serial=self.serial+1
    return true
end
function RoomStore:setList(data)
    self.listPending=false
    if type(data)~='table' or type(data.rooms)~='table' or #data.rooms>10 then self.report('INVALID_ROOMS','The room list is invalid.') return end
    for _,room in ipairs(data.rooms) do
        if type(room)~='table' or not Protocol.id(room.id) or not Protocol.string(room.name,128) or not Protocol.integer(room.revision,0,9007199254740991) or not Protocol.integer(room.players,0,10) or not Protocol.integer(room.spectators,0,20) or (room.track~='authoritative' and room.track~='relay') or not Protocol.settings(room.settings) or type(room.passwordProtected)~='boolean' then self.report('INVALID_ROOMS','The room list contains an invalid entry.') return end
    end
    self.rooms=data.rooms
    self.listSerial=self.listSerial+1
end
function RoomStore:member(id)
    if not self.snapshot then return end
    for _,member in ipairs(self.snapshot.members) do if member.id==id then return member end end
end
function RoomStore:clear()
    self.snapshot=false
    self.chat={}
    self.serial=self.serial+1
end
function RoomStore:event(kind,data)
    if kind=='room.snapshot' then
        if type(data)~='table' or type(data.room)~='table' or data.roomId~=data.room.id or data.roomRevision~=data.room.revision then self.report('INVALID_ROOM','The revisioned room snapshot envelope is invalid.') return false end
        return self:apply(data.room)
    end
    if not self.snapshot or type(data)~='table' or data.roomId~=self.snapshot.id then return false end
    if kind=='room.closed' then
        self:clear()
    elseif kind=='room.chat' then
        local id=data.accountId
        if not Protocol.id(id) or not Protocol.string(data.text,512) then self.report('INVALID_CHAT','An invalid chat message was isolated.') return false end
        local member=self:member(id)
        self.chat[#self.chat+1]={id=id,name=member and member.name or id,text=data.text}
        if #self.chat>128 then table.remove(self.chat,1) end
        self.serial=self.serial+1
    end
    return true
end
return RoomStore
