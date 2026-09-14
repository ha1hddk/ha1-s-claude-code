---
name: handoff
description: Produce a self-contained handoff prompt to continue the current work in a fresh Claude Code session — saved to a store, and when running inside Herdr, handed straight to a new pane instead of the clipboard. Use when the user asks to "đưa prompt handoff", "handoff qua session mới", "chuẩn bị chuyển session", "lưu lại để mai làm", "save session", or wants to resume earlier saved work ("/handoff resume", "nạp lại handoff", "hôm trước làm đến đâu").
---

# Session Handoff

Generate ONE copy-paste-ready prompt that lets a fresh session resume the current work with zero re-discovery. The goal: the new session does the *next action* immediately and correctly, without re-investigating what this session already established.

## Modes

| Invocation | What happens |
|---|---|
| `/handoff` (default) | Write the prompt → **save to store** → **delegate to a new Herdr pane if we're in Herdr**, else copy to clipboard → print fenced block |
| `/handoff save [tên]` | Write + save to store only — for "lưu để mai/tuần sau làm", no clipboard, no delegation |
| `/handoff here` | Write + save + clipboard, **never delegate** — for when the user wants to carry it elsewhere themselves |
| `/handoff list` | List saved handoffs (name, date, first line of VIỆC NGAY) |
| `/handoff resume [tên]` | Load a saved handoff and ACT on it (run in the NEW session). No name → offer the most recent few |

## Delegate automatically when running inside Herdr

Default mode checks one thing before falling back to the clipboard:

```bash
test "${HERDR_ENV:-}" = 1
```

**Pass** → the point of a handoff is already achievable here: spawn a sibling pane, start Claude
Code in it, hand it the work. Do that instead of asking the user to `/clear` and paste. Invoke the
`herdr` skill and follow its **"Delegate a handoff to a new pane"** section — it owns the pane +
messaging mechanics; do not reimplement them here.

**Fail** → clipboard + fenced block, exactly as before. Not in Herdr means there is no pane to
delegate to, and the prompt itself is the deliverable.

Two rules that survive delegation:

- **Save to the store first, always.** Delegation can fail (no pane, agent never reaches idle, a
  send that does not land). The store file is what makes the failure recoverable, so it is written
  before anything is spawned.
- **Re-read the tree before handing off.** A handoff describes a state; if you edited files
  *after* drafting it, the new session will redo work that already exists. Run `git status --short`
  and fold anything new into a **## ĐÃ LÀM DỞ** section listing what is already changed and what
  remains. This is the single most common way a delegated handoff wastes a session.

Still print the fenced block after delegating. The user may want it for a second pane, another
machine, or tomorrow.

## When to Use

- User says "đưa/cho t prompt handoff", "handoff qua session mới", "viết prompt để chạy tiếp", "chuẩn bị chuyển session", "lưu lại mai làm tiếp".
- Context window is near full, or the user wants a fresh/cheaper session to continue.
- A long-running job (test harness, build, migration) will outlive the session and someone must pick up the result.
- Next session: "hôm trước đang làm gì", "nạp lại cái handoff", `/handoff resume`.

This skill writes/loads the handoff and — inside Herdr — hands it to a new pane. It does NOT do
the work itself: no commits, no edits to the task's files while producing one. Spawning a pane and
delivering the brief is part of the handoff; doing the next action yourself is not.

## Core principle

A good handoff is **not a summary of the conversation** — it is an **operating brief for the next session**. Optimize for: (1) what to do next, (2) what NOT to redo. The single most valuable section is the *immediate next action* stated precisely enough to execute blind.

## What to capture (in this order)

1. **Goal / context** — 1–3 sentences: what we're trying to achieve and why. Include the repo, branch, and the governing higher-level objective if one exists.
2. **DONE** — what's already finished and verified (with the concrete artifacts: file paths, function names, result numbers). Keep it factual, not narrative.
3. **IMMEDIATE NEXT ACTION** — the ONE thing the new session should do first, written so it can run without guessing: exact command(s), file(s) to edit, expected outcome. If there's a sequence, number it but lead with step 1.
4. **KNOWN — don't re-investigate** — facts this session already established that the next session would otherwise waste time rediscovering: root causes already found, code already patched (and where), dead ends, config locations, the shape of the data. This section is what makes a handoff cheap.
5. **CONSTRAINTS** — durable rules that must survive: commit policy (e.g. "KHÔNG commit trừ khi user yêu cầu"), secret handling, "keep test data", communication language, anything in CLAUDE.md/memory that bears on this task.
6. **POINTERS** — relevant files, memory files (`[[name]]` or path), plan docs, prior result files, ticket/PR links.
7. **HOW TO VERIFY** (when applicable) — how the next session confirms success (test command, expected number, what "done" looks like).

## Rules for a reliable handoff

- **Self-contained.** The new session sees none of this conversation. Spell out anything it needs; never write "as discussed above" or "the file we edited".
- **Paste-ready.** Emit the whole prompt inside ONE fenced code block so the user can copy it in one action. Use a language-less fence (```` ``` ````) or `````text````` so any inner backticks survive — prefer a 4-backtick outer fence if the body contains triple-backtick code blocks.
- **Absolute over relative.** Convert "today / tomorrow / last run" to absolute dates and concrete paths. Background jobs do NOT survive a session — if one is running, say whether to wait for it, re-run it, or read its output file (give the path).
- **Precise next action.** "Run the repair" is weak; give the exact env + command + working dir + output file. Ambiguity here is what forces the new session to re-explore.
- **Scope, don't dump.** Include what's needed to act, not a transcript. If a detail isn't load-bearing for the next action or the don't-redo list, leave it out.
- **Carry the guardrails.** Re-state the no-commit / no-delete / language constraints explicitly — a fresh session won't infer them from tone.
- **Match the user's language.** This user works in Vietnamese; write the handoff in Vietnamese unless told otherwise (code/commands stay as-is).

## Process (default & save)

1. Reconstruct the task state from the conversation: the goal, what's done, the single next action, the don't-redo facts, the constraints, the pointers.
2. If a current plan file or memory entry already holds some of this, reference it by path rather than re-typing it — but still state the immediate next action inline.
3. Draft the prompt using the section order above. Drop sections that genuinely don't apply.
4. **Save to the store** (both modes — saving is not optional, it's what makes resume possible):
   - Path: `~/.claude/handoffs/YYYY-MM-DD-<slug>.md` (`mkdir -p` first). Slug: short kebab-case task name — user-provided `[tên]` wins, else derive from the task (e.g. `harness-audit`, `core-chatbot-i18n`).
   - Same-day same-slug → overwrite (it's the newer state of the same task).
5. **Re-read the tree** (`git status --short`) and fold anything changed since you started drafting
   into **## ĐÃ LÀM DỞ**. Skipping this is how a delegated session redoes finished work.
6. Default mode: if `HERDR_ENV=1`, delegate via the `herdr` skill; otherwise run `clip.sh` on the
   saved file. Either way, emit the fenced block afterwards. `save` mode: confirm path + slug in one
   line, print the block only if asked. `here` mode: clipboard + block, never delegate.

## Skeleton (adapt; omit empty sections)

````
# Handoff: <task in one line> — <repo> (<branch>)

## Bối cảnh
<goal + why, governing objective if any>

## DONE
- <finished + verified, with paths / numbers>

## VIỆC NGAY (làm đầu tiên)
<exact command / file edit / expected outcome — runnable blind>

## ĐÃ BIẾT (đừng điều tra lại)
- <root causes, patches already made + where, dead ends, config locations, data shape>

## RÀNG BUỘC
- <commit policy, secrets, keep-test-data, language, etc.>

## POINTERS
- files / memory / plan docs / result files / links

## CÁCH VERIFY
<how the next session confirms success>
````

## Resume (run in the new session)

1. **Locate.** Named: `~/.claude/handoffs/*<tên>*.md` (newest on multiple matches). Unnamed: list the 3 most recent — name, date, first line of VIỆC NGAY — let the user pick. Nothing in the store: say so; also check legacy `~/.claude/session-data/` before giving up.
2. **Staleness check — mandatory before acting.** A handoff is a snapshot; the world moved on. Compare file date to today, then verify the load-bearing facts cheaply: branch still exists, files in VIỆC NGAY still present, background-job output files still there. Older than ~3 days → verify every DONE claim you depend on before building on it. A failed check does NOT invalidate the handoff — report the drift ("file X đã đổi so với lúc lưu") and adapt.
3. **Confirm scope in one line** ("Nạp handoff `<slug>` ngày N — việc ngay là X — chạy luôn nhé?") **only if** the handoff is stale or ambiguous; a fresh handoff with a precise next action → just execute it, that's what it's for.
4. **Execute** VIỆC NGAY, honoring RÀNG BUỘC as if the user had typed them this session.
5. When the task later finishes for real, offer to delete the store file — the store is a to-do shelf, not an archive.

## Copy to clipboard (so the user just /clear + paste)

A command/skill cannot drive the TUI — it cannot run `/new`/`/clear`, open a window, or paste into the input box (those are client-side). The closest automation that actually helps is to **put the handoff prompt on the system clipboard**, so the user only does `/clear` then paste.

Use `clip.sh` in this skill dir — it copies a file (or stdin) to the clipboard, handling Wayland (`wl-copy`) and X11/XWayland (`xclip`), and auto-deriving `WAYLAND_DISPLAY` from the socket if unset:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/handoff/clip.sh" <prompt-file>     # or:  echo "$PROMPT" | bash .../clip.sh
```

**When clipboard isn't reachable** (e.g. over SSH with no `$DISPLAY`/`$WAYLAND_DISPLAY`, or no `wl-copy`/`xclip`): `clip.sh` exits non-zero and says so. Fall back to emitting the prompt in one fenced block for the user to copy manually. Do NOT treat a clipboard failure as a handoff failure — the prompt itself is the deliverable (and it's saved in the store regardless).

**Notes:**
- Background jobs from THIS session do not carry over; if the new session must wait on or re-run one, the prompt's "VIỆC NGAY" must say so (with the output-file path or the re-run command).
- This does NOT auto-submit anything — the user reviews the pasted prompt and presses Enter themselves. Good: nothing runs (or spends tokens) without their go-ahead.

## Done when

Default/save: the prompt exists in `~/.claude/handoffs/` — leading with a next action precise
enough to execute blind and a don't-redo list. Default mode additionally either (a) has a named
peer session working on it, reported back to the user with its pane id and session name, or
(b) is on the clipboard so the user only needs `/clear` + paste. Resume: the saved next action is
running (or the drift that blocks it has been reported), with the saved constraints in force.

A delegated handoff is NOT done when the pane exists — it is done when the task has actually been
delivered to the agent in it. Confirm the send landed; a pane sitting at an empty prompt is a
failure that looks like a success.
