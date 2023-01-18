return {
    version=VERSION.code,

    -- Basic
    drop=1e99,
    lock=1e99,
    wait=0,
    fall=0,
    hang=5,
    hurry=1e99,

    -- Control
    nextCount=6,
    holdMode='hold',
    holdCount=1,
    infHold=true,
    phyHold=false,

    -- Visual
    bone=false,

    -- Rule
    sequence='bag',
    lockout=false,
    fieldH=20,
    heightLimit=1e99,
    bufferLimit=1e99,

    ospin=true,
    fineKill=false,
    b2bKill=false,
    easyFresh=true,
    deepDrop=false,
    visible='show',
    freshLimit=1e99,

    opponent="X",
    life=0,
    pushSpeed=3,
    garbageSpeed=1,
    missionKill=false,

    -- Else
    bg='blockrain',
    bgm='hang out',

    eventSet="X",
}
