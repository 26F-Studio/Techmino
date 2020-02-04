function string.splitS(s,sep)
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

local count=0
BGblockList={}for i=1,16 do BGblockList[i]={v=0}end
function getNewBlock()
	count=count+1
	if count==17 then count=1 end
	local t=BGblockList[count]
	t.bn,t.size=BGblock.next,2+3*rnd()
	t.b=blocks[t.bn][rnd(0,3)]
	t.x=rnd(-#t.b[1]*t.size*30+100,1180)
	t.y=-#t.b*30*t.size
	t.v=t.size*(1+rnd())
	BGblock.next=BGblock.next%7+1
	return t
end

function timeSort(a,b)
	return a.time>b.time
end
function stencil_field()
	gc.rectangle("fill",0,-10,300,610)
end
function stencil_field_small()
	gc.rectangle("fill",0,0,300,600)
end
--Single use