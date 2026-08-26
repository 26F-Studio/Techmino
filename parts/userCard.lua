local gc=love.graphics
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw,gc_rectangle=gc.draw,gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf
local gc_push,gc_pop=gc.push,gc.pop
local gc_replaceTransform=gc.replaceTransform
local gc_translate=gc.translate
local gc_stencil,gc_setStencilTest=gc.stencil,gc.setStencilTest

local approach=MATH.expApproach

local CARD={}

local AUTH=require'parts.authModal'

CARD.x=0
CARD.w=310
CARD.h=100
CARD.slideX=0
CARD.alpha=0
CARD.open=false
CARD.menu=false
CARD.menuAlpha=0
CARD.menuY=0
CARD.menuH=0
CARD.playerName=""
CARD.nameTextObj=nil
CARD.nameScaleK=1
CARD.nameWidth=0
CARD.nameOffY=0

local menuItems={}

function CARD.reset()
    CARD.playerName=""
    CARD.nameTextObj=nil
    CARD.nameScaleK=1
    CARD.nameWidth=0
    CARD.nameOffY=0
end

function CARD.enter(targetX)
    CARD.open=true
    CARD.menu=false
    CARD.menuAlpha=0
    CARD.alpha=0
    CARD.slideX=targetX or -320
end

function CARD.leave()
    CARD.open=false
    CARD.menu=false
    CARD.menuAlpha=0
end

function CARD.update(dt)
    local targetX = CARD.open and 0 or -CARD.w
    CARD.slideX=approach(CARD.slideX,targetX,dt*12)
    if CARD.open then
        CARD.alpha=math.min(CARD.alpha+dt*8,1)
    else
        CARD.alpha=math.max(CARD.alpha-dt*8,0)
    end
    if CARD.menu then
        CARD.menuAlpha=math.min(CARD.menuAlpha+dt*10,1)
    else
        CARD.menuAlpha=math.max(CARD.menuAlpha-dt*10,0)
    end
end

function CARD._isCardAbove(mx,my)
    if CARD.alpha<0.5 then return false end
    local screenX,screenY=SCR.xOy:transformPoint(mx,my)
    local rx,ry=SCR.xOy_ur:inverseTransformPoint(screenX,screenY)
    local cx=CARD.slideX
    return rx>cx-320 and rx<cx and ry>10 and ry<110
end

function CARD.mouseClick(x,y)
    local screenX,screenY=SCR.xOy:transformPoint(x,y)
    local rx,ry=SCR.xOy_ur:inverseTransformPoint(screenX,screenY)
    if CARD.menuAlpha>0 and CARD.menu then
        local menuX=-160
        local menuY=CARD.h+10+16
        local menuW=160
        local menuH=#menuItems*56+16
        if rx>=menuX and rx<=menuX+menuW and ry>=menuY and ry<=menuY+menuH then
            for i,item in ipairs(menuItems) do
                local iy=menuY+8+(i-1)*56
                if ry>=iy and ry<=iy+48 then
                    CARD.closeMenu()
                    if item.url then
                        love.system.openURL(item.url)
                    elseif item.code then
                        item.code()
                    end
                    return true
                end
            end
            CARD.closeMenu()
            return true
        end
        CARD.closeMenu()
        return true
    end
    if CARD._isCardAbove(x,y) then
        CARD.toggleMenu()
        return true
    end
    return false
end

function CARD.openMenu()
    CARD.menu=true
    menuItems={}
    if USER.uid then
        table.insert(menuItems,{label="Profile",url="https://teblocks.my.id/profile"})
        table.insert(menuItems,{label="Match History",url="https://teblocks.my.id/history"})
        table.insert(menuItems,{label="Settings",code=function() SCN.go('setting_game') end})
        table.insert(menuItems,{label="Log Out",code=function()
            USER.__data.uid=false
            USER.__data.aToken=false
            USER.__data.oToken=false
            love.filesystem.remove('conf/user')
            SCN.backTo('main')
        end})
    else
        table.insert(menuItems,{label="Log In",code=function() AUTH.open('login') end})
        table.insert(menuItems,{label="Register",code=function() AUTH.open('register') end})
    end
    CARD.menuH=#menuItems*56+16
end

function CARD.closeMenu()
    CARD.menu=false
end

function CARD.toggleMenu()
    if CARD.menu then
        CARD.closeMenu()
    else
        CARD.openMenu()
    end
end

function CARD.setOpen(state)
    CARD.open=state
end

function CARD.draw()
    if CARD.alpha<=0 and CARD.menuAlpha<=0 then return end

    if CARD.alpha>0 then
        gc_push('transform')
        gc_replaceTransform(SCR.xOy_ur)
        gc_translate(CARD.slideX,0)
            gc_setColor(.15,.15,.15,.85*CARD.alpha)
            gc_rectangle('fill',-320,10,310,100,6)
            gc_setColor(1,1,1,CARD.alpha)
            gc_setLineWidth(2)
            gc_rectangle('line',-320,10,310,100,6)

            gc_setColor(1,1,1,CARD.alpha)
            gc_rectangle('line',-308,20,74,74,3)

            local isGuest = not USER.uid
            local avatar = isGuest and nil or USERS.getAvatar(USER.uid)
            if avatar then
                gc_draw(avatar,-306,22,nil,.58)
            end

            local username = isGuest and "Guest" or USERS.getUsername(USER.uid)
            if username~=CARD.playerName then
                CARD.playerName=username
                CARD.nameTextObj=GC.newText(getFont(25),username)
                CARD.nameWidth=CARD.nameTextObj:getWidth()
                CARD.nameScaleK=170/math.max(CARD.nameWidth,170)
                CARD.nameOffY=CARD.nameTextObj:getHeight()/2
            end
            gc_setColor(COLOR.Z[1],COLOR.Z[2],COLOR.Z[3],CARD.alpha)
            gc_draw(CARD.nameTextObj,-155,32,nil,CARD.nameScaleK,nil,CARD.nameWidth,CARD.nameOffY)

            setFont(18)
            local rank = isGuest and 0 or (STAT.globalRank or 0)
            local rankStr = rank > 0 and ("#"..rank) or "Unranked"
            gc_setColor(COLOR.lH[1],COLOR.lH[2],COLOR.lH[3],CARD.alpha)
            gc_print(text.globalRank.." "..rankStr,-222,58)

            local elo = isGuest and 0 or (STAT.elo or 1200)
            gc_setColor(COLOR.lY[1],COLOR.lY[2],COLOR.lY[3],CARD.alpha)
            gc_print(text.elo.." "..elo,-222,80)

            -- Dropdown arrow indicator
            setFont(12)
            gc_setColor(.6,.6,.6,CARD.alpha)
            gc_printf("▼",-310,2,100,'center')
        gc_pop()
    end

    -- Dropdown menu
    if CARD.menuAlpha>0 and #menuItems>0 then
        gc_push('transform')
        gc_replaceTransform(SCR.xOy_ur)
        local mx=-160
        local my=CARD.h+10+16
        local menuW=160
        local menuH=#menuItems*56+16

        gc_setColor(.1,.1,.1,.92*CARD.menuAlpha)
        gc_rectangle('fill',mx,my,menuW,menuH,4)
        gc_setColor(.3,.3,.3,CARD.menuAlpha)
        gc_setLineWidth(1)
        gc_rectangle('line',mx,my,menuW,menuH,4)

        setFont(22)
        for i,item in ipairs(menuItems) do
            local iy=my+8+(i-1)*56
            local ih=48
            if not item.hide or not item.hide() then
                gc_setColor(.2,.2,.2,.5*CARD.menuAlpha)
                gc_rectangle('fill',mx+4,iy,menuW-8,ih,3)
                gc_setColor(1,1,1,CARD.menuAlpha)
                gc_print(item.label,mx+14,iy+12)
            end
        end
        gc_pop()
    end
end

return CARD
