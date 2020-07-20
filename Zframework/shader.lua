local function N(file)
	return love.graphics.newShader("Zframework/shader/"..file..".glsl")
end
return{
	-- glow=gc.newShader("Zframework/shader/glow.cs"),
	alpha=N("alpha"),
	warning=N("warning"),

	aura=N("aura"),
	gradient1=N("grad1"),--Horizonal
	gradient2=N("grad2"),--Vertical
	gradient3=N("grad3"),--Oblique
}