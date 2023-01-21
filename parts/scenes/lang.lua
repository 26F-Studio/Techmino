local langList={
    zh="简体中文",
    zh_trad="繁體中文",
    en="English",
    fr="Français",
    es="　Español\n(Castellano)",
    pt="Português",
    id="Bahasa Indonesia",
    ja="日本語",
    symbol="?????",
    zh_code="Code(zh);"
	vi="Tiếng Việt",
}
local languages={
    "Language  Langue  Lingua",
    "语言  言語  언어",
    "Idioma  Línguas  Sprache",
    "Язык  Γλώσσα  Bahasa",
	"Ngôn ngữ", 
}
local curLang=1

local scene={}

function scene.leave()
    saveSettings()
end

function scene.update(dt)
    curLang=curLang+dt*1.26
    if curLang>=#languages+1 then
        curLang=1
    end
end

function scene.draw()
    setFont(80)
    love.graphics.setColor(1,1,1,1-curLang%1*2)
    GC.mStr(languages[curLang-curLang%1],640,20)
    love.graphics.setColor(1,1,1,curLang%1*2)
    GC.mStr(languages[curLang-curLang%1+1] or languages[1],640,20)
end

local function _setLang(lid)
    SETTING.locale=lid
    applySettings()
    TEXT.clear()
    TEXT.show(langList[lid],640,360,100,'appear',.626)
    collectgarbage()
    if FIRSTLAUNCH then SCN.back() end
end

scene.widgetList={
    WIDGET.newButton{x=270,y=210,w=330,h=100,font=40, fText=langList.en,      color='R',sound='click',code=function()_setLang('en') end},
    WIDGET.newButton{x=270,y=330,w=330,h=100,font=40, fText=langList.fr,      color='F',sound='click',code=function()_setLang('fr') end},
    WIDGET.newButton{x=270,y=450,w=330,h=100,font=35, fText=langList.es,      color='O',sound='click',code=function()_setLang('es') end},
    WIDGET.newButton{x=270,y=570,w=330,h=100,font=35, fText=langList.id,      color='Y',sound='click',code=function()_setLang('id') end},

    WIDGET.newButton{x=640,y=210,w=330,h=100,font=40, fText=langList.pt,      color='A',sound='click',code=function()_setLang('pt') end},
    WIDGET.newButton{x=640,y=330,w=330,h=100,font=40, fText=langList.symbol,  color='G',sound='click',code=function()_setLang('symbol') end},
    WIDGET.newButton{x=640,y=450,w=330,h=100,font=40, fText=langList.ja,      color='J',sound='click',code=function()_setLang('ja') end},
    WIDGET.newButton{x=640,y=570,w=330,h=100,font=40, fText=langList.vi,      color='L',sound='click',code=function()_setLang('vi') end},

    WIDGET.newButton{x=1000,y=210,w=330,h=100,font=40,fText=langList.zh,      color='C',sound='click',code=function()_setLang('zh') end},
    WIDGET.newButton{x=1000,y=330,w=330,h=100,font=40,fText=langList.zh_trad, color='S',sound='click',code=function()_setLang('zh_trad') end},
    WIDGET.newButton{x=1000,y=450,w=330,h=100,font=40,fText=langList.zh_code, color='P',sound='click',code=function()_setLang('zh_code') end},

    WIDGET.newButton{name='back',x=1000,y=570,w=330,h=100,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
