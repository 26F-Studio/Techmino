local SKIN={}
function SKIN.init(list)
	local Skins={}

	local simpList={}
	for _,v in next,list do
		table.insert(simpList,v.name)
		Skins[v.name]=v.path
	end
	function SKIN.getList()return simpList end

	local gc=love.graphics
	local function C(x,y)
		local canvas=gc.newCanvas(x,y)
		gc.setCanvas(canvas)
		return canvas
	end

	SKIN.lib,SKIN.libMini={},{}
	local skinMeta={__index=function(self,name)
		gc.push()
		gc.origin()
		local f1,f2=gc.getDefaultFilter()
		gc.setDefaultFilter('nearest','nearest')
		local I
		local N=Skins[name]
		if love.filesystem.getInfo(N)then
			I=gc.newImage(N)
		else
			MES.new('warn',"No skin file: "..Skins[name])
		end
		gc.setDefaultFilter(f1,f2)

		SKIN.lib[name],SKIN.libMini[name]={},{}
		gc.setColor(1,1,1)
		for y=0,2 do
			for x=1,8 do
				SKIN.lib[name][8*y+x]=C(30,30)
				if I then gc.draw(I,30-30*x,-30*y)end

				SKIN.libMini[name][8*y+x]=C(6,6)
				if I then gc.draw(I,6-6*x,-6*y,nil,.2)end
			end
		end
		gc.setCanvas()
		gc.pop()
		return self[name]
	end}
	setmetatable(SKIN.lib,skinMeta)
	setmetatable(SKIN.libMini,skinMeta)

	function SKIN.loadAll()SKIN.loadAll=nil for _,v in next,list do local _=SKIN.lib[v.name]end end
end
return SKIN