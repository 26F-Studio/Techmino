local C=COLOR
local all_month={"T01","T02","T03","T04","T05","T06","T07","T08","T09","T10","T11","T12"}

-- There are some strings, due to game's history, temproary be commented just in case
-- If it is not used anymore, it will be removed, in one day…

return {
    fallback='en',
    loadText={
        loadSFX="Đang tải các hiệu ứng âm thanh",
        loadSample="Đang tải các mẫu nhạc cụ",
        loadVoice="Đang tải các gói voice",
        loadFont="Đang tải phông chữ",
        loadModeIcon="Đang tải các biểu tượng",
        loadMode="Đang tải các chế độ chơi",
        loadOther="Đang tải các tài nguyên khác",
        finish="Nhấn một phím bất kỳ để bắt đầu!",
    },
    sureQuit="Nhấn thêm một lần nữa để thoát",
    sureReset="Nhấn thêm một lần nữa để đặt lại",
    sureDelete="Nhấn thêm một lần nữa để xoá",
    newDay="Một ngày mới, một khởi đầu mới!",
    playedLong="Bạn chơi cũng lâu rồi. Hãy dành chút thời gian nghỉ ngơi đi",
    playedTooMuch="Có lẽ bạn chơi quá nhiều rồi! Đặt máy xuống và nghỉ ngơi đi bạn!",
    settingWarn="CẨN THẬN - Bạn vừa sửa một cài đặt quan trọng của game!",
    settingWarn2="Cài đặt này sẽ có hiệu lực sau khi khởi động lại",

    atkModeName={"Ngẫu nhiên","Huy hiệu","K.O.","Phản công"},
    royale_remain="Còn $1 người chơi",
    powerUp={[0]="+000%","+025%","+050%","+075%","+100%"},
    cmb={nil,"1 Combo","2 Combo","3 Combo","4 Combo","5 Combo","6 Combo","7 Combo","8 Combo","9 Combo","10 Combo!","11 Combo!","12 Combo!","13 Combo!","14 Combo!!","15 Combo!!","16 Combo!!","17 Combo!!!","18 Combo!!!","19 Combo!!!","MEGACMB"},
    spin="-spin ",
    spinNC="-spin",
    clear={"Single","Double","Triple","Techrash","Pentacrash","Hexacrash","Heptacrash","Octacrash","Nonacrash","Decacrash","Undecacrash","Dodecacrash","Tridecacrash","Tetradecacrash","Pentadecacrash","Hexadecacrash","Heptadecacrash","Octadecacrash","Nonadecacrash","Ultracrash","Impossicrash"},
    cleared="$1 hàng",
    mini="Mini",b2b="B2B ",b3b="B2B2B ",
    PC="Perfect Clear",HPC="Hemi-Perfect Clear",
    replaying="[Đang phát lại]",
    tasUsing="[TAS]",

    stage="Chặng $1 hoàn thành!",
    great="Tốt lắm!",
    awesome="Tuyệt vời!",
    almost="Gần được rồi!",
    continue="Cố gắng lên!",
    maxspeed="TỐC ĐỘ TỐI ĐA!",
    speedup="Tăng tốc nào!",
    missionFailed="Nhiệm vụ thất bại",

    speedLV="Tốc độ rơi",
    piece="Gạch",line="Hàng",atk="Attack",eff="Efficiency",
    rpm="RPM",tsd="TSD",
    grade="Grade",techrash="Techrash",
    wave="Wave",nextWave="Next",
    combo="Combo",maxcmb="Max Combo",
    pc="Perfect Clear",ko="KOs",

    win="Thắng!",
    lose="Thua",

    finish="Hoàn thành",
    gamewin="Bạn đã thắng",
    gameover="Kết thúc",

    pause="Tạm dừng",
    pauseCount="Số lần tạm dừng",
    finesse_ap="All Perfect",
    finesse_fc="Full Combo",

    page="Trang ",

    cc_fixed="CC không tương thích với trình xáo gạch cố định",
    cc_swap="CC không tương thích với chế độ Hold là Chuyển",
    ai_prebag="AI không tương thích với trình xáo gạch chứa gạch không phải là tetromino.",
    ai_mission="AI không tương thích với nhiệm vụ tuỳ chọn.",
    switchSpawnSFX="Vui lòng bật Spawn SFX để chơi!",
    needRestart="Khởi động lại để áp dụng mọi thay đổi.",

    loadError_errorMode="Tải '$1' thất bại: không có chế độ tải '$2'",
    loadError_read="Tải tệp '$1' thất bại: đọc thất bại",
    loadError_noFile="Tải tệp '$1' thất bại: không có tệp",
    loadError_other="Tải tệp '$1' thất bại: $2",
    loadError_unknown="Tải tệp '$1' thất bại: không rõ lý do",

    saveError_duplicate="Lưu tệp '$1' thất bại: trùng tên tệp",
    saveError_encode="Lưu tệp '$1' thất bại: mã hoá thất bại",
    saveError_other="Lưu tệp '$1' thất bại: $2",
    saveError_unknown="Lưu tệp '$1' thất bại: không rõ lý do",

    copyDone="Đã sao chép!",
    saveDone="Đã lưu dữ liệu",
    exportSuccess="Đã xuất thành công",
    importSuccess="Đã nhập thành công",
    dataCorrupted="Dữ liệu bị hỏng",
    pasteWrongPlace="Bạn đã dán ở nhầm nơi rồi",
    noFile="Thiếu tệp",

    nowPlaying="Đang phát:",

    VKTchW="Trọng số chạm",
    VKOrgW="Trọng số nút",
    VKCurW="Trọng số hiện tại",

    noScore="Không có điểm",
    modeLocked="Bị khoá",
    unlockHint="Đạt hạng B trở lên trong các chế độ trước đó để mở khóa",
    highScore="Điểm cao",
    newRecord="Thành tích mới!",

    replayBroken="Không thể tải bản phát lại",

    dictNote="==Đã sao chép từ TetroDictionary==",



    -- Server's warn/error messages
    Techrater={
        internalError="Lỗi nội bộ",
        databaseError="Lỗi cơ sở dữ liệu",
        invalidFormat="Định dạng không hợp lệ",
        invalidArguments="Đối số không hợp lệ",
        tooFrequent="Quá thường xuyên",
        notAvailable="Không khả dụng",
        noPermission="Không có quyền",
        roomNotFound="Không tìm thấy phòng",

        -- Controllers
        WebSocket={
            invalidConnection="Kết nối không hợp lệ",
            invalidAction="Hành động không hợp lệ",
            playerNotFound="Không tìm thấy người chơi",
            connectionFailed="Kết nối thất bại",
        },
        -- Filters
        CheckPermission={
            playerNotFound="Không tìm thấy người chơi",
        },
        -- Plugins
        ConnectionManager={
            playerInvalid="Người chơi không hợp lệ",
            playerNotFound="Không tìm thấy người chơi",
            connectionReplaced="Đã thay đổi kết nối",
        },
        NoticeManager={
            noticeNotFound="Không có thông báo",
        },
        PlayerManager={
            -- invalidEmail="Email không hợp lệ",
            -- playerNotFound="Không tìm thấy người chơi",
            -- invalidEmailPass="Email hoặc người chơi không hợp lệ",
            -- emailExists="Email đã tồn tại",
            -- emailSendError="Lỗi gửi email",
            invalidCode="Mã không hợp lệ",
            invalidAccessToken="Mã xác thực không hợp lệ",
        },
        -- Strategies
        PlayerRole={
            invalidRole="Vị trí không hợp lệ",
            invalidTarget="Mục tiêu không hợp lệ",
        },
        PlayerType={
            invalidType="Invalid type",
            roomFull="Phòng đã đầy",
        },
        RoomJoin={
            wrongPassword="Sai mật khẩu",
        },
    },

    tooFrequent="Yêu cầu vào quá nhiều",
    roomPasswordChanged="Mật khẩu của phòng đã thay đổi",
    oldVersion="Phiên bản $1 hiện đã ra mắt",
    versionNotMatch="Phiên bản không khớp",
    notFinished="Sắp ra mắt!",

    -- Deprecated
    -- noUsername="Vui lòng nhập email của bạn",
    -- wrongEmail="Địa chỉ email không hợp lệ",
    -- wrongCode="Mã xác minh không hợp lệ",
    -- noPassword="Vui lòng nhập mật khẩu của bạn",
    -- diffPassword="Mật khẩu không đúng",
    -- checkEmail="Yêu cầu đăng ký đã được gửi.",

    wsFailed="Kết nối WebSocket đã thất bại: $1",
    wsClose="WebSocket đã đóng: $1",
    netTimeout="Kết nối đã quá hạn",
    serverDown="Ối! Server sập! Hãy quay lại sau",
    requestFailed="Yêu cầu thất bại",

    onlinePlayerCount="Trực tuyến: $1",
    createRoomSuccessed="Tạo phòng thành công",
    playerKicked="$1 đã đá $2 khỏi phòng",
    becomeHost="$1 giờ là chủ phòng",
    started="Đang chơi",
    joinRoom="$1 vừa vào phòng.",
    leaveRoom="$1 vừa rời phòng.",
    roomRemoved="Phòng đã bị xoá",
    ready="Sẵn sàng",
    spectating="Đang theo dõi",



    keySettingInstruction="Nhấn một phím để gán phím đó\nescape (esc): Hủy\nbackspace: Xoá",
    customBGhelp=not MOBILE and "Kéo một tấm ảnh vào đây để áp dụng ảnh nền tuỳ chỉnh" or "Chưa hỗ trợ ảnh nền cho điện thoại",
    customBGloadFailed="Định dạng ảnh không được hỗ trợ",

    errorMsg="Techmino bị lỗi và cần phải được khởi động lại\nBạn có thể gửi error log để giúp dev sửa game nhanh hơn.",

    modInstruction="Hãy chọn mod bạn muốn.\nMod cho phép bạn có thể tùy biến game, nhưng cũng có thể làm game sập.\nĐiểm sẽ không được lưu lại khi dùng mod.",
    modInfo={
        next="NEXT\nGhi đè số gạch hiển thị ở cột NEXT",
        hold="HOLD\nGhi đè số lượng gạch được giữ ở cột HOLD",
        hideNext="Hidden NEXT\nẨn số lượng gạch ở cột NEXT (Tính từ ô đầu tiên)",
        infHold="InfiniHold\nCho phép bạn HOLD vô số lần",
        hideBlock="Hide Current Piece\nGạch đang rơi trong bảng sẽ bị tàng hình",
        hideGhost="No Ghost\nBóng gạch sẽ bị tắt",
        hidden="Hide Locked Pieces\nGạch sẽ bị ẩn sau một khoảng thời gian",
        hideBoard="Hide Board\nChe một phần của bảng hay che nguyên bảng",
        flipBoard="Flip Board\nXoay bảng hay lật bảng",
        dropDelay="Gravity\nĐiều chỉnh tốc độ rơi của gạch",
        lockDelay="Lock Delay\nGhi đè thời gian chờ khoá của gạch",
        waitDelay="Spawn Delay\nGhi đè thời gian gạch xuất hiện",
        fallDelay="Line Clear Delay\nGhi đè thời gian xoá hàng",
        life="Life\nThay đổi số mạng",
        forceB2B="B2B Only\nKết thúc trò chơi khi cột B2B giảm xuống dưới vạch ban đầu",
        forceFinesse="Finesse Only\nKết thúc trò chơi khi có lỗi di chuyển",
        tele="Teleport\nDAS = 0, ARR = 0",
        noRotation="No Rotation\nKhông thể xoay gạch",
        noMove="No Movement\nKhông thể di chuyển trái phải",
        customSeq="Randomizer\nGhi đè trình xáo gạch",
        pushSpeed="Garbage Speed\nGhi đề tốc độ xuất hiện của hàng rác",
        boneBlock="[ ]\nChơi với skin [ ]",
    },
    pauseStat={
        "Thời gian chơi:",
        "Phím/Xoay/Giữ:",
        "Số gạch:",
        "Hàng/Đào:",
        "Gửi/Gửi khi đào:",
        "Nhận:",
        "Xóa:",
        "Spin:",
        "B2B/B3B/PC/HPC:",
        "Lỗi di chuyển:",
    },
    radar={"DEF","OFF","ATK","SEND","SPD","DIG"},
    radarData={"D’PM","ADPM","APM","SPM","L’PM","DPM"},
    stat={
        "Số lần bật trò chơi:",
        "Số ván đã chơi:",
        "Thời gian chơi:",
        "Phím/Xoay/Giữ:",
        "Gạch/Hàng/Gửi:",
        "Nhận/Phản/Đẩy:",
        "Đào/Gửi khi đào:",
        "H.quả/H.quả khi Đào:",
        "B2B/B3B:",
        "PC/HPC:",
        "Lỗi di chuyển/Tỉ lệ ko mắc:",
    },
    aboutTexts={
        "Đây chỉ là một trò chơi xếp gạch *thông thường*. Không, thật đấy, chỉ có vậy thôi",
        "Lấy cảm hứng từ C2/IO/JS/WWC/KOS v.v.",
        "",
        "Chạy bằng LÖVE",
        "Chúng tôi đánh giá cao mọi đề xuất và báo cáo lỗi do các bạn gửi đến",
        "Hãy đảm bảo trò chơi được tải về từ nguồn chính thức",
        "vì các nguồn khác có thể không an toàn.",
        "Tác giả KHÔNG CHỊU TRÁCH NHIỆM với bất kỳ bản sửa đổi nào.",
        FNNS and "" or "Trò chơi này hoàn toàn miễn phí! Nếu các bạn thích nó, các bạn có thể ủng hộ chúng tôi!",
        FNNS and "" or "Kiểm tra Zictionary để có thêm thông tin chi tiết",
    },
    staff={
        "ĐƯỢC SÁNG TÁC BỞI MrZ",
        "E-mail: 1046101471@qq.com",
        "",
        "Được lập trình, Phát triển và Thiết kế bởi",
        "MrZ",
        "",
        "Âm nhạc được sản xuất với",
        "Beepbox",
        "FL Studio",
        "FL Mobile",
        "Logic Pro X",
        "",
        "[ĐƯỢC XÂY DỰNG BẰNG LÖVE]",
        "",
        "Lập trình",
        "MrZ",
        "ParticleG",
        "Gompyn",
        "Trebor",
        "(scdhh)",
        "(FinnTenzor)",
        "(NOT_A_ROBOT)",
        "(user670)",
        "",
        "GitHub CI, Đóng gói & BackEnd",
        "ParticleG",
        "Trebor",
        "LawrenceLiu",
        "Gompyn",
        "flaribbit",
        "scdhh",
        "",
        "Thiết kế đồ hoạ, UI & UX",
        "MrZ",
        "Gnyar",
        "C₂₉H₂₅N₃O₅",
        "ScF",
        "(旋律星萤)",
        "(T0722)",
        "",
        "Minh hoạ",
        "Miya",
        "Mono",
        "Xiaoya",
        "葉枭",
        "",
        "Thiết kế âm nhạc",
        "MrZ",
        "柒栎流星",
        "ERM",
        "Trebor",
        "C₂₉H₂₅N₃O₅",
        "(T0722)",
        "(Aether)",
        "(Hailey)",
        "",
        "Hiệu ứng âm thanh & Voice packs",
        "Miya",
        "Xiaoya",
        "Mono",
        "MrZ",
        "Trebor",
        "",
        "Dịch thuật",
        "User670",
        "MattMayuga",
        "Mizu",
        "Mr.Faq",
        "ScF",
        "C₂₉H₂₅N₃O₅",
        "NOT_A_ROBOT",
        "XMiao",
        "sakurw, Airun, 幽灵3383",
        "Shard Nguyễn, Squishy, cộng đồng TVN",
        "",
        "Performances",
        "Electric283",
        "Hebomai",
        "",
        "Xin gửi lời cảm ơn chân thành tới",
        "Flyz",
        "Big_True",
        "NOT_A_ROBOT",
        "思竣",
        "yuhao7370",
        "Farter",
        "Teatube",
        "蕴空之灵",
        "T9972",
        "No-Usernam8",
        "andrew4043",
        "smdbs-smdbs",
        "paoho",
        "Allustrate",
        "Haoran SUN",
        "Tianling Lyu",
        "huaji2369",
        "Lexitik",
        "Tourahi Anime",
        "[cùng với các thành viên thử nghiệm khác]",
        "…và BẠN!",
    },
    used=[[
    Các công cụ đã sử dụng:
        BeepBox
        GoldWave
        GFIE
        FL Mobile
    Các thư viện đã sử dụng:
        Cold_Clear [MinusKelvin]
        json.lua [rxi]
        profile.lua [itraykov]
        sha2 [Egor Skriptunoff]
    ]],
    support="Hỗ trợ người làm game",
    dict={
        sizeChanged="Đã đổi cỡ phông: $1",
        sizeReset="Đã đặt lại cỡ phông!",
        helpText=
[[
HƯỚNG DẪN ĐIỀU HƯỚNG TRONG TETRODICTIONARY

A. Chuột và màn hình cảm ứng
        - Nhấn/chạm [$13] để mở Trợ giúp.
        - Giữ và kéo lên/xuống hoặc lăn chuột để cuộn văn bản.

        - Nhấn/chạm vào một mục trong danh sách ở bên trái để chọn mục cần tra.
        - Nhấn/chạm [$16] hoặc [$17] để nhanh chóng cuộn qua danh sách. Bạn cũng có thể nhấn giữ chuột giữa hoặc chuột phải sau đó lăn chuột để chuyển qua các mục.

        - Nhấn/chạm [aA] để hiện 2 nút điều khiển cỡ chữ.
        - Nhấn/chạm [a] để giảm cỡ chữ và [A] để tăng cỡ chữ.
        - Để đặt cỡ chữ về cỡ mặc định, chờ một vài giây để nút [100%] xuất hiện, sau đó nhấn [100%].

        - Nhấn/chạm [$14] để sao chép nội dung của mục đang xem.
        - Nhấn/chạm [$15] để mở link của mục đang xem (nếu có).

        - Nhấp vào nút quay lại ở góc trên bên phải để thoát TetroDictionary


B. Bàn phím
    Nhấn…
        - [F1] để hiển thị Trợ giúp.
        - [$1] hoặc [$2] để cuộn qua văn bản.
        - [$3] để mở mục trước đó và [$4] để mở mục tiếp theo.

        - [Ctrl] + [-] để giảm cỡ chữ, [Ctrl] + [+] để tăng cỡ chữ.
        - [Ctrl] + [0] để khôi phục về cỡ chữ mặc định

        - [Ctrl] + [C] để sao chép văn bản
        - [$18] (phím Menu ngữ cảnh/phím Ứng dụng)
        để mở liên kết của mục đang xem (nếu có)

        - [Esc] để thoát TetroDictionary


C. Tay cầm chơi game (Gamepad)
        Nhấn $10 để hiển thị trợ giúp.
        Nhấn $5 hoặc $6 để cuộn văn bản.
        Nhấn $7 để mở mục trước và $8 để mở mục tiếp theo.
        Giữ $11 và nhấn $7 hoặc $8 để cuộn nhanh qua danh sách.
        Giữ $11 và nhấn $6 để giảm cỡ chữ hoặc $5 để tăng cỡ chữ.
        Nhấn [BACK] để thoát TetroDictionary.
]]
        -- 1-4: Up, Down, Left, Right
        -- 5-8: Up, Down, Left, Right but D-Pad
        -- 9-12: X, Y, A, B
        -- 13-18: Help, Copy, Open, Forward, Backward, MENU
    },
    WidgetText={
        main={
            offline="Chơi đơn",
            qplay="Chơi nhanh: ",
            online="Nhiều người chơi",
            custom="Chế độ Tự do",
            setting="Cài đặt",
            stat="Thống kê",
            dict="Zictionary",
            replays="Phòng phát lại",
        },
        main_simple={
            sprint="Sprint",
            marathon="Marathon",
        },
        mode={
            mod="Mods (F1)",
            start="Bắt đầu!",
        },
        mod={
            title="Mods",
            reset="Đặt lại (tab)",
            unranked="Không tính điểm",
        },
        pause={
            setting="Cài đặt (S)",
            replay="Phát lại (P)",
            save="Lưu (O)",
            resume="Tiếp tục (esc)",
            restart="Thử lại (R)",
            quit="Thoát (Q)",
            tas="TAS (T)",
        },
        net_menu={
            league="Tech League",
            ffa="FFA",
            rooms="Danh sách phòng",
            resetPW="Đặt lại mật khẩu",
            logout="Đăng xuất",
        },
        net_league={
            match="Tìm trận",
        },
        net_rooms={
            password="Mật khẩu",
            refreshing="Đang làm mới…",
            noRoom="Hiện không có phòng nào",
            refresh="Làm mới",
            new="Phòng mới",
            join="Vào phòng",
        },
        net_newRoom={
            title="Cấu hình phòng",
            roomName="Tên phòng (Mặc định: “[username]'s room”)",
            password="Mật khẩu",
            description="Mô tả phòng",

            life="Mạng",
            pushSpeed="Tốc độ đẩy rác vào",
            garbageSpeed="Tốc độ gửi rác",
            visible="Chế độ hiện gạch",
            freshLimit="Lock Reset tối đa",

            fieldH="Độ cao bảng",
            bufferLimit="Giới hạn nhận rác",
            heightLimit="Giới hạn độ cao",

            drop="Drop Delay",
            lock="Lock Delay",
            wait="Entry Delay",
            fall="Line Delay",
            hang="Death Delay",
            hurry="ARE Interruption",

            capacity="Giới hạn số người",
            create="Tạo phòng",

            ospin="O-spin",
            fineKill="100% Finesse",
            b2bKill="Không phá B2B",
            lockout="Thua khi Lock Out",
            easyFresh="Lock Reset Thường",
            deepDrop="Thả rơi sâu",
            bone="Dùng skin []",

            eventSet="Rule Set",

            holdMode="Chế độ Hold",
            nextCount="Next",
            holdCount="Hold",
            infHold="Hold vô tận",
            phyHold="Hold tại chỗ",
        },
        net_game={
            ready="Sẵn sàng",
            spectate="Theo dõi",
            cancel="Huỷ",
        },
        setting_game={
            title="Cài đặt trò chơi",
            graphic="←Đồ hoạ",
            sound="Âm thanh→",
            style="Trang trí",

            -- ctrl="Cài đặt điều khiển",
            -- key="Cài đặt bố cục phím",
            -- touch="Cài đặt cảm ứng",
            ctrl="Điều chỉnh thg. số",  -- ctrl="Điều chỉnh độ nhạy"
            key="Sửa bố cục bàn phím",
            touch="Sửa bố cục cảm ứng",
            showVK="Bật điều khiển bằng cảm ứng", -- Pull from Galaxy

            reTime="Đếm ngược bắt đầu",
            RS="Hệ thống xoay gạch",
            menuPos="Vị trí nút Menu",
            sysCursor="Sử dụng con trỏ chuột của hệ thống",
            autoPause="Tạm dừng khi ở ngoài game",
            autoSave="Tự động lưu thành tích mới",
            simpMode="Chế độ Đơn giản",
        },
        setting_video={
            title="Cài đặt đồ hoạ",
            sound="←Âm thanh",
            game="Trò chơi→",

            block="Hiện gạch đang rơi",
            smooth="Rơi mượt",
            upEdge="Gạch 3D",
            bagLine="Vạch tách Túi gạch",

            ghostType="Loại bóng gạch",
            ghost="Độ bóng",
            center="Tâm xoay",
            grid="Lưới",
            lineNum="# hàng",

            lockFX="H.ứng Khóa gạch",
            dropFX="H.ứng Thả nhẹ",
            moveFX="H.ứng Di chuyển",
            clearFX="H.ứng Xóa hàng",
            splashFX="H.ứng Gạch “rụng”",
            shakeFX="Độ nảy bảng",
            atkFX="H.ứng Tấn công",

            frame="Tần suất cập nhật khung hình (%)",

            text="Hiện loại xoá hàng",
            score="Hiện điểm thành phần",
            bufferWarn="Hiện số hàng rác",
            showSpike="Hiện độ lớn spike",
            nextPos="Hiện chỗ spawn",
            highCam="Trượt bảng",
            warn="Cảnh báo nguy hiểm",

            clickFX="Click FX",
            power="Hiện thanh pin",
            clean="Vẽ nhanh",
            fullscreen="Toàn màn hình",
            portrait="Để dọc",
            msaa="Khử r.cưa (MSAA)",

            bg_on="Ảnh nền thường",
            bg_off="Không ảnh nền",
            bg_custom="Ảnh nền tự chọn",

            blockSatur="Độ đậm gạch",
            fieldSatur="Độ đậm bảng",
        },
        setting_sound={
            title="Cài đặt âm thanh",

            game="←Trò chơi",
            graphic="Đồ hoạ→",

            mainVol="Âm lượng tổng",
            bgm="Nhạc nền",
            sfx="Hiệu ứng",
            stereo="Stereo",
            spawn="Hiệu ứng spawn",
            warn="Hiệu ứng cảnh báo",
            vib="Rung",
            voc="Giọng",

            autoMute="Tắt tiếng nếu đang ở ngoài game",
            fine="Âm thanh báo lỗi di chuyển",
            sfxPack="Gói SFX",
            vocPack="Gói Voice",
            apply="Chọn",
        },
        setting_control={
            -- title="Cài đặt Điều khiển",
            title="Đ.chỉnh thg. số",
            preview="Xem trước",

            das="DAS",arr="ARR",
            dascut="DAS cut",
            dropcut="Auto-lock cut",
            sddas="DAS thả nhẹ",sdarr="ARR thả nhẹ",
            ihs="Giữ tức thì",
            irs="Xoay tức thì",
            ims="Di chuyển tức thì",
            reset="Đặt lại",
        },
        setting_key={
            a1 ="Sang Trái",
            a2 ="Sang Phải",
            a3 ="Xoay Phải",
            a4 ="Xoay Trái",
            a5 ="Xoay 180°",
            a6 ="Thả Mạnh",
            a7 ="Thả Nhẹ",
            a8 ="Giữ",
            a9 ="Chức năng 1 (F1)",
            a10="Chức năng 2 (F2)",
            a11="Trái tức thì",
            a12="Phải tức thì",
            a13="Thả Nhanh",
            a14="Xuống 1",
            a15="Xuống 4",
            a16="Xuống 10",
            a17="Thả Trái",
            a18="Thả Phải",
            a19="Zangi Trái",
            a20="Zangi Phải",
            restart="Thử lại",
        },
        setting_skin={
            skinSet="Tên Skin",
            title="Trang Trí",
            skinR="Đặt lại màu",
            faceR="Đặt lại hướng",
        },
        setting_touch={
            default="Mặc định",
            snap="Bám theo khung",
            size="Kích cỡ",
            shape="Hình dạng",
        },
        setting_touchSwitch={
            b1 ="Sang Trái:",
            b2 ="Sang Phải:",
            b3 ="Xoay Phải:",
            b4 ="Xoay Trái:",
            b5 ="Xoay 180° (F):",
            b6 ="Thả Mạnh:",
            b7 ="Thả Nhẹ:",
            b8 ="Giữ (H):",
            b9 ="Chức năng 1 (F1):",
            b10="Chức năng 2 (F2):",
            b11="Trái tức thì:",
            b12="Phải tức thì:",
            b13="Thả Nhanh:",
            b14="Xuống 1:",
            b15="Xuống 4:",
            b16="Xuống 10:",
            b17="Thả Trái:",
            b18="Thả Phải:",
            b19="Zangi Trái:",
            b20="Zangi Phải:",

            norm="Thường",
            pro="Nâng cao",
            icon="Icon",
            sfx="SFX",
            vib="Rung",
            alpha="Độ đậm",

            track="Tự động theo",
            dodge="Tự động tránh",
        },
        customGame={
            title="Chế độ Tự do",
            defSeq="Tr.xáo cố định",
            noMsn="Không có nhiệm vụ",

            drop="Drop Delay",
            lock="Lock Delay",
            wait="Entry Delay",
            fall="Line Delay",
            hang="Death Delay",
            hurry="ARE Interruption",

            bg="Ảnh nền",
            bgm="Nhạc",

            copy="Chép Bảng+Tr.xáo+N.vụ",
            paste="Dán Bảng+Tr.xáo+N.vụ",
            play_clear="Bắt đầu-Clear",
            play_puzzle="Bắt đầu-Puzzle",

            reset="Đặt lại (del)",
            advance="More (A)",
            mod="Mod (F1)",
            field="Cài đặt bảng (F)",
            sequence="C. đặt Trình xáo gạch (S)",
            mission="Cài đặt Nhiệm vụ (M)",

            eventSet="Rule Set",

            holdMode="Chế độ Hold",
            nextCount="Next",
            holdCount="Hold",
            infHold="Hold vô tận",
            phyHold="Hold tại chỗ",

            fieldH="Độ cao bảng",
            visible="Chế độ hiển thị",
            freshLimit="Lock Reset tối đa",
            opponent="Đối thủ",
            life="Mạng",
            pushSpeed="Tốc độ đẩy rác vào",
            garbageSpeed="Tốc độ gửi rác",

            bufferLimit="Giới hạn nhận rác",
            heightLimit="Giới hạn độ cao",
            ospin="O-Spin",
            fineKill="100% Finesse",
            b2bKill="Không phá B2B",
            lockout="Thua khi Lock Out",
            easyFresh="Lock Reset Thường",
            deepDrop="Thả Sâu",
            bone="Dùng gạch []",
        },
        custom_field={
            title="Chế độ Tự do",
            subTitle="Bảng",

            any="Xoá",
            smart="Thông minh",

            push="Thêm Hàng (K)",
            del="Xoá Hàng (L)",

            demo="Không hiện “×”",

            newPg="Trang mới (N)",
            delPg="Xoá trang (M)",
            prevPg="Trang trước",
            nextPg="Trang tiếp",
        },
        custom_sequence={
            title="Chế độ Tự do",
            subTitle="Trình xáo gạch",
            sequence="Cách xáo",
        },
        custom_mission={
            title="Chế độ Tự do",
            subTitle="Nhiệm vụ",

            _1="1",_2="2",_3="3",_4="4",
            any1="Spin1",any2="Spin2",any3="Spin3",any4="Spin4",
            PC="PC",
            Z1="Z1",S1="S1",J1="J1",L1="L1",T1="T1",O1="O1",I1="I1",
            Z2="Z2",S2="S2",J2="J2",L2="L2",T2="T2",O2="O2",I2="I2",
            Z3="Z3",S3="S3",J3="J3",L3="L3",T3="T3",O3="O3",I3="I3",
            O4="O4",I4="I4",
            mission="Đúng trình tự!",
        },
        about={
            staff="Đội ngũ",
            his="Thay đổi",
            legals="Pháp lý",
        },
        dict={
            title="Từ điển Tetro",
        },
        stat={
            path="Mở thư mục chứa dữ liệu",
            save="Trình quản lý dữ liệu",
        },
        music={
            title="Phòng Nhạc",
            arrow="→",
            now="Đang phát:",

            bgm="BGM",
            sound="SFXs",
        },
        launchpad={
            title="Phòng SFX",
            bgm="BGM",
            sfx="SFX",
            voc="VOC",
            music="BGMs",
            label="nhãn",
        },
        login={
            title="Đăng Nhập",
            ticket="Mã uỷ quyền",
            authorize="Mở trang uỷ quyền",
            paste="Dán mã",
            submit="Gửi",
        },
        -- reset_password={
        --     title="Đặt lại Mật khẩu",
        --     send="Gửi mã",
        --     code="Mã xác nhận",
        --     password="Mật khẩu",
        --     password2="Nhập lại Mật khẩu",
        --     setPW="Đặt mật khẩu",
        -- },
        account={
            title="Tài khoản",
        },
        app_15p={
            color="Màu",
            invis="Tàng hình",
            slide="Lướt",
            pathVis="Hiện con trỏ",
            revKB="Ngược",
        },
        app_schulteG={
            rank="Độ khó",
            invis="Tàng hình",
            disappear="Biến mất",
            tapFX="Tap FX",
        },
        app_AtoZ={
            level="Level",
            keyboard="Bàn phím",
        },
        app_2048={
            invis="Tàng hình",
            tapControl="Chạm trong bảng",

            skip="Bỏ qua",
        },
        app_ten={
            next="Next",
            invis="Tàng hình",
            fast="Nhanh",
        },
        app_dtw={
            color="Màu",
            mode="Chế độ",
            bgm="BGM",
            arcade="Chế độ đuổi kịp",
        },
        app_link={
            invis="Tàng hình",
        },
        savedata={
            export="Xuất từ clipboard",
            import="Nhập vào clipboard",
            unlock="Tiến trình",
            data="Thống kê",
            setting="Cài đặt",
            vk="Bố cục cảm ứng",

            couldSave="Lưu qua Cloud (CẢNH BÁO: ĐANG THỬ NGHIỆM!)",
            notLogin="[Đăng nhập để lưu]",
            upload="Tải lên Cloud",
            download="Tải xuống từ Cloud",
        },
    },
    modes={
        ['sprint_10l']=     {"Sprint",            "10L",            "Xoá 10 hàng!"},
        ['sprint_20l']=     {"Sprint",            "20L",            "Xoá 20 hàng!"},
        ['sprint_40l']=     {"Sprint",            "40L",            "Xoá 40 hàng!"},
        ['sprint_100l']=    {"Sprint",            "100L",           "Xoá 100 hàng!"},
        ['sprint_400l']=    {"Sprint",            "400L",           "Xoá 400 hàng!"},
        ['sprint_1000l']=   {"Sprint",            "1,000L",         "Xoá 1,000 hàng!"},
        ['sprintPenta']=    {"Sprint",            "PENTOMINO",      "Xoá 40 hàng với 18 pentomino"},
        ['sprintMPH']=      {"Sprint",            "MPH",            "Memoryless\nPreviewless\nHoldless"},
        ['sprint123']=      {"Sprint",            "M123",           "Xoá 40 hàng chỉ với monomino, domino, và trimino"},
        ['secret_grade']=   {"Secret Grade",      "",               "Xây một đường lỗ theo hình dích dắc!"},
        ['dig_10l']=        {"Dig",               "10L",            "Đào 10 hàng rác càng nhanh càng tốt"},
        ['dig_40l']=        {"Dig",               "40L",            "Đào 40 hàng rác càng nhanh càng tốt!"},
        ['dig_100l']=       {"Dig",               "100L",           "Đào 100 hàng rác càng nhanh càng tốt!"},
        ['dig_400l']=       {"Dig",               "400L",           "Đào 400 hàng rác càng nhanh càng tốt!"},
        ['dig_eff_10l']=    {"Dig",               "EFFICIENCY 10L", "Đào 10 hàng rác càng ít gạch càng tốt!"},
        ['dig_eff_40l']=    {"Dig",               "EFFICIENCY 40L", "Đào 40 hàng rác càng ít gạch càng tốt!"},
        ['dig_eff_100l']=   {"Dig",               "EFFICIENCY 100L","Đào 100 hàng rác càng ít gạch càng tốt!"},
        ['dig_eff_400l']=   {"Dig",               "EFFICIENCY 400L","Đào 400 hàng rác càng ít gạch càng tốt!"},
        ['dig_quad_10l']=   {"Dig",               "TECHRASH 10L",   "Đào 10 hàng rác nhưng chỉ dùng techrash!"},
        ['drought_n']=      {"Drought",           "100L",           "Không có thanh dài"},
        ['drought_l']=      {"Drought+",          "100L",           "C L G T"},
        ['marathon_n']=     {"Marathon",          "THƯỜNG",         "Xoá 200 hàng với tốc độ nhanh dần"},
        ['marathon_h']=     {"Marathon",          "KHÓ",            "Xoá 200 hàng với tốc độ cao"},
        ['solo_e']=         {"Battle",            "DỄ",             "Đánh bại AI!"},
        ['solo_n']=         {"Battle",            "THƯỜNG",         "Đánh bại AI!"},
        ['solo_h']=         {"Battle",            "KHÓ",            "Đánh bại AI!"},
        ['solo_l']=         {"Battle",            "RẤT KHÓ",        "Đánh bại AI!"},
        ['solo_u']=         {"Battle",            "THÁCH ĐẤU",      "Đánh bại AI!"},
        ['techmino49_e']=   {"Tech 49",           "DỄ",             "Cuộc chiến 49 người.\nNgười trụ lại cuối cùng giành chiến thắng"},
        ['techmino49_h']=   {"Tech 49",           "KHÓ",            "Cuộc chiến 49 người.\nNgười trụ lại cuối cùng giành chiến thắng"},
        ['techmino49_u']=   {"Tech 49",           "THÁCH ĐẤU",      "Cuộc chiến 49 người.\nNgười trụ lại cuối cùng giành chiến thắng"},
        ['techmino99_e']=   {"Tech 99",           "DỄ",             "Cuộc chiến 99 người.\nNgười trụ lại cuối cùng giành chiến thắng"},
        ['techmino99_h']=   {"Tech 99",           "KHÓ",            "Cuộc chiến 99 người.\nNgười trụ lại cuối cùng giành chiến thắng"},
        ['techmino99_u']=   {"Tech 99",           "THÁCH ĐẤU",      "Cuộc chiến 99 người.\nNgười trụ lại cuối cùng giành chiến thắng"},
        ['round_e']=        {"Turn-Based",        "DỄ",             "Chơi theo lượt và đánh bại AI!"},
        ['round_n']=        {"Turn-Based",        "THƯỜNG",         "Chơi theo lượt và đánh bại AI!"},
        ['round_h']=        {"Turn-Based",        "KHÓ",            "Chơi theo lượt và đánh bại AI!"},
        ['round_l']=        {"Turn-Based",        "RẤT KHÓ",        "Chơi theo lượt và đánh bại AI!"},
        ['round_u']=        {"Turn-Based",        "THÁCH ĐẤU",      "Chơi theo lượt và đánh bại AI!"},
        ['big_n']=          {"Big",               "THƯỜNG",         "Chơi với một bảng nhỏ hơn!"},
        ['big_h']=          {"Big",               "KHÓ",            "Chơi với một bảng nhỏ hơn!"},
        ['master_n']=       {"Master",            "THƯỜNG",         "Dành cho người mới chơi 20G"},
        ['master_h']=       {"Master",            "KHÓ",            "Dành cho người chơi đã quen 20G"},
        ['master_m']=       {"Master",            "M21",            "Dành cho cao thủ 20G"},
        ['master_final']=   {"Master",            "FINAL",          "Dành cho các pháp sư 20G"},
        ['master_ph']=      {"Master",            "PHANTASM",       "Hả???"},
        ['master_g']=       {"Master",            "GRADED",         "Lấy điểm cao nhất có thể!"},
        ['master_ex']=      {"GrandMaster",       "EXTRA",          "Cũng là lấy điểm cao nhất có thể nhưng mà gắt hơn!"},
        ['master_instinct']={"Master",            "INSTINCT",       "Lấy điểm cao nhất có thể nhưng với gạch tàng hình!"},
        ['strategy_e']=     {"Strategy",          "DỄ",             "Quyết định nhanh hoặc là thua"},
        ['strategy_h']=     {"Strategy",          "KHÓ",            "Quyết định nhanh hoặc là thua"},
        ['strategy_u']=     {"Strategy",          "THÁCH ĐẤU",      "Quyết định nhanh hoặc là thua"},
        ['strategy_e_plus']={"Strategy",          "DỄ+",            "Quyết định nhanh và không được Hold!"},
        ['strategy_h_plus']={"Strategy",          "KHÓ+",           "Quyết định nhanh và không được Hold!"},
        ['strategy_u_plus']={"Strategy",          "THÁCH ĐẤU+",     "Quyết định nhanh và không được Hold!"},
        ['blind_e']=        {"Invisible",         "DỄ",             "Dành cho người mới"},
        ['blind_n']=        {"Invisible",         "THƯỜNG",         "Dành cho người đã quen"},
        ['blind_h']=        {"Invisible",         "KHÓ",            "Dành cho người đã có kinh nghiệm"},
        ['blind_l']=        {"Invisible",         "KHÓ+",           "Dành cho người chơi chuyên nghiệp"},
        ['blind_u']=        {"Invisible",         "?",              "Bạn đã sẵn sàng chưa?"},
        ['blind_wtf']=      {"Invisible",         "CLGT?",          "Bạn chưa đủ trình cho màn này đâu!"},
        ['classic_e']=      {"Classic",           "DỄ",             "Chế độ cổ điển từ thập niên 80"},
        ['classic_h']=      {"Classic",           "KHÓ",            "Chế độ cổ điển từ thập niên 80 với tốc độ cao hơn"},
        ['classic_l']=      {"Classic",           "RẤT KHÓ",        "Chế độ cổ điển từ thập niên 80 với tốc độ rất cao"},
        ['classic_u']=      {"Classic",           "THÁCH ĐẤU",      "Chế độ cổ điển từ thập niên 80 với tốc độ nhanh như chớp"},
        ['survivor_e']=     {"Survival",          "DỄ",             "Bạn có thể trụ được bao lâu?"},
        ['survivor_n']=     {"Survival",          "THƯỜNG",         "Bạn có thể trụ được bao lâu?"},
        ['survivor_h']=     {"Survival",          "KHÓ",            "Bạn có thể trụ được bao lâu?"},
        ['survivor_l']=     {"Survival",          "RẤT KHÓ",        "Bạn có thể trụ được bao lâu?"},
        ['survivor_u']=     {"Survival",          "THÁCH ĐẤU",      "Bạn có thể trụ được bao lâu?"},
        ['attacker_h']=     {"Attacker",          "KHÓ",            "Luyện tập kỹ năng tấn công!"},
        ['attacker_u']=     {"Attacker",          "THÁCH ĐẤU",      "Luyện tập kỹ năng tấn công!"},
        ['defender_n']=     {"Defender",          "THƯỜNG",         "Luyện tập kỹ năng phòng thủ!"},
        ['defender_l']=     {"Defender",          "RẤT KHÓ",        "Luyện tập kỹ năng phòng thủ!"},
        ['dig_h']=          {"Driller",           "KHÓ",            "Luyện tập kỹ năng đào xuống!"},
        ['dig_u']=          {"Driller",           "THÁCH ĐẤU",      "Luyện tập kỹ năng đào xuống!"},
        ['c4wtrain_n']=     {"C4W Training",      "THƯỜNG",         "Combo vô tận"},
        ['c4wtrain_l']=     {"C4W Training",      "RẤT KHÓ",        "Combo vô tận"},
        ['pctrain_n']=      {"PC Training",       "THƯỜNG",         "Luyện tập Perfect Clear"},
        ['pctrain_l']=      {"PC Training",       "RẤT KHÓ",        "Luyện tập Perfect Clear nhưng khó hơn"},
        ['pc_n']=           {"PC Challenge",      "THƯỜNG",         "Lấy càng nhiều PC càng tốt trong 100 hàng!"},
        ['pc_h']=           {"PC Challenge",      "KHÓ",            "Lấy càng nhiều PC càng tốt trong 100 hàng!"},
        ['pc_l']=           {"PC Challenge",      "RẤT KHÓ",        "Lấy càng nhiều PC càng tốt trong 100 hàng!"},
        ['pc_inf']=         {"Inf. PC Challenge", "",               "Lấy càng nhiều PC càng tốt"},
        ['tech_n']=         {"Tech",              "THƯỜNG",         "Cố gắng không phá B2B!"},
        ['tech_n_plus']=    {"Tech",              "THƯỜNG+",        "Chỉ được clear Spin hoặc PC"},
        ['tech_h']=         {"Tech",              "KHÓ",            "Cố gắng không phá B2B!"},
        ['tech_h_plus']=    {"Tech",              "KHÓ+",           "Chỉ được clear Spin hoặc PC"},
        ['tech_l']=         {"Tech",              "RẤT KHÓ",        "Cố gắng không phá B2B!"},
        ['tech_l_plus']=    {"Tech",              "RẤT KHÓ+",       "Chỉ được clear Spin hoặc PC"},
        ['tech_finesse']=   {"Tech",              "HOÀN HẢO",       "Không được phép có lỗi di chuyển!"},
        ['tech_finesse_f']= {"Tech",              "HOÀN HẢO+",      "Không được phép có lỗi di chuyển hoặc loại Xoá hàng thường!"},
        ['tsd_e']=          {"TSD Challenge",     "DỄ",             "Chỉ được làm T-Spin Double!"},    -- Chỉ được clear…
        ['tsd_h']=          {"TSD Challenge",     "KHÓ",            "Chỉ được làm T-Spin Double!"},
        ['tsd_u']=          {"TSD Challenge",     "THÁCH ĐẤU",      "Chỉ được làm T-Spin Double!"},
        ['backfire_n']=     {"Backfire",          "THƯỜNG",         "Sống sót những hàng rác do chính bạn gửi"},
        ['backfire_h']=     {"Backfire",          "KHÓ",            "Sống sót những hàng rác do chính bạn gửi"},
        ['backfire_l']=     {"Backfire",          "RẤT KHÓ",        "Sống sót những hàng rác do chính bạn gửi"},
        ['backfire_u']=     {"Backfire",          "THÁCH ĐẤU",      "Sống sót những hàng rác do chính bạn gửi"},
        ['sprintAtk']=      {"Sprint",            "100 Attack",     "Gửi 100 hàng!"},
        ['sprintEff']=      {"Sprint",            "Efficiency",     "Gửi càng nhiều hàng càng tốt trong 40 hàng"},
        ['zen']=            {'Zen',               "200",            "Xoá 200 hàng nhưng không có thời gian giới hạn"},
        ['ultra']=          {'Ultra',             "EXTRA",          "Lấy càng nhiều điểm càng tốt trong 2 phút"},
        ['infinite']=       {"Infinite",          "",               "Chỉ là một chế độ tự do"},
        ['infinite_dig']=   {"Infinite: Dig",     "",               "Đào, đào nữa, đào mãi"},
        ['marathon_inf']=   {"Marathon",          "VÔ TẬN",         "Marathon không có điểm dừng."},

        ['custom_clear']=   {"Custom",            "NORMAL"},
        ['custom_puzzle']=  {"Custom",            "PUZZLE"},
    },
    getTip={refuseCopy=true,
    -- Lưu ý dành cho những bạn sửa phần này: Nguyên đoạn này là lấy từ bản tiếng Anh
    -- Nhưng User670 khi dịch từ tiếng Trung sang đã chọn lược bỏ bớt một số câu
        ":dcgpray:",
        "Không thể mở “Techmino.app” vì người làm game đã bay màu",
        "“Techmino.app” là vi rút đấy. Xoá đi",
        "“TechminOS”",
        "(RUR’U’)R’FR2U’R’U’(RUR’F’)",
        "\\jezevec/\\jezevec/\\jezevec/",
        "\\osk/\\osk/\\osk/",
        "↑↑↓↓←→←→BA",
        "$include<studio.h>",
        "0next 0hold",
        "1next 0hold",
        "1next 1hold!",
        "1next 6hold!",
        "20G thực chất là một chế độ mới đấy!",
        "Kỷ lục Sprint 40 hàng: 14.708s (hiryu)",
        "6next 1hold!",
        "6next 6hold?!",
        "Rất gần nhưng lại rất xa",
        "ALL SPIN!",
        "Am G F G",
        "B2B2B???",
        "B2B2B2B không có thật",
        "Back-to-Back Techrash, 10 Combo, PC!",
        "Nhớ dốc hết sức cho ngày hôm nay nha bạn!",
        "Bridge clear sắp ra mắt!",
        "Bạn có thể chinh phục game xếp gạch này không?",
        "Con tim này luôn hướng về 3M",
        "Mọi thay đổi của game (tiếng Anh) sẽ được ghi lại trên Discord",
        "Color clear sắp ra mắt!",
        "Giảm DAS và ARR sẽ giúp bạn chơi nhanh hơn nhưng khó điều khiển hơn",
        "Tao vừa mới thấy Back-to-Back-to-Back hả?",
        "B2B2B2B tồn tại hả?",
        "Đừng để những thứ nhỏ nhặt làm bạn nản chí!",
        "Đây không phải là lỗi, đây là tính năng!",
        "Hệ thống xoay gạch của Techmino rất đẹp trai!",
        "Em rất tốt nhưng anh rất tiếc…",
        "Đừng quên xem qua phần cài đặt!",
        "Nếu bạn thấy có vấn đề gì, hãy lên trang GitHub báo lại cho chúng tôi!",
        "Game xếp gạch nhưng có thêm chế độ FFA!",
        "Bạn muốn đóng góp ý tưởng? Hãy vào Discord của chúng tôi!",
        "Bạn có biết khi gạch xoay thì nó biến thành gì không?",
        "Khuyến khích đeo tai nghe để có trải nghiệm tốt hơn",
        "Hello world!",
        "Chỉ có 2 loại trimino là I3 và L3",
        "if a==true",
        "Việc tăng tần số khung hình sẽ mang trải nghiệm tốt hơn cho bạn",
        "[Hành động] tức thì có thể cứu bạn đấy!",
        "B2B2B2B là gì? Ăn được không?",
        "Nó vừa load cutscene, vừa load game đấy!",
        "Bạn có thể xoá 40 hàng mà không cần dùng nút trái/phải",
        "Bạn có thể xoá 40 hàng mà không cần dùng nút xoay",
        "Hãy tham gia Discord của chúng tôi!",
        "l-=-1",
        "Nổi lửa lên em, NỔI LỬA LÊN EM!",
        "Việc giảm tần số khung hình sẽ mang trải nghiệm tệ hơn cho bạn",
        "LrL RlR LLr RRl RRR LLL FFF RfR RRf rFF",
        "Mix clear sắp ra mắt!",
        "Hầu hết các biểu tượng của các nút được vẽ tay vào trong bảng Unicode Private Use Area",
        "Hầu hết nhạc trong game được tạo bằng Beepbox",
        "Nghe nhạc làm bạn phân tâm? Tắt nó đi",
        "Nếu mà Chế độ đơn giản được bật thì bạn sẽ không thấy điều đặc biệt nào đâu!",
        "Thương cho tấm thân cơ hàn, ngậm ngùi lặng nhìn con đò sang ngang",
        "Chơi game một tay chưa?",
        "Có công mài sắt, có ngày nên kim!",
        "Chạy bằng LÖVE",
        "Chạy bằng Un..LÖVE",
        "pps-0.01",
        "Dit me VNPT",
        "Một số yêu cầu để đạt được rank X là rất khó, kể cả đối với những người giỏi nhất",
        "Bạn sẽ sớm được chơi với mọi người trên thế giới thôi",
        "Split clear sắp ra mắt!",
        "Techmino là sự kết hợp giữa “technique” và “tetromino”",
        "Hình như mình nghiện Techmino rồi!",
        "Techmino trên Nspire-CX ư? Có thật đấy! Mà khoan đã, hai game này không giống nhau chút nào cả!",
        "TetroDictionary đã ra mắt (có bản tiếng Việt rồi, nhưng mà hơi bruh, thôi vẫn đủ xài!)",
        "Những cái tên xuất hiện ở phần nền trong trang Đội Ngũ là danh sách các nhà tài trợ của chúng tôi",
        "Toàn bộ nhạc game này đã có mặt trên Soundcloud rồi đấy!",
        "The stacker future is yours in Techmino!",
        "Bạn có biết: Có một số chế độ đã bị ẩn khỏi map không?",
        "Có tất cả 18 miếng pentomino khác nhau",
        "Có tất cả 7 miếng tetromino khác nhau",
        "Chế độ nhiều người đã ra mắt rồi, hãy thử nó đi!",
        "Thử sử dụng nhiều ô Hold đi!",
        "Thử dùng 2 nút xoay đi. Dùng cả 3 thì càng tốt",
        {C.red,"CẢNH BÁO! ",C.white,"Cấu trúc dữ liệu và Giải thuật"},
        "20 PC thì sao?",
        "Thế còn 23 PC trong 100 hàng?",
        "26 TSD có nổi không thế?",
        "Game rác v*i c*t",
        "while (false)",
        "Bạn là Nhất!",
        "Bạn có thể giúp chúng tôi viết BGM và SFX!",
        "Bạn có thể cắm bàn phím vào điện thoại hoặc máy tính bảng (đối với iOS thì không)",
        "Bạn có thể cài đặt bố cục phím trong phần cài đặt!",
        "Bạn có thể mở thư mục chứa dữ liệu từ trang Thống kê",
        "Bạn có thể thực hiện Spin với tất cả cả miếng gạch trong game này",
        "Bạn có thể đặt hướng xuất hiện cho từng miếng gạch",
        "ZS JL T O I",
        {C.C,"Also try 15puzzle!"},
        {C.C,"Also try Ballance!"},
        {C.C,"Also try Minecraft!"},
        {C.C,"Also try Minesweeper!"},
        {C.C,"Also try Orzmic!"},
        {C.C,"Also try osu!"},
        {C.C,"Also try Phigros!"},
        {C.C,"Also try Puyo Puyo!"},
        {C.C,"Also try Quatrack"},
        {C.C,"Also try Rubik’s cube!"},
        {C.C,"Also try Terraria!"},
        {C.C,"Also try Touhou Project!"},
        {C.C,"Also try VVVVVV!"},
        {C.C,"Also try World of goo!"},
        {C.C,"Also try Zuma!"},
        {C.H,"MÓM RỒI ANH EM ƠI!!!!!"},
        {C.lP,"Con số bí mật: 626"},
        {C.lR,"Z ",C.lG,"S ",C.lS,"J ",C.lO,"L ",C.lP,"T ",C.lY,"O ",C.lC,"I"},
        {C.lY,"MÁT QUÁ!!"},
        {C.N,"Lua",C.Z," No.1"},
        {C.P,"T-spin!"},
        {C.R,"DMCA là gì?"},
        {C.R,"“Luật sở hữu trí tuệ”"},
        {C.R,"DD",C.Z," Cannon=",C.P,"TS",C.R,"D",C.Z,"+",C.P,"TS",C.R,"D",C.Z," Cannon"},
        {C.R,"DT",C.Z," Cannon=",C.P,"TS",C.R,"D",C.Z,"+",C.P,"TS",C.R,"T",C.Z," Cannon"},
        {C.R,"LrL ",C.G,"RlR ",C.B,"LLr ",C.O,"RRl ",C.P,"RRR ",C.P,"LLL ",C.C,"FFF ",C.Y,"RfR ",C.Y,"RRf ",C.Y,"rFF"},
        {C.Y,"O-Spin Triple!"},
        {C.Z,"Gì? ",C.lC,"Xspin?"},



    -- TECHMINO FUN FACT
        -- How do you pronounce Techmino?
        "Phát âm từ Techmino như thế nào mới đúng?",
        -- English UK: /'tɛkminəʊ/; English US: /tɛkminoʊ/
        "Techmino phát âm trong tiếng Anh là /'tɛkminəʊ/; còn tiếng Mỹ là /tɛkminoʊ/.",
        --
        "Ủa Techmino phải đọc là “Tét-mai-nô” hay là “Tét-mi-nô” vậy?",
        -- Where to download Techmino?
        "Tải Techmino ở đâu vậy? Trên GitHub đấy!",
        -- Techmino's birthday
        "Ngày sinh nhật của Techmino? Hiện tại (đang giả định) là 26/T6.",
        -- How to O-spin: Rotate 626 times in one second (mistaken)
        "Cách O-spin? Nhấn phím xoay 626 lần (ĐÙA ĐẤY ĐỪNG TIN!)",
        -- Hope you all like Z... Oh no, like Techmino
        {"Mình mong các bạn sẽ thích ",C.W,"Z",C.white,"… Ối! Không phải, thích ",C.green,"Techmino",C.white," cơ! Nhầm nhầm nhầm!"},
        -- 2021 was the year of Techmino's online debut.
        "2021 là năm ra mắt chế độ trực tuyến của Techmino.",
        -- The Chinese name of this game is 'Block Research Institute'.
        "Tên chính thức của game là “方块研究所” (Block Research Institute).",
        "Một tên khác của game này là “Tiehu Minuo”",
        -- This game is not called Teachmino
        "Tên game không phải là Teachmino!",
        --
        "Muốn game có thứ gì đó đặc biệt lúc mở game? Hãy chỉnh đồng hồ trên điện thoại vào một ngày đặc biệt nào đó đi!",
        --
        "Trừ khi bạn đang chơi Techmino: “O-spin is a lie!” (O-spin là lời nói dối (của em)!)",
        -- techminohaowan
        "Hảo Techmino",
--
    -- TIPS WHEN PLAYING
        -- Don't act weak! Don't act weak! Don't act weak!
        "Đừng tỏ ra yếu đuối! Đừng tỏ ra yếu đuối! ĐỪNG TỎ RA YẾU ĐUỐI!",
        -- Warning: No pretending to be weak.
        {C.red,"CẢNH BÁO! ",C.white,"Đừng giả vờ yếu đuối"},
        -- "Meow!"
        "Meow!",
        -- Getting popup messages in the middle of a game? Go to settings and disable them.
        "Thông báo tự dưng hiện lên giữa game? Vào cài đặt của app tạo ra popup và tắt nó đi.",
        "Do Not Distrub (Không làm phiền) sẽ là cứu tinh của bạn khi có quá nhiều thông báo cùng làm phiền.",
        -- Don't play with your phone if your homework isn't finished.
        "Đừng chơi điện thoại khi bài tập về nhà còn chưa hoàn thành.",
        -- Enabling vibration on some mobile systems may cause severe lag."
        "Bật rung trên điện thoại có thể khiến máy giật lag.",
        -- Eat the button? Really? I suggest you play it back to see if you pressed it and how long it took you to press it"
        "Phím không ăn? Giỡn à? Xem lại replay để chắc rằng ông đã nhấn và xem thử mất bao nhiêu thời gian để ông nhấn phím đó.",
        -- Probably someone will read the tip
        "Chắc chắn có người đang đọc cái dòng chữ nhỏ đang chạy ở dưới này.",
        -- It seems like no one has reached a high level by playing with their feet yet.
        "Hình như tới giờ chưa ai chơi xếp gạch giỏi bằng chân…",
        -- Moderate gaming is good for the brain. Addiction to games is harmful. Plan your time
        "Chơi game vừa phải có thể tốt cho bộ não. Nhưng nếu nghiện thì toeng! Nhớ quản lý thời gian nhé!",
        -- The ability to dig is extremely important in battles!!!
        "Khả năng đào xuống (downstacking) của bạn là RẤT QUAN TRỌNG trong chiến đấu!!!",
        -- Skilled players of the Classic Tetris game are also formidable; don't underestimate them
        "Xếp gạch cổ điển cũng không đơn giản gì như xếp gạch hiện đại đâu. Đừng có mà xem thường những người chơi hệ cổ điển!",
        -- Classic Tetris and Modern Tetris are two different games; being skilled in one doesn't mean you'll be skilled in the other. You have to start from scratch.
        "Xếp gạch cổ điển và xếp gạch hiện đại là hai thể loại game khác nhau đấy! Giỏi một trong hai không có nghĩa là bạn giỏi cả bên còn lại đâu. Bạn phải học từ đầu đấy! Không đơn giản đâu.",
        -- To protect the players' well-being, the game has a temporary and simplified anti-addiction system! (But you probably won't trigger it, haha)
        "Để tránh việc người chơi nào đó chơi quá lâu, game đã có hệ thống chống nghiện đơn giản tạm thời (Nhưng bạn có lẽ sẽ không bao giờ kích hoạt chúng đâu, haha)",
        -- Basic stacking and digging skills are crucial; those who neglect these two aspects often regret it (trust me)
        {"Kỹ năng xếp lên vào đào xuống là 2 kỹ năng RẤT quan trọng; những ai coi thường hoặc bỏ bê hai khía cạnh này thường hay bị bón hành súp mặt lờ (tin ",C.W,"MrZ",C.white," đi!)"},
        -- Even if you're topped out, don't give up; every line of garbage can potentially become your weapon.
        "Ngay cả khi bạn sắp bị top out, đừng bỏ cuộc; vì từng hàng rác có tiềm năng trở thành vũ khí của bạn!",
        -- The video shown above is not a recording; it's the robot playing in real-time.
        "Cái ở trên là replay hả? Không, là AI đang chơi trong thời gian thực đấy!",
        -- Extended gaming sessions will gradually deteriorate your performance! Remember to take breaks when playing for a long time~
        "Những lần chơi game kéo dài thường xuyên dần dần làm giảm hiệu suất chơi game (trong trường hợp tệ nhất bạn có thể bị stall). Nhớ nghỉ ngơi khi chơi lâu",
        -- Be careful of tenosynovitis!
        {C.red,"CẢNH BÁO! ",C.white,"Bệnh viêm bao gân cổ tay!"},
        -- The button with a question mark in the bottom-right corner is the game manual (assuming you haven't enabled the concise mode).
        "Cái nút "..CHAR.icon.help.." ở góc phải dưới cùng trong menu (không bật chế độ Đơn giản) đấy hả? Nó là manual (hướng dẫn sử dụng) của game đấy!",
        -- If you're new to blocks, just play more games; there isn't much specific targeted practice beyond 40 lines in two minutes
        "Bạn mới tập chơi xếp gạch à? Nếu vậy cứ chơi nhiều lên. Không có nhiều mục tiêu luyện tập cụ thể ngoài xóa 40 hàng trong 2 phút.",
        --
        "Hãy ra ngoài và chạm cỏ đi!",
--
    -- MrZ
        {C.W,"uid:225238922"},
        {"Ai là ",C.W,"MrZ",C.white," vậy?"},
--
    -- MrZ
        {C.W,"uid:225238922"},
        {"Ai là ",C.W,"MrZ",C.white," vậy?"},
--
    -- Z SAID
        -- I can't write cool music (crying)
        {C.W,"Z: ",C.white,"Tôi không thể nào viết một bản nhạc nào trông ngầu cả (sadge)."},
        -- I haven't studied music composition. I just composed it myself. If you really think it's good, that's great!
        {C.W,"Z: ",C.white,"Tôi chưa từng học sáng tác nhạc, và tôi chỉ tự sáng tác chúng. Nếu bạn thấy những bản nhạc này hay, thật tuyệt!"},
        -- What else can I write for tips?
        {C.W,"Z: ",C.white,"Còn mẹo nào tôi có thể viết ra nhỉ?"},
        -- I hope Minimalistic Mode is fine.
        {C.W,"Z: ",C.white,"Tôi mong là Chế độ Đơn giản đủ tốt"},
        -- I wonder how many people playing games actually care about who made the game.",
        {C.W,"Z: ",C.white,"Tôi tự hỏi là có bao nhiêu người chơi game thực sự quan tâm ai viết ra nó."},
--
    -- IT JOKES
        "git clone --recursive https://github.com/26F-Studio/Techmino.git",
        "git merge --rebase",
        "git stash",
        "git stash apply",
        "git submodule update",
        "git commit -m \".\"",
        "git push -f",
        "Lua No.1",
        "sudo rm -rf /*",
        "shutdown /s /t 0",         -- Turn off computer completely (no Fast Boot)
        "shutdown /s /t 0 /hybrid", -- Turn off computer with Fast Boot still activated
        -- Techmino has reached the limit.
        "Bạn không thể mở Techmino vì đã đạt tới giới hạn",
        -- Techmino.exe has stopped working.
        "Techmino.exe hiện không phản hồi",
        "Techmino đã đột ngột dừng lại",
        -- If you have a real interest in programming, I recommend Lua. Easy installation, simple syntax, and fast execution speed. Stay away from boring school programming (haha)
        {"Nếu bạn thực sự có hứng thú trong lập trình, tôi đề xuất sử dụng Lua. Dễ xài, cú pháp đơn giản, và tốc độ thực thi nhanh. Rồi tránh xa chương trình học nhàm chán ở trên trường luôn! (haha) - ",C.W,"Z",C.white," said."},
         -- COLD CLEAR PATH
         "Đường dẫn của Cold Clear: "..(SYSTEM=='Windows' and "<root>\\CCLoader.dll" or SYSTEM=='Linux' and "<root>/ColCLoader.so" or SYSTEM=='Android' and "<root>/libAndroid/arm64-v8a (hoặc armeabi-v7a)/CCLoader.so" or SYSTEM=='OS X' and "<root/CCLoader.dylib" or "(Tui không rõ bạn đang dùng HĐH nào nên tui không biết :3)"),
--
    -- CHANGELOG
        {C.lW, "V0.0.091726",": ",C.white, "Đã thêm hệ thống xoay TRS"},
        {C.lW, "V0.7.9 "    ,": ",C.white, "Đã thêm ",C.yellow,"O-spin"},
        {C.lW, "V0.7.19"    ,": ",C.white, "Đã thêm hệ thống voice"},
        {C.lW, "V0.7.22"    ,": ",C.white, "Đã thêm hiệu ứng rơi mượt"},
        {C.lW, "V0.8.5 "    ,": ",C.white, "Đã thêm map và sắp xếp lại các chế độ"},
        {C.lW, "V0.8.19"    ,": ",C.white, "Đã thêm Pentomino"},
        {C.lW, "V0.9.0 "    ,": ",C.white, "Đã thêm chế độ tự do và khả năng tùy biến chuỗi gạch"},
        {C.lW, "V0.10.0"    ,": ",C.white, "Đã thêm hệ thống replay"},
        {C.lW, "V0.11.1"    ,": ",C.white, "Đã thêm Little Z Dictionary (Zictionary)"},
        {C.lW, "V0.12.2"    ,": ",C.white, "Đã thêm hệ thống mod"},
        {C.lW, "V0.13.0"    ,": ",C.white, "Thử nghiệm chế độ trực tuyến"},
        {C.lW, "V0.13.2"    ,": ",C.white, "Đã thêm khả năng tùy biến chiều cao bảng"},
        {C.lW, "V0.13.3"    ,": ",C.white, "Đã thêm console"},
        {C.lW, "V0.14.5"    ,": ",C.white, "Đã thêm BGM đầu tiên được làm bởi cộng đồng"},
        {C.lW, "V0.15.5"    ,": ",C.white, "Đã thêm menu replay"},
        {C.lW, "V0.16.0"    ,": ",C.white, "Đã thêm hệ thống xoay BiRS"},
        {C.lW, "V0.16.2"    ,": ",C.white, "Đã thêm studio SFX với phong cách hit pad"},
        {C.lW, "V0.17.0"    ,": ",C.white, "Đã thêm hõ trợ điều khiển bằng joystick"},
        {C.lW, "V0.17.3"    ,": ",C.white, "Dừng phát triển Techmino, tập trung phát triển game mới"},
        {C.lW, "V0.17.12"   ,": ",C.white, "Đã thêm ngôn ngữ tiếng Việt"},
        {C.lW, "V0.17.15"   ,": ",C.white, "Cập nhật bản dịch tiếng Việt: thêm Zictionary + HDSD & cải thiện câu từ trong game + sửa lỗi font"},
--
        -- MATH FORMULAS
        "(a+b)²=a²+2ab+b²",
        "a²-b²=(a-b)(a+b)",
        "a²+b²=(a+b)²-2ab",
        "(a+b)³=a³+3a²b+3ab²+b³",
        "a³+b³=(a+b)(a²-ab+b²)",
        "a³-b³=(a-b)(a²+ab+b²)",
        "∫u dv=uv-∫v du",
        "cos(α+β)=CαCβ-SβSα",
        "cos²α-cos²β=-S(α+β)S(α-β)",
        "cos²α-sin²β=C(α+β)C(α-β)",
        "cos2α=C²α-S²α",
        "e^(πi)=-1",
        "e^(πi/2)=i",
        "e^(πi/4)=(1+i)/√2",
        "lim x→c f(x)/g(x)=lim x→c f'(x)/g'(x)",
        "S△ABC=√(h(h-a)(h-b)(h-c))，h=(a+b+c)/2",
        "sin(α+β)=SαCβ+SβCα",
        "sin²α-cos²β=-C(α+β)C(α-β)",
        "sin²α-sin²β=S(α+β)S(α-β)",
        "sin2α=2SαCα",
--
    -- FROM SEA
        {C.W,"MrZ",C.white," còn có một biệt danh dễ thương hơn, đó là ",C.W,"Z-Chan"},
        "Có hơn 400 mẹo bạn có thể nhìn thấy ở đây, là cái dòng chữ này, nếu bạn đang chơi Techmino tiếng Trung",

        {C.lSea,"Sea: ",C.white,"Tui không có đủ mặn để viết joke. Nên một số câu đùa đang chạy ở đây được viết bởi ",C.yellow,"Shard Nguyễn",C.white,". “Em cảm ơn anh!”"},
        {C.lSea,"Sea: ",C.white,"Tui đang tự hỏi liệu còn bao nhiêu lỗi tui bỏ sót lúc dịch game không? Tính ra tui đã cập nhật đi cập nhật lại cũng 4-5 lần rồi."},

        {"Cộng đồng Tetris ",C.red,"Việt ",C.lYellow,"Nam ",C.white,": https://discord.gg/jX7BX9g"}, -- Tetris Vietnam
        {C.W,"MrZ ",C.white,"vẫn chưa biết chọn tên nào để đặt cho từ điển của Techmino. Hiện có 3 tên: “Zictionary”, “TetroDictionary” và “Little Z Dictionary”"},
        "Ủa tao nhớ game này tên là xếp hình mà? Ừ thì đúng nhưng để giữ độ đồng nhất và tránh bị cấn mồm thì nên gọi game này là game xếp gạch.",
        "Mình xin phép ủng hộ cho player này. Ủng hộ càng nhiều tỉ lệ thắng càng cao!",
        {"Aiiiii mua cần phô mai ủng hộ ",C.yellow,"Chủ tiệm phô mai",C.white," không?"}, -- Little joking
        {"Hôm nay là ngày ",os.date("%d"),"/",all_month[tonumber(os.date("%m"))],"/",os.date("%Y")}, -- inspired from Nokia 1280, activating talking clock by holding * key at main menu
    },
    pumpkin="Tôi là một quả bí ngô",
}
