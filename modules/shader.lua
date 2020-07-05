local function N(file)
	return love.graphics.newShader("shader/"..file..".glsl")
end
return{
	-- glow=gc.newShader("shader/glow.cs"),
	alpha=N("alpha"),
	warning=N("warning"),

	rainbow=N("rainbow"),
	strap=N("strap"),
	aura=N("aura"),
}