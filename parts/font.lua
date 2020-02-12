local new=love.graphics.setNewFont
local set=love.graphics.setFont
local F,cur={}
return function(s)
	local f=F[s]
	if s~=cur then
		if f then
			set(f)
		else
			f=new("font.ttf",s)
			F[s]=f
			set(f)
		end
		cur=s
	end
	return f
end