desktop = r'''
[Desktop Entry]
Name=Techmino Alpha
Comment=Techmino is fun!
Exec=wrapper-love %f
Type=Application
Categories=Game;
Terminal=false
Icon=icon
'''

with open("love.desktop", "w+", encoding="utf-8") as file:
    file.write(desktop)