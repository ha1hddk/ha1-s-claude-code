# ha1vd-harness

Personal Claude Code plugin — bộ harness cấp user đã tinh gọn sau đợt audit 07/2026
(mọi thứ trong đây đều sống sót qua kiểm chứng bằng eval hoặc số lần dùng thật).

## Có gì

| Thành phần | Mô tả | Ghi chú |
|---|---|---|
| `skills/handoff` | Viết brief bàn giao cho phiên mới (việc làm ngay + danh sách đừng-điều-tra-lại), lưu vào `~/.claude/handoffs/`. Đang chạy trong Herdr thì giao thẳng cho một pane mới; không thì copy clipboard (Wayland/X11). Có `resume` để nạp lại brief cũ | dùng nhiều nhất: 51 lần/tháng |
| `skills/herdr` | Điều khiển Herdr (terminal multiplexer cho coding agent): pane/tab/workspace, khởi động agent, và **giao việc cho pane mới bằng cơ chế nhắn tin giữa các phiên Claude Code** thay vì gõ vào TUI | cần `HERDR_ENV=1` + binary `herdr` |
| `skills/brainstorming` | Ép thiết kế kỹ trước khi code TÍNH NĂNG MỚI: hỏi từng câu, 2-3 phương án, spec được duyệt | chỉnh từ obra/superpowers (MIT) — bỏ writing-plans, kết thúc mềm; bản gốc kèm ở `SKILL.upstream.md` |
| `skills/design-taste` | Chống UI "AI hoá": khoá art direction vào `design/DIRECTION.md` trước khi code, danh sách cấm AI-defaults, vòng screenshot tự chấm sau khi code | tổng hợp từ frontend-design (Anthropic), refactoring-ui-skill, jiji262, OneRedOak (đều MIT); dùng kèm MCP playwright bên dưới |
| `.mcp.json` | MCP `playwright` (`npx -y @playwright/mcp@latest`) — lái trình duyệt thật để xác minh UI | npx tự tải, không cần cài trước |

## Cài

Máy này đang cài marketplace **từ thư mục local**, nên sửa file là thấy ngay:

```bash
/plugin marketplace add /home/ha1vd/Workspaces/ha1vd-harness
/plugin install ha1vd-harness
```

Máy mới thì lấy từ GitHub:

```bash
/plugin marketplace add ha1hddk/ha1-s-claude-code
/plugin install ha1vd-harness
```

Hai cách loại trừ nhau — cùng tên marketplace `ha1vd-harness`, chỉ đăng ký được một
nguồn. Bản GitHub phải `git push` rồi `/plugin marketplace update ha1vd-harness` mới
nhận thay đổi.

## Binary cần cài ngoài (plugin không kèm)

- `herdr` — cho skill herdr; không có thì skill tự bất hoạt (điều kiện `HERDR_ENV=1`)
- `node` >= 18 — MCP playwright chạy qua `npx`
- `wl-copy` (Wayland) hoặc `xclip` (X11) — để `handoff` copy được clipboard; thiếu thì
  skill in prompt ra cho copy tay, không coi là lỗi

## Sửa skill

Claude Code **cache nội dung SKILL.md theo phiên**: sửa file xong rồi gọi lại skill
trong CÙNG phiên vẫn chạy bản cũ. Phải mở phiên mới mới có hiệu lực (kiểm chứng
14/09/2026).

## License

Skill `brainstorming` chỉnh từ [obra/superpowers](https://github.com/obra/superpowers)
(MIT, Jesse Vincent) — xem `skills/brainstorming/LICENSE`. `design-taste` tổng hợp từ
các nguồn MIT ghi trong `skills/design-taste/references/`. Phần còn lại: tự viết.
