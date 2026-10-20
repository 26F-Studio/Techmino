local Protocol=require'parts.online.protocol'
local Render=require'parts.online.render'
local MatchSession={}
MatchSession.__index=MatchSession
function MatchSession.new(net)
    return setmetatable({net=net,id=false,state='idle',participants={},byAccount={},bySlot={},pending={},nextSeq=1,lastAckSeq=0,lastSentSeq=0,serverFrame=0,renderFrame=0,held={},histories={},historyBytes=0,isolated={},countdown=false},MatchSession)
end
function MatchSession:isActive()
    return self.id and (self.state=='playing' or self.state=='catching_up' or self.state=='paused' or self.state=='finishing')
end
function MatchSession:isParticipant()
    return self.id and self.accountSlots and self.accountSlots[USER.uid]~=nil
end
function MatchSession:clock()
    if self.state=='paused' then return self.serverFrame end
    return math.min(54000,self.serverFrame+math.floor((love.timer.getTime()-(self.anchor or love.timer.getTime()))*60))
end
function MatchSession:observeFrame(frame)
    if not Protocol.integer(frame,0,54000) then return false end
    self.serverFrame=frame
    self.anchor=love.timer.getTime()
    return true
end
function MatchSession:clear()
    self:releaseAll()
    self.id=false
    self.state='idle'
    self.participants={}
    self.accountSlots={}
    self.byAccount={}
    self.bySlot={}
    self.pending={}
    self.histories={}
    self.countdown=false
    self.historyBytes=0
    self.held={}
    self.finished=false
    GAME.net=false
    GAME.playing=false
    GAME.recording=false
    destroyPlayers()
end
function MatchSession:loadSourcePlayers()
    Render.create(self)
end
function MatchSession:start(data)
    if not Protocol.match(data) then self.net.report('INVALID_MATCH','The match start data is invalid.') return false end
    if not self.net.roomStore.snapshot or self.net.roomStore.snapshot.id~=data.roomId then self.net.report('MATCH_ROOM_MISMATCH','The match start does not belong to the current revisioned room.') return false end
    if self.id==data.matchId then return true end
    self.id=data.matchId
    self.roomId=data.roomId
    self.track=data.track
    self.seed=data.seed
    self.rulesetVersion=data.rulesetVersion
    self.participants=data.participants
    self.accountSlots={}
    self.byAccount={}
    self.bySlot={}
    self.pending={}
    self.nextSeq,self.lastAckSeq,self.lastSentSeq=1,0,0
    self.adoptingAck=data.frame>0
    self.resendCursor=false
    self.lastInputFrame=0
    self.catchupTarget=false
    self.needsReplay=false
    self.renderFrame=0
    self.histories={}
    self.streamSequences={}
    self.isolated={}
    self.historyBytes=0
    self.targetEvents={}
    self.held={}
    self.finished=false
    self.finishRequested=false
    self.releasePending=false
    self.terminalFrames={}
    self.pauseReason=false
    self.pauseUntil=false
    self.recovering=false
    self.finalState=false
    self.result=false
    self.snapshot=false
    self.absent=false
    self.countdown=false
    self.state='playing'
    self:observeFrame(data.frame or 0)
    for _,member in ipairs(self.participants) do
        self.accountSlots[member.accountId]=member.slot
        self.histories[member.accountId]={}
        self.streamSequences[member.accountId]=0
    end
    if not MODES.netBattle then
        MODES.netBattle=require'parts.modes.netBattle'
        MODES.netBattle.name='netBattle'
    end
    GAME.curMode=MODES.netBattle
    GAME.curModeName='netBattle'
    GAME.modeEnv=TABLE.copy(MODES.netBattle.env)
    GAME.net=true
    GAME.playing=true
    GAME.authority=false
    resetGameData('n',self.seed)
    -- Relay recording uses the original recording/parser grammar, never wire Lua.
    -- Authoritative render snapshots are not simulation checkpoints or local replays.
    GAME.recording=false
    GAME.statSaved=self.track=='authoritative' or not self:isParticipant()
    if self.track=='relay' then BG.set('none') end
    return true
end
function MatchSession:queueInput(kind,action,value,reconcile)
    local releasing=reconcile and kind==0 and self.held[action] and (self.state=='playing' or self.state=='finishing')
    if (self.state~='playing' or self.finished) and not releasing or self.absent or not self:isParticipant() or self.net.connectionState~='ready' or self.recovering or self.adoptingAck then return false end
    if not Protocol.integer(action,kind==2 and 0 or 1,kind==2 and 0 or 20) then return false end
    if kind==2 and self.track=='authoritative' then self.net.report('INPUT_UNSUPPORTED','Manual targeting is not enabled for authoritative default rules.') return false end
    if self.nextSeq-self.lastAckSeq>2048 then self.net.report('INPUT_QUEUE_LIMIT','Input recovery exceeded its approved bound.') self:absentNow() return false end
    local frame=math.max(self:clock()+6,self.lastInputFrame or 1)
    if frame>54000 then return false end
    local event={seq=self.nextSeq,frame=frame,kind=kind,action=action,value=value or 0}
    self.pending[self.nextSeq]=event
    self.nextSeq=self.nextSeq+1
    self.lastInputFrame=frame
    return true
end
function MatchSession:press(action)
    if self.held[action] then return end
    if self:queueInput(1,action,0) then self.held[action]=true return true end
end
function MatchSession:release(action,reconcile)
    if not self.held[action] then return end
    if self:queueInput(0,action,0,reconcile) then self.held[action]=nil return true end
    self.releasePending=true
end
function MatchSession:releaseAll()
    self.releasePending=false
    for action=1,20 do if self.held[action] then self:release(action,true) end end
end
function MatchSession:flush(fromSeq)
    if not self.id or self.net.connectionState~='ready' then return end
    local first=fromSeq or self.resendCursor or self.lastSentSeq+1
    local events={}
    for sequence=first,math.min(self.nextSeq-1,first+63) do
        local event=self.pending[sequence]
        if not event then break end
        events[#events+1]=event
    end
    if #events==0 then return false end
    local packet,err=Protocol.encodeInput(self.id,first,events)
    if not packet then self.net.report('INVALID_INPUT',err) return end
    local ok,sendError=self.net.session.client:send(self.net.socketId,packet,'binary')
    if ok then
        self.lastSentSeq=math.max(self.lastSentSeq,first+#events-1)
        self.resendCursor=first+#events<self.nextSeq and first+#events or false
        return true
    else self.net.session:report(sendError) return false end
end
function MatchSession:flushAll()
    for _=1,32 do if not self:flush() then break end end
end
function MatchSession:ack(data)
    if data.accountId and data.accountId~=USER.uid then return end
    local through=data.acceptedThrough
    local expected=data.expectedSeq
    if self.adoptingAck and Protocol.integer(through,0,4294967294) and Protocol.integer(expected,1,4294967295) and through==expected-1 then
        self.nextSeq=expected
        self.lastAckSeq,self.lastSentSeq=through,through
        self.adoptingAck=false
    end
    if not Protocol.integer(through,0,self.nextSeq-1) or not Protocol.integer(expected,1,self.nextSeq) or through~=expected-1 then self.net.report('INVALID_ACK','The server returned an invalid input acknowledgement.') return end
    self.lastAckSeq=math.max(self.lastAckSeq,through)
    for sequence in pairs(self.pending) do if sequence<expected then self.pending[sequence]=nil end end
    self.lastSentSeq=math.max(self.lastSentSeq,expected-1)
    if data.frame then self:observeFrame(data.frame) end
    if self.pending[expected] and expected<=self.lastSentSeq then self:flush(expected) end
end
function MatchSession:finishBoundary()
    if not self:isParticipant() or self.finished or not self:isActive() then return end
    self:releaseAll()
    self:flushAll()
    self.finished=true
    self.state=self.state=='paused' and 'paused' or 'finishing'
    self:sendFinish()
end
function MatchSession:sendFinish()
    if not self.finished or self.finishRequested or self.net.connectionState~='ready' or self.recovering or self.adoptingAck or self.releasePending or self.absent then return end
    self:flushAll()
    if self.lastSentSeq<self.nextSeq-1 then return end
    self.finishRequested=self.net.request('match.finish',{roomId=self.roomId,matchId=self.id,finalSeq=self.nextSeq-1,finalFrame=math.max(self.lastInputFrame or 0,self:clock())}) or false
end
function MatchSession:absentNow()
    if not self:isActive() or not self:isParticipant() or self.absent then return end
    self:releaseAll()
    self:flushAll()
    self.absent=true
    self.net.request('match.absent',{roomId=self.roomId,matchId=self.id})
end
function MatchSession:returnNow()
    if not self:isActive() or not self.absent then return end
    self.absent=false
    self.net.request('match.return',{roomId=self.roomId,matchId=self.id})
end
function MatchSession:resume()
    if not self:isActive() then return end
    self.recovering=true
    self.net.request('match.resume',{roomId=self.roomId,matchId=self.id,lastAckSeq=self.lastAckSeq},function(data,err)
        if err then self.recovering=false self.state='aborted' self.net.report(err.code,err.message) return end
        if data and data.expectedSeq then self:ack(data) end
    end)
end
function MatchSession:isolate(id,message)
    if not self.isolated[id] then
        self.isolated[id]=true
        self.net.report('INVALID_RELAY_STREAM','A relay stream was isolated: '..tostring(id)..'. '..message)
    end
end
function MatchSession:inputs(data)
    if type(data)~='table' or data.matchId~=self.id or not self.accountSlots[data.accountId] or data.slot~=self.accountSlots[data.accountId] or type(data.events)~='table' or #data.events<1 or #data.events>64 then
        self:isolate(type(data)=='table' and data.accountId or 'unknown','Invalid input envelope.')
        return
    end
    if self.track~='relay' or self.isolated[data.accountId] then return end
    local previous=self.streamSequences[data.accountId]
    local lastFrame=0
    local valid={}
    for _,event in ipairs(data.events) do
        if not Protocol.input(event,#self.participants) or event.frame<lastFrame then self:isolate(data.accountId,'Invalid input grammar.') return end
        lastFrame=event.frame
        if event.seq>previous then
            valid[#valid+1]=event
            previous=event.seq
        end
    end
    if #valid==0 then return end
    if self.historyBytes+#valid*32>16777216 then self.state='aborted' self.net.report('REPLAY_LIMIT','The bounded relay replay limit was reached.') return end
    self.historyBytes=self.historyBytes+#valid*32
    self.streamSequences[data.accountId]=previous
    local P=self.byAccount[data.accountId]
    local recording={}
    local late=false
    for _,event in ipairs(valid) do
        self.histories[data.accountId][#self.histories[data.accountId]+1]=event
        if event.frame<=self.renderFrame then late=true end
        if event.kind==2 then
            self.targetEvents[event.frame]=self.targetEvents[event.frame] or {}
            self.targetEvents[event.frame][#self.targetEvents[event.frame]+1]={slot=data.slot,target=event.value}
        else
            recording[#recording+1]=event.frame-1
            recording[#recording+1]=event.action+(event.kind==0 and 32 or 0)
        end
    end
    if late then self.needsReplay=true else DATA.pumpRecording(DATA.dumpRecording(recording),P.stream) end
end
function MatchSession:rebuildRelay()
    self.byAccount,self.bySlot={},{}
    self.renderFrame=0
    self.targetEvents={}
    local history=self.histories
    resetGameData('n',self.seed)
    GAME.recording=false
    for _,member in ipairs(self.participants) do
        local recording={}
        for _,event in ipairs(history[member.accountId]) do
            if event.kind==2 then
                self.targetEvents[event.frame]=self.targetEvents[event.frame] or {}
                self.targetEvents[event.frame][#self.targetEvents[event.frame]+1]={slot=member.slot,target=event.value}
            else
                recording[#recording+1]=event.frame-1
                recording[#recording+1]=event.action+(event.kind==0 and 32 or 0)
            end
        end
        DATA.pumpRecording(DATA.dumpRecording(recording),self.byAccount[member.accountId].stream)
    end
    self.needsReplay=false
end
function MatchSession:event(kind,data)
    if kind=='match.countdown' then
        if type(data)=='table' and self.net.roomStore.snapshot and data.roomId==self.net.roomStore.snapshot.id and data.seconds==3 then self.countdown=love.timer.getTime()+3 end
        return
    elseif kind=='match.cancelled' then if type(data)=='table' and self.net.roomStore.snapshot and data.roomId==self.net.roomStore.snapshot.id then self.countdown=false end return
    elseif kind=='match.started' then return self:start(data) end
    if type(data)~='table' or data.matchId~=self.id or data.roomId~=self.roomId then return end
    if kind=='match.inputAck' then self:ack(data)
    elseif kind=='match.inputRejected' then
        if data.accountId==USER.uid then
            if Protocol.integer(data.expectedSeq,1,self.nextSeq) then
                self:ack{accountId=USER.uid,acceptedThrough=data.expectedSeq-1,expectedSeq=data.expectedSeq,frame=data.frame}
            end
            self.net.report(data.code or 'INPUT_REJECTED','Input was rejected by the server; its sequence was explicitly resolved.')
        end
    elseif kind=='match.inputs' then self:inputs(data)
    elseif kind=='match.snapshot' then
        if self.track~='authoritative' or not Render.apply(data.state,self) then self.net.report('INVALID_SNAPSHOT','The authoritative source render state was rejected.') return end
        self:observeFrame(data.frame)
        self.recovering=false
        self:applyParticipants(data.participants)
        if type(data.acks)=='table' and data.acks[USER.uid] then self:ack{accountId=USER.uid,acceptedThrough=data.acks[USER.uid],expectedSeq=data.acks[USER.uid]+1} end
    elseif kind=='match.catchup' then
        if self.track~='relay' or type(data.entries)~='table' or #data.entries>512 then self.net.report('INVALID_CATCHUP','The spectator catch-up chunk is invalid.') return end
        self.state='catching_up'
        for _,entry in ipairs(data.entries) do self:inputs(entry) end
    elseif kind=='match.catchupComplete' then
        self:observeFrame(data.frame)
        if data.expectedSeq and self:isParticipant() then self:ack(data) end
        self.recovering=false
        self.adoptingAck=false
        self:applyParticipants(data.participants)
        self.catchupTarget=data.frame
        self.state=self.pauseReason and 'paused' or self.finished and 'finishing' or 'playing'
    elseif kind=='match.paused' then
        self:observeFrame(data.frame)
        self.state='paused'
        self.pauseReason=data.reason
        self.pauseUntil=data['until']
    elseif kind=='match.resumed' then
        self:observeFrame(data.frame)
        self.state=self.finished and 'finishing' or 'playing'
        self.pauseReason=false
        self.pauseUntil=false
    elseif kind=='match.participantEnded' then
        if self.track=='relay' and self.accountSlots[data.accountId] and Protocol.integer(data.frame,0,54000) then self.terminalFrames[data.accountId]=data.frame end
        if data.accountId==USER.uid then self:finishBoundary() end
    elseif kind=='match.completed' or kind=='match.aborted' then
        self:releaseAll()
        self:observeFrame(data.frame)
        self.state=kind=='match.completed' and 'completed' or 'aborted'
        self.result=data.result or {code=data.code,message=data.message}
        self.replayId=data.replayId
        self.durable=data.durable==true
        self.pending={}
        if self.track=='relay' then self.catchupTarget=data.frame self.finalState=kind=='match.completed' and 'completed' or 'aborted' end
        self.countdown=false
        self.held={}
        if kind=='match.aborted' then self.net.report(data.code or 'MATCH_ABORTED',data.message or 'The match was aborted.') end
    end
end
function MatchSession:applyParticipants(participants)
    if type(participants)~='table' then return end
    for _,participant in ipairs(participants) do
        if type(participant)=='table' and self.accountSlots[participant.accountId]==participant.slot then
            if participant.status=='ended' and Protocol.integer(participant.terminalFrame,0,54000) then self.terminalFrames[participant.accountId]=participant.terminalFrame end
            if participant.accountId==USER.uid then
                self.absent=participant.absent==true
                if participant.status=='ended' or participant.status=='inputComplete' or participant.status=='finishing' then self.finished=true self.finishRequested=true end
            end
        end
    end
end
function MatchSession:update()
    if not self:isActive() and not (self.track=='relay' and self.catchupTarget) then return end
    if self.releasePending and self.net.connectionState=='ready' and not self.recovering then self:releaseAll() end
    self:flush()
    self:sendFinish()
    if self.track~='relay' or self.state=='paused' or self.state=='catching_up' then return end
    if self.needsReplay then self:rebuildRelay() end
    local target=self.catchupTarget or math.max(0,self:clock()-12)
    local steps=math.min(120,math.max(0,target-self.renderFrame))
    for _=1,steps do
        local nextFrame=self.renderFrame+1
        for _,event in ipairs(self.targetEvents[nextFrame] or {}) do
            local P,T=self.bySlot[event.slot],self.bySlot[event.target]
            if P and T and P~=T then P:changeAtk(T) end
        end
        self.targetEvents[nextFrame]=nil
        for _,P in ipairs(PLAYERS) do
            if self.terminalFrames[P.uid] and self.terminalFrames[P.uid]<nextFrame and P.alive then P:lose(true) end
            local own=P.uid==USER.uid and self:isParticipant()
            local progress=P.streamProgress
            if own then
                local cursor=progress
                while P.stream[cursor]==P.frameRun do
                    GAME.rep[#GAME.rep+1]=P.frameRun
                    GAME.rep[#GAME.rep+1]=P.stream[cursor+1]
                    cursor=cursor+2
                end
            end
            local ok=pcall(P.update,P,1/60)
            if not ok then self:isolate(P.uid,'The validated recording could not be applied.') P.stream={} P.streamProgress=1 end
            if P.streamProgress and P.streamProgress>512 then
                local remaining={}
                for index=P.streamProgress,#P.stream do remaining[#remaining+1]=P.stream[index] end
                P.stream=remaining
                P.streamProgress=1
            end
        end
        self.renderFrame=nextFrame
    end
    if self.catchupTarget and self.renderFrame>=self.catchupTarget then
        self.catchupTarget=false
        if self.finalState then self.state=self.finalState self.finalState=false end
    end
    local own=self.byAccount[USER.uid]
    if own and not own.alive and not self.finished then self:finishBoundary() end
end
return MatchSession
