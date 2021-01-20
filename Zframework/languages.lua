local langList,publicText={},{}
local LANG={}

--Call these before call LANG.init()
function LANG.setLangList(list)langList=list end
function LANG.setPublicText(L)publicText=L end

function LANG.init()--Attention, calling this will destory all initializing methods, create a LANG.set()!
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

	for i=1,#langList do
		local L=langList[i]

		--Set public text
		for key,list in next,publicText do
			L[key]=list
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

	LANG.init,LANG.setLangList,LANG.setPublicText=nil

	function LANG.set(l)
		text=langList[l]
		WIDGET.setLang(text.WidgetText)
		for k,v in next,drawableText do
			if text[k]then
				v:set(text[k])
			end
		end
	end

	function LANG.addScene(name)
		for i=1,#langList do
			if langList[i].WidgetText and not langList[i].WidgetText[name]then
				langList[i].WidgetText[name]={back=langList[i].back}
			end
		end
	end
end

return LANG