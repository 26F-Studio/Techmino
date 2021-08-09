VERSION={
	build=356,
	code=1600,
	string="V0.16.0@DEV",
	room="V1.1",
	name="空间站 Space station",
}
function love.conf(t)
	t.identity='Techmino'--Saving folder
	t.version="11.1"
	t.gammacorrect=false
	t.appendidentity=true--Search files in source then in save directory
	t.accelerometerjoystick=false--Accelerometer=joystick on ios/android
	if t.audio then
		t.audio.mic=false
		t.audio.mixwithsystem=true
	end

	local W=t.window
	W.title="Techmino "..VERSION.string
	W.icon="media/image/icon.png"
	W.width,W.height=1280,720
	W.minwidth,W.minheight=640,360
	W.borderless=false
	W.resizable=true
	W.fullscreen=false
	W.vsync=0--Unlimited FPS
	W.msaa=10--Multi-sampled antialiasing
	W.depth=0--Bits/samp of depth buffer
	W.stencil=1--Bits/samp of stencil buffer
	W.display=1--Monitor ID
	W.highdpi=true--High-dpi mode for the window on a Retina display
	W.x,W.y=nil

	local M=t.modules
	M.window,M.system,M.event,M.thread=true,true,true,true
	M.timer,M.math,M.data=true,true,true
	M.video,M.audio,M.sound=true,true,true
	M.graphics,M.font,M.image=true,true,true
	M.mouse,M.touch,M.keyboard,M.joystick=true,true,true,true
	M.physics=false
end