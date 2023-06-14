-- Toàn bộ nội dung này được sao chép y nguyên từ dict_en.lua
-- Và file này được sửa bằng tay, không dùng tool của User670: https://github.com/user670/techmino-dictionary-converter/blob/master/tool.py

platform_restriction_text = "Nội dung của mục này đã bị ẩn đi do yêu cầu của nền tảng. Nhưng bạn vẫn có thể hỏi về nội dung này trong server Discord của chúng tôi."

return {
    {"Ghi chú dịch #1",
        "",
        "help",
        [[
Đây là bản dịch tiếng Việt của TetroDictionary từ bản tiếng Anh.
Bản tiếng Anh được dịch từ bản tiếng Trung Giản thể và do User670 và C₂₉H₂₅N₃O₅ vừa dịch vừa sửa chữa.

Vì bản dịch là bản dịch đã qua một ngôn ngữ trung gian khác là tiếng Anh, nên nội dung đôi khi hoặc có thể không giống với bản tiếng Trung Giản thể.

Muốn gửi đóng góp cho bản dịch? Hay là xem những ai đã đóng góp cho bản dịch này? Nếu thế, hãy nhấn vào biểu tượng quả địa cầu ở góc dưới bên phải để mở trang web.

Dịch bởi Squishy, xem và sửa bởi <ai đó>.
        ]],
        "https://github.com/26F-Studio/Techmino/blob/main/parts/language/dict_vi.lua",
    },
    {"H.dẫn cho ng.mới",
        "guides newbie noob readme recommendations suggestions helps"..
        "hướng dẫn  người mới chơi  lời khuyên",
        "help",
        [[
Hướng dẫn dành cho người mới:
Đây là những lời khuyên của chúng tôi dành cho những người mới chơi Tetris (xếp gạch):
    Có 2 nguyên tắc cần nhớ:
        1. Chọn một game xếp gạch có cơ chế điều khiển tốt (ví dụ như Techmino, TETR.IO, Jstris, Tetris Online, Tetr.js). Tránh chơi phiên bản "nguyên thủy", bởi vì chúng khác quá nhiều so với Guildline và cơ chế điều khiển của chúng cực tệ.
        2. Dành thời gian để có thể đạt các kỹ năng cơ bản: ví dụ như có thể đọc dãy NEXT và có thể làm Tetris (xóa 4 hàng cùng một lúc) ổn định. Đừng học các kỹ năng đặc biệt như T-spin vào lúc này
    
    Có 2 kỹ năng cần nắm:
        1. Nhớ vị trí xuất hiện của gạch và điều khiển để di chuyển gạch tới vị trí mong muốn
        2. Lên kế hoạch trước (trong đầu) về nơi đặt các gạch tiếp theo

Liên kết sau là phiên bản tiếng Anh (dịch bởi User670) của một bài viết tên là "Suggestion for new players to Tetris Online" ("Lòi khuyên dành cho người mới chơi Tetris Online") được viết bởi một người chơi xếp gạch ở Trung Quốc tên là Tatianyi (2019). Zictionary có hẳn một mục để giới thiệu về người ấy. Hãy nhấn vào biểu tượng quả địa cầu để xem bài viết
        ]],
        "https://github.com/user670/temp/blob/master/tips_to_those_new_to_top.md",
    },
    {"Đề xuất l.tập [1/2]",
        "readme noob new guides recommendations suggestions helps"..
        "hướng dẫn  người mới chơi  lời khuyên",
        "help",
[[
Lời khuyên khi tập chơi (Trang 1/2):
Chúng tôi có các đề xuất để cải thiện kỹ năng Tetris của bạn (danh sách đề xuất nằm ở mục tiếp theo). Nếu bạn từng cảm thấy khó khăn trong quá trình luyện tập, bạn có thể thư giãn và dành thời gian chơi các chế độ mà bạn yêu thích. Chơi vui vẻ!

Hãy nhớ: mặc dù các đề xuất này được xếp thành nhóm, bạn vẫn nên làm cả ba nhóm cùng lúc thay vì làm từng cái một.

Lưu ý: Nhóm C rất linh động, bạn có thể điều chỉnh độ khó tùy vào khả năng của bạn (ví dụ như "không làm bạn chơi quá chậm")
Sau khi bạn hoàn thành hết nhóm C, hãy tiếp tục luyện tập nhóm A, đây là một kỹ năng RẤT quan trọng trong bất kỳ tựa game xếp gạch nào; và bạn sẽ có thể dần dần làm chủ bất kỳ chế độ nào, lúc đó chỉ cần nhìn lướt qua NEXT là đủ rồi.
]],
    },
    {"Đề xuất l.tập [2/2]",
        "readme noob new guides recommendations suggestions helps"..
        "hướng dẫn  người mới chơi  lời khuyên  trợ giúp",
        "help",
[[
Lời khuyên khi tập chơi (Trang 2/2):
Danh sách các đề xuất mà bạn cần làm theo khi tập chơi:

A. Stacking (Xếp gạch)
    A1. Suy nghĩ kỹ trước khi đặt gạch. Chưa vừa ý? Suy nghĩ thêm lần nữa.
    A2. Xếp gạch càng phẳng càng tốt để bạn có thể ra quyết định đặt gạch dễ dàng hơn.
    A3. Lên kế hoạch trước cách xếp, hãy tận dụng tối đa NEXT và HOLD để giữ được thế đẹp. 

B. Efficiency & Speed (Hiệu quả & Tốc độ)
    B1. Trước mỗi lần đặt gạch, hãy suy nghĩ xem bạn sẽ đặt gạch ở đâu? Bấm những phím nào để gạch tới chỗ đó và đứng đúng tư thế? Thay vì dựa dẫm vào gạch ma quá nhiều
    B2. Nên sử dụng 2 (hoặc 3, tùy game) phím xoay thay vì nhấn 1 phím xoay liên tục trong thời gian dài.
    B3. Đừng lo lắng về tốc độ khi bạn mới tập chơi Finesse, đây là chuyện bình thường. Hơn nữa bạn có thể tập chơi nhanh hơn một khi bạn đã quen tay — việc này không khó đâu!

C. Practice (Luyện tập)
    C1. Hoàn thành chế độ "40 hàng".
    C2. Hoàn thành chế độ "40 hàng" mà không dùng HOLD.
    C3. Hoàn thành chế độ "40 hàng" mà chỉ được làm Techrash.
    C4. Hoàn thành chế độ "40 hàng" mà chỉ được làm Techrash và không được dùng HOLD.
]]
    },
    {"Học làm T-spin",
        "tspins learning study guides tips recommendations suggestions helps",
        "help",
        [[
Xin lưu ý rằng T-spin là một kỹ năng khá là cao cấp trong Tetris, vì vậy bạn không thể thành thạo nó nếu chỉ đơn thuần nhìn vào địa hình nơi T-spin được thực hiện. Tất nhiên, bạn phải có kỹ năng xếp gạch tốt và có thể nhìn quét xa dãy NEXT. Nếu bạn thực sự muốn làm T-spin, hãy đảm bảo bạn thành thạo những kỹ năng cơ bản trước khi học và làm.

Lời khuyên của chúng tôi: chỉ nên bắt đầu học làm T-spin khi bạn có thể xóa 40 hàng với 60 giây hoặc ít hơn (hoặc từ 40-120s tùy vào điều kiện của bạn), 40 hàng chỉ dùng Tetris, 40 hàng chỉ dùng Tetris + không Hold. Tất cả mà không làm bạn bị tụt tốc độ quá nhiều (Phát triển khả năng để xem trước và suy nghĩ đủ kỹ trước khi thả rơi gạch.)
        ]],
    },
    {"Website chính thức",
        "homepage mainpage websites".."website homepage  trang chủ ",
        "help",
        "Trang web chính thức của Techmino!\nBạn có thể lấy bản ổn định mới nhất của Techmino cũng như tạo tài khoản, thay avatar ngay tại đó\nNhấn vào biểu tượng quả địa cầu để mở website đó trong trình duyệt",
        "http://studio26f.org",
    },
    {"Huiji Wiki",
        "huiji wiki",
        "help",
        "(灰机wiki)\n\nMột wiki về Tetris của những người đam mê Tetris từ các nhóm Cộng đồng Nghiên cứu Tetris Trung Quốc và các nhóm phụ của nó. Hiện tại hầu hết các trang đều được tham khảo và dịch từ Hard Drop Wiki và Tetris Wiki. Liên kết sẽ dẫn bạn tới bản tiếng Trung giản thể.",
        "https://tetris.huijiwiki.com",
    },
    {"Hard Drop Wiki",
        "harddrop hd wiki",
        "help",
        "Một wiki về Tetris được host bởi cộng đồng Hard Drop.",
        "https://harddrop.com/wiki/Tetris_Wiki",
    },
    {"Tetris.wiki",
        "tetris wiki",
        "help",
        "Tetris.wiki là một wiki tập trung vào các nội dung liên quan đến Tetris. Wiki được tạo ra từ năm 2015 bởi Myndzi. Trong những năm qua, hàng nghìn đóng góp đã được thực hiện để ghi lại các game xếp gạch chính thức và các game do fan làm, các series, những cơ chế của game,... cũng như tạo ra những bài hướng dẫn để cải thiện cách chơi.",
        "https://tetris.wiki",
    },
    {"Tetris Wiki Fandom",
        "tetris wiki fandom",
        "help",
        "Cũng là một wiki về Tetris nhưng nó ở trên Fandom",
        "https://tetris.fandom.com/wiki/Tetris_Wiki",
    },
    {"Four.lol",
        "four wiki",
        "help",
        "Một website chứa các setup để làm opener",
        "https://four.lol",
    },
    {"‘Tetris Hall’",
        "",
        "help",
        "(テトリス堂)\n\nMột trang web tiếng Nhật, chứa nhiều setup, hướng dẫn cũng như có các minigame. Nó cũng có mô tả chi tiết về PC liên tiếp",
        "https://shiwehi.com/tetris/",
    },
    {"‘Tetris Template Collections’",
        "",
        "help",
        "(テトリステンプレ集@テト譜)\n\nMột trang web tiếng Nhật với các setup và các danh mục chi tiết. Hầu hết các setup đều có ảnh minh họa, vì vậy việc chia sẻ với người khác sẽ dễ dàng hơn.",
        "https://w.atwiki.jp/tetrismaps/",
    },
    {"tetristemplate.info",
        "",
        "help",
        "(テトリスブログ - PerfectClear)\n\nMột trang web ở Nhật Bản chứa một số setup. Tuy số lượng không bằng các trang web khác nhưng bù lại các setup đều được giải thích rất chi tiết",
        "https://tetristemplate.info/",
    },
    {"Fumen",
        "fumen",
        "help",
        "Đây là một công cụ chỉnh sửa bảng dành cho Tetris bằng tiếng Nhật. Thường được sử dụng để chia sẻ setup, PC solution (hướng đi để làm PC), v.v. Liên kết của mục này sẽ dẫn bạn tới bản tiếng Anh.",
        "http://fumen.zui.jp/#english.js",
    },
    {"Fumen bản Đ.thoại",
        "fumenformobile fm",
        "help",
        "Fumen for Mobile (Fumen bản dành cho Điện thoại)\n\nCũng là Fumen nhưng hỗ trợ cho màn hình cảm ứng",
        "https://knewjade.github.io/fumen-for-mobile/",
    },
    -- # Webpages / Organizations
    {"Dự án trên GitHub",
        "githubrepository sourcecode src".."mã nguồn mở  dự án  kho lưu trữ",
        "org",
        "Kho lưu trữ chính thức của Techmino trên GitHub. Chúng tôi đánh giá cao nếu bạn tặng cho chúng tôi một ngôi sao! (bạn có thể tặng sao miễn phí).",
        "https://github.com/26F-Studio/Techmino",
    },
    {"Cộng đồng",
        "community communities discord".."cộng đồng",
        "org",
        "Hãy tham gia các cộng đồng về xếp gạch và nói chuyện với những người khác. Bạn có thể tham gia cộng đồng Hard Drop bằng cách nhấn vào biểu tượng quả địa cầu.",
        "https://discord.gg/harddrop",
    },
    {
    "Tetris Việt Nam",      -- I will edit it later
        "community vietnam  việt nam ",
        "org",
        [[
Một trong những cộng đồng xếp gạch tại Việt Nam. Cộng đồng này hiện có một nhóm Facebook và một server tại Discord.

Liên kết ở mục này sẽ dẫn bạn tới server Discord, còn để tìm nhóm Facebook thì lên Facebook và tìm "Tetris Việt Nam"
        ]],
        "https://discord.gg/jX7BX9g",
    },
    {"Tetris OL Servers",
        "tetrisonline servers tos".."server  tos",
        "org",
        "Hãy lên Google tra “Tetris Online Poland” để tìm server ở Ba Lan.\nCòn nếu tìm server Tetris Online Study được đặt tại Trung Quốc (cung cấp bởi Teatube) thì nhấn vào biểu tượng quả địa cầu",
        "https://teatube.cn/tos/",
    },
FNNS and     {"Ủng hộ 1",
        "support wechat vx weixin alipay zfb zhifubao",
        "org",
        platform_restriction_text,
    } or     {"Ủng hộ 1",
        "support wechat vx weixin alipay zfb zhifubao",
        "org",
        "Để ủng hộ cho Techmino thông qua WeChat Pay hoặc Alipay, gõ “support” ở trong console và quét mã QR.",
    },
FNNS and     {"Ủng hộ 2",
        "support afdian aidadian",
        "org",
        platform_restriction_text,
    } or     {"Ủng hộ 2",
        "support afdian aidadian",
        "org",
        "Để ủng hộ cho Techmino qua Aifadian, hãy nhấn vào biểu tượng quả địa cầu để mở URL trực tiếp vào trình duyệt. Lưu ý là Aifadian sẽ trừ bạn 6% phí giao dịch.",
        "https://afdian.net/@MrZ_26",
    },
FNNS and     {"Ủng hộ 3",
        "support patreon",
        "org",
        platform_restriction_text,
    } or     {"Ủng hộ 3",
        "support patreon",
        "org",
        "Để ủng hộ cho Techmino qua Patreon, hãy nhấn vào biểu tượng quả địa cầu. Lưu ý rằng Patreon có thể tính phí dịch vụ cho bạn đối với các giao dịch trên một số tiền nhất định.",
        "https://www.patreon.com/techmino",
    },
    -- # Games
    {"TTT",
        "tetris trainer tres bien",
        "game",
        [[
Tetris Trainer Très-Bien (viết bởi こな “kona”). Một website chứa các hướng dẫn thực hành các kỹ thuật nâng cao trong Tetris hiện đại (lưu ý: website này chỉ hỗ trợ bàn phím vật lý, không phải bàn phím ảo).
Đề xuất cho những người chơi có thể hoàn thành chế độ 40L chỉ làm Tetris + không dùng Hold
Website này đề cập tới T-spin, finesse, SRS và một số setup để chơi Battle
Liên kết sẽ dẫn bạn tới phiên bản tiếng Anh, được dịch bởi User670 (Bản gốc là bản tiếng Nhật).
        ]],
        "https://user670.github.io/tetris-trainer-tres-bien/",
    },
    {"TTPC",
        "tetris perfect clear challenge",
        "game",
        [[
Tetris Perfect Clear Challenge (viết bởi chokotia). Một website hướng dẫn bạn cách làm Perfect Clear khi sử dụng hệ thống xoay SRS và Bag-7 (chỉ hỗ trợ bàn phím). Đề xuất sử dụng nếu bạn đã hoàn thành TTT và đã làm quen với SRS

Liên kết sẽ dẫn bạn tới phiên bản tiếng Anh, bản gốc là tiếng Nhật
        ]],
        "https://teatube.cn/ttpc/ttpc/",
    },
    {"NAZO",
        "nazo",
        "game",
        [[
(ナゾ)

Một website chứa các loại câu đố SRS từ dễ đến cực kỳ khó, bao gồm T-spin và All spin. Đề xuất cho những người đã hoàn thành TTT.

Liên kết sẽ dẫn bạn tới bản tiếng Trung Giản thể, nguyên bản bằng tiếng Nhật.
        ]],
        "https://teatube.cn/nazo/",
    },
    {"TPO",
        "nazo",
        "game",
        "Tetris Puzzle O. Một trang web bằng tiếng Nhật được viết bởi TCV100 (có lấy một vài câu đố từ NAZO sang).",
        "http://121.36.2.245:3000/tpo",
    },
    {"Ghi chú về mục game",
        "note nb NB DM notice",
        "game",
        "Nội dung sau đây là những giới thiệu ngắn gọn về một số game xếp gạch chính thức và do fan làm có mức độ phổ biến cao. MrZ - tác giả của Techmino đã để lại một vài lời nhận xét, và Sea - tình nguyện viên dịch Zictionary sang tiếng Việt, có để lại một vài lời nhận xét và một số thông tin bổ sung về một vài game. Hãy nhớ là không phải game nào được nhắc đến đều có lời nhận xét, và chúng chỉ là những ý kiến chủ quan. Đọc chỉ để tham khảo, những nhận xét này không có tính chuyên môn.",
    },
    {"King of Stackers",
        "kos kingofstackers",
        "game",
        [[
Chơi trên trình duyệt | Chơi trực tuyến | Hỗ trợ điện thoại

Gọi tắt là KoS. Một game xếp gạch chơi trên trình duyệt theo lượt. Các quy tắc chính như sau: người chơi thay phiên nhau đặt các gạch trong bảng của họ theo chu kỳ 7 gạch. Các cuộc tấn công chỉ vào bảng khi một gạch được đặt mà không xóa một hàng nào. Trò chơi mang tính chiến lược cao và có các tùy chọn khác nhau cho cơ chế tấn công.
        ]],
        "https://kingofstackers.com/games.php",
    },
    {"Tetr.js",
        "tetrjs tetr.js",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn | Hỗ trợ điện thoại

Một game xếp gạch chơi trên trình duyệt với nhiều điều chỉnh và chế độ chuyên nghiệp.
Liên kết của mục này sẽ đưa bạn tới bản của Farter (bản này là một bản đã mod, đã thêm một vài chế độ khác)
Bạn cũng có thể tìm một phiên bản khác có tên là "Tetr.js Enhanced" - bản mod này do Dr Ocelot làm

[MrZ: Giao diện đơn giản với hầu như không có bất kỳ hiệu ứng (animation) nào. Chỉ có một số tổ hợp phím ảo khả dụng cho thiết bị di động.]

[Sea: Hiện tại Tetr.js Enhanced không còn khả dụng nữa. Và Dr Ocelot cũng không muốn mang Tetr.js Enhanced quay lại]
        ]],
        "http://farter.cn/t",
    },
    {"Tetra Legends",
        "tl tetralegends",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn | Không hỗ trợ điện thoại

Gọi tắt là TL. Một tựa game chứa nhiều chế độ chơi đơn + 2 chế độ nhịp điệu. INó cũng hình dung các cơ chế thường ẩn trong các trò chơi Tetris khác. Quá trình phát triển đã dừng lại (và bỏ hoang) từ tháng 12 năm 2020.
        ]],
        "https://tetralegends.app",
    },
    {"Ascension",
        "asc ASC",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn/Chơi trực tuyến

Gọi tắt là ASC. Game sử dụng hệ thống xoay có tên là ASC và có nhiều chế độ chơi đơn. Chế độ 1 đấu 1 hiện vẫn còn trong giai đoạn Alpha (16/T4/2022). Chế độ Stack của Techmino cũng bắt nguồn ý tưởng từ game này.
        ]],
        "https://asc.winternebs.com",
    },
    {"Jstris",
        "js jstris",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn/Chơi trực tuyến | Hỗ trợ điện thoại

Gọi tắt là JS. Nó có một số chế độ chơi đơn với thông số có thể điều chỉnh được. Có thể điều chỉnh phím ảo trên màn hình, nhưng trò chơi này không có hiệu ứng động nào cả.
        ]],
        "https://jstris.jezevec10.com",
    },
    {"TETR.IO",
        "io tetrio tetr.io teto",
        "game",
        [[
Chơi trên trình duyệt/Chơi trên client chính thức | Chơi đơn/Chơi trực tuyến

Gọi tắt là teto hoặc IO. Trò chơi này có một hệ thống xếp rank cũng như có chế độ tự do với nhiều thông số có thể tùy chỉnh. Trò chơi này cũng có một client dành cho máy tính, giúp cải thiện tốc độ, giảm độ trễ và gỡ bỏ quảng cáo
        
[MrZ: Có vẻ như Safari không thể mở game này.]
        ]],
        "https://tetr.io",
    },
    {"Nuketris",
        "nuketris",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn/Chơi trực tuyến

Một trò xếp gạch có chế độ 1 đấu 1 có xếp rank + các chế độ chơi đơn thông thường
        ]],
        "https://nuketris.com",
    },
    {"Worldwide Combos",
        "wwc worldwidecombos",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn/Chơi trực tuyến

Gọi tắt là WWC. Có chế độ 1 đấu 1 toàn cầu: chơi với người thật hoặc chơi với bản ghi trận đấu; có vài quy tắc khác nhau, với các trận đấu gửi rác bằng bom."
        ]],
        "https://worldwidecombos.com",
    },
    {"Tetris Friends",
        "tf tetrisfriends notrisfoes",
        "game",
        [[
Chơi trên trình duyệt/Chơi trên client chính thức | Chơi đơn/Chơi trực tuyến

Gọi tắt là TF. Một trò chơi Tetris dựa trên một plugin đã bị khai tử từ lâu. Từng rất phổ biến trong quá khứ, nhưng tất cả trò chơi đã đóng cửa từ mấy năm trước. Hiện giờ còn một máy chủ riêng tư tên là “Notris Foes” vẫn còn tồn tại. Nhấn vào biểu tượng quả địa cầu để mở ở trong trình duyệt

[Sea: Lưu ý bạn cần phải cài một client cho Notris Foes thì mới có thể chạy game. Sẽ tốn công vô ích nếu bạn cố cài tiện ích bổ sung trên trình duyệt bạn hay dùng để chạy game.]
        ]],
        "https://notrisfoes.com",
    },
    {"tetris.com",
        "tetris online official",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn | Hỗ trợ điện thoại

Game Tetris chính thức tetris.com, mà chỉ có một chế độ (Marathon). Bù lại, có hỗ trợ hệ thống điều khiển thông minh bằng chuột

[Sea: Thông tin thêm: nếu bạn ở trên điện thoại thì có ba cách điều khiển: "vuốt" (swipe), "thông minh" (smart), "bàn phím". Bạn có thể thử nghiệm với cả ba chế độ điều khiển để tìm xem chế độ nào phù hợp với mình nhất. Để điều khiển bằng "bàn phím" thì bạn chỉ cần kết nối với bàn phím là được (miễn là điện thoại có thể nhận bàn phím thì game cũng sẽ nhận thôi), còn để đổi giữa "vuốt" và "thông minh" thì hãy mở Options của game.]
        ]],
    },
    {"Tetris Gems",
        "tetris online official gem",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn | Hỗ trợ điện thoại

Một game xếp gạch khác từ tetris.com . Có cơ chế trọng lực và mỗi ván chỉ kéo dài trong 1 phút. Có 3 loại gem (ngọc) khác nhau với khả năng riêng biệt.
        ]],
    },
    {"Tetris Mind Bender",
        "tetris online official gem",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn | Hỗ trợ điện thoại

Một game xếp gạch khác từ tetris.com . Một chế độ Marathon vô tận với một mino đặc biệt gọi là "Mind Bender" sẽ đưa cho bạn ngẫu nhiên một hiệu ứng nào đó (có thể là tốt hoặc xấu).
        ]],
    },
    {"Techmino",
        "techmino",
        "game",
        [[
Đa nền tảng | Chơi đơn/Chơi trực tuyến

Gọi tắt là Tech. Một tựa game xếp gạch được phát triển bởi MrZ. Sử dụng engine LÖVE (love2d). Có rất nhiều chế độ chơi đơn, cũng như có nhiều thông số có thể tùy chỉnh được. Tuy nhiên, chế độ nhiều người chơi hiện tại vẫn đang còn phát triển
        ]],
    },
    {"Falling Lightblocks",
        "fl fallinglightblocks",
        "game",
        [[
Chơi trên trình duyệt/iOS/Android | Chơi đơn/Chơi trực tuyến

Một game xếp gạch đa nền tảng có thể chơi ở chế độ dọc hoặc ngang. Game này có DAS và ARE khi xóa hàng cố định; và có thể điều chỉnh cơ chế điều khiển trên điện thoại. Hầu hết các chế độ trong game đều được thiết kế dựa trên NES Tetris, nhưng cũng có vài chế độ hiện đại. Chế độ Battle theo kiểu nửa "theo lượt", nửa "theo thời gian thực", rác cũng không vào hàng chờ hay có thể hủy được.
        ]],
        "https://golfgl.de/lightblocks/",
    },
    {"Cambridge",
        "cambridge",
        "game",
        [[
Đa nền tảng | Chơi đơn

Một game xếp gạch được phát triển bằng LÖVE và được dảnh riêng để tạo ra một nền tảng mạnh mẽ, dễ dàng tùy chỉnh để tạo ra các chế độ mới. Ban đầu được phát triển bởi Joe Zeng, Milla đã tiếp quản quá trình phát triển từ 08/T10/2020, kể từ V0.1.5.

— Tetris Wiki
        ]],
    },
    {"Nanamino",
        "nanamino",
        "game",
        [[
Windows/Android | Chơi đơn
        
Một trò chơi do fan làm đang được phát triển với hệ thống xoay đặc trưng cực kỳ thú vị,
        ]],
    },
    {"TGM",
        "tetrisgrandmaster tetristhegrandmaster",
        "game",
        [[
Chỉ có trên game thùng | Chơi đơn/Chơi qua mạng cục bộ

Tetris The Grand Master, một series Tetris dành cho máy thùng. Những thứ như S13 hay GM cũng từ chính series này. TGM3 được coi là tựa game nổi tiếng nhất của series này.
        ]],
    },
    {"DTET",
        "dtet",
        "game",
        [[
Windows | Chơi đơn

Một game xếp gạch dựa trên quy tắc Cổ điển của TGM + 20G với hệ thống xoay gạch mạnh mẽ. Cơ chế điều khiển tốt nhưng không có tùy chỉnh nào ngoài tùy chỉnh gán phím. Game này bây giờ hơi khó tìm và bạn có thể phải cài tệp DLL cần thiết bằng tay 

[Sea: Lưu ý rằng game không chạy được trên Windows Vista, bạn có thể phải sử dụng máy ảo (virutal machine) cài hệ điều hành Windows XP mới có thể chạy được.]
        ]],
    },
    {"Heboris",
        "hb heboris",
        "game",
        [[
Windows | Chơi đơn

Một game với phong cách chơi Arcade, có khả năng mô phỏng nhiều chế độ của các trò chơi Tetris khác.
        ]],
    },
    {"Texmaster",
        "txm texmaster",
        "game",
        [[
Windows | Chơi đơn

Một game bao gồm tất cả chế độ trong TGM để có thể sử dụng để thực hành TGM. Lưu ý rằng quy tắc Rule trong Texmaster hơi khác một chút so với TGM
        ]],
    },
    {"Tetris Effect",
        "tec tetriseffectconnected",
        "game",
        [[
PS/Oculus Quest/Xbox/NS/Windows | Chơi đơn/Chơi trực tuyến

Gọi tắt là TE(C). Một game xếp gạch chính thức với đồ họa và nhạc nền lạ mắt chuyển động theo sự điều khiển của bạn. Phiên bản cơ bản (Tetris Effect, không có chữ "Connected") chỉ có các chế độ chơi đơn. Phiên bản mở rộng, Tetris Effected Connected có 4 chế độ chơi trực tuyến đó là: Connected (VS), Zone Battle, Score Attack, và Classic Score Attack.
        ]],
    },
    {"Tetris 99",
        "t99 tetris99",
        "game",
        [[
Nintendo Switch | Chơi đơn/Chơi trực tuyến

Một trò chơi nổi tiếng với chế độ Battle Royale 99 người và có nhiều chiến lược thú vị mà không có trong các trò chơi chiến đấu truyền thống. Nó cũng có các chế độ chơi đơn hạn chế như Marathon hay các trận đấu bot có sẵn dưới dạng DLC
        ]],
    },
    {"Puyo Puyo Tetris",
        "ppt puyopuyotetris",
        "game",
        [[
PS/NS/Xbox/Windows | Chơi đơn/Chơi trực tuyến

Đây là một tựa game ghép từ hai trò chơi giải đố: Tetris  và Puyo Puyo, và bạn có thể chơi đối đầu trong cả hai game này. Có nhiều chế độ chơi đơn và chơi trực tuyến.

[MrZ: Bản PC (Steam) có cơ chế điều khiển và trải nghiệm trực tuyến khá là tệ.]
        ]],
    },
    {"Tetris Online",
        "top tetrisonline",
        "game",
        [[
Windows | Chơi đơn/Chơi trực tuyến

Một game xếp gạch của Nhật Bản đã bị khai tử từ lâu. Có chế độ chơi đơn và chơi trực tuyến. Có thể điều chỉnh DAS và ARR nhưng không thể đặt thành 0. Độ trễ đầu vào nhỏ. Tuy server chính ở Nhật đã bị đóng cửa còn lâu nhưng vẫn còn tồn tại server riêng. Game rất phù hợp cho những người mới bắt đầu.
        ]],
    },
    {"Tetra Online",
        "TO tetraonline",
        "game",
        [[
Windows/macOS/Linux | Chơi đơn/Chơi trực tuyến

Gọi tắt là TO. Một tựa game xếp gạch được phát triển bởi Dr Ocelot và Mine. Các loại độ trễ như AREs được cố tình đẩy ở giá trị cao, và những ai đã từng quen chơi xếp gạch mà có độ trễ thấp/không có độ trễ sẽ khó làm quen với game này
Game đã bị gỡ ra khỏi Steam vào ngày 9/T12/2020 do TTC gửi thông báo DMCA
Dù sao thì, vẫn còn một bản build có thể tải từ GitHub.
        ]],
        "https://github.com/Juan-Cartes/Tetra-Offline/releases/tag/1.0",
    },
    {"Cultris II",
        "c2 cultris2 cultrisii",
        "game",
        [[
Windows/OS X | Chơi đơn/Chơi trực tuyến

Gọi tắt là C2. Được thiết kế dựa trên Tetris cổ điển, Cultris II cho phép bạn có thể điều chỉnh DAS và ARR. Chế độ chiến đấu tập trung vào các combo dựa trên thời gian, thử thách người chơi về mặt tốc độ, n-wide setup và kỹ năng đào xuống của người chơi

[MrZ: Phiên bản dành cho Mac đã không được bảo trì trong thời gian dài. Nếu bạn đang dùng macOS Catalina hoặc macOS mới hơn thì không thể chạy game này.]
        ]],
    },
    {"Nullpomino",
        "np nullpomino",
        "game",
        [[
Windows/macOS/Linux | Chơi đơn/Chơi trực tuyến

Gọi tắt là NP. Một game xếp gạch chuyên nghiệp có khả năng tùy biến cao. Gần như mọi thông số trong game đều có thể điều chỉnh được.

[MrZ: Giao diện của game mang phong cách retro. Ngoài ra, game chỉ có thể điều khiển thông qua bàn phím, nên một vài người chơi mới sẽ gặp khó khi làm quen. Ngoài ra, có vẻ như macOS Monterey không thể chạy được game này.]
        ]],
    },
    {"Misamino",
        "misamino",
        "game",
        [[
Windows | Chơi đơn

Chỉ có chế độ chơi 1 đấu 1 với bot, chủ yếu là chơi theo lượt. Bạn có thể viết bot cho game này (nhưng bạn cần phải học API của game này).

Misamino cũng là tên của bot trong game này.
        ]],
    },
    {"Touhoumino",
        "touhoumino",
        "game",
        [[
Windows | Chơi đơn

Một game Tetris do fan làm. Game này là một bản chỉnh sửa của Nullpomino

[MrZ: Được đề xuất cho những người chơi có ít nhất một nửa kỹ năng, nếu không, bạn thậm chí không biết mình đã chết như thế nào]
        ]],
    },
    {"Tetris Blitz",
        "blitz ea mobile phone",
        "game",
        [[
iOS/Android | Chơi đơn

Một game xếp gạch được làm bởi Electronic Arts (EA). Có cơ chế trọng lực, và mỗi ván game chỉ kéo dài trong vòng 2 phút. Sẽ có một vài gạch sẽ rơi xuống (làm đệm) mỗi khi bắt đầu mỗi ván, và bạn có thể kích hoạt chế độ “Frenzy” bằng cách liên tục xóa hàng. Có rất nhiều loại power-up khác nhau, thậm chí có cả Finisher giúp cho màn chơi kết thúc của bạn thêm đẹp mắt và tăng mạnh số điểm của bạn lên. Game không có cơ chế top-out. Khi mà gạch vừa tới đè lên gạch đang có thì tự động một vài hàng trên cùng sẽ tự động xóa 

Game đã bị khai tử từ tháng 4 năm 2020
        ]],
    },
    {"Tetris (EA)",
        "tetris ea galaxy universe cosmos mobile phone",
        "game",
        [[
iOS/Android | Chơi đơn/Chơi trực tuyến?

Một tựa game xếp gạch được phát triển bởi EA. Có hai cách điều khiển: Swipe (Vuốt) và One-Touch (Một chạm). Game này có chế độ Galaxy ngoài chế độ Marathon (với cơ chế trọng lực), và mục tiêu của chế độ này là xóa hết tất cả các gạch của Galaxy trước khi hết chuỗi gạch

Game đã bị khai tử từ tháng 4 năm 2020

[Sea: game đang nhắc ở đây là bản năm 2011 (phát hành khoảng 2011 - 2012)]
        ]],
    },
    {"Tetris (N3TWORK)",
        "tetris n3twork mobile phone",
        "game",
        [[
iOS/Android | Chơi đơn

Một tựa game xếp gạch, trước đây được phát triển bởi N3TWORK. Nhưng từ cuối tháng 11 năm 2021, PlayStudios đã giành được bản quyền để phát triển độc lập. Từ đó PlayStudios tiếp tục phát triển game này. Có chế độ Chơi nhanh 3 phút, Marathon, chế độ Royale 100 người chơi và chế độ Phiêu lưu (nơi mà bạn sẽ phải hoàn thành toàn bộ mục tiêu trước khi hết lượt).

Ghi chú: từ tháng 11 hoặc tháng 12 năm 2022 và sau này, tất cả các tài khoản mới tạo chỉ có chế độ Marathon và chế độ Phiêu lưu. Tức là chế độ Chơi nhanh và Royale sẽ không xuất hiện trên những tài khoản này

[MrZ: UI thì tuyệt nhưng cơ chế điều khiển thì tệ]

[Sea: Z nói cơ chế điều khiển tệ là vì: phím trên màn hình cảm ứng nó khá là nhỏ, nhỏ hơn cả ngón tay mình có thể bấm. Mà cơ chế vuốt cũng không ổn lắm.]
        ]],
    },
    {"Tetris Beat",
        "n3twork rhythm",
        "game",
        [[
iOS | Chơi đơn
        
Một game xếp gạch tới từ nhà N3TWORK nhưng chỉ dành cho Apple Arcade. Nó có một chế độ gọi là “Beat” ngoài chế độ Marathon, nhưng bạn chỉ có thể thả gạch theo nhịp của bài thôi.

[Hiệu ứng của game rất là nặng và cơ chế điều khiển không tốt]
        ]],
    },
    {"Tetris Journey",
        "tetrisjourney mobile phone huanyouji",
        "game",
        [[
iOS/Android | Chơi đơn

[Sea: mục này mình xin phép viết lại cho dễ đọc, MrZ viết rối quá mình dịch không nổi. Có tham khảo từ Tetris.wiki]

Một game xếp gạch chính thức đã bị khai tử được phát triển bởi Tencent (chỉ có ở Trung Quốc).

Có 5 chế độ chơi đơn: Marathon, Sprint (40 hàng), Ultra (2 phút), Road to Master (chế độ luyện tập, chứa nhiều bài học về các kỹ thuật khác nhau), Adventure (chế độ câu chuyện với minigame).

Cùng với 3 chế độ chơi trực tuyến gồm: League Battle (chế độ đối đầu có xếp rank), Melee 101 (na ná như Tetris 99 nhưng mỗi phòng có 101 người), Relax Battle (cũng chế độ đối đầu nhưng không xếp rank)
Mỗi trận trong chế độ chơi trực tuyến thường dài 2 phút, nếu không ai bị top out thì ai gửi nhiều hàng nhất sẽ giành chiến thắng

Có thể điều chỉnh vị trí và kích thước phím ảo, nhưng không thể điều chỉnh DAS và ARR.
        ]],
    },
    {"JJ Tetris",
        "jjtetris",
        "game",
        [[
Android | Chơi trực tuyến

(JJ块)

Một game bình thưởng trên JJ Card Games (JJ棋牌). Chơi ở màn hình dọc, độ trễ đầu vào thấp, điều khiển mượt. DAS/ARR có thể điều chỉnh được, nhưng hạn chế về tùy biến bố cục phím ảo. Không Hold cũng như B2B, không bộ đệm rác hay hủy rác được [giống như FULL Passthough trong tetr.io]. Mỗi tấn công gửi tối đa 4 hàng, còn combo thì "ao chình". Phần còn lại thì tương tự như Tetris hiện đại.
        ]],
    },
    {"Huopin Tetris",
        "huopin qq",
        "game",
        [[
Windows | Chơi trực tuyến

(火拼俄罗斯)

Một game xếp gạch ở trên Tencent Game Center, bảng rộng 12 ô, DAS và ARR giống với DAS và ARR hay dùng trong các app gõ văn bản, 1 Next, không Hold. Chỉ có thể gửi rác bằng Tetris (gửi 3 hàng rác) và xóa 3 hàng (gửi 2 hàng rác). Hàng rác có cấu trúc bàn cờ và gần như không thể đào xuống
        ]],
    },
    -- # Terms
    {"Ghi chú dịch #2",
        "",
        "help",
        [[
Ghi chú về những thuật ngữ

Về thuật ngữ có liên quan với "mỗi phút" và "mỗi giây": Không phải tất cả thuật ngữ nào được nhắc đến trong này đều được áp dụng rộng rãi trong cộng đồng, hoặc là có chung ý nghĩa trong mọi bối cảnh. Chúng chủ yếu áp dụng cho Techmino

Về các thuật ngữ spawn delay và clear delay:
    spawn delay: thời gian cần để gạch sinh ra (gạch xuất hiện ở trên đầu bảng)
    clear delay: thời gian cần để hàng có thể biến mất

        ]],
    },
    {"LPM",
        "linesperminute speed",
        "term",
        [[
Lines per minute | Số hàng mỗi phút
    Phản ánh tốc độ chơi.
    Mỗi game có cách tính LPM khác nhau. Ví dụ như, Tetris Online tính LPM bằng cách sử dụng PPS (nhìn mục ở bên dưới), trong đó 1 PPS = 24 LPM; do đó số hàng rác sẽ không được tính vào LPM và làm cho LPM khác với nghĩa đen của nó. Trong Techmino, giá trị LPM theo cách tính của Techmino gọi là "L'PM"
        ]],
    },
    {"PPS",
        "piecespersecond speed",
        "term",
        "Pieces per second | Số gạch mỗi giây\n\tPhản ánh tốc độ chơi.",
    },
    {"BPM",
        "blocksperminute piecesperminute speed",
        "term",
        "Blocks per minute | Số gạch mỗi phút\n\tPhản ánh tốc độ chơi.\n\tNgoài ra chúng được gọi là PPM (để tránh nhầm lẫn với một thuật ngữ trong âm nhạc) (P là viết tắt của từ Pieces).",
    },
    {"KPM",
        "keysperminute keypressesperminute",
        "term",
        "Keypresses per minute | Số lần nhấn mỗi phút\n\tPHản ánh tốc độ người chơi nhấn phím hoặc nút.",
    },
    {"KPP",
        "keysperpiece keypressesperpiece",
        "term",
        "Keypresses per piece | Số lần nhấn mỗi viên gạch\n\tPhản ánh mức độ hiệu quả việc điều khiển gạch. Giảm con số này bằng cách học Finesse",
    },
    {"APM",
        "attackperminute",
        "term",
        "Attack per minute | Số hàng tấn công mỗi phút\n\tPhản ánh sức mạnh tấn công của người chơi",
    },
    {"SPM",
        "linessentperminute",
        "term",
        "[lines] Sent per minute | Số hàng gửi mỗi phút \n\tPhản ánh sức mạnh tấn công *thực tế* của người chơi (không tính các hàng được xóa để xử những hàng rác trong bộ đệm).",
    },
    {"DPM",
        "digperminute defendperminute",
        "term",
        "Dig/Defend per minute | Số hàng đào xuống mỗi phút\n\tĐôi khi có thể phản ánh mức độ sống sót của người chơi khi nhận được rác",
    },
    {"RPM",
        "receive jieshou",
        "term",
        "[lines] Receive per Minute\n\tPhản ánh áp lực hiện có của người chơi",
    },
    {"ADPM",
        "attackdigperminute vs",
        "term",
        "Attack & Dig per minute | Số hàng tấn công & đào xuống mỗi phút\n\tDùng để so sánh sự khác nhau về kỹ năng của hai người chơi trong một trận đấu; chính xác hơn một chút so với APM\n\tNhân tiện thì VS Score (điểm VS) trong tetr.io chính là ADPM mỗi 100 giây",
    },
    {"APL",
        "attackperline efficiency",
        "term",
        "Attack per line (cleared) | Số hàng tấn công / Số hàng đã xóa\n\tCòn được biết với tên “efficiency” (độ hiệu quả). Phản ánh độ hiệu quả khi tấn công sau mỗi lần xóa hàng. Ví dụ Tetris và T-spin có độ hiệu quả cao hơn so với Xóa 2 hàng và Xóa 3 hàng.",
    },
    {"Single",
        "single 1",
        "term",
        "Xóa 1 hàng cùng một lúc.",
    },
    {"Double",
        "double 2",
        "term",
        "Xóa 2 hàng cùng một lúc.",
    },
    {"Triple",
        "triple 3",
        "term",
        "Xóa 3 hàng cùng một lúc.",
    },
    {"Techrash",
        "techrash tetris 4",
        "term",
        "*Chỉ có trên Techmino*\n\nXóa 4 hàng cùng một lúc.",
    },
    {"Tetris",
        "tetris 4",
        "term",
        "Đây chính là tên game (cũng như là tên thương hiệu của nó). Đây cũng là thuật ngữ chỉ việc xóa 4 hàng cùng lúc trong các game chính thức.\nĐược ghép từ 2 từ: Tetra (<τέτταρες>, có nghĩa là số 4 trong tiếng Hy Lạp) and Tennis (quần vợt, môn thể thao yêu thích nhất của người đã sáng tạo ra Tetris). Nhân tiện những game xếp gạch được phát triển bởi Nintendo và SEGA đều được cấp phép bởi TTC. Hai công ty này không có bản quyền của Tetris",
        -- _comment: original Lua file had this comment: "Thanks to Alexey Pajitnov!"
    },
    {"All Clear",
        "pc perfectclear ac allclear",
        "term",
        "Còn được biết tới là Perfect Clear (PC). Đây là thuật ngữ được dùng nhiều trong cộng đồng và cũng như được dùng trong Techmino\nXóa toàn bộ gạch ra khỏi bảng, không trừ gạch nào\n\n[Sea: từ này còn một tên khác nữa giờ ít dùng đó là “Bravo”]",
    },
    {"HPC",
        "hc clear halfperfectclear",
        "term",
        "*Chỉ có trên Techmino*\n\nHalf Perfect Clear\nMột biến thể của All Clear. Nếu hàng đó bị xóa mà rõ ràng giống với Perfect Clear khi bỏ qua những hàng bên dưới, thì được tính là Half Perfect Clear và sẽ gửi thêm một lượng hàng rác nhỏ",
    },
    {"Spin",
        "spin",
        "term",
        "Xoay gạch để di chuyển tới một vị trí mà thông thường sẽ không tiếp cận được. Ở một số game, thao tác này sẽ gửi thêm hàng rác hoặc là tăng thêm điểm. Game khác nhau sẽ có cách kiểm tra Spin khác nhau.",
    },
    {"Mini",
        "mini",
        "term",
        "Một thuật ngữ bổ sung khác chỉ những Spin mà game nghĩ là có thể thực hiện dễ dàng (bởi vì trong một game cũ nó được gọi là “Ez T-spin”). Bonus điểm và hàng rác đều bị giảm so với Spin thông thường.\nCác game khác nhau có các quy tắc khác nhau để kiểm tra chúng có phải là Mini-Spin hay không. Bạn chỉ cần nhớ mấy cái bố cục làm Mini-spin là được.",
    },
    {"All-spin",
        "allspin",
        "term",
        "Một quy luật mà trong đó, làm Spin bằng gạch gì đều cũng được thưởng thêm điểm và gửi thêm hàng rác; đối lập với việc chỉ được Spin bằng gạch T (hay còn gọi là “Chỉ làm T-spin”).",
    },
    {"T-spin",
        "tspin",
        "term",
        [[
Spin được thực hiện bởi Tetromino T.
Trong các game hiện đại chính thức, T-spins chủ yếu được phát hiện bởi quy luật 3 góc. Tức là, nếu 3 trong 4 góc của một hình chữ nhật (có tâm là tâm xoay của gạch T) bị đè bởi bất kỳ gạch nào, thì Spin đó được tính là T-spin. Một vài game cũng sẽ có thêm vài quy tắc để xem T-spin đó có phải là T-spin thường không hay Mini T-spin.
        ]],
    },
    {"TSS",
        "t1 tspinsingle",
        "term",
        "T-spin Single | T-spin Đơn\nXóa một hàng bằng T-spin",
    },
    {"TSD",
        "t2 tspindouble",
        "term",
        "T-spin Double | T-spin Đôi\nXóa hai hàng bằng T-spin.",
    },
    {"TST",
        "t3 tspintriple",
        "term",
        "T-spin Triple | T-spin Tam\nXóa ba hàng bằng T-spin.",
    },
    {"MTSS",
        "minitspinsingle tsms tspinminisingle",
        "term",
        "Mini T-spin Single | Mini T-spin Đơn\nTrước đây từng biết tới với tên là T-spin Mini Single (TSMS) (T-spin Mini Đơn).\nXóa một hàng bằng Mini T-spin.\nMỗi game sẽ có cách khác nhau để xác định xem T-spin đó có phải là Mini hay không.",
    },
    {"MTSD",
        "minitspindouble tsmd tspinminidouble",
        "term",
        "Mini T-spin Double | Mini T-spin Đôi\nTrước đây từng biết tới với tên là T-spin Mini Double (TSMD) (T-spin Mini Đôi).\nXóa hai hàng bằng Mini T-spin. MTSD chỉ xuất hiện trong một vài game hạn chế và có các cách kích khác nhau.",
    },
    {"O-Spin",
        "ospin",
        "term",
        "Bởi vì gạch O “tròn”, không đổi hình dạng khi xoay, nên không có cách nào để nó “đá” được. Từ đó có một meme trong cộng đồng Tetris: Đã có một người làm một fake video hướng dẫn làm O-Spin trong Tetris 99 và Tetris Friends, sau đó thì được viral\n\nTrong khi đó:\n\tXRS cho phép gạch O có thể “teleport” tới một cái hố.\n\tTRS cho phép gạch O “teleport” hoặc “biến hình” (theo nghĩa đen) thành một gạch có hình dạng khác",
    },
    {"Hệ thống xoay gạch",
        "wallkick rotationsystem",
        "term",
        [[
Một hệ thống để xác định cách gạch xoay.

Trong các trò Tetris hiện đại, mỗi gạch có thể xoay dựa trên một tâm xoay cố định (có thể không hiện diện trong vài trò chơi). Nếu gạch sau khi xoay đè lên gạch khác hoặc ra ngoài khỏi bảng, hệ thống sẽ thử di chuyển gạch ở các vị trí xung quanh vị trí đang đứng (một quá trình được gọi “wall-kicking” ('đá' tường)).
'Đá' tường cho phép gạch có thể đến những hố có hình dạng nào đó mà bình thường không thể tiếp cận được. Các vị trí mà gạch có thể 'đá' được chứa trong một bảng gọi là “wall-kick table” (bảng các vị trí 'đá' tường)

P/s: trong Zictionary (TetroDictionary), từ “bảng các vị trí 'đá' tường” viết tắt là “bảng 'đá' tường” (do lười gõ, mà cái này có thể thay đổi sau)
        ]]
    },
    {"Hướng gạch",
        "direction 0r2l 02 20 rl lr",
        "term",
        [[
Trong hệ thống xoay SRS và các biến thể của SRS, có một hệ thống các ký hiệu tiêu chuẩn mô tả hướng của các gạch:
    0: Hướng mặc định của hệ thống xoay
    R: Xoay phải, góc 90° theo chiều kim đồng hồ
    L: Xoay trái, góc 90° theo ngược chiều kim đồng hồ
    2: Xoay 2 lần, góc 180° theo bất kì chiều nào.

Ví dụ:
    0→L nghĩa là xoay gạch ngược chiều kim đồng hồ, từ hướng ban đầu (0) sang hướng bên trái (L)
    0→R nghĩa là xoay gạch theo chiều kim đồng hồ, từ hướng ban đầu (0) sang hướng bên phải (R)
    2→R nghĩa là xoay gạch ngược chiều kim đồng hồ, từ hướng 180° (2) sang hướng bên phải (R).
        ]],
    },
    {"ARS",
        "arikrotationsystem atarirotationsystem",
        "term",
        "Có thể chỉ 1 trong 2 hệ thống sau:\nArika Rotation System (Hệ thống xoay Arika): hệ thống xoay được dùng trong series game Tetris: The Grand Master.\nAtari Rotation System (Hệ thống xoay Atari), hệ thống xoay luôn căn chỉnh các gạch ở trên cùng bên trái khi xoay.",
    },
    {"ASC",
        "ascension",
        "term",
        "Hệ thống xoay được dùng trong Ascension - một bản sao (chính xác là clone) của Tetris. Tất cả các gạch đều sử dụng chung một bảng 'đá' tường (một dành cho xoay phải, một dành cho xoay trái), và vùng 'đá' nằm trong khoảng cách ± 2 ô ở cả hai trục.",
    },
    {"ASC+",
        "ascension ascplus",
        "term",
        "Một phiên bản chỉnh sửa của ASC trong Techmino, hỗ trợ 'đá' tường cho trường hợp xoay 180°.",
    },
    {"BRS",
        "bulletproofsoftware",
        "term",
        "BPS rotation system | Hệ thống xoay BPS, được dùng trong các game Tetris được viết bởi Bullet-Proof Software.",
    },
    {"BiRS",
        "biasrs biasrotationsystem",
        "term",
        [[
*Chỉ có trên Techmino*

Bias Rotation System | Hệ thống xoay Bias. Hệ thống xoay 'độc quyền' của Techmino, dựa trên SRS và XRS
Hệ thống sẽ điều chỉnh độ lệch khi xoay tùy vào bạn giữ phím trái/phải/rơi nhẹ khi nhấn phím xoay

Quá trình thử của hệ thống này diễn ra như sau:
    1. Thử dịch chuyển gạch sang trái/phải/xuống tùy thuộc vào phím đang giữ (là phím Sang trái/Sang phải/Thả nhẹ); có thêm độ lệch xuống dưới
    2. Nếu thất bại, cũng thử di chuyển sang bên trái/bên phải/đi xuống tùy thuộc vào phím đang giữ; nhưng lúc này không thêm độ lệch xuống dưới
    3. Nếu thất bại... thì việc xoay thất bại luôn (cái này thì không còn gì để nói)

Khi so sánh với XRS, BiRS dễ nhớ hơn nhiều vì nó chỉ dùng một bảng 'đá' tường; nhưng vẫn giữ nguyên được tính năng vượt địa hình của SRS.

Khoảng cách euclide của độ lệch của cú đá được chọn không được lớn hơn √5; và nếu có độ lệch theo chiều ngang, thì hướng của cú đá đó không được là hướng ngược lại với hướng đã chọn (từ việc giữ phím)
        ]],
    },
    {"C2RS",
        "c2rs cultris2",
        "term",
        "Cultris II rotation system | Hệ thống xoay Cultris II, một hệ thống xoay được dùng trong Cultris II - một bản sao (clone) của Tetris.\nToàn bộ gạch và cả hướng xoay đều sử dụng chung một bảng 'đá' tường (trái, phải, xuống, xuống + trái, xuống + phải, trái 2, phải 2), với ưu tiên về phía bên trái so với bên phải.\n\nTrong Techmino có một bản chỉnh sửa của hệ thống này, đó là C2sym. C2sym sẽ ưu tiên hướng theo hình dạng của gạch",
    },
    {"C2sym",
        "cultris2",
        "term",
        "Một bản mod của C2RS. Hệ thống sẽ ưu tiên hướng Trái/Phải tùy vào hình dạng của các viên gạch khác nhau.",
    },
    {"DRS",
        "dtetrotationsystem",
        "term",
        "DTET Rotation System | Hệ thống xoay DTET\nHệ thống xoay được dùng trong trò DTET.",
    },
    {"NRS",
        "nintendorotationsystem",
        "term",
        "Nintendo Rotation System | Hệ thống xoay Nintendo\nHệ thống được sử dụng trong hai game Tetris, một dành cho máy NES, một dành cho máy Game Boy.\nHệ thống xoay này cũng có hai phiên bản ngược chiều nhau: trên Game Boy thì gạch sẽ căn về bên trái; trên NES thì gạch sẽ căn về bên phải.",
    },
    {"SRS",
        "superrotationsystem",
        "term",
        "Super Rotation System | Hệ thống xoay Siêu cấp [*], là hệ thống xoay được sử dụng rất nhiều trong các game xếp gạch và có rất nhiều hệ thống xoay do fan làm ra cũng dựa vào hệ thống này. Có 4 hướng cho Tetromino và có thể xoay phải và xoay trái (nhưng không thể xoay 180°). Nếu Tetromino đụng tường, đụng đáy, hay đè lên gạch khác sau khi xoay; hệ thống sẽ kiểm tra các vị trí xung quanh. Bạn có thể xem .\n\n[*] [Sea]: ban đầu tính dịch thành “Hệ thống xoay Super”, nhưng thôi mình chọn cụm từ này để dịch cho sát nghĩa.",
    },
    {"SRS+",
        "srsplus superrotationsystemplus",
        "term",
        "Một biến thể của SRS, hỗ trợ bảng 'đá' tường khi xoay 180°.",
    },
    {"TRS",
        "techminorotationsystem",
        "term",
        "*Chỉ có trên Techmino*\n\nTechmino Rotation System | Hệ thống xoay Techmino\nHệ thống xoay được dùng trong Techmino, dựa trên SRS.\nHệ thống này sửa những trường hợp gạch S/Z bị kẹt và không thể xoay trong một vài trường hợp; cũng như bổ sung thêm những vị trí 'đá' hữu dụng. Pentomino cũng có bảng 'đá' tường dựa trên logic của SRS. TRS cũng hỗ trợ O-Spin (O-Spin cho phép gạch có thể 'đá' và có thể 'biến hình').",
    },
    {"XRS",
        "xrs",
        "term",
        "X rotation system | Hệ thống xoay X, một hệ thống xoay được dùng trong T-ex.\n\nHệ thống giới thiệu một tính năng với tác dụng “dùng một bảng 'đá' tường khác khi giữ một phím mũi tên,” cho phép người chơi có thể nói game hướng mà gạch nên di chuyển theo ý muốn của họ.",
    },
    {"Back to Back",
        "b2b btb backtoback",
        "term",
        "Hay còn gọi là B2B. Xóa 2 hoặc nhiều lần xóa theo kiểu 'kỹ thuật' (như Tetris hay Spin) liên tiếp (nhưng không xóa theo kiểu 'thông thường'; gửi thêm hàng rác khi tấn công\nKhông như combo, Back To Back sẽ không bị mất khi đặt gạch.",
    },
    {"B2B2B",
        "b3b",
        "term",
        "*Chỉ có trên Techmino*\n\nBack to back to back, hay còn gọi là B3B (hoặc B2B2B). Thực hiện nhiều Back to Back liên tiếp để lấp đầy thanh B3B; cuối cùng khi bạn đã lấp B3B vượt một mức nhất định, bạn có thể tấn công mạnh hơn khi làm được B2B, nhờ sức mạnh từ B3B",
    },
    {"Fin, Neo, Iso",
        "fin neo iso",
        "term",
        "Các kỹ thuật T-spin đặc biệt khai thác việc gạch T 'đá' và hệ thống phát hiện T-spin. Chúng có sức mạnh tấn công khác nhau trong các game khác nhau (một số game sẽ coi chúng là Mini T-spin), nhưng hầu như cũng không có giá trị gì trong thực sự trong chiến đấu do cách setup tương đối phức tạp của chúng.",
    },
    {"Modern Tetris",
        "modern",
        "term",
        [[
Khái niệm về trò chơi Tetris hay trò chơi xếp gạch “hiện đại” rất mờ nhạt. Nói chung, một trò chơi xếp gạch hiện đại thường sẽ bám sát theo Tetris Design Guideline (Nguyên tắc thiết kế Tetris hiện đại).
Dưới đây là một số quy tắc chung, nhưng chúng không phải là quy tắc bắt buộc
    1. Phần có thể nhìn được của bảng có kích thước 10 × 20 (rộng × dài), cùng với 2 - 3 hàng ẩn ở bên nhau.
    2. Gạch sẽ được sinh ra ở giữa trên cùng của ma trận có thể nhìn thấy (thường là ở hàng 21-22). Mỗi mảnh đều có màu sắc và hướng quay mặc định riêng.
    3. Có một bộ xáo gạch như 7-bag hay His.
    4. Có hẳn một hệ thống xoay, và cho phép xoay theo ít nhất 2 hướng.
    5. Có một hệ thống trì hoãn khóa gạch thích hợp.
    6. Có điều kiện kiểm tra gạch có đè lên gạch khác hay không.
    7. Có hiện NEXT, với nhiều gạch sắp rơi xuất hiện trong đó (thường là từ 3-6), những gạch này được hiện với hướng mà chúng sẽ đứng khi chúng được sinh ra.
    8. Cho phép giữ gạch (Hold).
    9. Nếu có spawn delay hoặc clear delay, thì game thường sẽ có hệ thống IRS và IHS.
    10. Có hệ thống DAS cho các chuyển động ngang chính xác và nhanh chóng.
        ]],
    },
    {"H.dạng của Tetro.",
        "shape structure form tetromino tetrimino hình dạng",
        "term",
        "Trong những game xếp gạch chuẩn, tất cả toàn bộ gạch đều là Tetromino. Tức là, những gạch này được liên kết bởi 4 ô, bám dính vào mặt chứ không bám vào góc.\n\nCó 7 loại Tetromino, (nếu ta cho phép xoay nhưng không được lật ngang hay dọc). 7 Tetromino này được đặt tên theo hình dạng của chúng. Đó là Z, S, J, L, T, O, và I. Hãy xem mục “Gạch & tên tg. ứng” để có thêm thông tin.",
    },
    {"Màu của Tetromino",
        "colour hue tint tetromino tetrimino màu",
        "term",
        "Nhiều game xếp gạch hiện đại đang sử dụng cùng một bảng màu cho Tetromino, dù chính thức hay do fan làm. Những màu này bao gồm:\nZ - Đỏ, S - Lục, J - Lam, L - Cam, T - Tím, O - Vàng, và I - Lục lam.\n\nTechmino cũng sử dụng bảng màu “chuẩn” này để tô màu cho Tetromino.",
    },
    {"IRS",
        "initialrotationsystem",
        "term",
        "Initial Rotation System\nGiữ phím xoay trong khoảng thời gian spawn delay để gạch xoay sẵn lúc xuất hiện. Đôi khi có thể giúp bạn thoát chết.",
    },
    {"IHS",
        "initialholdsystem",
        "term",
        "Initial Hold System\nGiữ phím Hold trong khoảng thời gian spawn delay để lấy gạch từ HOLD (hoặc gạch tiếp theo trong NEXT nếu chưa có gạch nào trong HOLD) thay vì sử dụng gạch hiện tại, và đặt gạch hiện tại vào trong HOLD. Đôi khi có thể giúp bạn thoát chết.",
    },
    {"IMS",
        "initialmovesystem",
        "term",
        "*Chỉ có trên Techmino*\n\nInitial Movement System\nGiữ một phím di chuyển trong khoảng thời gian spawn delay để gạch sinh ra ở một bên. Đôi khi có thể giúp bạn thoát chết.\nLưu ý: DAS buộc phải được “sạc” đủ trước khi gạch xuất hiện.",
    },
    {"Next (Kế/Tiếp)",
        "nextpreview",
        "term",
        "Hiện một vài gạch tiếp theo sẽ xuất hiện. Có một kỹ năng cần thiết để lên kế hoạch trước nơi đặt các gạch từ hàng đợi NEXT.",
    },
    {"Hold (Giữ)",
        "hold",
        "term",
        "Lưu gạch hiện tại của bạn để sử dụng sau này, và lấy gạch đã giữ trước đó (hoặc gạch tiếp theo trong hàng Next, nếu như chưa giữ gạch nào trước đó) để dùng. Bạn chỉ có thể giữ gạch 1 lần.\n\n*Chỉ có trên Techmino*: Techmino có một tính năng gọi là “In-place Hold” (“Giữ ngay tại chỗ”). Khi được bật thì gạch được lấy ra từ Hold sẽ xuất hiện ngay tại vị trí gạch trước đó đang rơi, thay vì xuất hiện ngay ở trên cùng bảng",
    },
    {"Swap",
        "hold",
        "term",
        "Tương tự như *Hold*, nhưng sẽ lấy gạch tiếp theo từ Next; gạch đang rơi hiện tại sẽ đứng cuối hàng. Bạn chỉ có thể đổi gạch một lần trong đa số trương hợp.",
    },
    {"Deepdrop (Rơi sâu)",
        "shenjiang",
        "term",
        "*Chỉ có trên Techmino*\n\nMột chức năng cho phép cho phép gạch có thể teleport xuyên đất để xuống phía dưới. Khi gạch đụng vào đáy hoặc một gạch khác, nhấn phím Thả nhẹ để kích hoạt Deepdrop. Nếu có một cái hố phù hợp với hình dạng của gạch ở dưới vị trí gạch đang rơi, gạch sẽ được teleport vào hố đó.\nCơ chế này đặc biệt hữu ích cho AI vì nó cho phép AI bỏ qua sự khác biệt giữa các hệ thống xoay khác nhau.",
    },
    {"Misdrop",
        "md misdrop",
        "term",
        "Vô tình thả rơi/đặt gạch vào nơi không mong muốn.",
    },
    {"Mishold",
        "mh mishold",
        "term",
        "Vô tình nhấn nhầm phím Hold. Việc này có thể dẫn đến việc dùng một viên gạch không mong muốn, và có thể bỏ lỡ cơ hội có thể làm PC.",
    },
    {"sub",
        "sub",
        "term",
        "Sub-[số] có nghĩa là khoảng thời gian ở dưới một mốc nhất định. Đơn vị thời gian thường được bỏ qua và có thể tự suy ra. Ví dụ: “sub-30” có nghĩa là hoàn thành chế độ 40 hàng dưới 30 giây, “sub-15” có nghĩa là hoàn thành chế độ 1000 hàng dưới 15 phút.",
    },
    {"Digging (Đào xuống)",
        "downstacking ds",
        "term",
        "Dọn hàng rác để tiếp xúc đáy bảng. Hay còn gọi là downstacking.",
    },
    {"Donation",
        "donate",
        "term",
        "Một phương pháp “nhét” vào hố có thể làm Tetris để làm T-spin. Sau khi làm T-spin, hố đó được mở ra để làm Tetris hoặc đào xuống.\n-- Harddrop wiki",
    },
    {"‘Debt’",
        "qianzhai debt owe",
        "term",
        "Một thuật ngữ hay được sử dụng trong cộng đồng Tetris Trung Quốc. “Debt” đề cập đến tình huống mà trước mắt một người chơi phải hoàn thành việc thực hiện một setup cụ thể trước khi học có thể thực hiện một/nhiều T-spin để có thể thực sự tấn công. Cho nên, khi đang làm một hoặc nhiều debt liên tiếp, người chơi buộc phải để ý tới đối thủ để đảm bảo an toàn; nếu không, khả năng người chơi sẽ bị đá bay trước khi xây dựng xong là khá cao\n\nThuật ngữ này hay được sử dụng để diễn tả một số setup như TST tower.\nHãy nhớ bạn thực sự KHÔNG THỂ thực hiện tấn công nếu như đang làm debt.",
    },
    {"Tấn công & Phg thủ",
        "attacking defending phòng thủ",
        "term",
        [[
Tấn công: Gửi hàng rác tới đối thủ bằng cách xóa hàng.
Phòng thủ: Loại hàng rác ra khỏi hàng chờ bằng cách xóa hàng sau khi đối thủ gửi hàng rác.
Phản công: Gửi hàng rác lại sau khi nhận đòn tấn công, hoặc trong khi/sau khi tấn công.

Trong hầu hết các trò chơi, tỷ lệ phản công rác thường là 1:1, một lần tấn công đánh phản lại một lần nhận rác.
        ]],
    },
    {"Combo",
        "ren combo",
        "term",
        "Ở Nhật Bản, từ này được gọi là REN.\nXóa hàng liên tiếp để tạo ra combo. Từ lần xóa hàng thứ 2 thì tính là 1 Combo, và từ lần xóa hàng thứ 3 thì tính là 2 Combo, và cứ như thế.\nKhông như Back to Back, đặt một viên gạch = phá combo.",
    },
    {"Spike",
        "spike",
        "term",
        "Làm nhiều đợt tấn công trong thời gian ngắn.\n\nKể cả Techmino và TETR.IO đều có bộ đếm spike, sẽ hiện cho bạn bao nhiêu hàng bạn đã gửi cho đối thủ.\n\nLưu ý rằng hàng rác mà bị tích lũy do mạng lag thì không được tính là spike.",
    },
    {"Side well",
        "ren combo sidewell",
        "term",
        "Một phương pháp xếp gạch mà bạn sẽ để lại một cái hố có một chiều rộng nhất định ở một bên bảng .\nSetup Side 1-wide là setup truyền thống để làm Tetris (ví dụ như, Side well Tetris).\nCác loại setup như Side 2-, 3-, hay 4-wide; là những setup được dùng để làm combo. Đối với những người chơi mới, đây là cách hiệu quả nhất để tấn công. Nhưng, đối thủ có thể dễ dàng tấn công lại bạn, một là chết còn không thì stack của bạn sẽ bị cắt ngắn do bạn phải phản công lại. Chính vì lẽ đó, những người chơi nâng cao thường sẽ không xây giếng sâu thăm thẳm, thay vào đó họ sẽ giữ một lượng T-spins và Tetris nhất định để có thể tấn công đối thủ khi đối thủ không có khả năng dọn rác tới.",
    },
    {"Center well",
        "ren combo centerwell",
        "term",
        "Một phương pháp xếp gạch mà bạn sẽ để lại một cái giếng có chiều rộng nhất định ở giữa bảng.",
    },
    {"Partial well",
        "ren combo partialwell",
        "term",
        "Một phương pháp xếp gạch mà bạn sẽ để lại một cái giếng có chiều rộng nhất định nhưng không ở giữa hay một bên bảng.",
    },
    {"Side 1-wide",
        "s1w side1wide sidewelltetris",
        "term",
        "Hay còn gọi là Side well Tetris.\nĐây là cách chơi xếp gạch kinh điển nhất, và để làm được thì bạn sẽ phải xây một cái hố (duy nhất) sâu rộng 1 ô ở một mặt bên của bảng. Dễ thực hiện trong Tetris hiện đại và có thể làm tấn công... nửa vời [*]. Nhưng setup này hiếm khi được sử dụng trong những trận đấu hạng cao do hiệu quả của Tetris thấp hơn so với T-spin.\n\n[*] [Sea]: cái này mình không có viết vào, Zictionary nó viết như vậy á.",
    },
    {"Side 2-wide",
        "s2w side2wide",
        "term",
        "Tương tự như Side 1-wide nhưng hố rộng 2 ô. Một setup để làm combo phổ biến.\nDễ sử dụng. Những người mới chơi có thể thử và tạo ra một số kết hợp nửa vời khi kết hợp với Hold. Nhưng setup này hiếm khi được sử dụng trong những trận đấu hạng cao, bởi vì tốn thời gian để xây, nhường thời gian cho đối thủ tấn công và có thể làm stack của bạn bị cắt ngắn. Và nó cũng không tốt lắm về mặt hiệu quả (efficiency).",
    },
    {"Side 3-wide",
        "s3w side2wide",
        "term",
        "Tương tự như Side 1-wide hay Side 2-wide nhưng hố rộng 3 ô. Ít phổ biến hơn so với Side 2-wide.\nTuy có thể làm nhiều combo hơn với setup này, nhưng lại khó xây, và dễ làm hỏng combo.",
    },
    {"Side 4-wide",
        "s4w side4wide",
        "term",
        "Tương tự như Side 1-, 2- hay 3-wide nhưng hố rộng 4 ô.\nNếu làm tốt thì nó có thể tạo ra những combo rất ấn tượng. Hơn nữa, setup này mất ít thời gian hơn để xây dựng, vì vậy có thể tranh thủ làm combo trước khi rác đến. Tuy nhiên, bạn vẫn có thể bị đá bay nếu có quá nhiều rác, do đó nó khó áp đảo lại rác đến.", -- TODO: Need to find the proper word for "overpower" (SEA)
    },
    {"Center 1-wide",
        "c1w center1wide centerwelltetris",
        "term",
        "Hay còn gọi là Center well Tetris.\nMột phương pháp xếp gạch mà bạn sẽ để lại một cái hô sâu rộng 1 ô ở giữa bảng. Chủ yếu dùng trong combat bởi vì cho phép làm Tetris và T-spin trong khi nó không quá khó để làm.",
    },
    {"Center 2-wide",
        "c2w center2wide",
        "term",
        "Tương tự như Center 1-wide, nhưng hố rộng 2 ô. Tuy nhiên nó không được phổ biến lắm.",
    },
    {"Center 3-wide",
        "c3w center3wide",
        "term",
        "Tương tự như Center 1- hay 2-wide, nhưng hố rộng 3 ô. Tuy nhiên nó cũng không được phổ biến lắm.",
    },
    {"Center 4-wide",
        "c4w center4wide",
        "term",
        "Tượng tự như Center 1-, 2-, hay 3-wide.\nĐây là một setup combo không được phổ biến lắm, nhưng cho phép bạn gửi nhiều combo trong khi đánh bật luôn cả điều kiện game over nếu bạn nhận một vài hàng rác. Nhiều người chơi thường ghét kỹ thuật này, bởi vì chúng làm mất cân bằng trong game.",
    },
    {"Residual",
        "c4w s4w",
        "term",
        "Đề cập đến có bao nhiêu gạch được đặt trong cái hố khi sử dụng setup combo 4-wide. Phổ biến nhất laf 3-residual và 6-residual.\n3-residual có ít biến thể và dễ học dễ nhớ hơn, và có khả năng thành công cao, cũng như rất hữu dựng trong combat.\n6-residual thì lại có nhiều biến thể hơn và khó học khó xài hơn, nhưng chúng thường sẽ ổn định nếu bạn làm tốt. Residual cũng có thể được sử dụng trong những thử thách đặc biệt như lấy 100 combo trong một thử thánh 4-wide vô tận.\nVề nguyên tắc, hãy dùng 6-Res trước, sau đó 5-Res rồi 3-Res, và cuối cùng là 4-Res.",
    },
    {"6 - 3 Stacking",
        "63stacking six-three sixthree",
        "term",
        "Một phương pháp để xếp gạch, bạn sẽ phải tạo ra một bức tường cao có chiều rộng rộng 6 ô ở bên trái và một bức tường cao nữa có chiều rộng 3 ô ở bên phải.\nĐối với một người chơi có kỹ năng, phương pháp cho phép người chơi giảm số phím cần nhấn, và đây là một phương pháp phổ biến để chơi Sprint (như 10 hàng, 20 hàng, 40 hàng,…). Phương pháp này hoạt động được nhờ việc gạch xuất hiện hay bị căn lệch về bên trái.",
    },
    {"Freestyle",
        "ziyou",
        "term",
        "Thuật ngữ hay được sử dụng trong thử thách 20TSD. Freestyle nghĩa là hoàn thành thử thách 20TSD mà không sử dụng phương pháp xếp gạch cố định nào. Làm 20TSD với Freestyle khó hơn nhiều so với việc sử dụng phương pháp nào đó như LST, và màn chạy có thể đại diễn cho các kỹ năng T-spin có được trong các trận đấu.",
    },
    {"Topping out",
        "die death topout toppingout",
        "term",
        [[
Một tựa game xếp gạch hiện đại thường có 3 điều kiện để “game over”:
    1. Block out: Gạch mới được sinh ra chồng chéo với một gạch đã đặt;
    2. Lock out: Có gạch nằm trên vùng skyline (đường chân trời);
    3. Top out: Độ cao của bảng vượt quá độ cao cho phép (thường là do có một cột cao quá 40 ô).
Techmino không kiểm tra điều kiện Lock out và Top out.
        ]],
    },
    {"Vùng đệm",
        "above super invisible disappear buffer zone",
        "term",
        "Tên tiếng Anh là “Buffer Zone”. Thường dùng để nhắc tới những hàng có độ cao từ ô thứ 21-40, vùng này là vùng ở trên vùng nhìn thấy của bảng. Bởi vì gạch có thể cao hơn vùng nhìn thấy (thường xảy ra nếu có quá nhiều rác tới cùng một lúc) cho nên vùng đệm được tạo ra để cho phép những gạch ở trên cao có thể quay lại (sau) khi người chơi xóa hàng rác. Ngoài ra, vùng đệm thường nằm ở độ cao từ 21-40 vì chúng có thể áp dụng cho hầu hết các trường hợp. Tuy nhiên vẫn có những trường hợp ngoại lệ, hãy tham khảo “Vanish Zone” để biết thêm thông tin chi tiết",
    },
    {"Vùng biến mất",
        "disappear gone cut die vanish zone",
        "term",
        "Tên tiếng Anh là “Vanish Zone”. Thường dùng để nhắc tới những hàng có độ cao từ 40 ô và cao hơn. Cái này chỉ có thể phát hiện ra bằng cách sử dụng C4W và đống hàng rác. Thông thường, nếu cột cao nhất trong bảng đụng vào vùng biến mất.\nTuy nhiên, có một số game có những phản ứng khác nhau. Một số game sẽ bị lỗi và sập khi có gạch đi vào vùng biến mất (ví dụ như Tetris Online). Riêng ở một số game thì game sẽ có hành động lạ (bạn có thể tham khảo video này, hãy nhấn vào biểu tượng quả địa cầu để mở video).\n\nThông tin thêm: Jstris không có vùng đệm, chỉ có vùng biến mất được đặt từ hàng thứ 22.",
        "https://youtu.be/z4WtWISkrdU",
    },
    {"Tốc độ rơi",
        "fallingspeed gravity",
        "term",
        [[
Đơn vị của tốc độ rơi là “G”, có nghĩa là gạch rơi xuống bao nhiêu ô mỗi một khung hình.
“G” là đơn vị thường có số khá lớn. Tốc độ của Level 1 trong chế độ Marathon thường là 1/60G (1 ô/giây), và ở Level 13 thường là 1G.
Tốc độ cao nhất trong các game Tetris hiện đại là 20G. Ý nghĩa thật sự của 20G là “Tốc độ rơi vô cực” (“Infinite falling speed”), và kể cả có chỉnh bảng cao hơn 20 hàng, chế độ 20G sẽ ép gạch phải xuất hiện ở dưới đáy bảng. Bạn có thể tìm hiểu về 20G ở mục “20G”
Trong Techmino, tốc độ rơi được mô tả là số khung hình cần thiết để gạch rơi xuống một đơn vị; ví dụ, 60 để chỉ gạch rơi mỗi ô một giây (mà game mặc định chạy ở 60FPS).
        ]],
    },
    {"20G",
        "gravity instant",
        "term",
        "Tốc độ nhanh nhất trong các game xếp gạch hiện đại. Trong các chế độ xài tốc độ 20G, các viên gạch thay vì rơi từ từ, nó sẽ xuất hiện ngay lập tức ở đáy bảng. Việc này đôi khi sẽ làm bạn không thể di chuyển được theo phương ngang như ý bạn muốn; vì gạch không thể leo qua chỗ lồi lõm hoặc ra khỏi hố sâu.\nBạn có thể tìm hiểu thêm về đơn vị “G” trong mục “Tốc độ rơi”.",
    },
    {"Lockdown Delay",
        "lockdelay lockdowndelay lockdowntimer",
        "term",
        "Thời gian chờ khóa gạch\n\nĐây là khoảng thời gian sau khi gạch chạm đất và trước khi gạch bị khóa (lockdown) (giống như kiểu: bạn không thể điều khiển gạch đó nữa vì nó đã dính cố định tại chỗ rồi; và bạn sẽ điều khiển gạch vừa mới xuất hiện).\nCác game Tetris hiện đại thường có cơ chế trì hoãn việc khóa gạch, trong đó bạn có thể di chuyển hoặc xoay gạch để đặt lại thời gian chờ (tối đa 15 lần trong đa số game); bạn có thể sử dụng để thêm (một chút) thời gian chờ. Tetris cổ điển hầu như không có thời gian này (thật ra là có nhưng nó ngắn tới nỗi mà bạn gần như chỉ có thể đưa gạch sang 1 ô 1 hướng duy nhất khi cần lấp mấy ô trống)",
    },
    {"ARE",
        "spawn appearance delay",
        "term",
        "Tên đầy đủ là Apperance Delay, đôi khi được gọi là Entry Delay (Thời gian trì hoãn sự xuất hiện của gạch mới). ARE chỉ khoảng thời gian sau khi gạch bị khóa và trước khi gạch mới sinh ra.",
    },
    {"Line ARE",
        "appearance delay",
        "term",
        "Khoảng thời gian khi hiệu ứng xóa hàng bắt đầu chạy cho tới khi gạch mới sinh ra.",
    },
    {"Death ARE",
        "die delay dd",
        "term",
        "Khi có một viên gạch chặn ngay tại vị trí xuất hiện của gạch mới, spawn ARE sẽ được cộng với một khoảng thời gian nữa để tạo thành Death ARE. Cơ chế này có thể được sử dụng cùng với IHS và IRS để cho phép bạn có thể thoát chết.\nÝ tưởng ban đầu của NOT_A_ROBOT.",
    },
    {"Finesse",
        "finesse lỗi di chuyển",
        "term",
        [[
Một kỹ thuật di chuyển gạch vào vị trí mong muốn với số lần nhấn phím ít nhất. Giúp tiết kiệm thời gian và giảm khả năng misdrop.
Bạn có thể luyện tập bằng cách dùng tính năng “Chơi lại nếu mắc lỗi di chuyển” hoặc là để ý tới hiệu ứng âm thanh báo lỗi di chuyển của Techmino.

Techmino phát hiện lỗi di chuyển không dựa trên “số lần nhấn phím tối thiểu để di chuyển theo lý thuyết”, mà thay vào đó chỉ kiểm tra lỗi di chuyển dựa trên số lần nhấn phím tương đương đã được quy định trước *khi gạch được đặt tại một vị trí mà không cần dùng Thả nhẹ*. Có nghĩa là Techmino sẽ không tính lỗi di chuyển nếu bạn phải “nhét” gạch đó để lấp hố hoặc thực hiện spin
Techmino có kiểm tra bổ sung một số điều kiện nữa, như nếu bạn giữ gạch mà cả gạch hiện tại giống với gạch đang giữ, hoặc là giữ gạch khi bạn đã di chuyển gạch hiện tại, cũng đều tính là lỗi di chuyển.
Finesse% trong Techmino được tính như sau: 100% nếu số phím bằng hoặc ít hơn par, 50% nếu quá par 1 phím, 25% nếu quá par 2 phím, và 0% nếu quá par 3 phím hoặc hơn.
Lưu ý thêm nữa: trong 20G nếu vẫn kiểm tra lỗi di chuyển, kết quả có thể không chính xác.

Thông tin thêm: Par là một thuật ngữ được dùng chủ yếu trong trò đánh golf, thường được sử dụng để chỉ số lượt gậy dự kiến cần để có thể đưa bóng vào hố (hole) hoặc một vòng đánh golf (round of golf). Hãy tra Google để biết thêm thông tin.
        ]],
    },
    {"‘Doing Research’",
        "scientificresearch",
        "term",
        "“Doing scientific research” (“Nghiên cứu khoa học”) là một thuật ngữ đôi khi được dùng ở cộng đồng Tetris Trung Quốc (không dùng ở cộng đồng Tetris Việt Nam), chỉ việc nghiên cứu/luyện tập kỹ thuật nào đó trong môi trường chơi đơn và tốc độ rơi thấp..",
    },
    {"Bố cục phím",
        "feel",
        "term",
        [[
Dưới đây là vài lời khuyên hữu ích khi bạn đang chỉnh sửa bố cục phím

1.  Một ngón tay chỉ nên thực hiện một chức năng khác nhau. Ví dụ như: 1 ngón cho sang trái, 1 ngón cho sang phải, 1 ngón cho phím xoay phải, 1 ngón cho rơi mạnh

2.  Trừ khi bạn tự tin với ngót út của mình, thì không nên để ngón tay này làm bất kì việc hết! Ngoài ra, nên xài ngón trỏ và ngón giữa vì hai ngón này là nhanh nhẹn nhất, nhưng bạn cũng có thể thoải mái tìm hiểu xem các ngón tay của mình nhanh chậm thế nào, mạnh yếu ra sao.

3.  Không nhất thiết phải sao chép bố cục phím của người khác, vì không ai giống ai. Thay vào đó hãy chỉnh theo cách của bạn, miễn là bạn chơi thoải mái là được.
        ]],
    },
    {"Khả năng xử lý gạch",
        "feel handling",
        "term",
        [[
Những yếu tố ảnh hưởng tới việc xử lý gạch của bạn:

(1) Độ trễ đầu vào, có thể là do cấu hình, thông số hoặc tình trạng của thiết bị. Khởi động lại trò chơi, bảo dưỡng, sửa chữa hoặc thay đổi thiết bị của bạn có thể khắc phục vấn đề này.
(2) Trò chơi không ổn định/thiết kế quá sơ sài và nhiều lỗi. Có thể giảm tình trạng này bằng cách chỉnh sửa cài đặt hiệu ứng để ở mức thấp.
(3) Cái gì cũng có mục đích của nó, ngay cả thiết kế cũng vậy. Việc làm quen với chúng có thể giúp bạn.
(4) Cài đặt thông số xử lý gạch không phù hợp (ví dụ: DAS, ARR, SDARR,…). Thay đổi cài đặt.
(5) Tư thế chơi ko hợp lý, có thể gây ra bất tiện trong những lúc quan trọng. Nên tìm tư thế chơi phù hợp sao cho thuận tiện khi chơi.
(6) Thao tác không quen sau khi đổi vị trí phím hay  đổi sang thiết bị mới. Tập làm quen với chúng hoặc thay đổi cài đặt có thể hữu ích.
(7) Mỏi cơ, chuột rút,… làm cho việc phản ứng và phối hợp tay khó khăn hơn. Hãy nghỉ ngơi và trở lại sau một hoặc vài ngày.
        ]],
    },
    {"DAS (simple)",
        "das arr delayedautoshift autorepeatrate",
        "term",
        "Tưởng tượng bạn đang gõ chữ, và bạn nhấn giữ phím “O”. \nVà bạn sẽ nhận được một chuỗi toàn là o.\nỞ trên thanh thời gian thì nó trông như thế này: o—————o-o-o-o-o-o-o-o-o…\n“—————” là DAS, còn “-” là ARR.",
    },
    {"DAS & ARR",
        "das arr delayedautoshift autorepeatrate",
        "term",
        "DAS viết tắt của từ Delayed Auto Shift, chỉ cách viên gạch di chuyển khi bạn giữ phím di chuyển sang trái hoặc phải. Thuật ngữ này còn ám chỉ khoảng thời gian từ lúc bạn nhấn phím cho tới khi gạch có thể tự động di chuyển liên tục. DAS chỉ được tính một lần và sẽ bị đặt lại khi bạn nhả phím\n\nARR viết tắt của từ Auto-Repeat Rate, nó là khoảng thời gian nghỉ sau khi gạch di chuyển được 1 ô trong quá trình di chuyển liên tục (sau khi đã qua DAS).\n\nTrong một vài game, DAS và ARR được tính bằng f (frame, khung hình). Nhân f với 16.7 (nếu bạn đang chạy game ở 60 FPS) để đổi sang ms (mili giây).",
    },
    {"Hiệu chỉnh DAS",
        "das tuning",
        "term",
        "Với những người chơi nâng cao mà muốn chơi nhanh hơn, có thể điều chỉnh DAS thành 4-6 f (67-100 ms) và ARR 0 f (0 ms); đây là hai giá trị khuyên dùng. (Ở ARR 0ms, các viên gạch sẽ ngay lập tức dính vào tường khi bạn vượt qua DAS.)\n\nĐây là cấu hình lý tưởng cho người nâng cao, với chiến lược là cắt giảm DAS trong khi vẫn có thể kiểm soát được gạch một cách tin cậy mặc dù ARR bằng 0 nếu có thể hoặc càng thấp càng tốt.",
    },
    {"DAS cut",
        "dascut dcd",
        "term",
        "*Chỉ có trên Techmino*\n\nTrong Techmino, bạn có thể hủy hoặc rút một khoảng thời gian từ bộ đếm ngược của DAS. Có thể giảm được tình trạng gạch di chuyển ngay lập tức khi vừa mới xuất hiện nếu có phím di chuyển nào đang được giữ.\n\nNhững game khác có thể có tính năng này nhưng cách hoạt động có thể đôi chút khác biệt.",
    },
    {"Auto-lock cut",
        "autolockcut mdcut",
        "term",
        "Một tính năng được thiết kế để ngăn chặn việc mis-harddrop (thả gạch rơi mạnh không đúng thời điểm) do việc nhấn phím “Thả mạnh” ngay sau khi gạch cuối cùng bị khóa một cách tự nhiên\nPhím “Thả mạnh” sẽ tạm thời bị vô hiệu trong vòng vài khung hình (tùy vào từng game/cài đặt của người chơi) ngay sau khi có gạch bị khóa một cách tự nhiên.\n\nNhững game khác có thể có tính năng này nhưng cách hoạt động có thể đôi chút khác biệt.",
    },
    {"SDF",
        "softdropfactor",
        "term",
        "Soft Drop Factor (Hệ số tốc độ rơi nhẹ)\n\nMột cách để xác định tốc độ gạch rơi khi nhấn phím “Thả nhẹ”. Ở những game chính thức: SDF = tốc độ rơi × 20 → SDF của những game này là 20. Techmino không dùng SDF để xác định tốc độ rơi nhẹ, mà dùng SDARR (giống như ARR nhưng thông số này không giống với ARR và chỉ được dùng cho phím “Thả nhẹ”).",
    },
    {"Gạch & tên tg. ứng",
        "mino gạch & tên tương ứng",
        "term",
        "Đây là danh sách gạch mà Techmino sử dụng cùng với tên tương ứng của chúng:\nTetromino:\nZ: "..CHAR.mino.Z..",  S: "..CHAR.mino.S..",  J: "..CHAR.mino.J..",  L: "..CHAR.mino.L..",  T: "..CHAR.mino.T..",  O: "..CHAR.mino.O..",  I: "..CHAR.mino.I..";\n\nPentomino:\nZ5: "..CHAR.mino.Z5..",  S5: "..CHAR.mino.S5..",  P: "..CHAR.mino.P..",  Q: "..CHAR.mino.Q..",  F: "..CHAR.mino.F..",  E: "..CHAR.mino.E..",  T5: "..CHAR.mino.T5..",  U: "..CHAR.mino.U..",  V: "..CHAR.mino.V..",  W: "..CHAR.mino.W..",  X: "..CHAR.mino.X..",  J5: "..CHAR.mino.J5..",  L5: "..CHAR.mino.L5..",  R: "..CHAR.mino.R..",  Y: "..CHAR.mino.Y..",  N: "..CHAR.mino.N..",  H: "..CHAR.mino.H..",  I5: "..CHAR.mino.I5..";\n\nTrimino, Domino, and Mino:\nI3: "..CHAR.mino.I3..",  C: "..CHAR.mino.C..",  I2: "..CHAR.mino.I2..",  O1: "..CHAR.mino.O1..".",
    },
    {"Kiểu xáo Túi 7",
        "bag7bag randomgenerator",
        "term",
        [[
Hay còn gọi là “7-Bag Generator”. Tên tiếng Việt là “Kiểu xáo Túi 7 gạch”. Còn tên gọi chính thức của nó là “Random Generator” (Trình xáo gạch ngẫu nhiên)

Đây là thuật toán hay được sử dụng bởi các trò chơi xếp gạch hiện đại. Từ khi bắt đầu game, bạn luôn được đảm bảo rằng bạn sẽ có đủ 7 Tetromino mỗi 7 viên gạch bạn đã thả rơi.
Một vài ví dụ: ZSJLTOI, OTSLZIJ, LTISZOJ.
        ]],
    },
    {"Kiểu xáo His",
        "history hisgenerator",
        "term",
        [[
Kiểu xáo His, tên đầy đủ là History - Roll. (Tên tiếng Việt là Nhớ - Lặp)

Một phương pháp xáo gạch được sử dụng nhiều trong các game Tetris: The Grand Master. Mỗi lần một Tetromino sẽ được chọn ngẫu nhiên: Nếu nó là một trong những gạch đã bốc ra trước đó, thì bốc lại thêm lần nữa cho tới khi bốc được gạch không phải là những viên gạch kia, hoặc là hết lượt bốc lại. Ví dụ: “his 4 roll 6” (h4r6) (nhớ 4 lặp 6) sẽ nhớ 4 gạch đã bốc cuối cùng, và chỉ được bốc lại tối đa 6 lần nếu cần thiết.

Kiểu xáo His cũng có một vài biến thể khác, như “his4 roll6 pool35” (nhớ 4 - bốc 6 - rổ 35), giảm kha khá tính ngẫu nhiên của chuỗi gạch. Xem chi tiết tại mục “Kiểu xáo HisPool”.

Trong Techmino, số lần bốc lại ngẫu nhiên sẽ là một nửa độ dài chuỗi gạch.
        ]],
    },
    {"K.xáo HisPool [1/2]",
        "hisPool history pool",
        "term",
        [[
Kiểu xáo HisPool, tên đầy đủ là History (- Roll) - Pool. (Tên tiếng Việt là Nhớ - Lặp - Rổ)

Một kiểu xáo dựa trên kiểu xáo His. Nó giới thiệu một cơ chế mới: “Pool” (Rổ)[*]. Mỗi lần bốc gạch, HisPool sẽ chọn ngẫu nhiên một viên gạch trong cái Rổ và tăng khả năng xuất hiện của gạch ít xuất hiện nhất. (Bạn có thể tra mục tiếp theo để tìm hiểu về cơ chế Pool nếu bạn tò mò)

Cơ chế này giúp chuỗi gạch ổn định hơn và tránh tình trạng drought xảy ra quá lâu

[*][Sea: thật ra thì từ Pool có nghĩa là cái hồ bơi, hồ nước (ngoài ra còn có nghĩa là tiền đặt cược). Nhưng mình nghĩ nếu dịch thành “Nhớ - Lặp - Hồ” thì không ổn lắm nên mình mới bịa ra “Nhớ - Lặp - Hồ”]
        ]],
    },
    {"K.xáo HisPool [2/2]",
    "hisPool history pool",
    "term",
    [[
[Sea: Phần này không có trong Zictionary ngôn ngữ khác!]
Cách hoạt động của kiểu xáo “Nhớ - Lặp - Rổ” diễn ra tuần tự như sau:

Đầu tiên, lấy một viên gạch ngẫu nhiên trong cái Rổ. Nếu gạch đó là một trong những gạch đã bốc ra trước đó thì bốc lại cho tới khi gạch đó không còn là một trong những viên gạch kia, hoặc là hết lượt bốc lại.
Gạch được bốc trúng sẽ được lấy ra khỏi Rổ. Với các gạch khác, mỗi viên gạch sẽ bị cộng 1 lần vào số lần không xuất hiện của chúng.

Vấn đề là, chiếc Rổ lúc này chỉ còn 34 gạch, nhưng yêu cầu đặt ra là chiếc Rổ phải có 35 gạch. Bây giờ phải kiếm thêm gạch từ đâu ra?

Câu trả lời là: lấy gạch có *số lần không xuất hiện nhiều nhất* (hiểu nôm na là gạch ít xuất hiện nhất) (“The droughtest piece”) để thêm ngược lại Rổ. Và lẽ tất nhiên game có theo dõi các viên gạch đã không xuất hiện bao nhiêu lần để biết gạch nào cần lấy chứ :)

Sau khi gạch đó đã thêm vào Rổ, số lần không xuất hiện của nó sẽ bị đặt lại về 0
Cuối cùng là thêm gạch vào chuỗi NEXT và quay về bước đầu tiên.
        ]],
    },
    {"Kiểu xáo EZ-Start",
        "bages easy start khởi đầu suôn sẻ",
        "term",
        "*Chỉ có trên Techmino*\n\nKiểu xáo Túi “Khởi đầu suôn sẻ” (Bag Easy-Start generator), một kiểu xáo được cải tiến từ kiểu xáo Túi thông thường. Gạch đầu tiên của mỗi túi sẽ không bao giờ là gạch khó đặt (S/Z/O/S5/Z5/F/E/W/X/N/H).",
    },
    {"Kiểu xáo Reverb",
        "reverb",
        "term",
        "*Chỉ có trên Techmino*\n\nMột cách xáo gạch có nguồn gốc từ cách xáo Túi. Kiểu xáo Reverb sẽ lặp ngẫu nhiên một vài gạch từ kiểu xáo Túi thông thường. Khả năng lặp lại gạch giảm nếu gạch bị lặp quá nhiều và ngược lại",
    },
    {"Kiểu xáo C2",
        "cultris2generator cultrisiigenerator c2generator",
        "term",
        "Ban đầu toàn bộ Tetromino sẽ có khối lượng (“weight”) là 0.\nSau mỗi lần xáo gạch, toàn bộ cân nặng của các gạch sẽ bị chia hết cho 2, và được cộng một số thực dương ngẫu nhiên từ 0 tới 1. Gạch có khối lượng cao nhất sẽ được bốc, và sau đó cân nặng của nó sẽ bị chia cho 3.5.",
    },
    {"Hypertapping",
        "hypertapping",
        "term",
        "Hypertapping (Nhấn liên tục)\n\nĐề cập tới một kỹ năng là khi bạn rung tay liên tục để nhấn liên tục làm tốc độ di chuyển nhanh hơn\nKỹ năng này được dùng nhiều trong xếp gạch cổ điển (Classic Tetris). Nhưng bạn không cần dùng vì DAS ngắn hơn nhiều so với trước đây.",
    },
    {"Rolling",
        "rolling",
        "term",
        [[
Một phương pháp khác để khai thác nhanh ở chế độ trọng lực cao (khoảng 1G) (với cài đặt DAS/ARR chậm).
Khi bạn thực hiện thao tác rolling, bạn cố định ngón tay của bạn trên phím bạn muốn nhấn ở một bên tay, sau đó dùng các ngón tay ở bên kia gõ mạnh liên tục ở mặt sau của tay cầm. Phương pháp này nhanh hơn nhiều so với việc nhấn liên tục (xem mục “Hypertapping” để biết thêm thông tin) và yêu cầu ít công sức hơn.
Phương pháp này lần đầu tiên được phát hiện ra bởi Cheez-fish - người đã đạt tốc độ nhấn lên tới 20 Hz.
        ]],
    },
    {"Passthrough",
        "pingthrough",
        "term",
        "Đề cập đến một tình huống mà trong đó cả hai người chơi đều gửi tấn công, nhưng thay vì chúng hủy bỏ lẫn nhau thì nó lại gửi thẳng vào bảng của đối phương. Một thuật ngữ khác là “pingthrough” đề cập tình huống passthrough xảy ra do ping cao.",
    },
    {"Tetris OL attack",
        "top tetrisonlineattack",
        "term",
        [[
Cách tính tấn công trong Tetris Online

Đơn/Đôi/Tam/Tetris gửi 0/1/2/4 hàng rác.
T-spin Đơn/Đôi/Tam gửi 2/4/6 hàng rác, cắt một nửa nếu là Mini.
Combo gửi thêm 0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 5 hàng rác.
Back to Back gửi thêm 1 (hoặc 2 nếu T-spin Triple).
All Clear gửi thêm 6 hàng rác. Nhưng 6 hàng rác này sẽ gửi thẳng vào bảng đối thủ, chứ không hủy rác tới.
        ]],
    },
    {"Techmino attack",
        "techminoattack",
        "term",
        "Cách tính tấn công trong Techmino\n\nTra “hướng dẫn sử dụng” bằng cách nhấn phím ở góc dưới bên phải trên màn hình chính của game.",
    },
    {"Stacking",
        "stacking",
        "term",
        "Dùng để chỉ việc xếp các gạch mà không để lại một cái hố.",
    },
    {"Các phím xoay (1/2)",
        "doublerotation",
        "term",
        "Dùng cả phím xoay phải và xoay trái giảm số lầm phím cần nhấn bằng cách thay thế nhấn 3 lần phím xoay một bên bằng cách nhấn 1 lần phím xoay bên kia.\nLỗi di chuyển cũng có tính đến việc có sử dụng cả hai phím xoay hai không.",
    },
    {"Các phím xoay (2/2)",
        "triplerotation",
        "term",
        "Sử dụng cả ba phím xoay (phím thứ ba là xoay 180°), tất cả các gạch muốn xoay thì chỉ cần duy nhất nhấn một phím một lần.\nTuy nhiên, việc này không phải lúc nào cũng hữu dụng vì không phải game nào đều hỗ trợ cả 3 phím xoay. Hơn nữa, sự cải thiện về tốc độ khi so sánh dùng 3 phím so với 2 phím không nhiều bằng dùng 2 phím so với 1 phím. Bạn có thể bỏ qua kỹ thuật này trừ khi bạn muốn đạt tốc độ cực cao.",
    },
    {"Drought",
        "drought",
        "term",
        "Tình trạng một viên gạch nào đó bạn đang cần, thường là gạch I (a.k.a “cái Thanh dài” (the Long bar)) không xuất hiện trong một khoảng thời gian dài. Việc này có thể xảy ra và đây là hiện tượng cực kỳ nguy hiểm đối với những người chơi Tetris cổ điển. May mắn là những người chơi Tetris hiện đại hiếm khi gặp tình huống này hơn nhờ vào Trình xáo gạch ngẫu nhiên (Random Generator).\nVới Trình xáo gạch ngẫu nhiên, nếu bạn có đen lắm thì khoảng cách giữa hai gạch I TỐI ĐA là 12 gạch.",
    },
    {"Bone block",
        "bone tgm",
        "term",
        [[
Đây là skin được dùng trong những phiên bản đời đầu của Tetris
Trước đây, tất cả máy tính đều sử dụng Giao diện Dòng lệnh (Command-Line Interfaces) (nó na ná như cmd trên Windows, Terminal trên Mac, hay Console trên Linux), cho nên mỗi ô gạch đều được hiển thị dưới dạng 2 ngoặc vuông (như thế này: [ ]). Nó nhìn giống như xương, nên đôi khi được gọi là skin bone block (gạch xương).
Trong Techmino, bone block được mô tả là “một skin gạch duy nhất, lạ mắt mà tất cả các gạch đều sử dụng.” Skin khác nhau sẽ có skin bone block khác nhau.

Cũng trong Techmino nhưng trong bản tiếng Việt, từ “gạch []” để chỉ bone block.
        ]],
    },
    {"Tàng hình một phần",
        "half invisible semi",
        "term",
        "Tên tiếng Anh: Semi-invisible\nChỉ một luật trong đó gạch sẽ tàng hình sau một khoảng thời gian từ lúc nó được đặt xuống.\nKhoảng thời gian đó thường không được định sẵn, nên có thể chấp nhận mô tả nó là “biến mất sau một vài giây”.",
    },
    {"Tàng hình hoàn toàn",
        "invisible",
        "term",
        "Tên tiếng Anh: Invisible\nChỉ một luật trong đó gạch sẽ tàng hình ngay tức thì sau khi đặt xuống\nGhi chú: Nếu mode tàng hình hoàn toàn mà có hiệu ứng biến mất thì vẫn được chấp nhận. Tuy vậy, nó làm game dễ hơn đôi chút, cho nên ở Techmino, chế độ tàng hình hoàn toàn mà không có hiệu ứng biến mất được gọi là “Sudden Invisible.”",
    },
    {"Chế độ MPH",
        "mph",
        "term",
        "Sự kết hợp của ba quy tắc: “Không nhớ gì” (chuỗi gạch tạo ra hoàn toàn ngẫu nhiên), “Không biết trước gạch nào sẽ tới” (không hiện NEXT), và “Không giữ được”. Một chế độ đòi hỏi tốc độ phản ứng.",
    },
    {"Độ trễ đầu vào",
        "input delay",
        "term",
        "Bất kỳ thiết bị đầu vào cũng cần một khoảng thời gian để tín hiệu có thể tới game. Độ trễ này từ vài ms cho tới mấy trăm ms.\nNếu độ trễ đầu vào quá cao, thì việc điều khiển sẽ không thoải mái.\nĐộ trễ này thường do phần cứng và phần mềm, thứ mà bạn khó mà kiểm soát được. Bật chế độ Hiệu suất cao (Performance mode) hoặc tắt chế độ tiết kiệm năng lượng (Energy saving), đồng thời bật chế độ Gaming trên màn hình máy tính/TV, có thể giúp giảm độ trễ.",
    },
    {"Secret Grade",
        "larger than",
        "term",
        "Một chế độ dạng easter egg trong series TGM. Ở lối chơi “secret grade”, người chơi sẽ làm một đường dích dắc (zigzag) (trông giống như “>” hay “<”) bằng cách tạo ra 1 ô trống duy nhất cho từng hàng. Mục tiêu cuối cùng là hoàn thành đường dích dắc bằng 19 hàng (hoặc hơn).\nĐể biết thêm thông tin, vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để biết thêm thông tin.",
        "https://harddrop.com/wiki?search=Secret_Grade_Techniques",
    },
    {"Cold Clear",
        "cc coldclear ai bot",
        "term",
        "Một bot chơi Tetris. Được viết bởi MinusKelvin, ban đầu dành cho Puyo Puyo Tetris.\nBản Cold Clear ở trong Techmino có hỗ trợ All-spin và hệ thống TRS.",
    },
    {"ZZZbot",
        "ai bot zzztoj",
        "term",
        "Một bot chơi Tetris. Được viết bởi một người chơi Tetris Trung Quốc có tên là 奏之章 (Zòu Zhī Zhāng, xem mục bên dưới) và hoạt động khá tốt trong nhiều game (sau khi điều chỉnh thông số)",
    },
    -- # Setups
    {"Openers",
        "setup openers",
        "setup",
        [[
Opener thường là các setup thường dùng ở đầu trận. Bạn vẫn có thể làm những setup này giữa trận, nhưng thường sẽ yêu cầu một tập hợp các vị trí gạch khác nhau.

Setup này thường phải đạt cả ba yêu cầu sau:
- Có thể thích ứng với các vị trí gạch khác nhau,
- Tấn công mạnh, ít lãng phí gạch T,
- Ít yêu cầu phải Thả nhẹ để có thể đặt gạch nhanh hơn và yêu cầu sử dụng finesse.
- Có chiến lược rõ ràng và ít nhánh/biến thể.

Đa số opener sẽ tận dụng Kiểu xáo Túi 7 gạch và khai thác một điều thực tế là kiểu xáo gạch này luôn cung cấp một cho mỗi loại gạch sau mỗi 7 gạch khác nhau. Yếu tố dự đoán này giúp có thể có các setup tin cậy hơn.
        ]],
    },
    {"DT Cannon",
        "dtcannon doubletriplecannon",
        "setup",
        "Double-Triple Cannon (Pháo T-spin Đôi-Tam).\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=dt",
    },
    {"DTPC",
        "dtcannon doubletriplecannon",
        "setup",
        "Phần tiếp theo của DT Cannon kết thúc bằng All Clear.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=dt",
    },
    {"BT Cannon",
        "btcannon betacannon",
        "setup",
        "β Cannon, Beta Cannon.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=bt_cannon",
    },
    {"BTPC",
        "btcannon betacannon",
        "setup",
        "Phần tiếp theo của DT Cannon kết thúc bằng All Clear.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=bt_cannon",
    },
    {"TKI 3 Perfect Clear",
        "ddpc tki3perfectclear",
        "setup",
        "Một opener dạng TSD dẫn đến Double-Double-All Clear.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=TKI_3_Perfect_Clear",
    },
    {"QT Cannon",
        "qtcannon",
        "setup",
        "Một setup gần giống với DT Cannon và khả năng gửi DT Attack cao (DT Attack = T-spin Double + T-spin Triple).\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=QT_cannon",
    },
    {"Mini-Triple",
        "mt minitriple",
        "setup",
        "Một cấu trúc dùng để làm Mini T-spin và T-spin Triple.",
        "https://harddrop.com/wiki?search=mt",
    },
    {"Trinity",
        "trinity",
        "setup",
        "Một cấu trúc dùng để làm TSD + TSD + TSD hoặc TSMS + TST + TSD.",
        "https://harddrop.com/wiki?search=trinity",
    },
    {"Wolfmoon Cannon",
        "wolfmooncannon",
        "setup",
        "Một opener.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=wolfmoon_cannon",
    },
    {"Sewer",
        "sewer",
        "setup",
        "Một opener.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=sewer",
    },
    {"TKI",
        "tki-3 tki3",
        "setup",
        "TKI-3. Có thể chỉ TKI-3 bắt đầu bằng một TSD hoặc C-spin bắt đầu bằng một TST.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=tki_3_opening",
    },
    {"God Spin",
        "godspin",
        "setup",
        "Một setup nhìn đẹp mắt [nhưng khó sử dụng trên thực tế]. Được phát minh bởi Windkey.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=godspin",
    },
    {"Albatross",
        "albatross",
        "setup",
        "Một opener nhìn đẹp mắt, nhịp độ nhanh với TSD - TST - TSD - All Clear, khó mà lãng phí gạch T.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=Albatross_Special",
    },
    {"Pelican",
        "",
        "setup",
        "Một opener kiểu Alabatross được sử dụng trong trường hợp trật tự gạch tới không ủng hộ opener Alabatross nguyên gốc.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=Pelican",
    },
    {"Perfect Clear Opener",
        "7piecepuzzle",
        "setup",
        "Một Opener làm All Clear có khả năng thành công cao (~84.6% nếu bạn đang giữ I trong ô Hold và ~61.2% nếu không giữ). Trong chế độ PC Training (Luyện tập PC), setup này được sử dụng để tạo ra setup chưa hoàn chỉnh, không tạo ra hố.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=Perfect_Clear_Opener",
    },
    {"Grace System",
        "liuqiaoban gracesystem 1stpc",
        "setup",
        "Một opener dùng để làm PC có khả năng thành công ~88.57%. Hố vuông 4x4 trong chế độ PC Training cũng là nhờ setup này.",
        "https://four.lol/perfect-clears/grace-system",
    },
    {"DPC",
        "DPC",
        "setup",
        "Một setup để làm TSD + PC gần như 100% không có gạch nào trong bảng và gạch cuối cùng trong Túi 7 gạch trong hàng đợi NEXT. Để có thêm thông tin, xin vui lòng tra trên tetristemplate.info.",
        "https://tetristemplate.info/dpc/",
    },
    {"Gamushiro Stacking",
        "gamushiro",
        "setup",
        "(ガムシロ積み) Một opener để làm TD Attack (TD Attack = T-spin Triple + T-spin Double).\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=Gamushiro_Stacking",
    },
    -- # Pattern
    {"Mid-game Setups",
        "midgamesetups",
        "pattern",
        "Chỉ những setup cho phép gửi nhiều rác giữa trận. Một số có thể dùng làm opener, nhưng hầu như chúng không cần thiết.",
    },
    {"C-spin",
        "cspin",
        "pattern",
        "Một setup gửi tấn công bằng T-spin Triple + T-spin Double, known as TKI in Japan.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=c-spin",
    },
    {"STSD",
        "stsd",
        "pattern",
        "Super T-spin Double, một setup cho phép làm T-spin Doubles.\nNhưng nếu có rác ngay dưới hố STSD thì không tài nào làm T-spin Double được\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=stsd",
    },
    {"STMB Cave",
        "stmb",
        "pattern",
        "STMB cave, một setup dạng donation bằng cách sử dụng S/Z để bịt tường rộng 3 ô và làm T-spin Double.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=stmb_cave",
    },
    {"Fractal",
        "shuangrenjian fractal spider",
        "pattern",
        "Một setup dùng để làm T-spin.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=Fractal",
    },
    {"LST stacking",
        "lst",
        "pattern",
        "Một setup dùng để làm T-spin với số lượng vô tận.",
        "https://four.lol/stacking/lst",
    },
    {"Hamburger",
        "hamburger",
        "pattern",
        "Một setup dạng donation setup dùng để tạo cơ hội làm Tetris.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=hamburger",
    },
    {"Imperial Cross",
        "imperialcross",
        "pattern",
        "Che hố hình chữ thập bằng phần nhô ra để thực hiện hai lần T-spin Double\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=imperial_cross",
    },
    {"Kaidan",
        "jieti kaidan stairs",
        "pattern",
        "Một setup dạng donation có thể làm TSD trên địa hình cầu thang.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=kaidan",
    },
    {"Shachiku Train",
        "shachikutrain shechu",
        "pattern",
        "Một setup dạng donation cho phép làm thêm hai TSD từ setup TST.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=Shachiku_Train",
    },
    {"Cut Copy",
        "qianniao cutcopy",
        "pattern",
        "Một setup dạng donate để làm T-spin Double trên một cái hố nhỏ và có thể làm thêm một TSD nữa sau đó.",
    },
    {"King Crimson",
        "kingcrimson",
        "pattern",
        "Xếp chồng để làm (các) TSD trên STSD.\nĐể có thêm thông tin, xin vui lòng tra wiki Hard Drop. Hãy nhấn vào biểu tượng quả địa cầu để mở link.",
        "https://harddrop.com/wiki?search=King_Crimson",
    },
    {"PC liên tiếp (1/3)",
        "pcloop",
        "pattern",
        "Bạn có thể tìm hướng dẫn đầy đủ trên “Tetris Hall” từ PC đầu → PC thứ 4 và thứ 7. Sau khi nó hoàn thành PC thứ 7, bạn đã dùng chính xác 70 gạch nên bạn có thể quay lại và làm PC đầu.",
        "https://shiwehi.com/tetris/template/consecutivepc.php",
    },
    {"PC liên tiếp (2/3)",
        "pcloop",
        "pattern",
        "four.lol có hướng dẫn cho PC thứ 5 và thứ 6.",
        "https://four.lol/perfect-clears/5th",
    },
    {"PC liên tiếp (3/3)",
        "pcloop",
        "pattern",
        "Một hướng dẫn làm PC-loop hoàn chỉnh được viết bởi NitenTeria.",
        "https://docs.qq.com/sheet/DRmxvWmt3SWxwS2tV",
    },
    -- # Savedata managing
    {"Console",
        "cmd commamd minglinghang kongzhitai terminal",
        "command",
        "Techmino có một console cho phép kích hoạt tính năng gỡ lỗi và bật các tính năng nâng cao.\nĐể truy cập, hãy chạm/nhấn vào logo Techmino/ nhấn phím C 4 lần, tại màn hình chính.\n\nHành động bất cẩn trong console có thể dẫn đến HƯ HỎNG/ MẤT TOÀN BỘ dữ liệu đã lưu KHÔNG THỂ PHỤC HỒI.\n\nCÓ RỦI RO KHI TIẾN HÀNH\nKHÔNG AI CHỊU TRÁCH NHIỆM MỌI MẤT MÁT CÓ THỂ XẢY RA TRỪ CHÍNH BẠN!",
    },
    {"Đặt lại thiết lập",
        "reset setting",
        "command",
        "Vào console, gõ “rm conf/setting” sau đó nhấn Enter/Return.\nKhởi động lại Techmino để thay đổi có hiệu lực.\nĐể hoàn tác/hủy bỏ thay đổi đã thực hiện, hãy vào Cài đặt rồi trở ra.",
    },
    {"Xóa t.bộ thành tích",
        "reset statistic data",
        "command",
        "Vào console, gõ “rm conf/data” sau đó nhấn Enter/Return.\nKhởi động lại Techmino để thay đổi có hiệu lực.\nĐể hoàn tác/hủy bỏ thay đổi đã thực hiện, chơi một chế độ bất kỳ sau đó nhận màn hình Thắng/Thua",
    },
    {"Đặt lại t.trg mở khóa",
        "reset unlock",
        "command",
        "Vào console, gõ “rm conf/unlock” sau đó nhấn Enter/Return.\nKhởi động lại Techmino để thay đổi có hiệu lực.\nĐể hoàn tác/hủy bỏ thay đổi đã thực hiện, cập nhật lại tình trạng của một chế độ bất kỳ.",
    },
    {"Xóa t.bộ kỷ lục",
        "reset record",
        "command",
        "Vào console, gõ “rm -s record” sau đó nhấn Enter/Return.\nKhởi động lại Techmino để thay đổi có hiệu lực.\nYou can revert this action on an individual-mode basis; play one game and have its leaderboards updated to recover that mode's leaderboards.",
    },
    {"Đặt lại bố cục phím",
        "reset virtualkey",
        "command",
        "Vào console, gõ “rm conf/[File_bố_cục_phím]” sau đó nhấn Enter/Return.\nThay [File_bố_cục_phím] với file cần xóa: File bố cục bàn phím trên máy tính: key; File bố cục nút trên màn hình: virtualkey; Bản lưu bố cục nút trên màn hình: vkSave1, vkSave2\nKhởi động lại Techmino để hai thay đổi đầu tiên có hiệu lực.\nVào một trang chỉnh sửa bố cục phím/nút sau đó trở ra để lấy lại file tương ứng.",
    },
    {"Delete replays",
        "delete recording",
        "command",
        "Vào console, gõ “rm -s replay“ sau đó nhấn Enter/Return.\nHiệu lực tức thì, KHÔNG THỂ HOÀN TÁC",
    },
    {"Delete cache",
        "delete cache",
        "command",
        "Vào console, gõ “rm -s cache” sau đó nhấn Enter/Return.\nHiệu lực tức thì, KHÔNG THỂ HOÀN TÁC",
    },
    -- # English
    {"SFX",
        "soundeffects",
        "english",
        "Từ viết tắt của “Sound Effects” (Hiệu ứng âm thanh). Ở Nhật Bản, từ này được viết tắt là “SE”.",
    },
    {"BGM",
        "backgroundmusic",
        "english",
        "Từ viết tắt của “Background Music.”",
    },
    {"TAS",
        "tas",
        "english",
        "Từ viết tắt của “Tool-Assisted Speedrun (Superplay)” (Công cụ hỗ trợ Speedrun)\nChơi một game nào đó mà không cần công cụ đặc biệt để phá vỡ quy tắc của game (ở cấp độ chương trình/phần mềm).\nNó thường được sử dụng để đạt điểm tối đa theo lý thuyết/đạt được những mục tiêu thú vị\nMột công cụ TAS như vậy cũng có sẵn, nhưng là bản nhỏ gọn, được đi kèm với Techmino.",
    },
    {"AFK",
        "afk",
        "english",
        "Từ viết tắt của “Away From Keyboard” (dịch sát nghĩa: “Đang ở xa bàn phím”), hay theo nghĩa rộng hơn, khoảng thời gian bạn không chơi game.\nNghỉ giải lao thường xuyên giúp bạn giảm căng cơ và giúp bạn chơi tốt hơn khi quay trở lại.",
    },
}
