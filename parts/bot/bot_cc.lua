--[[ControlID:
    1~5:mL,mR,rR,rL,rF,
    6~10:hD,sD,H,A,R,
    11~13:LL,RR,DD
]]
local pcall=pcall
local ins,rem=table.insert,table.remove
local yield=coroutine.yield
local bot_cc={}
function bot_cc:checkDest(b2b,atk,exblock,yomi)
    local dest=self.P.destFX
    if not dest then return end
    if not (dest.b2b==b2b and dest.attack==atk and dest.extra==exblock) then
        -- print(('hope: %s %s %s'):format(dest.b2b,dest.attack,dest.extra))
        -- print(('real: %s %s %s'):format(b2b,atk,exblock))
        -- print(yomi)
        self:lockWrongPlace()
        self.P.destFX=nil
        return
    end
    local CB=self.P.cur.bk
    for k=1,#dest,2 do
        local r=CB[dest[k+1]-self.P.curY+2]
        if not r or not r[dest[k]-self.P.curX+2] then
            -- print('wrong place')
            self:lockWrongPlace()
            self.P.destFX=nil
            return
        end
    end
    local should_spawn = self.P:getNextSpawn() - 1
    if dest.spawn ~= should_spawn then
        assert(dest.spawn > should_spawn)
        -- print('wrong spawn: should be '..dest.spawn..' but '..should_spawn)
        -- print('-- should only happen when camera is going down')
        self:lockWrongPlace()
        self.P.destFX=nil
        return
    end
end
function bot_cc:revive()
    TABLE.cut(self.P.holdQueue)
    self.P:loadAI(self.data)
end
function bot_cc:pushNewNext(id)
    ins(self.bufferedNexts,id)
    self.ccBot:addNext(rem(self.bufferedNexts,1))
end
function bot_cc:thread()
    local P,keys=self.P,self.keys
    local ccBot=self.ccBot
    while true do
        -- Start thinking
        yield()
        ccBot:think()

        -- Poll keys
        local success,result,dest,hold,move,b2b,attack,extra,spawn
        repeat
            yield()
            success,result,dest,hold,move,b2b,attack,extra,spawn=pcall(ccBot.getMove,ccBot)
        until not success or result==0 or result==2
        if not success then break end
        if result==2 then
            break
        elseif result==0 then
            dest[5],dest[6]=dest[1][1],dest[1][2]
            dest[7],dest[8]=dest[2][1],dest[2][2]
            dest[1],dest[2]=dest[3][1],dest[3][2]
            dest[3],dest[4]=dest[4][1],dest[4][2]
            dest.b2b = b2b
            dest.attack = attack
            dest.extra = extra
            dest.spawn = spawn
            P.destFX=dest
            if hold then-- Hold
                keys[1]=8
            end
            while move[1] do
                local m=rem(move,1)
                if m<4 then
                    ins(keys,m+1)
                elseif m==5 then
                    ins(keys, 5)
                elseif not self.data._20G then
                    ins(keys,13)
                end
            end
            ins(keys,6)
        end

        -- Check if time to change target
        yield()
        if P.aiRND:random()<.00126 then
            P:changeAtkMode(P.aiRND:random()<.85 and 1 or #P.atker>3 and 4 or P.aiRND:random()<.3 and 2 or 3)
        end
    end
end
function bot_cc:updateField()
    local P=self.P
    local F0=P.field
    local F,i={},1
    for y=1,#F0 do for x=1,10 do
        F[i],i=F0[y][x]>0,i+1
    end end
    while i<=400 do F[i],i=false,i+1 end
    local y = P:getNextSpawn()-1
    if not pcall(self.ccBot.reset,self.ccBot,F,P.b2b,P.combo,P.stat.pc,P.stat.row,y) then
        print("CC is dead ("..P.id..")","error")
        for y=#F0,1,-1 do
            local s=""
            for x=1,10 do
                s=s..(F[(y-1)*10+x] and "[]" or "..")
            end
            print(s)
        end
    end
end
function bot_cc:switch20G()
    TABLE.cut(self.P.holdQueue)
    self.data._20G=true
    self.P:loadAI(self.data)
end
bot_cc.lockWrongPlace=bot_cc.updateField
return bot_cc
