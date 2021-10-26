local langList={
    zh="中文",
    zh_full="全中文",
    en="English",
    fr="Français",
    es="Español",
    pt="Português",

    zh_grass="机翻",
    zh_yygq="就这?",
    symbol="?????",
}

local scene={}

function scene.sceneBack()
    saveSettings()
end

local function _setLang(lid)
    SETTING.locale=lid
    applyLanguage()
    TEXT.clear()
    TEXT.show(langList[lid],640,360,100,'appear',.626)
    collectgarbage()
end
scene.widgetList={
    WIDGET.newButton{x=200,y=100,w=200,h=120,fText=langList.zh,      color='R', code=function()_setLang('zh')end},
    WIDGET.newButton{x=420,y=100,w=200,h=120,fText=langList.zh_full, color='dR',code=function()_setLang('zh_full')end},
    WIDGET.newButton{x=640,y=100,w=200,h=120,fText=langList.en,      color='N', code=function()_setLang('en')end},
    WIDGET.newButton{x=860,y=100,w=200,h=120,fText=langList.fr,      color='lW',code=function()_setLang('fr')end},
    WIDGET.newButton{x=1080,y=100,w=200,h=120,fText=langList.es,     color='O', code=function()_setLang('es')end},
    WIDGET.newButton{x=200,y=250,w=200,h=120,fText=langList.pt,      color='Y', code=function()_setLang('pt')end},
    WIDGET.newButton{x=200,y=550,w=200,h=120,fText=langList.zh_grass,color='lG',code=function()_setLang('zh_grass')end},
    WIDGET.newButton{x=420,y=550,w=200,h=120,fText=langList.zh_yygq, color='D', code=function()_setLang('zh_yygq')end},
    WIDGET.newButton{x=640,y=550,w=200,h=120,fText=langList.symbol,  color='dH',code=function()_setLang('symbol')end},
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
