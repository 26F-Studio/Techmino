local LANG={}
-- ONLY FIRST CALL MAKE SENSE
-- Create LANG.get() and LANG.addScene()
function LANG.init(defaultLang,langList,publicText,pretreatFunc)
    local function _langFallback(T0,T)
        for k,v in next,T0 do
            if type(v)=='table' and not v.refuseCopy then-- refuseCopy: just copy pointer, not contents
                if not T[k] then T[k]={} end
                if type(T[k])=='table' then
                    _langFallback(v,T[k])
                end
            elseif not T[k] then
                T[k]=v
            end
        end
    end

    -- Set public text
    if publicText then
        for _,L in next,langList do
            for key,list in next,publicText do L[key]=list end
        end
    end

    -- Fallback to default language
    for name,L in next,langList do
        if name~=defaultLang then
            _langFallback(langList[L.fallback or defaultLang],L)
        end
    end

    -- Custom pretreatment for each language
    if pretreatFunc then
        for _,L in next,langList do
            pretreatFunc(L)
        end
    end

    function LANG.get(l)
        if not langList[l] then
            LOG("Wrong language: "..tostring(l))
            l=defaultLang
        end
        return langList[l]
    end

    function LANG.addScene(name)
        for _,L in next,langList do
            if L.WidgetText and not L.WidgetText[name] then
                L.WidgetText[name]={}
            end
        end
    end

    function LANG.init() end
end
return LANG
