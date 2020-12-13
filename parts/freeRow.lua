local FREEROW={}
local L={}--Storage
local len=0--Length
function FREEROW.reset(num)
	if num<len then
		for i=len,num+1,-1 do
			L[i]=nil
		end
	elseif num>len then
		for i=len+1,num do
			L[i]={0,0,0,0,0,0,0,0,0,0}
		end
	end
	len=num
end
function FREEROW.get(val,ifGarbage)
	if len==0 then
		for i=1,10 do
			L[i]={0,0,0,0,0,0,0,0,0,0}
		end
		len=len+10
	end
	local t=L[len]
	for i=1,10 do t[i]=val end
	t.garbage=ifGarbage==true
	L[len]=nil
	len=len-1
	return t
end
function FREEROW.discard(t)
	len=len+1
	L[len]=t
end
function FREEROW.getCount()
	return len
end
return FREEROW