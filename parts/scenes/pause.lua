local GAME,SCR=GAME,SCR
local sin,log=math.sin,math.log10
local GC=GC

local scene={}

local page
local timer1,timer2-- Animation timer
local form-- Form of clear & spins
local radar-- Radar chart
local val-- Radar chart normalizer
local standard-- Standard hexagon
local chartColor-- Color of radar chart
local rank-- Current rank
local trophy-- Current trophy
local trophyColor-- Current trophy color

function scene.enter()
    page=0
    if type(SCN.prev)=='string' and SCN.prev:find("setting") then
        TEXT.show(text.needRestart,640,410,50,'fly',.6)
    end
    local P1=PLAYERS[1]
    local S=P1.stat

    timer1=(SCN.prev=='game' or SCN.prev=='depause') and 0 or 1
    timer2=timer1

    local frameLostRate=(S.frame/S.time/60-1)*100
    form={
        {COLOR.Z,STRING.time(S.time),frameLostRate>10 and COLOR.R or frameLostRate>3 and COLOR.Y or COLOR.H,(" (%.2f%%)"):format(frameLostRate)},
        ("%d/%d/%d"):format(S.key,S.rotate,S.hold),
        ("%d  %.2fPPS"):format(S.piece,S.piece/S.time),
        ("%d(%d)  %.2fLPM"):format(S.row,S.dig,S.row/S.time*60),
        ("%d(%d)  %.2fAPM"):format(S.atk,S.digatk,S.atk/S.time*60),
        ("%d(%d-%d)"):format(S.pend,S.recv,S.recv-S.pend),
        ("[1] %-7d[2] %-7d[3] %-7d[4] %-7d"):format(S.clears[1],S.clears[2],S.clears[3],S.clears[4]),
        (CHAR.icon.num0InSpin.." %-8d"..CHAR.icon.num1InSpin.." %-8d"..CHAR.icon.num2InSpin.." %-8d"..CHAR.icon.num3InSpin.." %-8d"):format(S.spins[1],S.spins[2],S.spins[3],S.spins[4]),
        ("%d/%d ; %d/%d"):format(S.b2b,S.b3b,S.pc,S.hpc),
        ("%d/%dx/%.2f%%"):format(S.extraPiece,S.maxFinesseCombo,S.finesseRate*20/S.piece),
    }
    -- From right-down, 60 degree each
    radar={
        (S.off+S.dig)/S.time*60,-- DefPM
        (S.atk+S.dig)/S.time*60,-- ADPM
        S.atk/S.time*60,        -- AtkPM
        S.send/S.time*60,       -- SendPM
        S.piece/S.time*24,      -- Line'PM
        S.dig/S.time*60,        -- DigPM
    }
    val={1/80,1/160,1/120,1/80,1/100,1/40}

    -- Normalize Values
    for i=1,6 do
        val[i]=val[i]*radar[i] if val[i]>1.26 then val[i]=1.26+log(val[i]-.26) end
    end

    for i=1,6 do
        radar[i]=("%.2f%s"):format(radar[i],text.radarData[i])
    end
    local f=1
    for i=1,6 do
        if val[i]>.5 then
        f=2
        end
        if val[i]>1 then
            f=3
            break
        end
    end
    if f==1 then     chartColor,f={.4,.9,.5},1.25-- Vegetable
    elseif f==2 then chartColor,f={.4,.7,.9},1   -- Normal
    elseif f==3 then chartColor,f={1,.3,.3},.626 -- Diao
    end
    standard={
        120*.5*f, 120*3^.5*.5*f,
        120*-.5*f,120*3^.5*.5*f,
        120*-1*f, 120*0*f,
        120*-.5*f,120*-3^.5*.5*f,
        120*.5*f, 120*-3^.5*.5*f,
        120*1*f,  120*0*f,
    }

    for i=6,1,-1 do
        val[2*i-1],val[2*i]=val[i]*standard[2*i-1],val[i]*standard[2*i]
    end

    if P1.result=='win' and P1.stat.piece>4 then
        local acc=P1.stat.finesseRate*.2/P1.stat.piece
        rank=CHAR.icon['rank'..(
            acc==1. and "Z" or
            acc>.97 and "S" or
            acc>.94 and "A" or
            acc>.87 and "B" or
            acc>.70 and "C" or
            acc>.50 and "D" or
            acc>.30 and "E" or
            "F"
        )]
        if acc==1 then
            trophy=text.finesse_ap
            trophyColor=COLOR.Y
        elseif P1.stat.maxFinesseCombo==P1.stat.piece then
            trophy=text.finesse_fc
            trophyColor=COLOR.lC
        else
            trophy=nil
        end
    else
        rank,trophy=nil
    end
    if GAME.prevBG then
        BG.set(GAME.prevBG)
        GAME.prevBG=false
    end
end
function scene.leave()
    trySave()
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    if key=='q' then
        GAME.playing=false
        SCN.back()
    elseif key=='escape' then
        SCN.swapTo(GAME.result and 'game' or 'depause','none')
    elseif key=='s' then
        if not GAME.fromRepMenu then
            GAME.prevBG=BG.cur
            SCN.go('setting_sound')
        end
    elseif key=='r' then
        if not GAME.fromRepMenu then
            resetGameData()
            SCN.swapTo('game','none')
        end
    elseif key=='p' then
        if (GAME.result or GAME.replaying) and #PLAYERS==1 then
            resetGameData('r')
            PLAYERS[1]:startStreaming(GAME.rep)
            SCN.swapTo('game','none')
        end
    elseif key=='o' then
        if (GAME.result or GAME.replaying) and #PLAYERS==1 and not GAME.saved then
            if DATA.saveReplay() then
                GAME.saved=true
                SFX.play('connected')
            end
        end
    elseif key=='tab' or key=='Stab' then
        if love.keyboard.isDown('lshift','rshift') or key=='Stab' then
            page=(page-1)%2
        else
            page=(page+1)%2
        end
        timer2=0
    elseif key=='t' then
        if SETTING.allowTAS and not (GAME.result or GAME.replaying) then
            GAME.tasUsed=true
            SFX.play('ren_mega')
            SFX.play('clear_3')
            SYSFX.newShade(1.2,555,200,620,380,.6,.6,.6)
        end
    else
        return true
    end
end

function scene.update(dt)
    if not (GAME.result or GAME.replaying) then
        GAME.pauseTime=GAME.pauseTime+dt
    end
    timer1=math.min(timer1+dt*60*.02,1)
    timer2=math.min(timer2+dt*60*.04,1)
end

local hexList={1,0,.5,1.732*.5,-.5,1.732*.5}
for i=1,6 do hexList[i]=hexList[i]*150 end
local textPos={90,131,-90,131,-200,-25,-90,-181,90,-181,200,-25}
local dataPos={90,143,-90,143,-200,-13,-90,-169,90,-169,200,-13}
local tasText=GC.newText(getFont(100),"TAS")
function scene.draw()
    if timer1<1 or GAME.result then
        SCN.scenes.game.draw()
    end

    -- Dark BG
    local _=timer1
    if GAME.result then _=_*.76 end
    GC.setColor(.12,.12,.12,_)
    GC.replaceTransform(SCR.origin)
    GC.rectangle('fill',0,0,SCR.w,SCR.h)
    GC.replaceTransform(SCR.xOy)

    GC.setColor(.97,.97,.97,timer1)

    -- Result Text
    mDraw(GAME.result and TEXTOBJ[GAME.result] or TEXTOBJ.pause,640,70-10*(5-timer1*5)^1.5)

    -- Mode Info (outside)
    GC.draw(TEXTOBJ.modeName,745-TEXTOBJ.modeName:getWidth(),143)

    -- Level rank
    if RANK_CHARS[GAME.rank] then
        GC.push('transform')
            GC.translate(1050,5)
            FONT.set(80)
            GC.setColor(0,0,0,timer1*.7)
            GC.print(RANK_CHARS[GAME.rank],-5,-4,nil,1.5)
            local L=RANK_COLORS[GAME.rank]
            GC.setColor(L[1],L[2],L[3],timer1)
            GC.print(RANK_CHARS[GAME.rank],0,0,nil,1.5)
        GC.pop()
    end

    if GAME.tasUsed then
        GC.setColor(.97,.97,.97,timer1*.08)
        mDraw(tasText,870,395,.3,2.6)
    end

    -- Big info frame
    if PLAYERS[1].frameRun>=180 then
        GC.push('transform')
        GC.translate(560,205)
        GC.setLineWidth(2)

        -- Pause Info (outside)
        FONT.set(25)
        if GAME.pauseCount>0 then
            GC.setColor(.97,.97,.97,timer1*.06)
            GC.rectangle('fill',-5,390,620,36,8)
            GC.setColor(.97,.97,.97,timer1)
            GC.rectangle('line',-5,390,620,36,8)
            GC.mStr(("%s:[%d] %.2fs"):format(text.pauseCount,GAME.pauseCount,GAME.pauseTime),305,389)
        end

        -- Pages
        if page==0 then
            -- Frame
            GC.setColor(.97,.97,.97,timer2*.06)
            GC.rectangle('fill',-5,-5,620,380,8)
            GC.setColor(.97,.97,.97,timer2)
            GC.rectangle('line',-5,-5,620,380,8)

            -- Game statistics
            GC.push('transform')
            GC.scale(.85)
            GC.setLineWidth(2)

            -- Stats
            _=form
            FONT.set(30)
            GC.setColor(.97,.97,.97,timer2)
            for i=1,10 do
                GC.print(text.pauseStat[i],5,43*(i-1)+2)
                GC.printf(_[i],210,43*(i-1)+2,500,'right')
            end

            -- Finesse rank & trophy
            if rank then
                FONT.set(40)
                GC.setColor(.7,.7,.7,timer2)
                GC.print(rank,405,383)
                if trophy then
                    FONT.set(30)
                    GC.setColor(trophyColor[1],trophyColor[2],trophyColor[3],timer2*2-1)
                    GC.printf(trophy,95-120*(1-timer2^.5),390,300,'right')
                end
            end
            GC.pop()
        elseif page==1 then
            -- Radar Chart
            GC.setLineWidth(1)
            GC.push('transform')
            GC.translate(310,185)

            -- Polygon
            GC.push('transform')
                GC.scale((3-2*timer2)*timer2)
                GC.setColor(.97,.97,.97,timer2*(.5+.3*sin(TIME()*6.26)))
                GC.regRoundPolygon('line',0,0,120,6,8)
                GC.setColor(chartColor[1],chartColor[2],chartColor[3],timer2*.626)
                for i=1,9,2 do
                    GC.polygon('fill',0,0,val[i],val[i+1],val[i+2],val[i+3])
                end
                GC.polygon('fill',0,0,val[11],val[12],val[1],val[2])
                GC.setColor(.97,.97,.97,timer2)
                for i=1,9,2 do
                    GC.line(val[i],val[i+1],val[i+2],val[i+3])
                end
                GC.line(val[11],val[12],val[1],val[2])
            GC.pop()

            -- Texts
            local C
            _=TIME()%6.2832
            if _>3.142 then
                GC.setColor(.97,.97,.97,-timer2*sin(_))
                FONT.set(35)
                C,_=text.radar,textPos
            else
                GC.setColor(.97,.97,.97,timer2*sin(_))
                FONT.set(20)
                C,_=radar,dataPos
            end
            for i=1,6 do
                GC.mStr(C[i],_[2*i-1],_[2*i])
            end
            GC.pop()
        end
        GC.pop()
    end

    -- Mods
    GC.push('transform')
    GC.translate(131,600)
    GC.scale(.65)
    if #GAME.mod>0 then
        GC.setLineWidth(2)
        if scoreValid() then
            GC.setColor(.7,.7,.7,timer1)
            GC.rectangle('line',-5,-5,500,150,8)
            GC.setColor(.7,.7,.7,timer1*.05)
            GC.rectangle('fill',-5,-5,500,150,8)
        else
            GC.setColor(.8,0,0,timer1)
            GC.rectangle('line',-5,-5,500,150,8)
            GC.setColor(1,0,0,timer1*.05)
            GC.rectangle('fill',-5,-5,500,150,8)
        end
        FONT.set(35)
        for _,M in next,MODOPT do
            if M.sel>0 then
                _=M.color
                GC.setColor(_[1],_[2],_[3],timer1)
                GC.mStr(M.id,35+M.no%8*60,math.floor(M.no/8)*45)
            end
        end
    end
    GC.pop()
end

scene.widgetList={
    WIDGET.newKey{name='resume',   x=290,y=240,w=300,h=70,code=pressKey'escape'},
    WIDGET.newKey{name='restart',  x=290,y=340,w=300,h=70,code=pressKey'r',hideF=function() return GAME.fromRepMenu end},
    WIDGET.newKey{name='setting',  x=290,y=440,w=300,h=70,code=pressKey's',hideF=function() return GAME.fromRepMenu end},
    WIDGET.newKey{name='quit',     x=290,y=540,w=300,h=70,code=pressKey'q'},
    WIDGET.newKey{name='tas',      x=290,y=620,w=240,h=50,code=pressKey't',hideF=function() return not SETTING.allowTAS or GAME.tasUsed or GAME.result or GAME.replaying end},
    WIDGET.newKey{name='page_prev',x=500,y=390,w=70,code=pressKey'tab',
        fText=GC.DO{70,70,{'setLW',2},                                              {'dRRPol',33,35,32,3,6,3.142},{'dRRPol',45,35,32,3,6,3.142}},
        fShade=GC.DO{70,70,{'setCL',1,1,1,.4},{'draw',GC.DO{70,70,{'setCL',1,1,1,1},{'fRRPol',33,35,32,3,6,3.142},{'fRRPol',45,35,32,3,6,3.142}}}},
        hideF=function() return PLAYERS[1].frameRun<=180 end,
        },
    WIDGET.newKey{name='page_next',x=1230,y=390,w=70,code=pressKey'Stab',
        fText=GC.DO{70,70,{'setLW',2},                                              {'dRRPol',37,35,32,3,6},{'dRRPol',25,35,32,3,6}},
        fShade=GC.DO{70,70,{'setCL',1,1,1,.4},{'draw',GC.DO{70,70,{'setCL',1,1,1,1},{'fRRPol',37,35,32,3,6},{'fRRPol',25,35,32,3,6}}}},
        hideF=function() return PLAYERS[1].frameRun<=180 end,
        },
    WIDGET.newKey{name='replay',   x=865,y=165,w=200,h=40,font=25,code=pressKey'p',hideF=function() return not (GAME.result or GAME.replaying) or #PLAYERS>1 end},
    WIDGET.newKey{name='save',     x=1075,y=165,w=200,h=40,font=25,code=pressKey'o',hideF=function() return not (GAME.result or GAME.replaying) or #PLAYERS>1 or GAME.saved end},
}

return scene
