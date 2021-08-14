if arg[1]=="-code"then
	return require"version".apkCode
elseif arg[1]=="-string"then
	return require"version".string
else
	local note=require"parts.updateLog"
	local p1=note:find("\n%d")
	local p2=note:find("\n%d",p1+1)
	note=note:sub(p1,p2-2)
	note=note:gsub("\t","")
	return note
end