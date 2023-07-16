local gc=love.graphics
local gc_push,gc_pop,gc_clear,gc_origin=gc.push,gc.pop,gc.clear,gc.origin
local gc_translate,gc_scale,gc_rotate=gc.translate,gc.scale,gc.rotate
local gc_setCanvas,gc_setShader=gc.setCanvas,gc.setShader
local gc_draw,gc_line,gc_rectangle=gc.draw,gc.line,gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_stencil,gc_setStencilTest=gc.stencil,gc.setStencilTest

local int,ceil,rnd=math.floor,math.ceil,math.random
local max,min,sin,modf=math.max,math.min,math.sin,math.modf
local setFont=FONT.set
local SKIN,TEXTURE,IMG=SKIN,TEXTURE,IMG
local TEXT,COLOR,TIME=TEXT,COLOR,TIME
local shader_alpha,shader_lighter=SHADER.alpha,SHADER.lighter
local shader_fieldSatur,shader_blockSatur=SHADER.fieldSatur,SHADER.blockSatur
local TEXTOBJ,ENUM_MISSION,BLOCK_COLORS=TEXTOBJ,ENUM_MISSION,BLOCK_COLORS


local RCPB={10,33,200,33,105,5,105,60}
local attackColor={
    {COLOR.dH,COLOR.Z},
    {COLOR.H,COLOR.Z},
    {COLOR.lV,COLOR.Z},
    {COLOR.lR,COLOR.Z},
    {COLOR.dG,COLOR.C},
}
local hideBoardStencil={
    up=function() gc_rectangle('fill',0,-600,300,300,6) end,
    down=function() gc_rectangle('fill',0,-300,300,300,6) end,
    all=function() gc_rectangle('fill',0,-600,300,600,6) end,
}
local dialNeedle=TEXTURE.dial.needle
local multiple=TEXTURE.multiple
local playerborder=TEXTURE.playerBorder
local gridLines=TEXTURE.gridLines

local seqGenBanner=setmetatable({
    none=GC.DO{1,1},
    bag=GC.DO{100,10,
        {'fRect',35,2,-2,6},
        {'fRect',40,4,20,2},
        {'fRect',65,2,2,6},
    },
    bagES=GC.DO{100,10,
        {'fRect',35,2,-2,6},
        {'fRect',40,4,20,2},
        {'fRect',65,2,2,6},
        {'fCirc',40,5,3},
    },
    his=GC.DO{100,10,
        {'fRect',15,3,2,7},
        {'fRect',20,3,2,7},
        {'fRect',25,3,2,7},
        {'fRect',30,3,2,7},
    },
    hisPool=GC.DO{100,10,
        {'fRect',15,3,2,7},
        {'fRect',20,3,2,7},
        {'fRect',25,3,2,7},
        {'fRect',30,3,2,7},
        {'fRect',60,5,25,2},
    },
    c2=GC.DO{100,10,
        {'fRect',20-1,5-1,2,2},
        {'fRect',30-2,5-2,4,4},
        {'fRect',40-1,5-1,2,2},
        {'fRect',50-2,5-2,4,4},
        {'fRect',60-1,5-1,2,2},
        {'fRect',70-2,5-2,4,4},
        {'fRect',80-1,5-1,2,2},
    },
    bagP1inf=GC.DO{100,10,
        {'fRect',10,4,40,2},
        {'fRect',55,4,20,2},
        {'fRect',80,4,10,2},
    },
    rnd=GC.DO{100,10,
        {'fRect',30-3,1,6,6},
        {'fRect',70-3,1,6,6},
    },
    mess=GC.DO{100,10,
        {'setLW',2},
        {'dRect',30-3,1,6,6},
        {'dRect',70-3,1,6,6},
    },
    reverb=GC.DO{100,10,
        {'fRect',25,1,30,2},
        {'fRect',20,4,60,2},
        {'fRect',45,7,30,2},
    },
    loop=GC.DO{100,10,
        {'fRect',25,4,20,2},
        {'fRect',55,4,20,2},
    },
    fixed=GC.DO{100,10,
        {'fRect',40,4,20,2},
    },
},{__index=function(self,k)
    self[k]=self.none
    return self.none
end})

local LDmarks=gc.newSpriteBatch(GC.DO{14,5,{'fRect',0,0,14,5,3}},15,'static')
for i=0,14 do LDmarks:add(3+20*i,615) end

local function _boardTransform(mode)
    if mode then
        if mode=="U-D" then
            gc_translate(0,590)
            gc_scale(1,-1)
        elseif mode=="L-R" then
            gc_translate(300,0)
            gc_scale(-1,1)
        elseif mode=="180" then
            gc_translate(300,590)
            gc_scale(-1,-1)
        end
    end
end
local function _stencilBoard() gc_rectangle('fill',0,-10,300,610) end
local function _applyField(P)
    gc_push('transform')

    -- Apply shaking
    if P.shakeTimer>0 then
        local dx=int(P.shakeTimer/2)
        local dy=int(P.shakeTimer/3)
        gc_translate(dx^1.6*(dx%2*2-1)*(P.gameEnv.shakeFX+1)/30,dy^1.4*(dy%2*2-1)*(P.gameEnv.shakeFX+1)/30)
    end

    -- Apply swingOffset
    local O=P.swingOffset
    if P.gameEnv.shakeFX then
        local k=P.gameEnv.shakeFX
        gc_translate(O.x*k+150+150,O.y*k+300)
        gc_rotate(O.a*k)
        gc_translate(-150,-300)
    else
        gc_translate(150,0)
    end

    -- Apply stencil
    gc_stencil(_stencilBoard)
    gc_setStencilTest('equal',1)

    -- Move camera
    gc_push('transform')
    _boardTransform(P.gameEnv.flipBoard)
    gc_translate(0,P.fieldBeneath+P.fieldUp)
end
local function _cancelField()
    gc_setStencilTest()
    gc_pop()
    gc_pop()
end

local function _drawRow(texture,h,V,L,showInvis)
    local t=TIME()*4
    for i=1,10 do
        if L[i]>0 then
            if V[i]>0 then
                gc_setColor(1,1,1,V[i]*.05)
                gc_draw(texture[L[i]],30*i-30,-30*h)
            elseif showInvis then
                gc_setColor(1,1,1,.3+.08*sin(.5*(h-i)+t))
                gc_rectangle('fill',30*i-30,-30*h,30,30)
            end
        end
    end
end
local function _drawField(P,showInvis)
    local ENV=P.gameEnv
    local V,F=P.visTime,P.field
    local start=int((P.fieldBeneath+P.fieldUp)/30+1)
    local texture=P.skinLib
    if P.falling==0 then-- Blocks only
        if ENV.upEdge then
            gc_setShader(shader_lighter)
            gc_translate(0,-4)
            -- <drawRow>
                for j=start,min(start+21,#F) do _drawRow(texture,j,V[j],F[j]) end
            -- </drawRow>
            gc_setShader(shader_fieldSatur)
            gc_translate(0,4)
        else
            gc_setShader(shader_fieldSatur)
        end

        -- <drawRow>
            for j=start,min(start+21,#F) do _drawRow(texture,j,V[j],F[j],showInvis) end
        -- </drawRow>
    else-- With falling animation
        local stepY=ENV.smooth and (P.falling/(ENV.fall+1))^1.6*30 or 30
        local alpha=P.falling/ENV.fall
        local h=1
        if ENV.upEdge then
            gc_push('transform')
            gc_setShader(shader_lighter)
            gc_translate(0,-4)
            -- <drawRow>
                for j=start,min(start+21,#F) do
                    while j==P.clearingRow[h] do
                        h=h+1
                        gc_translate(0,-stepY)
                    end
                    _drawRow(texture,j,V[j],F[j])
                end
            -- </drawRow>
            gc_setShader(shader_fieldSatur)
            gc_pop()
            h=1
        else
            gc_setShader(shader_fieldSatur)
        end

        gc_push('transform')
        -- <drawRow>
            for j=start,min(start+21,#F) do
                while j==P.clearingRow[h] do
                    h=h+1
                    gc_translate(0,-stepY)
                    gc_setColor(1,1,1,alpha)
                    gc_rectangle('fill',0,30-30*j,300,stepY)
                end
                _drawRow(texture,j,V[j],F[j],showInvis)
            end
        -- </drawRow>
        gc_pop()
    end
    gc_setShader()
end
local function _drawFXs(P)
    -- LockFX
    for i=1,#P.lockFX do
        local S=P.lockFX[i]
        if S[3]<.5 then
            gc_setColor(1,1,1,2*S[3])
            gc_rectangle('fill',S[1],S[2],60*S[3],30)
        else
            gc_setColor(1,1,1,2-2*S[3])
            gc_rectangle('fill',S[1]+30,S[2],60*S[3]-60,30)
        end
    end

    -- DropFX
    for i=1,#P.dropFX do
        local S=P.dropFX[i]
        gc_setColor(1,1,1,.6-S[5]*.6)
        local w=30*S[3]*(1-S[5]*.5)
        gc_rectangle('fill',30*S[1]-30+15*S[3]-w*.5,-30*S[2],w,30*S[4])
    end

    -- MoveFX
    local texture=P.skinLib
    for i=1,#P.moveFX do
        local S=P.moveFX[i]
        gc_setColor(1,1,1,.6-S[4]*.6)
        gc_draw(texture[S[1]],30*S[2]-30,-30*S[3])
    end

    -- ClearFX
    for i=1,#P.clearFX do
        local S=P.clearFX[i]
        local t=S[2]
        local x=t<.3 and 1-(3.3333*t-1)^2 or 1
        local y=t<.2 and 5*t or 1-1.25*(t-.2)
        gc_setColor(1,1,1,y)
        gc_rectangle('fill',150-x*150,15-S[1]*30-y*15,300*x,y*30)
    end
end
local drawGhost={
    color=function(CB,curX,ghoY,alpha,texture,clr)
        gc_setColor(1,1,1,alpha)
        for i=1,#CB do for j=1,#CB[1] do
            if CB[i][j] then
                gc_draw(texture[clr],30*(j+curX-1)-30,-30*(i+ghoY-1))
            end
        end end
    end,
    gray=function(CB,curX,ghoY,alpha,texture,_)
        gc_setColor(1,1,1,alpha)
        for i=1,#CB do for j=1,#CB[1] do
            if CB[i][j] then
                gc_draw(texture[21],30*(j+curX-1)-30,-30*(i+ghoY-1))
            end
        end end
    end,
    colorCell=function(CB,curX,ghoY,alpha,_,clr)
        clr=BLOCK_COLORS[clr]
        gc_setColor(clr[1],clr[2],clr[3],alpha)
        for i=1,#CB do for j=1,#CB[1] do
            if CB[i][j] then
                gc_rectangle('fill',30*(j+curX-1)-30,-30*(i+ghoY-1),30,30)
            end
        end end
    end,
    grayCell=function(CB,curX,ghoY,alpha,_,_)
        gc_setColor(1,1,1,alpha)
        for i=1,#CB do for j=1,#CB[1] do
            if CB[i][j] then
                gc_rectangle('fill',30*(j+curX-1)-30,-30*(i+ghoY-1),30,30)
            end
        end end
    end,
    colorLine=function(CB,curX,ghoY,alpha,_,clr)
        clr=BLOCK_COLORS[clr]
        gc_setColor(clr[1],clr[2],clr[3],alpha)
        gc_setLineWidth(4)
        for i=1,#CB do for j=1,#CB[1] do
            if CB[i][j] then
                gc_rectangle('line',30*(j+curX-1)-30+4,-30*(i+ghoY-1)+4,22,22)
            end
        end end
    end,
    grayLine=function(CB,curX,ghoY,alpha,_,_)
        gc_setColor(1,1,1,alpha)
        gc_setLineWidth(4)
        for i=1,#CB do for j=1,#CB[1] do
            if CB[i][j] then
                gc_rectangle('line',30*(j+curX-1)-30+4,-30*(i+ghoY-1)+4,22,22)
            end
        end end
    end,
}
local function _drawBlockOutline(CB,curX,curY,texture,trans)
    shader_alpha:send('a',trans)
    gc_setShader(shader_alpha)
    for i=1,#CB do for j=1,#CB[1] do
        if CB[i][j] then
            local x=30*(j+curX)-60-3
            local y=30-30*(i+curY)-3
            gc_draw(texture,x,y)
            gc_draw(texture,x+6,y+6)
            gc_draw(texture,x+6,y)
            gc_draw(texture,x,y+6)
        end
    end end
    gc_setShader()
end
local function _drawBlockShade(CB,curX,curY,alpha)
    gc_setColor(1,1,1,alpha)
    for i=1,#CB do for j=1,#CB[1] do
        if CB[i][j] then
            gc_rectangle('fill',30*(j+curX)-60,30-30*(i+curY),30,30)
        end
    end end
end
local function _drawBlock(CB,curX,curY,texture)
    gc_setColor(1,1,1)
    gc_setShader(shader_blockSatur)
    for i=1,#CB do for j=1,#CB[1] do
        if CB[i][j] then
            gc_draw(texture,30*(j+curX-1)-30,-30*(i+curY-1))
        end
    end end
    gc_setShader()
end
local function _drawNextPreview(B,fieldH,fieldBeneath)
    gc_setColor(1,1,1,.8)
    local y=int(fieldH+1-modf(B.RS.centerPos[B.id][B.dir][1]))+ceil(fieldBeneath/30)
    B=B.bk
    local x=int(6-#B[1]*.5)
    local cross=TEXTURE.puzzleMark[-1]
    for i=1,#B do for j=1,#B[1] do
        if B[i][j] then
            gc_draw(cross,30*(x+j-2),30*(1-y-i))
        end
    end end
end
local function _drawHoldPreview(B,fieldH,fieldBeneath)
    gc_setColor(1,1,1,.3)
    local y=int(fieldH+1-modf(B.RS.centerPos[B.id][B.dir][1]))+ceil(fieldBeneath/30)+.14
    B=B.bk
    local x=int(6-#B[1]*.5)
    local cross=TEXTURE.puzzleMark[-1]
    for i=1,#B do for j=1,#B[1] do
        if B[i][j] then
            gc_draw(cross,30*(x+j-2),30*(1-y-i))
        end
    end end
end
local function _drawBuffer(atkBuffer,bufferWarn,atkBufferSum1,atkBufferSum)
    local h=0
    for i=1,#atkBuffer do
        local A=atkBuffer[i]
        local bar=A.amount*30
        if h+bar>600 then bar=600-h end
        if not A.sent then
            if A.time<20 then
                -- Appear
                bar=bar*(20*A.time)^.5*.05
            end
            if A.countdown>0 then
                -- Timing
                gc_setColor(attackColor[A.lv][1])
                gc_rectangle('fill',303,600-h-bar,11,bar,2)
                gc_setColor(1,1,1)
                for j=30,A.cd0-30,30 do
                    gc_rectangle('fill',303,600-h-bar*(j/A.cd0),6,2)
                end
                gc_setColor(attackColor[A.lv][2])
                gc_rectangle('fill',303,600-h-bar,11,bar*(1-A.countdown/A.cd0),2)
            else
                -- Warning
                local a=math.sin((TIME()-i)*30)*.5+.5
                local c1,c2=attackColor[A.lv][1],attackColor[A.lv][2]
                gc_setColor(c1[1]*a+c2[1]*(1-a),c1[2]*a+c2[2]*(1-a),c1[3]*a+c2[3]*(1-a))
                gc_rectangle('fill',303,600-h-bar,11,bar,2)
            end
        else
            -- Disappear
            gc_setColor(attackColor[A.lv][1])
            bar=bar*(20-A.time)*.05
            gc_rectangle('fill',303,600-h-bar,11,bar,2)
        end
        h=h+bar
        if h>=600 then break end
    end
    if bufferWarn then
        local sum=atkBufferSum1
        if sum>=8 then
            gc_push('transform')
            gc_translate(300,max(0,600-30*sum))
            gc_scale(min(.2+sum/50,1))
            gc_setColor(1,.2+min(sum*.02,.8)*(.5+.5*sin(TIME()*min(sum,32))),.2,min(sum/30,.8))
            setFont(100)
            if sum>20 then
                local d=atkBufferSum-sum
                if d>.5 then
                    gc_translate(d^.5*(rnd()-.5)*15,d^.5*(rnd()-.5)*15)
                end
            end
            gc_printf(int(sum),-300,-20,292,'right')
            gc_pop()
        end
    end
end
local function _drawB2Bbar(b2b,b2b1)
    local a,b=b2b,b2b1
    if a>b then a,b=b,a end
    if b>0 then
        gc_setColor(.8,1,.2)
        gc_rectangle('fill',-14,600-b*.6,11,b*.6,2)
        gc_setColor(b2b<50 and COLOR.Z or b2b<=800 and COLOR.lR or COLOR.lB)
        gc_rectangle('fill',-14,600-a*.6,11,a*.6,2)
        if TIME()%.5<.3 then
            gc_setColor(1,1,1)
            gc_rectangle('fill',-15,b<50 and 570 or 120,13,3,2)
        end
    end
end
local function _drawLDI(easyFresh,length,freshTime)-- Lock Delay Indicator
    if easyFresh then
        gc_setColor(.97,.97,.97)
    else
        gc_setColor(1,.5,.5)
    end
    if length>=0 then
        gc_rectangle('fill',0,602,300*length,4)
    end
    if freshTime>0 then
        LDmarks:setDrawRange(1,min(freshTime,15))
        gc_draw(LDmarks)
    end
end
local function _drawHold(holdQueue,holdCount,holdTime,skinLib)
    local N=holdCount*72
    gc_push('transform')
        gc_translate(12,20)
        gc_setLineWidth(2)
        gc_setColor(0,0,0,.4)gc_rectangle('fill',0,0,100,N+8,5)
        gc_setColor(.97,.97,.97)gc_rectangle('line',0,0,100,N+8,5)
        N=#holdQueue<holdCount and holdQueue[1] and 1 or holdTime+1
        gc_push('transform')
            gc_translate(50,40)
            gc_setLineWidth(8)
            gc_setColor(1,1,1)
            gc_setShader(shader_blockSatur)
            for n=1,#holdQueue do
                if n==N then gc_setColor(.7,.5,.5) end
                local bk,clr=holdQueue[n].bk,holdQueue[n].color
                local texture=skinLib[clr]
                local k=min(2.3/#bk,3/#bk[1],.85)
                gc_scale(k)
                for i=1,#bk do for j=1,#bk[1] do
                    if bk[i][j] then
                        gc_draw(texture,30*(j-#bk[1]*.5)-30,-30*(i-#bk*.5))
                    end
                end end
                gc_scale(1/k)
                gc_translate(0,72)
            end
            gc_setShader()
        gc_pop()
    gc_pop()
end
local function _drawNext(P,repMode)
    local ENV=P.gameEnv
    local texture=P.skinLib
    gc_translate(488,20)
        gc_setLineWidth(2)
        local h=ENV.nextCount*72
        gc_setColor(ENV.nextStartPos>1 and .5 or 0,0,0,.4)
        gc_rectangle('fill',0,0,100,h+8,5)
        gc_setColor(1,1,1,.626)
        gc_draw(seqGenBanner[ENV.sequence],0,-11)
        gc_setColor(.97,.97,.97)
        if ENV.holdMode=='swap' then gc_rectangle('fill',1,72*ENV.holdCount+4,50,4) end
        gc_rectangle('line',0,0,100,h+8,5)
        gc_push('transform')
            gc_translate(50,40)

            -- Draw nexts
            gc_setLineWidth(6)
            gc_setColor(1,1,1,.2)
            gc_setShader(shader_blockSatur)
            local hiding
            if ENV.holdMode=='swap' then
                gc_setColor(.7,.5,.5)
                hiding=true
            else
                gc_setColor(1,1,1)
            end
            local queue=P.nextQueue
            local N=1
            while N<=ENV.nextCount and queue[N] do
                if hiding and N>ENV.holdCount-P.holdTime then
                    gc_setColor(1,1,1)
                    hiding=false
                end

                local bk,sprite=queue[N].bk,texture[queue[N].color]
                local k=min(2.3/#bk,3/#bk[1],.85)
                gc_scale(k)
                for i=1,#bk do for j=1,#bk[1] do
                    if bk[i][j] then
                        gc_draw(sprite,30*(j-#bk[1]*.5)-30,-30*(i-#bk*.5))
                    end
                end end
                gc_scale(1/k)

                gc_translate(0,72)
                N=N+1
            end
            gc_setShader()

            -- Draw more nexts
            if repMode then
                gc_translate(50,-28)
                local blockImg=TEXTURE.miniBlock
                local n=N
                while n<=10 and queue[n] do
                    local id=queue[n].id
                    local _=BLOCK_COLORS[queue[n].color]
                    gc_setColor(_[1],_[2],_[3],.26)
                    _=blockImg[id]
                    gc_draw(_,-_:getWidth()*10,0,nil,10,nil)
                    gc_translate(0,10*_:getHeight()+3)
                    n=n+1
                end
            end
        gc_pop()

        local c=min(ENV.nextStartPos-1,P.pieceCount)
        if c>0 then
            gc_setColor(.3,.3,.3,repMode and .8 or 1)
            gc_rectangle('fill',1,1,98,c*72+4,4)
        end
        if ENV.bagLine then
            gc_setColor(.8,.8,.8,.8)
            for i=-P.pieceCount%ENV.bagLine,N-1,ENV.bagLine do-- i=phase
                gc_rectangle('fill',1,72*i+3,98,2)
            end
        end
    gc_translate(-488,-20)
end
local _drawDial do
    local function _getDialBackColor(speed)
        if     speed<60  then return COLOR.H
        elseif speed<120 then return COLOR.Z
        elseif speed<180 then return COLOR.lC
        elseif speed<240 then return COLOR.lG
        elseif speed<300 then return COLOR.lY
        elseif speed<420 then return COLOR.O
        else                  return COLOR.R
        end
    end
    local function _getDialColor(speed)
        if     speed<60  then return COLOR.Z
        elseif speed<120 then return COLOR.lC
        elseif speed<180 then return COLOR.lG
        elseif speed<240 then return COLOR.lY
        elseif speed<300 then return COLOR.O
        else                  return COLOR.R
        end
    end
    function _drawDial(x,y,speed)
        local theta=3*math.pi/2+((math.pi*(speed<300 and speed or 150+speed/2)/30)%MATH.tau)

        gc_setColor(0,0,0,.4)
        gc.circle('fill',x+40,y+40,36)

        gc_setColor(1,1,1)
        gc_draw(dialNeedle,x+40,y+40,theta,nil,nil,1,1)

        gc_setLineWidth(3)
        gc_setColor(_getDialBackColor(speed))
        gc.circle('line',x+40,y+40,37)

        gc_setColor(_getDialColor(speed))
        if speed<420 then
            gc.arc('line','open',x+40,y+40,37,3*math.pi/2,theta)
        else
            gc.circle('line',x+40,y+40,37)
        end
        setFont(30)GC.mStr(int(speed),x+40,y+19)
    end
end
local function _drawFinesseCombo_norm(P)
    if P.finesseCombo>2 then
        local S=P.stat
        local t=P.finesseComboTime
        local str=P.finesseCombo.."x"
        if S.finesseRate==5*S.piece then
            gc_setColor(.9,.9,.3,t*.2)
            gc_print(str,20,570)
            gc_setColor(.9,.9,.3,1.2-t*.1)
        elseif S.maxFinesseCombo==S.piece then
            gc_setColor(.7,.7,1,t*.2)
            gc_print(str,20,570)
            gc_setColor(.7,.7,1,1.2-t*.1)
        else
            gc_setColor(1,1,1,t*.2)
            gc_print(str,20,570)
            gc_setColor(1,1,1,1.2-t*.1)
        end
        gc_print(str,20,600,nil,1+t*.08,nil,0,30)
    end
end
local function _drawFinesseCombo_remote(P)
    if P.finesseCombo>2 then
        local S=P.stat
        if S.finesseRate==5*S.piece then
            gc_setColor(.9,.9,.3)
        elseif S.maxFinesseCombo==S.piece then
            gc_setColor(.7,.7,1)
        else
            gc_setColor(.97,.97,.97)
        end
        gc_print(P.finesseCombo.."x",20,570)
    end
end
local function _drawLife(life)
    gc_setColor(.97,.97,.97)
    gc_draw(IMG.lifeIcon,475,595,nil,.8)
    if life>3 then
        gc_draw(multiple,502,602)
        setFont(20)gc_print(life,517,595)
    else
        if life>1 then gc_draw(IMG.lifeIcon,500,595,nil,.8) end
        if life>2 then gc_draw(IMG.lifeIcon,525,595,nil,.8) end
    end
end
local function _drawMission(curMission,L,missionkill)
    -- Draw current mission
    setFont(35)
    if missionkill then
        gc_setColor(1,.7+.2*sin(TIME()*6.26),.4)
    else
        gc_setColor(.97,.97,.97)
    end
    gc_print(ENUM_MISSION[L[curMission]],85,110)

    -- Draw next mission
    setFont(20)
    for i=1,3 do
        local m=L[curMission+i]
        if m then
            m=ENUM_MISSION[m]
            gc_print(m,87-28*i,117)
        else
            break
        end
    end
end
local function _drawStartCounter(time)
    time=179-time
    gc_push('transform')
        gc_translate(300,300)
        local r,g,b
        local num=int(time/60)+1
        local d=time%60
        if num==3 then
            r,g,b=.7,.8,.98
            if d>45 then gc_rotate((d-45)^2*.00355) end
        elseif num==2 then
            r,g,b=.98,.85,.75
            if d>45 then gc_scale(1+(d/15-3)^2,1) end
        elseif num==1 then
            r,g,b=1,.7,.7
            if d>45 then gc_scale(1,1+(d/15-3)^2) end
        end
        setFont(100)

        gc_setColor(r,g,b,d/60)
        gc_push('transform')
            gc_scale((1.5-d/60*.6)^1.5)
            GC.mStr(num,0,-70)
        gc_pop()

        gc_setColor(r,g,b)
        gc_scale(min(d/20,1)^.4)
        GC.mStr(num,0,-70)
    gc_pop()
end

local draw={}
draw.drawGhost=drawGhost
draw.applyField=_applyField
draw.cancelField=_cancelField
function draw.drawTargetLine(P,h)
    if h<=20+(P.fieldBeneath+P.fieldUp+10)/30 and h>0 then
        gc_setLineWidth(3)
        gc_setColor(1,h>10 and 0 or .2+.8*rnd(),.5)
        _applyField(P)
        h=600-30*h
        if P.falling~=-1 then
            h=h-#P.clearingRow*(P.gameEnv.smooth and (P.falling/(P.gameEnv.fall+1))^1.6*30 or 30)
        end
        gc_line(0,h,300,h)
        _cancelField()
    end
end
function draw.drawMarkLine(P,h,r,g,b,a)
    if h<=20+(P.fieldBeneath+P.fieldUp+10)/30 and h>0 then
        gc_setLineWidth(4)
        gc_setColor(r,g,b,a)
        _applyField(P)
        h=600-30*h
        gc_line(0,h,300,h)
        _cancelField()
    end
end
function draw.drawProgress(s1,s2)
    setFont(40)
    GC.mStr(s1,62,322)
    GC.mStr(s2,62,376)
    gc_rectangle('fill',15,375,90,4,2)
end

function draw.norm(P,repMode)
    local ENV=P.gameEnv
    local FBN,FUP=P.fieldBeneath,P.fieldUp
    local camDY=FBN+FUP
    local t=TIME()
    gc_push('transform')
        gc_translate(P.x,P.y)
        gc_scale(P.size)

        -- Draw username
        setFont(30)
        gc_setColor(GROUP_COLORS[P.group])
        GC.mStr(P.username or USERS.getUsername(P.uid),300,-60)

        -- Draw HUD
        if ENV.nextCount>0 then _drawNext(P,repMode) end
        if ENV.holdMode=='hold' and ENV.holdCount>0 then _drawHold(P.holdQueue,ENV.holdCount,P.holdTime,P.skinLib) end
        if P.curMission then _drawMission(P.curMission,ENV.mission,ENV.missionKill) end
        _drawDial(499,505,P.dropSpeed)
        if P.life>0 then _drawLife(P.life) end

        -- Field-related things
        _applyField(P)
            -- Fill field
            gc_setColor(0,0,0,.6)
            gc_rectangle('fill',0,-10-camDY,300,610)

            -- Draw grid
            if ENV.grid then
                gc_setColor(1,1,1,ENV.grid)
                gc_draw(gridLines,0,-40-(camDY-camDY%30))
            end

            gc_translate(0,600)

            local fieldTop=-ENV.fieldH*30

            -- Draw dangerous area
            if fieldTop-camDY<610 then
                gc_setColor(1,0,0,.26)
                gc_rectangle('fill',0,fieldTop,300,-10-camDY-(600-fieldTop))
            end

            -- Draw field
            _drawField(P,repMode)

            -- Draw line number
            if ENV.lineNum then
                setFont(20)
                local dy=camDY<900 and 0 or camDY-camDY%300-600
                for i=1,3 do
                    local num=10+10*i+dy/30
                    local y=-325-300*i-dy
                    gc_setColor(0,0,0,ENV.lineNum)
                    gc.print(num,1,y)
                    gc.print(num,2,y+1)
                    gc_setColor(.97,.97,.97,ENV.lineNum)
                    gc.print(num,2,y)
                    gc.print(num,2,y)
                end
            end

            -- Draw spawn line
            gc_setLineWidth(4)
            gc_setColor(1,sin(t)*.4+.5,0,.5)
            gc_rectangle('fill',0,fieldTop,300,4)

            -- Draw height limit line
            gc_setColor(.4,.7+sin(t*12)*.3,1,.7)
            gc_rectangle('fill',0,-ENV.heightLimit*30-FBN-2,300,4)

            -- Draw FXs
            _drawFXs(P)

            -- Draw current block
            if P.alive and P.control and P.cur then
                local C=P.cur
                local curColor=C.color

                local trans=P.lockDelay/ENV.lock
                local centerPos=C.RS.centerPos[C.id][C.dir]
                local centerX=30*(P.curX+centerPos[2])-20

                -- Draw ghost & rotation center
                local centerDisp=ENV.center and C.RS.centerDisp[C.id]
                if ENV.ghost then
                    drawGhost[ENV.ghostType](P.cur.bk,P.curX,P.ghoY,ENV.ghost,P.skinLib,curColor)
                    if centerDisp then
                        gc_setColor(1,1,1,ENV.center)
                        gc_draw(C.RS.centerTex,centerX,-30*(P.ghoY+centerPos[1])+10)
                    end
                elseif repMode then
                    drawGhost.grayCell(P.cur.bk,P.curX,P.ghoY,.15,nil,nil)
                end

                local dy=ENV.smooth and P.ghoY~=P.curY and (P.dropDelay/ENV.drop-1)*30 or 0
                gc_translate(0,-dy)
                    -- Draw block & rotation center
                    if ENV.block then
                        _drawBlockOutline(P.cur.bk,P.curX,P.curY,P.skinLib[curColor],trans)
                        _drawBlock(P.cur.bk,P.curX,P.curY,P.skinLib[curColor])
                        if centerDisp then
                            gc_setColor(1,1,1,ENV.center)
                            gc_draw(C.RS.centerTex,centerX,-30*(P.curY+centerPos[1])+10)
                        end
                    elseif repMode then
                        _drawBlockShade(P.cur.bk,P.curX,P.curY,trans*.3)
                    end
                gc_translate(0,dy)
            end

            -- Draw next preview
            if ENV.nextPos then
                if P.nextQueue[1] then _drawNextPreview(P.nextQueue[1],ENV.fieldH,P.fieldBeneath) end
                if P.holdQueue[1] then _drawHoldPreview(P.holdQueue[1],ENV.fieldH,P.fieldBeneath) end
            end

            -- Draw AI's drop destination
            if P.destFX then
                local L=P.destFX
                local texture=TEXTURE.puzzleMark[21]
                for i=1,#L,2 do
                    gc_draw(texture,30*L[i],-30*L[i+1]-30)
                end
            end

            -- Board cover
            if ENV.hideBoard then
                gc_stencil(hideBoardStencil[ENV.hideBoard])
                gc_setStencilTest('equal',1)
                local alpha
                if repMode then
                    gc_setLineWidth(18.8)
                    alpha=.7
                else
                    gc_setLineWidth(20)
                    alpha=1
                end
                for i=0,24 do
                    local l=.32+.05*sin(i*.26+t*.2)
                    gc_setColor(l,l,l,alpha)
                    gc_line(20*i-190,-602,20*i+10,2)
                end
            end
            gc_translate(0,-600)
        gc_setStencilTest()
        gc_pop()
            -- Draw Frame and buffers
            gc_setColor(P.frameColor)
            gc_draw(playerborder,-17,-12)
            _drawBuffer(P.atkBuffer,ENV.bufferWarn,P.atkBufferSum1,P.atkBufferSum)
            _drawB2Bbar(P.b2b,P.b2b1)
            _drawLDI(ENV.easyFresh,P.lockDelay/ENV.lock,P.freshTime)

            -- Draw target selecting pad
            if ENV.layout=='royale' then
                if P.atkMode then
                    gc_setColor(1,.8,0,min(P.swappingAtkMode,30)*.02)
                    gc_rectangle('fill',RCPB[2*P.atkMode-1],RCPB[2*P.atkMode],90,35,8,4)
                end
                gc_setColor(1,1,1,min(P.swappingAtkMode,30)*.025)
                setFont(35)
                gc_setLineWidth(1)
                for i=1,4 do
                    gc_rectangle('line',RCPB[2*i-1],RCPB[2*i],90,35,8,4)
                    gc_printf(text.atkModeName[i],RCPB[2*i-1]-4,RCPB[2*i]+4,200,"center",nil,.5)
                end
            end

            -- Spike
            local sp,spt=P.spike,P.spikeTime
            if ENV.showSpike and spt>0 and sp>=10 then
                local rg=10/sp
                gc_setColor(rg,rg,1,min(spt/30,.8))
                local x,y=150,100
                if spt>85 then
                    local d=2*(spt-85)*min(sp/50,1)
                    x,y=x+(rnd()-.5)*d,y+(rnd()-.5)*d
                end
                mDraw(P.spikeText,x,y,nil,min(.3+(sp/26)*.4+spt/100*.3,1))
            end

            -- Bonus texts
            TEXT.draw(P.bonus)

            -- Display Ys
            -- gc_setLineWidth(6)
            -- if P.curY then gc_setColor(COLOR.R)gc_line(0,611-P.curY*30,300,610-P.curY*30) end
            -- if P.ghoY then gc_setColor(COLOR.G)gc_line(0,615-P.ghoY*30,300,615-P.ghoY*30) end
            -- if P.minY then gc_setColor(COLOR.B)gc_line(0,619-P.minY*30,300,620-P.minY*30) end
            --                                     gc_line(0,600-P.garbageBeneath*30,300,600-P.garbageBeneath*30)
        gc_pop()

        -- Score & Time
        setFont(25)
        local tm=STRING.time(P.stat.time)
        gc_setColor(0,0,0,.3)
        gc_print(ceil(P.score1),18,509)
        gc_print(tm,18,539)
        gc_setColor(.97,.97,.92)
        gc_print(ceil(P.score1),20,510)
        gc_setColor(.85,.9,.97)
        gc_print(tm,20,540)

        -- FinesseCombo
        ;(P.type=='remote' and _drawFinesseCombo_remote or _drawFinesseCombo_norm)(P)

        -- Mode informations
        for i=1,#ENV.mesDisp do
            gc_setColor(.97,.97,.97)
            ENV.mesDisp[i](P,repMode)
        end

        if P.frameRun<180 then
            _drawStartCounter(P.frameRun)
        end
    gc_pop()
end
function draw.small(P)
    -- Update canvas
    P.frameWait=P.frameWait-1
    if P.frameWait==0 then
        P.frameWait=10
        gc_setCanvas(P.canvas)
        gc_clear(0,0,0,.4)
        gc_push('transform')
        gc_origin()
        gc_setColor(1,1,1,P.result and max(20-P.endCounter,0)*.05 or 1)

        -- Field
        local F=P.field
        local texture=SKIN.libMini[SETTING.skinSet]
        for j=1,#F do
            for i=1,10 do if F[j][i]>0 then
                gc_draw(texture[F[j][i]],6*i-6,120-6*j)
            end end
        end

        -- Draw border
        if P.alive then
            gc_setLineWidth(2)
            gc_setColor(P.frameColor)
            gc_rectangle('line',0,0,60,120)
        end

        -- Draw badge
        if P.gameEnv.layout=='royale' then
            gc_setColor(1,1,1)
            for i=1,P.strength do
                gc_draw(IMG.badgeIcon,12*i-7,4,nil,.5)
            end
        end

        -- Draw result
        if P.result then
            gc_setColor(1,1,1,min(P.endCounter,60)*.01)
            setFont(20)mDraw(TEXTOBJ[P.result],30,60,nil,P.size)
            setFont(15)GC.mStr(P.modeData.place,30,82)
        end
        gc_pop()
        gc_setCanvas()
    end

    -- Draw Canvas
    gc_setColor(1,1,1)
    local size=P.size
    gc_draw(P.canvas,P.x,P.y,nil,size*10)
    if P.killMark then
        gc_setColor(1,0,0)
        gc_rectangle('fill',P.x+40*size,P.y+40*size,160*size,160*size)
    end
end
function draw.demo(P)
    local ENV=P.gameEnv

    -- Camera
    gc_push('transform')
        gc_translate(P.x,P.y)
        gc_scale(P.size)

        gc_translate(-150,0)
        _applyField(P)
            gc_setStencilTest()
            gc_setColor(0,0,0,.6)
            gc_rectangle('fill',0,0,300,600,3)
            gc_push('transform')
                gc_translate(0,600)
                _drawField(P)
                _drawFXs(P)
                if P.alive and P.cur then
                    local curColor=P.cur.color
                    if ENV.ghost then
                        drawGhost[ENV.ghostType](P.cur.bk,P.curX,P.ghoY,ENV.ghost,P.skinLib,curColor)
                    end
                    if ENV.block then
                        local dy=ENV.smooth and P.ghoY~=P.curY and (P.dropDelay/ENV.drop-1)*30 or 0
                        gc_translate(0,-dy)
                        _drawBlockOutline(P.cur.bk,P.curX,P.curY,P.skinLib[curColor],P.lockDelay/ENV.lock)
                        _drawBlock(P.cur.bk,P.curX,P.curY,P.skinLib[curColor])
                        gc_translate(0,dy)
                    end
                end
            gc_pop()

            local blockImg=TEXTURE.miniBlock
            local skinSet=ENV.skin

            -- Draw hold
            local N=1
            while P.holdQueue[N] do
                local id=P.holdQueue[N].id
                local _=BLOCK_COLORS[skinSet[id]]
                gc_setColor(_[1],_[2],_[3],.3)
                _=blockImg[id]
                gc_draw(_,15,40*N-10,nil,8,nil,0,_:getHeight()*.5)
                N=N+1
            end

            -- Draw next
            N=1
            while N<=ENV.nextCount and P.nextQueue[N] do
                local id=P.nextQueue[N].id
                local _=BLOCK_COLORS[skinSet[id]]
                gc_setColor(_[1],_[2],_[3],.3)
                _=blockImg[id]
                gc_draw(_,285,40*N-10,nil,8,nil,_:getWidth(),_:getHeight()*.5)
                N=N+1
            end

            -- Frame
            gc_setLineWidth(2)
            gc_setColor(COLOR.Z)
            gc_rectangle('line',-1,-1,302,602,3)
        gc_pop()
        gc_pop()
        gc_translate(150,0)
        TEXT.draw(P.bonus)
    gc_pop()
end

return draw
