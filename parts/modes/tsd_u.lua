local gc=love.graphics
local function check_tsd(P)
    local C=P.lastPiece
    if C.row>0 then
        if C.id==5 and C.row==2 and C.spin then
            if TABLE.find(P.modeData.history,C.centX)then
                P:showText("STACK",0,-140,40,'flicker',.3)
                P:lose()
            else
                P.modeData.tsd=P.modeData.tsd+1
                table.insert(P.modeData.history,1,C.centX)
                P.modeData.history[5]=nil
            end
        else
            P:lose()
        end
    end
end

return{
    color=COLOR.lYellow,
    env={
        drop=60,lock=60,
        freshLimit=15,
        dropPiece=check_tsd,
        task=function(P)P.modeData.history={}end,
        ospin=false,
        bg='matrix',bgm='vapor',
    },
    mesDisp=function(P)
        setFont(60)
        mStr(P.modeData.tsd,63,250)
        mText(drawableText.tsd,63,315)
        PLY.draw.applyField(P)
        local L=P.modeData.history
        for i=1,#L do
            gc.setColor(1,.5,.5,.3-i*.05)
            gc.rectangle('fill',30*L[i]-30,0,30,600)
        end
        PLY.draw.cancelField(P)
    end,
    score=function(P)return{P.modeData.tsd,P.stat.time}end,
    scoreDisp=function(D)return D[1].."TSD   "..STRING.time(D[2])end,
    comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)
        local T=P.modeData.tsd
        return
        T>=20 and 5 or
        T>=18 and 4 or
        T>=16 and 3 or
        T>=13 and 2 or
        T>=10 and 1 or
        T>=4 and 0
    end,
}