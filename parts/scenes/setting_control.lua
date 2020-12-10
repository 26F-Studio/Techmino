local gc=love.graphics
local int=math.floor

local scene={}

local das,arr
local pos,dir,wait

function scene.sceneInit()
	das,arr=SETTING.das,SETTING.arr
	pos,dir,wait=0,1,30
	BG.set("bg1")
end

function scene.update()
	if wait>0 then
		wait=wait-1
		if wait==0 then
			pos=pos+dir
		else
			return
		end
	end
	if das>0 then
		das=das-1
		if das==0 then
			if arr==0 then
				pos=pos+7*dir
				das=SETTING.das+1
				arr=SETTING.arr
				dir=-dir
				wait=26
			else
				pos=pos+dir
			end
		end
	else
		arr=arr-1
		if arr==0 then
			pos=pos+dir
			arr=SETTING.arr
		elseif arr==-1 then
			pos=dir>0 and 8 or 0
			arr=SETTING.arr
		end
		if pos%8==0 then
			dir=-dir
			wait=26
			das=SETTING.das
		end
	end
end

function scene.draw()
	--Testing grid line
	gc.setLineWidth(4)
	gc.setColor(1,1,1,.4)
	gc.line(550,540,950,540)
	gc.line(550,580,950,580)
	gc.line(550,620,950,620)
	for x=590,910,40 do
		gc.line(x,530,x,630)
	end
	gc.setColor(1,1,1)
	gc.line(550,530,550,630)
	gc.line(950,530,950,630)

	--O mino animation
	local O=SKIN.curText[SETTING.skin[6]]
	local x=550+40*pos
	gc.draw(O,x,540,nil,40/30)
	gc.draw(O,x,580,nil,40/30)
	gc.draw(O,x+40,540,nil,40/30)
	gc.draw(O,x+40,580,nil,40/30)
end

local function sliderShow(S)
	S=S.disp()
	return S.."F "..int(S*16.67).."ms"
end
scene.widgetList={
	WIDGET.newText{name="title",	x=80,	y=50,font=70,align="L"},
	WIDGET.newText{name="preview",	x=520,	y=540,font=40,align="R"},

	WIDGET.newSlider{name="das",	x=250,	y=190,w=600,unit=20,disp=WIDGET.lnk_SETval("das"),	show=sliderShow,code=WIDGET.lnk_SETsto("das")},
	WIDGET.newSlider{name="arr",	x=250,	y=260,w=525,unit=15,disp=WIDGET.lnk_SETval("arr"),	show=sliderShow,code=WIDGET.lnk_SETsto("arr")},
	WIDGET.newSlider{name="sddas",	x=250,	y=330,w=350,unit=10,disp=WIDGET.lnk_SETval("sddas"),show=sliderShow,code=WIDGET.lnk_SETsto("sddas")},
	WIDGET.newSlider{name="sdarr",	x=250,	y=400,w=140,unit=4,	disp=WIDGET.lnk_SETval("sdarr"),show=sliderShow,code=WIDGET.lnk_SETsto("sdarr")},
	WIDGET.newSlider{name="dascut",	x=250,	y=470,w=600,unit=20,disp=WIDGET.lnk_SETval("dascut"),show=sliderShow,code=WIDGET.lnk_SETsto("dascut")},
	WIDGET.newSwitch{name="ihs",	x=1100,	y=260,				disp=WIDGET.lnk_SETval("ihs"),	code=WIDGET.lnk_SETrev("ihs")},
	WIDGET.newSwitch{name="irs",	x=1100,	y=330,				disp=WIDGET.lnk_SETval("irs"),	code=WIDGET.lnk_SETrev("irs")},
	WIDGET.newSwitch{name="ims",	x=1100,	y=400,				disp=WIDGET.lnk_SETval("ims"),	code=WIDGET.lnk_SETrev("ims")},
	WIDGET.newButton{name="reset",	x=160,	y=580,w=200,h=100,color="lRed",font=40,
		code=function()
			local _=SETTING
			_.das,_.arr,_.dascut=10,2,0
			_.sddas,_.sdarr=0,2
			_.ihs,_.irs,_.ims=false,false,false
		end},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene