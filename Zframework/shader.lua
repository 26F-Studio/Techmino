local function N(file)
	return love.graphics.newShader("Zframework/shader/"..file..".glsl")
end
return{
	-- glow=gc.newShader("Zframework/shader/glow.cs"),
	alpha=N("alpha"),
	warning=N("warning"),

	aura=N("aura"),
	gradient1=N("grad1"),--Horizonal red-blue gradient
	gradient2=N("grad2"),--Vertical red-green gradient
	rgb1=N("rgb1"),--Colorful RGB
	rgb2=N("rgb2"),--Blue RGB
}