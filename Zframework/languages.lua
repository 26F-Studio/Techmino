local function langFallback(T0,T)
	for k,v in next,T0 do
		if type(v)=="table"and not v.refuseCopy then--refuseCopy: just copy pointer, not contents
			if not T[k]then T[k]={}end
			if type(T[k])=="table"then langFallback(v,T[k])end
		elseif not T[k]then
			T[k]=v
		end
	end
end
local tipMeta={__call=function(L)return L[math.random(#L)]end}

local langList={}
local publicText,publicWidgetText={},{}

local LANG={}

--Must call before LANG.init
function LANG.setLangList(list)langList=list end
function LANG.setPublicText(L)publicText=L end
function LANG.setPublicWidgetText(L)publicWidgetText=L end

function LANG.init()
	for i=1,#langList do
		local L=langList[i]
	
		--Set public text
		for key,list in next,publicText do
			L[key]=list
		end
	
		--Set public widget text
		for key,list in next,publicWidgetText do
			local WT=L.WidgetText
			if not WT[key]then WT[key]={}end
			for k,v in next,list do
				WT[key][k]=v
			end
		end
	
		--Fallback to other language, default zh
		if i>1 then
			langFallback(langList[L.fallback or 1],L)
		end
	
		--Metatable:__call for table:getTip
		if type(rawget(L,"getTip"))=="table"then
			setmetatable(L.getTip,tipMeta)
		end
	
		--set global name for all back button
		for _,v in next,L.WidgetText do
			v.back=L.back
		end
	end
	LANG.init=nil
end

function LANG.set(l)
	text=langList[l]
	WIDGET.setLang(text.WidgetText)
	for _,s in next,drawableTextLoad do
		drawableText[s]:set(text[s])
	end
end

return LANG