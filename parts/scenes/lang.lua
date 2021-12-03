local langList={
    zh="简体中文",
    zh_full="全简体中文",
    zh_trad="繁體中文",
    en="English",
    fr="Français",
    es="Español\n(Castellano)",
    pt="Português",

    zh_grass="机翻",
    zh_yygq="就这?",
    symbol="?????",
}
local languages={
    "Language",
    "语言",
    "言語",
    "Langue",
    "Idioma",
    "Línguas",
    "Sprache",
    "Lingua",
    "Язык",
    "Γλώσσα",
    "언어",
}
local curLang=1

local scene={}

function scene.sceneBack()
    saveSettings()
end

function scene.update(dt)
    curLang=curLang+dt*0.6
    if curLang>=#languages+1 then
        curLang=1
    end
end

function scene.draw()
    setFont(60)
    love.graphics.setColor(1,1,1,1-curLang%1)
    GC.mStr(languages[curLang-curLang%1],640,20)
    love.graphics.setColor(1,1,1,curLang%1)
    GC.mStr(languages[curLang-curLang%1+1]or languages[1],640,20)
end

local function _setLang(lid)
    SETTING.locale=lid
    applyLanguage()
    TEXT.clear()
    TEXT.show(langList[lid],640,360,100,'appear',.626)
    collectgarbage()
end

scene.widgetList={
    WIDGET.newButton{x=271,y=190,w=346,h=120,font=40, fText=langList.zh,      color='O',code=function()_setLang('zh')end},
    WIDGET.newButton{x=637,y=190,w=346,h=120,font=40, fText=langList.zh_trad, color='F',code=function()_setLang('zh_trad')end},
    WIDGET.newButton{x=1003,y=190,w=346,h=120,font=40,fText=langList.zh_full, color='R',code=function()_setLang('zh_full')end},

    WIDGET.newButton{x=225,y=331,w=255,h=120,font=40, fText=langList.en,      color='L',code=function()_setLang('en')end},
    WIDGET.newButton{x=500,y=331,w=255,h=120,font=40, fText=langList.fr,      color='J',code=function()_setLang('fr')end},
    WIDGET.newButton{x=775,y=331,w=255,h=120,font=33, fText=langList.es,      color='G',code=function()_setLang('es')end},
    WIDGET.newButton{x=1050,y=331,w=255,h=120,font=40,fText=langList.pt,      color='A',code=function()_setLang('pt')end},

    WIDGET.newButton{x=271,y=472,w=346,h=120,font=45, fText=langList.zh_grass,color='N',code=function()_setLang('zh_grass')end},
    WIDGET.newButton{x=637,y=472,w=346,h=120,font=45, fText=langList.zh_yygq, color='S',code=function()_setLang('zh_yygq')end},
    WIDGET.newButton{x=1003,y=472,w=346,h=120,font=45,fText=langList.symbol,  color='B',code=function()_setLang('symbol')end},
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
