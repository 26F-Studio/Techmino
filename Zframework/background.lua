local gc_clear=love.graphics.clear
local BGs={
    none={draw=function()gc_clear(.08,.08,.084)end}
}
local BGlist={'none'}
local BG={
    cur='none',
    default='none',
    init=false,
    resize=false,
    update=NULL,
    draw=BGs.none.draw,
    event=false,
    discard=NULL,
}

function BG.add(name,bg)
    BGs[name]=bg
    BGlist[#BGlist+1]=name
end
function BG.getList()
    return BGlist
end
function BG.send(...)
    if BG.event then
        BG.event(...)
    end
end
function BG.setDefault(bg)
    BG.default=bg
end
function BG.set(background)
    if not background then background=BG.default end
    if not BGs[background]or not SETTING.bg then return end
    if background~=BG.cur then
        BG.discard()
        BG.cur=background
        background=BGs[background]

        BG.init=   background.init or NULL
        BG.resize= background.resize or NULL
        BG.update= background.update or NULL
        BG.draw=   background.draw or NULL
        BG.event=  background.event or NULL
        BG.discard=background.discard or NULL
        BG.init()
    end
    return true
end
return BG