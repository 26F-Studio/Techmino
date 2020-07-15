local function N(file)
	return love.graphics.newShader("Zframework/shader/"..file..".glsl")
end
return{
	-- glow=gc.newShader("Zframework/shader/glow.cs"),
	alpha=N("alpha"),
	warning=N("warning"),

	rainbow=N("rainbow"),
	strap=N("strap"),
	aura=N("aura"),
}