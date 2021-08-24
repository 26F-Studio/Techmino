local LANG={}
function LANG.init(langList,publicText)--Attention, calling this will destory all initializing methods, create a LANG.set()!
    local function _langFallback(T0,T)
        for k,v in next,T0 do
            if type(v)=='table'and not v.refuseCopy then--refuseCopy: just copy pointer, not contents
                if not T[k]then T[k]={}end
                if type(T[k])=='table'then _langFallback(v,T[k])end
            elseif not T[k]then
                T[k]=v
            end
        end
    end
    local tipMeta={__call=function(L)return L[math.random(#L)]end}

    for i=1,#langList do
        local L=langList[i]

        --Set public text
        for key,list in next,publicText do
            L[key]=list
        end

        --Fallback to other language, default zh
        if i>1 then
            _langFallback(langList[L.fallback or 1],L)
        end

        --Metatable:__call for table:getTip
        if type(rawget(L,'getTip'))=='table'then
            setmetatable(L.getTip,tipMeta)
        end
    end

    LANG.init,LANG.setLangList,LANG.setPublicText=nil

    function LANG.set(l)
        if text~=langList[l]then
            text=langList[l]
            WIDGET.setLang(text.WidgetText)
            for k,v in next,drawableText do
                if text[k]then
                    v:set(text[k])
                end
            end
        end
    end

    function LANG.addScene(name)
        for i=1,#langList do
            if langList[i].WidgetText and not langList[i].WidgetText[name]then
                langList[i].WidgetText[name]={back=langList[i].back}
            end
        end
    end
end
return LANG