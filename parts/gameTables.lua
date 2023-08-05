-- Static data tables
BLOCK_NAMES={
    'Z','S','J','L','T','O','I',
    'Z5','S5','P','Q','F','E',
    'T5','U','V','W','X',
    'J5','L5','R','Y','N','H','I5',
    'I3','C','I2','O1'
}
BLOCK_CHARS={} for i=1,#BLOCK_NAMES do BLOCK_CHARS[i]=CHAR.mino[BLOCK_NAMES[i]] end
BLOCK_COLORS={
    COLOR.R,COLOR.F,COLOR.O,COLOR.Y,COLOR.L,COLOR.J,COLOR.G,COLOR.A,
    COLOR.C,COLOR.N,COLOR.S,COLOR.B,COLOR.V,COLOR.P,COLOR.M,COLOR.W,
    COLOR.dH,COLOR.D,COLOR.lY,COLOR.H,COLOR.lH,COLOR.dV,COLOR.dR,COLOR.dG,
}
RANK_CHARS={'B','A','S','U','X'} for i=1,#RANK_CHARS do RANK_CHARS[i]=CHAR.icon['rank'..RANK_CHARS[i]] end
RANK_COLORS={
    {.8,.86,.9},
    {.6,.9,.7},
    {.93,.93,.65},
    {1,.5,.4},
    {.95,.5,.95},
}
GROUP_COLORS={
    [0]=COLOR.Z,
    [1]={STRING.hexColor'e57373'},
    [2]={STRING.hexColor"4caf50"},
    [3]={STRING.hexColor'5c6bc0'},
    [4]={STRING.hexColor'ffe082'},
    [5]={STRING.hexColor'ba68c8'},
    [6]={STRING.hexColor'80deea'},
}

do-- SVG_TITLE_FILL, SVG_TITLE_LINE
    SVG_TITLE_FILL={
        {
            0,0,
            0,34,
            63,34,
            63,227,
            97,227,
            97,34,
            160,34,
            160,0,
        },
        {
            126,60,
            244,60,
            244,94,
            160,94,
            160,127,
            230,127,
            230,161,
            160,161,
            160,194,
            244,194,
            244,227,
            126,227,
        },
        {
            262,82,
            283,60,
            385,60,
            385,94,
            296,94,
            296,194,
            385,194,
            385,227,
            283,227,
            262,206,
        },
        {
            404,60,
            437,60,
            437,127,
            505,127,
            505,60,
            538,60,
            538,227,
            505,227,
            505,161,
            437,161,
            437,227,
            404,227,
        },
        {
            558,60,
            604,60,
            640,153,
            676,60,
            722,60,
            722,227,
            688,227,
            688,108,
            655,194,
            625,194,
            591,108,
            591,227,
            558,227,
        },
        {
            743,60,
            777,60,
            777,227,
            743,227,
        },
        {
            798,60,
            831,60,
            899,173,
            899,60,
            933,60,
            933,227,
            899,227,
            831,115,
            831,227,
            798,227,
        },
        {
            950,82,
            971,60,
            1064,60,
            1085,82,
            1085,206,
            1064,227,
            971,227,
            950,206,
            950,82,

            984,94,
            984,194,
            1051,194,
            1051,94,
            984,94,
        },
    }
    for _,C in next,SVG_TITLE_FILL do
        for i=1,#C do
            C[i]=C[i]*.94
        end
    end

    SVG_TITLE_LINE=TABLE.shift(SVG_TITLE_FILL)
    SVG_TITLE_LINE[8],SVG_TITLE_LINE[9]={},{}
    for j=1,16 do SVG_TITLE_LINE[8][j]=SVG_TITLE_FILL[8][j] end
    for j=19,#SVG_TITLE_FILL[8]-2 do SVG_TITLE_LINE[9][j-18]=SVG_TITLE_FILL[8][j] end
end
do-- SVG_TITLE_FAN
    SVG_TITLE_FAN={}
    local sin,cos=math.sin,math.cos
    for i=1,9 do
        local L=TABLE.copy(SVG_TITLE_LINE[i])
        SVG_TITLE_FAN[i]=L
        for j=1,#L,2 do
            local x,y=L[j],L[j+1]-- 0<x<988, 290<y<1280
            x,y=-(x+280)*.002,(y-580)*.9-- X=ang, Y=dist
            x,y=y*cos(x),-y*sin(x)-- Rec-Pol-Rec
            L[j],L[j+1]=x,y+300
        end
    end
end
do-- MISSIONENUM
    ENUM_MISSION={
        _1=01,_2=02,_3=03,_4=04,
        A1=05,A2=06,A3=07,A4=08,
        PC=09,
        Z1=11,Z2=12,Z3=13,
        S1=21,S2=22,S3=23,
        J1=31,J2=32,J3=33,
        L1=41,L2=42,L3=43,
        T1=51,T2=52,T3=53,
        O1=61,O2=62,O3=63,O4=64,
        I1=71,I2=72,I3=73,I4=74,
    }
    local L={}
    for k,v in next,ENUM_MISSION do L[v]=k end
    for k,v in next,L do ENUM_MISSION[k]=v end
end
do-- TEXTOBJ
    local function T(s,t) return love.graphics.newText(getFont(s),t) end
    TEXTOBJ={
        modeName=T(30),

        win=T(120),
        lose=T(120),

        finish=T(90),
        gamewin=T(90),
        gameover=T(90),
        pause=T(90),

        speedLV=T(20),
        piece=T(25),line=T(25),atk=T(20),eff=T(20),
        rpm=T(35),tsd=T(35),
        grade=T(25),techrash=T(25),
        wave=T(30),nextWave=T(30),
        combo=T(20),maxcmb=T(20),
        pc=T(20),ko=T(25),

        noScore=T(45),highScore=T(30),modeLocked=T(45),
    }
end
do-- BLOCKS
    local O,_=true,false
    BLOCKS={
        -- Tetromino
        {{_,O,O},{O,O,_}},-- Z
        {{O,O,_},{_,O,O}},-- S
        {{O,O,O},{O,_,_}},-- J
        {{O,O,O},{_,_,O}},-- L
        {{O,O,O},{_,O,_}},-- T
        {{O,O},{O,O}},    -- O
        {{O,O,O,O}},      -- I

        -- Pentomino
        {{_,O,O},{_,O,_},{O,O,_}},-- Z5
        {{O,O,_},{_,O,_},{_,O,O}},-- S5
        {{O,O,O},{O,O,_}},        -- P
        {{O,O,O},{_,O,O}},        -- Q
        {{_,O,_},{O,O,O},{O,_,_}},-- F
        {{_,O,_},{O,O,O},{_,_,O}},-- E
        {{O,O,O},{_,O,_},{_,O,_}},-- T5
        {{O,O,O},{O,_,O}},        -- U
        {{O,O,O},{_,_,O},{_,_,O}},-- V
        {{_,O,O},{O,O,_},{O,_,_}},-- W
        {{_,O,_},{O,O,O},{_,O,_}},-- X
        {{O,O,O,O},{O,_,_,_}},    -- J5
        {{O,O,O,O},{_,_,_,O}},    -- L5
        {{O,O,O,O},{_,O,_,_}},    -- R
        {{O,O,O,O},{_,_,O,_}},    -- Y
        {{_,O,O,O},{O,O,_,_}},    -- N
        {{O,O,O,_},{_,_,O,O}},    -- H
        {{O,O,O,O,O}},            -- I5

        -- Trimino
        {{O,O,O}},    -- I3
        {{O,O},{_,O}},-- C

        -- Domino
        {{O,O}},-- I2

        -- Dot
        {{O}},-- O1
    }
    local function _RotCW(B)
        local N={}
        local r,c=#B,#B[1]-- row,col
        for x=1,c do
            N[x]={}
            for y=1,r do
                N[x][y]=B[y][c-x+1]
            end
        end
        return N
    end
    for i=1,#BLOCKS do
        local B=BLOCKS[i]
        BLOCKS[i]={[0]=B}
        for j=1,3 do
            B=_RotCW(B)
            BLOCKS[i][j]=B
        end
    end
end
MODE_UPDATE_MAP={
    attacker_hard="attacker_h",
    attacker_ultimate="attacker_u",
    blind_easy="blind_e",
    blind_hard="blind_h",
    blind_lunatic="blind_l",
    blind_normal="blind_n",
    blind_ultimate="blind_u",
    c4wtrain_lunatic="c4wtrain_l",
    c4wtrain_normal="c4wtrain_n",
    defender_lunatic="defender_l",
    defender_normal="defender_n",
    dig_100="dig_100l",
    dig_10="dig_10l",
    dig_400="dig_400l",
    dig_40="dig_40l",
    dig_hard="dig_h",
    dig_ultimate="dig_u",
    drought_lunatic="drought_l",
    drought_normal="drought_n",
    marathon_hard="marathon_h",
    marathon_normal="marathon_n",
    pcchallenge_hard="pc_h",
    pcchallenge_lunatic="pc_l",
    pcchallenge_normal="pc_n",
    pctrain_lunatic="pctrain_l",
    pctrain_normal="pctrain_n",
    round_1="round_e",
    round_2="round_h",
    round_3="round_l",
    round_4="round_n",
    round_5="round_u",
    solo_1="solo_e",
    solo_2="solo_h",
    solo_3="solo_l",
    solo_4="solo_n",
    solo_5="solo_u",
    sprint_10="sprint_10l",
    sprint_20="sprint_20l",
    sprint_40="sprint_40l",
    sprint_400="sprint_400l",
    sprint_100="sprint_100l",
    sprint_1000="sprint_1000l",
    survivor_easy="survivor_e",
    survivor_hard="survivor_h",
    survivor_lunatic="survivor_l",
    survivor_normal="survivor_n",
    survivor_ultimate="survivor_u",
    tech_finesse2="tech_finesse_f",
    tech_hard2="tech_h_plus",
    tech_hard="tech_h",
    tech_lunatic2="tech_l_plus",
    tech_lunatic="tech_l",
    tech_normal2="tech_n_plus",
    tech_normal="tech_n",
    techmino49_easy="techmino49_e",
    techmino49_hard="techmino49_h",
    techmino49_ultimate="techmino49_u",
    techmino99_easy="techmino99_e",
    techmino99_hard="techmino99_h",
    techmino99_ultimate="techmino99_u",
    tsd_easy="tsd_e",
    tsd_hard="tsd_h",
    tsd_ultimate="tsd_u",
    GM="master_ex",
    master_beginner="master_l",
    master_advance="master_u",
    master_phantasm="master_ph",
    master_extra="master_ex",
}
EVENTSETS={
    'X',
    'attacker_h','attacker_u',
    'backfire_120','backfire_60','backfire_30','backfire_0',
    'checkAttack_100',
    'checkLine_10','checkLine_20','checkLine_40','checkLine_100','checkLine_200','checkLine_400','checkLine_1000',
    'classic_e','classic_h','classic_l','classic_u',
    'defender_n','defender_l',
    'dig_10l','dig_40l','dig_100l','dig_400l',
    'dig_h','dig_u',
    'marathon_n','marathon_h',
    'master_n','master_h','master_final','master_m','master_ex','master_ph',
    'pctrain_n','pctrain_l','pc_inf',
    'survivor_e','survivor_n','survivor_h','survivor_l','survivor_u',
    'tsd_e','tsd_h','tsd_u',
    'ultra',
}

do-- Mod data
    local function _disableKey(P,key)
        table.insert(P.gameEnv.keyCancel,key)
    end
    MODOPT={-- Mod options
        {no=0,id="NX",name="next",
            key="q",x=80,y=230,color='lO',
            list={0,1,2,3,4,5,6},
            func=function(P,O) P.gameEnv.nextCount=O end,
            unranked=true,
        },
        {no=1,id="HL",name="hold",
            key="w",x=200,y=230,color='lO',
            list={0,1,2,3,4,5,6},
            func=function(P,O) P.gameEnv.holdCount=O end,
            unranked=true,
        },
        {no=2,id="FL",name="hideNext",
            key="e",x=320,y=230,color='lA',
            list={1,2,3,4,5},
            func=function(P,O) P.gameEnv.nextStartPos=O+1 end,
            unranked=true,
        },
        {no=3,id="IH",name="infHold",
            key="r",x=440,y=230,color='lA',
            func=function(P) P.gameEnv.infHold=true end,
            unranked=true,
        },
        {no=4,id="HB",name="hideBlock",
            key="y",x=680,y=230,color='lV',
            func=function(P) P.gameEnv.block=false end,
            unranked=true,
        },
        {no=5,id="HG",name="hideGhost",
            key="u",x=800,y=230,color='lV',
            func=function(P) P.gameEnv.ghost=false end,
            unranked=true,
        },
        {no=6,id="HD",name="hidden",
            key="i",x=920,y=230,color='lP',
            list={'easy','slow','medium','fast','none'},
            func=function(P,O) P.gameEnv.visible=O end,
            unranked=true,
        },
        {no=7,id="HB",name="hideBoard",
            key="o",x=1040,y=230,color='lP',
            list={'down','up','all'},
            func=function(P,O) P.gameEnv.hideBoard=O  end,
            unranked=true,
        },
        {no=8,id="FB",name="flipBoard",
            key="p",x=1160,y=230,color='lJ',
            list={'U-D','L-R','180'},
            func=function(P,O) P.gameEnv.flipBoard=O  end,
            unranked=true,
        },

        {no=9,id="DT",name="dropDelay",
            key="a",x=140,y=350,color='lR',
            list={0,.125,.25,.5,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
            func=function(P,O) P.gameEnv.drop=O end,
            unranked=true,
        },
        {no=10,id="LT",name="lockDelay",
            key="s",x=260,y=350,color='lR',
            list={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
            func=function(P,O) P.gameEnv.lock=O end,
            unranked=true,
        },
        {no=11,id="ST",name="waitDelay",
            key="d",x=380,y=350,color='lR',
            list={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
            func=function(P,O) P.gameEnv.wait=O end,
            unranked=true,
        },
        {no=12,id="CT",name="fallDelay",
            key="f",x=500,y=350,color='lR',
            list={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
            func=function(P,O) P.gameEnv.fall=O end,
            unranked=true,
        },
        {no=13,id="LF",name="life",
            key="j",x=860,y=350,color='lY',
            list={0,1,2,3,5,10,15,26,42,87,500},
            func=function(P,O) P.gameEnv.life=O end,
            unranked=true,
        },
        {no=14,id="FB",name="forceB2B",
            key="k",x=980,y=350,color='lY',
            func=function(P) P.gameEnv.b2bKill=true end,
            unranked=true,
        },
        {no=15,id="PF",name="forceFinesse",
            key="l",x=1100,y=350,color='lY',
            func=function(P) P.gameEnv.fineKill=true end,
            unranked=true,
        },

        {no=16,id="TL",name="tele",
            key="z",x=200,y=470,color='lH',
            func=function(P)
                P.gameEnv.das,P.gameEnv.arr=0,0
                P.gameEnv.sddas,P.gameEnv.sdarr=0,0
            end,
            unranked=true,
        },
        {no=17,id="FX",name="noRotation",
            key="x",x=320,y=470,color='lH',
            func=function(P)
                _disableKey(P,3)
                _disableKey(P,4)
                _disableKey(P,5)
            end,
            unranked=true,
        },
        {no=18,id="GL",name="noMove",
            key="c",x=440,y=470,color='lH',
            func=function(P)
                _disableKey(P,1)_disableKey(P,2)
                _disableKey(P,11)_disableKey(P,12)
                _disableKey(P,17)_disableKey(P,18)
                _disableKey(P,19)_disableKey(P,20)
            end,
            unranked=true,
        },
        {no=19,id="CS",name="customSeq",
            key="b",x=680,y=470,color='lB',
            list={'bag','bagES','his','hisPool','c2','bagP1inf','rnd','mess','reverb'},
            func=function(P,O) P.gameEnv.sequence=O end,
            unranked=true,
        },
        {no=20,id="PS",name="pushSpeed",
            key="n",x=800,y=470,color='lB',
            list={.5,1,2,3,5,15,1e99},
            func=function(P,O) P.gameEnv.pushSpeed=O end,
            unranked=true,
        },
        {no=21,id="BN",name="boneBlock",
            key="m",x=920,y=470,color='lB',
            list={'on','off'},
            func=function(P,O) P.gameEnv.bone=O=='on' end,
            unranked=true,
        },
    }
    for i=1,#MODOPT do
        local M=MODOPT[i]
        M.sel,M.time=0,0
        M.color=COLOR[M.color]
    end
end
do-- Game data tables
    PLAYERS={}-- Players data
    PLY_ALIVE={}
    FIELD={}-- Field(s) for custom game
    BAG={}-- Sequence for custom game
    MISSION={}-- Clearing mission for custom game
    GAME={-- Global game data
        playing=false,      -- If in-game
        init=false,         -- If need initializing game when enter scene-play
        net=false,          -- If play net game

        result=false,       -- Game result (string)
        rank=0,             -- Rank reached
        pauseTime=0,        -- Time paused
        pauseCount=0,       -- Pausing count
        warnLVL0=0,         -- Warning level
        warnLVL=0,          -- Warning level (show)

        seed=1046101471,    -- Game seed
        curMode=false,      -- Current gamemode object
        mod={},             -- List of loaded mods
        modeEnv=false,      -- Current gamemode environment
        setting={},         -- Game settings
        rep={},             -- Recording list, key,time,key,time...
        statSaved=true,     -- If recording saved
        recording=false,    -- If recording
        replaying=false,    -- If replaying
        saved=false,        -- If recording saved
        tasUsed=false,      -- If tasMode used

        prevBG=false,       -- Previous background, for restore BG when quit setting page

        -- Data for royale mode
        stage=false,        -- Game stage
        mostBadge=false,    -- Most badge owner
        secBadge=false,     -- Second badge owner
        mostDangerous=false,-- Most dangerous player
        secDangerous=false, -- Second dangerous player
    }
    ROYALEDATA={
        powerUp=false,
        stage=false,
    }
    CUSTOMENV={}
    ROOMENV={
        -- Room config
        capacity=10,

        -- Basic
        drop=30,lock=60,
        wait=0,fall=0,
        hang=5,hurry=1e99,

        -- Control
        nextCount=6,
        holdMode='hold',
        holdCount=1,
        infHold=false,
        phyHold=false,

        -- Visual
        bone=false,

        -- Rule
        life=0,
        pushSpeed=5,
        garbageSpeed=2,
        visible='show',
        freshLimit=15,

        fieldH=20,
        heightLimit=1e99,
        bufferLimit=1e99,

        ospin=true,
        fineKill=false,
        b2bKill=false,
        easyFresh=true,
        deepDrop=false,

        eventSet="X",
    }
    REPLAY={}-- Replay objects (not include stream data)
end
do-- Userdata tables
    USER=setmetatable({-- User infomation
        __data={
            uid=false,
            aToken=false,
            oToken=false,
        },
    },{
        __index=function(self,k)
            return self.__data[k]
        end,
        __newindex=function(self,k,v)
            if self.__data[k]~=nil and v~=nil then
                self.__data[k]=v
            end
        end,
    })
    SETTING={-- Settings
        -- Tuning
        das=10,arr=2,
        dascut=0,dropcut=0,
        sddas=0,sdarr=2,
        ihs=true,irs=true,ims=true,
        holdMode='hold',
        RS='TRS',

        -- System
        reTime=2,
        allowTAS=false,
        autoPause=true,
        menuPos='middle',
        fine=false,
        autoSave=false,
        simpMode=false,
        sysCursor=true,
        maxFPS=60,
        frameMul=100,
        locale='zh',
        skinSet='crystal_scf',
        skin={
            1,7,11,3,14,4,9,
            1,7,2,6,10,2,13,5,9,15,4,11,3,12,2,16,8,4,
            10,13,2,8
        },
        face={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},

        -- Graphic
        ghostType='gray',
        block=true,ghost=.3,center=1,
        smooth=true,grid=.16,lineNum=.5,
        upEdge=true,
        bagLine=false,
        lockFX=2,
        dropFX=2,
        moveFX=2,
        clearFX=2,
        splashFX=2,
        shakeFX=2,
        atkFX=2,
        cleanCanvas=false,
        blockSatur='normal',
        fieldSatur='normal',

        text=true,
        score=true,
        bufferWarn=true,
        showSpike=true,
        highCam=true,
        nextPos=true,
        fullscreen=SYSTEM~='Web',
        portrait=false,
        msaa=0,
        bg='on',
        bgAlpha=.26,
        powerInfo=false,
        clickFX=true,
        warn=true,

        -- Sound
        autoMute=true,
        sfxPack='chiptune',
        vocPack='miya',
        mainVol=1,
        sfx=1,
        sfx_spawn=0,
        sfx_warn=.4,
        bgm=.7,
        stereo=.7,
        vib=0,
        voc=0,

        -- Virtualkey
        VKSFX=.2,-- SFX volume
        VKVIB=0,-- VIB
        VKSwitch=false,-- If disp
        VKSkin=1,-- If disp
        VKTrack=false,-- If tracked
        VKDodge=false,-- If dodge
        VKTchW=.3,-- Touch-Pos Weight
        VKCurW=.4,-- Cur-Pos Weight
        VKIcon=true,-- If disp icon
        VKAlpha=.3,
    }
    KEY_MAP={-- Key setting
        keyboard={
            left=1,right=2,x=3,z=4,c=5,
            up=6,down=7,space=8,a=9,s=10,
            r=0,
        },
        joystick={
            dpleft=1,dpright=2,b=3,a=4,y=5,
            dpup=6,dpdown=7,rightshoulder=8,x=9,
            leftshoulder=0,
        },
    }
    VK_ORG={-- Virtualkey layout, refresh all VKs' position with this before each game
        {ava=true,  x=80,      y=720-200,r=80},-- moveLeft
        {ava=true,  x=320,     y=720-200,r=80},-- moveRight
        {ava=true,  x=1280-80, y=720-200,r=80},-- rotRight
        {ava=true,  x=1280-200,y=720-80, r=80},-- rotLeft
        {ava=true,  x=1280-200,y=720-320,r=80},-- rot180
        {ava=true,  x=200,     y=720-320,r=80},-- hardDrop
        {ava=true,  x=200,     y=720-80, r=80},-- softDrop
        {ava=true,  x=1280-320,y=720-200,r=80},-- hold
        {ava=true,  x=80,      y=280,    r=80},-- func1
        {ava=true,  x=1280-80, y=280,    r=80},-- func2
        {ava=false, x=670,     y=50,     r=30},-- insLeft
        {ava=false, x=730,     y=50,     r=30},-- insRight
        {ava=false, x=790,     y=50,     r=30},-- insDown
        {ava=false, x=850,     y=50,     r=30},-- down1
        {ava=false, x=910,     y=50,     r=30},-- down4
        {ava=false, x=970,     y=50,     r=30},-- down10
        {ava=false, x=1030,    y=50,     r=30},-- dropLeft
        {ava=false, x=1090,    y=50,     r=30},-- dropRight
        {ava=false, x=1150,    y=50,     r=30},-- zangiLeft
        {ava=false, x=1210,    y=50,     r=30},-- zangiRight
    }
    RANKS={sprint_10l=0}-- Ranks of modes
    STAT={
        version=VERSION.code,
        run=0,game=0,time=0,frame=0,
        key=0,rotate=0,hold=0,
        extraPiece=0,finesseRate=0,
        piece=0,row=0,dig=0,
        atk=0,digatk=0,
        send=0,recv=0,pend=0,off=0,
        clear=(function() local L={} for i=1,29 do L[i]={0,0,0,0,0,0} end return L end)(),
        spin=(function() local L={} for i=1,29 do L[i]={0,0,0,0,0,0,0} end return L end)(),
        pc=0,hpc=0,b2b=0,b3b=0,score=0,
        lastPlay='sprint_10l',-- Last played mode ID
        item=setmetatable({},{__index=function(self,k)
            self[k]=0
            return 0
        end}),
        date=false,
        todayTime=0,
    }
end
