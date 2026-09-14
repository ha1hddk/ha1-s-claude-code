---
name: design-taste
description: "MUST use when building or restyling any UI (page, component, dashboard, landing). The agent does NOT trust its own aesthetic judgment: a real designer-made SAMPLE is found first (template catalogs / user reference), its design DNA is extracted into the PROJECT's design/DIRECTION.md, and code only executes that. Includes AI-default bans and a mandatory screenshot verify loop."
---

<!-- v3, 2026-07-30. Architecture: this user-scope skill holds only the GENERALIZED
     process — where to find designer-made samples, how to extract their DNA, how to
     execute and verify. Concrete tokens of a chosen look are PROJECT data: they live in
     that repo's design/DIRECTION.md, never in this skill. Rationale (measured, not
     guessed): rules the model writes for itself cannot exceed its own taste ceiling;
     skills raise the floor (bans, checklists) but only real samples raise the ceiling.
     Vendored craft references (MIT, attributed): references/refactoring-ui.md (distilled
     from Refactoring UI via jaywilburn), references/design-principles.md (OneRedOak). -->

# Design Taste v3 — sample-first: find the giant, extract, execute, verify

Role split (never violate it):
- **Taste** = a real designer's sample + the user's eyes. Not you.
- **You** = librarian (find samples), surveyor (extract DNA), builder (execute
  exactly), inspector (verify against the sample).

<HARD-GATE>
No production UI code before a direction is locked in the project's
design/DIRECTION.md — either extracted from a sample or picked from previews.
</HARD-GATE>

## Step 0 — Existing direction wins

If `design/DIRECTION.md` exists in the repo: read it and OBEY. No re-invention,
no new previews. Per-page overrides: `design/overrides/`.

## Step 1 — Get a sample (the main path)

Ask ONE question first: "Có mẫu nào bạn thích không — link, ảnh, tên template?"

If the user has none, offer to find candidates from the catalog map below:
pick 2–3 that fit the domain/audience, show them (links or screenshots), let
the user choose with their eyes. Zero design knowledge required of the user.

**Catalog map — designer-made, extractable sources (prefer top of list):**
- **Open-source template libraries with full theme source** — best case, DNA
  is verbatim: Creative Tim free templates (MIT: Vision UI, Soft UI, Argon,
  Material Dashboard...), tremor.so blocks, daisyUI themes, shadcn/ui themes
  + tweakcn, Flowbite. Extract from their theme/tokens source files.
- **Open design systems** (systematic, documented tokens): Primer (GitHub),
  Polaris (Shopify), Carbon (IBM), Atlassian, Radix themes.
- **Live sites the user admires** (their product's peers, Linear/Stripe/...):
  extractable via CSS inspection — borrow discipline (grid, type scale,
  surface strategy), never identity (logos, exact brand colors as-is).
- **Image-only inspiration** (Dribbble, Behance, awwwards, screenshots):
  extraction is interpolation — usable, but mark every guessed value.

## Step 2 — Extract the DNA (recipes by source type)

- **MIT/open repo**: read the actual theme source (colors, gradients with
  exact stops/degrees, radius scale, shadows, blur values, type scale, font
  families). Copy values VERBATIM — never approximate what you can read.
- **Live site**: fetch its CSS; extract custom properties, font stacks, type
  scale, spacing rhythm, surface layering. Note what's inferred vs read.
- **Screenshot only**: interpolate palette/type/spacing from the image; mark
  every value as estimated; expect a correction round after first render.

What "DNA" means — capture ALL of: base surfaces & their layering strategy,
accent colors + WHERE they're allowed (usually tiny areas), the one repeated
atom (icon chip, hairline, pill), radius scale, shadow/glow recipe, type
family + scale + label-over-number patterns, spacing rhythm, how depth is
made (layers vs shadows), signature element.

**Extract the layout GRAMMAR, not just the layout**: the sample's screens are
sentences; you need its grammar so you can write new sentences. Record: the
grid system (columns, gutters, breakpoint behavior), the sizing logic (WHY is
that card 2× wide — is it "hero content gets 2 cells", "charts get full
row"?), section rhythm (what separates topic shifts), density rules, where
imagery is allowed, and what the sample does with forms/tables/empty states
if shown.

## Step 3 — Compose the layout (this is YOUR contribution)

Copying the sample verbatim only works when your screen IS the sample's
screen. For everything else, you actively design the layout — grounded, not
invented:

1. **Content inventory first.** List what actually goes on this page and rank
   it: what must be seen first, what supports, what is secondary. Layout
   derives from this ranking — never from the sample's content.
2. **Apply the sample's grammar to your inventory.** Your #1 content gets the
   sample's hero treatment; supporting content gets its supporting patterns.
   Use the Layout Decision Framework in `references/refactoring-ui.md` for
   the calls the grammar doesn't cover (grouping, proximity, alignment,
   when to break symmetry).
3. **Screens the sample never shows** (settings, forms, empty states...):
   derive them from the grammar + `references/design-principles.md` patterns;
   flag them in DIRECTION.md as "extrapolated — review after first render".
4. **When the mapping is genuinely ambiguous** (two plausible arrangements
   with different trade-offs): sketch both as ASCII wireframes, one line of
   reasoning each, let the user pick. Don't silently pick for them, and
   don't ask when the content ranking already decides it.

## Step 4 — Lock it into the PROJECT

Write `design/DIRECTION.md` in the repo: sample name + link, extracted tokens
(named hex, gradients verbatim, radius/shadow/type scales), the sample's
layout grammar + YOUR composed layout per screen (ASCII, from Step 3)
(ASCII), the repeated atom, signature element, and per-value provenance
(read vs inferred). This file is project property — commit it with the
project when the user commits. All UI code derives from it.

## Fallback — no sample, user wants to skip choosing

Only then: build `design/previews.html` with 3 genuinely different directions
(different layout topology + type strategy + surface strategy, each anchored
to a NAMED real-world look, 1 plain-language sentence each), open in browser,
user picks. Then Steps 3–4 as usual.

## NEVER (bans — the floor; they hold regardless of direction)

- Fonts: Inter, Roboto, Arial, Open Sans, Lato, system-ui as the chosen face
- Purple/indigo gradient on WHITE; gradient-text hero + blobs
- Unexamined defaults: cream #F4F1EA + serif + terracotta; near-black + acid
  accent; broadsheet hairlines — banned as defaults, fine as a user-picked look
- Emoji as icons/bullets; N identical cards in a row (vary visual weight)
- Pure #000/#fff; untinted grays; uniform section spacing
- Lorem ipsum, invented metrics; placeholders must be marked TODO
- AI copy tells: "It's not just X, it's Y", tricolons, empty intensifiers,
  em-dash spam, hollow CTAs
- Accent colors spread wide: the sample's accent discipline (tiny areas)
  must survive into your build

## MUST (craft floor — see references/)

Read `references/refactoring-ui.md` (personality, color, layout frameworks)
and `references/design-principles.md` (S-tier checklist) before designing.
Token discipline: all values via CSS variables from DIRECTION.md; spacing on
4/8 with meaningful variation; type scale ~1.25; dark mode via semantic
tokens; motion 150–300ms, one orchestrated moment, respect reduced-motion.

## Verify loop — AFTER coding, MANDATORY (playwright)

1. Screenshot 1440 / 768 / 375; light+dark; hover/focus/disabled; console clean.
2. **Put the render NEXT TO the sample** — same crop where possible. Grade:
   does the material match (surfaces, accents, type, spacing), does the page
   still match what the user picked, Vietnamese diacritics not clipping?
3. Audit against both reference files (contrast AA, focus, hierarchy, density).
4. Triage [Blocker]/[High]/[Medium]/[Nit]; fix Blocker+High; re-screenshot.

## Quality floor

Before delivering, clear all four. A floor, not the goal — passing these says
nothing about whether the design is good.

- **Contrast** — text and UI affordances meet WCAG AA against their real
  background, in both light and dark.
- **Touch targets** — anything tappable is ≥44×44px, including icon-only buttons.
- **Layout stability** — no CLS: images and async blocks reserve their space.
- **Keyboard** — every interactive element reachable by Tab, focus ring visible,
  Esc closes overlays, focus returns where it came from.
