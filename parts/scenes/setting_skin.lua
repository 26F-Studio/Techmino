local gc=love.graphics
local int=math.floor
local sin=math.sin

local minoRot={0,0,0,0,0,0,0}
local minoRot0={}

local scene={}

function scene.sceneInit()
	for i=1,7 do
		minoRot0[i]=SETTING.face[i]*1.57
		minoRot[i]=minoRot0[i]
	end
end

function scene.update()
	for i=1,7 do
		minoRot[i]=minoRot[i]*.8+minoRot0[i]*.2
	end
end
function scene.draw()
	local t=TIME()
	gc.setColor(1,1,1)
	local texture=SKIN.lib[SETTING.skinSet]
	for n=1,7 do
		gc.push('transform')
		gc.translate(-10+140*n,340)
		gc.rotate(minoRot[n]+sin(t*3-n*.5)*.08)
		local color=SETTING.skin[n]
		local B=BLOCKS[n][0]
		local x,y=-45-SCS[n][0][2]*30,15+SCS[n][0][1]*30
		local col=#B[1]
		for i=1,#B do for j=1,col do
			if B[i][j]then
				gc.draw(texture[color],x+30*j,y-30*i)
			end
		end end
		gc.circle('fill',0,0,sin(t*10)+5)
		gc.pop()
	end
	for i=1,5 do
		gc.draw(texture[19+i],570+60*i,610+sin(2.6*t-i)*5,nil,2)
	end
	gc.draw(texture[17],930,610+sin(2.6*t-6)*5,nil,2)
end

local function prevSkin(i)
	SETTING.skin[i]=(SETTING.skin[i]-2)%16+1
end
local function nextSkin(i)
	SETTING.skin[i]=SETTING.skin[i]%16+1
end
local function nextDir(i)
	SETTING.face[i]=(SETTING.face[i]+1)%4
	minoRot0[i]=minoRot0[i]+1.5707963
	if minoRot0[5]>62 then
		loadGame('marathon_bfmax',true)
	end
	SFX.play('rotate')
end

scene.widgetList={
	WIDGET.newText{name="title",	x=80,y=50,font=70,align='L'},

	WIDGET.newSelector{name="skinSet",x=780,y=100,w=260,list=SKIN.getList(),disp=SETval('skinSet'),code=SETsto('skinSet')},
	WIDGET.newButton{name="prev1",	x=130,y=230,w=90,h=65,fText="↑",code=function()prevSkin(1)end},
	WIDGET.newButton{name="prev2",	x=270,y=230,w=90,h=65,fText="↑",code=function()prevSkin(2)end},
	WIDGET.newButton{name="prev3",	x=410,y=230,w=90,h=65,fText="↑",code=function()prevSkin(3)end},
	WIDGET.newButton{name="prev4",	x=550,y=230,w=90,h=65,fText="↑",code=function()prevSkin(4)end},
	WIDGET.newButton{name="prev5",	x=690,y=230,w=90,h=65,fText="↑",code=function()prevSkin(5)end},
	WIDGET.newButton{name="prev6",	x=830,y=230,w=90,h=65,fText="↑",code=function()prevSkin(6)end},
	WIDGET.newButton{name="prev7",	x=970,y=230,w=90,h=65,fText="↑",code=function()prevSkin(7)end},

	WIDGET.newButton{name="next1",	x=130,y=450,w=90,h=65,fText="↓",code=function()nextSkin(1)end},
	WIDGET.newButton{name="next2",	x=270,y=450,w=90,h=65,fText="↓",code=function()nextSkin(2)end},
	WIDGET.newButton{name="next3",	x=410,y=450,w=90,h=65,fText="↓",code=function()nextSkin(3)end},
	WIDGET.newButton{name="next4",	x=550,y=450,w=90,h=65,fText="↓",code=function()nextSkin(4)end},
	WIDGET.newButton{name="next5",	x=690,y=450,w=90,h=65,fText="↓",code=function()nextSkin(5)end},
	WIDGET.newButton{name="next6",	x=830,y=450,w=90,h=65,fText="↓",code=function()nextSkin(6)end},
	WIDGET.newButton{name="next7",	x=970,y=450,w=90,h=65,fText="↓",code=function()nextSkin(7)end},

	WIDGET.newButton{name="spin1",	x=130,y=540,w=90,h=65,code=function()nextDir(1)end},
	WIDGET.newButton{name="spin2",	x=270,y=540,w=90,h=65,code=function()nextDir(2)end},
	WIDGET.newButton{name="spin3",	x=410,y=540,w=90,h=65,code=function()nextDir(3)end},
	WIDGET.newButton{name="spin4",	x=550,y=540,w=90,h=65,code=function()nextDir(4)end},
	WIDGET.newButton{name="spin5",	x=690,y=540,w=90,h=65,code=function()nextDir(5)end},
	--WIDGET.newButton{name="spin6",x=825,y=540,w=90,h=65,code=function()nextDir(6)end},--Cannot rotate O
	WIDGET.newButton{name="spin7",	x=970,y=540,w=90,h=65,code=function()nextDir(7)end},

	WIDGET.newButton{name="skinR",	x=200,y=640,w=220,h=80,color='lV',font=35,
		code=function()
			SETTING.skin={1,7,11,3,14,4,9,1,7,2,6,10,2,13,5,9,15,10,11,3,10,2,16,8,4,10,13,2,8}
			SFX.play('rotate')
		end},
	WIDGET.newButton{name="faceR",	x=480,y=640,w=220,h=80,color='lR',font=35,
		code=function()
			for i=1,29 do
				SETTING.face[i]=0
			end
			for i=1,7 do
				minoRot0[i]=(int(minoRot0[i]/6.2831853)+(minoRot0[i]%6.2831853>4 and 1 or 0))*6.2831853
			end
			SFX.play('hold')
		end},
	WIDGET.newButton{name="back",	x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene