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
    if P.control and P.waiting==-1 then
        bot.delay=bot.delay-1
        if not keys[1]then
            if bot.runningThread then
                pcall(bot.runningThread)
            else
                P:act_hardDrop()
            end
        elseif bot.delay<=0 then
            bot.delay=bot.delay0*.5
            P:pressKey(keys[1])P:releaseKey(keys[1])
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

local AISpeed={60,50,40,30,20,14,10,6,4,3}
-- For CC bot:
-- TODO you still need to switch20G() at the right time.
-- since it's not cc-specific I'm not dealing with it for now
--[[
    next: number of nexts
    hold: holdable?
    speedLV: level
    node: search nodes
    randomizer: random generator
    _20G: 20G?
]]
function BOT.template(arg)
    if arg.type=='CC'then
        if not arg.randomizer then arg.randomizer='bag' end
        return{
            type='CC',
            next=arg.next,
            hold=arg.hold,
            delay=AISpeed[arg.speedLV],
            node=arg.node,
            bag=arg.randomizer=='bag',
            _20G=arg._20G,
        }
    elseif arg.type=='9S'then
        return{
            type='9S',
            delay=math.floor(AISpeed[arg.speedLV]),
            hold=arg.hold,
        }
    end
end

function BOT.new(P,data)
    local bot={P=P,data=data}
    if data.type=="CC"then
        P:setRS('SRS')
        bot.keys={}
        bot.nexts={}
        bot.delay=data.delay
        bot.delay0=data.delay
        if P.gameEnv.holdCount and P.gameEnv.holdCount>1 then P:setHold(1)end

        local cc=require"CCloader"
        local opt,wei=cc.getDefaultConfig()
            wei:fastWeights()
            opt:setHold(data.hold)
            opt:set20G(data._20G)
            opt:setBag(data.bag=='bag')
            opt:setNode(data.node)
        bot.ccBot=cc.launchAsync(opt,wei)
        local cc_lua=require"parts.bot.bot_cc"
        setmetatable(bot,{__index=function(self,k)
            return
                self.ccBot[k] and function(_,...)self.ccBot[k](self.ccBot,...)end or
                cc_lua[k] and function(_,...)cc_lua[k](self,...)end or
                baseBot[k] and baseBot[k] or
                error("MrZ did something bad again! He just wanted "..k)
        end})

        for i,B in next,P.nextQueue do
            if i<=data.next then
                bot:addNext(B.id)
            else
                ins(bot.nexts,B.id)
            end
        end
        bot.runningThread=coroutine.wrap(cc_lua.thread)
        bot.runningThread(bot)
    elseif data.type=="9S"or true then--9s or else
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