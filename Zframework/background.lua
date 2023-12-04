local gc_clear=love.graphics.clear
local BGs={
    none={draw=function() gc_clear(.08,.08,.084) end}
}
local BGlist={'none'}
local BG={
    default='none',
    locked=false,
    cur='none',
    init=false,
    resize=false,
    update=NULL,
    draw=BGs.none.draw,
    event=false,
    discard=NULL,
}

function BG.lock() BG.locked=true end
function BG.unlock() BG.locked=false end
function BG.add(name,bg)
    BGs[name]=bg
    BGlist[#BGlist+1]=name
end
function BG.getList()
    return BGlist
end
function BG.remList(name)
    table.remove(BGlist,TABLE.find(BGlist,name))
end
function BG.send(...)
    if BG.event then
        BG.event(...)
    end
end
function BG.setDefault(bg)
    BG.default=bg
end
function BG.set(name,...)
    name=name or BG.default
    if not BGs[name] or BG.locked then return end
    if name~=BG.cur then
        BG.discard()
        BG.cur=name
        local bg=BGs[name]

        BG.init=   bg.init or NULL
        BG.resize= bg.resize or NULL
        BG.update= bg.update or NULL
        BG.draw=   bg.draw or NULL
        BG.event=  bg.event or NULL
        BG.discard=bg.discard or NULL
        BG.init()
        if ... then BG.send(...) end
    end
    return true
end
return BG
