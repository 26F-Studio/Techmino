local langList={
	require("LANG/lang_zh"),
	require("LANG/lang_zh2"),
	require("LANG/lang_en"),
	require("LANG/lang_fr"),
	require("LANG/lang_sp"),
	require("LANG/lang_symbol"),
	require("LANG/lang_yygq"),
	--Add new language file to LANG folder. Attention, new language won't show in-game when you add language
}
local publicText={
	block={
		"Z","S","J","L","T","O","I",
		"Z5","S5","Q","P","F","E",
		"T5","U","V","W","X",
		"J5","L5","R","Y","N","H","I5"
	},
}
local publicWidgetText={
	calculator={
		_1="1",_2="2",_3="3",
		_4="4",_5="5",_6="6",
		_7="7",_8="8",_9="9",
		_0="0",["."]=".",e="e",
		["+"]="+",["-"]="-",["*"]="*",["/"]="/",
		["<"]="<",["="]="=",
		play="-->",
	},
	staff={},
	history={
		prev="↑",
		next="↓",
	},
	lang={
		zh="中文",
		zh2="全中文",
		en="English",
		fr="Français",
		sp="Español",
		symbol="?????",
		yygq="就这?",
	},
}
local function langFallback(T0,T)
	for k,v in next,T0 do
		if type(v)=="table"and not v.noMerge then--noMerge=true : copy pointer instead of content
			if not T[k]then T[k]={}end
			if type(T[k])=="table"and not v[1]then langFallback(v,T[k])end
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
	if type(L.getTip)=="table"then
		setmetatable(L.getTip,tipMeta)
	end

	--set global name for all back button
	for _,v in next,L.WidgetText do
		v.back=L.back
	end
end

local drawableTextLoad={
	"anykey",
	"replaying",
	"next","hold",
	"win","finish","gameover","pause",

	"VKTchW","VKOrgW","VKCurW",
	"noScore","highScore",
}
local LANG={}
function LANG.getLen()
	return #langList
end
function LANG.set(l)
	text=langList[l]
	for S,L in next,Widgets do
		for _,W in next,L do
			W.text=text.WidgetText[S][W.name]
		end
	end
	for _,s in next,drawableTextLoad do
		drawableText[s]:set(text[s])
	end
	collectgarbage()
end
return LANG