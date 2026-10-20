local Json=require'parts.online.json'
local BoardStore={}
function BoardStore.encode(boards)
    local legacy=true
    for _,board in ipairs(boards) do
        if #board>126 then legacy=false break end
        for _,row in ipairs(board) do
            for _,cell in ipairs(row) do if cell< -1 or cell>26 then legacy=false break end end
            if not legacy then break end
        end
        if not legacy then break end
    end
    if legacy then return DATA.copyBoards(boards) end
    return Json.encode{schemaVersion=1,customBoards=boards}
end
function BoardStore.decode(bytes)
    if type(bytes)~='string' then return end
    if bytes:match('^%s*{') then
        local saved=Json.decode(bytes)
        if type(saved)~='table' or saved.schemaVersion~=1 then return end
        for key in pairs(saved) do if key~='schemaVersion' and key~='customBoards' then return end end
        local valid,data=require('parts.online.cloud').validate{customBoards=saved.customBoards}
        if valid then
            local boards={}
            for _,board in ipairs(data.customBoards) do boards[#boards+1]=DATA.newBoard(board) end
            if #boards==0 then boards[1]=DATA.newBoard() end
            return boards
        end
    else
        local boards={}
        for _,boardBytes in ipairs(STRING.split(bytes,'!')) do
            local valid,board=DATA.pasteBoard(boardBytes)
            if not valid then return end
            boards[#boards+1]=board
        end
        return boards
    end
end
return BoardStore
