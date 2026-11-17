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
