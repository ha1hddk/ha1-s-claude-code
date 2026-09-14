# ha1vd-harness

Personal Claude Code plugin — bộ harness cấp user đã tinh gọn sau đợt audit 07/2026
(mọi thứ trong đây đều sống sót qua kiểm chứng bằng eval hoặc số lần dùng thật).

## Có gì

| Thành phần | Mô tả | Ghi chú |
|---|---|---|
| `skills/handoff` | Tạo prompt bàn giao sang phiên mới + copy clipboard (Wayland/X11) | dùng nhiều nhất: 51 lần/tháng |
| `skills/brainstorming` | Ép thiết kế kỹ trước khi code TÍNH NĂNG MỚI: hỏi từng câu, 2-3 phương án, spec được duyệt | chỉnh từ obra/superpowers (MIT) — bỏ writing-plans, kết thúc mềm; bản gốc kèm ở `SKILL.upstream.md` |
| `skills/design-taste` | Chống UI "AI hoá": khoá art direction vào `design/DIRECTION.md` trước khi code, danh sách cấm AI-defaults, vòng screenshot tự chấm sau khi code | tổng hợp từ frontend-design (Anthropic), refactoring-ui-skill, jiji262, OneRedOak (đều MIT); phối với plugin playwright + ui-ux-pro-max |
| `skills/herdr` | Điều khiển Herdr (terminal multiplexer cho coding agent) | cần `HERDR_ENV=1` + binary `herdr` |
| `.mcp.json` | MCP `codegraph serve --mcp` — hỏi đáp codebase qua knowledge graph | cần binary `codegraph` |

## Cài

```bash
# thêm marketplace (sau khi push repo này lên GitHub)
/plugin marketplace add <github-user>/ha1vd-harness
/plugin install ha1vd-harness
```

Sau khi bật plugin:

1. **Xoá bản skill trùng ở user scope** (nếu còn): `~/.claude/skills/{brainstorming,handoff,herdr}` — plugin thay thế chúng, để cả hai sẽ bị trùng tên.
2. **Xoá MCP codegraph cấp user** (nếu có) trong `~/.claude.json` → key `mcpServers.codegraph` — plugin đã khai rồi.

## Binary cần cài ngoài (plugin không kèm)

- `codegraph` — cho MCP; project nào muốn dùng thì chạy `codegraph init` trong repo đó
- `herdr` — cho skill herdr; không có thì skill tự bất hoạt (điều kiện `HERDR_ENV=1`)
- `node` >= 18

## Cấu hình khuyến nghị (plugin không tự ghi vào settings)

Thêm vào `~/.claude/settings.json → permissions.allow` để codegraph không hỏi từng lần:

```json
"mcp__codegraph__codegraph_explore", "mcp__codegraph__codegraph_search",
"mcp__codegraph__codegraph_node", "mcp__codegraph__codegraph_callers",
"mcp__codegraph__codegraph_callees", "mcp__codegraph__codegraph_impact",
"mcp__codegraph__codegraph_files", "mcp__codegraph__codegraph_status"
```

Hai file chỉ dẫn cấp user (`~/.claude/CLAUDE.md`, `~/.claude/RTK.md` — cách dùng RTK
và CodeGraph) plugin không chở được — chép tay khi cài máy mới.

## License

Skill `brainstorming` chỉnh từ [obra/superpowers](https://github.com/obra/superpowers)
(MIT, Jesse Vincent) — xem `skills/brainstorming/LICENSE`. Phần còn lại: tự viết.
