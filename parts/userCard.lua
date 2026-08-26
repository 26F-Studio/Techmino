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

CARD.w=310
CARD.h=100
CARD.slideX=320
CARD.alpha=0
CARD.open=false
CARD.menu=false
CARD.menuAlpha=0
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

function CARD.enter(startX)
    CARD.open=true
    CARD.menu=false
    CARD.menuAlpha=0
    CARD.alpha=0
    CARD.slideX=startX or 320
end

function CARD.leave()
    CARD.open=false
    CARD.menu=false
    CARD.menuAlpha=0
end

function CARD.update(dt)
    local targetX = CARD.open and 0 or CARD.w
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
    local cardX=1280-CARD.w-10+CARD.slideX
    return mx>=cardX and mx<=cardX+CARD.w and my>=10 and my<=10+CARD.h
end

function CARD.mouseClick(x,y)
    local cardX=1280-CARD.w-10+CARD.slideX
    if CARD.menuAlpha>0 and CARD.menu then
        local menuW=180
        local menuH=#menuItems*50+16
        local menuX=1280-menuW-10+CARD.slideX
        local menuY=CARD.h+10+10
        if x>=menuX and x<=menuX+menuW and y>=menuY and y<=menuY+menuH then
            for i,item in ipairs(menuItems) do
                local iy=menuY+8+(i-1)*50
                if y>=iy and y<=iy+44 then
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

    local cardX=1280-CARD.w-10+CARD.slideX
    local cardY=10

    if CARD.alpha>0 then
        gc_push('transform')
        gc_replaceTransform(SCR.xOy)
            gc_setColor(.15,.15,.15,.85*CARD.alpha)
            gc_rectangle('fill',cardX,cardY,CARD.w,CARD.h,6)
            gc_setColor(1,1,1,CARD.alpha)
            gc_setLineWidth(2)
            gc_rectangle('line',cardX,cardY,CARD.w,CARD.h,6)

            -- Avatar border & avatar
            gc_setColor(1,1,1,CARD.alpha)
            gc_rectangle('line',cardX+CARD.w-84,cardY+12,74,74,3)

            local isGuest = not USER.uid
            local avatar = isGuest and nil or USERS.getAvatar(USER.uid)
            if avatar then
                gc_draw(avatar,cardX+CARD.w-82,cardY+14,nil,.58)
            end

            -- Username
            local username = isGuest and "Guest" or USERS.getUsername(USER.uid)
            if username~=CARD.playerName then
                CARD.playerName=username
                CARD.nameTextObj=GC.newText(getFont(25),username)
                CARD.nameWidth=CARD.nameTextObj:getWidth()
                CARD.nameScaleK=180/math.max(CARD.nameWidth,180)
                CARD.nameOffY=CARD.nameTextObj:getHeight()/2
            end
            gc_setColor(COLOR.Z[1],COLOR.Z[2],COLOR.Z[3],CARD.alpha)
            gc_draw(CARD.nameTextObj,cardX+16,cardY+24,nil,CARD.nameScaleK)

            -- Rank and ELO
            setFont(16)
            local rank = isGuest and 0 or (STAT.globalRank or 0)
            local rankStr = rank > 0 and ("#"..rank) or "Unranked"
            gc_setColor(COLOR.lH[1],COLOR.lH[2],COLOR.lH[3],CARD.alpha)
            gc_print(text.globalRank.." "..rankStr,cardX+16,cardY+48)

            local elo = isGuest and 0 or (STAT.elo or 1200)
            gc_setColor(COLOR.lY[1],COLOR.lY[2],COLOR.lY[3],CARD.alpha)
            gc_print(text.elo.." "..elo,cardX+16,cardY+70)

            -- Dropdown arrow indicator
            setFont(12)
            gc_setColor(.6,.6,.6,CARD.alpha)
            gc_printf("▼",cardX+CARD.w-35,cardY+CARD.h-18,25,'center')
        gc_pop()
    end

    -- Dropdown menu
    if CARD.menuAlpha>0 and #menuItems>0 then
        gc_push('transform')
        gc_replaceTransform(SCR.xOy)
        local menuW=180
        local menuH=#menuItems*50+16
        local menuX=1280-menuW-10+CARD.slideX
        local menuY=CARD.h+10+10

        gc_setColor(.1,.1,.1,.95*CARD.menuAlpha)
        gc_rectangle('fill',menuX,menuY,menuW,menuH,4)
        gc_setColor(.3,.3,.3,CARD.menuAlpha)
        gc_setLineWidth(1)
        gc_rectangle('line',menuX,menuY,menuW,menuH,4)

        setFont(20)
        for i,item in ipairs(menuItems) do
            local iy=menuY+8+(i-1)*50
            local ih=44
            if not item.hide or not item.hide() then
                gc_setColor(.2,.2,.2,.5*CARD.menuAlpha)
                gc_rectangle('fill',menuX+4,iy,menuW-8,ih,3)
                gc_setColor(1,1,1,CARD.menuAlpha)
                gc_print(item.label,menuX+14,iy+10)
            end
        end
        gc_pop()
    end
end

return CARD
