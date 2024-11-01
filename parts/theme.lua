local THEME={
    cur=false,-- Current theme
}
local themeColor={
    xmas={COLOR.lR,COLOR.Z,COLOR.lG},
    sprfes={COLOR.lR,COLOR.O,COLOR.lY},
    halloween={COLOR.lH,COLOR.O,{COLOR.hsv(.76,.50,.42)},{COLOR.hsv(.33,.80,.42)}},
}

function THEME.calculate(Y,M,D)
    if not Y then
        Y,M,D=os.date('%Y'),os.date('%m'),os.date('%d')
    end
    -- Festival calculate within one statement
    if not SETTING.noTheme then return
        -- Christmas
        M=='12' and math.abs(D-25)<4 and
        'xmas' or

        -- Halloween
        (M=='10' and D>='28' or M=='11' and D>='01' and D<='04') and
        'halloween' or

        -- Birthday
        M=='06' and D=='06' and
        'birth' or

        -- Spring festival
        M<'03' and math.abs((({
            -- Festival days. Jan 26=26, Feb 1=32, etc.
            24,43,32,22,40,29,49,38,26,45,
            34,23,41,31,50,39,28,47,36,25,
            43,32,22,41,29,48,37,26,44,34,
            23,42,31,50,39,28,46,35,24,43,
            32,22,41,30,48,37,26,45,33,23,
            42,32,50,39,28,46,35,24,43,33,
            21,40,
        })[Y-2000] or -26)-((M-1)*31+D))<6 and
        'sprfes' or

        -- April fool's day
        M=='04' and D=='01' and
        'fool' or

        -- April fool's day
        M=='07' and (D=='14' or  D=='15') and
        'edm' or

        -- Z day
        D=='26' and (
            (M=='03' or M=='04' or M=='05' or M=='06') and 'zday1' or
            (M=='07' or M=='08' or M=='09' or M=='10') and 'zday2' or
            (M=='11' or M=='12' or M=='01' or M=='02') and 'zday3'
        )
    end

    -- If there is theme and theme is enabled, then we will never reach here
    return -- Normal
    (
        (M=='02' or M=='03' or M=='04') and 'season1' or
        (M=='05' or M=='06' or M=='07') and 'season2' or
        (M=='08' or M=='09' or M=='10') and 'season3' or
        (M=='11' or M=='12' or M=='01') and 'season4'
    )
end

local themeBG={
    zday1='lanterns',zday2='lanterns',zday3='lanterns',

    xmas     ='snow',
    birth    ='magicblock',
    sprfes   ='firework',
    halloween='glow',
    fool     ='blockrain',
    edm      ='lightning2'
}
local themeBGM={
    season1='null',season2='nil',season3='vacuum',season4='space',
    zday1='overzero',zday2='jazz nihilism',zday3='empty',

    xmas     ='xmas',
    birth    ='magicblock',
    sprfes   ='spring festival',
    halloween='antispace',
    fool     ='how feeling',
    edm      ='malate'
}
local themeMessages={
    xmas     ="==Merry Christmas==",
    sprfes   ="★☆新年快乐☆★",
    halloween=">>Happy halloween<<",
    edm      ="                    红  色  电  音\n                 极  地  大  冲  击\n        只要你敢触电——\n           7月14日、15日 天地人间完全放电\n不用麻醉，一样情不自禁HI起来，飞起来"
}
function THEME.set(theme,keepBGM)
    if not (themeBG[theme] or themeBGM[theme]) then return end
    THEME.cur=theme

    BG.setDefault(themeBG[theme] or SETTING.defaultBG)
    BGM.setDefault(themeBGM[theme])

    BG.set()
    if not keepBGM then BGM.play() end

    if themeMessages[theme] then
        MES.new(theme=='edm' and 'music' or 'info',themeMessages[theme])
    end

    return true
end

function THEME.getThemeColor(theme)
    if not theme then
        theme=THEME.cur
    end
    return themeColor[theme]
end

return THEME
