--[[ControlID:
    1~5:mL,mR,rR,rL,rF,
    6~10:hD,sD,H,A,R,
    11~13:LL,RR,DD
]]
local ins,rem=table.insert,table.remove
local yield=coroutine.yield
local bot_cc={}
function bot_cc:pushNewNext(id)
    self.bot:addNext(rem(self.nexts,1))
    ins(self.nexts,id)
end
function bot_cc:thread()
    local P,keys=self.P,self.keys
    local ccBot=self.ccBot
    while true do
        --Start thinking
        yield()
        ccBot:think()

        --Poll keys
        local success,result,dest,hold,move
        repeat
            yield()
            success,result,dest,hold,move=ccBot:getMove()
        until not success or result==0 or result==2
        if not success then break end
        if result==2 then
            break
        elseif result==0 then
            dest[5],dest[6]=dest[1][1],dest[1][2]
            dest[7],dest[8]=dest[2][1],dest[2][2]
            dest[1],dest[2]=dest[3][1],dest[3][2]
            dest[3],dest[4]=dest[4][1],dest[4][2]
            P.AI_dest=dest
            if hold then keys[1]=8 end--Hold
            while move[1]do
                local m=rem(move,1)
                if m<4 then
                    ins(keys,m+1)
                elseif not P.AIdata._20G then
                    ins(keys,13)
                end
            end
            ins(keys,6)
        end

        --Check if time to change target
        yield()
        if P.aiRND:random()<.00126 then
            P:changeAtkMode(P.aiRND:random()<.85 and 1 or #P.atker>3 and 4 or P.aiRND:random()<.3 and 2 or 3)
        end
    end
end
return bot_cc