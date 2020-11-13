local gc=love.graphics
local int=math.floor

function sceneInit.setting_control()
	sceneTemp={
		das=SETTING.das,
		arr=SETTING.arr,
		pos=0,
		dir=1,
		wait=30,
	}
	BG.set("bg1")
end

function Tmr.setting_control()
	local T=sceneTemp
	if T.wait>0 then
		T.wait=T.wait-1
		if T.wait==0 then
			T.pos=T.pos+T.dir
		else
			return
		end
	end
	if T.das>0 then
		T.das=T.das-1
		if T.das==0 then
			if T.arr==0 then
				T.pos=T.pos+7*T.dir
				T.das=SETTING.das+1
				T.arr=SETTING.arr
				T.dir=-T.dir
				T.wait=26
			else
				T.pos=T.pos+T.dir
			end
		end
	else
		T.arr=T.arr-1
		if T.arr==0 then
			T.pos=T.pos+T.dir
			T.arr=SETTING.arr
		elseif T.arr==-1 then
			T.pos=T.dir>0 and 8 or 0
			T.arr=SETTING.arr
		end
		if T.pos%8==0 then
			T.dir=-T.dir
			T.wait=26
			T.das=SETTING.das
		end
	end
end

function Pnt.setting_control()
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
	local x=550+40*sceneTemp.pos
	gc.draw(O,x,540,nil,40/30)
	gc.draw(O,x,580,nil,40/30)
	gc.draw(O,x+40,540,nil,40/30)
	gc.draw(O,x+40,580,nil,40/30)
end

local function sliderShow(S)
	S=S.disp()
	return S.."F "..int(S*16.67).."ms"
end
WIDGET.init("setting_control",{
	WIDGET.newText({name="title",	x=80,	y=50,font=70,align="L"}),
	WIDGET.newText({name="preview",	x=520,	y=540,font=40,align="R"}),

	WIDGET.newSlider({name="das",	x=250,	y=200,w=910,unit=26,disp=WIDGET.lnk_SETval("das"),	show=sliderShow,code=WIDGET.lnk_SETsto("das")}),
	WIDGET.newSlider({name="arr",	x=250,	y=290,w=525,unit=15,disp=WIDGET.lnk_SETval("arr"),	show=sliderShow,code=WIDGET.lnk_SETsto("arr")}),
	WIDGET.newSlider({name="sddas",	x=250,	y=380,w=350,unit=10,disp=WIDGET.lnk_SETval("sddas"),show=sliderShow,code=WIDGET.lnk_SETsto("sddas")}),
	WIDGET.newSlider({name="sdarr",	x=250,	y=470,w=140,unit=4,	disp=WIDGET.lnk_SETval("sdarr"),show=sliderShow,code=WIDGET.lnk_SETsto("sdarr")}),
	WIDGET.newSwitch({name="ihs",	x=1100,	y=290,				disp=WIDGET.lnk_SETval("ihs"),	code=WIDGET.lnk_SETrev("ihs")}),
	WIDGET.newSwitch({name="irs",	x=1100,	y=380,				disp=WIDGET.lnk_SETval("irs"),	code=WIDGET.lnk_SETrev("irs")}),
	WIDGET.newSwitch({name="ims",	x=1100,	y=470,				disp=WIDGET.lnk_SETval("ims"),	code=WIDGET.lnk_SETrev("ims")}),
	WIDGET.newButton({name="reset",	x=160,	y=580,w=200,h=100,color="lRed",font=40,
		code=function()
			local _=SETTING
			_.das,_.arr=10,2
			_.sddas,_.sdarr=0,2
			_.ihs,_.irs,_.ims=false,false,false
		end}),
	WIDGET.newButton({name="back",	x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK}),
})