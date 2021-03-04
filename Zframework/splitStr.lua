local find,sub=string.find,string.sub
return function(s,sep)
	local L={}
	local p1,p2=1--start,target
	while p1<=#s do
		p2=find(s,sep,p1)or #s+1
		L[#L+1]=sub(s,p1,p2-1)
		p1=p2+#sep
	end
	return L
end