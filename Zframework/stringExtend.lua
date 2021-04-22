local STRING={}
local int,format=math.floor,string.format
local find,sub,upper=string.find,string.sub,string.upper

do--function STRING.shiftChar(c)
	local shiftMap={
		["1"]="!",["2"]="@",["3"]="#",["4"]="$",["5"]="%",
		["6"]="^",["7"]="&",["8"]="*",["9"]="(",["0"]=")",
		["`"]="~",["-"]="_",["="]="+",
		["["]="{",["]"]="}",["\\"]="|",
		[";"]=":",["'"]="\"",
		[","]="<",["."]=">",["/"]="?",
	}
	function STRING.shiftChar(c)
		return shiftMap[c]or upper(c)
	end
end

function STRING.split(s,sep,regex)
	local L={}
	local p1,p2=1--start,target
	if regex then
		while p1<=#s do
			p2=find(s,sep,p1)or #s+1
			L[#L+1]=sub(s,p1,p2-1)
			p1=p2+#sep
		end
	else
		while p1<=#s do
			p2=find(s,sep,p1,true)or #s+1
			L[#L+1]=sub(s,p1,p2-1)
			p1=p2+#sep
		end
	end
	return L
end

function STRING.simpEmailCheck(e)
	e=STRING.split(e,"@")
	if #e~=2 then return false end
	if e[1]:sub(-1)=="."or e[2]:sub(-1)=="."then return false end
	local e1,e2=STRING.split(e[1],"."),STRING.split(e[2],".")
	if #e1*#e2==0 then return false end
	for _,v in next,e1 do if #v==0 then return false end end
	for _,v in next,e2 do if #v==0 then return false end end
	return true
end

function STRING.time(s)
	if s<60 then
		return format("%.3f\"",s)
	elseif s<3600 then
		return format("%d'%05.2f\"",int(s/60),s%60)
	else
		local h=int(s/3600)
		return format("%d:%.2d'%05.2f\"",h,int(s/60%60),s%60)
	end
end

do--function STRING.urlEncode(str)
	local rshift=bit.rshift
	local b16={[0]="0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"}
	function STRING.urlEncode(str)
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
end

return STRING