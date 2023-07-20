-------------------------------------------------
-- Var P in other files represent Player object!--
-------------------------------------------------

local Player={}-- Player class

local int,ceil,rnd=math.floor,math.ceil,math.random
local max,min,abs,modf=math.max,math.min,math.abs,math.modf
local assert,ins,rem=assert,table.insert,table.remove
local resume,yield,status=coroutine.resume,coroutine.yield,coroutine.status
local approach=MATH.expApproach

local SFX,BGM,VOC,VIB,SYSFX=SFX,BGM,VOC,VIB,SYSFX
local LINE,TABLE,TEXT,TASK=LINE,TABLE,TEXT,TASK
local PLAYERS,PLY_ALIVE,GAME=PLAYERS,PLY_ALIVE,GAME

local SETTING=SETTING
--------------------------<FX>--------------------------
function Player:_showText(text,dx,dy,font,style,spd,stop)
    ins(self.bonus,TEXT.getText(text,150+dx,300+dy,font,style,spd,stop))
end
function Player:_createLockFX(x,y,t)-- Not used
    ins(self.lockFX,{x,y,0,t})
end
function Player:_createDropFX(x,y,w,h)-- Not used
    ins(self.dropFX,{x,y,w,h})
end
function Player:_createMoveFX(color,x,y,spd)-- Not used
    ins(self.moveFX,{color,x,y,0,spd})
end
function Player:_createClearingFX(y,spd)-- Not used
    ins(self.clearFX,{y,0,spd})
end
function Player:_rotateField(dir)
    if self.gameEnv.shakeFX then
        if dir==1 or dir==3 then
            self.swingOffset.va=self.swingOffset.va+(2-dir)*6e-3
        else
            self.swingOffset.va=self.swingOffset.va+self:getCenterX()*3e-3
        end
    end
end
function Player:shakeField(strength)-- Range: 1~10
    if self.gameEnv.shakeFX then
        self.shakeTimer=max(self.shakeTimer,3*self.gameEnv.shakeFX+int(4*min(max(strength,1),10)))
    end
end
function Player:checkTouchSound()
    if self.sound and self.curY==self.ghoY then
        SFX.play('touch')
    end
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
    self:_showText(text.stage:repD(stage),0,-120,60,'fly',1.26)
end
function Player:createLockFX()
    if self.gameEnv.lockFX then
        local CB=self.cur.bk
        local t=12-self.gameEnv.lockFX*2

        for i=1,#CB do
            local y=self.curY+i-1
            local L=self.clearedRow
            local skip
            for j=1,#L do
                if L[j]==y then skip=true break end-- goto CONTINUE_skip
            end
            if not skip then
                y=-30*y
                for j=1,#CB[1] do
                    if CB[i][j] then
                        ins(self.lockFX,{30*(self.curX+j-2),y,0,t})
                    end
                end
            end
            -- ::CONTINUE_skip::
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
        if moveDir=='left' then
            for i=1,#CB do
                for j=#CB[1],1,-1 do
                    if CB[i][j] then
                        ins(L,{C,x+j,y+i,0,spd})
                        break
                    end
                end
            end
        elseif moveDir=='right' then
            for i=1,#CB do
                for j=1,#CB[1] do
                    if CB[i][j] then
                        ins(L,{C,x+j,y+i,0,spd})
                        break
                    end
                end
            end
        elseif moveDir=='down' then
            for j=1,#CB[1] do
                for i=#CB,1,-1 do
                    if CB[i][j] then
                        ins(L,{C,x+j,y+i,0,spd})
                        break
                    end
                end
            end
        else
            for i=1,#CB do
                for j=1,#CB[1] do
                    if CB[i][j] then
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
        local y=self.fieldY+size*(self.swingOffset.y+self.fieldBeneath+self.fieldUp+615)-30*h*size
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
    if self.gameEnv.atkFX and self.cur then
        local C=self.cur
        local power=self.gameEnv.atkFX
        local x1,y1,x2,y2
        if self.miniMode then
            x1,y1=self.centerX,self.centerY
        else
            local sc=C.RS.centerPos[C.id][C.dir]
            x1=self.x+(30*(self.curX+sc[2])-30+15+150)*self.size
            y1=self.y+(600-30*(self.curY+sc[1])+15+self.fieldUp+self.fieldBeneath)*self.size
        end
        if R.miniMode then x2,y2=R.centerX,R.centerY
        else x2,y2=R.x+308*R.size,R.y+450*R.size
        end

        local c=BLOCK_COLORS[C.color]
        local r,g,b=c[1]*2,c[2]*2,c[3]*2
        local a=(power+2)*.0626
        if self.type~='human' and R.type~='human' then a=a*.2 end
        SYSFX.newAttack(1-power*.1,x1,y1,x2,y2,int(send^.7*(4+power)),r,g,b,a)
    end
end
--------------------------</FX>--------------------------

--------------------------<Action>--------------------------
function Player:_deepDrop()
    local CB=self.cur.bk
    local y=self.curY-1
    while self:ifoverlap(CB,self.curX,y) and y>0 do
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
function Player:act_moveLeft(auto)
    self.movDir=-1
    if not self.control then return end
    if not auto then
        self.ctrlCount=self.ctrlCount+1
    end
    if self.cur then
        if self.cur and not self:ifoverlap(self.cur.bk,self.curX-1,self.curY) then
            self:createMoveFX('left')
            self.curX=self.curX-1
            self:freshBlock('move')
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
    self.movDir=1
    if not self.control then return end
    if not auto then
        self.ctrlCount=self.ctrlCount+1
    end
    if self.cur then
        if self.cur and not self:ifoverlap(self.cur.bk,self.curX+1,self.curY) then
            self:createMoveFX('right')
            self.curX=self.curX+1
            self:freshBlock('move')
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
    if not self.control then return end
    if self.cur then
        self.ctrlCount=self.ctrlCount+1
        self:spin(1)
        self.keyPressing[3]=false
    end
end
function Player:act_rotLeft()
    if not self.control then return end
    if self.cur then
        self.ctrlCount=self.ctrlCount+1
        self:spin(3)
        self.keyPressing[4]=false
    end
end
function Player:act_rot180()
    if not self.control then return end
    if self.cur then
        self.ctrlCount=self.ctrlCount+2
        self:spin(2)
        self.keyPressing[5]=false
    end
end
function Player:act_hardDrop()
    if not self.control then return end
    local ENV=self.gameEnv
    if self.cur then
        if self.lastPiece.autoLock and self.frameRun-self.lastPiece.frame<ENV.dropcut then
            SFX.play('drop_cancel',.3)
        else
            if self.curY>self.ghoY then
                self:createDropFX()
                self.curY=self.ghoY
                self.spinLast=false
                if self.sound then
                    SFX.play('drop',nil,self:getCenterX()*.15)
                    if SETTING.vib>0 then VIB(SETTING.vib+1) end
                end
            end
            if ENV.shakeFX then
                self.swingOffset.vy=.6
                self.swingOffset.va=self.swingOffset.va+self:getCenterX()*6e-4
            end
            self.lockDelay=-1
            self.keyPressing[6]=false
            self:drop()
        end
    end
end
function Player:act_softDrop()
    if not self.control then return end
    self.downing=0
    if self.cur then
        if self.curY>self.ghoY then
            if self.gameEnv.sddas==0 then
                if self.gameEnv.sdarr==0 then
                    self:act_insDown()
                else
                    self:act_down1()
                    self:act_down1()
                end
            else
                self:act_down1()
            end
            self:checkTouchSound()
        elseif self.gameEnv.deepDrop then
            self:_deepDrop()
        end
    end
end
function Player:act_hold()
    if not self.control then return end
    if self.cur then
        if self:hold() then
            self.keyPressing[8]=false
        end
    end
end
function Player:act_func1()
    if not self.control then return end
    self.gameEnv.fkey1(self)
end
function Player:act_func2()
    if not self.control then return end
    self.gameEnv.fkey2(self)
end

function Player:act_insLeft(auto)
    if not self.control then return end
    if not self.cur then
        return
    end
    local x0=self.curX
    while not self:ifoverlap(self.cur.bk,self.curX-1,self.curY) do
        self:createMoveFX('left')
        self.curX=self.curX-1
        self:freshBlock('move',true)
    end
    if self.curX~=x0 then
        self.spinLast=false
        self:checkTouchSound()
    end
    if self.gameEnv.shakeFX then
        self.swingOffset.vx=-1.5
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
    if not self.control then return end
    if not self.cur then
        return
    end
    local x0=self.curX
    while not self:ifoverlap(self.cur.bk,self.curX+1,self.curY) do
        self:createMoveFX('right')
        self.curX=self.curX+1
        self:freshBlock('move',true)
    end
    if self.curX~=x0 then
        self.spinLast=false
        self:checkTouchSound()
    end
    if self.gameEnv.shakeFX then
        self.swingOffset.vx=1.5
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
    if not self.control then return end
    if self.cur and self.curY>self.ghoY then
        local ENV=self.gameEnv
        self:createDropFX()
        if ENV.shakeFX then
            self.swingOffset.vy=.5
        end
        self.curY=self.ghoY
        self.lockDelay=ENV.lock
        self.spinLast=false
        self:freshBlock('fresh')
        self:checkTouchSound()
    end
end
function Player:act_down1()
    if not self.control then return end
    if self.cur then
        if self.curY>self.ghoY then
            self:createMoveFX('down')
            self.curY=self.curY-1
            self:freshBlock('fresh')
            self.spinLast=false
        elseif self.gameEnv.deepDrop then
            self:_deepDrop()
        end
    end
end
function Player:act_down4()
    if not self.control then return end
    if self.cur then
        if self.curY>self.ghoY then
            local ghoY0=self.ghoY
            self.ghoY=max(self.curY-4,self.ghoY)
            self:createDropFX()
            self.curY,self.ghoY=self.ghoY,ghoY0
            self:freshBlock('fresh')
            self.spinLast=false
        elseif self.gameEnv.deepDrop then
            self:_deepDrop()
        end
    end
end
function Player:act_down10()
    if not self.control then return end
    if self.cur then
        if self.curY>self.ghoY then
            local ghoY0=self.ghoY
            self.ghoY=max(self.curY-0,self.ghoY)
            self:createDropFX()
            self.curY,self.ghoY=self.ghoY,ghoY0
            self:freshBlock('fresh')
            self.spinLast=false
        elseif self.gameEnv.deepDrop then
            self:_deepDrop()
        end
    end
end
function Player:act_dropLeft()
    if not self.control then return end
    if self.cur then
        self:act_insLeft()
        self:act_hardDrop()
    end
end
function Player:act_dropRight()
    if not self.control then return end
    if self.cur then
        self:act_insRight()
        self:act_hardDrop()
    end
end
function Player:act_zangiLeft()
    if not self.control then return end
    if self.cur then
        self:act_insLeft()
        self:act_insDown()
        self:act_insRight()
        self:act_hardDrop()
    end
end
function Player:act_zangiRight()
    if not self.control then return end
    if self.cur then
        self:act_insRight()
        self:act_insDown()
        self:act_insLeft()
        self:act_hardDrop()
    end
end
--------------------------</Action>--------------------------

--------------------------<Method>--------------------------
local playerActions={
    Player.act_moveLeft,  -- 1
    Player.act_moveRight, -- 2
    Player.act_rotRight,  -- 3
    Player.act_rotLeft,   -- 4
    Player.act_rot180,    -- 5
    Player.act_hardDrop,  -- 6
    Player.act_softDrop,  -- 7
    Player.act_hold,      -- 8
    Player.act_func1,     -- 9
    Player.act_func2,     -- 10
    Player.act_insLeft,   -- 11
    Player.act_insRight,  -- 12
    Player.act_insDown,   -- 13
    Player.act_down1,     -- 14
    Player.act_down4,     -- 15
    Player.act_down10,    -- 16
    Player.act_dropLeft,  -- 17
    Player.act_dropRight, -- 18
    Player.act_zangiLeft, -- 19
    Player.act_zangiRight,-- 20
}function Player:pressKey(keyID)
    if self.id==1 then
        if GAME.recording then
            local L=GAME.rep
            ins(L,self.frameRun)
            ins(L,keyID)
        elseif self.streamProgress then
            VK.press(keyID)
        end
    end
    if self.keyAvailable[keyID] and self.alive then
        if self.waiting>self.gameEnv.hurry then
            self.waiting=self.gameEnv.hurry
            if self.waiting==0 and self.falling==0 then
                self:popNext()
            end
        end
        self.keyPressing[keyID]=true
        playerActions[keyID](self)
        self.stat.key=self.stat.key+1
    end
end
function Player:releaseKey(keyID)
    if self.id==1 then
        if GAME.recording then
            local L=GAME.rep
            ins(L,self.frameRun)
            ins(L,32+keyID)
        elseif self.streamProgress then
            VK.release(keyID)
        end
    end
    self.keyPressing[keyID]=false
end
function Player:newTask(code,...)
    local thread=coroutine.create(code)
    assert(resume(thread,self,...))
    if status(thread)~='dead' then
        ins(self.tasks,{
            thread=thread,
            code=code,
            args={...},
        })
    end
end

function Player:startStreaming(streamData)
    self.stream=streamData or self.stream
    self.streamProgress=1
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
do-- function Player:movePosition(x,y,size)
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
do-- function Player:dropPosition(x,y,size)
    local function task_dropPosition(self)
        local vy=0
        local x,y,size=self.x,self.y,self.size
        while true do
            yield()
            y=y+vy
            vy=vy+.0626
            self:setPosition(x,y,size)
            if y>2600 then
                local index=TABLE.find(PLAYERS,self)
                if index then
                    table.remove(PLAYERS,index)
                end
                return true
            end
        end
    end
    local function check_player(obj,Ptar)
        return obj.args[1]==Ptar
    end
    function Player:dropPosition()
        TASK.removeTask_iterate(check_player,self)
        TASK.new(task_dropPosition,self)
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
    if self.type=='human' then
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
function Player:setHold(count)-- Set hold count (false/true as 0/1)
    if not count then
        count=0
    elseif count==true then
        count=1
    end
    self:switchKey(8,count>0)
    self.gameEnv.holdCount=count
    self.holdTime=count
    while self.holdQueue[count+1] do rem(self.holdQueue) end
end
function Player:setNext(next)-- Set next count
    self.gameEnv.nextCount=next
end
function Player:setInvisible(time)-- Time in frames
    if time<0 then
        self.keepVisible=true
        self.showTime=1e99
    else
        self.keepVisible=false
        self.showTime=time
    end
end
function Player:setRS(RSname)
    local rs=RSlist[RSname] or RSlist.TRS
    self.RS=rs

    -- Reset all player's blocks' RSs
    for i=1,#self.nextQueue do self.nextQueue[i].RS=rs end
    for i=1,#self.holdQueue do self.holdQueue[i].RS=rs end
    if self.cur then
        self.cur.RS=rs
    end
end

function Player:_triggerEvent(eventName)
    local L=self.gameEnv[eventName]
    if L[1] then
        for i=1,#L do
            L[i](self)
        end
        return true
    end
end

function Player:getHolePos()-- Get a good garbage-line hole position
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
function Player:garbageRelease()-- Check garbage buffer and try to release them
    local n=1
    while true do
        local A=self.atkBuffer[n]
        if A and A.countdown<=0 and not A.sent then
            self:garbageRise(19+A.lv,A.amount,A.line)
            self.atkBufferSum=self.atkBufferSum-A.amount
            A.sent,A.time=true,0
            self.stat.pend=self.stat.pend+A.amount
            n=n+1
        else
            break
        end
    end
end
function Player:garbageRise(color,amount,line)-- Release n-lines garbage to field
    local _
    local t=self.showTime*2
    for _=1,amount do
        ins(self.field,1,LINE.new(0,true))
        ins(self.visTime,1,LINE.new(t))
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
        _[2]=_[2]-30*amount-- Shift 30px per line cleared
    end
    for i=1,#self.dropFX do
        _=self.dropFX[i]
        _[3],_[5]=_[3]+amount,_[5]+amount
    end
    if
        #self.field>self.gameEnv.heightLimit and (
            not self:_triggerEvent('hook_die') or
            #self.field>self.gameEnv.heightLimit
        )
    then
        self:lose()
    end
end

local invList={2,1,4,3,5,6,7}
function Player:pushLineList(L,mir)-- Push some lines to field
    local l=#L
    local S=self.gameEnv.skin
    for i=1,l do
        local r=LINE.new(0)
        if not mir then
            for j=1,10 do
                r[j]=S[L[i][j]] or 0
            end
        else
            for j=1,10 do
                r[j]=S[invList[L[i][11-j]]] or 0
            end
        end
        ins(self.field,1,r)
        ins(self.visTime,1,LINE.new(20))
    end
    self.fieldBeneath=self.fieldBeneath+30*l
    if self.cur then
        self.curY=self.curY+l
        self.ghoY=self.ghoY+l
    end
    self:freshBlock('push')
end
function Player:pushNextList(L,mir)-- Push some nexts to nextQueue
    for i=1,#L do
        self:getNext(mir and invList[L[i]] or L[i])
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
    [x]>0-- to catch bug (nil[*])
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
        if self.field[y+i-1] then
            for j=1,C do
                if bk[i][j] and self.field[y+i-1][x+j-1]>0 then
                    return true
                end
            end
        end
    end
end
function Player:attack(R,send,time,line,fromStream)
    if GAME.net then
        if self.type=='human' then-- Local player attack others
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
        if fromStream and R.type=='human' then-- Local player receiving lines
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
        })-- Sorted insert(by time)
        self.atkBufferSum=self.atkBufferSum+send
        self.stat.recv=self.stat.recv+send
        if self.sound then
            SFX.play(send<4 and 'warn_1' or 'warn_2',min(send+1,5)*.1)
        end
        if send>=2 then
            self:shakeField(send/2)
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
    -- if self.type~='human' then R=PLAYERS[1] end-- 1vALL mode?
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
function Player:freshBlock(mode,ifTele)-- string mode: push/move/fresh/newBlock
    local ENV=self.gameEnv
    -- Fresh ghost
    if (mode=='move' or mode=='newBlock' or mode=='push') and self.cur then
        local CB=self.cur.bk
        self.ghoY=min(#self.field+1,self.curY)
        if self._20G or ENV.sdarr==0 and self.keyPressing[7] and self.downing>=ENV.sddas then
            local _=self.ghoY

            -- Move ghost to bottom
            while not self:ifoverlap(CB,self.curX,self.ghoY-1) do
                self.ghoY=self.ghoY-1
            end

            -- Cancel spinLast
            if _~=self.ghoY then
                self.spinLast=false
            end

            -- Create FX if dropped
            if self.curY>self.ghoY then
                self:createDropFX()
                if ENV.shakeFX then
                    self.swingOffset.vy=.5
                end
                self.curY=self.ghoY
            end
        else
            while not self:ifoverlap(CB,self.curX,self.ghoY-1) do
                self.ghoY=self.ghoY-1
            end
        end
    end

    -- Fresh delays
    if mode=='move' or mode=='newBlock' or mode=='fresh' then
        local d0,l0=ENV.drop,ENV.lock
        local C=self.cur
        local sc=C.RS.centerPos[C.id][C.dir]
        if ENV.easyFresh then
            if self.lockDelay<l0 and self.freshTime>0 then
                if mode~='newBlock' then
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

    -- Play sound if touch ground
    if mode=='move' and not ifTele then
        self:checkTouchSound()
    end
end
function Player:lock()
    local CB=self.cur.bk
    for i=1,#CB do
        local y=self.curY+i-1
        if not self.field[y] then
            self.field[y]=LINE.new(0)
            self.visTime[y]=LINE.new(0)
        end
        for j=1,#CB[1] do
            if CB[i][j] then
                self.field[y][self.curX+j-1]=self.cur.color
                self.visTime[y][self.curX+j-1]=self.showTime
            end
        end
    end
end

function Player:_checkClear(field,start,height,CB,CX)
    local cc,gbcc=0,0
    for i=1,height do
        local h=start+i-2

        -- Bomb trigger (optional, must with CB)
        if CB and h>0 and field[h] and self.clearedRow[cc]~=h then
            for x=1,#CB[1] do
                if CB[i][x] and field[h][CX+x-1]==19 then
                    cc=cc+1
                    self.clearingRow[cc]=h-cc+1
                    self.clearedRow[cc]=h
                    break
                end
            end
        end

        h=h+1
        -- Row filled
        local full=true
        for x=1,10 do
            if field[h][x]<=0 then
                full=false
                break-- goto CONTINUE_notFull
            end
        end
        if full then
            cc=cc+1
            if field[h].garbage then gbcc=gbcc+1 end
            ins(self.clearingRow,h-cc+1)
            ins(self.clearedRow,h)
        end
        -- ::CONTINUE_notFull::
    end
    return cc,gbcc
end
function Player:_roofCheck()
    local CB=self.cur.bk
    for x=1,#CB[1] do
        local y=#CB

        -- Find the highest y of blocks' x-th column
        while not CB[y][x] do y=y-1 end

        local testX=self.curX+x-1-- Optimize

        -- Test the whole column of field to find roof
        for testY=self.curY+y,#self.field do
            if self:solid(testX,testY) then
                return true
            end
        end
    end
    return false
end
function Player:_removeClearedLines()
    for i=#self.clearedRow,1,-1 do
        local h=self.clearedRow[i]
        if self.field[h].garbage then
            self.garbageBeneath=self.garbageBeneath-1
        end
        LINE.discard(rem(self.field,h))
        LINE.discard(rem(self.visTime,h))
    end
end
function Player:_updateFalling(val)
    self.falling=val
    if self.falling==0 then
        local L=#self.clearingRow
        if self.sound and self.gameEnv.fall>0 and #self.field+L>self.clearingRow[L] then
            SFX.play('fall')
        end
        TABLE.cut(self.clearingRow)
    end
end
function Player:removeTopClearingFX()
    for i=#self.clearingRow,1,-1 do
        if self.clearingRow[i]>#self.field then
            rem(self.clearingRow)
        else
            break
        end
    end
    if self.clearingRow[1] then
        self:_updateFalling(self.gameEnv.fall)
        return false
    else
        return true
    end
end
function Player:_checkMission(piece,mission)
    if mission<5 then
        return piece.row==mission and not piece.spin
    elseif mission<9 then
        return piece.row==mission-4 and piece.spin
    elseif mission==9 then
        return piece.pc
    elseif mission<90 then
        return piece.row==mission%10 and piece.name==int(mission/10) and piece.spin
    end
    return false
end
function Player:_checkSuffocate()
    if
        self:ifoverlap(self.cur.bk,self.curX,self.curY) and (
            not self:_triggerEvent('hook_die') or
            self:ifoverlap(self.cur.bk,self.curX,self.curY)
        )
    then
        self:lock()
        self:lose()
    end
end

local spawnSFX_name={'spawn_1','spawn_2','spawn_3','spawn_4','spawn_5','spawn_6','spawn_7'}
function Player:resetBlock()-- Reset Block's position and execute I*S
    local C=self.cur
    local sc=C.RS.centerPos[C.id][C.dir]

    self.curX=int(6-#C.bk[1]*.5)
    local y=int(self.gameEnv.fieldH+1-modf(sc[1]))+ceil(self.fieldBeneath/30)
    self.curY=y
    self.minY=y+sc[1]

    local pressing=self.keyPressing
    -- IMS
    if self.gameEnv.ims and (pressing[1] and self.movDir==-1 or pressing[2] and self.movDir==1) and self.moving>=self.gameEnv.das then
        local x=self.curX+self.movDir
        if not self:ifoverlap(C.bk,x,y) then
            self.curX=x
        end
    end

    -- IRS
    if self.gameEnv.irs then
        if pressing[5] then
            self:spin(2,true)
        elseif pressing[3] then
            if pressing[4] then
                self:spin(2,true)
            else
                self:spin(1,true)
            end
        elseif pressing[4] then
            self:spin(3,true)
        end
        pressing[3],pressing[4],pressing[5]=false,false,false
    end

    -- DAS cut
    if self.gameEnv.dascut>0 then
        self.moving=self.moving-(self.moving>0 and 1 or -1)*self.gameEnv.dascut
    end

    -- Spawn SFX
    if self.sound and C.id<8 then
        SFX.fplay(spawnSFX_name[C.id],SETTING.sfx_spawn)
    end
end

function Player:getNextSpawn()
    local cur = self.nextQueue[1]
    return int(self.gameEnv.fieldH+1-modf(cur.RS.centerPos[cur.id][cur.dir][1]))+ceil(self.fieldBeneath/30)
end

function Player:spin(d,ifpre)
    local C=self.cur
    local sc=C.RS.centerPos[C.id][C.dir]
    local kickData=C.RS.kickTable[C.id]
    if type(kickData)=='table' then
        local idir=(C.dir+d)%4
        kickData=kickData[C.dir*10+idir]
        if not kickData then
            self:freshBlock('move')
            SFX.play(ifpre and 'prerotate' or 'rotate',nil,self:getCenterX()*.15)
            return
        end
        local icb=BLOCKS[C.id][idir]
        local isc=C.RS.centerPos[C.id][idir]
        local baseX,baseY=self.curX+sc[2]-isc[2],self.curY+sc[1]-isc[1]
        for test=1,#kickData do
            local ix,iy=baseX+kickData[test][1],baseY+kickData[test][2]
            if (self.freshTime>0 or kickData[test][2]<=0) and not self:ifoverlap(icb,ix,iy) then
                -- Create moveFX at the original position
                self:createMoveFX()

                -- Change block position
                sc,C.bk,C.dir=isc,icb,idir
                self.curX,self.curY=ix,iy
                self.spinLast=test==2 and 0 or 1

                -- Fresh ghost and freshTime
                local t=self.freshTime
                if not ifpre then
                    self:freshBlock('move')
                end
                if kickData[test][2]>0 and self.freshTime==t and self.curY~=self.imgY then
                    self.freshTime=self.freshTime-1
                end

                -- Sound & Field swinging
                local sfx
                if ifpre then
                    sfx='prerotate'
                elseif self:ifoverlap(icb,ix,iy+1) and self:ifoverlap(icb,ix-1,iy) and self:ifoverlap(icb,ix+1,iy) then
                    sfx='rotatekick'
                    self:_rotateField(d)
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
        SFX.play(ifpre and 'prerotate' or 'rotate',nil,self:getCenterX()*.15)
    end
end
local phyHoldKickX={
    [true]={0,-1,1},-- X==?.0 tests
    [false]={-.5,.5},-- X==?.5 tests
}
function Player:hold_norm(ifpre)
    local ENV=self.gameEnv
    if #self.holdQueue<ENV.holdCount and self.nextQueue[1] then-- Skip
        local C=self.cur
        ins(self.holdQueue,self:getBlock(C.id,C.name,C.color))

        local t=self.holdTime
        self:popNext(true)
        self.holdTime=t
    else-- Hold
        local C,H=self.cur,self.holdQueue[1]
        self.ctrlCount=0

        if ENV.phyHold and C and H and not ifpre then-- Physical hold
            local x,y=self.curX,self.curY
            x=x+(#C.bk[1]-#H.bk[1])*.5
            y=y+(#C.bk-#H.bk)*.5

            local iki=phyHoldKickX[x==int(x)]
            local success
            for Y=int(y),ceil(y+.5) do
                for i=1,#iki do
                    local X=x+iki[i]
                    if not self:ifoverlap(H.bk,X,Y) then
                        x,y=X,Y
                        success=true
                        break
                    end
                end
                if success then break end
            end
            if not success then -- All test failed, interrupt with sound
                SFX.play('drop_cancel')
                return
            end

            self.spinLast=false

            local hb=self:getBlock(C.id)
            hb.name=C.name
            hb.color=C.color
            ins(self.holdQueue,hb)
            self.cur=rem(self.holdQueue,1)

            self.curX,self.curY=x,y
        else-- Normal hold
            self.spinLast=false

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
        self:_checkSuffocate()
    end

    self.freshTime=int(min(self.freshTime+ENV.freshLimit*.25,ENV.freshLimit*((self.holdTime+1)/ENV.holdCount),ENV.freshLimit))
    if not ENV.infHold then
        self.holdTime=self.holdTime-1
    end

    if self.sound then
        SFX.play(ifpre and 'prehold' or 'hold')
    end

    self.stat.hold=self.stat.hold+1
end
function Player:hold_swap(ifpre)
    local ENV=self.gameEnv
    local hid=ENV.holdCount-self.holdTime+1
    if self.nextQueue[hid] then
        local C,H=self.cur,self.nextQueue[hid]
        self.ctrlCount=0

        if ENV.phyHold and C and not ifpre then-- Physical hold
            local x,y=self.curX,self.curY
            x=x+(#C.bk[1]-#H.bk[1])*.5
            y=y+(#C.bk-#H.bk)*.5

            local iki=phyHoldKickX[x==int(x)]
            local success
                for Y=int(y),ceil(y+.5) do
                    for i=1,#iki do
                        local X=x+iki[i]
                        if not self:ifoverlap(H.bk,X,Y) then
                            x,y=X,Y
                            success=true
                            break
                        end
                    end
                    if success then break end
                end
            if not success then -- All test failed, interrupt with sound
                SFX.play('finesseError')
                return
            end

            self.spinLast=false

            local hb=self:getBlock(C.id)
            hb.name=C.name
            hb.color=C.color
            self.cur,self.nextQueue[hid]=self.nextQueue[hid],hb

            self.curX,self.curY=x,y
        else-- Normal hold
            self.spinLast=false

            local hb=self:getBlock(C.id)
            hb.color=C.color
            hb.name=C.name
            self.cur,self.nextQueue[hid]=self.nextQueue[hid],hb

            self:resetBlock()
        end
        self:freshBlock('move')
        self.dropDelay=ENV.drop
        self.lockDelay=ENV.lock
        self:_checkSuffocate()
    end

    self.freshTime=int(min(self.freshTime+ENV.freshLimit*.25,ENV.freshLimit*((self.holdTime+1)/ENV.holdCount),ENV.freshLimit))
    if not ENV.infHold then
        self.holdTime=self.holdTime-1
    end

    if self.sound then
        SFX.play(ifpre and 'prehold' or 'hold')
    end

    self.stat.hold=self.stat.hold+1
end
function Player:hold(ifpre,force)
    if self.holdTime>0 and (self.cur or ifpre or force) then
        if self.gameEnv.holdMode=='hold' then
            self:hold_norm(ifpre)
        elseif self.gameEnv.holdMode=='swap' then
            self:hold_swap(ifpre)
        end
        return true
    end
end

function Player:getBlock(id,name,color)-- Get a block object
    local ENV=self.gameEnv
    local dir=ENV.face[id]
    return {
        id=id,
        dir=dir,
        bk=BLOCKS[id][dir],
        RS=self.RS,
        name=name or id,
        color=ENV.bone and 17 or color or ENV.skin[id],
    }
end
function Player:getNext(id)-- Push a block to nextQueue
    ins(self.nextQueue,self:getBlock(id))
    if self.bot then
        self.bot:pushNewNext(id)
    end
end
function Player:popNext(ifhold)-- Pop nextQueue to hand
    local ENV=self.gameEnv
    if not ifhold then
        self.holdTime=min(self.holdTime+1,ENV.holdCount)
    end
    self.spinLast=false
    self.ctrlCount=0

    if self.nextQueue[1] then
        self.cur=rem(self.nextQueue,1)
        self:newNext()
        self.pieceCount=self.pieceCount+1

        local pressing=self.keyPressing

        -- IHS
        if not ifhold and pressing[8] and ENV.ihs and self.holdTime>0 then
            self:hold(true)
            pressing[8]=false
        else
            self:resetBlock()
        end

        self.dropDelay=ENV.drop
        self.lockDelay=ENV.lock
        self.freshTime=ENV.freshLimit

        if self.cur then
            self:_checkSuffocate()
            self:freshBlock('newBlock')
        end

        -- IHdS
        if pressing[6] and not ifhold then
            self:act_hardDrop()
            pressing[6]=false
        end
    elseif self.holdQueue[1] then-- Force using hold
        self:hold(true,true)
    else-- Next queue is empty, force lose
        self:lose(true)
    end
end

function Player:cancel(N)-- Cancel Garbage
    local off=0-- Lines offseted
    local bf=self.atkBuffer
    for i=1,#bf do
        if self.atkBufferSum==0 or N==0 then
            break
        end
        local A=bf[i]
        if not A.sent then
            local O=min(A.amount,N)-- Cur Offset
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

-- Player.drop(self)-- Place piece
-- Player:clearFilledLines(start,height)
do
    local clearSCR=setmetatable({-- B2Bmul:1.3/1.8
        80,200,400,1000,-- 1~4
        1500,2000,2300,2600,3000,3400,-- 5~10
        3800,4200,4600,5000,5500,6000,-- 11~16
        6500,7000,7500,8000,-- 17~20
        10000,11500,13000,14500,16000-- 21~25
    },{__index=function(self,k) self[k]=20000 return 20000 end})
    local spinSCR={
        {200,750,1300,2000},-- Z
        {200,750,1300,2000},-- S
        {220,700,1300,2000},-- L
        {220,700,1300,2000},-- J
        {250,800,1400,2000},-- T
        {260,900,1600,4500,7000},-- O
        {300,1200,1700,4000,6000},-- I
        {220,800,2000,3000,8000,26000},-- Else
    }-- B2B*=1.2; B3B*=2.0; Mini*=.6
    local b2bPoint={50,100,180,800,1000,9999}

    local b2bATK={3,5,8,12,18,26}
    local reAtk={0,0,1,1,1,2,2,3,3}
    local reDef={0,1,1,2,3,3,4,4,5}

    local spinVoice={'zspin','sspin','jspin','lspin','tspin','ospin','ispin','zspin','sspin','pspin','qspin','fspin','espin','tspin','uspin','vspin','wspin','xspin','jspin','lspin','rspin','yspin','nspin','hspin','ispin','ispin','cspin','ispin','ospin'}
    local clearVoice={'single','double','triple','techrash','pentacrash','hexacrash','heptacrash','octacrash','nonacrash','decacrash','undecacrash','dodecacrash','tridecacrash','tetradecacrash','pentadecacrash','hexadecacrash','heptadecacrash','octadecacrash','nonadecacrash','ultracrash','impossicrash'}
    local spinSFX={[0]='spin_0','spin_1','spin_2'}
    local renSFX={} for i=1,11 do renSFX[i]='ren_'..i end
    local finesseList={
        {
            {1,2,1,0,1,2,2,1},
            {2,2,2,1,1,2,3,2,2},
            1,2
        },-- Z
        1,-- S
        {
            {1,2,1,0,1,2,2,1},
            {2,2,3,2,1,2,3,3,2},
            {3,4,3,2,3,4,4,3},
            {2,3,2,1,2,3,3,2,2},
        },-- J
        3,-- L
        3,-- T
        {
            {1,2,2,1,0,1,2,2,1},
            1,1,1
        },-- O
        {
            {1,2,1,0,1,2,1},
            {2,2,2,2,1,1,2,2,2,2},
            1,2
        },-- I
        {
            {1,2,1,0,1,2,2,1},
            {2,3,2,1,2,3,3,2},
            1,2
        },-- Z5
        8,-- S5
        3,-- self
        3,-- Q
        {
            {1,2,1,0,1,2,2,1},
            {2,3,2,1,2,3,3,2},
            {3,4,3,2,3,4,4,3},
            2
        },-- F
        12,-- E
        12,-- T5
        3,-- U
        {
            {1,2,1,0,1,2,2,1},
            {2,3,3,2,1,2,3,2},
            {3,4,4,3,2,3,4,3},
            {2,3,2,1,2,3,3,2},
        },-- V
        12,-- W
        {
            {1,2,1,0,1,2,2,1},
            1,1,1
        },-- X
        {
            {1,2,1,0,1,2,1},
            {2,2,3,2,1,2,3,2,2},
            {3,4,3,2,3,4,3},
            2,
        },-- J5
        19,-- L5
        19,-- R
        19,-- Y
        19,-- N
        19,-- H
        {
            {1,1,0,1,2,1},
            {2,3,2,2,1,2,3,2,3,2},
            1,2
        },-- I5
        {
            {1,2,1,0,1,2,2,1},
            {2,2,3,2,1,2,3,3,2,2},
            1,2
        },-- I3
        {
            {1,2,2,1,0,1,2,2,1},
            {2,3,3,2,1,2,3,3,2},
            {3,4,4,3,2,3,4,4,3},
            2
        },-- C
        {
            {1,2,2,1,0,1,2,2,1},
            {2,2,3,2,1,1,2,3,2,2},
            1,2
        },-- I2
        {
            {1,2,2,1,0,1,2,3,2,1},
            1,1,1
        },-- O1
    }
    for k,v in next,finesseList do
        if type(v)=='table' then
            for d,l in next,v do
                if type(l)=='number' then
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
        self.dropTime[11]=ins(self.dropTime,1,self.frameRun)-- Update speed dial
        local ENV=self.gameEnv
        local Stat=self.stat
        local piece=self.lastPiece

        local finish
        local cmb=self.combo
        local C,CB,CX,CY=self.cur,self.cur.bk,self.curX,self.curY
        local sc=C.RS.centerPos[C.id][C.dir]
        local clear-- If clear with no line fall
        local cc,gbcc=0,0-- Row/garbage-row cleared,full-part
        local atk,exblock=0,0-- Attack & extra defense
        local send,off=0,0-- Sending lines remain & offset
        local cscore,sendTime=10,0-- Score & send Time
        local dospin,mini=0

        piece.id,piece.name=C.id,C.name
        piece.curX,piece.curY,piece.dir=self.curX,self.curY,C.dir
        piece.centX,piece.centY=self.curX+sc[2],self.curY+sc[1]
        piece.frame,piece.autoLock=self.frameRun,autoLock

        -- Tri-corner spin check
        if self.spinLast then
            if C.id<6 then
                local x,y=CX+sc[2],CY+sc[1]
                local c=0
                if self:solid(x-1,y+1) then c=c+1 end
                if self:solid(x+1,y+1) then c=c+1 end
                if c~=0 then
                    if self:solid(x-1,y-1) then c=c+1 end
                    if self:solid(x+1,y-1) then c=c+1 end
                    if c>2 then
                        dospin=dospin+2
                    end
                end
            end
        end
        -- Immovable spin check
        if self:ifoverlap(CB,CX,CY+1) and self:ifoverlap(CB,CX-1,CY) and self:ifoverlap(CB,CX+1,CY) then
            dospin=dospin+2
        end

        self:lock()

        -- Clear list of cleared-rows
        if self.clearedRow[1] then
            TABLE.cut(self.clearedRow)
        end

        -- Check line clear
        if self.gameEnv.fillClear then
            local _cc,_gbcc=self:_checkClear(self.field,CY,#CB,CB,CX)
            cc,gbcc=cc+_cc,gbcc+_gbcc
        end

        -- Create clearing FX
        for i=1,cc do
            local y=self.clearedRow[i]
            self:createClearingFX(y)
            self:createSplashFX(y)
        end

        -- Create locking FX
        if cc==0 then
            self:createLockFX()
        else
            self:clearLockFX()
        end

        -- Final spin check
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

        -- Finesse: roof check
        local finesse=CY>ENV.fieldH-2 or self:_roofCheck()

        -- Remove rows need to be cleared
        self:_removeClearedLines()

        -- Cancel top clearing FX & get clear flag
        clear=self:removeTopClearingFX()

        -- Finesse check (control)
        local finePts
        if not finesse then
            if dospin then-- Allow 2 more step for roof-less spin
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

        local yomi = ""

        piece.spin,piece.mini=dospin,false
        piece.pc,piece.hpc=false,false
        piece.special=false
        if cc>0 then-- If lines cleared,about 200 lines of codes below
            cmb=cmb+1
            if dospin then
                cscore=(spinSCR[C.name] or spinSCR[8])[cc]
                if self.b2b>800 then
                    self:showText(text.b3b..text.block[C.name]..text.spin..text.clear[cc],0,-30,35,'stretch')
                    yomi = yomi..text.b3b..text.block[C.name]..text.spin..text.clear[cc]
                    atk=b2bATK[cc]+cc*.5
                    exblock=exblock+1
                    cscore=cscore*2
                    Stat.b3b=Stat.b3b+1
                    if self.sound then
                        VOC.play('b3b',CHN)
                    end
                elseif self.b2b>=50 then
                    self:showText(text.b2b..text.block[C.name]..text.spin..text.clear[cc],0,-30,35,'spin')
                    yomi = yomi..text.b2b..text.block[C.name]..text.spin..text.clear[cc]
                    atk=b2bATK[cc]
                    cscore=cscore*1.2
                    Stat.b2b=Stat.b2b+1
                    if self.sound then
                        VOC.play('b2b',CHN)
                    end
                else
                    self:showText(text.block[C.name]..text.spin..text.clear[cc],0,-30,45,'spin')
                    yomi = yomi..text.block[C.name]..text.spin..text.clear[cc]
                    atk=2*cc
                end
                sendTime=20+atk*20
                if mini then
                    self:showText(text.mini,0,-80,35,'appear')
                    yomi = text.mini..' '..yomi
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
                    SFX.play(spinSFX[cc] or 'spin_3')
                    VOC.play(spinVoice[C.name],CHN)
                end
            elseif cc>=4 then
                cscore=clearSCR[cc]
                if self.b2b>800 then
                    self:showText(text.b3b..text.clear[cc],0,-30,50,'fly')
                    yomi = text.b3b..text.clear[cc]..yomi
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
                    yomi = text.b2b..text.clear[cc]..yomi
                    sendTime=80
                    atk=3*cc-7
                    cscore=cscore*1.3
                    Stat.b2b=Stat.b2b+1
                    if self.sound then
                        VOC.play('b2b',CHN)
                    end
                else
                    self:showText(text.clear[cc],0,-30,70,'stretch')
                    yomi = text.clear[cc]..yomi
                    sendTime=60
                    atk=2*cc-4
                end
                self.b2b=self.b2b+cc*50-50
                piece.special=true
            else
                self:showText(text.clear[cc],0,-30,35,'appear',(8-cc)*.3)
                yomi = text.clear[cc]..yomi
                atk=cc-.5
                sendTime=20+int(atk*20)
                cscore=cscore+clearSCR[cc]
                piece.special=false
            end

            if self.sound and (cc~=1 or dospin) then
                VOC.play(clearVoice[cc],CHN)
            end

            -- Combo bonus
            sendTime=sendTime+25*cmb
            if cmb>1 then
                atk=atk*(1+(cc==1 and .15 or .25)*min(cmb-1,12))
                if cmb>=3 then
                    atk=atk+1
                end
                self:showText(text.cmb[min(cmb,21)],0,25,15+min(cmb,15)*5,cmb<10 and 'appear' or 'flicker')
                yomi = yomi..' '..text.cmb[min(cmb,21)]
                cscore=cscore+min(50*cmb,500)*(2*cc-1)
            end

            -- PC/HPC
            if clear and cc>=#C.bk then
                if CY==1 then
                    piece.pc=true
                    piece.special=true
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
                        SFX.play('pc')
                        VOC.play('perfect_clear',CHN)
                    end
                elseif cc>1 or self.field[#self.field].garbage then
                    piece.hpc=true
                    piece.special=true
                    self:showText(text.HPC,0,-80,50,'fly')
                    atk=atk+4
                    exblock=exblock+2
                    sendTime=sendTime+60
                    self.b2b=self.b2b+100
                    cscore=cscore+626
                    Stat.hpc=Stat.hpc+1
                    if self.sound then
                        SFX.play('pc')
                        VOC.play('half_clear',CHN)
                    end
                end
            end

            if not piece.special then
                self.b2b=max(self.b2b-250,0)
            end

            if self.b2b>1000 then
                self.b2b=1000
            elseif self.b2b==0 and ENV.b2bKill then
                finish='lose'
            end

            -- Bonus atk/def when focused
            if ENV.layout=='royale' then
                local i=min(#self.atker,9)
                if i>1 then
                    atk=atk+reAtk[i]
                    exblock=exblock+reDef[i]
                end
            end

            -- Send Lines
            atk=int(atk*(1+self.strength*.25))-- Badge Buff
            send=atk
            if exblock>0 then
                exblock=int(exblock*(1+self.strength*.25))-- Badge Buff
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
                    if ENV.layout=='royale' then
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

            -- SFX & Vibrate
            if self.sound then
                playClearSFX(cc)
                SFX.play(renSFX[min(cmb,11)],.75)
                if cmb>14 then
                    SFX.play('ren_mega',(cmb-10)*.1)
                end
                if SETTING.vib>0 then VIB(SETTING.vib+cc+1) end
            end
        else-- No lines clear
            cmb=0

            -- Spin bonus
            if dospin then
                self:showText(text.block[C.name]..text.spinNC,0,-30,45,'appear')
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

        -- Spike
        if atk>0 then
            self.spike=self.spikeTime==0 and atk or self.spike+atk
            self.spikeTime=min(self.spikeTime+atk*20,100)
            self.spikeText:set(self.spike)
        end

        -- DropSpeed bonus
        if self._20G then
            cscore=cscore*2
        elseif ENV.drop<1 then
            cscore=cscore*1.5
        elseif ENV.drop<3 then
            cscore=cscore*1.2
        end

        -- Speed bonus
        if self.dropSpeed>60 then
            cscore=cscore*(.9+self.dropSpeed/600)
        end

        cscore=int(cscore)
        self:popScore(cscore)

        piece.row,piece.dig=cc,gbcc
        piece.score=cscore
        piece.atk,piece.exblock=atk,exblock
        piece.off,piece.send=off,send

        -- Check clearing task
        if cc>0 and self.curMission then
            if self:_checkMission(piece,ENV.mission[self.curMission]) then
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

        -- Fresh ARE
        self.waiting=ENV.wait

        -- Prevent sudden death if hang>0
        if ENV.hang>ENV.wait and self.nextQueue[1] then
            local B=self.nextQueue[1]
            if self:ifoverlap(B.bk,int(6-#B.bk[1]*.5),int(ENV.fieldH+1-modf(B.RS.centerPos[B.id][B.dir][1]))+ceil(self.fieldBeneath/30)) then
                self.waiting=self.waiting+ENV.hang
            end
        end

        -- Check bot things
        if self.bot then
            self.bot:checkDest(self.b2b,atk,exblock,yomi)
            self.bot:updateB2B(self.b2b)
            self.bot:updateCombo(self.combo)
        end

        -- Check height limit
        if cc==0 and (#self.field>ENV.heightLimit or ENV.lockout and CY>ENV.fieldH) then
            finish='lose'
        end

        -- Update stat
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
            _=Stat.spin[n]  _[cc+1]=_[cc+1]+1-- Spin[1~25][0~4]
            _=Stat.spins    _[cc+1]=_[cc+1]+1-- Spin[0~4]
        elseif cc>0 then
            _=Stat.clear[n] _[cc]=_[cc]+1-- Clear[1~25][1~5]
            _=Stat.clears   _[cc]=_[cc]+1-- Clear[1~5]
        end

        if finish then
            if finish=='lose' then
                self:lose()
            else
                self:_triggerEvent('hook_drop')
                if finish then
                    self:win(finish)
                end
            end
        else
            self:_triggerEvent('hook_drop')
        end

        -- Remove controling block
        self.cur=nil

        if self.waiting==0 and self.falling==0 then
            self:popNext()
        end
    end

    function Player:clearFilledLines(start,height)
        local _cc,_gbcc=self:_checkClear(self.field,start,height)
        if _cc>0 then
            playClearSFX(_cc)
            if self.sound then
                VOC.play(clearVoice[min(_cc,21)],VOC.getFreeChannel())
            end
            self:showText(text.clear[min(_cc,21)],0,0,75,'beat',.4)
            if _cc>6 then self:showText(text.cleared:repD(_cc),0,55,30,'zoomout',.4) end
            self:_removeClearedLines()
            self:_updateFalling(self.gameEnv.fall)
            if _cc>=4 then
                self.b2b=min(self.b2b+_cc*50-50,1000)
            else
                self.b2b=max(self.b2b-250,0)
            end
            self.stat.row=self.stat.row+_cc
            self.stat.dig=self.stat.dig+_gbcc
            self.stat.score=self.stat.score+clearSCR[_cc]
        end
        return _cc,_gbcc
    end
end
function Player:loadAI(data)-- Load AI with params
    self.bot=BOT.new(self,data)
    self.bot.data=data
end
--------------------------</Method>--------------------------

--------------------------<Tick>--------------------------
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

            -- Generate badge object
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
            -- Make field visible
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
            -- Make field visible
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
                    LINE.discard(self.field[_])
                    LINE.discard(self.visTime[_])
                    self.field[_],self.visTime[_]=nil
                end
                return
            end
        end
        if not self.gameEnv.layout=='royale' and #PLAYERS>1 then
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
        if SCN.cur~='game' or PLAYERS[1].frameRun<180 then
            return
        elseif time==120 then
            pauseGame()
            return
        end
    end
end
--------------------------</Tick>--------------------------

--------------------------<Event>--------------------------
local function _updateMisc(P,dt)
    -- Finesse combo animation
    if P.finesseComboTime>0 then
        P.finesseComboTime=P.finesseComboTime-1
    end

    -- Update spike counter
    if P.spikeTime>0 then
        P.spikeTime=P.spikeTime-1
    end

    -- Update atkBuffer alert
    local t=P.atkBufferSum1
    if t<P.atkBufferSum then
        P.atkBufferSum1=t+.25
    elseif t>P.atkBufferSum then
        P.atkBufferSum1=t-.5
    end

    -- Update attack buffer
    local bf=P.atkBuffer
    for i=#bf,1,-1 do
        local A=bf[i]
        A.time=A.time+1
        if not A.sent then
            if A.countdown>0 then
                A.countdown=max(A.countdown-P.gameEnv.garbageSpeed,0)
            end
        else
            if A.time>20 then
                rem(bf,i)
            end
        end
    end

    -- Push up garbages
    local y=P.fieldBeneath
    if y>0 then
        P.fieldBeneath=max(y-P.gameEnv.pushSpeed,0)
    end

    -- Move camera
    if P.gameEnv.highCam then
        if not P.alive then
            y=0
        else
            y=30*max(min(#P.field-18.5-P.fieldBeneath/30,P.ghoY-17),0)
        end
        local f=P.fieldUp
        if f~=y then
            P.fieldUp=f>y and max(approach(f,y,dt*6)-2,y) or min(approach(f,y,dt*3)+1,y)
        end
    end

    -- Update Score
    if P.stat.score>P.score1 then
        if P.stat.score-P.score1<10 then
            P.score1=P.score1+1
        else
            P.score1=approach(P.score1,P.stat.score,dt*62)
        end
    end

    -- Field swinging
    if P.gameEnv.shakeFX then
        local O=P.swingOffset
        O.vx=O.vx*.6-abs(O.x)^1.3*(O.x>0 and .1 or -.1)
        O.x=O.x+O.vx

        O.vy=O.vy*.7-abs(O.y)^1.2*(O.y>0 and .1 or -.1)
        O.y=O.y+O.vy

        O.va=O.va*.7-abs(O.a)^1.4*(O.a>0 and .08 or -.08)
        O.a=O.a+O.va
        if abs(O.a)<.0006 then
            O.a,O.va=0,0
        end
    end

    -- Field Shaking
    if P.shakeTimer>0 then
        P.shakeTimer=P.shakeTimer-1
    end

    -- Update texts
    if P.bonus then
        TEXT.update(1/60,P.bonus)
    end

    -- Update tasks
    local L=P.tasks
    for i=#L,1,-1 do
        local tr=L[i].thread
        assert(resume(tr))
        if status(tr)=='dead' then
            rem(L,i)
        end
    end
end
local function _updateFX(P,dt)
    -- Update lock FX
    for i=#P.lockFX,1,-1 do
        local S=P.lockFX[i]
        S[3]=S[3]+S[4]*dt
        if S[3]>1 then
            rem(P.lockFX,i)
        end
    end

    -- Update drop FX
    for i=#P.dropFX,1,-1 do
        local S=P.dropFX[i]
        S[5]=S[5]+S[6]*dt
        if S[5]>1 then
            rem(P.dropFX,i)
        end
    end

    -- Update move FX
    for i=#P.moveFX,1,-1 do
        local S=P.moveFX[i]
        S[4]=S[4]+S[5]*dt
        if S[4]>1 then
            rem(P.moveFX,i)
        end
    end

    -- Update clear FX
    for i=#P.clearFX,1,-1 do
        local S=P.clearFX[i]
        S[2]=S[2]+S[3]*dt
        if S[2]>1 then
            rem(P.clearFX,i)
        end
    end
end
local function update_alive(P,dt)
    local ENV=P.gameEnv

    P.frameRun=P.frameRun+1
    if P.frameRun<=180 then
        if P.frameRun==60 then
            if P.id==1 then playReadySFX(2) end
        elseif P.frameRun==120 then
            if P.id==1 then playReadySFX(1) end
        elseif P.frameRun==180 then
            if P.id==1 then playReadySFX(0) end
            P.control=true
            P.timing=true
            P:popNext()
            if P.bot then
                P.bot:updateField()
            end
        end
        if P.movDir~=0 then
            if P.moving<P.gameEnv.das then
                P.moving=P.moving+1
            end
        else
            P.moving=0
        end
        return true
    end

    if P.timing then P.stat.frame=P.stat.frame+1 end

    -- Calculate drop speed
    do
        local v=0
        for i=2,10 do v=v+i*(i-1)*72/(P.frameRun-P.dropTime[i]) end
        P.dropSpeed=approach(P.dropSpeed,v,dt)
    end

    if P.gameEnv.layout=='royale' then
        local v=P.swappingAtkMode
        local tar=#P.field>15 and 4 or 8
        if v~=tar then
            P.swappingAtkMode=v+(v<tar and 1 or -1)
        end
    end

    -- Fresh visible time
    if not P.keepVisible then
        local V=P.visTime
        for j=1,#P.field do
            local L=V[j]
            for i=1,10 do
                if L[i]>0 then
                    L[i]=L[i]-1
                end
            end
        end
    end

    -- Moving pressed
    if P.movDir~=0 then
        local das,arr=ENV.das,ENV.arr
        local mov=P.moving
        if P.cur then
            if P.movDir==1 then
                if P.keyPressing[2] then
                    if arr>0 then
                        if mov==das+arr or mov==das then
                            if not P.cur or P:ifoverlap(P.cur.bk,P.curX+1,P.curY) then
                                mov=das+arr-1
                            else
                                P:act_moveRight(true)
                                mov=das
                            end
                        end
                        mov=mov+1
                    else
                        if mov==das then
                            P:act_insRight(true)
                        else
                            mov=mov+1
                        end
                    end
                    if mov>=das and ENV.shakeFX and P.cur and P:ifoverlap(P.cur.bk,P.curX+1,P.curY) then
                        P.swingOffset.vx=.5
                    end
                else
                    P.movDir=0
                end
            else
                if P.keyPressing[1] then
                    if arr>0 then
                        if mov==das+arr or mov==das then
                            if not P.cur or P:ifoverlap(P.cur.bk,P.curX-1,P.curY) then
                                mov=das+arr-1
                            else
                                P:act_moveLeft(true)
                                mov=das
                            end
                        end
                        mov=mov+1
                    else
                        if mov==das then
                            P:act_insLeft(true)
                        else
                            mov=mov+1
                        end
                    end
                    if mov>=das and ENV.shakeFX and P.cur and P:ifoverlap(P.cur.bk,P.curX-1,P.curY) then
                        P.swingOffset.vx=-.5
                    end
                else
                    P.movDir=0
                end
            end
        elseif mov<das then
            mov=mov+1
        end
        P.moving=mov
    elseif P.keyPressing[1] then
        P.movDir=-1
        P.moving=0
    elseif P.keyPressing[2] then
        P.movDir=1
        P.moving=0
    end

    -- Drop pressed
    if P.keyPressing[7] then
        P.downing=P.downing+1
        if P.downing>=ENV.sddas then
            if ENV.sdarr==0 then
                P:act_insDown()
            end
            if ENV.shakeFX then
                P.swingOffset.vy=.2
            end
        end
    else
        P.downing=-1
    end

    local stopAtFalling

    -- Falling animation
    repeat
        if P.falling>0 then
            stopAtFalling=true
            P:_updateFalling(P.falling-1)
            if P.falling>0 then
                break-- goto THROW_stop
            end
        end

        -- Update block state
        if P.control then
            -- Try spawn new block
            if not P.cur then
                if not stopAtFalling and P.waiting>0 then
                    P.waiting=P.waiting-1
                end
                if P.waiting<=0 then
                    P:popNext()
                end
                break-- goto THROW_stop
            end

            -- Natural block falling
            if P.cur then
                if P.curY>P.ghoY then
                    local D=P.dropDelay
                    local dist-- Drop distance
                    if D>1 then
                        D=D-1
                        if P.keyPressing[7] and P.downing>=ENV.sddas then
                            D=D-ceil(ENV.drop/ENV.sdarr)
                        end
                        if D<=0 then
                            dist=1
                            P.dropDelay=(D-1)%ENV.drop+1
                        else
                            P.dropDelay=D
                            break-- goto THROW_stop
                        end
                    elseif D==1 then-- We don't know why dropDelay is 1, so checking ENV.drop>1 is neccessary
                        if ENV.drop>1 and P.downing>=ENV.sddas and (P.downing-ENV.sddas)%ENV.sdarr==0 then
                            dist=2
                        else
                            dist=1
                        end
                        -- Reset drop delay
                        P.dropDelay=ENV.drop
                    else-- High gravity case (>1G)
                        -- Add extra 1 if time to auto softdrop
                        if P.downing>ENV.sddas and (P.downing-ENV.sddas)%ENV.sdarr==0 then
                            dist=1/D+1
                        else
                            dist=1/D
                        end
                    end

                    -- Limit dropping to ghost at max
                    dist=min(dist,P.curY-P.ghoY)

                    -- Drop and create FXs
                    if ENV.moveFX and ENV.block and dist>1 then
                        for _=1,dist do
                            P:createMoveFX('down')
                            P.curY=P.curY-1
                        end
                    else
                        P.curY=P.curY-dist
                    end

                    P.spinLast=false
                    P:freshBlock('fresh')
                    P:checkTouchSound()
                else
                    P.lockDelay=P.lockDelay-1
                    if P.lockDelay>=0 then
                        break-- goto THROW_stop
                    end
                    P:drop(true)
                    if P.bot then
                        P.bot:lockWrongPlace()
                    end
                end
            end
        end
    until true
    -- ::THROW_stop::

    -- B2B bar animation
    if P.b2b1~=P.b2b then
        if P.b2b1<P.b2b then
            P.b2b1=min(approach(P.b2b1,P.b2b,dt*6)+.4,P.b2b)
        else
            P.b2b1=max(approach(P.b2b1,P.b2b,dt*12)-.6,P.b2b)
        end
    end

    _updateMisc(P,dt)
    --[[
        P:setPosition(
            640-150-(30*(P.curX+P.cur.sc[2])-15),
            30*(P.curY+P.cur.sc[1])+15-300+(
                ENV.smooth and P.ghoY~=P.curY and
                (P.dropDelay/ENV.drop-1)*30
                or 0
            )
        )
    ]]
end
local function update_streaming(P)
    local eventTime=P.stream[P.streamProgress]
    while eventTime and P.frameRun==eventTime do
        local event=P.stream[P.streamProgress+1]
        if event==0 then-- Just wait
        elseif event<=32 then-- Press key
            P:pressKey(event)
        elseif event<=64 then-- Release key
            P:releaseKey(event-32)
        elseif event>0x2000000000000 then-- Sending lines
            local sid=event%0x100
            local amount=int(event/0x100)%0x100
            local time=int(event/0x10000)%0x10000
            local line=int(event/0x100000000)%0x10000
            for _,p in next,PLY_ALIVE do
                if p.sid==sid then
                    P.netAtk=P.netAtk+amount
                    if P.netAtk~=P.stat.send then-- He cheated or just desynchronized to death
                        MES.new('warn',"#"..P.uid.." desynchronized")
                        NET.player_finish({reason='desync'})
                        P:lose(true)
                        return
                    end
                    P:attack(p,amount,time,line,true)
                    P:createBeam(p,amount)
                    break
                end
            end
        elseif event>0x1000000000000 then-- Receiving lines
            local sid=event%0x100
            for _,p in next,PLY_ALIVE do
                if p.sid==sid then
                    P:receive(
                        p,
                        int(event/0x100)%0x100,-- amount
                        int(event/0x10000)%0x10000,-- time
                        int(event/0x100000000)%0x10000-- line
                    )
                    break
                end
            end
        end
        P.streamProgress=P.streamProgress+2
        eventTime=P.stream[P.streamProgress]
    end
end
local function update_dead(P,dt)
    local S=P.stat

    -- Final average speed
    P.dropSpeed=approach(P.dropSpeed,S.piece/S.frame*3600,dt)

    if P.gameEnv.layout=='royale' then
        P.swappingAtkMode=min(P.swappingAtkMode+2,30)
    end

    if P.falling>0 then
        P:_updateFalling(P.falling-1)
    end
    if P.b2b1>0 then
        P.b2b1=max(0,P.b2b1*.92-1)
    end
    _updateMisc(P,dt)
end
function Player:_die()
    self.alive=false
    self.timing=false
    self.control=false
    self.waiting=1e99
    self.b2b=0
    self.tasks={}
    self:clearAttackBuffer()
    for i=1,#self.visTime do
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
function Player:update(dt)
    self.trigFrame=self.trigFrame+dt*60
    if self.alive then
        local S=self.stat
        if self.type=='bot' then self.bot:update(dt) end
        if self.trigFrame>=1 and self.alive then
            if self.streamProgress then
                S.time=self.stat.frame/60
            elseif self.timing then
                S.time=S.time+dt
            end
        end
        while self.trigFrame>=1 do
            if self.streamProgress then
                local frameDelta-- Time between now and end of stream
                if self.type=='remote' then
                    if self.loseTimer then
                        self.loseTimer=self.loseTimer-1
                        if self.loseTimer==0 then
                            self.loseTimer=false
                            self:lose(true)
                        end
                    end
                    frameDelta=(self.stream[#self.stream-1] or 0)-self.frameRun
                    if frameDelta==0 then frameDelta=nil end
                else
                    frameDelta=0
                end
                if frameDelta then
                    for _=1,
                        self.loseTimer and min(frameDelta,
                            self.loseTimer>16 and 2 or
                            self.loseTimer>6.2 and 12 or
                            self.loseTimer>2.6 and 260 or
                            2600
                        ) or
                        frameDelta<26 and 1 or
                        frameDelta<50 and 2 or
                        frameDelta<80 and 3 or
                        frameDelta<120 and 5 or
                        frameDelta<160 and 7 or
                        frameDelta<200 and 10 or
                        20
                    do
                        update_streaming(self)
                        update_alive(self,dt)
                    end
                end
            else
                update_alive(self,dt)
            end
            self.trigFrame=self.trigFrame-1
        end
    else
        while self.trigFrame>=1 do
            update_dead(self,dt)
            self.trigFrame=self.trigFrame-1
        end
    end
    _updateFX(self,dt)
end
function Player:revive()
    local h=#self.field
    for _=h,1,-1 do
        LINE.discard(self.field[_])
        LINE.discard(self.visTime[_])
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
    self:freshBlock('push')

    for i=1,h do
        self:createClearingFX(i)
    end
    SYSFX.newShade(1.4,self.fieldX,self.fieldY,300*self.size,610*self.size)
    SYSFX.newRectRipple(2,self.fieldX,self.fieldY,300*self.size,610*self.size)
    SYSFX.newRipple(2,self.x+(475+25*(self.life<3 and self.life or 0)+12)*self.size,self.y+(595+12)*self.size,20)
    playClearSFX(3)
    SFX.play('emit')
end
function Player:win(result)
    if self.result then
        return
    end
    self:_die()
    self.result='win'
    if self.gameEnv.layout=='royale' then
        self.modeData.place=1
        self:changeAtk()
    end
    if result=='finish' then
        for i=#PLY_ALIVE,1,-1 do
            if PLY_ALIVE[i]~=self then
                PLY_ALIVE[i]:lose(true)
            end
        end
    end
    if self.type=='human' then
        GAME.result=result or 'gamewin'
        SFX.play('win')
        VOC.play('win')
        if self.gameEnv.layout=='royale' then
            BGM.play('8-bit happiness')
        end
    end
    if GAME.curMode.name=='custom_puzzle' then
        self:_showText(text.win,0,0,90,'beat',.4)
    else
        self:_showText(text.win,0,0,90,'beat',.5,.2)
    end
    if self.type=='human' then
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
        elseif self.type=='remote' then
            if not self.loseTimer then
                self.waiting=1e99
                return
            end
        end
    end
    do
        local p=TABLE.find(PLY_ALIVE,self)
        if p then
            PLY_ALIVE[p]=PLY_ALIVE[#PLY_ALIVE]
            rem(PLY_ALIVE)
        end
    end
    self:_die()
    self.result='lose'
    if self.gameEnv.layout=='royale' then
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
                    if A.badge>=ROYALEDATA.powerUp[i] then
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
        if #PLY_ALIVE==ROYALEDATA.stage[GAME.stage] then
            royaleLevelup()
        end
        self:_showText(self.modeData.place,0,120,60,'appear',.26,.9)
    end
    self.gameEnv.keepVisible=self.gameEnv.visible~='show'
    self:_showText(text.lose,0,0,90,'appear',.26,.9)
    if self.type=='human' then
        GAME.result='gameover'
        SFX.play('fail')
        VOC.play('lose')
        if self.gameEnv.layout=='royale' then
            BGM.play('end')
        end
        gameOver()
        self:newTask(#PLAYERS>1 and task_lose or task_finish)
        if GAME.net and not NET.spectate then
            NET.player_finish({reason="lose"})
        else
            TASK.new(task_autoPause)
        end
    else
        self:newTask(task_lose)
    end

    if #PLY_ALIVE>0 then
        self:dropPosition()
        freshPlayerPosition('update')

        local finished=true
        for i=1,#PLY_ALIVE-1 do
            if PLY_ALIVE[i].group==0 or PLY_ALIVE[i].group~=PLY_ALIVE[i+1].group then
                finished=false
                break-- goto BREAK_notFinished
            end
        end
        -- Only 1 people or only 1 team survived, they win
        if finished then
            for i=1,#PLY_ALIVE do
                PLY_ALIVE[i]:win()
            end
        end
        -- ::BREAK_notFinished::
    end
end
--------------------------<\Event>--------------------------

return Player
