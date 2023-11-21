local floor=math.floor
local char,byte=string.char,string.byte
local ins=table.insert

local GAME=GAME

local DATA={}
-- Sep symbol: 33 (!)
-- Safe char: 34~126
--[[
    Count: 34~96
    Block: 97~125
    Encode: A[B] sequence, A = block ID, B = repeat times, no B means do not repeat.
    Example: "abcdefg" is [SZJLTOI], "a^aDb)" is [Z*63,Z*37,S*10]
]]
function DATA.copySequence(bag)
    local str=""

    local count=1
    for i=1,#bag+1 do
        if bag[i+1]~=bag[i] or count==64 then
            str=str..char(96+bag[i])
            if count>1 then
                str=str..char(32+count)
                count=1
            end
        else
            count=count+1
        end
    end

    return str
end
function DATA.pasteSequence(str)
    local bag={}
    local b,reg
    for i=1,#str do
        b=byte(str,i)
        if not reg then
            if b>=97 and b<=125 then
                reg=b-96
            else
                return
            end
        else
            if b>=97 and b<=125 then
                ins(bag,reg)
                reg=b-96
            elseif b>=34 and b<=96 then
                for _=1,b-32 do
                    ins(bag,reg)
                end
                reg=false
            end
        end
    end
    if reg then
        ins(bag,reg)
    end
    return true,bag
end

local fieldMeta={__index=function(self,h)
    for i=#self+1,h do
        self[i]={0,0,0,0,0,0,0,0,0,0}
    end
    return self[h]
end}
function DATA.newBoard(f)-- Generate a new board
    return setmetatable(f and TABLE.shift(f) or{},fieldMeta)
end
function DATA.copyBoard(F)-- Copy the [page] board
    local str=""

    -- Encode field
    for y=1,#F do
        local S=""
        local L=F[y]
        for x=1,10 do
            S=S..char(L[x]+1)
        end
        str=str..S
    end
    return STRING.packBin(str)
end
function DATA.copyBoards(field)
    local out={}
    for i=1,#field do
        out[i]=DATA.copyBoard(field[i])
    end
    return table.concat(out,"!")
end
function DATA.pasteBoard(str)-- Paste [str] data to [page] board
    local F=DATA.newBoard()

    -- Decode
    str=STRING.unpackBin(str)
    if not str then return end

    local fX,fY=1,1-- *ptr for Field(r*10+(c-1))
    local p=1
    local lineLimit=126
    while true do
        local b=byte(str,p)-- 1byte

        -- Str end
        if not b then
            if fX~=1 then
                return
            else
                break
            end
        end

        local id=b%32-1-- Block id
        if id>26 then return end-- Illegal blockid
        b=floor(b/32)-- Mode id

        F[fY][fX]=id
        if fX<10 then
            fX=fX+1
        else
            fY=fY+1
            if fY>lineLimit then break end
            fX=1
        end
        p=p+1
    end

    return true,F,#str>lineLimit*10
end

--[[
    Mission: 34~114
    Count: 115~126
    Encode: [A] or [AB] sequence, A = mission ID, B = repeat times, no B means do not repeat.

    _1=01,_2=02,_3=03,_4=04,
    A1=05,A2=06,A3=07,A4=08,
    PC=09,
    Z1=11,Z2=12,Z3=13,
    S1=21,S2=22,S3=23,
    J1=31,J2=32,J3=33,
    L1=41,L2=42,L3=43,
    T1=51,T2=52,T3=53,
    O1=61,O2=62,O3=63,O4=64,
    I1=71,I2=72,I3=73,I4=74,
]]
function DATA.copyMission(mission)
    local _
    local str=""

    local count=1
    for i=1,#mission+1 do
        if mission[i+1]~=mission[i] or count==13 then
            _=33+mission[i]
            str=str..char(_)
            if count>1 then
                str=str..char(113+count)
                count=1
            end
        else
            count=count+1
        end
    end

    return str
end
function DATA.pasteMission(str)
    local b
    local mission={}
    local reg
    for i=1,#str do
        b=byte(str,i)
        if not reg then
            if b>=34 and b<=114 then
                reg=b-33
            else
                return
            end
        else
            if b>=34 and b<=114 then
                if ENUM_MISSION[reg] then
                    ins(mission,reg)
                    reg=b-33
                else
                    TABLE.cut(mission)
                    return
                end
            elseif b>=115 and b<=126 then
                for _=1,b-113 do
                    ins(mission,reg)
                end
                reg=false
            end
        end
    end
    if reg then
        ins(mission,reg)
    end
    return true,mission
end

function DATA.copyQuestArgs(custom_env)
    local ENV=custom_env
    local str=""..
        ENV.holdCount..
        (ENV.ospin and "O" or "Z")..
        (ENV.missionKill and "M" or "Z")..
        ENV.sequence
    return str
end
function DATA.pasteQuestArgs(str)
    if #str<4 then return end
    local ENV={}
    ENV.holdCount=  MATH.clamp(str:byte(1)-48,0,26)
    ENV.ospin=      str:byte(2)~=90
    ENV.missionKill=str:byte(3)~=90
    ENV.sequence=   str:sub(4)
    if select(2,require"parts.player.seqGenerators"(ENV.sequence)) then
        MES.new('warn',text.invalidSequence)
        ENV.sequence='bag'
    end
    return true,ENV
end

local function _encode(t)
    if t<128 then return char(t) end
    local buffer2=char(t%128)
    t=floor(t/128)
    while t>=128 do
        buffer2=char(128+t%128)..buffer2
        t=floor(t/128)
    end
    return char(128+t)..buffer2
end
local function _decode(str,p)
    local ret=0
    repeat
        local b=byte(str,p)
        p=p+1
        ret=ret*128+(b<128 and b or b-128)
    until b<128
    return ret,p
end
--[[
    Replay file:
    a zlib-compressed json table

    Replay data format (table):
        {frame,event, frame,event, ...}

    Replay data format (byte): (1 byte each period)
        dt, event, dt, event, ...
    all data range from 0 to 127
    large value will be encoded as 1xxxxxxx(high)-1xxxxxxx-...-0xxxxxxx(low)

    Example (decoded):
        6,1, 20,-1, 0,2, 26,-2, 872,4, ...
    This means:
        Press key1 at 6f
        Release key1 at 26f (6+20)
        Press key2 at the same time (26+0)
        Release key 2 after 26 frame (26+26)
        Press key 4 after 872 frame (52+872)
        ...
]]
function DATA.dumpRecording(list,ptr)
    local out=""
    local buffer=""
    if not ptr then ptr=1 end
    local prevFrm=list[ptr-2] or 0
    while list[ptr] do
        -- Flush buffer
        if #buffer>10 then
            out=out..buffer
            buffer=""
        end

        -- Encode time
        local t=list[ptr]-prevFrm
        prevFrm=list[ptr]
        buffer=buffer.._encode(t)

        -- Encode event
        buffer=buffer.._encode(list[ptr+1])

        -- Step
        ptr=ptr+2
    end
    return out..buffer,ptr
end
function DATA.pumpRecording(str,L)
    local len=#str
    local p=1

    local curFrm=L[#L-1] or 0
    while p<=len do
        local code,event
        -- Read delta time
        code,p=_decode(str,p)
        curFrm=curFrm+code
        ins(L,curFrm)

        event,p=_decode(str,p)
        ins(L,event)
    end
end
do-- function DATA.saveReplay()
    local function _getModList()
        local res={}
        for number,sel in next,GAME.mod do
            if sel>0 then
                ins(res,{MODOPT[number].no,sel})
            end
        end
        return res
    end
    function DATA.saveReplay()
        -- Filtering modes that cannot be saved
        if GAME.initPlayerCount~=1 then
            MES.new('error',"Cannot save recording of more than 1 player now!")
            return
        end

        -- Write file
        local fileName=os.date("replay/%Y_%m_%d_%H%M%S.rep")
        if not love.filesystem.getInfo(fileName) then
            local metadata={
                date=os.date("%Y/%m/%d %H:%M:%S"),
                mode=GAME.curModeName,
                version=VERSION.string,
                player=USERS.getUsername(USER.uid),
                seed=GAME.seed,
                setting=GAME.setting,
                mod=_getModList(),
                tasUsed=GAME.tasUsed,
            }
            if GAME.curMode.savePrivate then
                metadata.private=GAME.curMode.savePrivate()
            end
            love.filesystem.write(fileName,
                love.data.compress('string','zlib',
                    JSON.encode(metadata).."\n"..
                    DATA.dumpRecording(GAME.rep)
                )
            )
            ins(REPLAY,1,DATA.parseReplay(fileName))
            return true
        else
            MES.new('error',"Save failed: File already exists")
        end
    end
end
function DATA.parseReplay(fileName,ifFull)
    local fileData
    -- Read file
    fileData=love.filesystem.read(fileName)
    return DATA.parseReplayData(fileName,fileData,ifFull)
end
function DATA.parseReplayData(fileName,fileData,ifFull)
    local success,metaData
    local rep={-- unavailable replay object
        fileName=fileName,
        available=false,
    }

    if not (fileData and #fileData>0) then return rep end-- goto BREAK_cannotParse

    -- Decompress file
    success,fileData=pcall(love.data.decompress,'string','zlib',fileData)
    if not success then return rep end-- goto BREAK_cannotParse

    -- Load metadata
    metaData,fileData=STRING.readLine(fileData)
    metaData=JSON.decode(metaData)
    if not metaData then return rep end-- goto BREAK_cannotParse

    -- Convert ancient replays
    metaData.mode=MODE_UPDATE_MAP[metaData.mode] or metaData.mode
    if not MODES[metaData.mode] then return rep end-- goto BREAK_cannotParse

    -- Create replay object
    rep={
        fileName=fileName,
        available=true,

        date=metaData.date,
        mode=metaData.mode,
        version=metaData.version,
        player=metaData.player,

        seed=metaData.seed,
        setting=metaData.setting,
        mod=metaData.mod,
        tasUsed=metaData.tasUsed,
    }
    if ifFull then rep.data=fileData end
    if metaData.private then
        rep.private=metaData.private
    end
    return rep
end
return DATA
