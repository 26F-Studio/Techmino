local Config={}
function Config.load()
    local config={}
    local bytes=love.filesystem.read('conf/online.json') or love.filesystem.read('online-config.json')
    if bytes and #bytes<=8192 then
        local ok,value=pcall(JSON.decode,bytes)
        if ok and type(value)=='table' then
            for _,key in ipairs{'tesseraOrigin','cadenceOrigin','websiteOrigin','webRedirectUri'} do
                if type(value[key])=='string' and #value[key]<=2048 then config[key]=value[key] end
            end
        end
    end
    if SYSTEM~='Web' then
        config.tesseraOrigin=os.getenv('TESSERA_ORIGIN') or config.tesseraOrigin
        config.cadenceOrigin=os.getenv('CADENCE_ORIGIN') or config.cadenceOrigin
        config.websiteOrigin=os.getenv('WEBSITE_ORIGIN') or config.websiteOrigin
    end
    return config
end
function Config.save(config)
    return love.filesystem.write('conf/online.json',JSON.encode{
        tesseraOrigin=config.tesseraOrigin,cadenceOrigin=config.cadenceOrigin,
        websiteOrigin=config.websiteOrigin,webRedirectUri=config.webRedirectUri,
    })
end
function Config.removeLegacyCredentials()
    if not love.filesystem.getInfo('conf/user') then return end
    local ok,value=pcall(FILE.load,'conf/user','-json')
    if not ok then ok,value=pcall(FILE.load,'conf/user','-luaon') end
    if not ok or type(value)~='table' then
        -- This file held legacy online identity only, not statistics or offline progress.
        love.filesystem.remove('conf/user')
        return
    end
    local function sanitize(data,depth)
        if depth>8 then return end
        for key,item in pairs(data) do
            if key=='aToken' or key=='oToken' or key=='accessToken' or key=='refreshToken' or key=='ticket' or key=='uid' then
                data[key]=nil
            elseif type(item)=='table' then sanitize(item,depth+1) end
        end
    end
    sanitize(value,0)
    if next(value) then love.filesystem.write('conf/user',JSON.encode(value)) else love.filesystem.remove('conf/user') end
end
return Config
