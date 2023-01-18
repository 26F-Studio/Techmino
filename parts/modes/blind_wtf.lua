local border=GC.DO{334,620,
    {'setLW',2},
    {'setCL',.97,.97,.97},
    {'dRect',16,1,302,618,5},
    {'fRect',17,612,300,2},
    {'dRect',318,10,15,604,3},
    {'dRect',1,10,15,604,3},
}
local sin,min=math.sin,math.min
return {
    env={
        drop=30,lock=60,
        nextCount=1,
        block=false,center=0,ghost=0,
        dropFX=0,lockFX=0,
        visible='none',
        freshLimit=15,
        mesDisp=function(P,repMode)
            if not GAME.result then
                GC.push('transform')
                if repMode then
                    GC.origin()
                    GC.setColor(COLOR.X)
                    GC.rectangle('fill',0,0,SCR.w,SCR.h)
                else
                    GC.clear(.2,.2,.2)
                    GC.setColor(.5,.5,.5)

                    -- Frame & Username
                    GC.setColor(.8,.8,.8)
                    GC.setLineWidth(2)
                    GC.rectangle('line',12,20,100,80,5)
                    GC.rectangle('line',488,20,100,80,5)
                    GC.draw(border,-17+150,-12)
                    setFont(30)
                    GC.mStr(P.username or USERS.getUsername(P.uid),300,-60)
                end
                GC.pop()
            end

            -- Figures
            local t=TIME()
            GC.setColor(1,1,1,.5+.2*sin(t))
            GC.draw(IMG.hbm,-276,-86,0,1.5)
            GC.draw(IMG.electric,476,152,0,2.6)

            -- Texts
            GC.setColor(.8,.8,.8)
            mText(TEXTOBJ.techrash,63,420)
            setFont(75)
            GC.mStr(P.stat.clears[4],63,340)
        end,
        eventSet='checkLine_40',
        bg='none',bgm='far',
    },
    load=function()
        PLY.newPlayer(1)
        if SETTING.sfx_spawn==0 then
            MES.new('warn',text.switchSpawnSFX)
        end
    end,
    score=function(P) return {min(P.stat.row,40),P.stat.time} end,
    scoreDisp=function(D) return D[1].." Lines   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local L=P.stat.row
        return
        L>=40 and 5 or
        L>=30 and 4 or
        L>=20 and 3 or
        L>=10 and 2 or
        L>=5 and 1 or
        L>=2 and 0
    end,
}
