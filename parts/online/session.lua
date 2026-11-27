local Session={}
Session.__index=Session

local function epoch(value)
    if type(value)~='string' or not value:match('Z$') then return end
    local y,m,d,h,n,s=value:match('^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)')
    y,m,d,h,n,s=tonumber(y),tonumber(m),tonumber(d),tonumber(h),tonumber(n),tonumber(s)
    if not y or m<1 or m>12 or d<1 or d>31 or h>23 or n>59 or s>59 then return end
    y=y-(m<=2 and 1 or 0)
    local era=math.floor(y/400)
    local yoe=y-era*400
    local mp=m+(m>2 and -3 or 9)
    local doy=math.floor((153*mp+2)/5)+d-1
    local days=era*146097+yoe*365+math.floor(yoe/4)-math.floor(yoe/100)+doy-719468
    return days*86400+h*3600+n*60+s
end
local function origin(value)
    if type(value)~='string' or #value>2048 then return end
    value=value:gsub('/+$','')
    if value:match('^https://[^/%s?#]+$') or value:match('^http://127%.0%.0%.1:%d+$') or value:match('^http://localhost:%d+$') or value:match('^http://%[::1%]:%d+$') then return value end
end
local function safeError(value,default)
    if type(value)=='table' and type(value.code)=='string' then
        return {code=value.code,message=type(value.message)=='string' and value.message:sub(1,256) or value.code}
    end
    return {code=default or 'REQUEST_FAILED',message='The request could not be completed.'}
end
local function base64url(bytes)
    return (love.data.encode('string','base64',bytes):gsub('%+','-'):gsub('/','_'):gsub('=',''):gsub('%s',''))
end

function Session.new(options)
    local self=setmetatable({
        productId=assert(options.productId),transportModule=options.transport,JSON=options.json,
        notify=options.notify or function() end,onSession=options.onSession or function() end,
        pending={},pendingCount=0,status='signed_out',storage={mode='memory_only'},
        user=false,accessToken=false,refreshToken=false,expiresAt=0,generation=0,
        config={},error=false,login=false,refreshing=false,closed=false,
    },Session)
    local ok,module=pcall(require,options.transport)
    if ok then
        self.driver=module
        local client,err=module.new()
        self.client=client
        if not client then self.error=safeError(err,'TRANSPORT_UNAVAILABLE') end
    else
        self.error={code='TRANSPORT_UNAVAILABLE',message='The packaged online transport is unavailable; offline play is unaffected.'}
    end
    local transportError=self.error
    self:configure(options.config or {})
    if not self.client then self.error=transportError end
    if self.driver and SYSTEM~='Web' then
        local token,state=self.driver.secureStoreGet(self.productId)
        self.storage=state or {mode='unavailable'}
        local stored=type(token)=='string' and self.JSON.decode(token)
        if type(stored)=='table' and origin(stored.issuer) and type(stored.refreshToken)=='string' and #stored.refreshToken>=16 and #stored.refreshToken<=4096 then
            self.refreshToken=stored.refreshToken
            self.refreshIssuer=stored.issuer
        end
    end
    if self.refreshToken and self.refreshIssuer~=self.config.tesseraOrigin then self.error={code='ISSUER_MISMATCH',message='The saved device grant belongs to a different configured account server. Restore its original server before revoking it.'} end
    return self
end
function Session:configure(config)
    if self.login or self.accessToken then return false,'Sign out or cancel authorization before changing servers.' end
    local issuer=origin(config.tesseraOrigin)
    local cadence=origin(config.cadenceOrigin)
    local website=origin(config.websiteOrigin or config.tesseraOrigin)
    if not issuer or not cadence or not website then
        self.error={code='ONLINE_NOT_CONFIGURED',message='Configure the Tessera, Cadence and account website origins before signing in.'}
        return false,self.error.message
    end
    if self.refreshToken and self.refreshIssuer~=issuer then return false,'Revoke the saved device session before changing its issuing account server.' end
    self.config={tesseraOrigin=issuer,cadenceOrigin=cadence,websiteOrigin=website,webRedirectUri=config.webRedirectUri}
    self.error=false
    return true
end
function Session:report(err)
    self.error=safeError(err)
    self.notify('error',self.error.code..': '..self.error.message)
end
function Session:request(service,path,method,data,callback,authenticated,raw)
    local function fail(err)
        err=safeError(err)
        self:report(err)
        if callback then callback(nil,err) end
    end
    if not self.client then fail(self.error) return end
    local host=self.config[service..'Origin']
    if not host then fail({code='ONLINE_NOT_CONFIGURED',message='Online service origins are not configured.'}) return end
    if self.pendingCount>=32 then fail({code='REQUEST_LIMIT',message='Too many requests are pending.'}) return end
    local headers={Accept=raw and 'image/png,image/jpeg,image/webp' or 'application/json'}
    if authenticated then
        if not self:isAuthenticated() then fail({code='AUTH_REQUIRED',message='Sign in before using this feature.'}) return end
        headers.Authorization='Bearer '..self.accessToken
    end
    local body
    if data then
        headers['Content-Type']='application/json'
        body=self.JSON.encode(data)
        if not body then fail({code='INVALID_JSON',message='The request cannot be encoded.'}) return end
    end
    -- Only Tessera consumes product cookies; Cadence HTTP is bearer-authenticated.
    local credentials=SYSTEM=='Web' and service=='tessera' and 'include' or 'omit'
    local id,err=self.client:request{url=host..path,method=method or 'GET',headers=headers,body=body,timeout=12,credentials=credentials}
    if not id then fail(err) return end
    self.pending[id]={callback=callback,raw=raw,generation=authenticated and self.generation or false,deadline=love.timer.getTime()+15}
    self.pendingCount=self.pendingCount+1
    return id
end
function Session:isAuthenticated()
    return self.accessToken and self.expiresAt>os.time() and self.user~=false
end
function Session:storageNotice()
    if SYSTEM=='Web' then return 'Refresh session: independent HttpOnly product cookie. Access credentials stay in memory.' end
    if self.storage.mode=='secure' then return 'Refresh session: OS secure storage ('..self.productId..').' end
    return 'Memory-only session: secure storage is unavailable or locked. Closing the game signs this device out locally.'
end
function Session:_accept(data)
    if type(data)~='table' or data.productId~=self.productId or type(data.grantId)~='string' or #data.grantId~=36 or type(data.accessToken)~='string' or #data.accessToken<16 or #data.accessToken>4096 or type(data.user)~='table' or type(data.user.id)~='string' or #data.user.id~=36 or type(data.user.name)~='string' or #data.user.name>128 or not epoch(data.expiresAt) or epoch(data.expiresAt)<=os.time() or (SYSTEM~='Web' and (type(data.refreshToken)~='string' or #data.refreshToken<16 or #data.refreshToken>4096)) then
        self:report({code='INVALID_SESSION',message='The issuer returned an invalid product session.'})
        return false
    end
    self.accessToken=data.accessToken
    self.refreshToken=SYSTEM~='Web' and data.refreshToken or false
    self.refreshIssuer=self.config.tesseraOrigin
    self.user={id=data.user.id,name=data.user.name}
    self.grantId=data.grantId
    self.expiresAt=epoch(data.expiresAt)
    self.status='signed_in'
    self.error=false
    if self.refreshToken then
        local _,state=self.driver.secureStoreSet(self.productId,self.JSON.encode{issuer=self.refreshIssuer,refreshToken=self.refreshToken})
        self.storage=state or {mode='unavailable'}
        if self.storage.mode~='secure' then self.notify('warn',self:storageNotice()) end
    end
    self.onSession(self)
    return true
end
function Session:beginLogin()
    if not self.client or not self.config.tesseraOrigin then self:report(self.error) return end
    if self.login or self.refreshing or self.status=='signing_out' or self:isAuthenticated() then return end
    local bytes,err=self.driver.randomBytes(64)
    if not bytes then self:report(err) return end
    local verifier=base64url(bytes:sub(1,32))
    local state=base64url(bytes:sub(33,64))
    local challenge,challengeError=self.driver.pkce(verifier)
    if not challenge then self:report(challengeError) return end
    local callback,callbackError=self.client:callbackBegin(self.productId,state,self.config.tesseraOrigin,180,self.config.webRedirectUri)
    if not callback then self:report(callbackError) return end
    self.generation=self.generation+1
    local login={id=callback.id,state=state,verifier=verifier,redirectUri=callback.redirectUri,generation=self.generation,deadline=love.timer.getTime()+180}
    self.login=login
    self.status='authorizing'
    self.error=false
    self:request('tessera','/v1/authorization/requests','POST',{
        productId=self.productId,clientKind=SYSTEM=='Web' and 'web' or 'native',redirectUri=login.redirectUri,
        codeChallenge=challenge,codeChallengeMethod='S256',state=state,deviceLabel=self.productId..' / '..SYSTEM,
    },function(data,requestError)
        if requestError then
            if self.login==login then self:cancelLogin() self:report(requestError) end
            return
        end
        if type(data)~='table' or type(data.requestId)~='string' or type(data.authorizationUrl)~='string' or data.authorizationUrl:sub(1,#self.config.websiteOrigin+1)~=self.config.websiteOrigin..'/' then
            if self.login==login then self:cancelLogin() self:report({code='INVALID_AUTHORIZATION',message='The issuer returned an invalid authorization URL.'}) end
            return
        end
        login.requestId=data.requestId
        if self.login~=login then
            self:request('tessera','/v1/authorization/requests/'..data.requestId..'/cancel','POST',{codeVerifier=login.verifier},function() end)
            return
        end
        local opened,openError=self.client:openAuthorization(data.authorizationUrl,login.id,self.config.websiteOrigin)
        if not opened then self:cancelLogin() self:report(openError) end
    end)
end
function Session:cancelLogin()
    local login=self.login
    if not login or login.cancelled then return end
    login.cancelled=true
    if not login.exchanging then self.login=false end
    self.generation=self.generation+1
    self.client:callbackCancel(login.id)
    if login.requestId then
        self:request('tessera','/v1/authorization/requests/'..login.requestId..'/cancel','POST',{codeVerifier=login.verifier},function() end)
    end
    self.status=self:isAuthenticated() and 'signed_in' or 'signed_out'
end
function Session:refresh(callback)
    if self.login or self.status=='signing_out' then if callback then callback(false,{code='SESSION_BUSY',message='Finish authorization or sign-out before restoring another session.'}) end return false end
    if self.refreshing then
        if callback then self.refreshWaiters[#self.refreshWaiters+1]=callback end
        return true
    end
    if SYSTEM~='Web' and (not self.refreshToken or self.refreshIssuer~=self.config.tesseraOrigin) then
        if callback then callback(false,{code='AUTH_REQUIRED',message='No saved device session exists.'}) end
        return false
    end
    self.refreshing=true
    self.refreshWaiters=callback and {callback} or {}
    local generation=self.generation
    local id=self:request('tessera','/v1/products/'..self.productId..'/session/refresh','POST',SYSTEM=='Web' and {} or {refreshToken=self.refreshToken},function(data,err)
        self.refreshing=false
        if generation~=self.generation then self.refreshWaiters={} return end
        local waiters=self.refreshWaiters
        self.refreshWaiters={}
        if not err and self:_accept(data) then
            for _,completion in ipairs(waiters) do completion(true) end
        else
            if err and (err.status==401 or err.status==403) then self:authorizationEnded() end
            self:report(err or self.error)
            for _,completion in ipairs(waiters) do completion(false,err or self.error) end
        end
        if self.logoutAfterRefresh then
            local completion=self.logoutAfterRefresh.callback
            self.logoutAfterRefresh=false
            self:logout(completion)
        end
    end)
    if not id then self.refreshing=false return false end
    return true
end
function Session:logout(callback)
    self:cancelLogin()
    if self.refreshing then self.logoutAfterRefresh={callback=callback} return end
    if self.status=='signing_out' then return end
    if SYSTEM~='Web' and not self.refreshToken then self:authorizationEnded() if callback then callback(true) end return end
    self.status='signing_out'
    local id=self:request('tessera','/v1/products/'..self.productId..'/session/logout','POST',SYSTEM=='Web' and {} or {refreshToken=self.refreshToken},function(_,err)
        if err then self.status='signed_in' self:report(err) if callback then callback(false,err) end return end
        self:authorizationEnded()
        if callback then callback(true) end
    end)
    if not id then self.status='signed_in' end
end
function Session:authorizationEnded()
    self.generation=self.generation+1
    self.accessToken=false
    self.refreshToken=false
    self.refreshIssuer=false
    self.user=false
    self.expiresAt=0
    self.grantId=false
    self.status='signed_out'
    if self.driver and SYSTEM~='Web' then
        local ok,state=self.driver.secureStoreDelete(self.productId)
        self.storage=state or self.storage
        if not ok and self.storage.mode=='secure' then self:report({code='SECURE_DELETE_FAILED',message='The revoked credential could not be removed from OS storage.'}) end
    end
    self.onSession(self)
end
function Session:handle(event)
    if event.kind=='error' and self.login and event.id==self.login.id then
        self:cancelLogin()
        self:report(event)
        return true
    end
    if event.kind=='http' or event.kind=='error' then
        local pending=self.pending[event.id]
        if not pending then return false end
        self.pending[event.id]=nil
        self.pendingCount=self.pendingCount-1
        if pending.generation and pending.generation~=self.generation then
            if pending.callback then pending.callback(nil,{code='AUTHORIZATION_ENDED',message='The product account changed before this operation completed.'}) end
            return true
        end
        local value,err
        if event.kind=='error' then
            err=safeError(event)
        elseif type(event.body)~='string' or #event.body>(pending.raw and 262144 or 1100000) then
            err={code='INVALID_RESPONSE',message='The response exceeds the approved size limit.'}
        elseif pending.raw then
            if event.status>=200 and event.status<300 then value=event.body else err={code='HTTP_ERROR',message='Image request failed.',status=event.status} end
        else
            local ok,decoded=pcall(self.JSON.decode,event.body)
            if ok and type(decoded)=='table' then value=decoded end
            if event.status<200 or event.status>=300 then
                err=safeError(value and value.error,'HTTP_ERROR')
                err.status=event.status
            elseif not value then
                err={code='INVALID_JSON',message='The server returned invalid JSON.'}
            end
        end
        if pending.callback then pending.callback(value,err,event) elseif err then self:report(err) end
        return true
    elseif event.kind=='callback' then
        local login=self.login
        if not login or event.id~=login.id then return false end
        if event.state~=login.state or event.issuer~=self.config.tesseraOrigin then self:cancelLogin() self:report({code='CALLBACK_MISMATCH',message='Authorization callback verification failed.'}) return true end
        if event.error or type(event.code)~='string' then
            self:cancelLogin()
            self:report({code=event.error or 'AUTHORIZATION_DENIED',message='Browser authorization was denied, cancelled or expired.'})
            return true
        end
        self.status='exchanging'
        login.exchanging=true
        self:request('tessera','/v1/authorization/exchange','POST',{productId=self.productId,code=event.code,codeVerifier=login.verifier,redirectUri=login.redirectUri},function(data,err)
            if self.login~=login then return end
            self.login=false
            self.client:callbackCancel(login.id)
            if err then self.status='signed_out' self:report(err)
            elseif login.cancelled then
                -- An exchange that raced cancellation must revoke the issued grant,
                -- never discard a usable credential or persist it accidentally.
                self.refreshToken=SYSTEM~='Web' and data.refreshToken or false
                self.refreshIssuer=self.config.tesseraOrigin
                self:logout()
            else self:_accept(data) end
        end)
        return true
    end
    return false
end
function Session:update()
    local now=love.timer.getTime()
    if self.login and not self.login.cancelled and now>self.login.deadline then self:cancelLogin() self:report({code='AUTHORIZATION_EXPIRED',message='Browser authorization expired.'}) end
    for id,pending in pairs(self.pending) do
        if now>pending.deadline then
            self.pending[id]=nil
            self.pendingCount=self.pendingCount-1
            self.client:cancel(id)
            if pending.callback then pending.callback(nil,{code='TIMEOUT',message='The request timed out.'}) end
        end
    end
    if self.accessToken and not self.refreshing and self.status~='signing_out' and os.time()>=self.expiresAt-60 and now>(self.nextRefresh or 0) then
        self.nextRefresh=now+5
        self:refresh()
    end
end
function Session:close()
    self:cancelLogin()
    self.closed=true
    if self.client then self.client:destroy() end
    self.accessToken=false
    self.refreshToken=false
end
Session.epoch=epoch
Session.origin=origin
return Session
