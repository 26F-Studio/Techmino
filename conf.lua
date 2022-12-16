SYSTEM=love._os if SYSTEM=='OS X' then SYSTEM='macOS' end
MOBILE=SYSTEM=='Android' or SYSTEM=='iOS'
FNNS=SYSTEM:find'\79\83'-- What does FNSF stand for? IDK so don't ask me lol

local _mobileFullscreen=true
local _msaa=0
if love.filesystem.getInfo('conf/settings') then
    local fileData=love.filesystem.read('conf/settings')
    if type(fileData)=='string' then
        if MOBILE and fileData:find('"portrait":true') then
            _mobileFullscreen=false
        end
        if fileData:find('"msaa":') then
            print(1)
            local num=tonumber(fileData:match('"msaa":(%d+)'))
            print(num)
            if num then _msaa=num end
        end
    end
end

function love.conf(t)
    t.identity='Techmino' -- Saving folder
    t.version="11.4"
    t.gammacorrect=false
    t.appendidentity=true -- Search files in source then in save directory
    t.accelerometerjoystick=false -- Accelerometer=joystick on ios/android
    if t.audio then
        t.audio.mic=false
        t.audio.mixwithsystem=true
    end

    local W=t.window
    W.title="Techmino "..require "version".string
    W.width,W.height=1280,720
    W.minwidth,W.minheight=640,360

    W.vsync=0 -- Unlimited FPS
    W.msaa=_msaa -- Multi-sampled antialiasing
    W.depth=0 -- Bits/samp of depth buffer
    W.stencil=1 -- Bits/samp of stencil buffer
    W.display=1 -- Monitor ID
    W.highdpi=true -- High-dpi mode for the window on a Retina display
    W.x,W.y=nil,nil -- Position of the window
    if love.filesystem.getInfo('media/image/icon.png') then
        W.icon='media/image/icon.png'
    end
    if MOBILE then
        W.borderless=true
        W.resizable=false
        W.fullscreen=_mobileFullscreen
    else
        W.borderless=false
        W.resizable=true
        W.fullscreen=false
    end

    local M=t.modules
    M.window,M.system,M.event,M.thread=true,true,true,true
    M.timer,M.math,M.data=true,true,true
    M.video,M.audio,M.sound=true,true,true
    M.graphics,M.font,M.image=true,true,true
    M.mouse,M.touch,M.keyboard,M.joystick=true,true,true,true
    M.physics=false
end
