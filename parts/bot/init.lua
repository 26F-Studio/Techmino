local rem=table.remove

local baseBot={
	pushNewNext=NULL,
	updateField=NULL,
	lockWrongPlace=NULL,
	switch20G=NULL,
	revive=NULL,
}
function baseBot.update(bot)
	local P=bot.P
	if P.control and P.waiting==-1 then
		local keyQueue=bot.keys
		bot.delay=bot.delay-1
		if not keyQueue[1]then
			if bot.runningThread then
				pcall(bot.runningThread)
				if not pcall(bot.runningThread)then
					P:destroyBot()
				end
			else
				P:act_hardDrop()
			end
		elseif bot.delay<=0 then
			bot.delay=bot.delay0*.5
			P:pressKey(keyQueue[1])P:releaseKey(keyQueue[1])
			rem(keyQueue,1)
		end
	end
end

local botMeta={__index=function(self,k)
	MES.new('warn',"Undefined method: "..k)
	self[k]=NULL
	return NULL
end}

return{
	new=function(P,data)
		local bot={P=P}
		if data.type=="/"then
			--
		else
			TABLE.cover(baseBot,bot)
			TABLE.cover(require"parts.bot.bot_9s",bot)
			bot.P:setRS('TRS')
			bot.runningThread=coroutine.wrap(bot.thread)
			bot.keys={}
			bot.delay=data.delay
			bot.delay0=data.delay
			bot.runningThread(P,bot.keys)
			setmetatable(bot,botMeta)
		end
		return bot
	end
}