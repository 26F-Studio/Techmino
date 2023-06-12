local int=math.floor
local char,byte=string.char,string.byte
local ins=table.insert

local BAG,FIELD,MISSION,CUSTOMENV,GAME=BAG,FIELD,MISSION,CUSTOMENV,GAME

local DATA={}
-- Sep symbol: 33 (!)
-- Safe char: 34~126
--[[
    Count: 34~96
    Block: 97~125
    Encode: A[B] sequence, A = block ID, B = repeat times, no B means do not repeat.
    Example: "abcdefg" is [SZJLTOI], "a^aDb)" is [Z*63,Z*37,S*10]
]]
function DATA.copySequence()
    local str=""

    local count=1
    for i=1,#BAG+1 do
        if BAG[i+1]~=BAG[i] or count==64 then
            str=str..char(96+BAG[i])
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
    TABLE.cut(BAG)
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
                ins(BAG,reg)
                reg=b-96
            elseif b>=34 and b<=96 then
                for _=1,b-32 do
                    ins(BAG,reg)
                end
                reg=false
            end
        end
    end
    if reg then
        ins(BAG,reg)
    end
    return true
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
function DATA.copyBoard(page)-- Copy the [page] board
    local F=FIELD[page or 1]
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
function DATA.copyBoards()
    local out={}
    for i=1,#FIELD do
        out[i]=DATA.copyBoard(i)
    end
    return table.concat(out,"!")
end
function DATA.pasteBoard(str,page)-- Paste [str] data to [page] board
    if not page then
        page=1
    end
    if not FIELD[page] then
        FIELD[page]=DATA.newBoard()
    end
    local F=FIELD[page]

    -- Decode
    str=STRING.unpackBin(str)
    if not str then return end

    local fX,fY=1,1-- *ptr for Field(r*10+(c-1))
    local p=1
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
        b=int(b/32)-- Mode id

        F[fY][fX]=id
        if fX<10 then
            fX=fX+1
        else
            fY=fY+1
            if fY>60 then break end
            fX=1
        end
        p=p+1
    end

    return true
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
function DATA.copyMission()
    local _
    local str=""

    local count=1
    for i=1,#MISSION+1 do
        if MISSION[i+1]~=MISSION[i] or count==13 then
            _=33+MISSION[i]
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
    TABLE.cut(MISSION)
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
                    ins(MISSION,reg)
                    reg=b-33
                else
                    TABLE.cut(MISSION)
                    return
                end
            elseif b>=115 and b<=126 then
                for _=1,b-113 do
                    ins(MISSION,reg)
                end
                reg=false
            end
        end
    end
    if reg then
        ins(MISSION,reg)
    end
    return true
end

function DATA.copyQuestArgs()
    local ENV=CUSTOMENV
    local str=""..
        ENV.holdCount..
        (ENV.ospin and "O" or "Z")..
        (ENV.missionKill and "M" or "Z")..
        ENV.sequence
    return str
end
function DATA.pasteQuestArgs(str)
    if #str<4 then return end
    local ENV=CUSTOMENV
    ENV.holdCount=  str:byte(1)-48
    ENV.ospin=      str:byte(2)~=90
    ENV.missionKill=str:byte(3)~=90
    ENV.sequence=   str:sub(4)
    return true
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
    local buffer,buffer2=""
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
        if t>=128 then
            buffer2=char(t%128)
            t=int(t/128)
            while t>=128 do
                buffer2=char(128+t%128)..buffer2
                t=int(t/128)
            end
            buffer=buffer..char(128+t)..buffer2
        else
            buffer=buffer..char(t)
        end

        -- Encode event
        t=list[ptr+1]
        if t>=128 then
            buffer2=char(t%128)
            t=int(t/128)
            while t>=128 do
                buffer2=char(128+t%128)..buffer2
                t=int(t/128)
            end
            buffer=buffer..char(128+t)..buffer2
        else
            buffer=buffer..char(t)
        end

        -- Step
        ptr=ptr+2
    end
    return out..buffer,ptr
end
function DATA.pumpRecording(str,L)
    local len=#str
    local p=1

    local curFrm=L[#L-1] or 0
    local code
    while p<=len do
        -- Read delta time
        code=0
        local b=byte(str,p)
        while b>=128 do
            code=code*128+b-128
            p=p+1
            b=byte(str,p)
        end
        curFrm=curFrm+code*128+b
        L[#L+1]=curFrm
        p=p+1

        local event=0
        b=byte(str,p)
        while b>=128 do
            event=event*128+b-128
            p=p+1
            b=byte(str,p)
        end
        L[#L+1]=event*128+b
        p=p+1
    end
end
do-- function DATA.saveReplay()
    local noRecList={"custom","solo","round","techmino"}
    local function _getModList()
        local res={}
        for _,v in next,GAME.mod do
            if v.sel>0 then
                ins(res,{v.no,v.sel})
            end
        end
        return res
    end
    function DATA.saveReplay()
        -- Filtering modes that cannot be saved
        for _,v in next,noRecList do
            if GAME.curModeName:find(v) then
                MES.new('error',"Cannot save recording of this mode now!")
                return
            end
        end

        -- Write file
        local fileName=os.date("replay/%Y_%m_%d_%H%M%S.rep")
        if not love.filesystem.getInfo(fileName) then
            love.filesystem.write(fileName,
                love.data.compress('string','zlib',
                    JSON.encode{
                        date=os.date("%Y/%m/%d %H:%M:%S"),
                        mode=GAME.curModeName,
                        version=VERSION.string,
                        player=USERS.getUsername(USER.uid),
                        seed=GAME.seed,
                        setting=GAME.setting,
                        mod=_getModList(),
                        tasUsed=GAME.tasUsed,
                    }.."\n"..
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
    return rep
end
return DATA
