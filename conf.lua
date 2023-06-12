SYSTEM=love._os if SYSTEM=='OS X' then SYSTEM='macOS' end
MOBILE=SYSTEM=='Android' or SYSTEM=='iOS'
FNNS=SYSTEM:find'\79\83'-- What does FNSF stand for? IDK so don't ask me lol

if SYSTEM=='Web' then
    local oldRead=love.filesystem.read
    function love.filesystem.read(name,size)
        if love.filesystem.getInfo(name) then
            return oldRead(name,size)
        end
    end
end

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

    local M=t.modules
    M.window,M.system,M.event,M.thread=true,true,true,true
    M.timer,M.math,M.data=true,true,true
    M.video,M.audio,M.sound=true,true,true
    M.graphics,M.font,M.image=true,true,true
    M.mouse,M.touch,M.keyboard,M.joystick=true,true,true,true
    M.physics=false

    local W=t.window
    W.vsync=0 -- Unlimited FPS
    W.msaa=msaa -- Multi-sampled antialiasing
    W.depth=0 -- Bits/samp of depth buffer
    W.stencil=1 -- Bits/samp of stencil buffer
    W.display=1 -- Monitor ID
    W.highdpi=true -- High-dpi mode for the window on a Retina display
    W.x,W.y=nil,nil -- Position of the window
    W.borderless=MOBILE -- Display window frame
    W.resizable=not MOBILE -- Whether window is resizable
    W.fullscreentype=MOBILE and "exclusive" or "desktop" -- Fullscreen type
    if portrait then
        W.width,W.height=720,1280
        W.minwidth,W.minheight=360,640
    else
        W.width,W.height=1280,720
        W.minwidth,W.minheight=640,360
    end
    W.title="Techmino "..require "version".string -- Window title
    if fs.getInfo('media/image/icon.png') then
        W.icon='media/image/icon.png'
    end
end
