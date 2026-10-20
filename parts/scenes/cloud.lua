local scene={}
local cloud=NET.cloud
local serial=-1
local confirmation=false
local function confirm(action,message)
    if confirmation and confirmation.action==action and love.timer.getTime()<confirmation.untilTime then confirmation=false return true end
    confirmation={action=action,untilTime=love.timer.getTime()+2}
    MES.new('warn',message,2)
end
local versions=WIDGET.newListBox{x=40,y=135,w=1080,h=310,lineH=60,drawF=function(version,index,selected)
    if selected then love.graphics.setColor(1,1,1,.2) love.graphics.rectangle('fill',0,0,1080,60) end
    love.graphics.setColor(1,1,1)
    FONT.set(24)
    love.graphics.printf(index..'. revision '..version.revision..' / '..version.createdAt..' / '..version.bytes..' bytes',12,2,1060,'left')
    FONT.set(16)
    love.graphics.printf(version.id,12,34,1060,'left')
end}
local function restore()
    local selected=versions:getSel()
    if selected and confirm('restore:'..selected.id,'Press Restore again within two seconds to replace these offline save sections after creating a local backup.') then cloud:restore(selected.id) end
end
function scene.enter()
    serial=-1
    confirmation=false
    if NET.session:isAuthenticated() then cloud:list() end
end
function scene.keyDown(key,rep)
    if rep then return true end
    if key=='escape' then SCN.back() elseif key=='r' then cloud:list() else return true end
end
function scene.update()
    if serial~=cloud.serial then versions:setList(cloud.versions) serial=cloud.serial end
end
function scene.draw()
    FONT.set(22)
    love.graphics.setColor(1,1,1)
    love.graphics.printf('Original seven save sections + custom boards, missions and sequences.\nCredentials, executable Lua, avatar caches and replays are excluded.\nAt most five immutable versions are retained; offline statistics are not authoritative rankings.',40,470,1160,'left')
    love.graphics.printf('Cloud: '..cloud.status..' / current revision: '..tostring(cloud.revision or '--'),40,90,1160,'left')
    if cloud.conflict then
        love.graphics.setColor(1,.65,.2)
        love.graphics.printf('CONFLICT: another device wrote revision '..cloud.conflict.revision..'.\nChoose a version to restore (after local backup), explicitly keep and upload the local candidate, or cancel.',40,560,1160,'left')
    elseif cloud.backupPath then
        love.graphics.printf('Latest local pre-restore backup: '..cloud.backupPath,40,560,1160,'left')
    elseif not NET.session:isAuthenticated() then love.graphics.printf('Sign in to the separate Techmino product session to use cloud saves.',40,560,1160,'left') end
end
scene.widgetList={
    WIDGET.newText{x=40,y=30,align='L',font=45,fText='Cloud save versions'},versions,
    WIDGET.newButton{x=200,y=650,w=280,h=80,font=25,fText='Upload local save',code=function() cloud:upload() end,hideF=function() return not NET.session:isAuthenticated() or cloud.conflict~=false end},
    WIDGET.newButton{x=200,y=650,w=280,h=80,font=25,fText='Keep and upload local',color='R',code=function()
        if cloud.conflict and confirm('keep:'..cloud.conflict.revision,'Press again within two seconds to upload the captured local save over this cloud revision.') then cloud:keepLocal() end
    end,hideF=function() return not cloud.conflict end},
    WIDGET.newButton{x=500,y=650,w=280,h=80,font=25,fText='Restore selected version',code=restore,hideF=function() return not NET.session:isAuthenticated() or #cloud.versions==0 end},
    WIDGET.newButton{x=800,y=650,w=260,h=80,font=25,fText='Refresh versions',code=function() cloud:list() end,hideF=function() return not NET.session:isAuthenticated() or cloud.conflict~=false end},
    WIDGET.newButton{x=800,y=650,w=260,h=80,font=25,fText='Cancel conflict',code=function() cloud:cancelConflict() end,hideF=function() return not cloud.conflict end},
    WIDGET.newButton{x=200,y=650,w=280,h=80,font=25,fText='Product login',code=NET.openOnline,hideF=function() return NET.session:isAuthenticated() end},
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene
