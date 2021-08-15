if arg[1]=="-code"then
	print (require"version".apkCode)
elseif arg[1]=="-string"then
	print ((require"version".string:gsub("@DEV","")))
elseif arg[1]=="-updateNote"then
	local note=require"parts.updateLog"
	local p1=note:find("\n%d")
	local p2=note:find("\n%d",p1+1)
	note=note:sub(p1,p2-2)
	note=note:gsub("\t","")
	print (note)
end