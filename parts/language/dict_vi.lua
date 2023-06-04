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
        "hướng dẫn ;,; người mới chơi ;,; lời khuyên",
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
        "hướng dẫn ;,; người mới chơi ;,; lời khuyên",
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
        "hướng dẫn ;,; người mới chơi ;,; lời khuyên ;,; trợ giúp",
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
        "homepage mainpage websites".."website homepage ;,; trang chủ ;,;",
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
        "githubrepository sourcecode src".."mã nguồn mở ;,; dự án ;,; kho lưu trữ",
        "org",
        "Kho lưu trữ chính thức của Techmino trên GitHub. Chúng tôi đánh giá cao nếu bạn tặng cho chúng tôi một ngôi sao! (À sao này miễn phí nhé)",
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
        "community vietnam ;,; việt nam ;,;",
        "org",
        [[
Một trong những cộng đồng xếp gạch tại Việt Nam. Cộng đồng này hiện có một nhóm Facebook và một server tại Discord.

Liên kết ở mục này sẽ dẫn bạn tới server Discord, còn để tìm nhóm Facebook thì lên Facebook và tìm "Tetris Việt Nam"
        ]],
        "https://discord.gg/jX7BX9g",
    },
    {"Tetris OL Servers",
        "tetrisonline servers tos".."server ;,; tos",
        "org",
        "Hãy lên Google tra “Tetris Online Poland” để tìm server ở Ba Lan.\nCòn nếu tìm server Tetris Online Study được đặt tại Trung Quốc (cung cấp bởi Teatube, hãy nhìn vào mục bên dưới) thì nhấn vào biểu tượng quả địa cầu",
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
Đề xuất cho những người chơi có thể hoàn thành chế độ 40L chỉ dùng Tetris + không dùng Hold
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
        "Tetris Puzzle O. Một trang web bằng tiếng Nhật được viết bởi TCV100 (có chứa một vài câu đố từ NAZO).",
        "http://121.36.2.245:3000/tpo",
    },
    {"Ghi chú",
        "note nb NB DM notice",
        "game",
        "Nội dung sau đây là những giới thiệu ngắn gọn về một số game xếp gạch chính thức và do fan làm có mức độ phổ biến cao. MrZ - tác giả của Techmino và Sea - tình nguyện viên dịch Zictionary sang tiếng Việt, có để lại một vài lời nhận xét (và thông tin bổ sung) cho game. Hãy nhớ là không phải game nào được nhắc đến đều có lời nhận xét, và chúng chỉ là những ý kiến chủ quan. Đọc chỉ để tham khảo, những nhận xét này không có tính chuyên môn.",
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

Gọi tắt là TL. Một tựa game chứa nhiều chế độ chơi đơn + 2 chế độ nhịp điệu. INó cũng hình dung các cơ chế thường ẩn trong các trò chơi Tetris khác. Quá trình phát triển (và bỏ hoang) từ tháng 12 năm 2020.
        ]],
        "https://tetralegends.app",
    },
    {"Ascension",
        "asc ASC",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn/Chơi trực tuyến

Gọi tắt là ASC. Game sử dụng hệ thống xoay riêng biệt (cũng tên là ASC) và có nhiều chế độ chơi đơn. Chế độ 1 đấu 1 hiện vẫn còn trong giai đoạn Alpha (16/T4/2022). Chế độ Stack của Techmino cũng bắt nguồn từ trò chơi này.
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

Gọi tắt là teto hoặc IO. Trò chơi này có một hệ thống xếp rank cũng như có chế độ tự do với nhiều thông số có thể tùy chỉnh. Trò chơi này cũng có một client dành cho máy tính, giúp cải thiện tốc độ và gỡ bỏ quảng cáo
        
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
Chơi trên trình duyệt | Chơi đơn/Chơi trực tuyến

Gọi tắt là TF. Một trò chơi Tetris dựa trên một plugin đã bị khai tử từ lâu. Từng rất phổ biến trong quá khứ, nhưng tất cả trò chơi đã đóng cửa từ mấy năm trước. Hiện giờ còn một máy chủ riêng tư tên là “Notris Foes” vẫn còn tồn tại. Nhấn vào biểu tượng quả địa cầu để mở ở trong trình duyệt

[Sea: Lưu ý bạn cần phải cài một client cho Notris Foes thì mới có thể chạy game mặc dù bạn cố cài tiện ích bổ sung.]
        ]],
        "https://notrisfoes.com",
    },
    {"tetris.com",
        "tetris online official",
        "game",
        [[
Chơi trên trình duyệt | Chơi đơn | Hỗ trợ điện thoại

Game Tetris chính thức tetris.com, mà chỉ có một chế độ (Marathon). Bù lại, có hỗ trợ hệ thống điều khiển thông minh bằng chuột

[Sea: Thông tin thêm: nếu bạn ở trên điện thoại thì có ba cách điều khiển: "vuốt" (swipe), "thông minh" (smart), "bàn phím". Bạn có thể thử nghiệm với cả ba chế độ điều khiển. Để điều khiển bằng "bàn phím" thì bạn chỉ cần kết nối với bàn phím là được, còn để đổi giữa "vuốt" và "thông minh" thì hãy mở Options của game.]
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
Chơi trên trình duyệt | Chơi đơn

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

Gọi tắt là TE(C). Một game xếp gạch chính thức với đồ họa và nhạc nền lạ mắt phản ứng với đầu vào của bạn. Phiên bản cơ bản (Tetris Effect, không có chữ "Connected") chỉ có các chế độ chơi đơn. Phiên bản mở rộng, Tetris Effected Connected có 4 chế độ chơi trực tuyến đó là: Connected (VS), Zone Battle, Score Attack, và Classic Score Attack.
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

[MrZ: Giao diện của game mang phong cách retro. Ngoài ra, game chỉ có thể điều khiển thông qua bàn phím, nên một vài người chơi mới có thể gặp một số vấn đề. Ngoài ra, có vẻ như macOS Monterey khoong thể chạy được game này.]
        ]],
    },
    {"Misamino",
        "misamino",
        "game",
        [[
Windows | Chơi đơn

Chỉ có chế độ chơi 1 đấu 1 với bot, chủ yếu là chơi theo lượt. Bạn có thể viết bot cho game này (nhưng cần phải học API của game này).

Misamino cũng là tên của bot trong game này
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

Một tựa game xếp gạch được phát triển bởi EA. Có hai cách điều khiển: Swipe (Vuốt) and One-Touch (Một chạm). Game này có chế độ Galaxy ngoài chế độ Marathon (với cơ chế trọng lực), và mục tiêu của chế độ này là xóa hết tất cả các mino của Galaxy trước khi hết chuỗi gạch

Game đã bị khai tử từ tháng 4 năm 2020

[Sea: game đang nhắc ở đây là bản năm 2011 (phát hành khoảng 2011 - 2012)]
        ]],
    },
    {"Tetris (N3TWORK)",
        "tetris n3twork mobile phone",
        "game",
        [[
iOS/Android | Chơi đơn

Một tựa game xếp gạch, trước đây được phát triển bởi N3TWORK. Nhưng từ cuối tháng 11 năm 2021, PlayStudios đã giành được bản quyền để phát triển độc lập. Từ đó PlayStudios tiếp tục phát triển game này. Có chế độ Chơi nhanh 3 phút, Marathon, chế độ Royale 100 người chơi và chế độ Phiêu lưu.

Ghi chú: từ tháng 11 hoặc tháng 12 năm 2022 và sau này, tất cả các tài khoản mới tạo chỉ có chế độ Marathon và chế độ Phiêu lưu. Tức là chế độ Chơi nhanh và Royale sẽ không xuất hiện trên những tài khoản này

[MrZ: UI thì tuyệt nhưng cơ chế điều khiển thì tệ]

[Sea: nói chung là phần điều khiển rất là tệ: phím trên màn hình cảm ứng nó khá là nhỏ, nhỏ hơn cả ngón tay mình có thể bấm, game nó khá là chán bởi vì thiếu mất chế độ Royale - chế độ duy nhất mà theo mình nghĩ là điểm sáng lẻ loi duy nhất, ngoài ra những thứ khác nhấn chìm xuống đáy biển sâu]
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

[Sea: mục này mình xin phép viết lại cho dễ đọc, MrZ viết rối quá dịch không nổi. Có tham khảo từ Tetris.wiki]

Một game xếp gạch chính thức đã bị khai tử được phát triển bởi Tencent (chỉ có ở Trung Quốc).

Có 5 chế độ chơi đơn: Marathon, Sprint (40 hàng), Ultra (2 phút), Road to Master (chế độ luyện tập, chứa nhiều bài học về các kỹ thuật khác nhau), Adventure (chế độ câu chuyện với minigame).

Cùng với 3 chế độ chơi trực tuyến gồm: League Battle (chế độ đối đầu có xếp rank), Melee 101 (gần giống với Tetris 99 nhưng mỗi phòng có 101 người), Relax Battle (cũng chế độ đối đầu nhưng không xếp rank)
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
    {"Ghi chú dịch thuật #2",
        "",
        "help",
        "Ghi chú về những thuật ngữ có liên quan tới \"mỗi phút\" và \"mỗi giây\"\n\nKhông phải tất cả thuật ngữ nào được nhắc đến trong này đều được áp dụng rộng rãi trong cộng đồng, hoặc là có chung ý nghĩa trong mọi bối cảnh. Chúng chủ yếu áp dụng cho Techmino",
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
        "Attack & Dig per minute | Số hàng tấn công & đào xuống mỗi phút\n\tDùng để so sánh sự khác nhau về kỹ năng của hai người chơi trong một trận đấu; chính xác hơn một chút so với APM\n\tNhân tiện thì VS Score (điểm VS) chính là ADPM mỗi 100 giây",
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
        "*Chỉ có trên Techmino*\nXóa 4 hàng cùng một lúc.",
    },
    {"Tetris",
        "tetris 4",
        "term",
        "Đây chính là tên game (cũng như là tên thương hiệu của nó). Đây cũng là thuật ngữ được dùng để nói về việc xóa 4 hàng cùng lúc trong các game chính thức.\nĐược ghép từ 2 từ: Tetra (<τέτταρες>, có nghĩa là số 4 trong tiếng Hy Lạp) and Tennis (quần vợt, môn thể thao yêu thích nhất của người đã sáng tạo ra Tetris). Nhân tiện những game xếp gạch được phát triển bởi Nintendo và SEGA đều được cấp phép bởi TTC. Hai công ty này không có bản quyền của Tetris",
        -- _comment: original Lua file had this comment: "Thanks to Alexey Pajitnov!"
    },
    {"All Clear",
        "pc perfectclear ac allclear",
        "term",
        "Còn được biết tới là Perfect Clear (PC). Đây là thuật ngữ được dùng nhiều trong cộng đồng và cũng như được dùng trong Techmino\nXóa toàn bộ gạch ra khỏi bảng, không trừ gạch nào\n\n[Sea: từ này còn một tên khác nữa giờ ít dùng đó là \"Bravo\"]",
    },
    {"HPC",
        "hc clear halfperfectclear",
        "term",
        "*Chỉ có trên Techmino*\nHalf Perfect Clear\nMột biến thể của All Clear. Nếu hàng đó bị xóa mà rõ ràng giống với Perfect Clear khi bỏ qua những hàng bên dưới, thì được tính là Half Perfect Clear và sẽ gửi thêm một lượng hàng rác nhỏ",
    },
    {"Spin",
        "spin",
        "term",
        "Xoay gạch để di chuyển tới một vị trí mà thông thường sẽ không tiếp cận được. Ở một số game, thao tác này sẽ gửi thêm hàng rác hoặc là tăng thêm điểm. Game khác nhau sẽ có cách kiểm tra Spin khác nhau.",
    },
    {"Mini",
        "mini",
        "term",
        "Một thuật ngữ bổ sung khác dành cho Spin dành cho những Spin mà game nghĩ là có thể thực hiện dễ dàng (bởi vì trong một game cũ nó được gọi là \"Ez T-spin\"). Bonus điểm và hàng rác đều bị giảm so với Spin thông thường.\nCác game khác nhau có các quy tắc khác nhau để kiểm tra chúng có phải là Mini-Spin hay không. Bạn chỉ cần nhớ mấy cái bố cục làm Mini-spin là được.",
    },
    {"All-Spin",
        "allspin",
        "term",
        "Một quy luật mà trong đó, làm Spin bằng gạch gì đều cũng được thưởng thêm điểm và gửi thêm hàng rác; đối lập với việc chỉ được Spin bằng gạch T (aka “Chỉ làm T-spin”).",
    },
    {"T-Spin",
        "tspin",
        "term",
        "Spin được thực hiện bởi Tetromino T.\nTrong các game hiện đại chính thức, T-Spins chủ yếu được phát hiện bởi quy luật 3 góc. Tức là, nếu 3 trong 4 góc của một hình chữ nhật (có tâm là tâm xoay của gạch T) bị đè bởi bất kỳ gạch nào, thì Spin đó được tính là T-spin. Một vài game cũng sẽ có thêm vài quy tắc để xem T-spin đó có phải là T-spin thường không hay Mini T-spin",
    },
    {"TSS",
        "t1 tspinsingle",
        "term",
        "T-Spin Single | T-Spin Đơn\nXóa một hàng bằng T-Spin",
    },
    {"TSD",
        "t2 tspindouble",
        "term",
        "T-Spin Double | T-Spin Đôi\nXóa hai hàng bằng T-Spin.",
    },
    {"TST",
        "t3 tspintriple",
        "term",
        "T-Spin Triple | T-Spin Tam\nXóa ba hàng bằng T-Spin.",
    },
    {"MTSS",
        "minitspinsingle tsms tspinminisingle",
        "term",
        "Mini T-Spin Single | Mini T-Spin Đơn\nTrước đây từng biết tới với tên là T-Spin Mini Single (TSMS) (T-spin Mini Đơn).\nXóa một hàng bằng Mini T-Spin.\nMỗi game sẽ có cách khác nhau để xác định xem T-spin đó có phải là Mini hay không.",
    },
    {"MTSD",
        "minitspindouble tsmd tspinminidouble",
        "term",
        "Mini T-spin Double | Mini T-Spin Đôi\nTrước đây từng biết tới với tên là T-Spin Mini Double (TSMD) (T-spin Mini Đôi).\nXóa hai hàng bằng Mini T-Spin. MTSD chỉ xuất hiện trong một vài game hạn chế và có các cách kích khác nhau.",
    },
    {"O-Spin",
        "ospin",
        "term",
        "Bởi vì gạch O luôn \"tròn\", không đổi hình dạng khi xoay, nên không có cách nào để \"đá\" gạch. Cho nên có một meme trong cộng đồng Tetris: Đã có một người làm một fake video làm cách nào để làm O-Spin trong Tetris 99 và Tetris Friends, và sau đó thì nó được viral\nXRS cho phép gạch O có thể “teleport” tới một cái hố.\nTrong TRS, ta có thể cho gạch O “teleport” hoặc có thể cho gạch O “biến hình” (theo nghĩa đen)thành một gạch có hình dạng khác",
    },
    {"Hệ thống xoay gạch",
        "wallkick rotationsystem",
        "term",
        "Một hệ thống để xác định cách gạch xoay.\n\nTrong các trò Tetris hiện đại, tetrominoes có thể xoay dựa trên một tâm xoay cố định (nhưng có thể sẽ không hiện diện trong một vài trò chơi). Nếu gạch sau khi xoay đè lên gạch khác hoặc là ra ngoài khỏi bảng, hệ thống sẽ thử dịch chuyển gạch ở các vị trí xung quanh vị trí đang đứng (một quá trình mà được biết với tên gọi “wall-kicking” ('đá' tường)).\n'Đá' tường cho phép gạch có thể đến những hố có hình dạng nào đó mà bình thường không thể tiếp cận được. Các vị trí mà gạch có thể 'đá' được chứa trong một bảng gọi là “wall-kick table” (bảng các vị trí 'đá' tường)\n\nP/s: trong Zictionary (TetroDictionary), từ \"bảng các vị trí 'đá' tường\" được viết tắt là \"bảng 'đá' tường\" (do lười gõ, mà cái này có thể thay đổi sau)",
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
    1. Thử dịch chuyển gạch sang trái/phải/xuống tùy thuộc vào phím đang giữ (là phím Sang trái/Sang phải/Rơi nhẹ); có thêm độ lệch xuống dưới
    2. Nếu thất bại, cũng thử di chuyển sang bên trái/bên phải/đi xuống tùy thuộc vào phím đang giữ; nhưng lúc này không thêm độ lệch xuống dưới
    3. Nếu thất bại... thì việc xoay thất bại luôn (cái này thì không còn gì để nói)

Khi so sánh với XRS, BiRS dễ nhớ hơn nhiều vì nó chỉ dùng một bảng 'đá' tường; nhưng vẫn giữ nguyên được tính năng vượt địa hình của SRS.

Khoảng cách euclide của độ lệch của cú đá được chọn không được lớn hơn √5; và nếu có độ lệch theo chiều ngang, thì hướng của cú đá đó không được là hướng ngược lại với hướng đã chọn (từ việc giữ phím)
        ]],
    },
    {"C2RS",
        "c2rs cultris2",
        "term",
        "Cultris II rotation system | Hệ thống xoay Cultris II, một hệ thống xoay được dùng trong Cultris II - một bản sao (clone) của Tetris.\nToàn bộ gạch và cả hướng xoay đều sử dụng chung một bảng 'đá' tường (trái, phải, xuống, xuống + trái, xuống + phải, trái 2, phải 2), với ưu tiên về phía bên trái so với bên phải.\n\nTrong Techmino có một bản chỉnh sửa của hệ thống này, đó là C2sym. C2sym sẽ ưu tiên hướng theo hình dáng của gạch",
    },
    {"C2sym",
        "cultris2",
        "term",
        "Một bản mod của C2RS. Hệ thống sẽ ưu tiên hướng Trái/Phải tùy vào hình dáng của các viên gạch khác nhau.",
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
        "Super Rotation System | Hệ thống xoay Siêu cấp [*], là hệ thống xoay được sử dụng rất nhiều trong các game xếp gạch và có rất nhiều hệ thống xoay do fan làm ra cũng dựa vào hệ thống này. Có 4 hướng cho Tetromino và có thể xoay phải và xoay trái (nhưng không thể xoay 180°). Nếu Tetromino đụng tường, đụng đáy, hay đè lên gạch khác sau khi xoay; hệ thống sẽ kiểm tra các vị trí xung quanh. Bạn có thể xem .\n\n[*] [Sea]: ban đầu tính dịch thành \"Hệ thống xoay Super\", nhưng thôi mình chọn cụm từ này để dịch cho sát nghĩa.",
    },
    {"SRS+",
        "srsplus superrotationsystemplus",
        "term",
        "Một biến thể của SRS, hỗ trợ bảng 'đá' tường khi xoay 180°.",
    },
    {"TRS",
        "techminorotationsystem",
        "term",
        "*Chỉ có trên Techmino*\nTechmino Rotation System | Hệ thống xoay Techmino\nHệ thống xoay được dùng trong Techmino, dựa trên SRS.\nHệ thống này sửa những trường hợp gạch S/Z bị kẹt và không thể xoay trong một vài trường hợp; cũng như bổ sung thêm những vị trí 'đá' hữu dụng. Pentomino cũng có bảng 'đá' tường dựa trên logic của SRS. TRS cũng hỗ trợ O-Spin (O-Spin cho phép gạch có thể 'đá' và có thể 'biến hình').",
    },
    {"XRS",
        "xrs",
        "term",
        "X rotation system | Hệ thống xoay X, một hệ thống xoay được dùng trong T-ex.\n\nHệ thống giới thiệu một tính năng với tác dụng “dùng một bảng 'đá' tường khác khi giữ một phím mũi tên,” cho phép người chơi có thể nói game hướng mà gạch nên di chuyển theo ý muốn của họ.",
    },
    {"Back to Back",
        "b2b btb backtoback",
        "term",
        "Aka B2B. Xóa 2 hoặc nhiều lần xóa theo kiểu 'kỹ thuật' (như Tetris hay Spin) liên tiếp (nhưng không xóa theo kiểu 'thông thường'; gửi thêm hàng rác khi tấn công\nKhông như combo, Back To Back sẽ không bị mất khi đặt gạch.",
    },
    {"B2B2B",
        "b3b",
        "term",
        "*Chỉ có trên Techmino*\nBack to back to back, aka B3B (hoặc B2B2B). Thực hiện nhiều Back to Back liên tiếp để lấp đầy thanh B3B; cuối cùng khi bạn đã lấp B3B vượt một mức nhất định, bạn có thể tấn công mạnh hơn khi làm được B2B, nhờ sức mạnh từ B3B",
    },
    {"Fin, Neo, Iso",
        "fin neo iso",
        "term",
        "Các kỹ thuật T-Spin đặc biệt khai thác việc gạch T 'đá' và hệ thống phát hiện T-Spin. Chúng có sức mạnh tấn công khác nhau trong các game khác nhau (một số game sẽ coi chúng là Mini T-Spin), nhưng hầu như cũng không có giá trị gì trong thực sự trong chiến đấu do cách setup tương đối phức tạp của chúng.",
    },
    {"Modern Tetris",
        "modern",
        "term",
        [[
Khái niệm về trò chơi Tetris hay trò chơi xếp gạch “hiện đại” rất mờ nhạt. Nói chung, một trò chơi xếp gạch hiện đại thường sẽ bám sát theo Tetris Design Guideline (Nguyên tắc thiết kế Tetris hiện đại).
Dưới đây là một số quy tắc chung, nhưng chúng không phải là quy tắc bắt buộc
    1. Phần có thể nhìn được của bảng có kích thước 10 × 20 (rộng × dài), cùng với 2 - 3 hàng ẩn ở bên nhau.
    2. Gạch sẽ được sinh ra ở giữa trên cùng của ma trận có thể nhìn thấy (thường là ở hàng 21-22). Mỗi mảnh đều có màu sắc và hướng quay mặc định riêng.
    3. Có một bộ xáo gạch như 7-bag hay His
    4. Có hẳn một hệ thống xoay, và cho phép xoay theo ít nhất 2 hướng
    5. Has an appropriate lockdown delay system.
    6. Has an appropriate top-out condition.
    7. Has a Next queue, with multiple next pieces displayed (usually 3-6), and with the presentation in the queue matching the spawn orientation of the piece.
    8. Has a Hold queue.
    9. If there is spawn delay or line delay, usually has IRS and IHS.
    10. Has a DAS system for precise and swift sideways movements.
        ]],
    },
    {"Tetrominos’ Shapes",
        "shape structure form tetromino tetrimino",
        "term",
        "In standard Tetris games, all the blocks used are tetrominoes, i.e., Blocks that are linked by four minoes side-by-side.\n\nThere are seven kinds of tetrominoes in total when allowing rotations and disallowing reflections. These tetrominoes are named by the letter in the alphabet that they resemble. They are Z, S, J, L, T, O, and I. See the “Shape & Name” entry for more information.",
    },
    {"Tetrominos’ Colors",
        "colour hue tint tetromino tetrimino",
        "term",
        "Many modern Tetris games use the same color scheme for the tetrominoes. The colors are:\nZ–red, S–green, J–blue, L–orange, T–purple, O–yellow, and I–cyan.\n\nTechmino also uses this “standard” coloring for the tetrominoes.",
    },
    {"IRS",
        "initialrotationsystem",
        "term",
        "Initial Rotation System\nHolding a rotation key during spawn delay to spawn the piece pre-rotated. Sometimes prevents death.",
    },
    {"IHS",
        "initialholdsystem",
        "term",
        "Initial Hold System\nHolding the Hold key during spawn delay to spawn the held piece (or next piece in the Next queue if there is no held piece) instead of the current piece, and put the current piece in the Hold as if the player has performed the held before spawning. Sometimes prevents death.",
    },
    {"IMS",
        "initialmovesystem",
        "term",
        "*Chỉ có trên Techmino*\nInitial Movement System\nHolding a sideways movement key during spawn delay to spawn the piece one block off to the side. Sometimes prevents death.\nNote that DAS needs to be fully charged when a new piece appears.",
    },
    {"Next",
        "nextpreview",
        "term",
        "Displays the next few pieces to come. It is an essential skill to plan ahead where to place blocks in the Next queue to improve your Tetris skill.",
    },
    {"Hold",
        "hold",
        "term",
        "Save your current piece for later use, and take out a previously held piece (or next piece in the next queue, if no piece was held) to place instead. You can only perform this once per piece in most cases.\n\n*Chỉ có trên Techmino*: Techmino has an “In-place Hold” feature. When enabled, pieces that spawn from the Hold queue will spawn at where your currently-controlling piece is, instead of at the top of the matrix.",
    },
    {"Swap",
        "hold",
        "term",
        "Like *Hold*, swap your current piece and the first piece of the next queue. You can also only perform this once per piece in most cases.",
    },
    {"Deepdrop",
        "shenjiang",
        "term",
        "*Chỉ có trên Techmino*\n\nA special function allows minoes to teleport through the wall to enter a hole. When the mino hits bottom, pressing the soft drop button again will enable the deep drop. Suppose there is a hole that fits the shape of the mino. In that case, it will teleport into this hole immediately.\nThis mechanism is especially useful for AIs because it allows AI to disregard the differences between different rotation systems.",
    },
    {"Misdrop",
        "md misdrop",
        "term",
        "Accidentally placed (dropped) a piece in an unintended location.",
    },
    {"Mishold",
        "mh mishold",
        "term",
        "Accidentally pressed the Hold key. This can lead to using an undesired piece or missing out on a chance to a PC.",
    },
    {"sub",
        "sub",
        "term",
        "A sub-[number] time means the time is below a certain milestone. The unit of the time is often left out and inferred; for example, a “sub-30” time for a 40-line Sprint means below 30 seconds, and a “sub-15” time for a 1000-line Sprint means below 15 minutes.",
    },
    {"Digging",
        "downstacking ds",
        "term",
        "Clearing garbage lines entered from the bottom of the field. Aka downstacking.",
    },
    {"Donation",
        "donate",
        "term",
        "A method of “plugging” up the Tetris hole to send a T-Spin. After the T-Spin, the Tetris hole is opened up once again to allow the continuation of Tetris or downstacking.\n-- Harddrop wiki",
    },
    {"‘Debt’",
        "qianzhai debt owe",
        "term",
        "A terminology used in the Chinese Tetris community. A “debt” refers to a situation where one must first finish constructing a specific setup before they can perform one or more T-spins with real attacks. When constructing a setup where one or multiple debts are created, it is important to observe the opponent to ensure your safety; otherwise, there is a high probability of topping out before the construction is finished.\n\nThis term is frequently used to describe setups such as TST tower. No real attacks can be made before the setup is constructed completely.",
    },
    {"Attack & Defend",
        "attacking defending",
        "term",
        "Attacking: send garbage lines to your opponent by clearing lines.\nDefending: You offset this garbage by clearing lines after your opponent sends you lines.\nCounter attack: Send attack back at your opponent after offsetting incoming garbage, or taking the hit, then attack back.\nIn most games, garbage offsetting is 1:1, i.e., one attack offsets one incoming garbage.",
    },
    {"Combo",
        "ren combo",
        "term",
        "Known in Japan as REN.\nConsecutive line clears make up combos. The second line clear in the combo is called 1 Combo, and the third line clear is called 2 Combo, and so on.\nUnlike Back to Back, placing a piece that does not clear a line will break the combo.",
    },
    {"Spike",
        "spike",
        "term",
        "Sending many attacks in a short time.\n\nBoth Techmino and TETR.IO have spike counters, which shows how many attacks you send in a short time.\n\nNote that accumulated garbage due to network lag do not count as a spike.",
    },
    {"Side well",
        "ren combo sidewell",
        "term",
        "A stacking method where you leave a well of a certain width on the side.\nA Side 1-wide setup is the traditional Tetris setup (i.e., Side well Tetris).\nA Side 2-, 3-, or 4-wide setup is a combo setup. For new players, they can be effective ways to send attacks. However, opponents can easily send you garbage while building your stack, killing you or cutting your stack short. Because of this, advanced players might not opt to build tall stacks and instead keep a steady stream of T-Spins and Tetrises and attack when the opponent is unlikely to offset the garbage.",
    },
    {"Center well",
        "ren combo centerwell",
        "term",
        "A stacking method where you leave a well of a certain width at the center.",
    },
    {"Partial well",
        "ren combo partialwell",
        "term",
        "A stacking method where you leave a well of a certain width at not-center-or-side position.",
    },
    {"Side 1-wide",
        "s1w side1wide sidewelltetris",
        "term",
        "Also known as Side well Tetris.\nThe most traditional way to play. It is also easy to do in modern Tetris and can send a half-decent attacks. However, this is hardly used in advanced matches due to the lower efficiency of Tetrises compared to T-Spins.",
    },
    {"Side 2-wide",
        "s2w side2wide",
        "term",
        "The stacking method where you leave a two-block-wide well on the side. A common combo setup.\nEasy to use. New players can give it a try and produce some half-decent combos when combined with Hold. Not often used in advanced games because it takes more time to build the stack, leaving room for opponents to send garbage and cut your stack short. It is also not so good in terms of efficiency.",
    },
    {"Side 3-wide",
        "s3w side2wide",
        "term",
        "The stacking method where you leave a three-block-wide well on the side. A combo setup is less common than 2-wide.\nCan perform more combos than 2-wide, but also harder to do, easy to break the combo.",
    },
    {"Side 4-wide",
        "s4w side4wide",
        "term",
        "The stacking method where you leave a four-block-wide well on the side. A combo setup.\nIf done well, it can produce very impressive combos. Also, it takes less time to build up, so you might be able to start your combo before incoming garbage. However, there is still a risk of being killed by incoming garbage, and it is thus less overpowered.",
    },
    {"Center 1-wide",
        "c1w center1wide centerwelltetris",
        "term",
        "Also known as Center well Tetris.\nThe stacking method where you leave a one-block-wide well in the middle. Commonly used in combat because this allows Tetrises and T-Spins and is not too difficult to make.",
    },
    {"Center 2-wide",
        "c2w center2wide",
        "term",
        "The combo setup where you leave a two-block-wide well in the middle. Not very common, though.",
    },
    {"Center 3-wide",
        "c3w center3wide",
        "term",
        "The combo setup where you leave a three-block-wide well in the middle. Not very common, though.",
    },
    {"Center 4-wide",
        "c4w center4wide",
        "term",
        "The stacking method where you leave a four-block-wide well in the middle.\nThe infamous combo setup that not only makes many combos but also abuses the death conditions and won’t die even if you receive some garbage. Players often dislike this technique due to how unbalanced it is.",
    },
    {"Residual",
        "c4w s4w",
        "term",
        "Refers to how many blocks to leave in the well of a four-wide combo setup. The most common are 3-residual and 6-residual.\n3-residual has fewer variations and is easier to learn, with a pretty good chance of success, and it’s pretty useful in combat.\n6-residual has more variables and is harder, but can be more consistent if you do it well. It can also be used for special challenges like getting 100 combos in an infinite 4-wide challenge.\nIn principle, use 6-Res first, then 5-Res and 3-Res, and then 4-Res.",
    },
    {"6–3 Stacking",
        "63stacking six-three sixthree",
        "term",
        "A way of stacking where you have a six-block-wide stack on the left and a three-block-wide stack on the right.\nFor a skilled player, this method of stacking might reduce the keypresses needed for stacking, and is a popular Sprint stacking method. The reason why it works has to do with the fact that pieces spawn with a bias to the left.",
    },
    {"Freestyle",
        "ziyou",
        "term",
        "This term is usually used in 20 TSDs. Freestyle means finishing 20 TSDs without using static stacking modes. Freestyle 20TSDs is more difficult than static stacking modes such as LST, and the performance can represent the T-spin skills a player has in battles.",
    },
    {"Topping out",
        "die death topout toppingout",
        "term",
        "Modern Tetris games have three different conditions in which the player tops out:\n1. Block out: when a piece spawned overlaps with the existing blocks in the field;\n2. Lock out: when a piece locks entirely above the skyline;\n3. Top out: when the stack exceeds 40 lines in height (often due to incoming garbage).\nTechmino does not check for locking out and topping out.",
    },
    {"Buffer zone",
        "above super invisible disappear",
        "term",
        "Refers to 21st-40th lines above the visible field. Because the blocks in the field could go over the visible field (this usually happens when multiple garbage lines come in) so the buffer zone was created so those blocks could go back to the field when garbage lines are cleared. Also, the buffer zone is usually located at 21st-40th lines because this is sufficient for most cases. Refer to “Vanish Zone” to learn more.",
    },
    {"Vanish zone",
        "disappear gone cut die",
        "term",
        "Refers to the area located above the 40th line. This is usually realized by combining c4w and multiple garbage lines. When any block reaches the vanish zone in many games, the game is terminated immediately.\nHowever, this area can have different behaviors in different games. Some games are flawed because the game could crash when the blocks enter the vanish zone (e.g., Tetris Online). Wierd behaviors could also happen when the blocks enter the vanish zone (you can refer to this video, click on the globe icon to open the link).\n\nFurthermore, the vanish zone in Jstris is located above the 22nd line, and any blocks locked above the 21st line will disappear.",
        "https://youtu.be/z4WtWISkrdU",
    },
    {"Falling speed",
        "fallingspeed gravity",
        "term",
        "Falling speed is often described as “G,” i.e., how many lines the blocks fall in one frame (usually assuming 60 fps).\nG is a relatively large unit. The speed of Lv 1 in a regular Marathon (one second per line) is 1/60 G, and 1G is about Lv 13 speed. The highest speed of modern Tetris is 20G because the field height is 20 lines. The real meaning of 20G is “Infinite falling speed,” and even when the field height is more than 20 lines, 20G modes force all the blocks to fall to the bottom instantly. You can learn more about 20G at the “20G” entry\nIn Techmino, falling speed is described as the frames it takes for a block to fall one unit; for example, a speed of 60 refers to one unit per second (as the game runs in 60 fps as default).",
    },
    {"20G",
        "gravity instant",
        "term",
        "The fastest falling speed of modern Tetris. In 20G modes, pieces appear instantly on the bottom of the field without the actual process of falling. This sometimes also limits a piece’s sideways movements, as it is not always possible to make a piece climb over a bump or out of a well in 20G. You can learn more at the unit “G” at the “falling speed” entry.",
    },
    {"Lockdown Delay",
        "lockdelay lockdowndelay lockdowntimer",
        "term",
        "The delay between block touching the ground and locking down (i.e., can no longer be controlled, and the next piece spawns).\nModern Tetris games often have forgiving lockdown delay mechanics where you can reset this delay by moving or rotating (up to 15 times), and you can sometimes stall for time by doing this. Classic Tetris games often have a far less forgiving lockdown delay.",
    },
    {"ARE",
        "spawn appearance delay",
        "term",
        "Sometimes called the Entry Delay. ARE refers to the delay between the lockdown of one piece and the spawn of another piece.",
    },
    {"Line ARE",
        "appearance delay",
        "term",
        "The delay between the start of a line clear animation to the spawn of the next piece.",
    },
    {"Death ARE",
        "die delay dd",
        "term",
        "When an existing block blocks the spawn location of the next piece in the field, a delay will be added to the spawn ARE, referred to as the death ARE. This mechanism can be used along with IHS and IRS to prevent death. \nOriginal idea by NOT_A_ROBOT.",
    },
    {"Finesse",
        "finesse",
        "term",
        "A technique to move a piece into the desired position with the minimum number of key presses. This saves time and reduces chances to misdrop.\nYou can practice by playing with Jstris’s “restart on finesse error” or with Techmino’s finesse error sound effect.\n\nTechmino’s finesse detection is not precisely “theoretical minimum key presses,” but instead only checks for finesse against a pre-determined par keypress count *when the piece locks in a position that does not require soft dropping*. This means that Techmino will not judge a piece as having a finesse error when you soft drop and spin or tuck.\nTechmino also introduced additional checks, such as holding while the current piece and the held piece is the same, or holding after you have manipulated the current piece, count as a finesse fault.\nFinesse% in Techmino is defined to be 100% when par or below par, 50% when one keypress above par, 25% when two keypresses above par, and 0% when three or more keypresses above par.\nAlso note that in 20G finesse still runs as if there were no gravity, which can cause inaccurate results.",
    },
    {"‘Doing Research’",
        "scientificresearch",
        "term",
        "“Doing scientific research” is a term sometimes used in the Chinese Tetris community, referring to researching/practicing techniques in a low-falling-speed, single-player environment.",
    },
    {"Keymapping",
        "feel",
        "term",
        "Here're some general principles for configuring your controls.\n\n1. Avoid assigning one finger to multiple keys that you might want to press together - for example, you won't typically need to press the multiple rotation buttons together. Try assigning other buttons to one finger each.\n2. Unless you are confident with your pinky, probably avoid assigning it a button. Usually the pointer finger and middle finger are the most agile, but feel free to see how your own fingers perform.\n3. No need to copy someone else's key config. Every person is different; as long as you keep these ideas in mind, using a different key config should have minimal impact on your skills.",
    },
    {"Handling",
        "feel handling",
        "term",
        "Several main factors that may affect handling:\n(1) Input delay, which could be affected by device configuration or condition. Restart the game or change your device can probably fix it.\n(2) Unstable programming or faulty designs. It could be alleviated by lowering the effect settings.\n(3) Designed on purpose. Adaptation might help.\n(4) Improper parameter setting. Change the settings.\n(5) Improper play posture. It’s not convenient to use force. Change your posture.\n(6) Not being used to the operation after changing the key position or changing the device. Getting used to it or changing the settings might help.\n(7) Muscle fatigue, response, and decreases in coordination abilities. Have some rest and come back later or in a few days.",
    },
    {"DAS (simple)",
        "das arr delayedautoshift autorepeatrate",
        "term",
        "Imagine typing on a keyboard, where you press and hold the “O” key. \nYou get a long string of o’s.\nOn the timeline, it kinds of looks like o—————o-o-o-o-o-o-o-o-o…\nThe “—————” is DAS, the “-” is ARR.",
    },
    {"DAS & ARR",
        "das arr delayedautoshift autorepeatrate",
        "term",
        "DAS refers to Delayed Auto Shift, how blocks move to the side when you hold left or right. It also refers to the delay between the initial movement (when you press down the button) and the first automatic movement.\nARR refers to Auto-Repeat Rate, which is the delay between automatic movements. In some games, DAS and ARR are calculated using the unit f (frame). Multiply f by 16.7 (if you are running the game in 60 fps) to convert it to ms (millisecond).",
    },
    {"DAS tuning",
        "das tuning",
        "term",
        "For advanced players who want to play faster, the recommended values are DAS 4–6 f (67–100 ms), ARR 0 f (0 ms). (At 0 ms ARR, pieces will instantly snap to the wall once you get past DAS.)\n\nThe ideal configuration strategy for advanced players is to minimize DAS while still being able to reliably control whether to tap or hold, and to set to ARR to 0 if possible, or as low as possible otherwise.",
    },
    {"DAS cut",
        "dascut dcd",
        "term",
        "*Chỉ có trên Techmino* In Techmino, the DAS timer can be cleared or discharged for a short time when the player starts to control a new piece. This can reduce the case where a piece instantly starts moving if spawned with a direction button held.\n\nOther games may have a similar feature but may function differently.",
    },
    {"Auto-lock cut",
        "autolockcut mdcut",
        "term",
        "A feature designed to prevent mis-harddropping from pressing the hard drop key shortly after the last piece is naturally locked down.\nHard drop key can be disabled for a few frames (depending on the settings) after a natural lockdown.\n\nOther games may have a similar feature but may function differently.",
    },
    {"SDF",
        "softdropfactor",
        "term",
        "Soft Drop Factor\n\nA way to define soft drop speed as a multiple of natural falling speed. In guideline games, the soft drop is usually 20x the speed of natural falling, i.e., it has an SDF of 20. Techmino does not use SDF to define soft drop speed.",
    },
    {"Shape & Names",
        "mino",
        "term",
        "Here is a list of the all the blocks used by Techmino and their corresponding names:\nTetrominos:\nZ: "..CHAR.mino.Z..",  S: "..CHAR.mino.S..",  J: "..CHAR.mino.J..",  L: "..CHAR.mino.L..",  T: "..CHAR.mino.T..",  O: "..CHAR.mino.O..",  I: "..CHAR.mino.I..";\n\nPentominos:\nZ5: "..CHAR.mino.Z5..",  S5: "..CHAR.mino.S5..",  P: "..CHAR.mino.P..",  Q: "..CHAR.mino.Q..",  F: "..CHAR.mino.F..",  E: "..CHAR.mino.E..",  T5: "..CHAR.mino.T5..",  U: "..CHAR.mino.U..",  V: "..CHAR.mino.V..",  W: "..CHAR.mino.W..",  X: "..CHAR.mino.X..",  J5: "..CHAR.mino.J5..",  L5: "..CHAR.mino.L5..",  R: "..CHAR.mino.R..",  Y: "..CHAR.mino.Y..",  N: "..CHAR.mino.N..",  H: "..CHAR.mino.H..",  I5: "..CHAR.mino.I5..";\n\nTriminos, Domino, and Mino:\nI3: "..CHAR.mino.I3..",  C: "..CHAR.mino.C..",  I2: "..CHAR.mino.I2..",  O1: "..CHAR.mino.O1..".",
    },
    {"Bag7 generator",
        "bag7bag randomgenerator",
        "term",
        "Also known as “7-Bag Generator.” Officially known as “Random Generator.”\nThis is the algorithm used by modern, official Tetris games to generate pieces. Starting from the beginning of a game, there is guaranteed to be one of the seven Tetrominoes for every seven pieces.\n\nAn example would be like: ZSJLTOI OTSLZIJ LTISZOJ.",
    },
    {"His generator",
        "history hisgenerator",
        "term",
        "A way to generate pieces, notably used in Tetris: The Grand Master games. Every time a random Tetromino is selected, but if this Tetromino is the same as one of the few previous pieces, then reroll until a different piece is rolled or until a reroll limit is reached.\nFor example, a “his 4 roll 6” (h4r6) generator rerolls when the piece is the same as one of the four previous pieces and rerolls up to 6 times.\nThere are other variations as well, such as “his4 roll6 pool35,” which further reduces the randomness of the piece sequence.\n\nIn Techmino, the maximum reroll count is half of the sequence length, rounded up.",
    },
    {"HisPool generator",
        "hisPool history pool",
        "term",
        "History Pool, a generator based on the His generator. It introduced a mechanism called “Pool.” When generating a new piece, HisPool randomly selects a piece from the Pool and increases the probability of spawning the least frequent piece.\n\nThis mechanism makes the sequence more stable and ensures that the drought won’t last forever.",
    },
    {"bagES generator",
        "bages easy start",
        "term",
        "*Chỉ có trên Techmino*\nBag Easy-Start, an improved Bag generator. The first piece in the first bag won’t be those hard-to-place pieces (S/Z/O/S5/Z5/F/E/W/X/N/H).",
    },
    {"Reverb generator",
        "reverb",
        "term",
        "*Chỉ có trên Techmino*\nA generator derived from Bag. The Reverb generator repeats each piece several times based on the Bag generator. The probability of repetition decreases when a certain piece repeats too frequently and vice versa.",
    },
    {"Hypertapping",
        "hypertapping",
        "term",
        "Refers to the technique of vibrating your finger on the controller to achieve faster sideways movement speed than holding it.\nIt is most commonly used on classic Tetris where DAS is relatively slow. In most cases, you do not need to hypertap in modern Tetris games because their DAS is usually fast enough.",
    },
    {"Rolling",
        "rolling",
        "term",
        "Another method of fast-tapping in high-gravity (around 1G) modes (with slow DAS/ARR setting).\nWhen you perform rolling, you fix the position of one hand and the controller, and then tap the back of the controller with fingers on your other hand repeatedly. This method allows even faster speeds than hypertapping (see “Hypertapping” for more) and requires much less effort.\nThis method was first discovered by Cheez-fish, and he has once achieved a tapping speed of more than 20 Hz.",
    },
    {"Passthrough",
        "pingthrough",
        "term",
        "Refers to a situation where the attacks from both players were sent to the other player’s board without canceling out. Another term called “pingthrough” refers to a situation where a passthrough occurs due to Internet delays.",
    },
    {"Tetris OL attack",
        "top tetrisonlineattack",
        "term",
        "Single/Double/Triple/Tetris sends 0/1/2/4 attack(s).\nT-Spin Single/Double/Triple sends 2/4/6, half if Mini.\nCombo send 0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 5.\nBack to Back sends extra 1 (or 2 if T-Spin Triple).\nAll Clear sends extra 6 lines. This extra 6 lines will be sent to opponents directly, and does not cancel the buffered incoming damage.",
    },
    {"Techmino attack",
        "techminoattack",
        "term",
        "Check the user manual on the bottom right corner of the homepage for more information.",
    },
    {"C2 Generator",
        "cultris2generator cultrisiigenerator c2generator",
        "term",
        "All Tetrominoes have an initial weight of 0.\nEvery time, divide all weights by 2, add a random number between 0 and 1, pick the piece with the highest weight, and divide this piece’s weight by 3.5.",
    },
    {"Stacking",
        "stacking",
        "term",
        "Often refers to stacking Tetrominoes without leaving holes. An essential skill.",
    },
    {"Rotation buttons (1/2)",
        "doublerotation",
        "term",
        "Using both clockwise and counter-clockwise rotation buttons reduces the number of key presses by replacing three rotation presses with one press of the opposite direction.\nFinesse assumes the use of both rotation buttons.",
    },
    {"Rotation buttons (2/2)",
        "triplerotation",
        "term",
        "Using all three rotation buttons (the third being 180° rotation), any piece only requires one rotation press to reach the desired direction.\nHowever, it is not exactly useful for not every game has this feature, and the speed increase from learning this technique is not as much as when you learn using both rotation buttons as opposed to one. You can skip this technique unless you want extreme speeds.",
    },
    {"Drought",
        "drought",
        "term",
        "A situation where a piece you want, often the I Tetromino (a.k.a. the Long Bar), does not spawn for a long time. This often happens and can be deadly for classic Tetris, but it is almost impossible for modern Tetris thanks to the Random Generator.\nWith the Random Generator, there can be at most 12 other pieces between two I Tetrominoes.",
    },
    {"Bone block",
        "bone tgm",
        "term",
        "The block skin used by the earliest version of Tetris.\nIn earlier times, computers all used the Command-Line Interfaces (like cmd on Windows, Terminal on Mac, or Console on Linux), so a single mino in the game Tetris is represented using two enclosing square brackets [ ]. It looks like bones, so it is sometimes called bone blocks.\nIn Techmino, bone blocks are defined as “a single, fancy block skin that all of the blocks use.” Different block skins may have different types of bone block styles.",
    },
    {"Semi-invisible",
        "half invisible semi",
        "term",
        "Refers to a rule where the tetrominoes will become invisible after some time.\nThis time interval is not definite, and it is acceptable to describe it as “disappear after a few seconds.”",
    },
    {"Invisible",
        "invisible",
        "term",
        "Refers to a rule where blocks will disappear instantly when locked onto the field. \nN.B. It is also acceptable to refer to an invisible mode where a disappearing animation is shown. However, this makes the game a lot easier, so in Techmino, the invisible mode without such animations is referred to as “Sudden Invisible.”",
    },
    {"MPH mode",
        "mph",
        "term",
        "Memoryless (random spawn), Previewless (no next queue), Holdless. A mode that requires quite some reaction speed.",
    },
    {"Input delay",
        "input delay",
        "term",
        "Any input device takes some time for the input to reach the game. This delay can range from a few ms to a few dozen ms.\nIf input delay is too long, the controls can feel uncomfortable.\nThis delay is often due to the performance of the hardware and software used, which is often something out of your control. Turn on performance mode (or turn off power saving mode) on your device, and turn on gaming mode on your monitor/TV (if you have one), which may help reduce input delay.",
    },
    {"Secret Grade",
        "larger than",
        "term",
        "An easter egg mode from the TGM series. During a “secret grade” gameplay, the player tries to make a “>” shape with one hole in each line using blocks. The ultimate goal is to finish the whole shape using 19 lines.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=Secret_Grade_Techniques",
    },
    {"Cold Clear",
        "cc coldclear ai bot",
        "term",
        "A Tetris bot. \nDeveloped by MinusKelvin originally for Puyo Puyo tetris. The Cold Clear build in Techmino supports all-spin and TRS.",
    },
    {"ZZZbot",
        "ai bot zzztoj",
        "term",
        "A Tetris bot. Built by the Chinese Tetris player 奏之章 (Zòu Zhī Zhāng, see entry below) and has decent performance in many games",
    },
    -- # Setups
    {"Openers",
        "setup openers",
        "setup",
        "Openers are setups that can be built when a game begins. You can still make these setups mid-game, but will often require a different set of piece placements.\n\nGood setups usually satisfy two to three of the following:\n- Can adapt to many piece orders,\n- Strong attack, minimal waste of the T piece,\n- Require minimal soft dropping for faster placement and using finesse,\n- Has clear follow-up strategies with few branches.\n\nMost openers make use of the Random Generator (bag-7 generator) and exploit the fact that it gives one of every piece for every seven pieces. This element of predictability makes it possible to have reliable setups.",
    },
    {"DT Cannon",
        "dtcannon doubletriplecannon",
        "setup",
        "Double-Triple Cannon.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=dt",
    },
    {"DTPC",
        "dtcannon doubletriplecannon",
        "setup",
        "A follow-up of the DT Cannon that ends with an All Clear.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=dt",
    },
    {"BT Cannon",
        "btcannon betacannon",
        "setup",
        "β Cannon, Beta Cannon.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=bt_cannon",
    },
    {"BTPC",
        "btcannon betacannon",
        "setup",
        "A follow-up of the BT Cannon that ends with an All Clear.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=bt_cannon",
    },
    {"TKI 3 Perfect Clear",
        "ddpc tki3perfectclear",
        "setup",
        "A TSD opener that leads to a Double-Double-All Clear.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=TKI_3_Perfect_Clear",
    },
    {"QT Cannon",
        "qtcannon",
        "setup",
        "A DT Cannon-like setup with a higher probability of sending a DT Attack.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=QT_cannon",
    },
    {"Mini-Triple",
        "mt minitriple",
        "setup",
        "A Mini T-Spin - T-Spin Triple structure.",
        "https://harddrop.com/wiki?search=mt",
    },
    {"Trinity",
        "trinity",
        "setup",
        "A TSD + TSD + TSD or TSMS + TST+ TSD setup.",
        "https://harddrop.com/wiki?search=trinity",
    },
    {"Wolfmoon Cannon",
        "wolfmooncannon",
        "setup",
        "An opener.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=wolfmoon_cannon",
    },
    {"Sewer",
        "sewer",
        "setup",
        "An opener.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=sewer",
    },
    {"TKI",
        "tki-3 tki3",
        "setup",
        "TKI-3. It can either refer to a TKI-3 starting with a TSD or a C-spin starting with a TST.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=tki_3_opening",
    },
    {"God Spin",
        "godspin",
        "setup",
        "A setup that is fancy on the eyes [but awkward to use in action]. Invented by Windkey.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=godspin",
    },
    {"Albatross",
        "albatross",
        "setup",
        "A fancy, fast-paced opener with TSD–TST–TSD–All Clear, hardly wasting any T pieces.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=Albatross_Special",
    },
    {"Pelican",
        "",
        "setup",
        "An Albatross-ish opener to use when the piece orders do not support that.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=Pelican",
    },
    {"Perfect Clear Opener",
        "7piecepuzzle",
        "setup",
        "An All Clear opener with a high success rate (~84.6% when you have an I in the Hold queue and ~61.2% if that’s not the case). In Techmino’s PC Practice modes, the setup that leaves an irregular opening is this setup.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=Perfect_Clear_Opener",
    },
    {"Grace System",
        "liuqiaoban gracesystem 1stpc",
        "setup",
        "A PC opener with a success rate of ~88.57%. The 4×4 square in the PC challenge is this setup.",
        "https://four.lol/perfect-clears/grace-system",
    },
    {"DPC",
        "DPC",
        "setup",
        "An almost 100% TSD + PC setup with no blocks in the field and the last block of 7-bag in the next queue. More information on tetristemplate.info.",
        "https://tetristemplate.info/dpc/",
    },
    {"Gamushiro Stacking",
        "gamushiro",
        "setup",
        "(ガムシロ積み) A TD-Attack opener.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=Gamushiro_Stacking",
    },
    -- # Pattern
    {"Mid-game Setups",
        "midgamesetups",
        "pattern",
        "Refers to some setups usually used to send a lot of garbage mid-game. Some of them can also be openers, though it is usually unnecessary.",
    },
    {"C-spin",
        "cspin",
        "pattern",
        "A T-Spin Triple + T-Spin Double attack, known as TKI in Japan.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=c-spin",
    },
    {"STSD",
        "stsd",
        "pattern",
        "Super T-Spin Double, a setup that allows two T-Spin Doubles.\nBut when the garbage is right under the STSD cave, it is impossible to perform two TSDs.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=stsd",
    },
    {"STMB Cave",
        "stmb",
        "pattern",
        "STMB cave, a donation setup by using S/Z to block off a 3-wide well and clear a T-Spin Double.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=stmb_cave",
    },
    {"Fractal",
        "shuangrenjian fractal spider",
        "pattern",
        "A setup involving overlapping two TSD setups.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=Fractal",
    },
    {"LST stacking",
        "lst",
        "pattern",
        "An infinite T-Spin Double setup.",
        "https://four.lol/stacking/lst",
    },
    {"Hamburger",
        "hamburger",
        "pattern",
        "A donation setup that opens up for Tetrises.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=hamburger",
    },
    {"Imperial Cross",
        "imperialcross",
        "pattern",
        "Covering a cross-shaped hole with an overhang to do two T-Spin Doubles.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=imperial_cross",
    },
    {"Kaidan",
        "jieti kaidan stairs",
        "pattern",
        "A setup that can donate a TSD on a stair-looking terrain.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=kaidan",
    },
    {"Shachiku Train",
        "shachikutrain shechu",
        "pattern",
        "A setup that can donate two TSDs on a TST setup.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=Shachiku_Train",
    },
    {"Cut Copy",
        "qianniao cutcopy",
        "pattern",
        "A setup to donate a T-Spin Double over a small hole and can do another T-Spin Double after that.",
    },
    {"King Crimson",
        "kingcrimson",
        "pattern",
        "Stacking TST(s) on top of a STSD.\nFor more information, please visit Hard Drop Wiki. Click on the globe icon to open the link.",
        "https://harddrop.com/wiki?search=King_Crimson",
    },
    {"Consecutive PCs (1/3)",
        "pcloop",
        "pattern",
        "You can find detailed guides on “Tetris Hall” about 1st–4th and 7th PC. After you finish the 7th PC, exactly 70 blocks are used so you can go back to the 1st PC.",
        "https://shiwehi.com/tetris/template/consecutivepc.php",
    },
    {"Consecutive PCs (2/3)",
        "pcloop",
        "pattern",
        "four.lol has guides on 5th and 6th PC.",
        "https://four.lol/perfect-clears/5th",
    },
    {"Consecutive PCs (2/3)",
        "pcloop",
        "pattern",
        "A complete PC-loop tutorial written by NitenTeria.",
        "https://docs.qq.com/sheet/DRmxvWmt3SWxwS2tV",
    },
    -- # Savedata managing
    {"Console",
        "cmd commamd minglinghang kongzhitai terminal",
        "command",
        "Techmino has a console that enables debugging/advanced features.\nTo access the console, repeatedly tap (or click) the Techmino logo or press the C key on the keyboard on the main menu.\n\nCareless actions in the console may result in corrupting or losing saved data. Proceed at your own risk.",
    },
    {"Reset setting",
        "reset setting",
        "command",
        "Go to console, type “rm conf/setting” and then press enter/return.\nRestart Techmino for this to take effect.\nTo revert this action, enter Settings then go back out.",
    },
    {"Reset statistics",
        "reset statistic data",
        "command",
        "Go to console, type “rm conf/data” and then press enter/return.\nRestart Techmino for this to take effect.\nTo revert this action, play one game and reach a game over or win screen.",
    },
    {"Reset unlock",
        "reset unlock",
        "command",
        "Go to console, type “rm conf/unlock” and then press enter/return.\nRestart Techmino for this to take effect.\nTo revert this action, update any mode's status on the map.",
    },
    {"Reset records",
        "reset record",
        "command",
        "Go to console, type “rm -s record” and then press enter/return.\nRestart Techmino for this to take effect.\nYou can revert this action on an individual-mode basis; play one game and have its leaderboards updated to recover that mode's leaderboards.",
    },
    {"Reset key",
        "reset virtualkey",
        "command",
        "Go to console, type “rm conf/[keyFile]” and then press enter/return.\nKeyboard: key, Virtualkey: virtualkey, Virtualkey save: vkSave1(2)\nRestart Techmino for the first two settings to take effect.\nEnter corresponding settings page and go back to get one file back.",
    },
    {"Delete replays",
        "delete recording",
        "command",
        "Go to console, type “rm -s replay“ and then press enter/return.\nTakes effect immediately.",
    },
    {"Delete cache",
        "delete cache",
        "command",
        "Go to console, type “rm -s cache” and then press enter/return.\nTakes effect immediately.",
    },
    -- # English
    {"SFX",
        "soundeffects",
        "english",
        "Acronym for “Sound Effects.” Also abbrevated as “SE” in Japan.",
    },
    {"BGM",
        "backgroundmusic",
        "english",
        "Acronym for “Background Music.”",
    },
    {"TAS",
        "tas",
        "english",
        "Acronym for “Tool-Assisted Speedrun (Superplay).”\nPlay a game with special tools without breaking the game’s rules (at the programming level).\nIt is generally used to get theoretical maximum scores or achieve interesting goals.\nA lightweight TAS tool is built into Techmino.",
    },
    {"AFK",
        "afk",
        "english",
        "Acronym for “Away From Keyboard,” or in a broader sense, a period when you are not playing.\nTaking regular breaks help relieve your muscle strain and allow you to play better when you come back.",
    },
}
