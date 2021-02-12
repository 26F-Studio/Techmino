local find=string.find
local tabs={
	[0]="",
	"\t",
	"\t\t",
	"\t\t\t",
	"\t\t\t\t",
	"\t\t\t\t\t",
}
function dumpTable(L,t)
	local s
	if t then
		s="{\n"
	else
		s="return{\n"
		t=1
		if type(L)~="table"then
			return
		end
	end
	local count=1
	for k,v in next,L do
		local T=type(k)
		if T=="number"then
			if k==count then
				k=""
				count=count+1
			else
				k="["..k.."]="
			end
		elseif T=="string"then
			if find(k,"[^0-9a-zA-Z_]")then
				k="[\""..k.."\"]="
			else
				k=k.."="
			end
		elseif T=="boolean"then k="["..k.."]="
		else error("Error key type!")
		end
		T=type(v)
		if T=="number"then v=tostring(v)
		elseif T=="string"then v="\""..v.."\""
		elseif T=="table"then v=dumpTable(v,t+1)
		elseif T=="boolean"then v=tostring(v)
		else error("Error data type!")
		end
		s=s..tabs[t]..k..v..",\n"
	end
	return s..tabs[t-1].."}"
end