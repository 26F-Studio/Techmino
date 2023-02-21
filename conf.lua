SYSTEM=love._os if SYSTEM=='OS X' then SYSTEM='macOS' end
MOBILE=SYSTEM=='Android' or SYSTEM=='iOS'
FNNS=SYSTEM:find'\79\83'-- What does FNSF stand for? IDK so don't ask me lol

function love.conf(t)
    local identity='Techmino'
    local msaa=0
    local portrait=false

    local fs=love.filesystem
    fs.setIdentity(identity)
    do -- Load grapgic settings from conf/settings
        local fileData=fs.read('conf/settings')
        if fileData then
            msaa=tonumber(fileData:match('"msaa":(%d+)')) or 0;
            portrait=MOBILE and fileData:find('"portrait":true') and true
        end
    end

    t.identity=identity -- Saving folder
    t.version="11.4"
    t.gammacorrect=false
    t.appendidentity=true -- Search files in source then in save directory
    t.accelerometerjoystick=false -- Accelerometer=joystick on ios/android
    if t.audio then
        t.audio.mic=false
        t.audio.mixwithsystem=true
    end

    t.window.title="Techmino "..require "version".string
    t.window.vsync=0 -- Unlimited FPS
    t.window.msaa=msaa -- Multi-sampled antialiasing
    t.window.depth=0 -- Bits/samp of depth buffer
    t.window.stencil=1 -- Bits/samp of stencil buffer
    t.window.display=1 -- Monitor ID
    t.window.highdpi=true -- High-dpi mode for the window on a Retina display
    t.window.x,t.window.y=nil,nil -- Position of the window
    t.window.borderless=MOBILE -- Display window frame
    t.window.resizable=not MOBILE -- Whether window is resizable
    t.window.fullscreen=MOBILE -- Fullscreen mode
    if portrait then
        t.window.width,t.window.height=720,1280
        t.window.minwidth,t.window.minheight=360,640
    else
        t.window.width,t.window.height=1280,720
        t.window.minwidth,t.window.minheight=640,360
    end
    if fs.getInfo('media/image/icon.png') then
        t.window.icon='media/image/icon.png'
    end

    local M=t.modules
    M.window,M.system,M.event,M.thread=true,true,true,true
    M.timer,M.math,M.data=true,true,true
    M.video,M.audio,M.sound=true,true,true
    M.graphics,M.font,M.image=true,true,true
    M.mouse,M.touch,M.keyboard,M.joystick=true,true,true,true
    M.physics=false
end
