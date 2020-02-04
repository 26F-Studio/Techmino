gameVersion="Alpha V0.7.27+"
function love.conf(t)
	t.identity="Techmino"--Save directory name
	t.version="11.1"
	t.console=X
	t.gammacorrect=X
	t.appendidentity=X--If search files in source before save directory
	t.accelerometerjoystick=X--If exposing accelerometer on iOS and Android as a Joystick
	t.audio.mixwithsystem=true--Switch on to keep sysBGM

	local W=t.window
	W.title=math.random()>.01 and "Techmino "..gameVersion or"MrZ NB!"
	W.icon="/image/icon.png"
	W.width,W.height=1280,720
	W.minwidth,W.minheight=640,360
	W.borderless=X
	W.resizable=1
	W.fullscreentype="desktop"--"exclusive"
	W.fullscreen=X
	W.vsync=X--0→∞fps
	W.msaa=X--The number of samples to use with multi-sampled antialiasing (number)
	W.depth=X--Bits per sample in the depth buffer
	W.stencil=1--The number of bits per sample in the stencil buffer
	W.display=1--Monitor ID
	W.highdpi=X--Enable high-dpi mode for the window on a Retina display (boolean)
	W.x,W.y=nil

	local M=t.modules
	M.window,M.system,M.event=1,1,1
	M.audio,M.sound=1,1
	M.math,M.data=1,1
	M.timer,M.graphics,M.font,M.image=1,1,1,1
	M.mouse,M.touch,M.keyboard,M.joystick=1,1,1,1
	M.physics,M.thread,M.video=X
end