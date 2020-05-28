gameVersion="Alpha V0.8.22"
function love.conf(t)
	t.identity="Techmino"--folder name
	t.version="11.1"
	t.console=false
	t.gammacorrect=false
	t.appendidentity=true--search files in source before save directory
	t.accelerometerjoystick=false--accelerometer=joystick on ios/android
	t.audio.mixwithsystem=true

	local W=t.window
	W.title="Techmino "..gameVersion
	W.icon="/image/icon.png"
	W.width,W.height=1280,720
	W.minwidth,W.minheight=640,360
	W.borderless=false
	W.resizable=true
	W.fullscreentype="desktop"--"exclusive"
	W.fullscreen=false
	W.vsync=0--infinite fps
	W.msaa=false--num of samples to use with multi-sampled antialiasing
	W.depth=0--bits/samp of depth buffer
	W.stencil=1--bits/samp of stencil buffer
	W.display=1--monitor ID
	W.highdpi=false--high-dpi mode for the window on a Retina display
	W.x,W.y=nil

	local M=t.modules
	M.window,M.system,M.event=true,true,true
	M.audio,M.sound=true,true
	M.math,M.data=true,true
	M.timer,M.graphics,M.font,M.image=true,true,true,true
	M.mouse,M.touch,M.keyboard,M.joystick=true,true,true,true
	M.physics,M.thread,M.video=false,false,false
end