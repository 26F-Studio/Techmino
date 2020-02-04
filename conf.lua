function love.conf(t)
	local X=nil
	t.identity="Techmino"--Save directory name
	t.appendidentity=X--If search files in source before save directory
	t.version="11.1"
	t.console=X
	t.accelerometerjoystick=X--If exposing accelerometer on iOS and Android as a Joystick
	t.gammacorrect=X
	t.audio.mixwithsystem=true--Switch on to keep sysBGM

	local W=t.window
	W.title="Techmino V0.7.10"
	W.icon="/image/icon.png"
	W.width,W.height=1280,720
	W.minwidth,W.minheight=640,360
	W.borderless=X
	W.resizable=true
	W.fullscreentype="desktop"--Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
	W.fullscreen=X
	W.vsync=X--0 to set ∞fps
	W.msaa=X--The number of samples to use with multi-sampled antialiasing (number)
	W.depth=X--Bits per sample in the depth buffer
	W.stencil=1--The number of bits per sample in the stencil buffer
	W.display=1--Monitor ID
	W.highdpi=X--Enable high-dpi mode for the window on a Retina display (boolean)
	W.x,W.y=nil

	local M=t.modules
	M.window=true
	M.system=true
	M.audio=true
	M.data=true
	M.event=true
	M.font=true
	M.graphics=true
	M.image=true
	M.joystick=true
	M.keyboard=true
	M.math=true
	M.mouse=true
	M.sound=true
	M.timer=true
	M.touch=true

	M.physics=X
	M.thread=X
	M.video=X
end