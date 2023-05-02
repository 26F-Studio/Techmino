local ins,rem=table.insert,table.remove

local baseBot={
    pushNewNext=NULL,
    updateField=NULL,
    updateB2B=NULL,
    updateCombo=NULL,
    checkDest=NULL,
    switch20G=NULL,
    revive=NULL,
}
function baseBot.update(bot)
    local P=bot.P
    local keys=bot.keys
    if P.control and P.cur then
        bot.delay=bot.delay-1
        if not keys[1] then
            if bot.runningThread then
                if not pcall(bot.runningThread) then
                    bot.runningThread=false
                end
            else
                bot.delay=math.min(10,bot.delay-1)
                if bot.delay==0 then
                    P:pressKey(6)
                    P:releaseKey(6)
                    bot.delay=10
                end
            end
        elseif bot.delay<=0 then
            if keys[1]>3 then
                bot.delay=bot.delay0
            else
                bot.delay=bot.delay0*.4
            end
            P:pressKey(keys[1])
            P:releaseKey(keys[1])
            rem(keys,1)
        end
    end
end

local function _undefMethod(self,k)
    print("Undefined method: "..k)
    self[k]=NULL
    return NULL
end
local botMeta={__index=_undefMethod}

local BOT={}

local AISpeed={60,50,42,34,27,21,16,12,9,6}
--[[
    arg={
        next: number of nexts
        hold: holdable
        speedLV: level
        node: search nodes
        randomizer: random generator
        _20G: 20G?
    }
]]
function BOT.template(arg)
    if arg.type=='CC' then
        return {
            type='CC',
            next=arg.next,
            hold=arg.hold,
            delay=AISpeed[arg.speedLV],
            node=arg.node,
            bag=(arg.randomizer or 'bag')=='bag',
            _20G=arg._20G,
        }
    elseif arg.type=='9S' then
        return {
            type='9S',
            delay=math.floor(AISpeed[arg.speedLV]),
            hold=arg.hold,
        }
    end
end

function BOT.new(P,data)
    local bot={P=P,data=data}
    if data.type=="CC" then
        P:setRS('TRS')
        bot.keys={}
        bot.bufferedNexts={}
        bot.delay=data.delay
        bot.delay0=data.delay
        if P.gameEnv.holdCount>1 then
            P:setHold(1)
        end

        local cc=REQUIRE"CCloader"
        if not cc then
            data.type=false
            return BOT.new(P,data)
        end
        local opt,wei=cc.getDefaultConfig()
            wei:fastWeights()
            opt:setHold(data.hold)
            opt:set20G(data._20G)
            opt:setBag(data.bag)
            opt:setNode(data.node)
        bot.ccBot=cc.launchAsync(opt,wei)
        local cc_lua=require"parts.bot.bot_cc"
        setmetatable(bot,{__index=function(self,k)
            return
                self.ccBot[k] and function(_,...)self.ccBot[k](self.ccBot,...) end or
                cc_lua[k] and function(_,...)cc_lua[k](self,...) end or
                assert(baseBot[k],"No CC action called "..k)
        end})

        local pushed=0
        if P.cur then
            bot:addNext(P.cur.id)
            pushed=pushed+1
        end
        for _,B in next,P.nextQueue do
            if pushed<=data.next then
                bot:addNext(B.id)
                pushed=pushed+1
            else
                ins(bot.bufferedNexts,B.id)
            end
        end
        bot.runningThread=coroutine.wrap(cc_lua.thread)
        bot.runningThread(bot)
    else-- if data.type=="9S" then-- 9s or else
        TABLE.cover(baseBot,bot)
        TABLE.cover(require"parts.bot.bot_9s",bot)
        P:setRS('TRS')
        bot.keys={}
        bot.delay=data.delay
        bot.delay0=data.delay
        bot.runningThread=coroutine.wrap(bot.thread)
        bot.runningThread(bot)
        setmetatable(bot,botMeta)
    end
    return bot
end

return BOT
