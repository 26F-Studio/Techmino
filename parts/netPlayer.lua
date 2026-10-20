local gc=love.graphics
local NetPlayers={selectedId=false,hoveredId=false}
local rectangles={}
function NetPlayers.mouseMove(x,y)
    NetPlayers.hoveredId=false
    for id,rect in pairs(rectangles) do
        if x>=rect.x and x<=rect.x+rect.w and y>=rect.y and y<=rect.y+rect.h then NetPlayers.hoveredId=id return end
    end
end
function NetPlayers.select(x,y)
    NetPlayers.mouseMove(x,y)
    NetPlayers.selectedId=NetPlayers.hoveredId
end
function NetPlayers.draw()
    local room=NET.roomStore.snapshot
    if not room then return end
    rectangles={}
    local columns=#room.members>15 and 2 or 1
    local width=columns==2 and 370 or 760
    local height=math.min(55,500/math.max(1,math.ceil(#room.members/columns)))
    for index,member in ipairs(room.members) do
        local column=math.floor((index-1)/15)
        local row=(index-1)%15
        local x,y=35+column*390,100+row*height
        rectangles[member.id]={x=x,y=y,w=width,h=height-3}
        gc.setColor(member.id==NetPlayers.selectedId and .2 or .08,member.ready and .35 or .12,member.role=='spectator' and .25 or .18,.8)
        gc.rectangle('fill',x,y,width,height-3,4)
        gc.setLineWidth(member.id==room.hostId and 3 or 1)
        gc.setColor(GROUP_COLORS[member.team])
        gc.rectangle('line',x,y,width,height-3,4)
        gc.setColor(1,1,1)
        gc.draw(USERS.getAvatar(member.id),x+3,y+3,nil,(height-9)/128)
        FONT.set(math.min(24,height*.48))
        local label=member.name..(member.id==USER.uid and ' (you)' or '')..(member.id==room.hostId and ' [host]' or '')
        gc.printf(label,x+height,y+2,width-height-8,'left')
        FONT.set(math.min(18,height*.35))
        gc.setColor(member.connected and .7 or 1,member.connected and .9 or .4,.7)
        gc.printf(member.role..' / team '..member.team..' / '..(member.connected and (member.ready and 'ready' or 'not ready') or 'recovering'),x+height,y+height*.55,width-height-8,'left')
        USERS.setName(member.id,member.name)
    end
    local id=NetPlayers.hoveredId or NetPlayers.selectedId
    if id then
        local member=NET.roomStore:member(id)
        if member then
            FONT.set(18)
            gc.setColor(1,1,1)
            gc.printf(member.id..'\n'..USERS.getMotto(id),35,610,755,'left')
        end
    end
end
return NetPlayers
