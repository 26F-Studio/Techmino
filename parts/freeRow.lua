local FREEROW={}
local L={}--Storage
local _=0--Length
function FREEROW.reset(num)
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
function FREEROW.get(val,type)--type: nil=norm, true=garbage
	if _==0 then
		for i=1,10 do
			L[i]={0,0,0,0,0,0,0,0,0,0}
		end
		_=_+10
	end
	local t=L[_]
	for i=1,10 do t[i]=val end
	t[11]=type
	L[_]=nil
	_=_-1
	return t
end
function FREEROW.discard(t)
	_=_+1
	L[_]=t
end
function FREEROW.getCount()
	return _
end
return FREEROW