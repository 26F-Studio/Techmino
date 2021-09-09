-------------------------------------------------
--Var P in other files represent Player object!--
-------------------------------------------------
local Player={}--Player class

local int,ceil,rnd=math.floor,math.ceil,math.random
local max,min,modf=math.max,math.min,math.modf
local ins,rem=table.insert,table.remove
local resume,yield,status=coroutine.resume,coroutine.yield,coroutine.status

local SFX,BGM,VOC,VIB,SYSFX=SFX,BGM,VOC,VIB,SYSFX
local FREEROW,TABLE,TEXT,NET,TASK=FREEROW,TABLE,TEXT,NET,TASK
local PLAYERS,PLY_ALIVE,GAME=PLAYERS,PLY_ALIVE,GAME

local ply_draw=require"parts.player.draw"
local ply_update=require"parts.player.update"

--------------------------<FX>--------------------------
function Player:_showText(text,dx,dy,font,style,spd,stop)
    ins(self.bonus,TEXT.getText(text,150+dx,300+dy,font,style,spd,stop))
end
function Player:_createLockFX(x,y,t)--Not used
    ins(self.lockFX,{x,y,0,t})
end
function Player:_createDropFX(x,y,w,h)--Not used
    ins(self.dropFX,{x,y,w,h})
end
function Player:_createMoveFX(color,x,y,spd)--Not used
    ins(self.moveFX,{color,x,y,0,spd})
end
function Player:_createClearingFX(y,spd)--Not used
    ins(self.clearFX,{y,0,spd})
end
function Player:showText(text,dx,dy,font,style,spd,stop)
    if self.gameEnv.text then
        ins(self.bonus,TEXT.getText(text,150+dx,300+dy,font,style,spd,stop))
    end
end
function Player:popScore(score)
    if self.gameEnv.score then
        self:_showText(
            score,
            self:getCenterX()*30,
            (10-self:getCenterY())*30+self.fieldBeneath+self.fieldUp,
            40-600/(score+20),
            'score',2
        )
    end
end
function Player:stageComplete(stage)
    self:_showText(text.stage:gsub("$1",stage),0,-120,60,'fly',1.26)
end
function Player:createLockFX()
    if self.gameEnv.lockFX then
        local CB=self.cur.bk
        local t=12-self.gameEnv.lockFX*2

        for i=1,#CB do
            local y=self.curY+i-1
            local L=self.clearedRow
            for j=1,#L do
                if L[j]==y then goto CONTINUE_skip end
            end
            y=-30*y
            for j=1,#CB[1]do
                if CB[i][j]then
                    ins(self.lockFX,{30*(self.curX+j-2),y,0,t})
                end
            end
            ::CONTINUE_skip::
        end
    end
end
function Player:clearLockFX()
    for i=1,#self.lockFX do
        self.lockFX[i]=nil
    end
end
function Player:createDropFX()
    if self.gameEnv.dropFX and self.gameEnv.block then
        local CB=self.cur.bk
        if self.curY-self.ghoY+1>#CB then
            ins(self.dropFX,{self.curX,self.curY-1,#CB[1],self.curY-self.ghoY-#CB+1,0,13-2*self.gameEnv.dropFX})
        end
    end
end
function Player:createMoveFX(moveDir)
    local ENV=self.gameEnv
    if ENV.moveFX and ENV.block then
        local spd=10-1.5*ENV.moveFX
        local C=self.cur.color
        local CB=self.cur.bk
        local x=self.curX-1
        local y=ENV.smooth and self.curY+self.dropDelay/ENV.drop-2 or self.curY-1
        local L=self.moveFX
        if moveDir=='left'then
            for i=1,#CB do
                for j=#CB[1],1,-1 do
                    if CB[i][j]then
                        ins(L,{C,x+j,y+i,0,spd})
                        break
                    end
                end
            end
        elseif moveDir=='right'then
            for i=1,#CB do
                for j=1,#CB[1]do
                    if CB[i][j]then
                        ins(L,{C,x+j,y+i,0,spd})
                        break
                    end
                end
            end
        elseif moveDir=='down'then
            for j=1,#CB[1]do
                for i=#CB,1,-1 do
                    if CB[i][j]then
                        ins(L,{C,x+j,y+i,0,spd})
                        break
                    end
                end
            end
        else
            for i=1,#CB do
                for j=1,#CB[1]do
                    if CB[i][j]then
                        ins(L,{C,x+j,y+i,0,spd})
                    end
                end
            end
        end
    end
end
function Player:createClearingFX(y)
    if self.gameEnv.clearFX then
        ins(self.clearFX,{y,0,7-self.gameEnv.clearFX})
    end
end
function Player:createSplashFX(h)
    if self.gameEnv.splashFX then
        local L=self.field[h]
        local size=self.size
        local y=self.fieldY+size*(self.fieldOff.y+self.fieldBeneath+self.fieldUp+615)-30*h*size
        for x=1,10 do
            local c=L[x]
            if c>0 then
                SYSFX.newCell(
                    2.5-self.gameEnv.splashFX*.4,
                    self.skinLib[c],
                    size,
                    self.fieldX+(30*x-15)*size,y,
                    rnd()*5-2.5,rnd()*-1,
                    0,.6
                )
            end
        end
    end
end
function Player:createBeam(R,send)
    if self.gameEnv.atkFX then
        local power=self.gameEnv.atkFX
        local color=self.cur.color
        local x1,y1,x2,y2
        if self.miniMode then
            x1,y1=self.centerX,self.centerY
        else
            local C=self.cur
            local sc=C.RS.centerPos[C.id][C.dir]
            x1=self.x+(30*(self.curX+sc[2])-30+15+150)*self.size
            y1=self.y+(600-30*(self.curY+sc[1])+15+self.fieldUp+self.fieldBeneath)*self.size
        end
        if R.miniMode then x2,y2=R.centerX,R.centerY
        else x2,y2=R.x+308*R.size,R.y+450*R.size
        end

        local c=minoColor[color]
        local r,g,b=c[1]*2,c[2]*2,c[3]*2

        local a=GAME.modeEnv.royaleMode and not(self.type=='human'or R.type=='human')and .2 or 1
        SYSFX.newAttack(1-power*.1,x1,y1,x2,y2,int(send^.7*(4+power)),r,g,b,a*(power+2)*.0626)
    end
end
--------------------------</FX>--------------------------

--------------------------<Method>--------------------------
function Player:newTask(code,...)
    local thread=coroutine.create(code)
    resume(thread,self,...)
    if status(thread)~='dead'then
        ins(self.tasks,{
            thread=thread,
            code=code,
            args={...},
        })
    end
end

function Player:setPosition(x,y,size)
    size=size or 1
    self.x,self.y,self.size=x,y,size
    if self.miniMode or self.demo then
        self.fieldX,self.fieldY=x,y
        self.centerX,self.centerY=x+300*size,y+600*size
    else
        self.fieldX,self.fieldY=x+150*size,y
        self.centerX,self.centerY=x+300*size,y+300*size
        self.absFieldX,self.absFieldY=x+150*size,y-10*size
    end
end
do--function Player:movePosition(x,y,size)
    local function task_movePosition(self,x,y,size)
        local x1,y1,size1=self.x,self.y,self.size
        while true do
            yield()
            if (x1-x)^2+(y1-y)^2<1 then
                self:setPosition(x,y,size)
                return true
            else
                x1=x1+(x-x1)*.126
                y1=y1+(y-y1)*.126
                size1=size1+(size-size1)*.126
                self:setPosition(x1,y1,size1)
            end
        end
    end
    local function check_player(obj,Ptar)
        return obj.args[1]==Ptar
    end
    function Player:movePosition(x,y,size)
        TASK.removeTask_iterate(check_player,self)
        TASK.new(task_movePosition,self,x,y,size or self.size)
    end
end

local frameColorList={[0]=COLOR.Z,COLOR.lG,COLOR.lB,COLOR.lV,COLOR.lO}
function Player:setFrameColor(c)
    self.frameColor=frameColorList[c]
end
function Player:switchKey(id,on)
    self.keyAvailable[id]=on
    if not on then
        self:releaseKey(id)
    end
    if self.type=='human'then
        VK.switchKey(id,on)
    end
end
function Player:set20G(if20g)
    self._20G=if20g
    local f=not self.gameEnv.noTele and not if20g
    self:switchKey(14,not if20g)
    self:switchKey(15,f)
    self:switchKey(16,f)
    if if20g and self.bot then
        self.bot:switch20G()
    end
end
function Player:setHold(count)--Set hold count (false/true as 0/1)
    if not count then
        count=0
    elseif count==true then
        count=1
    end
    self:switchKey(8,count>0)
    self.gameEnv.holdCount=count
    self.holdTime=count
    while self.holdQueue[count+1]do rem(self.holdQueue)end
end
function Player:setNext(next,hidden)--Set next count　(use hidden=true if set env.nextStartPos>1)
    self.gameEnv.nextCount=next
    if next==0 then
        self.drawNext=NULL
    elseif not hidden then
        self.drawNext=ply_draw.drawNext_norm
    else
        self.drawNext=ply_draw.drawNext_hidden
    end
end
function Player:setInvisible(time)--Time in frames
    if time<0 then
        self.keepVisible=true
        self.showTime=1e99
    else
        self.keepVisible=false
        self.showTime=time
    end
end
function Player:setRS(RSname)
    local rs=RSlist[RSname]or RSlist.TRS
    self.RS=rs

    --Reset all player's blocks' RSs
    for i=1,#self.nextQueue do self.nextQueue[i].RS=rs end
    for i=1,#self.holdQueue do self.holdQueue[i].RS=rs end
    if self.cur then
        self.cur.RS=rs
    end
end

function Player:triggerDropEvents()
    local L=self.gameEnv.dropPiece
    for i=1,#L do
        L[i](self)
    end
end

function Player:getHolePos()--Get a good garbage-line hole position
    if self.garbageBeneath==0 then
        return generateLine(self.holeRND:random(10))
    else
        local p=self.holeRND:random(10)
        if self.field[1][p]<=0 then
            return generateLine(self.holeRND:random(10))
        end
        return generateLine(p)
    end
end
function Player:garbageRelease()--Check garbage buffer and try to release them
    local n,flag=1
    while true do
        local A=self.atkBuffer[n]
        if A and A.countdown<=0 and not A.sent then
            self:garbageRise(19+A.lv,A.amount,A.line)
            self.atkBufferSum=self.atkBufferSum-A.amount
            A.sent,A.time=true,0
            self.stat.pend=self.stat.pend+A.amount
            n=n+1
            flag=true
        else
            break
        end
    end
    if flag and self.bot then
        self.bot:updateField()
    end
end
function Player:garbageRise(color,amount,line)--Release n-lines garbage to field
    local _
    local t=self.showTime*2
    for _=1,amount do
        ins(self.field,1,FREEROW.get(0,true))
        ins(self.visTime,1,FREEROW.get(t))
        for i=1,10 do
            self.field[1][i]=bit.rshift(line,i-1)%2==1 and color or 0
        end
    end
    self.fieldBeneath=self.fieldBeneath+amount*30
    if self.cur then
        self.curY=self.curY+amount
        self.ghoY=self.ghoY+amount
    end
    self.garbageBeneath=self.garbageBeneath+amount
    for i=1,#self.clearingRow do
        self.clearingRow[i]=self.clearingRow[i]+amount
    end
    self:freshBlock('push')
    for i=1,#self.lockFX do
        _=self.lockFX[i]
        _[2]=_[2]-30*amount--Shift 30px per line cleared
    end
    for i=1,#self.dropFX do
        _=self.dropFX[i]
        _[3],_[5]=_[3]+amount,_[5]+amount
    end
    if #self.field>self.gameEnv.heightLimit then
        self:lose()
    end
end

local invList={2,1,4,3,5,6,7}
function Player:pushLineList(L,mir)--Push some lines to field
    local l=#L
    local S=self.gameEnv.skin
    for i=1,l do
        local r=FREEROW.get(0)
        if not mir then
            for j=1,10 do
                r[j]=S[L[i][j]]or 0
            end
        else
            for j=1,10 do
                r[j]=S[invList[L[i][11-j]]]or 0
            end
        end
        ins(self.field,1,r)
        ins(self.visTime,1,FREEROW.get(20))
    end
    self.fieldBeneath=self.fieldBeneath+30*l
    self.curY=self.curY+l
    self.ghoY=self.ghoY+l
    self:freshBlock('push')
end
function Player:pushNextList(L,mir)--Push some nexts to nextQueue
    for i=1,#L do
        self:getNext(mir and invList[L[i]]or L[i])
    end
end

function Player:getCenterX()
    local C=self.cur
    return self.curX+C.RS.centerPos[C.id][C.dir][2]-5.5
end
function Player:getCenterY()
    local C=self.cur
    return self.curY-C.RS.centerPos[C.id][C.dir][1]
end
function Player:solid(x,y)
    if x<1 or x>10 or y<1 then
        return true
    end
    if y>#self.field then
        return false
    end
    return self.field[y]
    [x]>0--to catch bug (nil[*])
end
function Player:ifoverlap(bk,x,y)
    local C=#bk[1]
    if x<1 or x+C>11 or y<1 then
        return true
    end
    if y>#self.field then
        return
    end
    for i=1,#bk do
        if self.field[y+i-1]then
            for j=1,C do
                if bk[i][j]and self.field[y+i-1][x+j-1]>0 then
                    return true
                end
            end
        end
    end
end
function Player:attack(R,send,time,line,fromStream)
    if GAME.net then
        if self.type=='human'then--Local player attack others
            ins(GAME.rep,self.frameRun)
            ins(GAME.rep,
                R.sid+
                send*0x100+
                time*0x10000+
                line*0x100000000+
                0x2000000000000
            )
            self:createBeam(R,send)
        end
        if fromStream and R.type=='human'then--Local player receiving lines
            ins(GAME.rep,R.frameRun)
            ins(GAME.rep,
                self.sid+
                send*0x100+
                time*0x10000+
                line*0x100000000+
                0x1000000000000
            )
            R:receive(self,send,time,line)
        end
    else
        R:receive(self,send,time,line)
        self:createBeam(R,send)
    end
end
function Player:receive(A,send,time,line)
    self.lastRecv=A
    local B=self.atkBuffer
    if send+self.atkBufferSum>self.gameEnv.bufferLimit then
        send=self.gameEnv.bufferLimit-self.atkBufferSum
    end
    if send>0 then
        local m,k=#B,1
        while k<=m and time>B[k].countdown do k=k+1 end
        ins(B,k,{
            line=line,
            amount=send,
            countdown=time,
            cd0=time,
            time=0,
            sent=false,
            lv=min(int(send^.69),5),
        })--Sorted insert(by time)
        self.atkBufferSum=self.atkBufferSum+send
        self.stat.recv=self.stat.recv+send
        if self.sound then
            SFX.play(send<4 and'blip_1'or'blip_2',min(send+1,5)*.1)
        end
    end
end
function Player:clearAttackBuffer()
    for i=1,#self.atkBuffer do
        local A=self.atkBuffer[i]
        if not A.sent then
            A.sent=true
            A.time=0
        end
    end
    self.atkBufferSum=0
end
function Player:freshTarget()
    if self.atkMode==1 then
        if not self.atking or not self.atking.alive or rnd()<.1 then
            self:changeAtk(randomTarget(self))
        end
    elseif self.atkMode==2 then
        self:changeAtk(self~=GAME.mostBadge and GAME.mostBadge or GAME.secBadge or randomTarget(self))
    elseif self.atkMode==3 then
        self:changeAtk(self~=GAME.mostDangerous and GAME.mostDangerous or GAME.secDangerous or randomTarget(self))
    elseif self.atkMode==4 then
        for i=1,#self.atker do
            if not self.atker[i].alive then
                rem(self.atker,i)
                return
            end
        end
    end
end
function Player:changeAtkMode(m)
    if self.atkMode==m then
        return
    end
    self.atkMode=m
    if m==1 then
        self:changeAtk(randomTarget(self))
    elseif m==2 or m==3 then
        self:freshTarget()
    elseif m==4 then
        self:changeAtk()
    end
end
function Player:changeAtk(R)
    -- if self.type~='human'then R=PLAYERS[1]end--1vALL mode?
    if self.atking then
        local K=self.atking.atker
        local i=TABLE.find(K,self)
        if i then
            rem(K,i)
        end
    end
    if R then
        self.atking=R
        ins(R.atker,self)
    else
        self.atking=false
    end
end
function Player:freshBlock(mode)--string mode: push/move/fresh/newBlock
    local ENV=self.gameEnv
    --Fresh ghost
    if(mode=='move'or mode=='newBlock'or mode=='push')and self.cur then
        local CB=self.cur.bk
        self.ghoY=min(#self.field+1,self.curY)
        if self._20G or ENV.sdarr==0 and self.keyPressing[7]and self.downing>ENV.sddas then
            local _=self.ghoY

            --Move ghost to bottom
            while not self:ifoverlap(CB,self.curX,self.ghoY-1)do
                self.ghoY=self.ghoY-1
            end

            --Cancel spinLast
            if _~=self.ghoY then
                self.spinLast=false
            end

            --Create FX if dropped
            if self.curY>self.ghoY then
                self:createDropFX()
                if ENV.shakeFX then
                    self.fieldOff.vy=.5
                end
                self.curY=self.ghoY
            end
        else
            while not self:ifoverlap(CB,self.curX,self.ghoY-1)do
                self.ghoY=self.ghoY-1
            end
        end
    end

    --Fresh delays
    if mode=='move'or mode=='newBlock'or mode=='fresh'then
        local d0,l0=ENV.drop,ENV.lock
        local C=self.cur
        local sc=C.RS.centerPos[C.id][C.dir]
        if ENV.easyFresh then
            if self.lockDelay<l0 and self.freshTime>0 then
                if mode~='newBlock'then
                    self.freshTime=self.freshTime-1
                end
                self.lockDelay=l0
                self.dropDelay=d0
            end
            if self.curY+sc[1]<self.minY then
                self.minY=self.curY+sc[1]
                self.dropDelay=d0
                self.lockDelay=l0
            end
        else
            if self.curY+sc[1]<self.minY then
                self.minY=self.curY+sc[1]
                if self.lockDelay<l0 and self.freshTime>0 then
                    self.freshTime=self.freshTime-1
                    self.dropDelay=d0
                    self.lockDelay=l0
                end
            end
        end
    end
end
function Player:lock()
    local CB=self.cur.bk
    for i=1,#CB do
        local y=self.curY+i-1
        if not self.field[y]then
            self.field[y]=FREEROW.get(0)
            self.visTime[y]=FREEROW.get(0)
        end
        for j=1,#CB[1]do
            if CB[i][j]then
                self.field[y][self.curX+j-1]=self.cur.color
                self.visTime[y][self.curX+j-1]=self.showTime
            end
        end
    end
end

function Player:checkClear(field,start,height,CB,CX)
    local cc=0
    if self.gameEnv.fillClear then
        for i=1,height do
            local h=start+i-2

            --Bomb trigger (optional, must with CB)
            if CB and h>0 and field[h]and self.clearedRow[cc]~=h then
                for x=1,#CB[1]do
                    if CB[i][x]and field[h][CX+x-1]==19 then
                        cc=cc+1
                        self.clearingRow[cc]=h-cc+1
                        self.clearedRow[cc]=h
                        break
                    end
                end
            end

            h=h+1
            --Row filled
            for x=1,10 do
                if field[h][x]<=0 then
                    goto CONTINUE_notFull
                end
            end
            cc=cc+1
            ins(self.clearingRow,h-cc+1)
            ins(self.clearedRow,h)
            ::CONTINUE_notFull::
        end
    end
    return cc
end
function Player:roofCheck()
    local CB=self.cur.bk
    for x=1,#CB[1]do
        local y=#CB

        --Find the highest y of blocks' x-th column
        while not CB[y][x]do y=y-1 end

        local testX=self.curX+x-1--Optimize

        --Test the whole column of field to find roof
        for testY=self.curY+y,#self.field do
            if self:solid(testX,testY)then
                return true
            end
        end
    end
    return false
end
function Player:removeTopClearingFX()
    for i=#self.clearingRow,1,-1 do
        if self.clearingRow[i]>#self.field then
            rem(self.clearingRow)
        else
            return
        end
    end
end
function Player:checkMission(piece,mission)
    if mission<5 then
        return piece.row==mission and not piece.spin
    elseif mission<9 then
        return piece.row==mission-4 and piece.spin
    elseif mission==9 then
        return piece.pc
    elseif mission<90 then
        return piece.row==mission%10 and piece.name==int(mission/10)and piece.spin
    end
    return false
end

local spawnSFX_name={}for i=1,7 do spawnSFX_name[i]='spawn_'..i end
function Player:resetBlock()--Reset Block's position and execute I*S
    local C=self.cur
    local sc=C.RS.centerPos[C.id][C.dir]

    self.curX=int(6-#C.bk[1]*.5)
    local y=int(self.gameEnv.fieldH+1-modf(sc[1]))+ceil(self.fieldBeneath/30)
    self.curY=y
    self.minY=y+sc[1]

    local pressing=self.keyPressing
    --IMS
    if self.gameEnv.ims and(pressing[1]and self.movDir==-1 or pressing[2]and self.movDir==1)and self.moving>=self.gameEnv.das then
        local x=self.curX+self.movDir
        if not self:ifoverlap(C.bk,x,y)then
            self.curX=x
        end
    end

    --IRS
    if self.gameEnv.irs then
        if pressing[5]then
            self:spin(2,true)
        elseif pressing[3]then
            if pressing[4]then
                self:spin(2,true)
            else
                self:spin(1,true)
            end
        elseif pressing[4]then
            self:spin(3,true)
        end
        pressing[3],pressing[4],pressing[5]=false,false,false
    end

    --DAS cut
    if self.gameEnv.dascut>0 then
        self.moving=self.moving-(self.moving>0 and 1 or -1)*self.gameEnv.dascut
    end

    --Spawn SFX
    if self.sound and C.id<8 then
        SFX.fplay(spawnSFX_name[C.id],SETTING.sfx_spawn)
    end
end

function Player:spin(d,ifpre)
    local C=self.cur
    local sc=C.RS.centerPos[C.id][C.dir]
    local kickData=C.RS.kickTable[C.id]
    if type(kickData)=='table'then
        local idir=(C.dir+d)%4
        kickData=kickData[C.dir*10+idir]
        if not kickData then
            self:freshBlock('move')
            SFX.play(ifpre and'prerotate'or'rotate',nil,self:getCenterX()*.15)
            return
        end
        local icb=BLOCKS[C.id][idir]
        local isc=C.RS.centerPos[C.id][idir]
        local baseX,baseY=self.curX+sc[2]-isc[2],self.curY+sc[1]-isc[1]
        for test=1,#kickData do
            local ix,iy=baseX+kickData[test][1],baseY+kickData[test][2]
            if (self.freshTime>0 or kickData[test][2]<=0)and not self:ifoverlap(icb,ix,iy)then
                --Create moveFX at the original position
                self:createMoveFX()

                --Change block position
                sc,C.bk,C.dir=isc,icb,idir
                self.curX,self.curY=ix,iy
                self.spinLast=test==2 and 0 or 1

                --Fresh ghost and freshTime
                local t=self.freshTime
                if not ifpre then
                    self:freshBlock('move')
                end
                if kickData[test][2]>0 and self.freshTime==t and self.curY~=self.imgY then
                    self.freshTime=self.freshTime-1
                end

                --Sound & Field shaking
                local sfx
                if ifpre then
                    sfx='prerotate'
                elseif self:ifoverlap(icb,ix,iy+1)and self:ifoverlap(icb,ix-1,iy)and self:ifoverlap(icb,ix+1,iy)then
                    sfx='rotatekick'
                    if self.gameEnv.shakeFX then
                        if d==1 or d==3 then
                            self.fieldOff.va=self.fieldOff.va+(2-d)*6e-3
                        else
                            self.fieldOff.va=self.fieldOff.va+self:getCenterX()*3e-3
                        end
                    end
                else
                    sfx='rotate'
                end
                if self.sound then
                    SFX.play(sfx,nil,self:getCenterX()*.15)
                end
                self.stat.rotate=self.stat.rotate+1
                return
            end
        end
    elseif kickData then
        kickData(self,d)
    else
        self:freshBlock('move')
        SFX.play(ifpre and'prerotate'or'rotate',nil,self:getCenterX()*.15)
    end
end
local phyHoldKickX={
    [true]={0,-1,1},--X==?.0 tests
    [false]={-.5,.5},--X==?.5 tests
}
function Player:hold(ifpre)
    local ENV=self.gameEnv
    if self.holdTime>0 and(ifpre or self.waiting==-1)then
        if #self.holdQueue<ENV.holdCount and self.nextQueue[1]then--Skip
            local C=self.cur
            ins(self.holdQueue,self:getBlock(C.id,C.name,C.color))

            local t=self.holdTime
            self:popNext(true)
            self.holdTime=t
        else--Hold
            local C,H=self.cur,self.holdQueue[1]

            --Finesse check
            if H and C and H.id==C.id and H.name==C.name then
                self.ctrlCount=self.ctrlCount+1
            elseif self.ctrlCount<=1 then
                self.ctrlCount=0
            end

            if ENV.phyHold and C and not ifpre then--Physical hold
                local x,y=self.curX,self.curY
                x=x+(#C.bk[1]-#H.bk[1])*.5
                y=y+(#C.bk-#H.bk)*.5

                local iki=phyHoldKickX[x==int(x)]
                for Y=int(y),ceil(y+.5)do
                    for i=1,#iki do
                        local X=x+iki[i]
                        if not self:ifoverlap(H.bk,X,Y)then
                            x,y=X,Y
                            goto BREAK_success
                        end
                    end
                end
                --<for-else> All test failed, interrupt with sound
                    SFX.play('finesseError')
                    do return end
                --<for-end>
                ::BREAK_success::

                self.spinLast=false
                self.spinSeq=0
                local hb=self:getBlock(C.id)
                hb.name=C.name
                hb.color=C.color
                ins(self.holdQueue,hb)
                self.cur=rem(self.holdQueue,1)
                self.curX,self.curY=x,y
            else--Normal hold
                self.spinLast=false
                self.spinSeq=0

                if C then
                    local hb=self:getBlock(C.id)
                    hb.color=C.color
                    hb.name=C.name
                    ins(self.holdQueue,hb)
                end
                self.cur=rem(self.holdQueue,1)

                self:resetBlock()
            end
            self:freshBlock('move')
            self.dropDelay=ENV.drop
            self.lockDelay=ENV.lock
            if self:ifoverlap(self.cur.bk,self.curX,self.curY)then
                self:lock()
                self:lose()
            end
        end

        self.freshTime=int(min(self.freshTime+ENV.freshLimit*.25,ENV.freshLimit*((self.holdTime+1)/ENV.holdCount),ENV.freshLimit))
        if not ENV.infHold then
            self.holdTime=self.holdTime-1
        end

        if self.sound then
            SFX.play(ifpre and'prehold'or'hold')
        end

        self.stat.hold=self.stat.hold+1
    end
end

function Player:getBlock(id,name,color)--Get a block object
    local ENV=self.gameEnv
    local dir=ENV.face[id]
    return{
        id=id,
        dir=dir,
        bk=BLOCKS[id][dir],
        RS=self.RS,
        name=name or id,
        color=ENV.bone and 17 or color or ENV.skin[id],
    }
end
function Player:getNext(id)--Push a block to nextQueue
    ins(self.nextQueue,self:getBlock(id))
    if self.bot then
        self.bot:pushNewNext(id)
    end
end
function Player:popNext(ifhold)--Pop nextQueue to hand
    local ENV=self.gameEnv
    if not ifhold then
        self.holdTime=min(self.holdTime+1,ENV.holdCount)
    end
    self.spinLast=false
    self.spinSeq=0
    self.ctrlCount=0

    self.cur=rem(self.nextQueue,1)
    self.newNext()
    if self.cur then
        self.pieceCount=self.pieceCount+1

        local pressing=self.keyPressing

        --IHS
        if not ifhold and pressing[8]and ENV.ihs and self.holdTime>0 then
            self:hold(true)
            pressing[8]=false
        else
            self:resetBlock()
        end

        self.dropDelay=ENV.drop
        self.lockDelay=ENV.lock
        self.freshTime=ENV.freshLimit

        if self.cur then
            if self:ifoverlap(self.cur.bk,self.curX,self.curY)then
                self:lock()
                self:lose()
            end
            self:freshBlock('newBlock')
        end

        --IHdS
        if pressing[6]and not ifhold then
            self:act_hardDrop()
            pressing[6]=false
        end
    else
        self:hold()
    end
end

function Player:cancel(N)--Cancel Garbage
    local off=0--Lines offseted
    local bf=self.atkBuffer
    for i=1,#bf do
        if self.atkBufferSum==0 or N==0 then
            break
        end
        local A=bf[i]
        if not A.sent then
            local O=min(A.amount,N)--Cur Offset
            if N<A.amount then
                A.amount=A.amount-O
            else
                A.sent,A.time=true,0
            end
            off=off+O
            self.atkBufferSum=self.atkBufferSum-O
            N=N-O
        end
    end
    return off
end
do--Player.drop(self)--Place piece
    local clearSCR={80,200,400}--Techrash:1K; B2Bmul:1.3/1.8
    local spinSCR={
        {200,750,1300,2000},--Z
        {200,750,1300,2000},--S
        {220,700,1300,2000},--L
        {220,700,1300,2000},--J
        {250,800,1400,2000},--T
        {260,900,1600,4500,7000},--O
        {300,1200,1700,4000,6000},--I
        {220,800,2000,3000,8000,26000},--Else
    }--B2B*=1.2; B3B*=2.0; Mini*=.6
    local b2bPoint={50,100,180,800,1000,9999}

    local b2bATK={3,5,8,12,18,26}
    local reAtk={0,0,1,1,1,2,2,3,3}
    local reDef={0,1,1,2,3,3,4,4,5}

    local spinVoice={'zspin','sspin','jspin','lspin','tspin','ospin','ispin','zspin','sspin','pspin','qspin','fspin','espin','tspin','uspin','vspin','wspin','xspin','jspin','lspin','rspin','yspin','nspin','hspin','ispin','ispin','cspin','ispin','ospin'}
    local clearVoice={'single','double','triple','techrash','pentacrash','hexacrash'}
    local spinSFX={[0]='spin_0','spin_1','spin_2'}
    local clearSFX={'clear_1','clear_2','clear_3'}
    local renSFX={}for i=1,11 do renSFX[i]='ren_'..i end
    local finesseList={
        {
            {1,2,1,0,1,2,2,1},
            {2,2,2,1,1,2,3,2,2},
            1,2
        },--Z
        1,--S
        {
            {1,2,1,0,1,2,2,1},
            {2,2,3,2,1,2,3,3,2},
            {3,4,3,2,3,4,4,3},
            {2,3,2,1,2,3,3,2,2},
        },--J
        3,--L
        3,--T
        {
            {1,2,2,1,0,1,2,2,1},
            1,1,1
        },--O
        {
            {1,2,1,0,1,2,1},
            {2,2,2,2,1,1,2,2,2,2},
            1,2
        },--I
        {
            {1,2,1,0,1,2,2,1},
            {2,3,2,1,2,3,3,2},
            1,2
        },--Z5
        8,--S5
        3,--self
        3,--Q
        {
            {1,2,1,0,1,2,2,1},
            {2,3,2,1,2,3,3,2},
            {3,4,3,2,3,4,4,3},
            2
        },--F
        12,--E
        12,--T5
        3,--U
        {
            {1,2,1,0,1,2,2,1},
            {2,3,3,2,1,2,3,2},
            {3,4,4,3,2,3,4,3},
            {2,3,2,1,2,3,3,2},
        },--V
        12,--W
        {
            {1,2,1,0,1,2,2,1},
            1,1,1
        },--X
        {
            {1,2,1,0,1,2,1},
            {2,2,3,2,1,2,3,2,2},
            {3,4,3,2,3,4,3},
            2,
        },--J5
        19,--L5
        19,--R
        19,--Y
        19,--N
        19,--H
        {
            {1,1,0,1,2,1},
            {2,3,2,2,1,2,3,2,3,2},
            1,2
        },--I5
        {
            {1,2,1,0,1,2,2,1},
            {2,2,3,2,1,2,3,3,2,2},
            1,2
        },--I3
        {
            {1,2,2,1,0,1,2,2,1},
            {2,3,3,2,1,2,3,3,2},
            {3,4,4,3,2,3,4,4,3},
            2
        },--C
        {
            {1,2,2,1,0,1,2,2,1},
            {2,2,3,2,1,1,2,3,2,2},
            1,2
        },--I2
        {
            {1,2,2,1,0,1,2,3,2,1},
            1,1,1
        },--O1
    }
    for k,v in next,finesseList do
        if type(v)=='table'then
            for d,l in next,v do
                if type(l)=='number'then
                    v[d]=v[l]
                end
            end
        else
            finesseList[k]=finesseList[v]
        end
    end

    function Player:drop(autoLock)
        local _
        local CHN=VOC.getFreeChannel()
        self.dropTime[11]=ins(self.dropTime,1,self.frameRun)--Update speed dial
        local ENV=self.gameEnv
        local Stat=self.stat
        local piece=self.lastPiece

        local finish
        local cmb=self.combo
        local C,CB,CX,CY=self.cur,self.cur.bk,self.curX,self.curY
        local sc=C.RS.centerPos[C.id][C.dir]
        local clear--If clear with no line fall
        local cc,gbcc=0,0--Row/garbage-row cleared,full-part
        local atk,exblock=0,0--Attack & extra defense
        local send,off=0,0--Sending lines remain & offset
        local cscore,sendTime=10,0--Score & send Time
        local dospin,mini=0

        piece.id,piece.name=C.id,C.name
        piece.curX,piece.curY,piece.dir=self.curX,self.curY,C.dir
        piece.centX,piece.centY=self.curX+sc[2],self.curY+sc[1]
        piece.frame,piece.autoLock=self.frameRun,autoLock
        self.waiting=ENV.wait

        --Tri-corner spin check
        if self.spinLast then
            if C.id<6 then
                local x,y=CX+sc[2],CY+sc[1]
                local c=0
                if self:solid(x-1,y+1)then c=c+1 end
                if self:solid(x+1,y+1)then c=c+1 end
                if c~=0 then
                    if self:solid(x-1,y-1)then c=c+1 end
                    if self:solid(x+1,y-1)then c=c+1 end
                    if c>2 then
                        dospin=dospin+2
                    end
                end
            end
        end
        --Immovable spin check
        if self:ifoverlap(CB,CX,CY+1)and self:ifoverlap(CB,CX-1,CY)and self:ifoverlap(CB,CX+1,CY)then
            dospin=dospin+2
        end

        self:lock()

        --Clear list of cleared-rows
        if self.clearedRow[1]then
            TABLE.cut(self.clearedRow)
        end

        --Check line clear
        cc=cc+self:checkClear(self.field,CY,#CB,CB,CX)

        --Create clearing FX
        for i=1,cc do
            local y=self.clearedRow[i]
            self:createClearingFX(y)
            self:createSplashFX(y)
        end

        --Create locking FX
        if cc==0 then
            self:createLockFX()
        else
            self:clearLockFX()
        end

        --Final spin check
        if dospin>0 then
            if cc>0 then
                dospin=dospin+(self.spinLast or 0)
                if dospin<3 then
                    mini=C.id<6 and cc<#CB
                end
            end
        else
            dospin=false
        end

        --Finesse: roof check
        local finesse=CY>ENV.fieldH-2 or self:roofCheck()

        --Remove rows need to be cleared
        if cc>0 then
            for i=cc,1,-1 do
                _=self.clearedRow[i]
                if self.field[_].garbage then
                    self.garbageBeneath=self.garbageBeneath-1
                    gbcc=gbcc+1
                end
                FREEROW.discard(rem(self.field,_))
                FREEROW.discard(rem(self.visTime,_))
            end
        end

        --Cancel top clearing FX
        self:removeTopClearingFX()
        if self.clearingRow[1]then
            self.falling=ENV.fall
        else
            clear=true
        end

        --Finesse check (control)
        local finePts
        if not finesse then
            if dospin then--Allow 2 more step for roof-less spin
                self.ctrlCount=self.ctrlCount-2
            end
            local id=C.id
            local d=self.ctrlCount-finesseList[id][C.dir+1][CX]
            finePts=d<=0 and 5 or max(3-d,0)
        else
            finePts=5
        end
        piece.finePts=finePts

        Stat.finesseRate=Stat.finesseRate+finePts
        if finePts<5 then
            Stat.extraPiece=Stat.extraPiece+1
            if ENV.fineKill then
                finish='lose'
            end
            if self.sound then
                if ENV.fineKill then
                    SFX.play('finesseError_long',.6)
                elseif ENV.fine then
                    SFX.play('finesseError',.8)
                else
                    SFX.play('lock',nil,self:getCenterX()*.15)
                end
            end
        elseif self.sound then
            SFX.play('lock',nil,self:getCenterX()*.15)
        end

        if finePts<=1 then
            self.finesseCombo=0
        else
            self.finesseCombo=self.finesseCombo+1
            if self.finesseCombo>2 then
                self.finesseComboTime=12
            end
        end

        piece.spin,piece.mini=dospin,false
        piece.pc,piece.hpc=false,false
        piece.special=false
        if cc>0 then--If lines cleared,about 200 lines of codes below
            cmb=cmb+1
            if dospin then
                cscore=(spinSCR[C.name]or spinSCR[8])[cc]
                if self.b2b>800 then
                    self:showText(text.b3b..text.block[C.name]..text.spin.." "..text.clear[cc],0,-30,35,'stretch')
                    atk=b2bATK[cc]+cc*.5
                    exblock=exblock+1
                    cscore=cscore*2
                    Stat.b3b=Stat.b3b+1
                    if self.sound then
                        VOC.play('b3b',CHN)
                    end
                elseif self.b2b>=50 then
                    self:showText(text.b2b..text.block[C.name]..text.spin.." "..text.clear[cc],0,-30,35,'spin')
                    atk=b2bATK[cc]
                    cscore=cscore*1.2
                    Stat.b2b=Stat.b2b+1
                    if self.sound then
                        VOC.play('b2b',CHN)
                    end
                else
                    self:showText(text.block[C.name]..text.spin.." "..text.clear[cc],0,-30,45,'spin')
                    atk=2*cc
                end
                sendTime=20+atk*20
                if mini then
                    self:showText(text.mini,0,-80,35,'appear')
                    atk=atk*.25
                    sendTime=sendTime+60
                    cscore=cscore*.5
                    self.b2b=self.b2b+b2bPoint[cc]*.5
                    if self.sound then
                        VOC.play('mini',CHN)
                    end
                else
                    self.b2b=self.b2b+b2bPoint[cc]
                end
                piece.mini=mini
                piece.special=true
                if self.sound then
                    SFX.play(spinSFX[cc]or'spin_3')
                    VOC.play(spinVoice[C.name],CHN)
                end
            elseif cc>=4 then
                cscore=cc==4 and 1000 or cc==5 and 1500 or 2000
                if self.b2b>800 then
                    self:showText(text.b3b..text.clear[cc],0,-30,50,'fly')
                    atk=4*cc-10
                    sendTime=100
                    exblock=exblock+1
                    cscore=cscore*1.8
                    Stat.b3b=Stat.b3b+1
                    if self.sound then
                        VOC.play('b3b',CHN)
                    end
                elseif self.b2b>=50 then
                    self:showText(text.b2b..text.clear[cc],0,-30,50,'drive')
                    sendTime=80
                    atk=3*cc-7
                    cscore=cscore*1.3
                    Stat.b2b=Stat.b2b+1
                    if self.sound then
                        VOC.play('b2b',CHN)
                    end
                else
                    self:showText(text.clear[cc],0,-30,70,'stretch')
                    sendTime=60
                    atk=2*cc-4
                end
                self.b2b=self.b2b+cc*50-50
                piece.special=true
            else
                piece.special=false
            end
            if self.sound then
                VOC.play(clearVoice[cc],CHN)
            end

            --Normal clear,reduce B2B point
            if not piece.special then
                self.b2b=max(self.b2b-250,0)
                self:showText(text.clear[cc],0,-30,35,'appear',(8-cc)*.3)
                atk=cc-.5
                sendTime=20+int(atk*20)
                cscore=cscore+clearSCR[cc]
            end

            --Combo bonus
            sendTime=sendTime+25*cmb
            if cmb>1 then
                atk=atk*(1+(cc==1 and .15 or .25)*min(cmb-1,12))
                if cmb>=3 then
                    atk=atk+1
                end
                self:showText(text.cmb[min(cmb,21)],0,25,15+min(cmb,15)*5,cmb<10 and'appear'or'flicker')
                cscore=cscore+min(50*cmb,500)*(2*cc-1)
            end

            --PC/HPC
            if clear and cc>=#C.bk then
                if CY==1 then
                    self:showText(text.PC,0,-80,50,'flicker')
                    atk=max(atk,min(8+Stat.pc*2,16))
                    exblock=exblock+2
                    sendTime=sendTime+120
                    if Stat.row+cc>4 then
                        self.b2b=self.b2b+800
                        cscore=cscore+300*min(6+Stat.pc,10)
                    else
                        cscore=cscore+626
                    end
                    Stat.pc=Stat.pc+1
                    if self.sound then
                        SFX.play('clear')
                        VOC.play('perfect_clear',CHN)
                    end
                    piece.pc=true
                    piece.special=true
                elseif cc>1 or #self.field==self.garbageBeneath then
                    self:showText(text.HPC,0,-80,50,'fly')
                    atk=atk+4
                    exblock=exblock+2
                    sendTime=sendTime+60
                    self.b2b=self.b2b+100
                    cscore=cscore+626
                    Stat.hpc=Stat.hpc+1
                    if self.sound then
                        SFX.play('clear')
                        VOC.play('half_clear',CHN)
                    end
                    piece.hpc=true
                    piece.special=true
                end
            end

            if self.b2b>1000 then
                self.b2b=1000
            elseif self.b2b==0 and ENV.b2bKill then
                finish='lose'
            end

            --Bonus atk/def when focused
            if GAME.modeEnv.royaleMode then
                local i=min(#self.atker,9)
                if i>1 then
                    atk=atk+reAtk[i]
                    exblock=exblock+reDef[i]
                end
            end

            --Send Lines
            atk=int(atk*(1+self.strength*.25))--Badge Buff
            send=atk
            if exblock>0 then
                exblock=int(exblock*(1+self.strength*.25))--Badge Buff
                self:showText("+"..exblock,0,53,20,'fly')
                off=off+self:cancel(exblock)
            end
            if send>=1 then
                self:showText(send,0,80,35,'zoomout')
                _=self:cancel(send)
                send=send-_
                off=off+_
                if send>0 then
                    local T
                    if GAME.modeEnv.royaleMode then
                        if self.atkMode==4 then
                            local M=#self.atker
                            if M>0 then
                                for i=1,M do
                                    self:attack(self.atker[i],send,sendTime,generateLine(self.atkRND:random(10)))
                                end
                            else
                                T=randomTarget(self)
                            end
                        else
                            T=self.atking
                            self:freshTarget()
                        end
                    elseif #PLY_ALIVE>1 then
                        T=randomTarget(self)
                    end
                    if T then
                        self:attack(T,send,sendTime,generateLine(self.atkRND:random(10)))
                    end
                end
                if self.sound and send>3 then
                    SFX.play('emit',min(send,7)*.1)
                end
            end

            --SFX & Vibrate
            if self.sound then
                SFX.play(clearSFX[cc]or'clear_4')
                SFX.play(renSFX[min(cmb,11)])
                if cmb>14 then
                    SFX.play('ren_mega',(cmb-10)*.1)
                end
                VIB(cc+1)
            end
        else--No lines clear
            cmb=0

            --Spin bonus
            if dospin then
                self:showText(text.block[C.name]..text.spin,0,-30,45,'appear')
                self.b2b=self.b2b+20
                if self.sound then
                    SFX.play('spin_0')
                    VOC.play(spinVoice[C.name],CHN)
                end
                cscore=30
            end

            if self.b2b>800 then
                self.b2b=max(self.b2b-40,800)
            end
            self:garbageRelease()
        end

        self.combo=cmb

        --Spike
        if atk>0 then
            self.spike=self.spikeTime==0 and atk or self.spike+atk
            self.spikeTime=min(self.spikeTime+atk*20,100)
            self.spikeText:set(self.spike)
        end

        --DropSpeed bonus
        if self._20G then
            cscore=cscore*2
        elseif ENV.drop<1 then
            cscore=cscore*1.5
        elseif ENV.drop<3 then
            cscore=cscore*1.2
        end

        --Speed bonus
        if self.dropSpeed>60 then
            cscore=cscore*(.9+self.dropSpeed/600)
        end

        cscore=int(cscore)
        self:popScore(cscore)

        piece.row,piece.dig=cc,gbcc
        piece.score=cscore
        piece.atk,piece.exblock=atk,exblock
        piece.off,piece.send=off,send

        --Check clearing task
        if cc>0 and self.curMission then
            if self:checkMission(piece,ENV.mission[self.curMission])then
                self.curMission=self.curMission+1
                SFX.play('reach')
                if self.curMission>#ENV.mission then
                    self.curMission=false
                    if not finish then
                        finish='finish'
                    end
                end
            elseif ENV.missionKill then
                self:_showText(text.missionFailed,0,140,40,'flicker',.5)
                SFX.play('finesseError_long',.6)
                finish='lose'
            end
        end

        --Check bot things
        if self.bot then
            self.bot:checkDest()
            self.bot:updateB2B(self.b2b)
            self.bot:updateCombo(self.combo)
        end

        --Check height limit
        if cc==0 and #self.field>ENV.heightLimit then
            self:lose()
        end

        --Update stat
        Stat.piece=Stat.piece+1
        Stat.row=Stat.row+cc
        Stat.maxFinesseCombo=max(Stat.maxFinesseCombo,self.finesseCombo)
        Stat.maxCombo=max(Stat.maxCombo,self.combo)
        Stat.score=Stat.score+cscore
        if atk>0 then
            Stat.atk=Stat.atk+atk
            if send>0 then
                Stat.send=Stat.send+int(send)
            end
            if off>0 then
                Stat.off=Stat.off+off
            end
        end
        if gbcc>0 then
            Stat.dig=Stat.dig+gbcc
            if atk>0 then
                Stat.digatk=Stat.digatk+atk*gbcc/cc
            end
        end
        local n=C.name
        if dospin then
            _=Stat.spin[n]    _[cc+1]=_[cc+1]+1--Spin[1~25][0~4]
            _=Stat.spins    _[cc+1]=_[cc+1]+1--Spin[0~4]
        elseif cc>0 then
            _=Stat.clear[n]    _[cc]=_[cc]+1--Clear[1~25][1~5]
            _=Stat.clears    _[cc]=_[cc]+1--Clear[1~5]
        end

        if finish then
            if finish=='lose'then
                self:lose()
            else
                self:triggerDropEvents()
                if finish then
                    self:win(finish)
                end
            end
        else
            self:triggerDropEvents()
        end
    end
end
function Player:loadAI(data)--Load AI params
    self.bot=BOT.new(self,data)
    self.bot.data=data
end
--------------------------</Methods>--------------------------

--------------------------<Ticks>--------------------------
local function task_throwBadge(ifAI,sender,time)
    while true do
        yield()
        time=time-1
        if time%4==0 then
            local S,R=sender,sender.lastRecv
            local x1,y1,x2,y2
            if S.miniMode then
                x1,y1=S.centerX,S.centerY
            else
                x1,y1=S.x+300*S.size,S.y+450*S.size
            end
            if R.miniMode then
                x2,y2=R.centerX,R.centerY
            else
                x2,y2=R.x+66*R.size,R.y+274*R.size
            end

            --Generate badge object
            SYSFX.newBadge(x1,y1,x2,y2)

            if not ifAI and time%8==0 then
                SFX.play('collect')
            end
        end
        if time<=0 then
            return
        end
    end
end
local function task_finish(self)
    while true do
        yield()
        self.endCounter=self.endCounter+1
        if self.endCounter<40 then
            --Make field visible
            for j=1,#self.field do for i=1,10 do
                if self.visTime[j][i]<20 then
                    self.visTime[j][i]=self.visTime[j][i]+.5
                end
            end end
        elseif self.endCounter==60 then
            return
        end
    end
end
local function task_lose(self)
    while true do
        yield()
        self.endCounter=self.endCounter+1
        if self.endCounter<40 then
            --Make field visible
            for j=1,#self.field do for i=1,10 do
                if self.visTime[j][i]<20 then
                    self.visTime[j][i]=self.visTime[j][i]+.5
                end
            end end
        elseif self.endCounter>80 then
            for i=1,#self.field do
                for j=1,10 do
                    if self.visTime[i][j]>0 then
                        self.visTime[i][j]=self.visTime[i][j]-1
                    end
                end
            end
            if self.endCounter==120 then
                for _=#self.field,1,-1 do
                    FREEROW.discard(self.field[_])
                    FREEROW.discard(self.visTime[_])
                    self.field[_],self.visTime[_]=nil
                end
                return
            end
        end
        if not GAME.modeEnv.royaleMode and #PLAYERS>1 then
            self.y=self.y+self.endCounter*.26
            self.absFieldY=self.absFieldY+self.endCounter*.26
        end
    end
end
local function task_autoPause()
    local time=0
    while true do
        yield()
        time=time+1
        if SCN.cur~='game'or PLAYERS[1].frameRun<180 then
            return
        elseif time==120 then
            pauseGame()
            return
        end
    end
end
--------------------------</Ticks>--------------------------

--------------------------<Events>--------------------------
function Player:die()--Called both when win/lose!
    self.alive=false
    self.timing=false
    self.control=false
    self.update=ply_update.dead
    self.waiting=1e99
    self.b2b=0
    self.tasks={}
    self:clearAttackBuffer()
    for i=1,#self.field do
        for j=1,10 do
            self.visTime[i][j]=min(self.visTime[i][j],20)
        end
    end
    if GAME.net then
        if self.id==1 then
            ins(GAME.rep,self.frameRun)
            ins(GAME.rep,0)
        else
            if self.lastRecv and self.lastRecv.id==1 then
                SFX.play('collect')
            end
        end
    end
end
function Player:revive()
    self.waiting=62
    local h=#self.field
    for _=h,1,-1 do
        FREEROW.discard(self.field[_])
        FREEROW.discard(self.visTime[_])
        self.field[_],self.visTime[_]=nil
    end
    self.garbageBeneath=0
    if self.bot then
        self.bot:revive()
    end

    self:clearAttackBuffer()

    self.life=self.life-1
    self.fieldBeneath=0
    self.b2b=0

    for i=1,h do
        self:createClearingFX(i,1.5)
    end
    SYSFX.newShade(1.4,self.fieldX,self.fieldY,300*self.size,610*self.size)
    SYSFX.newRectRipple(2,self.fieldX,self.fieldY,300*self.size,610*self.size)
    SYSFX.newRipple(2,self.x+(475+25*(self.life<3 and self.life or 0)+12)*self.size,self.y+(595+12)*self.size,20)
    SFX.play('clear_3')
    SFX.play('emit')
end
function Player:win(result)
    if self.result then return end
    self:die()
    self.result='win'
    if GAME.modeEnv.royaleMode then
        self.modeData.place=1
        self:changeAtk()
    end
    if self.type=='human'then
        GAME.result=result or'gamewin'
        SFX.play('win')
        VOC.play('win')
        if GAME.modeEnv.royaleMode then
            BGM.play('8-bit happiness')
        end
    end
    if GAME.curMode.name=='custom_puzzle'then
        self:_showText(text.win,0,0,90,'beat',.4)
    else
        self:_showText(text.win,0,0,90,'beat',.5,.2)
    end
    if self.type=='human'then
        gameOver()
        TASK.new(task_autoPause)
    end
    self:newTask(task_finish)
end
function Player:lose(force)
    if self.result then
        return
    end
    if not force then
        if self.life>0 then
            self:revive()
            return
        end
        if self.type=='remote'then
            self.waiting=1e99
            return
        end
    end
    self:die()
    do
        local p=TABLE.find(PLY_ALIVE,self)
        if p then rem(PLY_ALIVE,p)end
    end
    self.result='lose'
    if GAME.modeEnv.royaleMode then
        self:changeAtk()
        self.modeData.place=#PLY_ALIVE+1
        self.strength=0
        if self.lastRecv then
            local A,depth=self,0
            repeat
                A,depth=A.lastRecv,depth+1
            until not A or A.alive or A==self or depth==3
            if A and A.alive then
                if self.id==1 or A.id==1 then
                    self.killMark=A.id==1
                end
                A.modeData.ko,A.badge=A.modeData.ko+1,A.badge+self.badge+1
                for i=A.strength+1,4 do
                    if A.badge>=ROYALEDATA.powerUp[i]then
                        A.strength=i
                        A:setFrameColor(i)
                    end
                end
                self.lastRecv=A
                if self.id==1 or A.id==1 then
                    TASK.new(task_throwBadge,not A.type=='human',self,max(3,self.badge)*4)
                end
            end
        else
            self.badge=-1
        end

        freshMostBadge()
        freshMostDangerous()
        if #PLY_ALIVE==ROYALEDATA.stage[GAME.stage]then
            royaleLevelup()
        end
        self:_showText(self.modeData.place,0,120,60,'appear',.26,.9)
    end
    self.gameEnv.keepVisible=self.gameEnv.visible~='show'
    self:_showText(text.lose,0,0,90,'appear',.26,.9)
    if self.type=='human'then
        GAME.result='gameover'
        SFX.play('fail')
        VOC.play('lose')
        if GAME.modeEnv.royaleMode then
            BGM.play('end')
        end
        gameOver()
        self:newTask(#PLAYERS>1 and task_lose or task_finish)
        if GAME.net and not NET.spectate then
            NET.signal_die()
        else
            TASK.new(task_autoPause)
        end
    else
        self:newTask(task_lose)
    end
    if #PLY_ALIVE==1 then
        PLY_ALIVE[1]:win()
    end
end
--------------------------<\Events>--------------------------

--------------------------<Actions>--------------------------
function Player:act_moveLeft(auto)
    if not auto then
        self.ctrlCount=self.ctrlCount+1
    end
    self.movDir=-1
    if self.keyPressing[9]then
        if self.gameEnv.swap then
            self:changeAtkMode(1)
            self.keyPressing[1]=false
        end
    elseif self.control and self.waiting==-1 then
        if self.cur and not self:ifoverlap(self.cur.bk,self.curX-1,self.curY)then
            self:createMoveFX('left')
            self.curX=self.curX-1
            self:freshBlock('move')
            if self.sound and self.curY==self.ghoY then
                SFX.play('move')
            end
            if not auto then
                self.moving=0
            end
            self.spinLast=false
        else
            self.moving=self.gameEnv.das
        end
    else
        self.moving=0
    end
end
function Player:act_moveRight(auto)
    if not auto then
        self.ctrlCount=self.ctrlCount+1
    end
    self.movDir=1
    if self.keyPressing[9]then
        if self.gameEnv.swap then
            self:changeAtkMode(2)
            self.keyPressing[2]=false
        end
    elseif self.control and self.waiting==-1 then
        if self.cur and not self:ifoverlap(self.cur.bk,self.curX+1,self.curY)then
            self:createMoveFX('right')
            self.curX=self.curX+1
            self:freshBlock('move')
            if self.sound and self.curY==self.ghoY then
                SFX.play('move')
            end
            if not auto then
                self.moving=0
            end
            self.spinLast=false
        else
            self.moving=self.gameEnv.das
        end
    else
        self.moving=0
    end
end
function Player:act_rotRight()
    if self.control and self.waiting==-1 and self.cur then
        self.ctrlCount=self.ctrlCount+1
        self:spin(1)
        self.keyPressing[3]=false
    end
end
function Player:act_rotLeft()
    if self.control and self.waiting==-1 and self.cur then
        self.ctrlCount=self.ctrlCount+1
        self:spin(3)
        self.keyPressing[4]=false
    end
end
function Player:act_rot180()
    if self.control and self.waiting==-1 and self.cur then
        self.ctrlCount=self.ctrlCount+2
        self:spin(2)
        self.keyPressing[5]=false
    end
end
function Player:act_hardDrop()
    local ENV=self.gameEnv
    if self.keyPressing[9]then
        if ENV.swap then
            self:changeAtkMode(3)
        end
        self.keyPressing[6]=false
    elseif self.control and self.waiting==-1 and self.cur then
        if self.lastPiece.autoLock and self.frameRun-self.lastPiece.frame<ENV.dropcut then
            SFX.play('drop_cancel',.3)
        else
            if self.curY>self.ghoY then
                self:createDropFX()
                self.curY=self.ghoY
                self.spinLast=false
                if self.sound then
                    SFX.play('drop',nil,self:getCenterX()*.15)
                    VIB(1)
                end
            end
            if ENV.shakeFX then
                self.fieldOff.vy=.6
                self.fieldOff.va=self.fieldOff.va+self:getCenterX()*6e-4
            end
            self.lockDelay=-1
            self:drop()
            self.keyPressing[6]=false
        end
    end
end
function Player:act_softDrop()
    local ENV=self.gameEnv
    if self.keyPressing[9]then
        if ENV.swap then
            self:changeAtkMode(4)
        end
    else
        self.downing=1
        if self.control and self.waiting==-1 and self.cur then
            if self.curY>self.ghoY then
                self.curY=self.curY-1
                self:freshBlock('fresh')
                self.spinLast=false
            elseif ENV.deepDrop then
                local CB=self.cur.bk
                local y=self.curY-1
                while self:ifoverlap(CB,self.curX,y)and y>0 do
                    y=y-1
                end
                if y>0 then
                    self.ghoY=y
                    self:createDropFX()
                    self.curY=y
                    self:freshBlock('move')
                    SFX.play('swipe')
                end
            end
        end
    end
end
function Player:act_hold()
    if self.control then
        if self.waiting==-1 then
            self:hold()
            self.keyPressing[8]=false
        end
    end
end
function Player:act_func1()
    self.gameEnv.fkey1(self)
end
function Player:act_func2()
    self.gameEnv.fkey2(self)
end

function Player:act_insLeft(auto)
    if not self.cur then
        return
    end
    local x0=self.curX
    while not self:ifoverlap(self.cur.bk,self.curX-1,self.curY)do
        self:createMoveFX('left')
        self.curX=self.curX-1
        self:freshBlock('move')
    end
    if self.curX~=x0 then
        self.spinLast=false
    end
    if self.gameEnv.shakeFX then
        self.fieldOff.vx=-.5
    end
    if auto then
        if self.ctrlCount==0 then
            self.ctrlCount=1
        end
    else
        self.ctrlCount=self.ctrlCount+1
    end
end
function Player:act_insRight(auto)
    if not self.cur then
        return
    end
    local x0=self.curX
    while not self:ifoverlap(self.cur.bk,self.curX+1,self.curY)do
        self:createMoveFX('right')
        self.curX=self.curX+1
        self:freshBlock('move')
    end
    if self.curX~=x0 then
        self.spinLast=false
    end
    if self.gameEnv.shakeFX then
        self.fieldOff.vx=.5
    end
    if auto then
        if self.ctrlCount==0 then
            self.ctrlCount=1
        end
    else
        self.ctrlCount=self.ctrlCount+1
    end
end
function Player:act_insDown()
    if self.cur and self.curY>self.ghoY then
        local ENV=self.gameEnv
        self:createDropFX()
        if ENV.shakeFX then
            self.fieldOff.vy=.5
        end
        self.curY=self.ghoY
        self.lockDelay=ENV.lock
        self.spinLast=false
        self:freshBlock('fresh')
    end
end
function Player:act_down1()
    if self.cur and self.curY>self.ghoY then
        self:createMoveFX('down')
        self.curY=self.curY-1
        self:freshBlock('fresh')
        self.spinLast=false
    end
end
function Player:act_down4()
    if self.cur and self.curY>self.ghoY then
        local ghoY0=self.ghoY
        self.ghoY=max(self.curY-4,self.ghoY)
        self:createDropFX()
        self.curY,self.ghoY=self.ghoY,ghoY0
        self:freshBlock('fresh')
        self.spinLast=false
    end
end
function Player:act_down10()
    if self.cur and self.curY>self.ghoY then
        local ghoY0=self.ghoY
        self.ghoY=max(self.curY-10,self.ghoY)
        self:createDropFX()
        self.curY,self.ghoY=self.ghoY,ghoY0
        self:freshBlock('fresh')
        self.spinLast=false
    end
end
function Player:act_dropLeft()
    if self.cur then
        self:act_insLeft()
        self:act_hardDrop()
    end
end
function Player:act_dropRight()
    if self.cur then
        self:act_insRight()
        self:act_hardDrop()
    end
end
function Player:act_zangiLeft()
    if self.cur then
        self:act_insLeft()
        self:act_insDown()
        self:act_insRight()
        self:act_hardDrop()
    end
end
function Player:act_zangiRight()
    if self.cur then
        self:act_insRight()
        self:act_insDown()
        self:act_insLeft()
        self:act_hardDrop()
    end
end
Player.actList={
    Player.act_moveLeft,  --1
    Player.act_moveRight, --2
    Player.act_rotRight,  --3
    Player.act_rotLeft,   --4
    Player.act_rot180,    --5
    Player.act_hardDrop,  --6
    Player.act_softDrop,  --7
    Player.act_hold,      --8
    Player.act_func1,     --9
    Player.act_func2,     --10
    Player.act_insLeft,   --11
    Player.act_insRight,  --12
    Player.act_insDown,   --13
    Player.act_down1,     --14
    Player.act_down4,     --15
    Player.act_down10,    --16
    Player.act_dropLeft,  --17
    Player.act_dropRight, --18
    Player.act_zangiLeft, --19
    Player.act_zangiRight,--20
}
--------------------------</Actions>--------------------------
return Player
