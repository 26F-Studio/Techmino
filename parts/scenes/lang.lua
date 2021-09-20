local langList={
    zh="中文",
    zh2="全中文",
    en="English",
    fr="Français",
    es="Español",
    pt="Português",

    grass="机翻",
    yygq="就这?",
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
    TEXT.show(langList[lid],640,500,100,'appear',.626)
    collectgarbage()
end
scene.widgetList={
    WIDGET.newButton{x=200,y=100,w=200,h=120,fText=langList.zh,    color='R', font=35,code=function()_setLang('zh')end},
    WIDGET.newButton{x=420,y=100,w=200,h=120,fText=langList.zh2,   color='dR',font=35,code=function()_setLang('zh2')end},
    WIDGET.newButton{x=640,y=100,w=200,h=120,fText=langList.en,    color='N', font=35,code=function()_setLang('en')end},
    WIDGET.newButton{x=860,y=100,w=200,h=120,fText=langList.fr,    color='lW',font=35,code=function()_setLang('fr')end},
    WIDGET.newButton{x=1080,y=100,w=200,h=120,fText=langList.es,   color='O', font=35,code=function()_setLang('es')end},
    WIDGET.newButton{x=200,y=250,w=200,h=120,fText=langList.pt,    color='Y', font=35,code=function()_setLang('pt')end},
    WIDGET.newButton{x=200,y=550,w=200,h=120,fText=langList.grass, color='lG',font=35,code=function()_setLang('grass')end},
    WIDGET.newButton{x=420,y=550,w=200,h=120,fText=langList.yygq,  color='D', font=35,code=function()_setLang('yygq')end},
    WIDGET.newButton{x=640,y=550,w=200,h=120,fText=langList.symbol,color='dH',font=35,code=function()_setLang('symbol')end},
    WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene
