function string.splitS(s,sep)
	sep=sep or"/"
	local t={}
	repeat
		local i=find(s,sep)or #s+1
		ins(t,sub(s,1,i-1))
		s=sub(s,i+#sep)
	until #s==0
	return t
end
function sgn(i)return i>0 and 1 or i<0 and -1 or 0 end--Row numbe is A-uth-or's id!
function stringPack(s,v)return s..toS(v)end
function without(t,v)
	for i=1,#t do
		if t[i]==v then return nil end
	end
	return true
end
function mStr(s,x,y)gc.printf(s,x-500,y,1000,"center")end
function convert(x,y)
	return x*screenK,(y-screenM)*screenK
end

function getNewRow(val)
	if not val then val=0 end
	local t=rem(freeRow)
	for i=1,10 do
		t[i]=val or 0
	end
	--clear a row and move to active list
	if #freeRow==0 then
		for i=1,20 do
			ins(freeRow,{0,0,0,0,0,0,0,0,0,0})
		end
	end
	--prepare new rows
	return t
end
function removeRow(t,k)
	ins(freeRow,rem(t,k))
end
function restockRow()
	for p=1,#players do
		local f,f2=players[p].field,players[p].visTime
		while #f>0 do
			removeRow(f,1)
			removeRow(f2,1)
		end
	end
end

function timeSort(a,b)
	return a.time>b.time
end
function stencil_field()
	gc.rectangle("fill",0,-10,300,610)
end
--Single use