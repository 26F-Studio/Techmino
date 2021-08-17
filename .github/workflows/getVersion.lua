if arg[1]=="-code"then
	print(require"version".apkCode)
elseif arg[1]=="-string"then
	print((require"version".string:gsub("@DEV","")))
elseif arg[1]=="-updateNote"then
	local note=require"parts.updateLog"
	local p1=note:find("\n%d")
	local p2=note:find("\n%d",p1+1)
	note=note:sub(p1,p2-2)
	note=note:gsub("\t\t\t\t","_")
	note=note:gsub("\t\t","")
	note=note:gsub("\n([^_])","\n\n%1")
	note=note:gsub("\n_","\n")
	note=note:gsub("\n\n","\n",1)
	print(note)
end