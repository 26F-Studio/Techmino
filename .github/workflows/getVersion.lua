if arg[1]=="-code"then
	print(require"version".apkCode)
elseif arg[1]=="-name"then
	print((require"version".string:gsub("@DEV","")))
elseif arg[1]=="-release"then
	print((require"version".string:gsub("V","")))
elseif arg[1]=="-updateTitle"then
	local note=require"parts.updateLog"
	local p1=note:find("\n%d")+1
	local p2=note:find("\n",p1)-1
	note=note:sub(p1,p2)
	print(note)
elseif arg[1]=="-updateNote"then
	local note=require"parts.updateLog"
	local p1=note:find("\n",note:find("\n%d")+1)+1
	local p2=note:find("\n%d",p1+1)
	note=note:sub(p1,p2-2)
	note=note
		:gsub("\t\t\t\t","_")
		:gsub("\t\t","")
		:gsub("\n([^_])","\n\n%1")
		:gsub("\n_","\n")
		:gsub("\n\n","\n",1)
	print(note)
end