local gc=love.graphics
local mStr=mStr
local ins=table.insert

local scene={}

local selected--if waiting for key
local keyList

local function freshKeyList()
	keyList={}for i=0,20 do keyList[i]={}end
	for k,v in next,keyMap.keyboard do
		ins(keyList[v],{COLOR.lB,k})
	end
	for k,v in next,keyMap.joystick do
		ins(keyList[v],{COLOR.lR,k})
	end
end

function scene.sceneInit()
	selected=false
	freshKeyList()
	BG.set('none')
end
function scene.sceneBack()
	FILE.save(keyMap,'conf/key')
end

local forbbidenKeys={
	["\\"]=true,
	["return"]=true,
}
function scene.keyDown(key)
	if key=="escape"then
		if selected then
			for k,v in next,keyMap.keyboard do
				if v==selected then
					keyMap.keyboard[k]=nil
				end
			end
			freshKeyList()
			selected=false
			SFX.play('finesseError',.5)
		else
			SCN.back()
		end
	elseif selected then
		if not forbbidenKeys[key]then
			keyMap.keyboard[key]=selected
			freshKeyList()
			selected=false
			SFX.play('reach',.5)
		end
	else
		WIDGET.keyPressed(key)
	end
end
function scene.gamepadDown(key)
	if key=="back"then
		if selected then
			for k,v in next,keyMap.joystick do
				if v==selected then
					keyMap.joystick[k]=nil
				end
			end
			freshKeyList()
			selected=false
			SFX.play('finesseError',.5)
		else
			SCN.back()
		end
	elseif selected then
		keyMap.joystick[key]=selected
		freshKeyList()
		selected=false
		SFX.play('reach',.5)
	else
		WIDGET.gamepadPressed(key)
	end
end

function scene.draw()
	setFont(15)
	gc.setColor(1,1,1)

	for i=0,20 do
		for j=1,#keyList[i]do
			local key=keyList[i][j]
			local font=#key[2]==1 and 40 or #key[2]<6 and 30 or 15
			setFont(font)
			mStr(key,
				(i>10 and 940 or 210)+100*j,
				i>10 and 60*(i-10)-23-font*.7 or
				i>0 and 60*i-23-font*.7 or
				667-font*.7
			)
		end
	end

	if selected then
		gc.setColor(COLOR[TIME()%.26<.13 and'R'or'Y'])
		local x,y=selected>10 and 910 or 270, selected>10 and 60*(selected-10)-50 or selected>0 and 60*selected-50 or 630
		setFont(40)gc.print("=",x,y)
		setFont(10)gc.print("esc?",x,y+40)
	end
end

local function setSel(i)
	if selected==i then
		selected=false
		SFX.play('rotate',.5)
	else
		selected=i
		SFX.play('lock',.5)
	end
end
scene.widgetList={
	WIDGET.newKey{name="a1",x=160,y=40,w=200,h=60,code=function()setSel(1)end},
	WIDGET.newKey{name="a2",x=160,y=100,w=200,h=60,code=function()setSel(2)end},
	WIDGET.newKey{name="a3",x=160,y=160,w=200,h=60,code=function()setSel(3)end},
	WIDGET.newKey{name="a4",x=160,y=220,w=200,h=60,code=function()setSel(4)end},
	WIDGET.newKey{name="a5",x=160,y=280,w=200,h=60,code=function()setSel(5)end},
	WIDGET.newKey{name="a6",x=160,y=340,w=200,h=60,code=function()setSel(6)end},
	WIDGET.newKey{name="a7",x=160,y=400,w=200,h=60,code=function()setSel(7)end},
	WIDGET.newKey{name="a8",x=160,y=460,w=200,h=60,code=function()setSel(8)end},
	WIDGET.newKey{name="a9",x=160,y=520,w=200,h=60,code=function()setSel(9)end},
	WIDGET.newKey{name="a10",x=160,y=580,w=200,h=60,code=function()setSel(10)end},

	WIDGET.newKey{name="a11",x=800,y=40,w=200,h=60,code=function()setSel(11)end},
	WIDGET.newKey{name="a12",x=800,y=100,w=200,h=60,code=function()setSel(12)end},
	WIDGET.newKey{name="a13",x=800,y=160,w=200,h=60,code=function()setSel(13)end},
	WIDGET.newKey{name="a14",x=800,y=220,w=200,h=60,code=function()setSel(14)end},
	WIDGET.newKey{name="a15",x=800,y=280,w=200,h=60,code=function()setSel(15)end},
	WIDGET.newKey{name="a16",x=800,y=340,w=200,h=60,code=function()setSel(16)end},
	WIDGET.newKey{name="a17",x=800,y=400,w=200,h=60,code=function()setSel(17)end},
	WIDGET.newKey{name="a18",x=800,y=460,w=200,h=60,code=function()setSel(18)end},
	WIDGET.newKey{name="a19",x=800,y=520,w=200,h=60,code=function()setSel(19)end},
	WIDGET.newKey{name="a20",x=800,y=580,w=200,h=60,code=function()setSel(20)end},

	WIDGET.newKey{name="restart",x=160,y=670,w=200,h=60,code=function()setSel(0)end},

	WIDGET.newButton{name="back",x=1140,y=640,w=190,h=80,fText=TEXTURE.back,code=backScene},
}

return scene