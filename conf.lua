VERSION={
	build=344,
	code=1506,
	short="V0.15.6",
	string="Alpha Fork V0.15.6",
	room="V1.0",
	name="强化装甲 Reinforced Armor",
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
	W.msaa=false--Num of samples to use with multi-sampled antialiasing
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