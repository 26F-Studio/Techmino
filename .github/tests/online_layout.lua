local function id(value)
    return ('00000000-0000-4000-8000-%012x'):format(value)
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
        print(('ONLINE_LAYOUT_CASE_PASS %s players=%d own=%d'):format(case.track,case.count,case.own))
    end
    NET.match:clear()
    NET.roomStore:clear()
    USER.uid=false
end
