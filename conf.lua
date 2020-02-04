function love.conf(t)
	local X=nil
	t.identity="Techmino"--The name of the save directory (string)
	t.appendidentity=X--Search files in source directory before save directory (boolean)
	t.version="11.1"
	t.console=X
	t.accelerometerjoystick=X--Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
	t.gammacorrect=true
	t.audio.mixwithsystem=true--Switch on to keep background music playing

	local W=t.window
	W.title="Techmino V0.65"
	W.icon="/image/icon.png"
	W.width,W.height=1280,720
	W.borderless=X
	W.resizable=true
	W.minwidth,W.minheight=640,360
	W.fullscreentype="desktop"--Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
	W.fullscreen=X
	W.vsync=X--0 to set ∞fps
	W.msaa=X--The number of samples to use with multi-sampled antialiasing (number)
	W.depth=X--The number of bits per sample in the depth buffer
	W.stencil=8--The number of bits per sample in the stencil buffer
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