local freeRow={}
local L={}--storage
local _=0--lenth
function freeRow.reset(num)
	if num<_ then
		for i=_,num+1,-1 do
			L[i]=nil
		end
	elseif num>_ then
		for i=_+1,num do
			L[i]={0,0,0,0,0,0,0,0,0,0}
		end
	end
	_=num
end
function freeRow.get(val)
	if _==0 then
		for i=1,10 do
			L[i]={0,0,0,0,0,0,0,0,0,0}
		end
		_=_+10
	end
	local t=L[_]
	for i=1,10 do t[i]=val end
	L[_]=nil
	_=_-1
	return t
end
function freeRow.discard(t)
	_=_+1
	L[_]=t
end
function freeRow.getCount()
	return _
end
return freeRow