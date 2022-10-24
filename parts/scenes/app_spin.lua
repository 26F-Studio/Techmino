
local spinner=require'parts/spinner'.new({
    {font=45,disp=CHAR.icon.retry_spin,item='zTicket',amount=1,freq=30},
    {font=60,disp=CHAR.mino.Z,item='Zfrag',amount=1,freq=10},
    {font=60,disp=CHAR.mino.S,item='Sfrag',amount=1,freq=10},
    {font=60,disp=CHAR.mino.J,item='Jfrag',amount=1,freq=10},
    {font=60,disp=CHAR.mino.L,item='Lfrag',amount=1,freq=10},
    {font=60,disp=CHAR.mino.T,item='Tfrag',amount=1,freq=10},
    {font=60,disp=CHAR.mino.O,item='Ofrag',amount=1,freq=10},
    {font=60,disp=CHAR.mino.I,item='Ifrag',amount=1,freq=10},
},function(item,amount)
    getItem(item,amount)
    saveStats()
end)

local scene={}

function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='space' or key=='return' then
        if STAT.item.zTicket>0 then
            if spinner:start() then
                STAT.item.zTicket=STAT.item.zTicket-1
                saveStats()
            end
        else
            MES.new('info',"Not enough zTicket")
        end
    elseif key=='escape' then
        SCN.back()
    end
end

function scene.update(dt)
    spinner:update(dt)
end

function scene.draw()
    setFont(40)
    love.graphics.print("zTickets: "..STAT.item.zTicket,90,80)
    spinner:draw(640,360)
end

scene.widgetList={
    WIDGET.newButton{name="spin", x=1140,y=360,w=120,font=60,fText=CHAR.icon.retry_spin,code=pressKey'space'},
    WIDGET.newButton{name='back', x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene
