local moduleName=... or 'Zframework.transport'
local framework=moduleName:match('^(.*)%.transport$') or 'Zframework'
local JSON=require(framework..'.json')
local Transport={}
local Client={}
Client.__index=Client
local system=rawget(_G,'SYSTEM') or love.system.getOS()
if system=='OS X' then system='macOS' end
local isWeb=system=='Web'
Transport.isWeb=isWeb
local ffi,library,loadError
local JS

local function failure(code,message)
    return {code=code,message=message}
end
local commandErrors={
    [-1]=failure('INVALID_ARGUMENT','Transport command is invalid.'),
    [-2]=failure('TRANSPORT_CLOSED','Transport client is closed.'),
    [-3]=failure('RESOURCE_LIMIT','Transport command exceeds a bounded resource limit.'),
    [-4]=failure('REQUEST_ID_REUSED','Transport request IDs must increase and cannot be reused.'),
    [-5]=failure('UNKNOWN_OPERATION','Transport operation is no longer active.'),
}
local function encode(value)
    local ok,result=pcall(JSON.encode,value)
    if ok and type(result)=='string' then return result end
    return nil,failure('INVALID_ARGUMENT','Transport parameters are not JSON encodable.')
end
local function decode(value)
    local ok,result=pcall(JSON.decode,value)
    if ok and type(result)=='table' then return result end
    return nil,failure('TRANSPORT_PROTOCOL','Transport returned malformed event data.')
end
local function base64(value)
    return love.data.encode('string','base64',value)
end
local function unbase64(value)
    return love.data.decode('string','base64',value)
end

local function requestOptions(options)
    if type(options)~='table' or type(options.url)~='string' or #options.url>4096 then return false end
    if options.timeout~=nil and (type(options.timeout)~='number' or options.timeout~=options.timeout or options.timeout<.1 or options.timeout>120) then return false end
    if options.headers~=nil then
        if type(options.headers)~='table' then return false end
        local count,bytes=0,0
        for key,value in pairs(options.headers) do
            if type(key)~='string' or type(value)~='string' then return false end
            count=count+1; bytes=bytes+#key+#value
            if count>32 or bytes>16384 then return false end
        end
    end
    return true
end

if isWeb then
    JS=rawget(_G,'JS') or require(framework..'.js')
    local source=love.filesystem.read(framework:gsub('%.','/')..'/transport_web.js')
    if source then JS.callJS('eval('..encode(source)..');') else loadError='Browser transport source is absent from the game package.' end
else
    local ok,result=pcall(require,'ffi')
    if ok then
        ffi=result
        ffi.cdef[[
            void *tn_client_new(const unsigned char *json, size_t len);
            void tn_client_destroy(void *client);
            int tn_command(void *client, const unsigned char *json, size_t len);
            int tn_poll(void *client, unsigned char *out, size_t capacity);
            int tn_callback_begin(void *client, const unsigned char *json, size_t len, unsigned char *out, size_t capacity);
            int tn_secret(const unsigned char *json, size_t len, unsigned char *out, size_t capacity);
            int tn_random(unsigned char *out, size_t count);
            int tn_pkce(const unsigned char *verifier, size_t len, unsigned char *out, size_t capacity);
        ]]
    else loadError='LuaJIT FFI is unavailable.' end
end

local function loadNative(explicit)
    if library then return library end
    if not ffi then return nil end
    if system=='iOS' then
        local ok=pcall(function() return ffi.C.tn_client_new end)
        if ok then library=ffi.C; return library end
        loadError='The iOS package does not export its statically linked native transport.'
        return nil
    end
    local filename=system=='Windows' and 'techmino_transport.dll' or system=='macOS' and 'libtechmino_transport.dylib' or 'libtechmino_transport.so'
    local base=love.filesystem.getSourceBaseDirectory()
    local candidates={}
    local function add(path) if path and #path>0 then candidates[#candidates+1]=path end end
    add(explicit)
    add(os.getenv('TECHMINO_TRANSPORT_LIBRARY'))
    local appdir=os.getenv('APPDIR')
    if appdir then add(appdir..'/lib/'..filename) end
    add(base..'/'..filename)
    add(base..'/lib/'..filename)
    add(base..'/../lib/'..filename)
    if system=='macOS' then add(base..'/../Frameworks/'..filename); add(base..'/Contents/Frameworks/'..filename) end
    add(filename)
    for i=1,#candidates do
        local ok,result=pcall(ffi.load,candidates[i])
        if ok then
            local valid=pcall(function() return result.tn_client_new end)
            if valid then library=result; return library end
        end
    end
    loadError='The package cannot load its native verified transport dependency.'
end

local function webCall(command)
    if loadError then return nil,failure('WEB_BRIDGE_UNAVAILABLE',loadError) end
    local json,err=encode(command)
    if not json then return nil,err end
    local path=encode(love.filesystem.getSaveDirectory())
    love.filesystem.remove('__transport_reply')
    JS.callJS('(function(){try{window.TechminoTransport.bridge('..json..','..path..');}catch(_){}})();')
    local data=love.filesystem.read('__transport_reply')
    love.filesystem.remove('__transport_reply')
    if not data then return nil,failure('WEB_BRIDGE_UNAVAILABLE','The browser FS bridge did not return an operation result.') end
    local reply,parseError=decode(data)
    if not reply then return nil,parseError end
    if not reply.ok then return nil,reply.error end
    return reply.result
end

function Transport.new(options)
    options=options or {}
    if type(options)~='table' then return nil,commandErrors[-1] end
    if isWeb then
        local id,err=webCall{call='create'}
        if not id then return nil,err end
        return setmetatable({webId=id,lastId=0,callbacks={}},Client)
    end
    local native=loadNative(options.libraryPath)
    if not native then return nil,failure('NATIVE_LIBRARY_UNAVAILABLE',loadError) end
    local caPem=options.caPem
    if not caPem then
        local caFile=os.getenv('TECHMINO_TRANSPORT_CA_FILE')
        if caFile then
            local file=io.open(caFile,'rb')
            if not file then return nil,failure('TLS_CONFIGURATION','The configured trust-root file cannot be opened.') end
            caPem=file:read(65537); file:close()
            if not caPem or #caPem>65536 then return nil,failure('TLS_CONFIGURATION','The configured trust-root file exceeds its bound.') end
        end
    end
    local json='{}'
    if caPem then json=encode{caPem=caPem} end
    if not json then return nil,failure('INVALID_ARGUMENT','Invalid native TLS options.') end
    local handle=native.tn_client_new(json,#json)
    if handle==nil then return nil,failure('TLS_CONFIGURATION','Native verified TLS transport could not be initialized.') end
    handle=ffi.gc(handle,function(value) native.tn_client_destroy(value) end)
    return setmetatable({handle=handle,lastId=0,callbacks={},buffer=ffi.new('unsigned char[?]',8192),capacity=8192},Client)
end

function Client:_nextId(requested)
    local id=requested or self.lastId+1
    if type(id)~='number' or id%1~=0 or id<=self.lastId or id>9007199254740991 then return nil,commandErrors[-4] end
    self.lastId=id
    return id
end
function Client:_command(command)
    if self.destroyed then return false,commandErrors[-2] end
    if isWeb then
        command.client=self.webId
        local result,err=webCall(command)
        if result==nil then return false,err end
        return result
    end
    local json,err=encode(command)
    if not json then return false,err end
    local code=library.tn_command(self.handle,json,#json)
    if code~=0 then return false,commandErrors[code] or failure('TRANSPORT_FAILED','Native transport rejected the command.') end
    return true
end
function Client:request(options)
    if not requestOptions(options) then return nil,commandErrors[-1] end
    local id,err=self:_nextId(options.id)
    if not id then return nil,err end
    if options.body~=nil and type(options.body)~='string' then return nil,commandErrors[-1] end
    if options.body and #options.body>2097152 then return nil,commandErrors[-3] end
    local command={op='request',id=id,url=options.url,method=options.method or 'GET',bodyBase64=base64(options.body or ''),timeoutMs=math.floor((options.timeout or 20)*1000)}
    if options.headers and next(options.headers) then command.headers=options.headers end
    if isWeb then command.credentials=options.credentials or 'omit' end
    local ok; ok,err=self:_command(command)
    if not ok then return nil,err end
    return id
end
function Client:connect(options)
    if not requestOptions(options) then return nil,commandErrors[-1] end
    local id,err=self:_nextId(options.id)
    if not id then return nil,err end
    local command={op='connect',id=id,url=options.url,timeoutMs=math.floor((options.timeout or 20)*1000)}
    if options.headers and next(options.headers) then command.headers=options.headers end
    local ok; ok,err=self:_command(command)
    if not ok then return nil,err end
    return id
end
function Client:send(id,payload,kind)
    if type(payload)~='string' or (kind and kind~='text' and kind~='binary') then return false,commandErrors[-1] end
    if #payload>262144 then return false,commandErrors[-3] end
    return self:_command{op='send',id=id,dataBase64=base64(payload),binary=kind=='binary'}
end
function Client:ping(id,payload)
    if payload~=nil and type(payload)~='string' then return false,commandErrors[-1] end
    if payload and #payload>125 then return false,commandErrors[-3] end
    return self:_command{op='ping',id=id,dataBase64=base64(payload or '')}
end
function Client:close(id,code,reason)
    if reason and (type(reason)~='string' or #reason>123) then return false,commandErrors[-1] end
    return self:_command{op='close',id=id,code=code or 1000,reason=reason or ''}
end
function Client:cancel(id)
    self.callbacks[id]=nil
    return self:_command{op='cancel',id=id}
end
function Client:callbackCancel(id) return self:cancel(id) end
function Client:callbackBegin(product,state,issuer,timeout,redirectUri)
    if self.destroyed then return nil,commandErrors[-2] end
    local id,err=self:_nextId()
    if not id then return nil,err end
    local command={id=id,product=product,state=state,issuer=issuer,timeoutSeconds=timeout or 180}
    local result
    if isWeb then
        command.op='callback_begin'; command.client=self.webId; command.redirectUri=redirectUri
        result,err=webCall(command)
    else
        local json; json,err=encode(command)
        if not json then return nil,err end
        local buffer=ffi.new('unsigned char[?]',16384)
        local count=library.tn_callback_begin(self.handle,json,#json,buffer,16384)
        if count<=0 then return nil,failure('CALLBACK_FAILED','Native callback receiver could not be started.') end
        result,err=decode(ffi.string(buffer,count))
        if result and result.error then return nil,result.error end
    end
    if not result then return nil,err end
    self.callbacks[id]={issuer=issuer,redirectUri=result.redirectUri}
    return result
end
function Client:openAuthorization(url,callbackId,authorizationOrigin)
    local callback=self.callbacks[callbackId]
    if not callback or type(url)~='string' then return false,commandErrors[-5] end
    local trusted=authorizationOrigin or callback.issuer
    if type(trusted)~='string' or not trusted:match('^https?://[^/@%s?#]+$') then return false,commandErrors[-1] end
    if isWeb then return self:_command{op='open_authorization',id=callbackId,url=url,authorizationOrigin=trusted} end
    if url:match('^(https?://[^/]+)')~=trusted then return false,failure('INVALID_AUTHORIZATION_URL','Authorization URL does not belong to the configured account website.') end
    local ok,result=pcall(love.system.openURL,url)
    if not ok or not result then return false,failure('BROWSER_OPEN_FAILED','The system browser could not be opened.') end
    return true
end
function Client:poll()
    if self.destroyed then return nil end
    local event,err
    if isWeb then event,err=webCall{call='poll',client=self.webId}
    else
        local count=library.tn_poll(self.handle,self.buffer,self.capacity)
        if count<0 and count>-4194305 then
            self.capacity=-count; self.buffer=ffi.new('unsigned char[?]',self.capacity)
            count=library.tn_poll(self.handle,self.buffer,self.capacity)
        end
        if count==0 then return nil end
        if count<0 then return {kind='error',id=0,code='TRANSPORT_FAILED',message='Native transport event buffer is invalid.'} end
        event,err=decode(ffi.string(self.buffer,count))
    end
    if err then return {kind='error',id=0,code=err.code,message=err.message} end
    if not event then return nil end
    if event.bodyBase64 then event.body=unbase64(event.bodyBase64); event.bodyBase64=nil end
    if event.dataBase64 then event.data=unbase64(event.dataBase64); event.dataBase64=nil end
    if event.kind=='callback' or (event.kind=='error' and self.callbacks[event.id]) then self.callbacks[event.id]=nil end
    return event
end
function Client:destroy()
    if self.destroyed then return end
    if isWeb then webCall{call='destroy',client=self.webId}
    else ffi.gc(self.handle,nil); library.tn_client_destroy(self.handle); self.handle=nil end
    self.callbacks={}; self.destroyed=true
end

local function secret(operation,product,value)
    if value and (type(value)~='string' or #value>8192) then return {ok=false,mode='unavailable',code='INVALID_CREDENTIAL',message='Credential exceeds its protected storage bound.'} end
    if isWeb then return {ok=false,mode='memory_only',code='WEB_COOKIE_SESSION',message='Browser product sessions use HttpOnly cookies. Bearer credentials are never persisted by the game.'} end
    if not loadNative() then return {ok=false,mode='unavailable',code='NATIVE_LIBRARY_UNAVAILABLE',message=loadError} end
    local json,err=encode{op=operation,product=product,value=value}
    if not json then return {ok=false,mode='unavailable',code=err.code,message=err.message} end
    local buffer=ffi.new('unsigned char[?]',16384)
    local count=library.tn_secret(json,#json,buffer,16384)
    if count<=0 then return {ok=false,mode='unavailable',code='SECURE_STORE_UNAVAILABLE',message='The operating system protected credential store could not be accessed.'} end
    local result=decode(ffi.string(buffer,count))
    ffi.fill(buffer,16384,0)
    return result or {ok=false,mode='unavailable',code='SECURE_STORE_UNAVAILABLE',message='Credential store returned invalid data.'}
end
function Transport.secureStoreGet(product)
    local result=secret('get',product)
    local token=result.value; result.value=nil; result.ok=nil
    return token,result
end
function Transport.secureStoreSet(product,value)
    local result=secret('set',product,value)
    local ok=result.ok; result.ok=nil; result.value=nil
    return ok,result
end
function Transport.secureStoreDelete(product)
    local result=secret('delete',product)
    local ok=result.ok; result.ok=nil; result.value=nil
    return ok,result
end
function Transport.randomBytes(count)
    if type(count)~='number' or count%1~=0 or count<1 or count>4096 then return nil,commandErrors[-1] end
    if isWeb then
        local encoded,err=webCall{call='random',count=count}
        if not encoded then return nil,err end
        return unbase64(encoded)
    end
    if not loadNative() then return nil,failure('NATIVE_LIBRARY_UNAVAILABLE',loadError) end
    local buffer=ffi.new('unsigned char[?]',count)
    if library.tn_random(buffer,count)~=0 then return nil,failure('SECURE_RANDOM_FAILED','Operating system secure random generation failed.') end
    local result=ffi.string(buffer,count); ffi.fill(buffer,count,0)
    return result
end
function Transport.pkce(verifier)
    if type(verifier)~='string' or #verifier<43 or #verifier>128 or verifier:find('[^%w%-%._~]') then return nil,commandErrors[-1] end
    if isWeb then
        local challenge=base64(love.data.hash('sha256',verifier)):gsub('%+','-'):gsub('/','_'):gsub('=+$','')
        return challenge
    end
    if not loadNative() then return nil,failure('NATIVE_LIBRARY_UNAVAILABLE',loadError) end
    local buffer=ffi.new('unsigned char[?]',64)
    local count=library.tn_pkce(verifier,#verifier,buffer,64)
    if count<=0 then return nil,failure('PKCE_FAILED','S256 PKCE challenge could not be generated.') end
    return ffi.string(buffer,count)
end
return Transport
