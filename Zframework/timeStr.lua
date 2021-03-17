local int,format=math.floor,string.format
return function(s)
	if s<60 then
		return format("%.3fs\"",s)
	elseif s<3600 then
		return format("%d'%05.2f\"",int(s/60),s%60)
	else
		local h=int(s/3600)
		return format("%d:%.2d'%05.2f\"",h,int(s/60%60),s%60)
	end
end