local gc=love.graphics
local gc_setColor=gc.setColor
local gc_draw,gc_rectangle=gc.draw,gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf

local setFont=setFont

local listBox=WIDGET.newListBox{name="list",x=50,y=50,w=1200,h=520,lineH=40,drawF=function(rep,id,ifSel)
	if ifSel then
		gc_setColor(1,1,1,.3)
		gc_rectangle('fill',0,0,1200,40)
	end

	setFont(30)
	gc_setColor(.8,.8,.8)
	gc_print(id,10,-2)

	if rep.available then
		gc_setColor(.9,.9,1)
		gc_print(rep.modeName,405,-2)
		setFont(20)
		gc_setColor(1,1,.8)
		gc_print(rep.date,80,6)
		gc_setColor(1,.4,.4,.6)
		gc_printf(rep.version,0,6,1190,'right')
		gc_setColor(1,1,1)
		gc_printf(rep.player,0,6,960,'right')
	else
		gc_setColor(.6,.6,.6)
		gc_print(rep.fileName,80,-2)
	end
end}

local scene={}

local sure

local function readLine(str)
	local p=str:find("\n")
	return str:sub(1,p-1),str:sub(p+1)
end
local function replay(rep)
	if not rep.available then
		MES.new('error',text.replayBroken)
	elseif MODES[rep.mode]then
		local data=love.data.decompress('string','zlib',rep.data)
		local seed,setting,mod

		seed,data=readLine(data)
		GAME.seed=tonumber(seed)

		setting,data=readLine(data)
		GAME.setting=JSON.decode(setting)

		mod,data=readLine(data)
		GAME.mod=JSON.decode(mod)

		GAME.rep={}
		DATA.pumpRecording(data,GAME.rep)

		loadGame(rep.mode,true)
		resetGameData('r')
		GAME.init=false
		GAME.saved=true
	else
		MES.new('error',("No mode id: [%s]"):format(rep.mode))
	end
end

function scene.sceneInit()
	sure=0
	local repList={}
	for i=#REPLAY,1,-1 do
		local file=love.filesystem.newFile(REPLAY[i])
		if file:open('r')then
			local metadata=""
			local enter=0
			while true do
				local b,len=file:read(1)
				if len==0 then
					file:close()
					repList[i]={
						fileName=REPLAY[i],
						available=false,
					}
					break
				end
				metadata=metadata..b
				if b=="\n"then
					enter=enter+1
					if enter==4 then
						metadata=STRING.split(metadata,'\n')
						local mode=text.modes[metadata[2]]or{"["..metadata[2].."]",""}
						repList[i]={
							fileName=REPLAY[i],
							available=true,
							date=metadata[1],
							mode=metadata[2],
							modeName=("%s  %s"):format(mode[1],mode[2]),
							version=metadata[3],
							player=metadata[4],
							data=file:read(),
						}
						file:close()
						break
					end
				end
			end
		else
			repList[i]={
				fileName=REPLAY[i],
				available=false,
			}
		end
	end
	listBox:setList(repList)
end

function scene.keyDown(key)
	if key=="return"then
		replay(listBox:getSel())
	elseif key=="escape"then
		SCN.back()
	elseif key=="delete"then
		if sure>20 then
			local rep=listBox:getSel()
			if rep then
				sure=0
				listBox:remove()
				love.filesystem.remove(rep.fileName)

				local i=TABLE.find(REPLAY,rep.fileName)
				if i then table.remove(REPLAY,i)end
				FILE.save(REPLAY,'conf/replay')

				SFX.play('finesseError',.7)
			end
		else
			sure=50
		end
	else
		WIDGET.keyPressed(key)
	end
end

function scene.update()
	if sure>0 then sure=sure-1 end
end

function scene.draw()
	--Confirm delete
	if sure>0 then
		gc_setColor(1,1,1,sure*.02)
		gc_draw(TEXTURE.sure,910,610)
	end
end

scene.widgetList={
	listBox,
	WIDGET.newButton{name="play",x=700,y=640,w=170,h=80,color='lY',code=pressKey"return",hideF=function()return listBox:getLen()==0 end,fText=DOGC{50,50,{'fPoly',10,0,49,24,10,49}}},
	WIDGET.newButton{name="delete",x=850,y=640,w=80,h=80,color='lR',code=pressKey"delete",hideF=function()return listBox:getLen()==0 end,fText=DOGC{50,50,{'setLW',8},{'line',5,5,45,45},{'line',5,45,45,5}}},
	WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene