local langList={
    "中文",
    "全中文",
    "就这?",
    "English",
    "Français",
    "Español",
    "Português",
    "?????",
}

local scene={}

function scene.sceneBack()
    saveSettings()
end

local function _setLang(n)
    SETTING.lang=n
    LANG.set(n)
    TEXT.clear()
    TEXT.show(langList[n],640,500,100,'appear',.626)
    collectgarbage()
end
scene.widgetList={
    WIDGET.newButton{x=200,y=100,w=200,h=120,fText=langList[1],color='R',font=35,code=function()_setLang(1)end},
    WIDGET.newButton{x=420,y=100,w=200,h=120,fText=langList[2],color='dR',font=35,code=function()_setLang(2)end},
    WIDGET.newButton{x=640,y=100,w=200,h=120,fText=langList[3],color='D',font=35,code=function()_setLang(3)end},
    WIDGET.newButton{x=860,y=100,w=200,h=120,fText=langList[4],color='N',font=35,code=function()_setLang(4)end},
    WIDGET.newButton{x=1080,y=100,w=200,h=120,fText=langList[5],color='lW',font=35,code=function()_setLang(5)end},
    WIDGET.newButton{x=200,y=250,w=200,h=120,fText=langList[6],color='O',font=35,code=function()_setLang(6)end},
    WIDGET.newButton{x=420,y=250,w=200,h=120,fText=langList[7],color='Y',font=35,code=function()_setLang(7)end},
    WIDGET.newButton{x=640,y=250,w=200,h=120,fText=langList[8],color='dH',font=35,code=function()_setLang(8)end},
    WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene
