# ha1-s-claude-code

A personal [Claude Code](https://claude.com/claude-code) plugin: four skills that
cover session handoff, terminal orchestration, feature design, and UI art
direction — plus a browser MCP server for visual verification.

The plugin is deliberately small. Each skill earned its place by being used on
real work; anything that did not survive an audit was removed rather than kept
"just in case".

## Contents

| Component | What it does |
|---|---|
| [`handoff`](#handoff) | Writes an operating brief that lets a fresh session resume work with no re-discovery. Stores it, and delegates it to a new Herdr pane when one is available. |
| [`herdr`](#herdr) | Drives Herdr, a terminal workspace manager for AI coding agents: panes, tabs, workspaces, agent lifecycle, and peer-to-peer task delegation. |
| [`brainstorming`](#brainstorming) | Forces a design pass before code on a new feature: one question at a time, 2–3 approaches with trade-offs, an approved spec. |
| [`design-taste`](#design-taste) | Keeps generated UI from looking machine-made: locate a designer-made sample, extract its design DNA into the project, then verify the build against it by screenshot. |
| `.mcp.json` | Bundles the [Playwright MCP server](https://github.com/microsoft/playwright-mcp) so skills can drive a real browser. |

## Requirements

| | Needed for | Notes |
|---|---|---|
| Claude Code | everything | — |
| Node.js ≥ 18 | Playwright MCP | launched through `npx`; nothing to install ahead of time |
| `herdr` | the `herdr` skill | the skill refuses to run unless `HERDR_ENV=1`, so a machine without it is unaffected |
| `wl-copy` or `xclip` | `handoff` clipboard output | optional — without it the brief is printed for manual copying |

## Installation

```
/plugin marketplace add ha1hddk/ha1-s-claude-code
/plugin install ha1-s-claude-code
```

To work on the plugin itself, point the marketplace at a local checkout instead —
edits then take effect without a push:

```
git clone git@github.com:ha1hddk/ha1-s-claude-code.git
```
```
/plugin marketplace add /path/to/ha1-s-claude-code
/plugin install ha1-s-claude-code
```

Both forms register a marketplace named `ha1-s-claude-code`, so only one can be
active at a time. Switch with `/plugin marketplace remove ha1-s-claude-code`
before adding the other.

## Skills

### handoff

Produces a self-contained brief for continuing work in a fresh session. The
output is an operating brief, not a conversation summary: it leads with the
single next action stated precisely enough to execute blind, followed by the
findings the next session must not re-derive.

| Mode | Behaviour |
|---|---|
| `/handoff` | Write → save → delegate to a Herdr pane if running inside Herdr, otherwise copy to clipboard |
| `/handoff save [name]` | Write and save only |
| `/handoff here` | Write, save, copy — never delegate |
| `/handoff list` | List stored briefs |
| `/handoff resume [name]` | Load a stored brief, check it for staleness, and act on it |

Briefs are stored as `~/.claude/handoffs/YYYY-MM-DD-<slug>.md`. The brief is
always written before any delegation is attempted, so a failed handoff stays
recoverable. Before handing off, the working tree is re-read so that work
finished after drafting is not silently repeated.

### herdr

Controls a running Herdr session through its CLI. Covers pane, tab and
workspace management, starting agents and ordinary commands in a pane, reading
their output, and waiting on state transitions.

Its most useful path is delegation. Rather than typing a prompt into another
agent's TUI — which is lost if the agent is still booting and mangles quoting —
the skill starts a Claude Code agent in a new pane, identifies it by diffing the
peer-session list, and hands over the work with a cross-session message pointing
at a stored handoff. Delivery is confirmed, and completion arrives as a
notification instead of a polling loop.

The skill is inert outside Herdr: it checks `HERDR_ENV=1` and stops if unset.

### brainstorming

Runs before a new feature is built, not before every change — small edits, bug
fixes and refactors proceed normally.

The sequence is: explore the project's existing patterns, ask clarifying
questions one at a time (purpose, constraints, success criteria), propose two or
three approaches with trade-offs and a recommendation, present the design in
sections and confirm each, then write a spec to
`docs/specs/YYYY-MM-DD-<topic>-design.md` and self-review it for placeholders,
contradictions and scope creep before the user reviews it.

Adapted from [obra/superpowers](https://github.com/obra/superpowers); the
unmodified original is kept alongside as `SKILL.upstream.md`.

### design-taste

Addresses a specific failure: a model asked to build UI produces something
competent and instantly recognisable as machine-made. The skill's premise is
that the agent's own aesthetic judgement should not be trusted, so it works from
a real sample instead.

1. If the repository already has `design/DIRECTION.md`, obey it — no
   re-invention.
2. Otherwise ask the user for a reference, or propose candidates from a ranked
   catalogue: open-source templates with extractable theme source first
   (Creative Tim, tremor, daisyUI, shadcn themes, Flowbite), then documented
   design systems (Primer, Polaris, Carbon, Radix), then admired live sites,
   then image-only inspiration where every extracted value is marked as a guess.
3. Extract the sample's design DNA — tokens, type scale, surface strategy,
   accent discipline — into `design/DIRECTION.md`.
4. Compose the layout, which is the agent's own contribution rather than a copy.
5. After coding, screenshot at 1440/768/375 in light and dark, place the render
   beside the sample, and triage the differences.

It also carries an explicit ban list for the defaults a model reaches for
unprompted — Inter and Roboto as the chosen face, purple-to-indigo gradients on
white, gradient-text heroes, emoji as icons, pure `#000`/`#fff`, untinted greys,
invented metrics, and the usual generated-copy tells.

## MCP servers

`.mcp.json` declares one stdio server, `playwright`, run via
`npx -y @playwright/mcp@latest`. It gives `design-taste` a real browser for its
verification loop and is available to any other task that needs one.

## Development

Skills live in `skills/<name>/SKILL.md`. The YAML front matter — `name` and
`description` — is what Claude Code matches against a request, so a change in
behaviour belongs in the description as much as in the body.

Two things to know when editing:

- **Skill bodies are cached per session.** Editing a `SKILL.md` and invoking the
  skill again in the same session runs the previous version. Start a new session
  to pick up changes.
- **A GitHub-sourced marketplace needs a push.** Run
  `/plugin marketplace update ha1-s-claude-code` after pushing. A
  directory-sourced marketplace reads the working tree directly.

## Credits

`brainstorming` is adapted from [obra/superpowers](https://github.com/obra/superpowers)
by Jesse Vincent (MIT). `design-taste` draws on Anthropic's frontend-design
skill, [Refactoring UI](https://www.refactoringui.com/), OneRedOak's design
review workflow, and jiji262's UI guidance — all MIT; the derived reference
material and its licences are in `skills/design-taste/references/`.

## License

Adapted and vendored material keeps the licence it shipped with, recorded beside
the file it applies to — `skills/brainstorming/LICENSE` and
`skills/design-taste/references/*.LICENSE`. The remaining original content has no
licence declared; add a root `LICENSE` file before treating it as reusable.
