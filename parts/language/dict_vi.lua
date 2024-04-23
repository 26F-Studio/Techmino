local tetromino = " tetromino tetramino tetrimino"
local function replaceCheckCrossMark(str)
    return STRING.repD(str,CHAR.icon.checkMark,CHAR.icon.crossMark)
end

return {
    {
        "=[NHÓM 01]=",
        "nhom01 giới thiệu bản dịch",
        "",
        [[
NHÓM 01: VỀ ZICTIONARY & BẢN DỊCH

Zictionary là một bộ từ điển về game xếp gạch cực kì hữu ích. Ở đây, bạn có thể tìm hiểu hầu hết mọi thứ liên quan đến trò chơi này.

Để nhảy nhanh tới mục lục, hãy gõ "mucluc" trên thanh tìm kiếm.

Đây là bản Việt hóa của Squishy từ bản dịch tiếng Anh của User670 và C₂₉H₂₅N₃O₅.
Được chuẩn hóa lại nhờ sự giúp đỡ của cộng đồng Tetris Việt Nam.
Bản dịch có thể có sai sót so với Zictionary tiếng Trung (bản gốc).

Bạn muốn đóng góp vào bản dịch? Bạn có thể vào trang dự án Techmino trên GitHub để làm nhé.
        ]],
        "https://github.com/26F-Studio/Techmino/blob/main/parts/language/dict_vi.lua",
    },
    {
        "Mục lục",
        "nhom01 index mucluc",
        "help",
        [[
01. Về Zictionary & Bản dịch game & Mục lục ← bạn đang xem mục này
02. Dự án Techmino: Trang web chính thức, Dự án trên GitHub, Discord
03. Ủng hộ cho tác giả của Techmino
04. Mẹo và lời khuyên:
        - Lời khuyên dành cho những người mới tập chơi
        - Đề xuất luyện tập, Học làm T-spin, Điều chỉnh DAS
        - Bố cục phím, Khả năng xử lý gạch, Các nút xoay

05. Các yếu tố cần thiết của các game xếp gạch hiện đại:
        - Next, Hold, In-place Hold, Swap, Topping out, Vùng đệm, Vùng biến mất
        05A. Gạch: Hình dạng, màu, hướng và tên của gạch
        05B. Hệ thống xoay gạch: ARS, ASC, ASC+, BRS, BiRS, C2RS, C2sym, NRS, SRS, SRS+, TRS, XRS
        05C. Hệ thống điều khiển: IRS, IHS, IMS
        05D. Cách kiểu xáo gạch: Túi 7 gạch, His, EZ-Start, Reverb, C2
            (và vấn đề Drought của một vài kiểu xáo)

        05E. Thông số
            05E1. Thông số của game:
                - Tốc độ rơi, 20G
                - ARE, Line ARE, Death ARE
                - Lockdown Delay, Spawn & Clear delay
            05E2. Thông số điều khiển:
                DAS & ARR, DAS cut, Auto-lock cut, SDF
        05F. Điều khiển
            05F1. Tốc độ: LPM, PPS, BPM, KPM, KPP
            05F2. Kỹ thuật: Hypertapping, Rolling, Finesse
            05F3. Độ trễ đầu vào
        05G. Khả năng tấn công
            - APM, SPM, DPM, RPM, ADPM, APL
            - Tấn công & Phòng thủ
            - Combo, Spike, Debt, Passthrough, Timing

        05H. Hành động bất cẩn (Mis-): Misdrop, Mishold
        05I. Spin: (Mini) / (All-) / (T-) / (O-) spin; Fin, Neo, Iso; Freestyle
        05J: Kỹ thuật xóa hàng:
            - Single, Double, Triple (Xóa 1/2/3 hàng); Techrash; Tetris
            - TSS, TSD, TST, MTSS, MTSD
            - Perfect Clear, Half Perfect Clear
        05K. Các thuật ngữ khác: sub, 'Doing Research', Bone block

06. Các game xếp gạch
        (Danh sách rất dài, gõ trên thanh tìm kiếm "nhom06" để xem danh sách đầy đủ)

07. Một vài cơ chế và chế độ của một số game:
            - Tàng hình một phần, tàng hình hoàn toàn
            - Chế độ MPH, Secert Grade, Deepdrop
08. Bot: Cold Clear, ZZZbot

09. Wiki; các trang web bày setup & cung cấp câu đố, chia sẻ setup
        09A. Wiki: Huiji Wiki, Wiki Hard Drop, tetris.wiki, Tetris Wiki Fandom
        09B. Bày setup: Four.lol, Tetris Hall, Tetris Template Collections, tetristemplate.info, 4-Wide Trainer
        09C. Chia sẻ câu đố: TTT, TTPC, NAZO, TPO
        09D. Chia sẻ setup: Fumen, Fumen bản Điện thoại
10. Cộng đồng: Tetris Online Servers, Tetris Việt Nam

11. Xếp lên và đào xuống
        11A. Stacking (Xếp lên):
            - Side / Center / Partial well
            - Side / Center 1 / 2 / 3 / 4-wide
            - Residual
            - 6-3 Stacking
        11B. Digging (Đào xuống)

12. Setup (Opener, Mid-game setup, Donation, Pattern)
        12A. Opener: DT Cannon, DTPC, BT Cannon, BTPC, TKI 3 Perfect Clear, QT Cannon, Mini-Triple, Trinity, Wolfmoon Cannon, Sewer, TKI, God Spin, Albatross, Pelican, Perrfect Clear Opener, Grace System, DPC, Gamushiro Stacking
        12B. Mid-game: C-spin, STSD, Fractal, LST stacking, Imperial Cross, King Crimson, PC liên tiếp (1+2+3)
        12C. Donation: Hamburger, STMB Cave, Kaidan, Shachiku Train, Cut Copy

13. Cách tính lượng sát thơng gây ra: Tetris Online / Notris Foes, Techmino

14. Console và chuyện quản lý dữ liệu game
        - Console, đặt lại thiết lập, tình trạng mở khóa, bố cục phím
        - Xóa toàn bộ thành tích, kỷ lục, bản phát lại, bộ nhớ đệm
15. Các thuật ngữ không liên quan gì tới Tetris (tiếng Anh): SFX, BGM, TAS, AFK
        ]]
    },
    {"=[NHÓM 02]=",
        "nhom02",
        "",
        "NHÓM 02: DỰ ÁN TECHMINO",
    },
    {"Website chính thức",
        "nhom02 websites; trang chủ",
        "org",
        "Trang web chính thức của Techmino!\nBạn có thể lấy bản mới nhất của Techmino cũng như tạo tài khoản, thay avatar ngay tại đó\nNhấn vào nút hình địa cầu ở bên phải để mở website trên trình duyệt của bạn.",
        "http://studio26f.org",
    },
    {"Dự án trên GitHub",
        "nhom02; mã nguồn mở; github; repository; kho lưu trữ",
        "org",
        "Repository chính thức của Techmino trên GitHub. Chúng tôi sẽ rất cảm kích nếu bạn tặng cho chúng tôi một ngôi sao!",
        "https://github.com/26F-Studio/Techmino",
    },
    {"Discord",
        "nhom02 máy chủ server",
        "org",
        [[
Discord của Techmino chính là nơi mà bạn có thể cập nhật mọi thông tin về Techmino, hoặc đơn giản là đến trò chuyện với tất cả mọi người.

Nhấn nút hình địa cầu để tham gia cùng chúng tôi!
        ]],
        "https://discord.gg/f9pUvkh"
    },
    not FNNS and {"=[NHÓM 03]=",
        "nhom03",
        "",
        "NHÓM 03: ỦNG HỘ CHO TÁC GIẢ CỦA TECHMINO",
    } or {"=[NHÓM 03]=",
        "nhom03",
        "",
        "Nội dung của nhóm này đã bị ẩn đi do yêu cầu của nền tảng. Nhưng bạn vẫn có thể hỏi về nội dung này trong server Discord của chúng tôi."
        },
    not FNNS and {"Ủng hộ 1",
        "nhom03; wechat alipay",
        "org",
        "Để ủng hộ cho Techmino thông qua WeChat Pay hoặc Alipay, gõ \"support\" ở trong console và quét mã QR.",
    } or {"*ĐÃ ẨN*", "", "org", ""},
    not FNNS and {"Ủng hộ 2",
        "nhom03; afdian aidadian",
        "org",
        "Để ủng hộ cho Techmino qua Aifadian, nhấn vào nút hình địa cầu để mở trang ủng hộ này. Lưu ý là Aifadian sẽ tính thêm 6% phí giao dịch.",
        "https://afdian.net/@MrZ_26",
    } or {"*ĐÃ ẨN*", "", "org", ""},
    not FNNS and {"Ủng hộ 3",
        "nhom03; patreon",
        "org",
        "Để ủng hộ cho Techmino qua Patreon, hãy nhấn vào nút hình địa cầu để mở trang ủng hộ này. Lưu ý là Patreon có thể tính phí dịch vụ cho bạn đối với các giao dịch trên một số tiền nhất định.",
        "https://www.patreon.com/techmino",
    } or {"*ĐÃ ẨN*", "", "org", ""},
    {"=[NHÓM 04]=",
        "nhom04",
        "",
        "NHÓM 04: MẸO & LỜI KHUYÊN"
    },
    {"Mới tập chơi?",
        "guides newbie noob readme recommendations suggestions helps",
        "help",
        [[
Chúng tôi có vài lời khuyên dành cho những người mới chơi xếp gạch:
    Hai thứ cơ bản:
        1. Chọn những game xếp gạch chuyên nghiệp có cơ chế điều khiển tốt. Techmino, TETR.IO, Jstris và Tetris Online là một số lựa chọn khá tốt đấy. Đừng chơi những game có đánh giá không tốt bởi vì đa số chúng không đi sát với Guideline, hoặc là có cơ chế điều khiển tệ hại; gây ảnh hưởng xấu trong quá trình luyện tập.
        2. Dành thời gian để học các kỹ năng cơ bản đã. Cố gắng dành nhiều thời gian hơn cho các kỹ năng như đọc hàng NEXT hoặc có thể xóa Tetris một cách ổn định. Làm chủ các phần cơ bản trước khi nghĩ tới những kỹ năng nâng cao hơn như T-spin.
    Ba kỹ năng cần có:
        1. Nhớ các vị trí xuất hiện của gạch.
        2. Nhớ các chuỗi thao tác để di chuyển gạch đến vị trí mong muốn.
        3. Suy nghĩ trước về vị trí đặt viên gạch sắp tới.

Bạn có thể nhấn nút Mở link để mở bài "Suggestion for new players to Tetris Online", viết bởi Tatianyi - một người chơi xếp gạch ở Trung Quốc (dịch sang tiếng Anh bởi User670).
        ]],
        "https://github.com/user670/temp/blob/master/tips_to_those_new_to_top.md",
    },
    {"Đề xuất luyện tập",
        "nhom04 readme noob new guides recommendations suggestions helps; đề xuất luyện tập; người mới chơi; hướng dẫn; lời khuyên; gợi ý",
        "help",
[[
Lời khuyên khi tập chơi:
Sau đây là vài lời khuyên của chúng tôi để cải thiện kỹ năng chơi của bạn. Bạn cũng đừng ngại nghỉ ngơi và dành nhiều thời gian hơn để chơi những chế độ bạn thích nếu bạn cảm thấy mệt mỏi. Chúc bạn thành công!

Những lời khuyên này đã được sắp xếp thành nhóm với độ khó tăng dần. Tuy vậy, chúng tôi khuyên bạn hãy làm cả 3 cùng lúc thay vì từng cái một (A → B → C)

A. Stacking (Xếp gạch)
        A1. Suy nghĩ kỹ trước khi đặt gạch. Chưa vừa ý? Suy nghĩ thêm lần nữa.
        A2. Xếp gạch càng phẳng càng tốt để bạn có thể ra quyết định đặt gạch dễ dàng hơn.
        A3. Lên kế hoạch trước cách xếp, hãy tận dụng tối đa NEXT và HOLD để giữ được thế đẹp.

B. Efficiency & Speed (Hiệu quả & Tốc độ)
        B1. Đừng dựa vào bóng gạch quá nhiều! Nên tập trung vào việc suy nghĩ vị trí tốt nhất cho gạch đó.
        B2. Nên sử dụng 2 (hoặc 3, tùy game) phím xoay thay vì nhấn 1 phím xoay liên tục trong thời gian dài.
        B3. Đừng lo lắng về tốc độ khi bạn mới tập chơi Finesse. Bạn có thể bắt đầu học bằng cách chơi chậm, rồi từ từ bạn có thể tập chơi nhanh hơn khi đã quen tay - việc này không khó đâu!

C. Practice (Luyện tập):
    Cố gắng hoàn thành các chế độ sau
        C1. "40 hàng".
        C2. "40 hàng" mà không dùng HOLD.
        C3. "40 hàng" mà chỉ được làm Techrash.
        C4. "40 hàng" mà chỉ được làm Techrash và không được dùng HOLD.

Mẹo: Bạn có thể điều chỉnh độ khó nhóm C tùy vào khả năng của bạn.

Sau khi xong nhóm C, hãy luyện tập tiếp nhóm A, đây là kỹ năng RẤT quan trọng trong bất kỳ game xếp gạch nào. Sau khi làm chủ được kỹ năng đọc NEXT thì bạn dễ dàng thành thạo các thứ khác.
]],
    },
    {"Học làm T-spin",
        "nhom04 tspin; học; hướng dẫn; mẹo; lời khuyên; đề xuất",
        "help",
        [[
T-spin là một kỹ năng khá khó, không tài nào thành thạo nổi nếu chỉ có nhìn vào địa hình nơi làm T-spin. Bạn cần phải có kỹ năng đọc NEXT và lên kế hoạch tốt để có thể làm T-spin

Lời khuyên của chúng tôi, bạn nên bắt đầu học làm T-spin khi bạn có thể:
    - Xoá 40 hàng trong vòng 60 giây (tùy vào khả năng cá nhân con số này sẽ khác)
    - Xóa 40 hàng chỉ dùng Tetris
    - Xóa 40 hàng chỉ dùng Tetris + không HOLD mà không bị mất tốc độ quá nhiều

Những chế độ này sẽ giúp bạn củng cố kỹ năng đọc NEXT và lên kế hoạch.
        ]],
    },
    {"Điều chỉnh DAS",
        "nhom04 das tuning",
        "help",
        "Với những người chơi đã có kinh nghiệm mà muốn chơi nhanh hơn, khuyên dùng DAS 4-6f (67-100 ms) và ARR 0f (các viên gạch sẽ ngay lập tức dính vào tường khi DAS kết thúc).\n\nNếu bạn thấy khó điều khiển, hãy thử tăng DAS lên 1-2f, nhưng giữ ARR bé hơn 2f (33 ms).\n\nTóm lại, DAS nên để thấp nhất có thể nhưng vẫn phải đảm bảo được game có thể phân biệt được bạn đang nhấn hay giữ phím trong khi ARR để ở mức thấp nhất có thể.",
    },
    {"Bố cục phím",
        "nhom04 feel",
        "help",
        [[
Dưới đây là vài lời khuyên hữu ích khi bạn đang chỉnh sửa bố cục phím

1. Một ngón tay chỉ nên thực hiện một chức năng duy nhất. Ví dụ như: một ngón cho sang trái, một ngón cho sang phải, một ngón cho rơi mạnh, …; và gán một ngón tay cho cả phím xoay trái và xoay phải (vì không ai xoay cả hai phía cùng một lúc cả)

2. Trừ khi bạn tự tin với ngón út của mình, thì không nên để ngón tay này làm bất kì việc nào hết! (Vì chúng rất kém linh hoạt). Lời khuyên: nên xài ngón trỏ và ngón giữa vì hai ngón này là nhanh nhẹn nhất, nhưng bạn cũng có thể thoải mái tìm hiểu xem các ngón tay của mình nhanh chậm thế nào, mạnh yếu ra sao.

3. Không nhất thiết phải sao chép bố cục phím của người khác, vì không ai giống ai. Bố cục phím thường không ảnh huởng quá nhiều đến kỹ năng của bạn nếu bạn đã tuân theo quy tắc 1 và 2.
        ]],
    },
    {"Khả năng xử lý gạch",
        "nhom04 feel handling",
        "help",
        [[
Những yếu tố sau có thể ảnh hưởng tới việc xử lý gạch của bạn:

1. Độ trễ đầu vào, có thể là do cấu hình, thông số hoặc tình trạng của thiết bị. Khởi động lại trò chơi; bảo dưỡng, sửa chữa thiết bị của bạn hoặc đổi sang thiết bị mới có thể khắc phục vấn đề này.
2. Độ ổn định của game, phụ thuộc vào cách thiết kế và cách lập trình của game. Có thể cải thiện tình trạng này bằng cách tắt hiệu ứng hình ảnh hoặc để chất lượng đồ họa ở mức thấp.
3. Thiết kế có chủ đích trong game.
4. Thông số điều khiển gạch chưa hợp lí (ví dụ: DAS, ARR, SDARR,…). Thay đổi các cài đặt này có thể giúp bạn.
5. Tư thế chơi không hợp lý. Hãy thử tìm tư thế chơi thoải mái nhất có thể.
6. Thao tác không quen sau khi đổi bố cục phím hoặc thiết bị. Tập làm quen với chúng hoặc thay đổi cài đặt phím.
7. Mỏi cơ, chuột rút,… làm cho việc phản ứng và phối hợp tay khó khăn hơn. Hãy nghỉ ngơi và trở lại sau một vài ngày.
        ]],
    },
    {"Các nút xoay",
        "nhom04 doublerotation phím xoay",
        "help",
        "Dùng cả nút xoay trái và phải sẽ giảm số lần nhấn nút, vì xoay một hướng ba lần thì cũng tương tự xoay một lần hướng ngược lại.\nĐây cũng là một thứ cần phải lưu ý nếu bạn muốn thành thạo Finesse.\n\nNếu bạn dùng thêm nút xoay 180°, bạn có thể xoay tới bất kì hướng nào chỉ với 1 lần nhấn phím (nếu không xét spin).\n\nTuy nhiên, chúng tôi không khuyến khích dùng 180° vì không phải game nào cũng hỗ trợ xoay 180°, và sự khác biệt về tốc độ giữa việc dùng hai nút và ba nút là không quá đáng kể.\nBạn có thể bỏ qua kỹ thuật này trừ khi bạn muốn chơi nhanh hơn chớp.",
    },
    {"=[NHÓM 05]=",
        "nhom05",
        "",
        [[
NHÓM 05: CÁC YẾU TỐ CẦN THIẾT CỦA CÁC GAME XẾP GẠCH HIỆN ĐẠI

Khái niệm về trò chơi Tetris hay trò chơi xếp gạch "hiện đại" khá là mờ nhạt.
Nói chung, một game xếp gạch hiện đại thường sẽ bám sát theo Tetris Design Guideline (Bộ nguyên tắc thiết kế cho một game Tetris). Game nào thỏa mãn đa số các tiêu chí dưới đây có thể được coi là game xếp gạch hiện đại.

    1. Phần có thể nhìn thấy được của bảng có kích thước 10 cột × 20 hàng, cùng với 2 - 3 hàng ẩn ở trên cùng. (Kích thước bảng thực tế ở trong mã nguồn game thường cố định ở 10 cột × 40 hàng).
    2. Gạch mới xuất hiện ở giữa trên cùng của vùng có thể nhìn thấy (thường là ở hàng 21-22). Mỗi gạch đều có màu sắc và hướng xuất hiện mặc định riêng. Với những gạch có chiều dài lẻ có thể lệch sang trái hoặc phải 1 ô.
    3. Có một bộ xáo gạch như 7-Bag hay His được thiết kế để giảm hoặc tránh tình trạng Flood hay Drought.
    4. Có một hệ thống xoay, và cho phép xoay theo ít nhất 2 hướng. Ưu tiên hệ thống xoay SRS hoặc các biến thể tương tự.
    5. Có hệ thống chờ khóa gạch thích hợp.
    6. Có cơ chế top-out thích hợp.
    7. Có hàng NEXT hiện từ 3 - 6 gạch sắp rơi (vẫn chấp nhận trường hợp chỉ hiện 1 gạch) và những gạch trong cột này phải giống tư thế khi chúng vừa mới xuất hiện trong bảng.
    8. Cho phép giữ gạch.
    9. Nếu có hệ thống chờ tạo gạch hoặc hệ thống chờ xóa hàng, game thường sẽ có hệ thống IRS và IHS. Techmino còn có cả hệ thống IMS nữa (tìm trong Zictionary để biết thêm).
    10. Có hệ thống DAS nhằm hỗ trợ các chuyển động ngang một cách chính xác và nhanh chóng.
        ]],
    },
    {"Next (Kế / Tiếp)",
        "nhom05 preview",
        "term",
        "Là một hàng dùng để hiện chuỗi gạch sẽ lần lượt xuất hiện. Có một kỹ năng cần thiết đó là lên kế hoạch trước cách đặt các gạch từ hàng NEXT. Số lượng gạch bạn muốn lên kế hoạch là tùy thuộc vào bạn và có thể thay đổi tùy theo chế độ chơi và tình trạng bảng chơi hiện tại của bạn.",
    },
    {"Hold (Giữ/Trữ/Cất)",
        "nhom05",
        "term",
        "Một chức năng cho phép bạn sử dụng gạch ở trong ô HOLD\n(hoặc gạch đầu tiên ở hàng NEXT nếu bạn chưa cất gạch trước đó)\nvà cất gạch đang rơi vào ô HOLD \n\nBình thường, Hold chỉ có thể được sử dụng 1 lần cho mỗi gạch.\n\nTrên thực tế, việc dùng Hold hay không cũng có ưu nhược của nó.\nNếu không dùng Hold:\n\t- Có thể giảm áp lực cho người chơi khi điều khiển gạch.\n\t- Đồng thời có thể giảm số phím cần nhấn trong game → có thể tăng KPS lên.\nTrên thực tế, đã có nhiều kỷ lục 40L được xác lập mà không cần Hold.\n\nNếu dùng Hold:\n\t- Hold có thể có ích trong nhiều trường hợp khác nhau (ví dụ như khi đang chơi ở tốc độ rơi cao).\n\t- Cho phép người chơi có thể làm được nhiều setup phức tạp hơn mà không đẩy thêm áp lực cho người chơi."
    },
    {"Hold tại chỗ",
        "nhom05 physicalhold physics inplacehold",
        "term",
        "*Chỉ có trên Techmino*\n\"Giữ ngay tại chỗ\".\n\nMột kiểu Hold đặc biệt cho phép gạch được lấy ra từ HOLD sẽ xuất hiện ngay tại vị trí mà gạch hiện tại đang rơi (khác với Hold thông thường khi mà gạch sẽ xuất hiện ở trên cùng của bảng).\nBạn có thể bật chức năng này trong Chế độ tự do.\n\nFun fact: người Trung gọi cái này là \"Physical Hold\"",
    },
    {"Swap (Chuyển)",
        "nhom05 hold",
        "term",
        "Một biến thể khác của \"Hold\". Swap sẽ đổi gạch đang rơi với gạch tiếp theo trong NEXT. Bạn có thể bật chức năng này trong Chế độ tự do.",
    },
    {"Topping out",
        "nhom05 topout toppingout game over",
        "term",
        [[
Một tựa game xếp gạch hiện đại thường có 3 điều kiện để "game over":

1. Block out: Gạch mới nằm chồng lên một gạch đã đặt.
2. Lock out: Có gạch nằm hoàn toàn ở phía trên vùng nhìn thấy.
3. Top out: Độ cao của bảng vượt quá độ cao cho phép (thường là 40 hàng). Cái này đa số là do hàng rác đẩy bảng lên quá cao.

Techmino mặc định sẽ không kiểm tra điều kiện Lock out và Top out.
    ]],
    },
    {"Vùng đệm",
        "nhom05 invisible buffer zone",
        "term",
        "Tên tiếng Anh là \"Buffer Zone\". Chỉ bao gồm các hàng từ hàng 21-40 (nằm ở phía trên vùng nhìn thấy).\n\nTồn tại vùng này là vì sẽ có trường hợp hàng rác sẽ đẩy gạch trong bảng ra khỏi vùng nhìn thấy (dễ thấy nhất là Center 4-Wide).\nNhững ô gạch nào đi ra khỏi vùng nhìn thấy được sẽ đi vào vùng đệm và sẽ xuất hiện lại trong vùng nhìn thấy nếu bạn đã xóa đủ hàng.\n\nVùng đệm thường cao 20 ô (thường là do bảng đã bị cố định kích thước ở trong các dòng code), nhưng có game có vùng này cao vô hạn (ví dụ như trong chính Techmino luôn, khi bảng có thể mở rộng kích thước của nó).\n\nCác bạn có thể tìm hiểu thêm ở mục \"Vùng biến mất\".",
    },
    {"Vùng biến mất",
        "nhom05 gone vanish zone",
        "term",
        [[
Tên tiếng Anh: "Vanish Zone". Là vùng bao gồm các hàng nằm ở trên "Vùng đệm", thường bắt đầu từ hàng 40 trở lên.

Bình thường, nếu có ô gạch nào ở trong vùng này thì game sẽ kích hoạt ngay cơ chế top-out.
Tuy nhiên, mỗi game sẽ có cách xử lý khác nhau. Ví dụ:
    - Jstris: Vùng biến mất nằm ở hàng 22 trở lên, những ô gạch nào nằm trong vùng này sẽ biến mất hoàn toàn.
    - Tetris Online: Game sập.
    - Puyo Puyo Tetris: Các ô gạch ở vùng biến mất sẽ sao chép lại vô số lần khi chúng quay về lại vùng nhìn thấy (nhấn vào hình địa cầu để xem ví dụ của trường hợp này).
    ]],
        "https://youtu.be/z4WtWISkrdU",
    },
    {">A|Gạch",
        "nhom05a",
        "",
        "Bạn có biết?\nGame này hỗ trợ và cho phép bạn chơi với 29 loại gạch khác nhau\n\n1 Mino | 1 Domino | 2 Trimino | 7 Tetromino | 18 Pentomino\n\nMino: gạch 1 ô\nDomino: gạch 2 ô\nTrimino: gạch 3 ô\nTetromino: gạch 4 ô\nPentomino: gạch 5 ô\n\nTechmino có Hexomino (gạch 5 ô) không?\nBây giờ thì chưa nhưng tương lai thì có thể có.",
    },
    {"Hình dạng",
        "nhom05a hình dáng"..tetromino,
        "term",
        "Trong đa số các game xếp gạch, tất cả gạch đều là Tetromino\n\nCó 7 loại Tetromino, nếu cho phép xoay nhưng không lật ngang hay dọc, gồm: Z, S, J, L, T, O, và I.\nHãy xem mục \"Tên\" (Nhóm 05A) để có thêm thông tin.", -- Removed " - gạch được liên kết bởi 4 ô, bám dính vào mặt chứ không bám vào góc."
    },
    {"Màu",
        "nhom05a màu"..tetromino,
        "term",
        "Nhiều game xếp gạch hiện đại, từ chính thức tới fan-made, đã và đang sử dụng cùng một bảng màu duy nhất cho Tetromino.\n\nNhững màu này bao gồm:\n\tZ - Đỏ \n\tS - Xanh lá \n\tJ - Xanh dương \n\tL - Cam \n\tT - Tím \n\tO - Vàng \n\tI - Xanh lơ\n\nTechmino cũng sử dụng bảng màu này để tô màu cho Tetromino.",
    },
    {"Tên",
        "nhom05a mino tên gạch"..tetromino,
        "term",
        "Đây là danh sách gạch mà Techmino sử dụng\n(cùng với tên tương ứng của chúng):\n\nTetromino:\nZ: "..CHAR.mino.Z..",  S: "..CHAR.mino.S..",  J: "..CHAR.mino.J..",  L: "..CHAR.mino.L..",  T: "..CHAR.mino.T..",  O: "..CHAR.mino.O..",  I: "..CHAR.mino.I..";\n\nPentomino:\nZ5: "..CHAR.mino.Z5..",  S5: "..CHAR.mino.S5..",  P: "..CHAR.mino.P..",  Q: "..CHAR.mino.Q..",  F: "..CHAR.mino.F..",  E: "..CHAR.mino.E..",  T5: "..CHAR.mino.T5..",  U: "..CHAR.mino.U..",  V: "..CHAR.mino.V..",  W: "..CHAR.mino.W..",  X: "..CHAR.mino.X..",  J5: "..CHAR.mino.J5..",  L5: "..CHAR.mino.L5..",  R: "..CHAR.mino.R..",  Y: "..CHAR.mino.Y..",  N: "..CHAR.mino.N..",  H: "..CHAR.mino.H..",  I5: "..CHAR.mino.I5..";\n\nTrimino, Domino và Mino:\nI3: "..CHAR.mino.I3..",  C: "..CHAR.mino.C..",  I2: "..CHAR.mino.I2..",  O1: "..CHAR.mino.O1..".",
    },
    {"Hướng",
        "nhom05a 0r2l 02 20 rl lr"..tetromino,
        "term",
        [[
Trong hệ thống xoay SRS và các biến thể của SRS, nhiều người sử dụng một hệ thống số và chữ cái để mô tả hướng của gạch:
    0: Hướng mặc định của hệ thống xoay
    R: Xoay phải, góc 90° theo chiều kim đồng hồ
    L: Xoay trái, góc 90° theo ngược chiều kim đồng hồ
    2: Xoay 2 lần, góc 180° theo bất kì chiều nào.

Hệ thống mô tả cách xoay như sau:
    - 0 → L nghĩa là xoay gạch ngược chiều kim đồng hồ, từ hướng ban đầu (0) sang hướng bên trái (L)
    - 0 → R nghĩa là xoay gạch theo chiều kim đồng hồ, từ hướng ban đầu (0) sang hướng bên phải (R)
    - 2 → R nghĩa là xoay gạch theo chiều kim đồng hồ, từ hướng 180° (2) sang hướng bên phải (R).
        ]],
    },
    {">B|Hệ thống xoay",
        "nhom05b",
        "",
        [[
Một hệ thống để xác định cách gạch xoay.

Ở các trò xếp gạch hiện đại, mỗi gạch có thể xoay dựa trên một tâm xoay cố định (vài game có thể không có cái này).
Nếu gạch sau khi xoay đè lên gạch khác / ra ngoài bảng, hệ thống sẽ thử "wall-kicking" (đẩy gạch sang các vị trí xung quanh).
Tuy nhiên, nếu khoảng cách quá lớn thì hệ thống xoay không thể đá gạch được

Wall-kick cho phép gạch có thể đến những lỗ có hình dạng nào đó mà bình thường không thể tiếp cận được. Các vị trí mà gạch hệ thống xoay có thể thử được chứa trong một bảng gọi là "wall-kick table".
        ]]
    },
    {"ARS",
        "nhom05b arikrotationsystem atarirotationsystem",
        "term",
        "Có thể chỉ 1 trong 2 hệ thống sau:\nArika Rotation System (Hệ thống xoay Arika): hệ thống xoay được dùng trong series game Tetris: The Grand Master.\nAtari Rotation System (Hệ thống xoay Atari), hệ thống xoay luôn căn chỉnh các gạch ở trên cùng bên trái khi xoay.",
    },
    {"ASC",
        "nhom05b ascension",
        "term",
        "Hệ thống xoay được dùng trong Ascension (tên viết tắt cũng là ASC) - một bản clone của Tetris. Tất cả các gạch đều sử dụng chung hai bảng wall-kick đối xứng với nhau cho 2 hướng xoay và vùng đá phải nằm trong khoảng cách 2 ô ở tất cả 4 hướng.",
    },
    {"ASC+",
        "nhom05b ascension ascplus",
        "term",
        "Một phiên bản được chỉnh sửa của ASC trong Techmino để hỗ trợ wall-kick khi xoay 180°.",
    },
    {"BPS",
        "nhom05b bulletproofsoftware",
        "term",
        "BPS rotation system | Hệ thống xoay BPS\nĐược dùng trong các game Tetris được viết bởi Bullet-Proof Software.",
    },
    {"BiRS",
        "nhom05b biasrs biasrotationsystem",
        "term",
        [[
Bias Rotation System | Hệ thống xoay Bias.
*Chỉ có trên Techmino*

Một hệ thống xoay dựa trên SRS và XRS

Để kích hoạt offset bổ sung trong BiRS, cần phải thỏa hai điều kiện sau cùng lúc:
1. Một nút di chuyển (Trái / Phải / Thả nhẹ) phải được giữ
2. Gạch hiện tại phải chạm một ô gạch bất kỳ hoặc chạm tường ở hướng đang được giữ ở bước 1

Nếu thực hiện thành công, offset ở hướng đang được giữ ở bước 1 sẽ được thêm 1 ô. Tuy nhiên, để kick được thì cần phải tuân thêm hai điều kiện:

1. Khoảng cách Euclide từ tâm tới vị trí đá tới được chọn phải bé hơn √5
2. Hướng của cú đá không phải là hướng đối diện với hướng đã được xác định bằng phím bấm.

Nếu không dùng kick đó được, offset trái phải sẽ bị hủy và thử lại, nếu không được nữa thì hủy luôn offset dưới.

So với XRS, BiRS dễ nhớ hơn vì chỉ dùng một bảng wall-kick; nhưng vẫn giữ được khả năng vượt địa hình của SRS.
        ]],
    },
    {"C2RS",
        "nhom05b c2rs cultris2",
        "term",
        "Cultris II rotation system | Hệ thống xoay Cultris II\n\nMột hệ thống xoay ở trong Cultris II - một bản clone của Tetris.\nToàn bộ gạch và cả hướng xoay đều sử dụng chung một bảng wall-kick (trái 1, phải 1, dưới 1, dưới trái 1, dưới phải 1, trái 2 và phải 2) và phía bên trái được ưu tiên hơn so với bên phải.\n\nTrong Techmino có một bản chỉnh sửa của hệ thống này, đó là C2sym.",
    },
    {"C2sym",
        "nhom05b cultris2",
        "term",
        "Một bản chỉnh sửa của C2RS trong Techmino. Hệ thống sẽ ưu tiên hướng trái hoặc phải tùy vào hình dạng của các viên gạch khác nhau.",
    },
    {"DRS",
        "nhom05b dtetrotationsystem",
        "term",
        "DTET Rotation System | Hệ thống xoay DTET\nHệ thống xoay trong DTET.",
    },
    {"NRS",
        "nhom05b nintendorotationsystem",
        "term",
        "Nintendo Rotation System | Hệ thống xoay Nintendo\n\nHệ thống được sử dụng trong các game Tetris cho hai hệ máy Nintendo Entertainment System (NES) và Game Boy.\nHệ thống xoay này có hai phiên bản ngược chiều nhau. Trên Game Boy thì gạch sẽ căn về phía bên trái, còn NES thì gạch sẽ căn về phía bên phải.",
    },
    {"SRS",
        "nhom05b superrotationsystem",
        "term",
        "Super Rotation System | Hệ thống xoay Siêu Cấp\n\nHệ thống xoay này được sử dụng rất nhiều trong các game xếp gạch hiện đại và có rất nhiều hệ thống xoay do fan làm ra cũng dựa vào hệ thống này.\nCó tất cả 8 bảng wall-kick trong SRS, tương ứng với hai hướng xoay cho tất cả bốn tư thế của tất cả các gạch (không có trường hợp cho 180°). Nếu gạch đụng tường, đụng đáy, hay đè lên gạch khác sau khi xoay, hệ thống sẽ kiểm tra các vị trí xung quanh. Bạn có thể xem đầy đủ các bảng wall-kick của SRS trên Tetris Wiki.",
    },
    {"SRS+",
        "nhom05b srsplus superrotationsystemplus",
        "term",
        "Một biến thể của SRS để thêm hỗ trợ wall-kick khi xoay 180°.",
    },
    {"TRS",
        "nhom05b techminorotationsystem",
        "term",
        "Techmino Rotation System | Hệ thống xoay Techmino\n*Chỉ có trên Techmino*\n\nMột hệ thống xoay dựa trên SRS.\nHệ thống này khắc phục được hiện tượng gạch S / Z bị kẹt trong một số trường hợp.\n\nHơn nữa, TRS có thêm các bảng wall-kick dành cho Pentomino dựa trên logic của SRS với Tetromino.\n\nHệ thống cũng hỗ trợ O-Spin, cho phép gạch O có thể đá hoặc \"biến hình\".",
    },
    {"XRS",
        "nhom05b xrs",
        "term",
        "X rotation system | Hệ thống xoay X, một hệ thống xoay trong T-ex.\n\nỞ trong các hệ thống khác, bảng wall-kick là cố định, nên gạch chỉ có thể bị đá ra một hướng (và hướng đó có thể không phải là hướng mà người chơi muốn). XRS giải quyết vấn đề nan giải này bằng cách cho phép người chơi giữ phím di chuyển (Trái / Phải / Thả nhẹ) để hệ thống ưu tiên theo hướng đó. Điều đó làm cho việc điều khiển hướng đi của gạch sau khi wall-kick của người chơi dễ dàng hơn.",
    },
    {">C|Hệ thg đ.khiển",
        "nhom05c",
        "",
        "NHÓM 5C: HỆ THỐNG ĐIỀU KHIỂN"
    },
    {"IRS",
        "nhom05c initialrotationsystem",
        "term",
        "Initial Rotation System\nCho phép bạn giữ phím xoay trong lúc chờ tạo gạch (spawn delay) để gạch được xoay sẵn lúc xuất hiện. Việc này có thể giúp bạn thoát chết trong một vài tình huống."
    },
    {"IHS",
        "nhom05c initialholdsystem",
        "term",
        "Initial Hold System\nCho phép bạn giữ phím Hold trong lúc chờ tạo gạch (spawn delay) để thay gạch sắp tới bằng gạch trong HOLD. Việc này có thể giúp bạn thoát chết trong một vài tình huống.",
    },
    {"IMS",
        "nhom05c initialmovesystem",
        "term",
        "Initial Movement System\n*Chỉ có trên Techmino*\n\nCho phép bạn giữ một phím di chuyển trái phải trong lúc chờ tạo gạch (spawn delay) để gạch xuất hiện cách chỗ ban đầu 1 ô theo hướng được giữ. Việc này có thể giúp bạn thoát chết trong một vài tình huống.\nLưu ý: DAS buộc phải được \"nạp đầy\" trước khi gạch xuất hiện.",
    },
    {">D|Các kiểu xáo",
        "nhom05d",
        "",
        ""
    },
    {"Túi 7",
        "nhom05d bag7 randomgenerator túi 7 gạch; kiểu xáo túi 7 gạch",
        "term",
        "Tên gọi chính thức là \"Random Generator\" (Trình xáo gạch ngẫu nhiên) hay \"7-Bag Generator\" (Kiểu xáo Túi 7 gạch).\nĐây là kiểu xáo hay được sử dụng bởi đa số các xếp gạch hiện đại.\n\nChuỗi gạch sẽ được chia thành các nhóm (túi). Mỗi túi gạch đều có dủ 7 Tetromino nhưng trình tự thì ngẫu nhiên.\nMột vài ví dụ về chuỗi gạch: ZSJLTOI, OTSLZIJ, LTISZOJ.\n\nKiểu xáo này cho phép ngăn chặn tình trạng sự xuất hiện không đồng đều của các viên gạch.",
    },
    {"His",
        "nhom05d historygenerator hisgenerator",
        "term",
        replaceCheckCrossMark[[
Một kiểu xáo gạch được sử dụng nhiều trong series game Tetris: The Grand Master.

Trong kiểu xáo này, cách chọn gạch diễn ra như nhau:
    - Bước 1: Chọn ngẫu nhiên một trong bảy Tetromino.
    - Bước 2: Kiểm tra xem liệu gạch đã bốc trúng có phải là một trong những gạch đã xuất hiện gần nhất không.
        $1: Tới Bước 3
        $2: Nhảy tới Bước 4
    - Bước 3: Cộng 1 vào số lần đã bốc lại, kiểm tra xem liệu số lần đã bốc lại có vượt qua giới hạn tối đa hay không?
        $1: Tới Bước 4
        $2: Nhảy về Bước 1
    - Bước 4: Dùng gạch đã bốc trúng

Kiểu xáo này hay được mô tả bằng "His [A] Roll [B]"
Trong đó:
    - Nhớ A gạch đã xuất hiện gần nhất.
    - Chỉ có thể bốc lại tối đa B lần.
Ví dụ: His4 Roll6
    - Nhớ 4 gạch xuất hiện gần nhất.
    - Chỉ có thể bốc lại tối đa 6 lần.

Trong Techmino, số lần bốc lại gạch bằng một nửa số gạch đã kiểm tra của kiểu/hệ thống xáo.

Kiểu xáo His là phiên bản cải tiến so với kiểu xáo ngẫu nhiên đơn giản và giảm tình trạng chuỗi S và Z liên tục.
        ]],
    },
    {"HisPool [1/2]",
        "nhom05d hispool historypoolgenerator kiểu xáo hispool",
        "term",
        "Một biến thể của kiểu xáo gạch His.\n\nĐi kèm với cơ chế \"Pool\" (Rổ) dựa trên những gạch đã xuất hiện gằn nhất,cho phép gạch chưa được xuất hiện quá lâu có cơ hội xuất hiện cao hơn.\n\nKiểu xáo này giúp ổn định chuỗi gạch và đảm bảo rằng flood & drought không xảy ra quá lâu.\n\nĐộ ổn định của kiểu xáo này tùy thuộc vào chuỗi gạch gần nhất và túi gạch.",
    },
    {"HisPool [2/2]",
        "nhom05d hispool historypoolgenerator kiểu xáo hispool",
        "term",
        replaceCheckCrossMark[[
[Sea: Phần này không có trong Zictionary ngôn ngữ khác!]
Cách hoạt động của kiểu xáo HisPool diễn ra tuần tự như sau:

Bước 1: Lấy một viên gạch ngẫu nhiên trong cái Rổ.
    - Kiểm tra xem gạch vừa bốc có nằm trong số gạch đã chọn hay không?
        $2: Chọn gạch vừa bốc và tới bước 2
        $1: Lặp lại bước 1 cho tới khi thỏa một trong hai điều kiện sau:
            -- Gạch vừa bốc không nằm trong số gạch đã chọn gần nhất.
            -- Hết lượt bốc lại
        Sau khi hết lặp, chọn gạch được bốc trúng gần nhất.

Bước 2: Gạch được bốc trúng sẽ được lấy ra khỏi Rổ.
    - Với mỗi gạch còn lại, cộng 1 vào số lần chưa bốc trúng.
    - Rổ lúc này còn 34 gạch.

Bước 3: Thêm gạch có số lần chưa bốc trúng nhiều nhất vào lại rổ (để đảm bảo số lượng là 35 gạch), và đặt lại số lần chưa bốc trúng của nó về 0

Bước 4: Thêm gạch đã chọn vào chuỗi NEXT cũng như chuỗi gạch đã chọn gần nhất, rồi quay về Bước 1.
        ]],
    },
    {"bagES",
        "nhom05d bages easy start khởi đầu suôn sẻ; kiểu xáo ez-start; kiểu xáo ezstart",
        "term",
        "*Chỉ có trên Techmino*\nTên khác: EZ-Start generator (Khởi đầu suôn sẻ)\n\nMột biến thể của kiểu xáo Túi. Gạch đầu tiên của mỗi túi sẽ không bao giờ là gạch khó đặt: S / Z / O / S5 / Z5 / F / E / W / X / N / H.",
    },
    {"Reverb",
        "nhom05d kiểu xáo reverb",
        "term",
        "*Chỉ có trên Techmino*\nMột biến thể của kiểu xáo Túi. \n\nKiểu xáo Reverb sẽ lặp ngẫu nhiên một vài gạch từ kiểu xáo Túi. Xác suất lặp lại gạch giảm nếu gạch đã xuất hiện và ngược lại\nSố lần lặp lại trên lý thuyết nằm từ 0 tới 6",
    },
    {"C2",
        "nhom05d cultris2generator cultrisiigenerator c2generator",
        "term",
        "Đây là kiểu xáo được dùng trong Cultris II với cách hoạt động như sau:\n\nBước 1. Ban đầu toàn bộ Tetromino sẽ có trọng số (\"weight\") là 0.\n\nBước 2. Cứ sau mỗi lần xáo gạch, toàn bộ trọng số của các gạch sẽ bị chia hết cho 2, và được cộng một số thực ngẫu nhiên từ 0 tới 1.\n\nBước 3. Gạch có trọng số cao nhất, và sau đó trọng số của nó sẽ bị chia cho 3.5.\n\nBước 4: Về Bước 2 và tiếp tục lặp lại",
    },
    {"H. tg. Drought",
        "drought",
        "term",
        "Hiện tượng gạch người chơi đang rất cần nhưng lại không xuất hiện trong thời gian quá dài. Thường dùng để chỉ hiện tượng khát gạch I trong mấy game cổ điển vì chúng thường dùng bộ xáo gạch ngẫu nhiên đơn giản.\n\nHiện nay, ở các game hiện đại, hiện tượng drought không thể xảy ra vì khoảng cách tối đa giữa 2 gạch cùng loại là 13 gạch.",
    },
    {">E|Thông số",
        "nhom05e",
        "",
        ""
    },
    {">E1|Thg số game",
        "nhom05e1",
        "",
        "NHÓM 5E1: THÔNG SỐ GAME"
    },
    {"Tốc độ rơi",
        "nhom05e1 trọng lực falling speed gravity",
        "term",
        [[
Tốc độ gạch rơi xuống. Đơn vị là "G".
Chỉ số hàng gạch rơi xuống trong một khung hình.
Con số này luôn đi kèm với giả thiết là game đang chạy ở 60FPS.

Ví dụ: gạch di chuyển xuống 1 ô / 60 khung hình (1 ô / giây) thì tốc độ rơi là ¹⁄₆₀ G

Tốc độ tối đa của game xếp gạch hiện đại là 20G (bởi vì có 20 hàng trong vùng nhìn thấy được).

Trong Techmino, tốc độ còn được biểu diễn ở dạng số khung hình gạch cần để đi xuống 1 ô.
60 ở hệ thống đó tương đương với 1 ô / 1 giây hoặc 1G.

Trong thực tiễn, "20G" không chỉ "20 ô / giây" mà chỉ "Tốc độ tối đa"
Xem mục tiếp theo để biết thêm.
        ]],
    },
    {"20G",
        "nhom05e1 trọng lực; ngay lập tức; gravity instantly",
        "term",
        "Tốc độ tối đa trong các game xếp gạch hiện đại.\n\nMặc dù nhìn qua thuật ngữ này thể hiện tốc độ rơi là 20 hàng / khung hình, nhưng thật ra chúng được dùng để chỉ tốc độ vô tận.\n\nHơn nữa, trong các chế độ 20G, game sẽ ưu tiên di chuyển gạch xuống đáy hơn là bất cứ thao tác di chuyển nào từ người chơi.\nLấy ví dụ: ngay cả khi ARR được đặt là 0, gạch vẫn cứ di chuyển một mạch xuống phía dưới một cách hồn nhiên giống như người chơi chưa nhấn gì.\nViệc này gây khó cho người chơi khi họ muốn gạch leo ra khỏi hố hoặc nhảy ra khỏi lỗ trong một số tình huống.",
    },
    {"Lockdown Delay",
        "nhom05e1 lockdelay lockdowndelay lockdowntimer ld; thời gian chờ khóa gạch",
        "term",
        "Thời gian chờ khóa gạch, viết tắt là LD.\nĐây là khoảng thời gian ngay sau khi gạch chạm đất và trước khi gạch bị khóa (không thể điều khiển được nữa).\n\nTrong các game xếp gạch cổ điển, khoảng thời gian chờ này = khoảng thời gian gạch cần có để di chuyển xuống 1 ô, và không có cơ chế nào để trì hoãn việc khóa gạch.\n\nTrong các game xếp gạch hiện đại, thời gian chờ được thong thả hơn, và trong game thường có cơ chế trì hoãn việc khóa gạch, trong đó bạn có thể di chuyển hoặc xoay gạch để đặt lại thời gian chờ (tối đa 15 lần trong hầu hết các game).",
    },
    {"Spawn&ClearDelay",
        "nhom05e1 spawndelay cleardelay; thời gian chờ gạch sinh ra; thời gian chờ xóa hàng",
        "term",
        "Spawn Delay (Thời gian chờ gạch sinh ra): Khoảng thời gian từ lúc gạch bị khóa cho tới khi gạch mới được sinh ra.\n\nLine Clear Delay (Thời gian chờ xóa hàng): Thời gian để hiệu ứng xóa hàng thực hiện xong."
    },
    {"ARE",
        "nhom05e1 spawn appearance delay",
        "term",
        "Thời gian chờ xuất hiện gạch mới\nHay còn được biết với tên: Appearance Delay và Entry Delay.\n\n\"ARE\" chỉ khoảng thời gian sau khi gạch bị khóa và trước khi gạch mới xuất hiện\n\nP/s: Từ \"ARE\" không phải là từ viết tắt hay hay là một dạng của \"be\" trong tiếng Anh; nó bắt nguồn từ <あれ> (a-re) trong tiếng Nhật, có nghĩa là \"nó\" hoặc \"cái đó\" / \"cái kia\" / \"cái ấy\".",
    },
    {"Line ARE",
        "nhom05e1 appearance delay",
        "term",
        "Khoảng thời gian khi hiệu ứng xóa hàng bắt đầu chạy cho tới khi gạch mới xuất hiện.",
    },
    {"Death ARE",
        "nhom05e1 die delay",
        "term",
        "Một cơ chế đặc biệt cho phép tránh game over trong một số trường hợp.\n\nDeath ARE sẽ được kích hoạt khi có một viên gạch chặn ngay tại vị trí xuất hiện của gạch mới (dẫn tới hiện tượng block out)\nKhi kích hoạt, spawn ARE sẽ được cộng với một khoảng thời gian bổ sung để cho phép người chơi dùng IRS, IHS hoặc IMS.\n\nÝ tưởng về cơ chế này được đề xuất lần đầu bởi @NOT_A_ROBOT.",
    },
    {">E2|Thg số đ.khiển",
        "nhom05e2",
        "",
        "NHÓM 5E2: THÔNG SỐ ĐIỀU KHIỂN"
    },
    {"DAS&ARR (dễ hiểu)",
        "nhom05e2 das delayedautoshift",
        "term",
        "Tưởng tượng bạn đang gõ chữ, và bạn nhấn giữ phím \"O\".\nVà bạn sẽ nhận được một chuỗi toàn là o.\n\nỞ trên thanh thời gian thì nó trông như thế này: o-----o-o-o-o-o-o-o-o-o…\n\"-----\" là DAS, còn \"-\" là ARR.",
    },
    {"DAS & ARR",
        "nhom05e2 das và arr delayedautoshift autorepeatrate",
        "term",
        "DAS, hay Delayed Auto-shift, chỉ khoảng thời gian sau khi gạch di chuyển sang một hướng đã chọn 1 ô cho đến truớc khi gạch di chuển một cách tự động.\n\nARR, hay Auto-Repeat Rate, chỉ khoảng cách thời gian giữ 2 lần di chuyển sang 1 ô trong lúc gạch đang tự động di chuyển.\n\nDAS và ARR được tính bằng f (khung hình) (¹/₆₀ ở 60FPS). 1ms = 16²/₃ khung hình.",
    },
    {"DAS cut",
        "nhom05e2 dascut dcd",
        "term",
        "Cơ chế đặc biệt sẽ được kích hoạt khi gạch mới xuất hiện. Khi kích hoạt, cơ chế này sẽ tăng DAS lên một chút để gạch không tự di chuyển ngay khi đang có phím được giữ.\n\nCác game khác có thể có tính năng tương tự nhưng cách hoạt động có thể khác nhau.",
    },
    {"Auto-lock cut",
        "nhom05e2 autolockcut",
        "term",
        "Một tính năng trong Techmino cho phép ngăn chặn việc misdrop khi gạch mới vừa xuất hiện. Nút Thả mạnh sẽ bị tắt trong một khoảng thời gian ngắn sau khi gạch trước đó bị khóa.\n\nCác game khác có thể có tính năng tương tự nhưng cách hoạt động có thể khác nhau.",
    },
    {"SDF",
        "nhom05e2 softdropfactor",
        "term",
        "Soft Drop Factor (Hệ số tốc độ rơi nhẹ)\n\nMột cách để xác định tốc độ gạch rơi khi nhấn phím \"Thả nhẹ\". Hầu hết các game xác đinh tốc độ rơi bằng công thức: Tốc độ thả nhẹ = SDF × 20\n\nTuy nhiên trong Techmino, tốc độ thả nhẹ là cố định với thông số SDARR (ARR nhưng dành cho nút \"thả nhẹ\").",
    },
    {">F|Điều khiển",
        "nhom05f",
        "",
        "",
    },
    {">F1|Tốc độ đ.khiển",
        "nhom05f1",
        "",
        "NHÓM 5F1: TỐC ĐỘ ĐIỀU KHIỂN",
    },
    {"LPM",
        "nhom05f1 linesperminute; số hàng mỗi phút; tốc độ",
        "term",
        "Lines per minute | Số hàng mỗi phút\nPhản ánh tốc độ chơi.\n\nMỗi game có cách tính LPM khác nhau. Ví dụ như, Tetris Online tính LPM dựa trên PPS (nhìn mục ở bên dưới), trong đó 1 PPS = 24 LPM; do đó số hàng rác sẽ không được tính vào LPM và làm cho LPM lệch đi so với nghĩa đen của nó. Trong Techmino, giá trị LPM theo cách tính đó gọi là \"L'PM\"",
    },
    {"PPS",
        "nhom05f1 piecespersecond số gạch mỗi giây; tốc độ",
        "term",
        "Pieces per second | Số gạch mỗi giây\nPhản ánh tốc độ chơi.",
    },
    {"BPM",
        "nhom05f1 blocksperminute piecesperminute số gạch mỗi phút; tốc độ",
        "term",
        "Blocks per minute | Số gạch mỗi phút\nPhản ánh tốc độ chơi.\n\nNgoài ra chúng được gọi là PPM (để tránh nhầm lẫn với một thuật ngữ trong âm nhạc) (P là viết tắt của từ Pieces).",
    },
    {"KPM",
        "nhom05f1 keysperminute keypressesperminute số lần nhấn mỗi phút; số phím mỗi phút",
        "term",
        "Keypresses per minute | Số lần nhấn mỗi phút\nPhản ánh tốc độ người chơi nhấn phím hoặc nút.",
    },
    {"KPP",
        "nhom05f1 số lần nhấn mỗi gạch; số phím mỗi gạch",
        "term",
        "Keypresses per piece | Số lần nhấn mỗi viên gạch\nPhản ánh mức độ hiệu quả việc điều khiển gạch.\nCó thể giảm con số này bằng cách học Finesse",
    },
    {">F2|K.th. đ.khiển",
        "nhom05f2",
        "",
        "NHÓM 5F2: KỸ THUẬT ĐIỀU KHIỂN",
    },
    {"Finesse",
        "nhom05f2 finesse lỗi di chuyển",
        "term",
        [[
Một kỹ thuật di chuyển gạch vào vị trí mong muốn với chuỗi phím ngắn nhất có thể, giúp tiết kiệm thời gian và giảm khả năng misdrop.

Đây là một kỹ năng quan trọng nên bạn hãy học Finesse sớm nhất có thể. Bạn có thể thấy khá nhiều video hướng dẫn trên Youtube cũng như các trang hướng dẫn với hình minh họa trên Google. Hãy bắt đầu từ thứ cơ bản nhất, rồi luyện tập dần để tăng độ chính xác lên. Hãy nhớ ưu tiên chính xác hơn là tốc độ nhé.

Bạn sẽ không bị mất Finesse khi bạn nhét gạch hay thực hiện Spin vì Techmino chỉ kiểm tra những vị trí không yêu cầu soft drop

Techmino cũng có finesse rate (%) (tỉ lệ *không* mắc lỗi di chuyển), được tính như sau:
    - 100% (Perfect) khi số lần nhấn phím bằng hoặc ít hơn mức chuẩn
    - 50% (Great) khi số lần nhấn phím cao hơn mức chuẩn 1 phím
    - 25% (Bad) khi số lần nhấn phím cao hơn mức chuẩn 2 phím
    - 0% (Miss) khi số lần nhấn phím cao hơn mức chuẩn 3 phím
Một Bad hoặc Miss sẽ phá combo finesse.

Lưu ý:
    - Finesse thường sẽ không được tính trong một vài tình huống như tốc độ rơi cao, phải sử dụng thả nhẹ hay bảng rất cao. Tuy nhiên, bộ đếm finesse của Techmino vẫn chạy bất chấp ở điều kiện nào (kể cả tốc độ rơi cao như 20G). Do vậy finesse rate thường sẽ không mang ý nghĩa gì trong trường hợp này.
    - Bạn sẽ không bị mất Finesse khi bạn nhét gạch hay thực hiện Spin vì Techmino chỉ kiểm tra những vị trí không yêu cầu soft drop
        ]],
    },
    {"Hypertapping",
        "nhom05f2 hypertapper nhấn liên tục",
        "term",
        "Hypertapping (Nhấn liên tục)\n\nĐề cập tới một kỹ năng là khi bạn rung tay liên tục thay vì giữ phím.\n\nTrong các game xếp gạch cổ điển, thông số DAS rất cao và không thể điều chỉnh được, dẫn tới nhấn nút liên tục sẽ nhanh hơn so với giữ phím.\nBây giờ thì không cần vì các game xếp gạch hiện đại đã có DAS và ARR có thể điều chỉnh được (nếu có chăng không điều chỉnh được thì DAS cũng đã thấp hơn nhiều so với ngày trước)\n\nNhững người dùng kỹ năng này được gọi là \"hypertapper\"",
    },
    {"Rolling",
        "nhom05f2",
        "term",
        [[
Một phương pháp khác để di chuyển nhanh ở chế độ trọng lực cao (khoảng 1G) (với cài đặt DAS / ARR chậm).

Để thực hiện thao tác rolling:
    - Cố định ngón tay của bạn trên phím bạn muốn nhấn ở một bên tay
    - Sau đó dùng các ngón tay ở bên kia gõ mạnh liên tục ở mặt sau của tay cầm.

Phương pháp này nhanh hơn nhiều so với việc nhấn liên tục (xem mục "Hypertapping" để biết thêm thông tin) và yêu cầu ít công sức hơn.
Phương pháp này lần đầu tiên được tìm thấy bởi Cheez-fish - người đã đạt tốc độ nhấn lên tới 20 Hz.
        ]],
    },
    {">F3|Độ trễ input",
        "nhom05f3 input delay",
        "",
        "Độ trễ đầu vào\n\nBất kỳ thiết bị đầu vào cũng cần một khoảng thời gian để tín hiệu có thể tới game, không cao thì thấp, từ mấy ms đến cả trăm ms.\n\nNếu độ trễ đầu vào quá cao, thì việc điều khiển sẽ không thoải mái.\n\nĐộ trễ này thường do phần cứng và phần mềm, thứ mà bạn gần như không kiểm soát được. Hiệu ứng này dễ thấy nhất ở trong các game như Tetris Online hay Tetris Effect.\n\nBật chế độ Hiệu suất cao (Performance mode) hoặc tắt chế độ tiết kiệm năng lượng (Energy saving), đồng thời bật chế độ Gaming trên màn hình máy tính / TV, có thể giúp giảm độ trễ.",
    },
    {">G|K.năng t.công",
        "nhom05g",
        "",
        "NHÓM 5G: KHẢ NĂNG TẤN CÔNG"
    },
    {"APM",
        "nhom05g attackperminute; số hàng tấn công mỗi phút; số hàng tấn công trong một phút",
        "term",
        "Attack per minute\n\tSố hàng tấn công trung bình mà một người chơi có thể tạo ra mỗi phút (bất kể đó là đòn tấn công hoặc chỉ dùng để hủy đòn tấn công của đối thủ)\n\nPhản ánh sức mạnh tấn công của người chơi",
    },
    {"SPM",
        "nhom05g linessentperminute; số hàng gửi mỗi phút; số hàng gửi trong một phút.",
        "term",
        "[lines] Sent per minute\n\tSố hàng tấn công trung bình mà được gửi vào đối thủ trong một phút.\n\nPhản ánh sức mạnh tấn công \"thực tế\" của người chơi (không tính các hàng dùng để chặn rác tới).",
    },
    {"DPM",
        "nhom05g digperminute defendperminute số hàng đào xuống mỗi phút; số hàng đào xuống trong một phút",
        "term",
        "Dig / Defend per minute\n\tSố hàng đào xuống trung bình mỗi phút\n\nĐôi khi có thể phản ánh mức độ sống sót của người chơi khi nhận được rác",
    },
    {"RPM",
        "nhom05g receive; receiveperminute; số hàng rác phải nhận mỗi phút; số rác phải nhận mỗi phút; số hàng rác phải nhận trong một phút; số rác phải nhận trong mỗi phút",
        "term",
        "[lines] Receive per Minute\n\tSố hàng rác trung bình nhận được mỗi phút\n\nPhản ánh áp lực hiện có của người chơi phải chịu ở một mức độ nào đó.",
    },
    {"ADPM",
        "nhom05g attackdigperminute vs; số hàng tấn công và đào xuống mỗi phút; số hàng tấn công và đào xuống mỗi phút",
        "term",
        "Attack & Dig per minute\n\tSố hàng tấn công & đào xuống trung bình mỗi phút\n\nDùng để so sánh sự khác nhau về kỹ năng của hai người chơi trong cùng một trận đấu; chính xác hơn một chút so với APM\n\nVS Score (điểm VS) trong TETR.IO chính là ADPM mỗi 100 giây",
    },
    {"APL",
        "nhom05g attackperline efficiency; số hàng tấn công; số hàng đã xóa; độ hiệu quả",
        "term",
        "Attack per line (cleared)\n\tSố hàng tấn công / Số hàng đã xóa\n\nCòn được biết với tên \"efficiency\" (độ hiệu quả). Phản ánh độ hiệu quả khi tấn công sau mỗi lần xóa hàng.\nVí dụ Tetris và T-spin có độ hiệu quả cao hơn so với xóa 2 / 3 hàng.",
    },
    {"Tấn công&Phg thủ",
        "nhom05g attacking defending phòng thủ; tấn công & phòng thủ; tấn công và phòng thủ",
        "term",
        [[
Tấn công: Gửi hàng rác tới đối thủ bằng cách gửi nhiều hàng.

Phòng thủ: Loại hàng rác ra khỏi hàng chờ bằng cách thực hiện các kiểu xóa đặc biệt sau khi đối thủ gửi hàng rác.

Phản công: Gửi hàng rác lại sau khi xử xong toàn bộ hàng rác trong hàng chờ.

Trong hầu hết các game, tấn công và phòng thủ là tương đương nhau: một đòn tấn công sẽ chặn một cú rác tới.
        ]],
    },
    {"Combo",
        "nhom05g ren combo",
        "term",
        "Xóa nhiều hàng liên tiếp để tạo ra combo. Từ lần xóa hàng thứ 2 thì tính là 1 Combo, và từ lần xóa hàng thứ 3 thì tính là 2 Combo, và cứ như thế.\nKhông như Back to Back, đặt một viên gạch = phá combo.\n\nỞ cộng đồng xếp gạch Nhật, combo được gọi là \"REN\", từ chữ kanji tiếng Nhật <連> (れん, ren).",
    },
    {"Spike",
        "nhom05g spike",
        "term",
        "Làm nhiều đợt tấn công liên tiếp trong một khoảng thời gian ngắn.\n\nCả Techmino và TETR.IO đều có bộ đếm spike, sẽ hiện bao nhiêu hàng rác bạn đã gửi cho đối thủ trong lúc spike.\n\nLưu ý: hàng rác mà bị tích lũy do mạng lag thì không được tính là spike.",
    },
    {"'Debt'",
        "nhom05g debt owe",
        "term",
        "Một thuật ngữ hay được sử dụng trong cộng đồng Tetris Trung Quốc.\n\n\"Debt\" đề cập đến tình huống mà bạn chỉ có thể tấn công KHI và CHỈ KHI setup được hoàn thành. Nên, khi đang làm một hoặc nhiều debt liên tiếp, người chơi bắt buộc phải để ý tới đối thủ để đảm bảo an toàn; còn không, bạn có thể bị bón hành sấp mặt.\n\nThuật ngữ này hay được sử dụng để diễn tả một số setup như TST tower.",
    },
    {"Passthrough",
        "nhom05g pingthrough",
        "term",
        "Chỉ tình huống cả hai người chơi cùng gửi tấn công lẫn nhau, nhưng thay vì chúng hủy bỏ lẫn nhau thì nó lại gửi thẳng vào bảng của đối phương.\n\nMột thuật ngữ khác là \"pingthrough\" đề cập tình huống passthrough xảy ra do ping cao.",
    },
    {"Timing",
        "nhom05g",
        "term",
        "Timimg đề cập đến việc lựa chọn khoảnh khắc để tấn công với nỗ lực tối ưu. Chọn đúng thời điểm cho phép bạn có thể phòng thủ trong khi đè bẹp đối thủ của bạn. Tuy nhiên, chúng tôi đề nghị những người chơi mới tập trung vào bảng và cải thiện tốc độ trước khi tập trung vào timing."
    },
    {">H|Mis-action",
        "nhom05h misaction misdrop mishold",
        "",
        "Misdrop: Vô tình thả rơi / đặt gạch vào nơi không mong muốn.\nMishold: Vô tình nhấn nhầm phím Hold. Việc này có thể dẫn đến việc dùng một viên gạch không mong muốn.\n\nCả misdrop và mishold có thể làm bạn mất cơ hội để làm PC"
    },
    {">I|Spin",
        "nhom05i",
        "",
        "(Ở trong một số game)\n\nXoay gạch để di chuyển tới một vị trí mà bình thường sẽ không tiếp cận được. Ở một số game, thao tác này sẽ gửi thêm hàng rác hoặc là tăng thêm điểm. Mỗi game sẽ có cách kiểm tra Spin khác nhau."
    },
    {"Mini",
        "nhom05i",
        "term",
        "Một kiểu spin (được cho là) dễ làm hơn so với spin thông thường (vì trong một số game cũ, chúng được gọi là \"Ez T-spin\").\nLượng điểm bổ sung và hàng rác đều ít hơn so với spin thông thường.\n\nMỗi game sẽ có các quy tắc khác nhau để kiểm tra và chúng có thể không trực quan.\nNhưng bạn chỉ cần nhớ mấy cái bố cục làm Mini-spin là được!",
    },
    {"All-spin",
        "nhom05i allspin",
        "term",
        "Một quy luật mà trong đó, làm Spin bằng gạch gì đều cũng được thưởng thêm điểm và gửi thêm hàng rác; trái ngược với\"T-spin Only\" (Chỉ làm T-spin).",
    },
    {"T-spin",
        "nhom05i tspin",
        "term",
        "Spin được thực hiện bởi Tetromino T.\n\nT-spin chủ yếu được phát hiện bởi \"quy luật 3 góc\".\nTức là, nếu 3 trong 4 góc của một hình chữ nhật (có tâm là tâm xoay của gạch T) bị đè bởi bất kỳ gạch nào, thì spin đó được tính là T-spin.\n\nNgoài quy tắc đó ra thì còn có một số quy tắc để phát hiện T-spin và phân biệt giữa T-spin và Mini T-spin.",
    },
    {"O-Spin",
        "nhom05i ospin",
        "term",
        "Gạch O vốn dĩ \"tròn\", không đổi hình dạng khi xoay ở bất cứ hướng nào, nên nó không thể \"đá\" được. Do đó gạch O không tài nào leo ra khỏi \"lỗ\" hoặc \"hố\" nếu bị kẹt. Từ việc này, có một người đã làm một cái video fake cách làm O-spin trong Tetris 99 và Tetris Friends\n\nHiện tại có 2 hệ thống xoay hỗ trợ O-spin:\n\tXRS cho phép gạch O có thể \"teleport\" tới một cái lỗ.\n\tTRS cho phép gạch O \"teleport\" và \"biến hình\"",
    },
    {"Fin, Neo, Iso",
        "nhom05i fin neo iso",
        "pattern",
        "Tên của 3 kiểu T-spin sử dụng wall-kick table đặc biệt của gạch T. Chúng không được sử dụng nhiều trong game bởi vì độ phức tạp và thường hay bị nerf bởi đa số game."
    },
    {"Freestyle",
        "nhom05i",
        "term",
        "Thuật ngữ hay được nhắc nhiều trong thử thách 20TSD. Freestyle là kiểu chơi không dùng setup nào để hoàn thành một số lượng TSD nhất định nào đó.\n\nFreestyle khó hơn nhiều so với việc sử dụng setup nào đó như LST\nNhững màn chạy dùng Freestyle có thể phản ánh cho các kỹ năng T-spin của người chơi trong các trận đấu trong thế giới thực.",
    },

    {">J|K.th. xóa hàng",
        "nhom05j",
        "",
        "NHÓM 5J: KỸ THUẬT XÓA HÀNG"
    },
    {"Xóa 1 / 2 / 3 hàng",
        "nhom05j 1 2 3 single double triple",
        "term",
        "Single: Xóa 1 hàng cùng một lúc.\nDouble: Xóa 2 hàng cùng lúc.\nTriple: Xóa 3 hàng cùng lúc.",
    },
    {"Techrash",
        "nhom05j tetris 4",
        "term",
        "*Chỉ có trên Techmino*\nXóa 4 hàng cùng một lúc.",
    },
    {"Tetris",
        "nhom05j 4",
        "term",
        "Đây chính là tên của một tựa game (và cũng là tên thương hiệu của nó). Đây cũng là thuật ngữ chỉ việc xóa 4 hàng cùng lúc trong các game chính thức.\n\nĐược ghép từ 2 từ: Tetra (<τέτταρες>, \"téttares\", có nghĩa là số 4 trong tiếng Hy Lạp) and tennis (quần vợt, môn thể thao yêu thích nhất của người đã sáng tạo ra Tetris).\n\nNhắc nhẹ: những game xếp gạch được phát triển bởi Nintendo và SEGA đều được cấp phép bởi TTC. Hai công ty này không (hề) sở hữu bản quyền của Tetris",
        -- _comment: original Lua file had this comment: "Thanks to Alexey Pajitnov!"
    },
    {"TSS, TSD, TST",
        "nhom05j t1 tspinsingle T-spin Đơn t2 tspindouble T-spn Đôi t3 tspintriple T-spin Tam",
        "term",
        "T-spin Single (TSS) | T-spin Đơn\n\tXóa một hàng bằng T-spin.\n\nT-spin Double (TSD) | T-spin Đôi\n\tXóa hai hàng bằng T-spin.\n\nT-spin Triple (TST) | T-spin Tam\n\tXóa ba hàng bằng T-spin."
    },
    {"MTSS",
        "nhom05j mintspinsingle tsms tspinminisingle Mini T-spin Đơn",
        "term",
        "Mini T-spin Single | Mini T-spin Đơn\nTừng biết tới với cái tên \"T-spin Mini Single\" (TSMS) (T-spin Mini Đơn).\n\nXóa một hàng bằng Mini T-spin.\n\nMỗi game sẽ có cách khác nhau để xác định xem T-spin đó có phải là Mini hay không.",
    },
    {"MTSD",
        "nhom05j minitspindouble tsmd tspinminidouble Mini T-spin Đôi",
        "term",
        "Mini T-spin Double | Mini T-spin Đôi\nTừng biết tới với cái tên \"T-spin Mini Double\" (TSMD) (T-spin Mini Đôi).\n\nXóa hai hàng bằng Mini T-spin.\n\nMTSD chỉ xuất hiện hạn chế trong một vài game và có các cách kích hoạt khác nhau.",
    },
    {"Back to Back",
        "nhom05j b2b btb backtoback",
        "term",
        "Hay còn gọi là B2B. Xóa 2 hoặc nhiều lần xóa theo kiểu nâng cao (như Tetris hay Spin) liên tiếp (nhưng không được kiểu xóa bình thường giữa chừng).\nKhông như combo, Back To Back sẽ không bị mất khi đặt gạch.\n\nỞ Techmino, B2B được tính bằng thanh năng lượng, chứ không tính theo số lần xóa kiểu đặc biệt.\nCũng trong Techmino, nhiều B2B liên tiếp được tính là Back-to-back-to-back (B3B) (xem mục B2B2B để biết thêm).\n\nTechmino cũng tính cả PC và HPC liên tiếp là B2B và B3B",
    },
    {"B2B2B",
        "nhom05j b3b backtobacktoback",
        "term",
        "*Chỉ có trên Techmino*\n\nBack to back to back, hay còn gọi là B3B (hoặc B2B2B). Thực hiện nhiều Back to Back liên tiếp để lấp đầy thanh B3B; cuối cùng khi bạn đã lấp B3B vượt một mức nhất định, bạn có thể tấn công mạnh hơn khi làm được B2B, nhờ sức mạnh từ B3B",
    },
    {"All Clear",
        "nhom05j pc perfectclear ac allclear",
        "term",
        "Còn được biết tới là Perfect Clear (PC). Đây là thuật ngữ được dùng nhiều trong cộng đồng và cũng như được dùng trong Techmino\nXóa toàn bộ gạch ra khỏi bảng, không trừ gạch nào\n\n[Sea: còn có một từ ít dùng nữa, đó là \"Bravo\"]",
    },
    {"HPC",
        "nhom05j hc halfperfectclear",
        "term",
        "*Chỉ có trên Techmino*\nHalf Perfect Clear\n\nMột biến thể của All Clear. Nếu hàng đó bị xóa mà rõ ràng giống với Perfect Clear khi bỏ qua những hàng bên dưới, thì được tính là Half Perfect Clear và sẽ gửi thêm một lượng hàng rác nhỏ",
    },
    {">K|T.ngữ khác",
        "nhom05k",
        "",
        "NHÓM 5L: CÁC THUẬT NGỮ KHÁC"
    },
    {"sub",
        "nhom05k sub",
        "term",
        "Sub-[số] có nghĩa là khoảng thời gian ở dưới một mốc nhất định. Đơn vị thời gian thường được bỏ qua và có thể tự suy ra.\n\nVí dụ: \"sub-30\" có nghĩa là hoàn thành chế độ 40 hàng dưới 30 giây, \"sub-15\" có nghĩa là hoàn thành chế độ 1000 hàng dưới 15 phút.\n\n\"Sub\" thường được sử dụng với số đã được làm tròn (cho nên hiếm khi người ta sử dụng theo kiểu \"sub-62\")",
    },
    {"‘Researching’",
        "nhom05k scientificresearching",
        "term",
        "(<科研>, ké yán)\n\nMột thuật ngữ đôi khi được dùng ở cộng đồng Tetris Trung Quốc, chỉ việc nghiên cứu / luyện tập kỹ thuật nào đó (ví dụ như một setup T-spin mới) trong môi trường chơi đơn và tốc độ rơi thấp…\nTrong Techmino, thuật ngữ này chỉ những mode đòi hỏi bạn gần như phải dùng spin trong suốt màn chạy.",
    },
    {"Bone block",
        "nhom05k bone tgm",
        "term",
        [[
Đây là skin được dùng trong những phiên bản đời đầu của Tetris

Trước đây, tất cả máy tính đều sử dụng Giao diện Dòng lệnh (Command-Line Interfaces), cho nên mỗi ô gạch đều được hiển thị dưới dạng 2 ngoặc vuông (như thế này: ]]..CHAR.icon.bone..[[).
Trông nó nhìn rất giống cục xương, nên đôi khi được gọi là skin bone block (gạch xương).

Trong Techmino, bone block được mô tả là "một skin gạch duy nhất, lạ mắt mà tất cả các gạch đều sử dụng".
Skin khác nhau sẽ có skin bone block khác nhau.

Cũng trong Techmino nhưng ở tiếng Việt, từ "gạch ]]..CHAR.icon.bone..[[" được dùng để chỉ bone block.
        ]],
    },
    {"=[NHÓM 06]=",
        "nhom06",
        "",
        [[
NHÓM 06: CÁC GAME XẾP GẠCH

Nội dung sau đây là những giới thiệu ngắn gọn về một số game xếp gạch chính thức và do fan làm có mức độ phổ biến cao. MrZ - tác giả của Techmino đã để lại một vài lời nhận xét, được đánh dấu chủ yếu bằng hai dấu ngoặc vuông

Squishy cũng có một số lời nhận xét và thông tin bổ sung, lời này được đánh dấu bắt đầu bằng "Sea" và ở trong một cặp ngoặc vuông

Hãy nhớ là không phải game nào được nói đến đều có lời nhận xét, chúng chỉ là những ý kiến chủ quan và không có tính chuyên môn, và cũng không nhất thiết phản ánh chất lượng của game. Chỉ đọc / dùng để tham khảo.
        ]]
    },
    {"King of Stackers",
        "nhom06 kos kingofstackers",
        "game",
        [[
Chơi trên trình duyệt | Chơi trực tuyến | Hỗ trợ màn hình cảm ứng

Gọi tắt là KoS. Một game xếp gạch chơi trên trình duyệt theo lượt. Về cơ bản: người chơi sẽ thay phiên nhau đặt các gạch trong bảng của họ theo chu kỳ 7 gạch. Hàng rác chỉ có thể vào bảng khi một gạch được đặt mà không xóa một hàng nào. Trò chơi mang tính chiến lược cao và có các tùy chọn khác nhau cho cơ chế tấn công.
        ]],
        "https://kingofstackers.com/games.php",
    },
    {"Tetr.js",
        "nhom06 tetrjs tetr.js",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn | Hỗ trợ màn hình cảm ứng

Một game xếp gạch chơi trên trình duyệt với nhiều điều chỉnh và chế độ chuyên nghiệp.
Liên kết của mục này sẽ đưa bạn tới bản của Farter (bản này là một bản đã mod, đã thêm một vài chế độ khác)
Bạn cũng có thể tìm một phiên bản khác có tên là "Tetr.js Enhanced" - bản mod này do Dr Ocelot làm (đã bị gỡ xuống và thay thế bằng Tetra Legends, nhưng cũng bị dừng phát triển hoàn toàn từ T12 / 2020)

[MrZ: Giao diện đơn giản với hầu như không có bất kỳ animation nào.
Chỉ có một số tổ hợp phím ảo khả dụng cho thiết bị di động.]
        ]],
        "http://farter.cn/t",
    },
    {"Tetra Legends",
        "nhom06 tl tetralegends",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn

Gọi tắt là TL. Một tựa game chứa nhiều chế độ chơi đơn + 2 chế độ nhịp điệu. Nó cũng hình dung các cơ chế thường ẩn trong các trò chơi Tetris khác. Quá trình phát triển đã dừng lại hoàn toàn từ T12 / 2020.
        ]],
        "https://tetralegends.app",
    },
    {"Ascension",
        "nhom06 asc",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn / Chơi trực tuyến

Gọi tắt là ASC. Game sử dụng hệ thống xoay có tên là ASC và có nhiều chế độ chơi đơn. Chế độ 1 đấu 1 hiện vẫn còn trong giai đoạn Alpha (tính tới 16 / T4 / 2022).
Chế độ Stack của Techmino cũng bắt nguồn từ game này.
        ]],
        "https://asc.winternebs.com",
    },
    {"Jstris",
        "nhom06 js",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn / Chơi trực tuyến | Hỗ trợ cảm ứng

Gọi tắt là JS. Game này có một số chế độ chơi đơn với thông số có thể điều chỉnh được. Có thể điều chỉnh phím ảo trên màn hình, nhưng trò chơi này không có hiệu ứng động nào cả.
        ]],
        "https://jstris.jezevec10.com",
    },
    {"TETR.IO",
        "nhom06 io tetrio",
        "game",
        [[
Chơi trên trình duyệt / client chính thức | Chơi đơn / Chơi trực tuyến

Gọi tắt là tetrio hoặc IO. Trò chơi này có một hệ thống xếp rank cũng như có chế độ tự do với nhiều thông số có thể tùy chỉnh. Trò chơi này cũng có một client dành cho máy tính, giúp cải thiện tốc độ, giảm độ trễ và bỏ quảng cáo

[MrZ: Có vẻ như Safari không thể mở game này.]
        ]],
        "https://tetr.io",
    },
    {"Nuketris",
        "nhom06",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn / Chơi trực tuyến

Một trò xếp gạch có chế độ 1 đấu 1 có xếp rank + các chế độ chơi đơn thông thường
        ]],
        "https://nuketris.com",
    },
    {"Worldwide Combos",
        "nhom06 wwc worldwidecombos",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn / Chơi trực tuyến

Gọi tắt là WWC. Có chế độ 1 đấu 1 toàn cầu: chơi với người thật hoặc chơi với replay; có vài quy tắc khác nhau, với các trận đấu gửi rác bằng bom."
        ]],
        "https://worldwidecombos.com",
    },
    {"Tetris Friends",
        "nhom06 tetris friends tf tetrisfriends notrisfoes",
        "game",
        [[
Chơi trên trình duyệt / client chính thức | Chơi đơn / Chơi trực tuyến

Gọi tắt là TF. Một game xếp gạch dùng engine là một plugin đã nghỉ hưu từ năm 2021 (vì vấn đề bảo mật). Từng rất phổ biến trong quá khứ, nhưng tất cả máy chủ chính thức đã đóng cửa từ mấy năm trước. Hiện giờ vẫn còn một máy chủ riêng tên là "Notris Foes". Nhấn vào nút hình địa cầu để mở ở trong trình duyệt
        ]],
        "https://notrisfoes.com",
    },
    {"tetris.com [1 / 2]",
        "nhom06 tetris tetris.com online official",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn | Hỗ trợ màn hình cảm ứng

Game Tetris chính thức từ tetris.com, mà chỉ có một chế độ (Marathon). Bù lại, có hỗ trợ hệ thống điều khiển thông minh bằng chuột
        ]],
    },
    {"tetris.com [2 / 2]",
        "nhom06 tetris tetris.com online official",
        "game",
        [[
[Mục này được viết bởi Squishy, chỉ xuất hiện ở bản dịch Zictionary này
Có thể áp dụng cho "Tetris Gems" và "Tetris Mind Bender"]

Hiện có ba cách điều khiển: hai cách dành cho màn hình cảm ứng gồm "vuốt" (swipe) và "thông minh" (smart), hoặc cắm bàn phím (nếu máy hỗ trợ).
Bạn có thể thử nghiệm với cả ba chế độ điều khiển để tìm xem chế độ nào tối ưu với mình nhất

Để điều khiển bằng bàn phím thì hãy kết nối bàn phím (miễn là điện thoại nhận được bàn phím thì game cũng sẽ nhận)
Để đổi giữa "vuốt" và "thông minh" thì hãy mở Options của game.
        ]]
    },
    {"Tetris Gems",
        "nhom06 tetris online official gem",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn | Hỗ trợ màn hình cảm ứng

Một game xếp gạch khác từ tetris.com
Có cơ chế trọng lực và mỗi ván chỉ kéo dài trong 1 phút. Có 3 loại gem (ngọc) khác nhau với chức năng khác nhau.
        ]],
    },
    {"Tetris Mind Bender",
        "nhom06 tetris online official gem",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn | Hỗ trợ màn hình cảm ứng

Một game xếp gạch khác từ tetris.com
Một chế độ Marathon vô tận với một mino đặc biệt gọi là "Mind Bender" sẽ đưa cho bạn ngẫu nhiên một hiệu ứng nào đó (có thể là tốt hoặc xấu).
        ]],
    },
    {"Techmino",
        "nhom06",
        "game",
        [[
Đa nền tảng | Chơi đơn / Chơi trực tuyến

Gọi tắt là Tech. Một tựa game xếp gạch được phát triển bởi MrZ (và các thành viên khác trong 26F-Studio). Sử dụng engine LÖVE (love2d). Có rất nhiều chế độ chơi đơn, cũng như có nhiều thông số có thể tùy chỉnh được. Tuy nhiên, chế độ nhiều người chơi hiện tại vẫn đang còn phát triển
        ]],
    },
    {"Falling Lightblocks",
        "nhom06 fl fallinglightblocks",
        "game",
        [[
Chơi trên trình duyệt / iOS / Android | Chơi đơn / Chơi trực tuyến

Một game xếp gạch đa nền tảng có thể chơi ở chế độ dọc hoặc ngang. Game này có DAS và ARE khi xóa hàng cố định; và có thể điều chỉnh cơ chế điều khiển trên điện thoại. Hầu hết các chế độ trong game đều được thiết kế dựa trên NES Tetris, nhưng cũng có vài chế độ hiện đại. Chế độ Battle theo kiểu nửa "theo lượt", nửa "theo thời gian thực", rác cũng không vào hàng chờ hay có thể hủy được.
        ]],
        "https://golfgl.de/lightblocks/",
    },
    {"Cambridge",
        "nhom06",
        "game",
        [[
Đa nền tảng | Chơi đơn

Một game xếp gạch được phát triển bằng LÖVE, với mục tiêu là tạo ra một nền tảng mạnh mẽ, dễ dàng tùy chỉnh để tạo ra các chế độ mới. Ban đầu được phát triển bởi Joe Zeng, Milla đã tiếp quản quá trình phát triển từ 08 / T10 / 2020, kể từ V0.1.5.

- Tetris Wiki
        ]],
    },
    {"Nanamino",
        "nhom06",
        "game",
        [[
Windows / Android | Chơi đơn

Một trò chơi do fan làm đang được phát triển với hệ thống xoay đặc trưng cực kỳ thú vị,
        ]],
    },
    {"TGM",
        "nhom06 tetrisgrandmaster tetristhegrandmaster",
        "game",
        [[
Máy thùng, và các hệ máy khác* | Chơi đơn / Chơi hai người

Tetris: The Grand Master, một series Tetris dành cho máy thùng, nổi tiếng với độ khó cực cao - được xem là series game khó nhất (tại thời điểm ra mắt). Những thứ như S13 hay GM cũng từ chính series này. TGM3 được coi là tựa game nổi tiếng nhất của series này.

(*): Hiện TGM1 và TGM2 đã được port sang PS và Switch dưới gói Arcade Archives.
        ]],
    },
    {"DTET",
        "nhom06",
        "game",
        [[
Windows | Chơi đơn

Một game xếp gạch dựa trên quy tắc Cổ điển của TGM + 20G với hệ thống xoay gạch mạnh mẽ. Cơ chế điều khiển tốt nhưng không có tùy chỉnh nào ngoài việc có thể gán lại phím.

Game này bây giờ hơi khó tìm và bạn có thể phải cài tệp DLL cần thiết bằng tay. Tuy nhiên cũng may là có một bài hướng dẫn cách cài DTET, bạn có thể nhấn nút hình địa cầu để mở bài viết.

CẢNH BÁO: Hãy cẩn thận khi tải bất cứ thứ gì về, kể cả file DLL hay EXE!
        ]],
        "https://t-sp.in/dtet"
    },
    {"Heboris",
        "nhom06 hb",
        "game",
        [[
Windows | Chơi đơn

Một game với phong cách chơi máy thùng, có khả năng mô phỏng nhiều chế độ của các trò chơi Tetris khác.
        ]],
    },
    {"Texmaster",
        "nhom06 txm",
        "game",
        [[
Windows | Chơi đơn

Một game có tất cả chế độ trong TGM để có thể sử dụng để luyện chơi TGM. Cần lưu ý rằng World Rule trong Texmaster sẽ hơi khác một chút so với TGM, ví dụ như game sử dụng cơ chế "Thả nhẹ-khóa tức thì"* thay vì sử dụng cơ chế "Thả nhẹ" thông thường và bảng kick cũng có đôi chút khác biệt

(*): Bản Zictionary tiếng Anh ghi là "instant-lock soft drop(s)". Có thể hiểu là bạn giữ nút Thả nhẹ, gạch vừa chạm đất là chốt vị trí đó luôn - giống với các game xếp gạch cổ điển.
        ]],
    },
    {"Tetris Effect",
        "nhom06 tec tetriseffectconnected",
        "game",
        [[
PS / Oculus Quest / Xbox / NS / Windows | Chơi đơn / Chơi trực tuyến

Gọi tắt là TE(C). Một game xếp gạch chính thức với đồ họa và nhạc nền lạ mắt chuyển động theo điều khiển của bạn. Phiên bản cơ bản (Tetris Effect) chỉ có các chế độ chơi đơn. Phiên bản mở rộng, Tetris Effected Connected có 4 chế độ chơi trực tuyến đó là: Connected (VS), Zone Battle, Score Attack, và Classic Score Attack.
        ]],
    },
    {"Tetris 99",
        "nhom06 t99 tetris99",
        "game",
        [[
Nintendo Switch | Chơi đơn / Chơi trực tuyến

Một trò chơi nổi tiếng với chế độ Battle Royale 99 người và có nhiều chiến lược thú vị mà không có trong các game chiến đấu truyền thống. Nó cũng có các chế độ chơi đơn hạn chế như Marathon hay các trận đấu bot có sẵn dưới dạng DLC.
        ]],
    },
    {"Puyo Puyo Tetris",
        "nhom06 ppt puyopuyotetris",
        "game",
        [[
PS / NS / Xbox / Windows | Chơi đơn / Chơi trực tuyến

Đây là một game được ghép từ hai trò chơi giải đố: Tetris và Puyo Puyo, và bạn có thể chơi đối đầu trong cả hai game này. Có nhiều chế độ chơi đơn và chơi trực tuyến.

[MrZ: Bản PC (Steam) có cơ chế điều khiển và trải nghiệm trực tuyến khá là tệ.]
        ]],
    },
    {"Tetris Online",
        "nhom06 top tetrisonline",
        "game",
        [[
Windows | Chơi đơn / Chơi trực tuyến

Một game xếp gạch của Nhật Bản đã nghỉ hưu từ lâu. Có chế độ chơi đơn và chơi trực tuyến. Có thể điều chỉnh DAS và ARR (nhưng không thể đặt thành 0). Độ trễ đầu vào nhỏ. Tuy server chính ở Nhật đã bị đóng cửa còn lâu nhưng vẫn còn tồn tại server riêng. Game rất phù hợp cho những người mới bắt đầu.
        ]],
    },
    {"Tetra Online",
        "nhom06 TO tetraonline",
        "game",
        [[
Windows / macOS / Linux | Chơi đơn / Chơi trực tuyến

Gọi tắt là TO. Một tựa game xếp gạch được phát triển bởi Dr Ocelot và Mine. Các loại độ trễ như AREs được cố tình đẩy ở giá trị cao, và những ai đã từng quen chơi xếp gạch mà có độ trễ thấp / không có độ trễ sẽ khó làm quen với game này
Game đã bị gỡ khỏi Steam vào ngày 9 / T12 / 2020 do TTC gửi thông báo DMCA
Dù sao thì, vẫn còn một bản build có thể tải từ GitHub.
        ]],
        "https://github.com/Juan-Cartes/Tetra-Offline/releases/tag/1.0",
    },
    {"Cultris II",
        "nhom06 c2 cultris2 cultrisii",
        "game",
        [[
Windows / OS X | Chơi đơn / Chơi trực tuyến

Gọi tắt là C2. Được thiết kế dựa trên Tetris cổ điển, Cultris II cho phép bạn có thể điều chỉnh DAS và ARR. Chế độ chiến đấu tập trung vào các combo dựa trên thời gian, thử thách người chơi về mặt tốc độ, n-wide setup và kỹ năng đào xuống của người chơi

[MrZ: Phiên bản dành cho Mac đã không được bảo trì trong thời gian dài. Nếu bạn đang dùng macOS 10.15 Catalina hoặc macOS mới hơn thì không thể chạy game này.]
        ]],
    },
    {"Nullpomino",
        "nhom06 np",
        "game",
        [[
Windows / macOS / Linux | Chơi đơn / Chơi trực tuyến

Gọi tắt là NP. Một game xếp gạch chuyên nghiệp có khả năng tùy biến cao. Gần như mọi thông số trong game đều có thể điều chỉnh được.

[MrZ: Giao diện của game mang phong cách retro. Ngoài ra, game chỉ có thể điều khiển thông qua bàn phím, nên một vài người chơi mới sẽ gặp khó khi làm quen. Ngoài ra, có vẻ như macOS Monterey không thể chạy được game này.]
        ]],
    },
    {"Misamino",
        "nhom06",
        "game",
        [[
Windows | Chơi đơn

Chỉ có chế độ chơi 1 đấu 1 với bot, chủ yếu là chơi theo lượt. Bạn có thể viết bot cho game này (nhưng bạn cần phải học API của nó).

Misamino cũng là tên của bot trong game này.
        ]],
    },
    {"Touhoumino",
        "nhom06",
        "game",
        [[
Windows | Chơi đơn

Một game Tetris do fan làm. Game này là một bản chỉnh sửa của Nullpomino với các yếu tố được thêm vào từ Touhou Project.

Chế độ Marathon có chứa "Spell Cards" của Touhou Project (thêm hiệu ứng đặc biệt để quấy phá màn chơi), chỉ có thể phá bằng cách đạt được số điểm  yêu cầu trong thời gian có hạn.

[MrZ: Chỉ nên chơi nếu bạn đã có kỹ năng ở mức nào đó*, nếu không, bạn thậm chí không biết mình đã chết như thế nào.]

(*) Bản Zictionary tiếng Anh ghi là: "half-decent skills", dịch sát nghĩa là "một nửa kỹ năng"
        ]],
    },
    {"Tetris Blitz",
        "nhom06 blitz ea mobile phone",
        "game",
        [[
iOS / Android | Chơi đơn

Một game xếp gạch được làm bởi Electronic Arts (EA). Có cơ chế trọng lực, và mỗi ván game chỉ kéo dài trong vòng 2 phút. Game sẽ tạo một cái giếng cao khoảng 10 hàng ở đầu game (và ngay sau khi bạn làm được Perfect Clear). Game có chế độ "Frenzy" có thể kích hoạt bằng cách liên tục xóa hàng; cùng với rất nhiều loại power-up khác nhau, có cả Finisher giúp cho màn chơi kết thúc của bạn thêm đẹp mắt và buff mạnh số điểm của bạn lên. Game không có cơ chế top-out mà thay vào đó game sẽ tự động xóa các hàng trên cùng nếu có gạch chồng lên gạch đã đặt.

Game đã nghỉ hưu từ T04 / 2020
        ]],
    },
    {"Tetris (EA)",
        "nhom06 tetris ea galaxy universe cosmos mobile phone",
        "game",
        [[
iOS / Android | Chơi đơn / Chơi trực tuyến?

Một tựa game xếp gạch được phát triển bởi EA. Có hai cách điều khiển: Swipe (Vuốt) và One-Touch (Một chạm). Game này có chế độ Galaxy cùng với chế độ Marathon (có cơ chế trọng lực), và mục tiêu của chế độ này là xóa hết tất cả các gạch của Galaxy trước khi hết chuỗi gạch

Ra mắt lần đầu năm 2011, nghỉ hưu từ T04 / 2020

[Sea: game đang nhắc ở đây là bản năm 2011 (phát hành khoảng 2011 - 2012)]
        ]],
    },
    {"Tetris (N3TWORK)",
        "nhom06 tetris n3twork mobile phone",
        "game",
        [[
iOS / Android | Chơi đơn

Một tựa game xếp gạch, trước đây được phát triển bởi N3TWORK; PlayStudio đã tiếp quản quá trình phát triển từ cuối tháng 11 năm 2021. Có chế độ Chơi nhanh (Ultra nhưng 3 phút), Marathon, chế độ Royale 100 người chơi và chế độ Phiêu lưu (nơi mà bạn sẽ phải hoàn thành mục tiêu của màn chơi chỉ với số bước di chuyển có hạn).

Từ cuối T11 / đầu T12 / 2022 và sau này, tất cả các tài khoản mới tạo chỉ có thể chơi chế độ Marathon và chế độ Phiêu lưu.

[MrZ: UI thì tuyệt nhưng cơ chế điều khiển thì tệ]
[Sea: Bạn tốt hơn đi kiếm game khác chứ game này bây giờ rác quá!]
        ]],
    },
    {"Tetris Beat",
        "nhom06 n3twork rhythm",
        "game",
        [[
iOS | Chơi đơn

Một game xếp gạch tới từ N3TWORK nhưng chỉ dành cho Apple Arcade. Ngoài chế độ Marathon cổ điển, game giới thiệu một chế độ được gọi là "Beat": người chơi sẽ phải thả gạch theo nhịp của BGM.

[MrZ: Hiệu ứng của game rất là nặng và cơ chế điều khiển không được lý tưởng]
        ]],
    },
    {"Tetris Journey",
        "nhom06 tetrisjourney mobile phone huanyouji",
        "game",
        [[
iOS / Android | Chơi đơn

(俄罗斯方块环游记)

Một game xếp gạch đã nghỉ hưu từng được phát triển bởi Tencent dành cho Trung Quốc.
Có 3 chế độ chơi trực tuyến, 4 chế độ chơi đơn cùng với một chế độ dựa trên cấp độ
Mỗi trận trong chế độ chơi trực tuyến dài 2 phút, nếu không ai bị top out thì ai gửi nhiều hàng nhất sẽ giành chiến thắng.

Có thể điều chỉnh vị trí và kích thước phím ảo, nhưng không thể điều chỉnh DAS và ARR.
Game đã nghỉ hưu từ 15 / T02 / 2023.
        ]],
    },
    {"JJ Tetris",
        "nhom06 jjtetris",
        "game",
        [[
Android | Chơi trực tuyến

(JJ块)

Một game xếp gạch ở trên JJ Card Games (JJ棋牌). Chơi ở màn hình dọc, độ trễ đầu vào thấp, điều khiển mượt. DAS / ARR có thể điều chỉnh được và có thể đổi giữ Thả nhanh / Thả nhẹ, nhưng hạn chế về tùy biến bố cục phím ảo. Không HOLD cũng như B2B, không bộ đệm rác hay cơ chế hủy rác. Mỗi tấn công gửi tối đa 4 hàng, còn cơ chế combo thì "ao chình". Phần còn lại thì tương tự như Tetris hiện đại.
        ]],
    },
    {"Huopin Tetris",
        "nhom06 huopin qq",
        "game",
        [[
Windows | Chơi trực tuyến

(火拼俄罗斯)

Một game xếp gạch ở trên Tencent Game Center - một nền tảng chơi game trực tuyến dành riêng tại Trung Quốc. Có bảng rộng 12 ô, 1 NEXT, 0 HOLD, DAS và ARR giống với DAS và ARR hay dùng trong các app gõ văn bản. Chỉ có thể gửi rác bằng Tetris (gửi 3 hàng rác) và xóa 3 hàng (gửi 2 hàng rác). Hàng rác có cấu trúc xen kẽ và gần như không thể đào.
        ]],
    },
    {"=[NHÓM 07]=",
        "nhom07",
        "",
        [[
NHÓM 07: MỘT VÀI CƠ CHẾ VÀ CHẾ ĐỘ CỦA MỘT SỐ GAME
        ]]
    },
    {"Tàng hình một phần",
        "nhom07 half invisible semi",
        "term",
        "Tên tiếng Anh: Semi-invisible\nChỉ một quy tắc trong đó gạch sẽ tàng hình sau một khoảng thời gian từ lúc nó được đặt xuống.\nKhoảng thời gian đó thường không được cố định, nên vẫn có thể mô tả nó là \"biến mất sau một vài giây\".",
    },
    {"Tàng hình",
        "nhom07 invisible",
        "term",
        "Tên tiếng Anh: Invisible\nChỉ một quy tắc trong đó gạch sẽ tàng hình ngay lập tức sau khi đặt xuống\n \nNếu mode tàng hình hoàn toàn mà có hiệu ứng biến mất thì vẫn được chấp nhận. Tuy nhiên, nó làm game dễ hơn đôi chút\n\nỞ Techmino, chế độ tàng hình mà không có hiệu ứng biến mất được gọi là \"sudden invisible.\"",
    },
    {"Chế độ MPH",
        "nhom07 mph",
        "term",
        "Sự kết hợp của ba quy tắc:\n\n\"Memoryless - Không nhớ gì\" (chuỗi gạch tạo ra hoàn toàn ngẫu nhiên)\n\"Previewless - Không biết trước gạch nào sẽ tới\" (không có hàng NEXT)\n\"Holdless- Không có ô HOLD\".\n\nMột chế độ đòi hỏi tốc độ và phản ứng nhạy bén từ người chơi.",
    },
    {"Secret Grade",
        "nhom07 larger than > <",
        "term",
        "Một easter egg trong series TGM.\n\nĐể có được \"secret grade\", người chơi sẽ làm một đường dích dắc (zigzag) (trông giống như \">\" hay \"<\") bằng cách tạo ra 1 ô trống duy nhất cho từng hàng. Mục tiêu cuối cùng là hoàn thành đường dích dắc cao (hơn) 19 hàng.\n\nNhấn vào nút hình địa cầu để xem các kỹ thuật dùng để đạt được Secret Grade.",
        "https://harddrop.com/wiki?search=Secret_Grade_Techniques",
    },
    {"Deepdrop (Rơi sâu)",
        "nhom07",
        "term",
        "*Chỉ có trên Techmino*\n\nMột chức năng cho phép cho phép gạch có thể teleport xuyên đất để xuống phía dưới. Khi gạch đụng vào gạch đã đặt, nhấn phím Thả nhẹ để kích hoạt Deepdrop. Nếu có một cái lỗ phù hợp với hình dạng của gạch ở dưới vị trí gạch đang rơi, gạch sẽ được teleport vào lỗ đó.\nCơ chế này đặc biệt hữu ích cho AI vì nó cho phép AI bỏ qua sự khác biệt giữa các hệ thống xoay khác nhau.",
    },
    {"=[NHÓM 08]=",
        "nhom08",
        "",
        "NHÓM 08: BOT"
    },
    {"Cold Clear",
        "nhom08 cc coldclear ai bot",
        "term",
        "Một bot chơi Tetris. Được viết bởi MinusKelvin, ban đầu được viết cho Puyo Puyo Tetris.\nBản Cold Clear ở trong Techmino có hỗ trợ All-spin và hệ thống TRS (nhưng không hỗ trợ O-spin).",
    },
    {"ZZZbot",
        "nhom08 ai bot zzztoj",
        "term",
        "Một bot chơi xếp gạch. Được viết bởi một người chơi Tetris Trung Quốc có tên là 奏之章 (Zòu Zhī Zhāng) và hoạt động khá tốt trong nhiều game (sau khi điều chỉnh các thông số cần thiết).\nBạn cũng có thể sử dụng bot này trên TETR.IO.",
    },
    {"=[NHÓM 09]=",
        "nhom09",
        "",
        "NHÓM 09: WIKI; CÁC TRANG WEB BÀY SETUP,\nCUNG CẤP CÂU ĐỐ & CHIA SẺ SETUP"
    },
    {">A|Wiki",
        "nhom09a",
        "",
        ""
    },
    {"Huiji Wiki",
        "nhom09a huiji wiki",
        "help",
        "(灰机wiki)\n\nMột wiki về Tetris của những người đam mê Tetris từ các nhóm và chi nhánh của Cộng đồng Nghiên cứu Tetris Trung Quốc. Hiện tại hầu hết các trang đều được tham khảo và dịch từ Wiki Hard Drop và Tetris Wiki. Liên kết sẽ dẫn bạn tới bản tiếng Trung giản thể.",
        "https://tetris.huijiwiki.com",
    },
    {"Wiki Hard Drop",
        "nhom09a harddrop hd wiki",
        "help",
        "Một wiki về Tetris được host bởi cộng đồng Hard Drop.",
        "https://harddrop.com/wiki/Tetris_Wiki",
    },
    {"Tetris.wiki",
        "nhom09a tetris wiki",
        "help",
        "Một wiki tập trung vào các nội dung liên quan đến Tetris. Wiki được tạo ra từ năm 2015 bởi Myndzi. Trong những năm qua, hàng nghìn đóng góp đã được thực hiện để ghi lại các game xếp gạch chính thức và các game do fan làm, các series, những cơ chế của game,… cũng như tạo ra những bài hướng dẫn để cải thiện trải nghiệm chơi.",
        "https://tetris.wiki",
    },
    {"Tetris Wiki Fandom",
        "nhom09a tetris wiki fandom",
        "help",
        "Cũng là một wiki về Tetris nhưng nó ở trên Fandom",
        "https://tetris.fandom.com/wiki/Tetris_Wiki",
    },
    {">B|Câu đố",
        "nhom09b",
        "",
        "NHÓM 09B: CÁC TRANG WEB CUNG CẤP CÂU ĐỐ"
    },
    {"TTT",
        "nhom09b tetris trainer tres bien T.T.T.",
        "game",
        [[
Tetris Trainer Très-Bien (viết bởi こな "kona"). Một website chứa các hướng dẫn thực hành các kỹ thuật nâng cao trong Tetris hiện đại (lưu ý: website này chỉ hỗ trợ bàn phím vật lý, không hỗ trợ bàn phím ảo).
Đề xuất cho những người chơi có thể hoàn thành chế độ 40L chỉ làm Tetris + không dùng Hold
Website này đề cập tới T-spin, finesse, SRS và một số setup để chơi Battle
Liên kết sẽ dẫn bạn tới phiên bản tiếng Anh, được dịch bởi User670 (Bản gốc là bản tiếng Nhật).
        ]],
        "https://user670.github.io/tetris-trainer-tres-bien/",
    },
    {"TTPC",
        "nhom09b tetris perfect clear challenge T.T.P.C",
        "game",
        [[
Tetris Perfect Clear Challenge (viết bởi chokotia). Một website hướng dẫn bạn cách làm Perfect Clear khi sử dụng hệ thống xoay SRS và Bag-7 (chỉ hỗ trợ bàn phím). Đề xuất sử dụng nếu bạn đã hoàn thành TTT và đã làm quen với SRS

Liên kết sẽ dẫn bạn tới phiên bản tiếng Anh, bản gốc là tiếng Nhật
        ]],
        "https://teatube.cn/ttpc/ttpc/",
    },
    {"NAZO",
        "nhom09b",
        "game",
        [[
(ナゾ)

Một website chứa các loại câu đố SRS từ dễ đến cực kỳ khó, bao gồm T-spin và All spin. Đề xuất cho những người đã hoàn thành TTT.

Liên kết sẽ dẫn bạn tới bản tiếng Trung Giản thể, nguyên bản bằng tiếng Nhật.
        ]],
        "https://teatube.cn/nazo/",
    },
    {"TPO",
        "nhom09b nazo T.P.O",
        "game",
        "Tetris Puzzle O. Một trang web bằng tiếng Nhật được viết bởi TCV100 (có lấy một vài câu đố từ NAZO sang).",
        "http://121.36.2.245:3000/tpo",
    },
    {"4-wide Trainer",
        "nhom09b nazo",
        "game",
        "Một công cụ được viết bởi DDRKirby(ISQ) để học & làm quen 4-wide.",
        "https://ddrkirby.com/games/4-wide-trainer/4-wide-trainer.html",
    },
    {">C|Setup",
        "nhom09c",
        "",
        "NHÓM 09C: CÁC TRANG WEB BÀY SETUP"
    },
    {"Four.lol",
        "nhom09c four wiki",
        "help",
        "Một website chứa các setup để làm opener",
        "https://four.lol",
    },
    {"‘Tetris Hall’",
        "nhom09c tetris hall",
        "help",
        "(テトリス堂)\n\nMột trang web tiếng Nhật, chứa nhiều setup, hướng dẫn cũng như có các minigame. Nó cũng có mô tả chi tiết về PC liên tiếp",
        "https://shiwehi.com/tetris/",
    },
    {"‘Tetris Template Collections’",
        "nhom09c tetris template collections",
        "help",
        "(テトリステンプレ集@テト譜)\n\nMột trang web tiếng Nhật với các setup và các danh mục chi tiết. Hầu hết các setup đều có ảnh minh họa, vì vậy việc chia sẻ với người khác sẽ dễ dàng hơn.",
        "https://w.atwiki.jp/tetrismaps/",
    },
    {"tetristemplate.info",
        "nhom09c",
        "help",
        "(テトリスブログ - PerfectClear)\n\nMột trang web ở Nhật Bản chứa một số setup. Tuy số lượng không bằng các trang web khác nhưng bù lại các setup đều được giải thích rất chi tiết",
        "https://tetristemplate.info/",
    },
    {">D|Chia sẻ setup",
        "nhom09d",
        "",
        "NHÓM 09D: CÁC TRANG WEB CHIA SẺ SETUP"
    },
    {"Fumen",
        "nhom09d",
        "help",
        "Đây là một công cụ chỉnh sửa bảng dành cho Tetris bằng tiếng Nhật. Thường được sử dụng để chia sẻ setup, PC solution (hướng đi để làm PC), v.v.\nLiên kết của mục này sẽ dẫn bạn tới bản tiếng Anh.",
        "http://fumen.zui.jp/#english.js",
    },
    {"Fumen bản Đ.thoại",
        "nhom09d fumenformobile fm",
        "help",
        "Fumen for Mobile (Fumen bản dành cho Điện thoại)\nCũng là Fumen nhưng hỗ trợ cho màn hình cảm ứng",
        "https://knewjade.github.io/fumen-for-mobile/",
    },
    {"=[NHÓM 10]=",
        "nhom10",
        "",
        "NHÓM 10: CỘNG ĐỒNG"
    },
    {"Tetris OL Servers",
        "nhom10 tetrisonline servers tos",
        "org",
        "Hãy lên Google tra \"Tetris Online Poland\" để tìm server ở Ba Lan.\nCòn nếu tìm server Tetris Online Study được đặt tại Trung Quốc (cung cấp bởi Teatube) thì nhấn vào nút hình địa cầu",
        "https://teatube.cn/tos/",
    },
    {
    "Tetris Việt Nam",
    -- Need an better description! @~@
        "nhom10 community vietnam tetris việt nam",
        "org",
        [[
Một trong những cộng đồng xếp gạch tại Việt Nam. Đây là nơi chia sẻ kinh nghiệm và thông tin: bao gồm cả game, các giải đấu và các sự kiên liên quan đến xếp gạch.

Nhấn nút hình địa cầu để vào server Discord, còn nếu muốn vào nhóm Facebook thì hãy vào Facebook và tìm nhóm "Tetris Việt Nam".
        ]],
        "https://discord.gg/jX7BX9g",
    },
    {"=[NHÓM 11]=",
        "nhom11",
        "",
        "NHÓM 11: XẾP LÊN VÀ ĐÀO XUỐNG"
    },
    {"A|Stacking",
        "nhom11a",
        "",
        "NHÓM 11A: STACKING (XẾP LÊN)\n\nDùng để chỉ việc xếp các gạch làm sao mà không để lại một cái lỗ.\nĐây là kỹ năng càn thiết yêu càu khả năng tận dụng hàng NEXT.\nBạn có thể cải thiện kỹ năng này bằng cách luyện tập 40L với 0 HOLD",
    },
    {"Side well",
        "nhom11a ren combo sidewell",
        "term",
        "Một phương pháp xếp gạch đặc biệt mà bạn sẽ để lại một cái lỗ có một chiều rộng nhất định ở một bên bảng.\n\nCó 4 loại setup này: Setup Side 1-wide là setup truyền thống để làm Tetris (ví dụ như, Side well Tetris). Các loại setup như Side 2-, 3-, hay 4-wide; là những setup được dùng để làm combo.\n\nĐối với những người chơi mới, đây là cách hiệu quả nhất để tấn công.\n\nNHƯNG, đối thủ có thể dễ dàng tấn công lại bạn, một là chết còn không thì stack của bạn sẽ bị cắt ngắn do bạn phải phản công lại.\nTrong thực tế, setup này chỉ dùng sau khi dùng setup T-spin nào đó hoặc là đối thủ chưa thể tấn công ngay; khi đó, side well có thể được sử dụng để tăng số cú tấn công tức thì.",
    },
    {"Center well",
        "nhom11a ren combo centerwell",
        "term",
        "Một phương pháp xếp gạch mà bạn sẽ để lại một cái giếng có chiều rộng nhất định ở giữa bảng. Bạn cũng có thể tránh bị top-out nếu giếng đủ rộng.",
    },
    {"Partial well",
        "nhom11a ren combo partialwell",
        "term",
        "Một phương pháp xếp gạch mà bạn sẽ để lại một cái giếng có chiều rộng nhất định nhưng không ở giữa hay một bên bảng.",
    },
    {"Side 1-wide",
        "nhom11a s1w side1wide sidewelltetris",
        "term",
        "Hay còn gọi là S1W.\nVới setup này bạn sẽ xây một cái giếng sâu rộng 1 ô ở một bên bảng.\n\nĐây được coi là setup / cách chơi xếp gạch kinh điển nhất\n\nNhững người mới tập chơi có thể dùng setup này để gửi Tetris, vì chúng có thể tấn công tốt trong một thời gian ngắn.\nTuy nhiên, những người chơi giỏi hơn thường sẽ không dùng setup này do ít hiệu quả + dễ bị tấn công trong lúc xây → dễ bị game over; họ chỉ xây S1W nếu như tình hình hiện tại đủ thuận lợi cho setup này.\n\nSetup này còn được biết tới với cái tên \"Side well Tetris\".",
    },
    {"Side 2-wide",
        "nhom11a s2w side2wide sidewell",
        "term",
        "Hay còn gọi là S2W.\nVới setup này bạn sẽ xây một cái giếng sâu rộng 2 ô ở một bên bảng.\n\nS2W rất dễ xây và có thể tạo ra combo khá dài khi kết hợp với HOLD.\nTuy nhiên, những người chơi giỏi hơn cũng sẽ ít khi dùng setup này vì các lý do tương tự như S1W.",
    },
    {"Side 3-wide",
        "nhom11a s3w side3wide sidewell",
        "term",
        "Hay còn gọi là S3W.\nVới setup này bạn sẽ xây một cái giếng sâu rộng 3 ô ở một bên bảng.\n\nĐây là setup it phổ biến hơn so với Side 2-wide.\n\nMặc dù khi so sánh, S3W có thể làm nhiều combo hơn so với S2W nhưng S3W hay dễ bị hỏng combo.",
    },
    {"Side 4-wide",
        "nhom11a s4w side4wide sidewell",
        "term",
        "Hay còn gọi là S4W.\nVới setup này bạn sẽ xây một cái giếng sâu rộng 4 ô ở một bên bảng.\n\nĐây là setup phổ biến dùng để làm combo.\n\nNgoài việc tạo ra được những combo dài hơn, S4W lại tốn ít thời gian hơn để xây so với setup side well khác. Việc này cho phép người chơi gửi tấn công sớm hơn trước khi đối thủ có thể trở tay kịp.\n\nSo với C4W, S4W được coi là cân bằng hơn vì người chơi có thể bị top-out trong khi đang xây setup này.",
    },
    {"Center 1-wide",
        "nhom11a c1w center1wide centerwelltetris",
        "term",
        "Hay còn gọi là C1W.\nVới setup này bạn sẽ xây một cái giếng sâu rộng 1 ô ở giữa bảng.\n\nChủ yếu dùng trong combat bởi vì cho phép làm Tetris và T-spin trong khi nó không quá khó để làm.",
    },
    {"Center 2-wide",
        "nhom11a c2w center2wide",
        "term",
        "Hay còn gọi là C2W.\nVới setup này bạn sẽ xây một cái giếng sâu rộng 2 ô ở giữa bảng.\n\nĐây là một setup combo có thể làm được nhưng ít phổ biến lắm.",
    },
    {"Center 3-wide",
        "nhom11a c3w center3wide",
        "term",
        "Hay còn gọi là C3W.\nVới setup này bạn sẽ xây một cái giếng sâu rộng 3 ô ở giữa bảng.\n\nĐây là một setup combo có thể làm được nhưng ít phổ biến lắm.",
    },
    {"Center 4-wide",
        "nhom11a c4w center4wide",
        "term",
        "Hay còn gọi là C4W.\nVới setup này bạn sẽ xây một cái giếng sâu rộng 4 ô ở giữa bảng.\n\nĐây là một setup khét tiếng có thể tạo ra lượng combo rất lớn nếu người xây tận dụng tốt.\nSetup này rất dễ xây, và có khả năng phòng thủ tốt trước các đòn tấn công bằng cách lợi dụng một lỗ hổng khi kiểm tra điều kiện chết trong (đa số) các game xếp gạch.\n\nRất nhiều người chơi ghét setup này vì nhiều lý do khác nhau; nhưng chủ yếu là vì phần thắng luôn thuộc về những người dùng setup này.\nHãy cẩn thận khi dùng setup này trong các trận đấu thực tế.",
    },
    {"Residual",
        "nhom11a c4w s4w",
        "term",
        "Thuật ngữ này đề cập đến số ô gạch được để dư trong cái giếng sau khi xây xong setup 4-wide.\nCác combo dài chủ yếu được thực hiện bằng cách dùng 3-residual (3-res) hay 6-residual (6-res).\n\n3-res dễ học hơn tại vì nó có ít biến thể hơn và có cơ hội cao để tạo ra combo dài hơn\n6-res linh hoạt hơn nhiều đồng nghĩa với việc khó nhớ hơn, nhưng combo tạo ra lại dài hơn 3-res nếu mọi thứ thuận lợi.\n\nNói chung, thứ tự ưu tiên của setup này là 6-res, rồi 3 sau đó 5, và cuối cùng là 4-res.",
    },
    {"6 - 3 Stacking",
        "nhom11a 63stacking six-three sixthree",
        "term",
        "Một phương pháp để xếp gạch đặc biệt, khi bạn sẽ phải tạo ra một bức tường cao rộng 6 ô ở bên trái và một bức tường cao nữa rộng 3 ô ở bên phải.\n\nĐối với một người chơi có kỹ năng, phương pháp cho phép người chơi giảm số phím cần nhấn, và đây là một phương pháp phổ biến để chơi Sprint (như 10 hàng, 20 hàng, 40 hàng,…). Phương pháp này hoạt động được nhờ việc vị trí xuất hiện của 3 gạch J, L, T hay dịch về bên trái 1 ô.\n\nNhắc nhẹ: Phương pháp này CÓ THỂ tăng số lần nhấn phím ở người mới tập chơi.",
    },
    {">B|Digging",
        "nhom11b",
        "",
        "Digging (Đào xuống)\nCòn được biết tới với tên là Downstacking\n\nDọn hàng rác để tiếp xúc đáy bảng.",
    },
    {"=[NHÓM 12]=",
        "nhom12",
        "",
        "NHÓM 12: Setup (Opener, Mid-game setup, Donation)"
    },
    {">A|Opener",
        "nhom12a opener",
        "",
        [[
NHÓM 12A: OPENER
Opener thường là các setup thường dùng ở đầu trận. Bạn vẫn có thể làm những setup này giữa trận, nhưng thường sẽ yêu cầu một tập hợp các vị trí gạch khác nhau.

Opener phải đạt 2 trong 4 tiêu chí sau
- Có thể thích ứng với các chuỗi gạch khác nhau,
- Tấn công mạnh, ít lãng phí gạch T
- Dùng Finesse trong đa số hành động, ít dùng thả nhẹ
- Có chiến lược rõ ràng và ít nhánh / biến thể.

Đa số opener được thiết kế cho kiểu xáo Túi 7. Chúng có thể không hoạt động với các kiểu xáo khác.
        ]],
    },
    {"DT Cannon",
        "nhom12a opener dtcannon doubletriplecannon",
        "setup",
        "Double-Triple Cannon (Súng thần công T-spin Đôi-Tam).\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=dt",
    },
    {"DTPC",
        "nhom12a opener dtcannon doubletriplecannon",
        "setup",
        "Phần tiếp theo của DT Cannon kết thúc bằng All Clear.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=dt",
    },
    {"BT Cannon",
        "nhom12a opener btcannon betacannon",
        "setup",
        "β Cannon, Beta Cannon.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=bt_cannon",
    },
    {"BTPC",
        "nhom12a opener btcannon betacannon",
        "setup",
        "Phần tiếp theo của DT Cannon kết thúc bằng All Clear.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=bt_cannon",
    },
    {"TKI 3 Perfect Clear",
        "nhom12a opener ddpc tki3perfectclear",
        "setup",
        "Một opener làm TSD dẫn đến Double-Double-All Clear.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=TKI_3_Perfect_Clear",
    },
    {"QT Cannon",
        "nhom12a opener qtcannon",
        "setup",
        "Một setup gần giống với DT Cannon và khả năng gửi DT Attack¹ cao.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop\n\n¹: DT Attack = T-spin Double + T-spin Triple",
        "https://harddrop.com/wiki?search=QT_cannon",
    },
    {"Mini-Triple",
        "nhom12a opener mt minitriple",
        "setup",
        "Một setup làm Mini T-spin và T-spin Triple.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=mt",
    },
    {"Trinity",
        "nhom12a opener",
        "setup",
        "Một setup làm TSD + TSD + TSD hoặc TSMS + TST + TSD. Để có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=trinity",
    },
    {"Wolfmoon Cannon",
        "nhom12a opener wolfmooncannon",
        "setup",
        "Một opener.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=wolfmoon_cannon",
    },
    {"Sewer",
        "nhom12a opener",
        "setup",
        "Một opener.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=sewer",
    },
    {"TKI",
        "nhom12a opener tki-3 tki3",
        "setup",
        "TKI-3. Có thể chỉ TKI-3 bắt đầu bằng một TSD hoặc C-spin bắt đầu bằng một TST.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=tki_3_opening",
    },
    {"God Spin",
        "nhom12a opener godspin",
        "setup",
        "Một setup nhìn đẹp mắt [nhưng khó sử dụng trên thực tế]. Được phát minh bởi Windkey.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=godspin",
    },
    {"Albatross",
        "nhom12a opener",
        "setup",
        "Một opener nhìn đẹp mắt, nhịp độ nhanh với TSD - TST - TSD - All Clear, khó mà lãng phí được gạch T.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=Albatross_Special",
    },
    {"Pelican",
        "nhom12a opener",
        "setup",
        "Một opener kiểu Alabatross được sử dụng trong trường hợp trật tự gạch tới không ủng hộ opener Alabatross gốc.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=Pelican",
    },
    {"Perfect Clear Opener",
        "nhom12a opener 7piecepuzzle",
        "setup",
        "Một opener làm All Clear có khả năng thành công cao (~84.6% nếu bạn đang giữ I trong ô HOLD và ~61.2% nếu không giữ).\n\nTrong chế độ PC Training (Luyện tập PC), setup này được sử dụng để tạo ra setup chưa hoàn chỉnh, không tạo ra lỗ.\n\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=Perfect_Clear_Opener",
    },
    {"Grace System",
        "nhom12a opener gracesystem 1stpc",
        "setup",
        "Một opener làm PC có khả năng thành công ~88.57%. Lỗ hình vuông 4 × 4 trong chế độ PC Training cũng dựa trên setup này.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên Four.lol",
        "https://four.lol/perfect-clears/grace-system",
    },
    {"DPC",
        "nhom12a opener",
        "setup",
        "Một setup làm TSD + PC gần như 100% không có gạch nào trong bảng và gạch cuối cùng trong Túi 7 gạch trong hàng đợi NEXT.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên tetristemplate.info.",
        "https://tetristemplate.info/dpc/",
    },
    {"Gamushiro Stacking",
        "nhom12a opener",
        "setup",
        "(ガムシロ積み) Một opener làm TD Attack (TD Attack = T-spin Triple + T-spin Double).\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=Gamushiro_Stacking",
    },
    {">B|Mid-game",
        "nhom12b midgame mid-game",
        "",
        "NHÓM 12B: MID-GAME SETUP\n\nChỉ những setup cho phép gửi nhiều rác giữa trận. Một số có thể dùng làm opener, nhưng hầu như chúng không cần thiết.",
    },
    {"C-spin",
        "nhom12b midgame mid-game cspin",
        "pattern",
        "Một setup gửi tấn công bằng T-spin Triple + T-spin Double, known as TKI in Japan.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=c-spin",
    },
    {"STSD",
        "nhom12b midgame mid-game",
        "pattern",
        "Super T-spin Double, một setup cho phép làm T-spin Double.\nNhưng nếu có rác ngay dưới setup này thì không tài nào làm T-spin Double được\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=stsd",
    },
    {"Fractal",
        "nhom12b midgame mid-game fractal spider",
        "pattern",
        "Một setup dùng để làm T-spin.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=Fractal",
    },
    {"LST stacking",
        "nhom12b midgame mid-game",
        "pattern",
        "Một setup dùng để làm T-spin với số lượng vô tận.",
        "https://four.lol/stacking/lst",
    },
    {"Imperial Cross",
        "nhom12b midgame mid-game imperialcross",
        "pattern",
        "Che lỗ hình chữ thập bằng phần nhô ra để thực hiện hai lần T-spin Double\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=imperial_cross",
    },
    {"King Crimson",
        "nhom12b midgame mid-game kingcrimson",
        "pattern",
        "Xếp chồng để làm (các) TSD trên STSD.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=King_Crimson",
    },
    {"PC liên tiếp [1/2]",
        "nhom12b midgame mid-game pcloop",
        "pattern",
        "four.lol có hướng dẫn cách làm Perfect Clear liên tiếp. Sau khi hoàn thành PC thứ 7 khi bạn cũng vừa xài đúng 70 gạch (10 túi 7 gạch) nên bạn có thể quay về PC thứ nhất.\n\nNhấn nút hình địa cầu để xem setup cho PC thứ nhất (để xem các setup sau, hãy thay 1st trong link bằng 2nd / 3rd / 4th / 5th / 6th / 7th)",
        "https://four.lol/perfect-clears/1st",
    },
    {"PC liên tiếp [2/2]",
        "nhom12b midgame mid-game pcloop",
        "pattern",
        "Một hướng dẫn làm vòng lặp PC hoàn chỉnh được viết bởi NitenTeria.",
        "https://docs.qq.com/sheet/DRmxvWmt3SWxwS2tV",
    },
    {">C|Donation",
        "nhom12c donation pattern",
        "",
        "NHÓM 12C: DONATION\n\nBiến một hố hoặc một cái giếng (ban đầu được tính để làm Tetris) thành setup T-spin bằng cách \"cắm thêm gạch vào\". Sau khi làm T-spin, hố đó sẽ được mở ra để cho phép bạn làm Tetris hoặc làm donation khác. \"Cắm thêm gạch\" vào hố hoặc giếng vốn không được tính để làm Tetris thì vẫn có thể gọi là \"donation\" như thường.",
    },
    {"STMB Cave",
        "nhom12c donation pattern stmb",
        "pattern",
        "STMB cave, một setup dạng donation bằng cách sử dụng S / Z để bịt tường rộng 3 ô và làm T-spin Double.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=stmb_cave",
    },
    {"Hamburger",
        "nhom12c donation pattern",
        "pattern",
        "Một setup dạng donation setup dùng để tạo cơ hội có thể làm Tetris.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=hamburger",
    },
    {"Kaidan",
        "nhom12c donation pattern kaidan stairs",
        "pattern",
        "Một setup dạng donation có thể làm TSD trên địa hình cầu thang.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=kaidan",
    },
    {"Shachiku Train",
        "nhom12c donation pattern shachikutrain shechu",
        "pattern",
        "Một setup dạng donation cho phép làm thêm hai TSD từ setup TST.\nĐể có thêm thông tin, bạn có thể nhấn nút hình địa cầu để mở bài ở trên wiki Hard Drop",
        "https://harddrop.com/wiki?search=Shachiku_Train",
    },
    {"Cut Copy",
        "nhom12c donation pattern cutcopy",
        "pattern",
        "Một setup dạng donation để làm T-spin Double trên một cái lỗ nhỏ và có thể làm thêm một TSD nữa sau đó.",
    },
    {"=[NHÓM 13]=",
        "nhom13",
        "",
        "NHÓM 13: CÁCH TÍNH TẤN CÔNG"
    },
    {"Tetris OL attack",
        "nhom13 top tetrisonlineattack",
        "term",
        [[
Cách tính tấn công trong Tetris Online

Đơn / Đôi / Tam / Tetris gửi 0 / 1 / 2 / 4 hàng rác.
T-spin Đơn / Đôi / Tam gửi 2 / 4 / 6 hàng rác, cắt một nửa nếu là Mini.
Combo gửi thêm 0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 5 hàng rác.
Back to Back gửi thêm 1 (hoặc 2 nếu T-spin Triple).

All Clear gửi thêm 6 hàng rác
nhưng gửi thẳng vào bảng đối thủ thay vì không hủy rác tới.
        ]],
    },
    {"Techmino attack",
        "nhom13 techminoattack",
        "term",
        "Cách tính tấn công trong Techmino\n\nĐể biết công thức tính, hãy xem \"hướng dẫn sử dụng\" bằng cách nhấn nút "..CHAR.icon.help.." ở màn hình chính của game.\n\nNhấn nút hình địa cầu sẽ dẫn bạn tới một bảng tấn công đã được tính sẵn và bạn chỉ cần cộng dồn lại các giá trị bạn muốn để biết kết quả.",
        "https://media.discordapp.net/attachments/743861514057941204/1093386431096950815/Untitled.jpg"
    },
    {"=[NHÓM 14]=",
        "nhom14",
        "",
        "NHÓM 14: CONSOLE VÀ CHUYỆN QUẢN LÝ DỮ LIỆU GAME"
    },
    {"Console",
        "nhom14 cmd commamd terminal console",
        "command",
        "Techmino có một console cho phép kích hoạt tính năng gỡ lỗi và bật các tính năng nâng cao.\nĐể truy cập, hãy chạm vào logo Techmino / nhấn phím C 4 lần, tại màn hình chính.\n\nCẢNH BÁO! CÓ RỦI RO KHI TIẾN HÀNH\nHành động bất cẩn trong console có thể dẫn đến HƯ HỎNG\nhoặc MẤT TOÀN BỘ dữ liệu đã lưu KHÔNG THỂ PHỤC HỒI.",
    },
    {"Đặt lại thiết lập",
        "nhom14 reset setting",
        "command",
        "Vào console, gõ \"rm conf / setting\" sau đó nhấn Enter / Return.\nKhởi động lại Techmino để thay đổi có hiệu lực.\nĐể hoàn tác / hủy bỏ thay đổi đã thực hiện, hãy vào Cài đặt rồi trở ra.",
    },
    {"Xóa t.bộ thành tích",
        "nhom14 reset statistic data",
        "command",
        "Xóa toàn bộ thành tích\n\nVào console, gõ \"rm conf / data\" sau đó nhấn Enter / Return.\nKhởi động lại Techmino để thay đổi có hiệu lực.\nĐể hoàn tác / hủy bỏ thay đổi đã thực hiện, chơi một chế độ bất kỳ sau đó nhận màn hình Thắng / Thua",
    },
    {"Khóa t.bộ map",
        "nhom14 reset unlock",
        "command",
        "Tất cả các mode sẽ bị khóa lại như khi bạn vừa mới vào chơi lần đầu.\n\nVào console, gõ \"rm conf / unlock\" sau đó nhấn Enter / Return.\nKhởi động lại Techmino để thay đổi có hiệu lực.\nĐể hoàn tác / hủy bỏ thay đổi đã thực hiện, cập nhật lại tình trạng của một chế độ bất kỳ.",
    },
    {"Xóa t.bộ kỷ lục",
        "nhom14 reset record",
        "command",
        "Xóa toàn bộ kỷ lục\n\nVào console, gõ \"rm -s record\" sau đó nhấn Enter / Return.\nKhởi động lại Techmino để thay đổi có hiệu lực.\nBạn có thể hoàn nguyên hành động này trên cơ sở từng chế độ; chơi một chế độ và cập nhật bảng xếp hạng để khôi phục bảng xếp hạng của chế độ đó.",
    },
    {"Đặt lại bố cục phím",
        "nhom14 reset virtualkey",
        "command",
        "Vào console, gõ \"rm conf / [File_bố_cục_phím]\" sau đó nhấn Enter / Return.\nThay [File_bố_cục_phím] với file cần xóa:\n\t- File bố cục bàn phím trên máy tính: key;\n\t- File bố cục nút trên màn hình: virtualkey;\n\t- File chứa 2 slot bố cục nút trên màn hình: vkSave1, vkSave2\n\nKhởi động lại Techmino để hai thay đổi đầu tiên có hiệu lực.\nVào một trang chỉnh sửa bố cục phím / nút sau đó trở ra để lấy lại file tương ứng.",
    },
    {"Xóa t.bộ replay",
        "nhom14 delete recording",
        "command",
        "Xóa toàn bộ bản phát lại\n\nVào console, gõ \"rm -s replay\" sau đó nhấn Enter / Return.\nHiệu lực tức thì, KHÔNG THỂ HOÀN TÁC",
    },
    {"Xóa bộ nhớ đệm",
        "nhom14 delete cache",
        "command",
        "Vào console, gõ \"rm -s cache\" sau đó nhấn Enter / Return.\nHiệu lực tức thì, KHÔNG THỂ HOÀN TÁC",
    },
    {"=[NHÓM 15]=",
        "nhom15",
        "",
        "NHÓM 15: CÁC THUẬT NGỮ KHÔNG LIÊN QUAN TỚI TETRIS (TIẾNG ANH)"
    },
    {"SFX",
        "nhom15 soundeffects",
        "english",
        "Từ viết tắt của \"Sound Effects\" (Hiệu ứng âm thanh). Ở Nhật Bản, từ này được viết tắt là \"SE\".",
    },
    {"BGM",
        "nhom15 backgroundmusic",
        "english",
        "Từ viết tắt của \"Background Music (Nhạc nền).\"",
    },
    {"TAS",
        "nhom15",
        "english",
        "Từ viết tắt của \"Tool-Assisted Speedrun (Superplay)\" (Công cụ hỗ trợ Speedrun)\nChơi một game nào đó mà không cần công cụ đặc biệt để phá vỡ quy tắc của game (ở cấp độ chương trình / phần mềm).\nNó thường được sử dụng để đạt điểm tối đa theo lý thuyết / đạt được những mục tiêu thú vị\nMột công cụ TAS như vậy cũng có sẵn, nhưng là bản nhỏ gọn, được đi kèm với Techmino.",
    },
    {"AFK",
        "nhom15",
        "english",
        "Từ viết tắt của \"Away From Keyboard\" nghĩa là hiện đang nghỉ ngơi / làm việc khác VÀ không đụng game.\nNghỉ giải lao thường xuyên giúp bạn giảm căng cơ và giúp bạn chơi tốt hơn khi quay trở lại.",
    },
}
