local gc=love.graphics
local Timer=love.timer.getTime
local sin=math.sin

function Pnt.setting_skin()
	gc.setColor(1,1,1)
	for N=1,7 do
		local face=SETTING.face[N]
		local B=blocks[N][face]
		local x,y=-55+140*N-spinCenters[N][face][2]*30,355+spinCenters[N][face][1]*30
		local col=#B[1]
		for i=1,#B do for j=1,col do
			if B[i][j]then
				gc.draw(blockSkin[SETTING.skin[N]],x+30*j,y-30*i)
			end
		end end
		gc.circle("fill",-10+140*N,340,sin(Timer()*10)+5)
	end
	gc.draw(blockSkin[17],930,610,nil,2)
	for i=1,5 do
		gc.draw(blockSkin[19+i],570+60*i,610,nil,2)
	end
end

local function prevSkin(n)return function()SKIN.prev(n)end end
local function nextSkin(n)return function()SKIN.next(n)end end
local function nextDir(n)return function()SKIN.rotate(n)end end

WIDGET.init("setting_skin",{
	WIDGET.newText({name="title",	x=80,y=50,font=70}),

	WIDGET.newButton({name="prev",	x=700,y=100,w=140,h=100,font=50,code=function()SKIN.prevSet()end}),
	WIDGET.newButton({name="next",	x=860,y=100,w=140,h=100,font=50,code=function()SKIN.nextSet()end}),
	WIDGET.newButton({name="prev1",	x=130,y=230,w=90,h=65,code=prevSkin(1)}),
	WIDGET.newButton({name="prev2",	x=270,y=230,w=90,h=65,code=prevSkin(2)}),
	WIDGET.newButton({name="prev3",	x=410,y=230,w=90,h=65,code=prevSkin(3)}),
	WIDGET.newButton({name="prev4",	x=550,y=230,w=90,h=65,code=prevSkin(4)}),
	WIDGET.newButton({name="prev5",	x=690,y=230,w=90,h=65,code=prevSkin(5)}),
	WIDGET.newButton({name="prev6",	x=830,y=230,w=90,h=65,code=prevSkin(6)}),
	WIDGET.newButton({name="prev7",	x=970,y=230,w=90,h=65,code=prevSkin(7)}),

	WIDGET.newButton({name="next1",	x=130,y=450,w=90,h=65,code=nextSkin(1)}),
	WIDGET.newButton({name="next2",	x=270,y=450,w=90,h=65,code=nextSkin(2)}),
	WIDGET.newButton({name="next3",	x=410,y=450,w=90,h=65,code=nextSkin(3)}),
	WIDGET.newButton({name="next4",	x=550,y=450,w=90,h=65,code=nextSkin(4)}),
	WIDGET.newButton({name="next5",	x=690,y=450,w=90,h=65,code=nextSkin(5)}),
	WIDGET.newButton({name="next6",	x=830,y=450,w=90,h=65,code=nextSkin(6)}),
	WIDGET.newButton({name="next7",	x=970,y=450,w=90,h=65,code=nextSkin(7)}),

	WIDGET.newButton({name="spin1",	x=130,y=540,w=90,h=65,code=nextDir(1)}),
	WIDGET.newButton({name="spin2",	x=270,y=540,w=90,h=65,code=nextDir(2)}),
	WIDGET.newButton({name="spin3",	x=410,y=540,w=90,h=65,code=nextDir(3)}),
	WIDGET.newButton({name="spin4",	x=550,y=540,w=90,h=65,code=nextDir(4)}),
	WIDGET.newButton({name="spin5",	x=690,y=540,w=90,h=65,code=nextDir(5)}),
	--WIDGET.newButton({name="spin6",x=825,y=540,w=90,h=65,code=nextDir(6)}),--Cannot rotate O
	WIDGET.newButton({name="spin7",	x=970,y=540,w=90,h=65,code=nextDir(7)}),

	WIDGET.newButton({name="skinR",	x=200,y=640,w=220,h=80,color="lPurple",font=35,
		code=function()
			SETTING.skin={1,7,11,3,14,4,9,1,7,1,7,11,3,14,4,9,14,9,11,3,11,3,1,7,4}
			SFX.play("rotate")
		end}),
	WIDGET.newButton({name="faceR",	x=480,y=640,w=220,h=80,color="lRed",font=35,
		code=function()
			for i=1,25 do
				SETTING.face[i]=0
			end
			SFX.play("hold")
		end}),
	WIDGET.newButton({name="back",		x=1140,y=640,w=170,h=80,font=40,code=WIDGET.lnk.BACK}),
})