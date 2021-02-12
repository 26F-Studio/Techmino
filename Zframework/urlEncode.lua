local rshift=bit.rshift
local b16={[0]="0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"}
function urlEncode(str)
	local out=""
	for i=1,#str do
		if str:sub(i,i):match("[a-zA-Z0-9]")then
			out=out..str:sub(i,i)
		else
			local b=str:byte(i)
			out=out.."%"..b16[rshift(b,4)]..b16[b%16]
		end
	end
	return out
end