local Json=require'parts.online.json'
local fs=love.filesystem
local function equal(expected,actual,path)
    assert(type(expected)==type(actual),path..' changed type')
    if type(expected)=='table' then
        for key,value in pairs(expected) do equal(value,actual[key],path..'.'..tostring(key)) end
        for key in pairs(actual) do assert(expected[key]~=nil,path..'.'..tostring(key)..' was added') end
    else assert(expected==actual,path..' changed value') end
end
local function persist(path,value,array)
    local bytes=assert(Json.encode(value,array),'Fixture JSON could not be encoded')
    assert(fs.write(path,bytes),'Fixture file could not be saved: '..path)
end
local function read(path)
    return assert(Json.decode(assert(fs.read(path))),'Fixture JSON could not be decoded: '..path)
end
local function view()
    return TABLE.copy{
        STAT={game=STAT.game,row=STAT.row,key=STAT.key,score=STAT.score,clear=STAT.clear,spin=STAT.spin,item=STAT.item},
        SETTING={das=SETTING.das,arr=SETTING.arr,ghost=SETTING.ghost,mainVol=SETTING.mainVol,showSpike=SETTING.showSpike,skin=SETTING.skin,face=SETTING.face},
        KEY_MAP=KEY_MAP,VK_ORG=VK_ORG,RANKS={sprint_40l=RANKS.sprint_40l},
    }
end
return function(phase)
    if phase=='restore' then
        STAT.game=6
        STAT.row,STAT.key,STAT.score=73,91,347
        STAT.clear[1][1],STAT.spin[29][7]=17,19
        STAT.item.gem,STAT.item.shard=13,2
        SETTING.das,SETTING.arr,SETTING.ghost,SETTING.mainVol=10,9,.71,.27
        SETTING.showSpike=false
        SETTING.skin[9],SETTING.face[5]=15,2
        KEY_MAP.keyboard.left,KEY_MAP.keyboard.right=1,2
        KEY_MAP.joystick.leftshoulder=15
        VK_ORG[2]={ava=false,x=370,y=625,r=70}
        RANKS.sprint_40l=4
        persist('conf/data',STAT)
        persist('conf/settings',SETTING)
        persist('conf/key',KEY_MAP)
        persist('conf/virtualkey',VK_ORG,true)
        persist('conf/unlock',RANKS)
        local previousStat,previousRanks=assert(fs.read('conf/data')),assert(fs.read('conf/unlock'))
        local expected=view()
        expected.STAT.game,expected.STAT.item.shard=10,7
        expected.SETTING.das=12
        expected.KEY_MAP.keyboard={q=20}
        expected.VK_ORG[1]={ava=true,x=140,y=380,r=65}
        local restored,message=NET.cloud:apply{
            STAT={game=10,item={shard=7}},SETTING={das=12},KEY_MAP={keyboard={q=20}},
            VK_ORG={{ava=true,x=140,y=380,r=65}},
        }
        assert(restored,message)
        equal(expected,view(),'restored memory')
        local savedStat,savedSettings,savedKeys,savedLayout=read('conf/data'),read('conf/settings'),read('conf/key'),read('conf/virtualkey')
        equal(expected.STAT,{game=savedStat.game,row=savedStat.row,key=savedStat.key,score=savedStat.score,clear=savedStat.clear,spin=savedStat.spin,item=savedStat.item},'saved statistics')
        equal(expected.SETTING,{das=savedSettings.das,arr=savedSettings.arr,ghost=savedSettings.ghost,mainVol=savedSettings.mainVol,showSpike=savedSettings.showSpike,skin=savedSettings.skin,face=savedSettings.face},'saved settings')
        equal(expected.KEY_MAP,savedKeys,'saved key maps')
        equal(expected.VK_ORG,savedLayout,'saved virtual keys')
        assert(fs.read('conf/unlock')==previousRanks,'An omitted section was rewritten')
        local backup=read(NET.cloud.backupPath)
        assert(love.data.decode('string','base64',backup.files['conf/data'])==previousStat,'The backup lost the exact pre-restore statistics file')
        persist('conf/cloud-restore-expected.json',expected)
    elseif phase=='reload' then
        equal(read('conf/cloud-restore-expected.json'),view(),'restarted client')
    else error('Unknown cloud restore regression phase') end
end
