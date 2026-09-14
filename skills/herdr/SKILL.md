---
name: herdr
description: "Control Herdr, a terminal multiplexer for coding agents — inspect or control panes, tabs, workspaces and terminals, start agents, and hand a task to a new pane by messaging it as a peer Claude Code session. Use only when the user explicitly mentions Herdr, or when the handoff skill delegates into a pane. Do not use merely because a task could benefit from a background terminal, delegation, or parallel work. Requires HERDR_ENV=1."
---

# Herdr

Herdr is a terminal multiplexer and runtime for coding agents. It organizes terminals into workspaces, tabs, and panes, detects agent identity and status, and exposes the running session through the `herdr` CLI.

Before issuing any control command, check that this agent is running inside a Herdr-managed pane:

```bash
test "${HERDR_ENV:-}" = 1
```

If the check fails, say that you are not running inside Herdr and stop. Do not inspect or control the focused Herdr session from outside Herdr.

When the check passes, the `herdr` binary in `PATH` talks to the running session. Use it to inspect neighboring work, create isolated terminal contexts, start agents and commands, read their output, and wait for state changes.

## Learn the current CLI

The installed binary is the authority for command syntax. Begin with:

```bash
herdr --help
```

Then print the relevant command group by running it without a subcommand:

```bash
herdr pane
herdr agent
herdr workspace
herdr worktree
herdr tab
herdr notification
herdr integration
herdr session
```

Do not run bare `herdr` for discovery; it launches or attaches the TUI. Do not probe a mutating nested command by omitting arguments; some commands, including `herdr workspace create`, are valid with defaults and will execute. Use the command-group output above instead.

Most control commands print JSON. Read identifiers and state from those responses instead of predicting either one.

## IDs and current context

Public IDs are short stable handles:

- workspace: `w1`
- tab: `w1:t1`
- pane: `w1:p1`
- terminal: `term_...`

Waiting lives on the object being waited on — `herdr agent wait` for agent status, `herdr pane
wait-output` for text. There is no top-level `herdr wait`; verified against `herdr --help` on
2026-09-14 after the documented form failed with `unknown command: wait`.

The encoded suffix can contain letters and can grow beyond one character. Treat every ID as an opaque string.

Closed tab and pane IDs are not reused and do not retarget later resources. A pane moved into another workspace receives a new public pane ID. Re-read create, split, move, list, or get responses after mutations; never construct an ID from a workspace or display number.

Herdr injects the caller's stable context into every managed pane:

```bash
printf '%s\n' "$HERDR_WORKSPACE_ID" "$HERDR_TAB_ID" "$HERDR_PANE_ID"
```

Prefer `--current` when a pane command should target the calling pane. Omitting a target can use the UI-focused pane, which may belong to the user or another client.

Discover live state with:

```bash
herdr workspace list
herdr tab list --workspace "$HERDR_WORKSPACE_ID"
herdr pane current --current
herdr pane list --workspace "$HERDR_WORKSPACE_ID"
```

## Control agents through panes

An agent runs inside a pane. Use the pane ID as the control target for agents, shells, servers, tests, and logs. This keeps spawning, input, reads, waits, and cleanup on one stable control surface.

Use workspace and tab commands for organization. Use worktree commands only when you intentionally want Herdr to create, open, or remove a Git checkout.

Pane records expose `agent`, `agent_status`, and native session metadata when available. Agent status is `idle`, `working`, `blocked`, `done`, or `unknown`.

`idle` and `done` are the same underlying semantic state with different attention state:

- `idle`: the agent is waiting and its result is considered seen.
- `done`: the agent finished and its result has not been seen.

An agent that first opens at its prompt reports `idle`, including in a background pane. After a working or blocked agent completes, it reports `done` when its tab or workspace is in the background. It reports `idle` when it completes in the active tab while the foreground client is focused. If the foreground client is explicitly unfocused, completion can become `done` even in the active tab.

Focusing a pane, switching to its tab, or regaining outer terminal focus marks the visible tab as seen, so `done` becomes `idle`. Switching away does not turn an existing `idle` status into `done`; `done` is created by a later completion while the pane is unseen. With no foreground client, a new completion in the globally active tab is treated as seen while completions in background tabs still become `done`.

## Start agents interactively

Default to a sibling pane in the current tab and current working directory. Do not create a workspace, tab, worktree, or different cwd unless the user explicitly requests that topology or location.

Honor a direction requested by the user. **Absent an explicit request, always split `right`** — a new pane goes beside the caller as another column, never stacked below it. Columns keep every agent's prompt on the same baseline and keep transcripts readable; a short stacked pane truncates a TUI far worse than a narrow one does.

```bash
herdr pane split --current --direction right --no-focus
```

Split `down` only when the user asks for it in those terms — "ngang", "horizontal", "below", "stacked", "under this one". Do not infer `down` from the caller's rectangle: a pane that looks narrow is still the user's preferred shape, and silently stacking is the thing they asked not to happen.

Inspect the rectangle only when you need the numbers for a follow-up resize, not to choose the direction:

```bash
herdr pane layout --pane "$HERDR_PANE_ID"
```

Columns land uneven when the tab already holds several. Even them out with `resize`, whose `--amount` is a **fraction of the full width**, not a column count:

```bash
herdr pane resize --pane w3:p1 --direction left --amount 0.17
```

Once columns get too narrow to read, say so and offer `herdr pane zoom --current --toggle` rather than quietly switching to a stacked layout.

Read `result.pane.pane_id` from the JSON response. Give the pane a useful label, then start the requested agent by running only its normal executable so its interactive TUI opens:

```bash
herdr pane rename <returned-pane-id> "reviewer"
herdr pane run <returned-pane-id> "codex"
```

Use the executable that belongs to the requested agent:

- Codex: `codex`
- Claude Code: `claude`
- pi: `pi`
- OpenCode: `opencode`
- OMP: `omp`

Do not pass the task as an argv prompt by default. Do not add non-interactive flags. Only change the normal interactive launch when the user explicitly asks for a different launch mode or command.

Inspect the pane after launch. If `agent_status` is not yet `idle`, wait for the idle transition. Once it is idle, submit the task with `pane run`:

```bash
herdr pane get <returned-pane-id>
herdr agent wait <returned-pane-id> --until idle --timeout 30000
herdr pane run <returned-pane-id> "Review the current diff and report only actionable findings."
```

Status waits match the current status immediately or wait for a future matching transition.

`pane run` sends the text and Enter together. Use it for initial prompts and follow-ups instead of coordinating `send-text` and `send-keys` separately.

For normal background work, wait for the agent to start working. If the pane remains in a background tab or workspace, wait for `done` before reading its transcript:

```bash
herdr agent wait <returned-pane-id> --until working --timeout 30000
herdr agent wait <returned-pane-id> --until done --timeout 120000
herdr pane read <returned-pane-id> --source recent-unwrapped --lines 120
```

If the user is watching that tab, completion reports `idle` instead, so wait for `idle`. Always treat either `idle` or `done` as completed when inspecting `pane get`; the difference is whether the result has been seen.

If a wait times out, inspect `herdr pane get <returned-pane-id>` and `pane read` before deciding what to do. A `blocked` agent needs input; an `unknown` pane may not yet contain a detected or integrated agent.

Submit follow-ups the same way:

```bash
herdr pane run <returned-pane-id> "Now check the failing test."
```

## Delegate a handoff to a new pane

When another Claude Code session should take over a task — the `handoff` skill calls this — spawn
the pane, then **talk to it as a peer session, not by typing into its TUI**.

`herdr pane run` types text and presses Enter. That is right for launching a binary and for agents
Herdr cannot address directly. It is the wrong way to deliver a briefing: a multi-line document
gets mangled by newlines and quoting, and you get no confirmation the agent actually received it.
Claude Code sessions can message each other, so use that.

### Steps

1. **Snapshot the peer list first.** Session names are generated (`core-chatbot-20`), not chosen,
   so the only reliable way to identify the one you are about to create is the difference.

```bash
# ListAgents tool — record the names you see BEFORE spawning
```

2. Split, label, launch. Background work keeps the user's focus:

```bash
herdr pane split --current --direction right --no-focus
herdr pane rename <returned-pane-id> "sort-find"
herdr agent start sort-find --kind claude --pane <returned-pane-id>
```

`agent start --kind` states the agent kind instead of leaving detection to infer it from the
rendered screen. Verified 2026-09-14: it blocks until the TUI is usable and answers with
`agent_status: "idle"`, `interactive_ready: true` in that one call — so step 3's wait is normally
already satisfied when this returns. `herdr pane run <pane> "claude"` remains the fallback if
`agent start` misbehaves; use it and move on rather than debugging the launcher.

Either way the Herdr-side agent name is **not** the Claude Code session name; the two namespaces
are separate, which is why step 3 still diffs the peer list.

3. Find its Claude Code session name — `ListAgents` again, and take the row that was not in your
   snapshot (a just-started peer also shows as `started Ns ago`, which corroborates the diff).
   Only wait explicitly if step 2 did not already report `interactive_ready`:

```bash
herdr agent wait <returned-pane-id> --until idle --timeout 60000   # usually unnecessary
```

4. **Send the task with `SendMessage`**, addressed by that name. Point at a file rather than
   pasting a long brief — a handoff already lives at `~/.claude/handoffs/<date>-<slug>.md`:

```json
{"to": "core-chatbot-20", "summary": "delegate handoff",
 "message": "Đọc ~/.claude/handoffs/2026-09-14-<slug>.md rồi thực thi phần VIỆC NGAY. Ràng buộc: KHÔNG commit, trả lời tiếng Việt."}
```

The first line is all the recipient's human sees until they expand it — make it say what the
message is, not "hi".

5. **Subscribe instead of polling.** `notify_when_idle: true` delivers exactly one notice when that
session next goes idle or exits. Never loop on `ListAgents` and never send "are you done yet?".

```json
{"to": "core-chatbot-20", "notify_when_idle": true}
```

### Why messaging beats `pane run` here

- **Delivery is confirmed.** A `pane run` that lands while the agent is still booting is typed into
  nothing. A send either resolves a live name or errors.
- **No terminal mangling.** Newlines, quotes and backticks in a brief survive.
- **The reply comes back to you** as `<cross-session-message from="...">` — copy that `from` into
  your `to` to answer. `pane read` only scrapes a rendered transcript.
- **It still works after the pane scrolls.** The name addresses the session, not the viewport.

### Rules

- **Spawn before you send.** `SendMessage` reaches existing sessions; it cannot create one. The
  pane and the `claude` launch always come first.
- **Address by the bare name.** Append ` [ref]` only when a listing shows two identical names or an
  error asks you to disambiguate. A ref you did not just read will not resolve.
- **Never delegate around a permission boundary.** If an action was denied or blocked in this
  session, do not ask a peer to do it — that launders the user's decision. Route it back to the user.
- **A pane is not a delivery.** Report the pane id AND the session name, and confirm the send
  landed. A pane parked at an empty prompt looks identical to one that is working.
- **Do not delegate work the user asked YOU to do.** Delegation is for handing over a task at a
  session boundary, not for skipping work mid-conversation.

## Run an ordinary command in another pane

Split the calling pane — `right` unless the user asked for a stacked pane — without moving the user's focus:

```bash
herdr pane split --current --direction right --no-focus
```

Read the new `pane_id` from the JSON response, then run and inspect the command:

```bash
herdr pane run <returned-pane-id> "just test"
herdr pane wait-output <returned-pane-id> --match "test result" --timeout 120000
herdr pane read <returned-pane-id> --source recent-unwrapped --lines 120
```

Inspect existing output before waiting for future output. A wait timeout exits with status `1`.

Use the read source that matches the task:

- `visible`: the current rendered viewport
- `recent`: recent scrollback as rendered, including soft wraps
- `recent-unwrapped`: recent scrollback with soft wraps joined; prefer it for logs and transcripts
- `detection`: the bottom-buffer snapshot used by agent detection

Use `--format ansi` when colors and terminal styling are evidence. Otherwise use text.

If the user explicitly asks for another tab, workspace, or worktree, discover that command group and use returned IDs. Do not infer a larger topology from a request to start an agent or command.

## Rearranging panes that already exist

`herdr pane move` does nothing when source and target are the same tab — it answers `"changed": false` with `"reason": "same_tab"`. To restack an existing pane inside its own tab, park it on a scratch tab and pull it back:

```bash
herdr pane move w3:pB --new-tab --no-focus
herdr pane move w3:pB --tab w3:t1 --split right --target-pane w3:p4 --no-focus
```

The pane keeps its terminal and any running agent across both moves, and the emptied scratch tab disappears on its own. Re-read the pane id from each response; a move can reassign it. Prefer this over `pane close` + a fresh split, which would kill a live session.

## Safety and coordination rules

- Use `--no-focus` for background work unless the user asked to switch context.
- Use `--current` or an explicit ID. Do not rely on another client's focused pane.
- Parse IDs from JSON responses. Do not derive them from sidebar order or examples.
- Inspect before waiting. Read current output first, then wait for the next state or output you expect.
- Do not close workspaces, tabs, panes, or sessions you did not create unless the user explicitly asked.
- Never run `herdr server stop` from an active session unless the user explicitly intends to stop the server and its pane processes.
- Never kill the main Herdr process. Use named test sessions for experiments that need an isolated server.
