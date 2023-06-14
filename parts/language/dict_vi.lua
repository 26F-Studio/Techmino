-- Toàn bộ nội dung này được sao chép y nguyên từ dict_en.lua
-- Và file này được sửa bằng tay, không dùng tool của User670: https://github.com/user670/techmino-dictionary-converter/blob/master/tool.py

platform_restriction_text = "Nội dung của mục này đã bị ẩn đi do yêu cầu của nền tảng. Nhưng bạn vẫn có thể hỏi về nội dung này trong server Discord của chúng tôi."

return {
    {
        "Giới thiệu bản dịch",
        "nhom1",
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
    {
        "Cách tìm kiếm",
        "nhom1",
        "help",
        [[
Có thể tìm một mục bằng cách gõ một phần hoặc toàn bộ tiêu đề

Nếu bạn muốn lọc theo nhóm, đầu tiên hãy mở Mục lục, sau đó thì tìm tới nhóm bạn cần. Lấy số ở đầu tiêu đề rồi gõ trên thanh tìm kiếm với cú pháp: "nhom<n>"
Ví dụ: nếu muốn lọc các mục trong nhóm "Các game xếp gạch", hãy gõ vào thanh tìm kiếm cú pháp "nhom6" để lọc và xem các game.
        ]]
    },
    {
        "Mục lục [1/_]", --TODO: make index
        "mucluc",
        "help",
        [[
1. Về Zictionary
        - Giới thiệu bản dịch
        - Cách tìm kiếm trong Zictionary
2. Mục lục                  <-- bạn đang xem cái này
3. Dự án Techmino
        - Trang web chính thức
        - Dự án trên GitHub
4. Ủng hộ cho tác giả của Techmino
        ]]
    },
    {
        "Mục lục [2/_]", --TODO: make index
        "mucluc",
        "help",
        [[
5. Tetris và các thuật ngữ
        5A. Tetris hiện đại
            * Next
            * Hold, Swap
            * Topping out
            * Vùng đệm
            * Vùng biến mất
        5B. Gạch
            * Hình dạng, màu, hướng của gạch
            * Gạch & tên tương ứng
        5C. Hệ thống xoay gạch: ARS, ASC, ASC+, BRS, BiRS, C2RS, C2sym, NRS, SRS, SRS+, TRS, XRS
        5D. Hệ thống điều khiển: IRS, IHS, IMS
        5E. Cách kiểu xáo gạch: Túi 7 gạch, His, EZ-Start, Reverb, C2
        5F. Vấn đề của một số kiểu xáo gạchL: Drought & Flood

[…] (Phần cuối của mục này ở trang 5)
        ]]
    },
    {
        "Mục lục [3/_]", --TODO: make index
        "mucluc",
        "help",
        [[
[…] (Tiếp tục từ trang 2 | Phần đầu tiên của mục này nằm ở trang 2)
        5G. Thông số
            5G1. Thông số của game
                * Tốc độ rơi, 20G
                * Lockdown Delay, Spawn & Clear delay
                * ARE, Line ARE, Death ARE
            5G2. Thông số điều khiển
                * DAS & ARR, DAS cut, Hiệu chỉnh DAS
                * Auto-lock cut, SDF
        5H. Điều khiển
            5H1. Tốc độ: LPM, PPS, BPM, KPM
            5H2. Kỹ thuật: Hypertapping, Rolling, Finesse
            5H3. Độ trễ đầu vào
[…] (Phần cuối của mục này ở trang 5)
        ]]
    },
    {
        "Mục lục [4/_]", --TODO: make index
        "mucluc",
        "help",
        [[
[…] (Tiếp tục từ trang 3 | Phần đầu tiên của mục này nằm ở trang 2)
        5I. Khả năng tấn công
            * APM, SPM, DPM, RPM, ADPM, APL
            * Tấn công & Phòng thủ
            * Combo, Spike
            * Dept
            * Passthrough
        5J. Hành động bất cẩn (Mis-): Misdrop, Mishold
        5K. Spin
            * (Mini)/(All-)/(T-)/(O-) spin
            * Fin, Neo, Iso
        5L: Kỹ thuật xóa hàng:
            * Single, Double, Triple, Techrash, Tetris
            * Perfect Clear, Half Perfect Clear
            * TSS, TSD, TST, MTSS, MSTSD
[…] (Phần cuối của mục này ở trang 5)
        ]]
    },
    {
        "Mục lục [5/_]", --TODO: make index
        "mucluc",
        "help",
        [[
[…] (Tiếp tục từ trang 3 | Phần đầu tiên của mục này nằm ở trang 2)
        5M. Các thuật ngữ khác: sub, 'Doing Research', Bone block
6. Các game xếp gạch
        (Danh sách dài, bạn hãy gõ trên thanh tìm kiếm "nhom6" để xem danh sách đầy đủ ở cột danh sách bên trái)
7. Một vài cơ chế và chế độ của một số game
        - Tàng hình một phần/hoàn toàn
        - Chế độ MPH
        - Secert Grade
        - Deepdrop
8. Bot: Cold Clear, ZZZbot
        ]]
    },
    {
        "Mục lục [6/_]", --TODO: make index
        "mucluc",
        "help",
        [[
9. Mẹo và lời khuyên hữu ích
        - Đề xuất luyện tập
        - Học làm T-spin
        - Hiệu chỉnh DAS
        - Bố cục phím
        - Khả năng xử lý gạch
        - Các phím xoay
10. Wiki; các trang web bày setup & cung cấp câu đố, chia sẻ setup
        10A. Wiki: Huiji Wiki, Hard Drop Wiki, tetris.wiki, Tetris Wiki Fandom
        10B. Bày setup: Four.lol, Tetris Hall, Tetris Template Collections, tetristemplate.info
        10C. Chia sẻ câu đố: TTT, TTPC, NAZO, TPO
        10D. Chia sẻ setup: Fumen, Fumen bản Điện thoại
11. Cộng đồng
        - Tetris Online Servers
        - Tetris Việt Nam
        - VTT (this item may not be existed)
        ]]
    },
    {
        "Mục lục [7/_]", --TODO: make index
        "mucluc",
        "help",
        [[
12. Xếp lên và đào xuống
        12A. Stacking --> Stacking (Xếp lên)
            * Side/Center/Partial well
            * Side/Center 1/2/3/4-wide
            * Residual
            * 6-3 Stacking
        12B. Digging (Đào xuống)
13. Setup (Opener, Mid-game setup, Donation, Spin related)
        13A. Freestyle
        13B. Donation
        13C. Opener: DT Cannon, DTPC, BT Cannon, BTPC, TKI 3 Perfect Clear, QT Cannon, Mini-Triple, Trinity, Wolfmoon Cannon, Sewer, TKI, God Spin, Albatross, Pelican, Perrfect Clear Opener, Grace System, DPC, Gamushiro Stacking
        13D. Mid-game: C-spin, STSD, STMB Cave, Fractal, LST stacking, Hamburger, Imperial Cross, Kaidan, Shachiku Train, Cut Copy, King Crimson, PC liên tiếp (1+2+3)
14. Cách tính tấn công: Tetris OL attack, Techmino attack
        ]]
    },
    {
        "Mục lục [8/_]", --TODO: make index
        "mucluc",
        "help",
        [[
15. Console và chuyện quản lý dữ liệu game
        - Console
        - Đặt lại thiết lập, tình trạng mở khóa, bố cục phím
        - Xóa toàn bộ thành tích, kỷ lục, bản phát lại, bộ nhớ đệm
16. Các thuật ngữ không liên quan gì tới Tetris (tiếng Anh): SFX, BGM, TAS, AFK
17. Phụ lục
        ]]
    }
}
