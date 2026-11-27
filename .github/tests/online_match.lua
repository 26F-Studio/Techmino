local function id(value)
    return ('00000000-0000-4000-8000-%012x'):format(value)
end
local function inputFixture(count)
    local packets,reports={},{}
    local resumeReply
    local net={
        connectionState='ready',socketId=1,
        report=function(code) reports[#reports+1]=code end,
        request=function(_,_,callback) resumeReply=callback return 'resume' end,
        session={
            client={send=function(_,_,packet) packets[#packets+1]=packet return true end},
            report=function(err) error(tostring(err)) end,
        },
    }
    local match=require'parts.online.matchSession'.new(net)
    match.id,match.roomId=id(10),id(100)
    match.state,match.track='playing','authoritative'
    match.accountSlots={[USER.uid]=1}
    match.seed,match.rulesetVersion=12345,'techmino-source-v1'
    match.terminalFrames={}
    match.participants={{accountId=USER.uid,slot=1,team=1},{accountId=id(2),slot=2,team=2}}
    match.byAccount={
        [USER.uid]={gameEnv={skinSet='Crystal (Scf)'}},
        [id(2)]={gameEnv={skinSet='Crystal (Scf)'}},
    }
    match:observeFrame(180)
    for sequence=1,count do
        assert(match:queueInput(sequence%2,1,0),'The input fixture could not queue a source action')
        match:flush()
    end
    return match,packets,reports,function(data) resumeReply(data) end
end
local function inputSnapshot(match,through)
    local players={}
    for index,member in ipairs(match.participants) do
        players[index]={
            accountId=member.accountId,slot=member.slot,team=member.team,
            state={
                alive=true,field={},visTime={},fieldGarbage={},cur=false,nextQueue={},holdQueue={},
                stat={},swingOffset={},lastPiece={},gameEnv={},
                clearingRow={},clearedRow={},keyPressing={},frameColor={},atkBuffer={},
            },
        }
    end
    return {
        matchId=match.id,roomId=match.roomId,frame=180,acks={[USER.uid]=through},
        state={
            schemaVersion=1,matchId=match.id,seed=match.seed,rulesetVersion=match.rulesetVersion,
            frame=180,readyFrames=180,players=players,
        },
    }
end
local function packetRange(packet,first,count)
    assert(love.data.unpack('<I2',packet,7)==count,'The recovery batch exceeded or lost its event boundary')
    assert(love.data.unpack('<I4',packet,25)==first,'The recovery batch started at the wrong sequence')
end
local function verifyInputAcknowledgements()
    USER.uid=id(1)
    local match,packets=inputFixture(3)
    match:ack{acceptedThrough=1,expectedSeq=2}
    match:ack{acceptedThrough=0,expectedSeq=1}
    assert(#packets==3,'Ordinary or stale acknowledgements resent in-flight inputs')
    assert(match.pending[1]==nil and match.pending[2] and match.pending[3],
        'Acknowledgement discarded unresolved input or retained resolved input')
    assert(match:queueInput(0,1,0))
    match:flush()
    assert(#packets==4,'Acknowledgement blocked newly queued input')
    packetRange(packets[4],4,1)
    match:event('match.inputRejected',{
        matchId=match.id,roomId=match.roomId,accountId=USER.uid,
        code='INPUT_TOO_LATE',seq=2,expectedSeq=3,frame=180,
    })
    assert(#packets==4 and match.pending[2]==nil and match.pending[3] and match.pending[4],
        'A resolved rejection retransmitted or discarded the in-flight suffix')
    match:ack{acceptedThrough=4,expectedSeq=5}
    assert(next(match.pending)==nil and #packets==4,'Final acknowledgement left input queued for replay')

    match,packets=inputFixture(3)
    match:event('match.inputRejected',{
        matchId=match.id,roomId=match.roomId,accountId=USER.uid,
        code='INPUT_GAP',expectedSeq=2,frame=180,
    })
    assert(#packets==4,'An explicit sequence gap did not resend the missing suffix')
    packetRange(packets[4],2,2)

    local reports,reply
    match,packets,reports,reply=inputFixture(70)
    match:ack{acceptedThrough=1,expectedSeq=2}
    assert(#packets==70,'An ordinary acknowledgement started recovery')
    match:resume()
    reply{id=match.roomId,phase='playing'}
    assert(#packets==70,'The room reply replayed input before the recovery snapshot')
    match:event('match.snapshot',inputSnapshot(match,1))
    assert(#packets==71 and not match.recovering,'The recovery snapshot did not start outstanding replay')
    packetRange(packets[71],2,64)
    match:update()
    assert(#packets==72,'Reconnect lost the remainder beyond one bounded batch')
    packetRange(packets[72],66,5)
    match:event('match.snapshot',inputSnapshot(match,1))
    assert(#packets==72,'A periodic snapshot restarted the outstanding replay')
    match:ack{acceptedThrough=70,expectedSeq=71}
    match:update()
    assert(next(match.pending)==nil and #packets==72,'Recovery acknowledgement restarted the replay')

    match,packets,reports,reply=inputFixture(3)
    match.track='relay'
    match:resume()
    reply{id=match.roomId,phase='playing'}
    local catchup={matchId=match.id,roomId=match.roomId,frame=180,acceptedThrough=1,expectedSeq=2}
    match:event('match.catchupComplete',catchup)
    assert(#packets==4 and not match.recovering,'Relay catch-up did not recover the outstanding suffix')
    packetRange(packets[4],2,2)
    match:event('match.catchupComplete',catchup)
    assert(#packets==4,'Repeated catch-up completion replayed in-flight inputs')

    match,packets,reports,reply=inputFixture(2)
    match:resume()
    reply{id=match.roomId,phase='playing'}
    match:event('match.snapshot',inputSnapshot(match,99))
    assert(reports[1]=='INVALID_ACK' and #packets==2 and match.pending[1] and match.pending[2],
        'An invalid recovery acknowledgement changed the outstanding stream')

    match,packets=inputFixture(0)
    match.adoptingAck=true
    match:ack{acceptedThrough=41,expectedSeq=42}
    assert(match:queueInput(1,1,0))
    match:flush()
    assert(#packets==1,'A fresh process replayed input it did not retain')
    packetRange(packets[1],42,1)
    print('ONLINE_MATCH_INPUT_PASS')
end
local function verifyRejectedReleases()
    USER.uid=id(1)
    local function released(clientFrame)
        local match,packets=inputFixture(0)
        assert(match:press(1)) match:flush()
        match:ack{accountId=USER.uid,acceptedThrough=1,expectedSeq=2,frame=183}
        if clientFrame then match:observeFrame(clientFrame) end
        assert(match:release(1)) match:flush()
        return match,packets
    end
    local function reject(match,seq,code,frame)
        match:event('match.inputRejected',{matchId=match.id,roomId=match.roomId,accountId=USER.uid,
            code=code or 'INPUT_TOO_LATE',seq=seq,expectedSeq=seq+1,frame=frame or 198})
    end
    local function snapshot(match,through,down,frame)
        local data=inputSnapshot(match,through)
        data.frame,data.state.frame=frame or 204,frame or 204
        data.state.players[1].state.keyPressing[1]=down
        match:event('match.snapshot',data)
        match:update()
    end
    local function assertRelease(packet,seq,serverFrame)
        assert(packet,'A confirmed stuck key never received a release')
        packetRange(packet,seq,1)
        local frame=love.data.unpack('<I4',packet,29)
        assert(frame>serverFrame and frame<=serverFrame+12 and packet:byte(35)==0 and packet:byte(36)==1,
            'Reconciliation did not send a fresh, admissible release for the affected key')
        return frame
    end
    local match,packets=released()
    reject(match,2)
    snapshot(match,1,true)
    assert(#packets==2,'A stale snapshot released a key')
    snapshot(match,2,true)
    local frame=assertRelease(packets[3],3,204)
    reject(match,2) snapshot(match,2,true)
    assert(#packets==3,'A duplicate rejection or snapshot repeated a correction')
    reject(match,3,'INPUT_FRAME_CAPACITY',frame-1)
    snapshot(match,2,true,frame)
    assert(#packets==3,'A rejected correction was repeated before a covering snapshot')
    snapshot(match,3,true,frame)
    assertRelease(packets[4],4,frame)
    snapshot(match,4,false,frame+12)
    assert(#packets==4,'A settled correction was repeated')

    for _,code in ipairs{'INPUT_TOO_FAR','INPUT_CAPACITY'} do
        match,packets=released(209)
        local target=love.data.unpack('<I4',packets[2],29)
        local at=code=='INPUT_TOO_FAR' and target-13 or target-1
        reject(match,2,code,at)
        snapshot(match,2,true,at)
        assert(#packets==2,'A release was corrected before its intended frame')
        snapshot(match,2,true,target)
        assertRelease(packets[3],3,target)
    end

    match,packets=released()
    reject(match,2) snapshot(match,2,false)
    snapshot(match,2,true)
    assert(#packets==2,'A settled release was applied to a later hold')

    match,packets=released()
    reject(match,2)
    assert(match:press(1)) match:flush()
    snapshot(match,2,true)
    assert(#packets==3 and packets[3]:byte(35)==1,'Reconciliation released a newly pressed key')

    match,packets=released()
    assert(match:press(1) and match:release(1)) match:flush()
    reject(match,2) snapshot(match,2,true)
    assert(#packets==3,'A superseded rejection duplicated a newer in-flight release')

    match,packets=inputFixture(0)
    assert(match:press(1)) match:flush()
    reject(match,1) snapshot(match,1,false)
    assert(#packets==1,'A rejected press was synthesized')
    print('ONLINE_MATCH_REJECTED_RELEASE_PASS')
end
local function verifyInputRejectionRecovery()
    USER.uid=id(1)
    local match,packets=inputFixture(2)
    local rejection={
        matchId=match.id,roomId=match.roomId,accountId=USER.uid,
        code='CAPACITY_EXCEEDED',expectedSeq=2,frame=180,
    }
    match:event('match.inputRejected',rejection)
    match:event('match.inputRejected',rejection)
    assert(#packets==2,'Capacity rejection started an immediate retry loop')
    match:update()
    assert(#packets==3 and match.pending[2],'Capacity rejection stranded an unresolved input')
    packetRange(packets[3],2,1)
    assert(love.data.unpack('<I4',packets[3],29)==love.data.unpack('<I4',packets[2],29),
        'Capacity recovery changed the original input frame')
    match:update()
    assert(#packets==3,'Capacity recovery repeated without another rejection')

    match,packets=inputFixture(3)
    match:ack{acceptedThrough=1,expectedSeq=2}
    match:event('match.inputRejected',{
        matchId=match.id,roomId=match.roomId,code='SERVICE_UNAVAILABLE',
    })
    match:ack{acceptedThrough=2,expectedSeq=3}
    match:update()
    assert(#packets==4 and match.pending[2]==nil and match.pending[3],
        'A delayed acknowledgement blocked the remaining timeout recovery')
    packetRange(packets[4],3,1)

    match,packets=inputFixture(2)
    match:event('match.inputRejected',{
        matchId=match.id,roomId=match.roomId,code='CAPACITY_EXCEEDED',
    })
    match:ack{acceptedThrough=2,expectedSeq=3}
    assert(match:queueInput(1,1,0))
    match:update()
    assert(#packets==3,'An acknowledgement overtaking recovery blocked new input')
    packetRange(packets[3],3,1)

    match,packets=inputFixture(2)
    match:event('match.inputRejected',{
        matchId=match.id,roomId=match.roomId,accountId=id(2),
        code='CAPACITY_EXCEEDED',expectedSeq=3,frame=180,
    })
    match:update()
    assert(#packets==2 and match.pending[1] and match.pending[2],
        'Another participant rejection changed the local input stream')
    print('ONLINE_MATCH_REJECTION_RECOVERY_PASS')
end

local function verifyTerminalInput()
    USER.uid=id(1)
    for _,kind in ipairs{'match.participantEnded','match.completed','match.aborted','match.snapshot'} do
        local match,packets=inputFixture(0)
        local requests={}
        match.net.request=function(command) requests[#requests+1]=command return 'request' end
        assert(match:press(1))
        local event={matchId=match.id,roomId=match.roomId,accountId=USER.uid,frame=180}
        if kind=='match.snapshot' then
            match.recovering=true
            event=inputSnapshot(match,0)
            event.participants={{accountId=USER.uid,slot=1,status='ended',terminalFrame=180}}
        end
        match:event(kind,event)
        match:update()
        assert(#packets==0 and #requests==0,'A server terminal transition sent input or a new final boundary')
        assert(next(match.pending)==nil and next(match.held)==nil and not match:press(2),
            'A server terminal transition retained or admitted local input')
    end

    local match,packets=inputFixture(0)
    match:event('match.participantEnded',{matchId=match.id,roomId=match.roomId,accountId=id(2),frame=180})
    assert(match:press(1),'A peer terminal event disabled the local participant')
    local boundary
    match.net.request=function(command,data)
        assert(command=='match.finish' and #packets==1,'Local completion did not flush final input before its boundary')
        boundary=data
        return 'finish'
    end
    match:finishBoundary()
    packetRange(packets[1],1,2)
    assert(boundary.finalSeq==2 and next(match.held)==nil,'Local completion lost its final release')

    match,packets=inputFixture(0)
    match.track='relay'
    match.terminalFrames={}
    assert(match:press(1))
    match:event('match.participantEnded',{matchId=match.id,roomId=match.roomId,accountId=USER.uid,frame=180})
    match:flush()
    match:sendFinish()
    assert(match.terminalFrames[USER.uid]==180 and #packets==0 and match.finishRequested==true,
        'A relay terminal notification lost its terminal frame or reopened its input boundary')
    print('ONLINE_MATCH_TERMINAL_PASS')
end
local cases={
    {track='authoritative',count=2,own=1},
    {track='authoritative',count=2,own=2},
    {track='authoritative',count=10,own=10},
    {track='relay',count=3,own=2},
    {track='authoritative',count=2,own=0},
}
local function verify(case,participants)
    local match=NET.match
    local main=match.bySlot[case.own==0 and 1 or case.own]
    assert(match:isParticipant()==(case.own~=0),'Spectator identity changed')
    for index,member in ipairs(participants) do
        local P=PLAYERS[index]
        assert(P==match.bySlot[index] and P==match.byAccount[member.accountId],
            'Presentation reordered the frozen source roster')
        assert(P.uid==member.accountId and P.sid==member.slot,
            'Presentation changed an account or source slot')
        if P.alive then
            if P~=main then
                assert(main.size>P.size,'The local player does not own the primary board')
            end
        end
    end
    assert(main.size>.9,'The primary board did not finish its layout transition')
end
return function()
    verifyInputAcknowledgements()
    verifyInputRejectionRecovery()
    verifyRejectedReleases()
    verifyTerminalInput()
    SETTING.portrait=false
    for index,case in ipairs(cases) do
        NET.match:clear()
        USER.uid=id(case.own==0 and 1000 or case.own)
        local participants={}
        for slot=1,case.count do
            participants[slot]={accountId=id(slot),name='Perspective '..slot,slot=slot,team=0,tuning={}}
        end
        local roomId=id(100)
        NET.roomStore.snapshot={id=roomId}
        assert(NET.match:start{
            matchId=id(200+index),roomId=roomId,seed=12345,frame=0,
            track=case.track,authoritative=case.track=='authoritative',
            rulesetVersion='source-netBattle-default-v1',participants=participants,
            inputBufferFrames=6,readyFrames=180,
        },'The frozen match fixture was rejected')
        -- Exercise the complete reset, including its scheduled layout animation.
        TEST.yieldN(90)
        verify(case,participants)
        freshPlayerPosition('update')
        TEST.yieldN(90)
        verify(case,participants)
        if case.track=='relay' then
            NET.match.bySlot[1]:lose(true)
            TEST.yieldN(90)
            verify(case,participants)
        end
        freshPlayerPosition('quick')
        verify(case,participants)
        print(('ONLINE_MATCH_LAYOUT_CASE_PASS %s players=%d own=%d'):format(case.track,case.count,case.own))
    end
    NET.match:clear()
    NET.roomStore:clear()
    USER.uid=false
end
