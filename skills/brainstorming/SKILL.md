---
name: brainstorming
description: "Deep design brainstorm BEFORE starting a NEW FEATURE. Use when the user says they want to build a new feature / tính năng mới, asks to 'brainstorm', or invokes /brainstorming. Explores intent, constraints and success criteria one question at a time, proposes 2-3 approaches with trade-offs, and produces an approved spec before any code. NOT for small edits, bug fixes, or refactors — those proceed normally."
---

<!-- Adapted from obra/superpowers `brainstorming` (MIT, Copyright (c) 2025 Jesse Vincent).
     Changes: trigger narrowed to new-feature starts; writing-plans handoff replaced with a
     flexible exit; visual companion replaced by built-in Artifact; no auto-commit. -->

# Brainstorming Ideas Into Designs

Turn a new-feature idea into a validated design through natural collaborative
dialogue. Understand the project context first, refine the idea one question at
a time, then present the design and get approval.

<HARD-GATE>
While this skill is active: do NOT write code, scaffold anything, or take any
implementation action until a design has been presented and the user approved it.
</HARD-GATE>

## Checklist (in order)

1. **Explore project context** — files, docs, recent commits, existing patterns
2. **Ask clarifying questions** — one at a time: purpose, constraints, success criteria
3. **Propose 2-3 approaches** — trade-offs + your recommendation, lead with it
4. **Present design** — in sections scaled to complexity, confirm after each section
5. **Write the spec** — to the project's convention (default `docs/specs/YYYY-MM-DD-<topic>-design.md`); do NOT commit unless asked
6. **Spec self-review** — placeholders, contradictions, ambiguity, scope (see below)
7. **User reviews the spec** — wait for approval or change requests
8. **Flexible exit** — see "After approval"

## The Process

**Understanding the idea:**

- Check the current project state first (files, docs, recent commits)
- Before detailed questions, assess scope: if the request spans multiple
  independent subsystems, flag it immediately and help decompose into
  sub-projects first. Each sub-project then gets its own brainstorm.
- Ask questions **one at a time** — one question per message. Prefer multiple
  choice when possible (AskUserQuestion works well); open-ended is fine too.
- Focus on: purpose, constraints, success criteria.

**Exploring approaches:**

- Propose 2-3 different approaches with trade-offs, conversationally
- Lead with your recommended option and explain why
- YAGNI ruthlessly — strip unnecessary features from every approach

**Presenting the design:**

- Scale each section to its complexity: a few sentences if straightforward,
  200-300 words if nuanced
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing
- For genuinely visual questions (layout choices, mockup comparisons, flow
  diagrams) use the built-in Artifact tool — one page, options side by side.
  Text questions stay in the terminal; a UI *topic* is not automatically a
  visual question.

**Design for isolation and clarity:**

- Break the system into units with one clear purpose each, communicating
  through well-defined interfaces, testable independently
- For each unit: what does it do, how do you use it, what does it depend on?
- If internals can't change without breaking consumers, boundaries need work.

**Working in existing codebases:**

- Explore current structure before proposing changes; follow existing patterns
- Include targeted improvements where existing problems affect this work;
  don't propose unrelated refactoring

## Spec Self-Review

After writing the spec, look at it with fresh eyes and fix inline:

1. **Placeholder scan** — any TBD/TODO/vague requirements? Fix them.
2. **Internal consistency** — do sections contradict? Does architecture match features?
3. **Scope check** — focused enough for one implementation effort, or needs decomposition?
4. **Ambiguity check** — could a requirement be read two ways? Pick one, make it explicit.

Then ask the user to review the spec file. If they request changes, apply and
re-run this self-review. Only proceed once approved.

## After approval (flexible exit — no fixed next skill)

Ask the user how they want to continue, or follow what they already said:

- **Plan chi tiết** → enter Plan mode (EnterPlanMode) to turn the spec into an
  implementation plan for approval
- **Làm luôn** → implement directly from the spec
- **Dừng ở spec** → stop; the spec stands on its own for later

Any of these is a valid end state. Do not force a follow-up skill.
