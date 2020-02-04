local N=gc.newImage
titleImage=N("/image/mess/title.png")
mouseIcon=N("/image/mess/mouseIcon.png")
spinCenter=N("/image/mess/spinCenter.png")
dialCircle=N("/image/mess/dialCircle.png")
dialNeedle=N("/image/mess/dialNeedle.png")
blockSkin={}
for i=1,13 do
	blockSkin[i]=N("/image/block/1/"..i..".png")
end
background={}
gc.setColor(1,1,1)
background={
	N("/image/BG/bg1.jpg"),
	N("/image/BG/bg2.png"),
}
virtualkeyIcon={}
for i=1,9 do
	virtualkeyIcon[i]=N("/image/virtualkey/"..actName[i]..".png")
end