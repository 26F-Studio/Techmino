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

---@param theme string
---@param keepBGM boolean|false|nil
function THEME.set(theme,keepBGM)
    if type(theme)~='string' then
        return
    elseif theme:sub(1,6)=='season' then
        BG.setDefault(SETTING.defaultBG)
        BGM.setDefault(({season1='null',season2='nil',season3='vacuum',season4='space'})[theme])
    elseif theme=='xmas' then
        BG.setDefault('snow')
        BGM.setDefault('xmas')
        MES.new('info',"==Merry Christmas==")
    elseif theme=='birth' then
        BG.setDefault('firework')
        BGM.setDefault('magicblock')
    elseif theme=='sprfes' then
        BG.setDefault('firework')
        BGM.setDefault('spring festival')
        MES.new('info',"★☆新年快乐☆★")
    elseif theme=='halloween' then
        BG.setDefault('glow')
        BGM.setDefault('antispace')
        MES.new('info',">>Happy halloween<<")
    elseif theme:sub(1,4)=='zday' then
        BG.setDefault('lanterns')
        BGM.setDefault(({zday1='overzero',zday2='jazz nihilism',zday3='empty'})[theme])
    elseif theme=='fool' then
        BG.setDefault('blockrain')
        BGM.setDefault('how feeling')
    elseif theme=='edm' then
        BG.setDefault('lightning2')
        BGM.setDefault('malate')
        MES.new('music',"                    红  色  电  音\n                 极  地  大  冲  击\n        只要你敢触电——\n           7月14日、15日 天地人间完全放电\n不用麻醉，一样情不自禁HI起来，飞起来")
    else
        return
    end

    THEME.cur=theme
    BG.set()
    if not keepBGM then BGM.play() end
    return true
end

function THEME.getThemeColor(theme)
    if not theme then
        theme=THEME.cur
    end
    return themeColor[theme]
end

return THEME
