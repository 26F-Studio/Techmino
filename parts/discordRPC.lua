local appId='1288557386700951554'

local ffi=require"ffi"

local RPC_C
if SYSTEM=='Windows' then
    local suc
    suc,RPC_C=pcall(ffi.load,"discord-rpc")
    if not (suc and RPC_C) then
        print("Failed to load Discord-RPC lib",RPC_C)
        MES.new('error',"Failed to load Discord-RPC lib")
        RPC_C=nil
    end
end

local RPC
if RPC_C then
    RPC={}
    ffi.cdef[[
        typedef struct DiscordRichPresence {
            const char* state;   /* max 128 bytes */
            const char* details; /* max 128 bytes */
            int64_t startTimestamp;
            int64_t endTimestamp;
            const char* largeImageKey;  /* max 32 bytes */
            const char* largeImageText; /* max 128 bytes */
            const char* smallImageKey;  /* max 32 bytes */
            const char* smallImageText; /* max 128 bytes */
            const char* partyId;        /* max 128 bytes */
            int partySize;
            int partyMax;
            const char* matchSecret;    /* max 128 bytes */
            const char* joinSecret;     /* max 128 bytes */
            const char* spectateSecret; /* max 128 bytes */
            int8_t instance;
        } DiscordRichPresence;

        typedef struct DiscordUser {
            const char* userId;
            const char* username;
            const char* discriminator;
            const char* avatar;
        } DiscordUser;

        typedef void (*readyPtr)(const DiscordUser* request);
        typedef void (*disconnectedPtr)(int errorCode, const char* message);
        typedef void (*erroredPtr)(int errorCode, const char* message);
        typedef void (*joinGamePtr)(const char* joinSecret);
        typedef void (*spectateGamePtr)(const char* spectateSecret);
        typedef void (*joinRequestPtr)(const DiscordUser* request);

        typedef struct DiscordEventHandlers {
            readyPtr ready;
            disconnectedPtr disconnected;
            erroredPtr errored;
            joinGamePtr joinGame;
            spectateGamePtr spectateGame;
            joinRequestPtr joinRequest;
        } DiscordEventHandlers;

        void Discord_Initialize(const char* applicationId,
                                DiscordEventHandlers* handlers,
                                int autoRegister,
                                const char* optionalSteamId);
        void Discord_Shutdown(void);
        void Discord_RunCallbacks(void);
        void Discord_UpdatePresence(const DiscordRichPresence* presence);
        void Discord_ClearPresence(void);
        void Discord_Respond(const char* userid, int reply);
        void Discord_UpdateHandlers(DiscordEventHandlers* handlers);
    ]]

    local function unpackDiscordUser(request)
        return ffi.string(request.userId),ffi.string(request.username),
            ffi.string(request.discriminator),ffi.string(request.avatar)
    end

    -- callback proxies
    -- note: callbacks are not JIT compiled (= SLOW), try to avoid doing performance critical tasks in them
    -- luajit.org/ext_ffi_semantics.html
    local ready_proxy=ffi.cast("readyPtr",function(request)
        if RPC.ready then
            RPC.ready(unpackDiscordUser(request))
        end
    end)

    local disconnected_proxy=ffi.cast("disconnectedPtr",function(errorCode,message)
        if RPC.disconnected then
            RPC.disconnected(errorCode,ffi.string(message))
        end
    end)

    local errored_proxy=ffi.cast("erroredPtr",function(errorCode,message)
        if RPC.errored then
            RPC.errored(errorCode,ffi.string(message))
        end
    end)

    local joinGame_proxy=ffi.cast("joinGamePtr",function(joinSecret)
        if RPC.joinGame then
            RPC.joinGame(ffi.string(joinSecret))
        end
    end)

    local spectateGame_proxy=ffi.cast("spectateGamePtr",function(spectateSecret)
        if RPC.spectateGame then
            RPC.spectateGame(ffi.string(spectateSecret))
        end
    end)

    local joinRequest_proxy=ffi.cast("joinRequestPtr",function(request)
        if RPC.joinRequest then
            RPC.joinRequest(unpackDiscordUser(request))
        end
    end)

    -- helpers
    local function checkArg(arg,argType,argName,func,maybeNil)
        assert(type(arg)==argType or (maybeNil and arg==nil),
            string.format("Argument \"%s\" to function \"%s\" has to be of type \"%s\"",
                argName,func,argType))
    end

    local function checkStrArg(arg,maxLen,argName,func,maybeNil)
        if maxLen then
            assert(type(arg)=="string" and arg:len()<=maxLen or (maybeNil and arg==nil),
                string.format("Argument \"%s\" of function \"%s\" has to be of type string with maximum length %d",
                    argName,func,maxLen))
        else
            checkArg(arg,"string",argName,func,true)
        end
    end

    local function checkIntArg(arg,maxBits,argName,func,maybeNil)
        maxBits=math.min(maxBits or 32,52) -- lua number (double) can only store integers < 2^53
        local maxVal=2^(maxBits-1) -- assuming signed integers, which, for now, are the only ones in use
        assert(type(arg)=="number" and math.floor(arg)==arg
            and arg<maxVal and arg>=-maxVal
            or (maybeNil and arg==nil),
            string.format("Argument \"%s\" of function \"%s\" has to be a whole number <= %d",
                argName,func,maxVal))
    end

    -- function wrappers
    function RPC.initialize(applicationId,autoRegister,optionalSteamId)
        local func="discordRPC.Initialize"
        checkStrArg(applicationId,nil,"applicationId",func)
        checkArg(autoRegister,"boolean","autoRegister",func)
        if optionalSteamId~=nil then
            checkStrArg(optionalSteamId,nil,"optionalSteamId",func)
        end

        local eventHandlers=ffi.new("struct DiscordEventHandlers")
        eventHandlers.ready=ready_proxy
        eventHandlers.disconnected=disconnected_proxy
        eventHandlers.errored=errored_proxy
        eventHandlers.joinGame=joinGame_proxy
        eventHandlers.spectateGame=spectateGame_proxy
        eventHandlers.joinRequest=joinRequest_proxy

        RPC_C.Discord_Initialize(applicationId,eventHandlers,
            autoRegister and 1 or 0,optionalSteamId)
    end

    function RPC.shutdown()
        RPC_C.Discord_Shutdown()
    end

    function RPC.runCallbacks()
        RPC_C.Discord_RunCallbacks()
    end
    -- http://luajit.org/ext_ffi_semantics.html#callback :
    -- It is not allowed, to let an FFI call into a C function (runCallbacks)
    -- get JIT-compiled, which in turn calls a callback, calling into Lua again (e.g. discordRPC.ready).
    -- Usually this attempt is caught by the interpreter first and the C function
    -- is blacklisted for compilation.
    -- solution:
    -- "Then you'll need to manually turn off JIT-compilation with jit.off() for
    -- the surrounding Lua function that invokes such a message polling function."
    jit.off(RPC.runCallbacks)

    function RPC.updatePresence(presence)
        local func="discordRPC.updatePresence"
        checkArg(presence,"table","presence",func)

        -- -1 for string length because of 0-termination
        checkStrArg(presence.state,127,"presence.state",func,true)
        checkStrArg(presence.details,127,"presence.details",func,true)

        checkIntArg(presence.startTimestamp,64,"presence.startTimestamp",func,true)
        checkIntArg(presence.endTimestamp,64,"presence.endTimestamp",func,true)

        checkStrArg(presence.largeImageKey,31,"presence.largeImageKey",func,true)
        checkStrArg(presence.largeImageText,127,"presence.largeImageText",func,true)
        checkStrArg(presence.smallImageKey,31,"presence.smallImageKey",func,true)
        checkStrArg(presence.smallImageText,127,"presence.smallImageText",func,true)
        checkStrArg(presence.partyId,127,"presence.partyId",func,true)

        checkIntArg(presence.partySize,32,"presence.partySize",func,true)
        checkIntArg(presence.partyMax,32,"presence.partyMax",func,true)

        checkStrArg(presence.matchSecret,127,"presence.matchSecret",func,true)
        checkStrArg(presence.joinSecret,127,"presence.joinSecret",func,true)
        checkStrArg(presence.spectateSecret,127,"presence.spectateSecret",func,true)

        checkIntArg(presence.instance,8,"presence.instance",func,true)

        local cpresence=ffi.new("struct DiscordRichPresence")
        cpresence.state=presence.state
        cpresence.details=presence.details
        cpresence.startTimestamp=presence.startTimestamp or 0
        cpresence.endTimestamp=presence.endTimestamp or 0
        cpresence.largeImageKey=presence.largeImageKey
        cpresence.largeImageText=presence.largeImageText
        cpresence.smallImageKey=presence.smallImageKey
        cpresence.smallImageText=presence.smallImageText
        cpresence.partyId=presence.partyId
        cpresence.partySize=presence.partySize or 0
        cpresence.partyMax=presence.partyMax or 0
        cpresence.matchSecret=presence.matchSecret
        cpresence.joinSecret=presence.joinSecret
        cpresence.spectateSecret=presence.spectateSecret
        cpresence.instance=presence.instance or 0

        RPC_C.Discord_UpdatePresence(cpresence)
    end

    function RPC.clearPresence()
        RPC_C.Discord_ClearPresence()
    end

    local replyMap={
        no=0,
        yes=1,
        ignore=2,
    }

    -- maybe let reply take ints too (0, 1, 2) and add constants to the module
    function RPC.respond(userId,reply)
        checkStrArg(userId,nil,"userId","discordRPC.respond")
        assert(replyMap[reply],"Argument 'reply' to discordRPC.respond must be 'yes'|'no'|'ignore'")
        RPC_C.Discord_Respond(userId,replyMap[reply])
    end

    -- garbage collection callback
    RPC.gcDummy=newproxy(true)
    getmetatable(RPC.gcDummy).__gc=function()
        RPC.shutdown()
        ready_proxy:free()
        disconnected_proxy:free()
        errored_proxy:free()
        joinGame_proxy:free()
        spectateGame_proxy:free()
        joinRequest_proxy:free()
    end

    function RPC.ready(userId,username,discriminator,avatar)
        print(string.format("Discord: ready (%s,%s,%s,%s)",userId,username,discriminator,avatar))
    end
    function RPC.disconnected(errorCode,message)
        print(string.format("Discord: disconnected (%d: %s)",errorCode,message))
    end
    function RPC.errored(errorCode,message)
        print(string.format("Discord: error (%d: %s)",errorCode,message))
    end
    function RPC.joinGame(joinSecret)
        print(string.format("Discord: join (%s)",joinSecret))
    end
    function RPC.spectateGame(spectateSecret)
        print(string.format("Discord: spectate (%s)",spectateSecret))
    end
    function RPC.joinRequest(userId,username,discriminator,avatar)
        print(string.format("Discord: join request (%s,%s,%s,%s)",userId,username,discriminator,avatar))
        RPC.respond(userId,'yes')
    end
    RPC.initialize(appId,true)
end

local MyRPC={
    C=RPC_C,
    RPC=RPC,
    presence={
        startTimestamp=os.time(),
        state="Loading...",
        details="",
        largeImageKey='',
        largeImageText="Techmino",
        smallImageKey='',
        smallImageText="",
    },
}

---@class DiscordRPC.presence
---@field state? string
---@field details? string
---@field startTimestamp? number
---@field endTimestamp? number
---@field largeImageKey? string
---@field largeImageText? string
---@field smallImageKey? string
---@field smallImageText? string
---@field partyId? string
---@field partySize? number
---@field partyMax? number
---@field matchSecret? string
---@field joinSecret? string
---@field spectateSecret? string
---@field instance? number

---@overload fun()
---@overload fun(state: DiscordRPC.presence)
---@param state string
---@param details string
function MyRPC.update(state,details)
    if state then
        for k,v in next,
        type(state)=='string'
        and {state=state,details=details}
        or state
        do
            MyRPC.presence[k]=v
        end
    end
    if RPC then RPC.updatePresence(MyRPC.presence) end
end

return MyRPC
