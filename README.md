# ha1-s-claude-code

Plugin [Claude Code](https://claude.com/claude-code) cá nhân: năm skill lo bàn giao
phiên, điều khiển terminal, thiết kế tính năng, art direction cho UI và biên tập
văn bản, hai agent chạy cô lập cho hai việc tốn context nhất, kèm một MCP server
trình duyệt để kiểm chứng bằng mắt.

Plugin cố ý giữ nhỏ. Mỗi skill ở đây đều đã dùng cho việc thật; thứ nào không qua
được đợt rà soát thì bỏ hẳn.

## Nội dung

| Thành phần | Làm gì |
|---|---|
| [`handoff`](#handoff) | Viết bản giao việc để một phiên mới làm tiếp mà không phải dò lại từ đầu. Lưu vào kho, và giao thẳng cho pane Herdr mới khi có. |
| [`herdr`](#herdr) | Điều khiển Herdr, trình quản lý không gian terminal cho AI coding agent: pane, tab, workspace, vòng đời agent, và giao việc giữa các agent. |
| [`brainstorming`](#brainstorming) | Bắt thiết kế trước khi code tính năng mới: hỏi từng câu một, 2–3 phương án kèm đánh đổi, chốt bằng spec được duyệt. |
| [`design-taste`](#design-taste) | Giữ UI do model dựng khỏi lộ dấu vết máy móc: tìm một mẫu do designer thật làm, rút design DNA về project, rồi đối chiếu bản build bằng screenshot. |
| [`humanizer`](#humanizer) | Viết lại văn bản nghe giống AI thành giọng người, giữ nguyên nội dung. Vendor từ [blader/humanizer](https://github.com/blader/humanizer). |
| [`agents/`](#agent) | Hai subagent bọc `design-taste` và `humanizer` để phần việc nặng context chạy ở nơi khác. |
| `.mcp.json` | Khai báo sẵn [Playwright MCP server](https://github.com/microsoft/playwright-mcp) để skill lái được trình duyệt thật. |

## Yêu cầu

| Thành phần | Cần cho | Ghi chú |
|---|---|---|
| Claude Code | tất cả | |
| Node.js ≥ 18 | Playwright MCP | chạy qua `npx`, không phải cài trước |
| `herdr` | skill `herdr` | skill tự dừng khi thiếu `HERDR_ENV=1`, nên máy không có Herdr vẫn dùng plugin bình thường |
| `wl-copy` hoặc `xclip` | `handoff` copy clipboard | tuỳ chọn; thiếu thì brief được in ra để copy tay |

## Cài đặt

```
/plugin marketplace add ha1hddk/ha1-s-claude-code
/plugin install ha1-s-claude-code
```

Muốn sửa chính plugin này thì trỏ marketplace vào bản checkout dưới máy, khi đó sửa
file là có hiệu lực ngay, khỏi push:

```
git clone git@github.com:ha1hddk/ha1-s-claude-code.git
```
```
/plugin marketplace add /path/to/ha1-s-claude-code
/plugin install ha1-s-claude-code
```

Hai cách cùng đăng ký một marketplace tên `ha1-s-claude-code` nên chỉ chạy được một
cách tại một thời điểm. Đổi qua lại bằng `/plugin marketplace remove ha1-s-claude-code`
rồi add cách kia.

## Các skill

### handoff

Sinh một bản giao việc tự chứa cho phiên kế tiếp. Bản này mở đầu bằng hành động cần
làm ngay, viết đủ chính xác để thực thi mà không cần hỏi lại, rồi tới danh sách
những gì phiên sau khỏi phải điều tra lại.

| Lệnh | Hành vi |
|---|---|
| `/handoff` | Viết, lưu, rồi giao cho pane Herdr nếu đang chạy trong Herdr, còn lại thì copy vào clipboard |
| `/handoff save [tên]` | Chỉ viết và lưu |
| `/handoff here` | Viết, lưu, copy; không giao cho pane nào |
| `/handoff list` | Liệt kê brief đã lưu |
| `/handoff resume [tên]` | Nạp brief đã lưu, kiểm tra xem còn hợp thời không, rồi làm theo |

Brief nằm ở `~/.claude/handoffs/YYYY-MM-DD-<slug>.md`. Skill luôn ghi file trước khi
thử giao việc, nên lúc giao hỏng thì vẫn còn đường cứu. Trước khi giao, skill đọc lại
cây làm việc để phiên sau khỏi làm lại phần đã xong.

### herdr

Điều khiển một phiên Herdr đang chạy qua CLI của nó: quản lý pane, tab, workspace,
khởi động agent và lệnh thường trong pane, đọc output, chờ trạng thái đổi.

Đường giao việc của skill đi qua cơ chế nhắn tin giữa các phiên. Skill khởi động một
agent Claude Code ở pane mới, xác định tên phiên đó bằng cách so danh sách peer
trước và sau khi spawn, rồi gửi tin nhắn trỏ tới file handoff đã lưu. Gõ prompt thẳng
vào TUI của agent khác thì mất trắng nếu agent còn đang khởi động, và dấu nháy hay
xuống dòng dễ vỡ; nhắn tin thì xác nhận được đã tới nơi, và lúc agent xong sẽ có
thông báo, khỏi hỏi dò.

Ngoài Herdr skill nằm im: nó kiểm tra `HERDR_ENV=1` và dừng nếu biến chưa được đặt.

### brainstorming

Dành cho tính năng mới. Sửa nhỏ, sửa bug và refactor cứ làm bình thường.

Trình tự: đọc pattern sẵn có của project, hỏi làm rõ từng câu một (mục đích, ràng
buộc, tiêu chí thành công), đưa hai hoặc ba phương án kèm đánh đổi và khuyến nghị,
trình bày thiết kế theo từng phần và chốt sau mỗi phần, rồi viết spec vào
`docs/specs/YYYY-MM-DD-<topic>-design.md` và tự soi lại spec xem có chỗ bỏ ngỏ, mâu
thuẫn hay phình phạm vi trước khi đưa user duyệt.

Chỉnh từ [obra/superpowers](https://github.com/obra/superpowers); bản gốc để nguyên
cạnh đó ở `SKILL.upstream.md`.

### design-taste

Giải quyết một lỗi cụ thể: model được giao dựng UI thì cho ra thứ đúng kỹ thuật mà
nhìn phát biết ngay là máy làm. Tiền đề của skill là không tin gu thẩm mỹ của chính
agent, nên nó làm việc từ một mẫu có thật.

1. Repo đã có `design/DIRECTION.md` thì đọc và tuân theo, không nghĩ lại từ đầu.
2. Chưa có thì hỏi user một mẫu, hoặc tự đề xuất ứng viên theo danh mục xếp hạng:
   ưu tiên template mã nguồn mở có sẵn source của theme (Creative Tim, tremor,
   daisyUI, shadcn themes, Flowbite), rồi tới design system có tài liệu (Primer,
   Polaris, Carbon, Radix), rồi site thật mà user thích, cuối cùng là ảnh cảm hứng
   thuần tuý, ở mức này mọi giá trị rút ra đều phải đánh dấu là phỏng đoán.
3. Rút design DNA của mẫu về `design/DIRECTION.md`: token, type scale, cách xử lý
   bề mặt, kỷ luật dùng màu nhấn.
4. Dựng bố cục. Phần này là đóng góp của agent.
5. Code xong thì chụp ở 1440/768/375 cho cả sáng lẫn tối, đặt bản render cạnh mẫu,
   rồi phân loại chỗ lệch theo mức độ.

Skill còn mang một danh sách cấm các mặc định mà model hay với tay tới: font Inter và
Roboto làm mặt chữ chính, gradient tím-chàm trên nền trắng, hero chữ gradient, emoji
làm icon, `#000`/`#fff` nguyên chất, xám không pha, số liệu bịa, và các dấu hiệu quen
thuộc của câu chữ do máy viết.

### humanizer

Biên tập văn bản nghe giống máy viết. Skill làm việc theo 25 dấu hiệu lấy từ bài
["Signs of AI writing"](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
của Wikipedia, chia thành năm nhóm (dàn cảnh, nhịp điệu theo công thức, thổi phồng,
định dạng máy móc, và rác còn sót từ chat), xếp theo độ mạnh: năm dấu hiệu đầu chỉ
cần thấy một lần là đủ lý do sửa, còn dấu hiệu gắn nhãn *weak alone* phải có dấu hiệu
khác trong cùng đoạn mới được động vào.

Hai ràng buộc đáng chú ý. Thứ nhất, cấm bịa: không một dữ kiện, tên, con số, ngày,
trích dẫn hay nguồn nào được phép xuất hiện nếu nó không đến từ văn bản gốc hoặc từ
user, nên bản viết lại không thể mua sự trôi chảy bằng chi tiết tự nghĩ ra. Thứ hai,
mục "When not to act" bảo vệ những lựa chọn có chủ ý của người viết: cụm từ nằm trong
trích dẫn, tiêu đề hay tên riêng thì để yên, và văn bản có trước 30/11/2022 thì không
thể do AI viết.

Ba chế độ trả về: trả bản nháp kèm danh sách dấu hiệu còn sót; sửa trực tiếp một file
được chỉ định, chỉ đụng văn xuôi và giữ nguyên code block, lệnh, đường dẫn, YAML và
link target; hoặc chỉ trả văn bản cuối khi một task khác gọi nó để viết commit
message hay mô tả pull request. Đưa cho nó một mẫu văn của bạn thì nó bám theo giọng
đó, và mẫu được ưu tiên hơn danh sách dấu hiệu.

Vendor nguyên bản ở version 3.0.0; xem `skills/humanizer/UPSTREAM.md` để biết commit
đã ghim và cách cập nhật.

## MCP server

`.mcp.json` khai báo một server stdio tên `playwright`, chạy bằng
`npx -y @playwright/mcp@latest`. Nó cấp trình duyệt thật cho vòng kiểm chứng của
`design-taste`, và task nào cần trình duyệt cũng dùng được.

## Agent

Hai skill có phiên bản subagent ở `agents/`. Lý do là chi phí context. Vòng kiểm
chứng của `design-taste` chụp ảnh ở ba bề ngang nhân hai theme, còn `humanizer` phải
đọc trọn 374 dòng `SKILL.md` cộng toàn bộ văn bản gốc rồi mới ra được một bản nháp.
Chạy cô lập thì những thứ đó nằm lại bên trong agent, phiên gọi chỉ nhận kết quả.

| Agent | Nhận vào | Trả về |
|---|---|---|
| `design-taste` | Hướng thiết kế đã chốt: repo có `design/DIRECTION.md`, hoặc người gọi chỉ đích danh mẫu | File đã đổi, kết quả triage của vòng verify, nguồn gốc hướng thiết kế |
| `humanizer` | Đoạn văn hoặc tên file, kèm mẫu giọng văn nếu có | Văn bản cuối, danh sách pattern đã sửa, chỗ cố ý giữ nguyên |

Cả hai đều đọc `SKILL.md` tương ứng làm nguồn chuẩn thay vì chép lại luật, nên sửa
skill là agent đổi theo.

Có một giới hạn chung cần biết: subagent không hỏi user được, mà cả hai skill đều có
bước cần hỏi. Hai file agent xử lý khác nhau vì mức thiệt hại khác nhau.

- `design-taste` gặp trường hợp repo chưa có `design/DIRECTION.md` và người gọi cũng
  không đưa mẫu thì **dừng và báo lại**, kèm hai ba ứng viên để user chọn. Agent tự
  chọn hướng thiết kế đúng là cái lỗi mà skill sinh ra để ngăn, và hướng đó sẽ bị ghi
  vào `DIRECTION.md` cho mọi việc sau kế thừa.
- `humanizer` gặp câu thiếu dữ kiện thì viết câu đơn giản hơn rồi ghi vào báo cáo là
  đã thiếu gì, đúng như luật cấm bịa của skill.

## Phát triển

Skill nằm ở `skills/<tên>/SKILL.md`. Phần YAML front matter gồm `name` và
`description` chính là thứ Claude Code đem đi so với yêu cầu của user, nên đổi hành
vi thì phải sửa cả description chứ không riêng phần thân.

Agent nằm ở `agents/<tên>.md`, front matter dùng `name`, `description`, và `tools`
nếu muốn giới hạn công cụ. `humanizer` có giới hạn `tools` vì nó chỉ cần đọc và ghi
file. `design-taste` cố ý bỏ trống: nó cần Playwright MCP, mà tên các tool đó có
nhúng tên plugin (`mcp__plugin_ha1-s-claude-code_playwright__*`), liệt kê ra là lần
sau đổi tên plugin sẽ hỏng ngầm.

Ba điều cần biết khi sửa:

- Nội dung skill bị cache theo phiên. Sửa `SKILL.md` rồi gọi lại skill trong cùng
  phiên thì vẫn chạy bản cũ. Phải mở phiên mới.
- Marketplace lấy từ GitHub cần push trước. Push xong chạy
  `/plugin marketplace update ha1-s-claude-code`. Marketplace trỏ vào thư mục thì
  đọc thẳng cây làm việc.
- Sửa luật của `design-taste` hay `humanizer` thì sửa trong `SKILL.md`. File agent
  chỉ nói cách chạy cô lập và trả kết quả, không chép lại luật.

## Ghi công

`humanizer` vendor nguyên bản từ [blader/humanizer](https://github.com/blader/humanizer)
của Siqi Chen (MIT). `brainstorming` chỉnh từ
[obra/superpowers](https://github.com/obra/superpowers) của Jesse Vincent (MIT).
`design-taste` tổng hợp từ skill frontend-design của Anthropic,
[Refactoring UI](https://www.refactoringui.com/), quy trình design review của
OneRedOak và hướng dẫn UI của jiji262, đều MIT; tài liệu tham chiếu rút ra cùng giấy
phép của chúng nằm ở `skills/design-taste/references/`.

## Giấy phép

Phần vay mượn và chỉnh sửa giữ nguyên giấy phép gốc, đặt cạnh file mà nó áp dụng:
`skills/humanizer/LICENSE`, `skills/brainstorming/LICENSE` và
`skills/design-taste/references/*.LICENSE`. Phần nội dung tự viết còn lại chưa khai
báo giấy phép; muốn cho người khác dùng lại thì thêm file `LICENSE` ở gốc repo.
