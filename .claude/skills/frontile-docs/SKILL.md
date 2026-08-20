---
name: frontile-docs
description: Write, review, and audit Frontile component documentation — the co-located `.md` files next to each `.gts` under `packages/frontile/src/components/`. Use this whenever the user is documenting a new component, editing any component `.md`, adding or changing usage demos, or asking whether the docs are accurate, complete, or consistent. Also use it whenever a change touches a component's public arguments, yielded blocks, or styling, because the docs and the JSDoc that generates the API table have to move with the code — reach for it even when the user only asked for the code change and didn't mention docs at all.
---

# Frontile component documentation

This skill is deliberately not a writing guide. It carries the mechanics of this repo's docs
pipeline that you cannot infer from reading the code, and the two places where sensible
instincts produce a wrong result here. Everything else — voice, structure, what makes a good
example — you can read off the sibling `.md` files, and they're a better teacher than prose.

Frontile's docs are the library's demo surface. Docfy renders every ` ```gts preview ` fence
on frontile.dev as a live, running component, so a wrong class name is a broken page and an
invented argument is a runtime error in public. Read the component's `.gts`, its theme file,
and its tests before writing about it.

## The API table is generated, not written

`## API` contains one tag:

```md
<Signature @component="Button" />
```

It renders from `site/app/components/signature-data.ts`, which
`site/lib/generate-signature-data.js` builds with `glimmer-docgen-typescript` from
`packages/*/declarations/`. Every argument's description and default comes from **JSDoc on
the `Args` interface in the `.gts`**. So documenting an argument is usually an edit to the
component file, and never a hand-written markdown table — a table drifts from the generated
one and gives readers two conflicting sources.

```ts
export interface ButtonArgs {
  /**
   * The button appearance
   *
   * @defaultValue 'default'
   */
  appearance?: 'default' | 'soft' | 'outlined' | 'minimal' | 'tonal' | 'custom';
}
```

An argument with no JSDoc still appears in the table, as a row with a blank description.
Comments written `/*` or `//` are silently ignored — only `/**` is collected. Check
`@defaultValue` against the theme's `defaultVariants` instead of assuming one exists.

After changing JSDoc:

```bash
pnpm build && pnpm --filter site generate-signature-data
```

**Build everything, not just the package you touched.** The generator doesn't fail on
missing declarations — it writes a file covering only what it found, silently dropping other
packages' signatures and blanking their API tables. If you regenerate before a full build,
`git checkout -- site/app/components/signature-data.ts`, build, regenerate. Then check
`git diff --stat` on that file: a diff much larger than your change, or one with mass
deletions, means this happened.

Two blind spots that follow from this:

- **A component with no `.md` is never linted**, so it quietly accumulates undocumented
  arguments. Before writing a page for one, audit its whole `Args` interface — otherwise you
  ship a polished page whose API table is a column of blank cells. Check inherited
  interfaces too: `FormControlSharedArgs` feeds Input, Select, Checkbox, Switch and more, so
  documenting it fixes many tables at once.
- **Utilities hardcoded in a component's `.gts` produce no CSS on the docs site.** Tailwind
  scans `site/` and `packages/theme/src` only. Style through the theme's variants.

## Structure

```
frontmatter (imports: Signature)
# ComponentName            ← one sentence on what it's for
## Import
## Usage                   ← the simplest thing that works
## <Feature sections>      ← one per axis: appearances, intents, sizes, states…
## Accessibility           ← required
## API                     ← <Signature @component="X" />
```

Full template, frontmatter schema (`imports` / `label` / `url`), approved heading vocabulary,
and the anatomy pattern for yielding components: **`references/structure.md`**.

`## Accessibility` is required because it's the one section a type signature can't generate:
keyboard table, roles and ARIA the consumer must supply, focus management, screen-reader
notes. Read the component's tests and document what you verified — if there's no test file,
say your claims came from source.

## Demos

Mechanics, fence rules, and the helper/icon conventions are in **`references/demos.md`**.
The four that bite most often:

- Fence ` ```gts preview `. Plain ` ```gts ` renders dead; ` ```gjs preview ` is legacy.
- Every demo is a standalone module — import everything, including `frontile` itself.
- `eq` doesn't exist. Import `hash`, `array`, `fn`, `get`, `concat` from `@ember/helper`.
- **No numbered color scale.** `bg-primary-500` isn't a class and fails silently as unstyled
  output. Use named levels: `subtle`, `muted`, `soft`, `mild`, DEFAULT, `firm`, `strong`,
  `bolder`, and `text-on-{category}-{level}` on filled backgrounds.
- Icons come from `site/components/icons`; never inline an `<svg>`.

### Demos should be made of Frontile

A demo is an implicit recommendation. Hand-rolling a `<button class='bg-primary …'>` when the
library ships `<Button>` teaches the reader to rebuild the component, and that markup then
has to be maintained as the theme changes.

The honest exception is documentation whose subject *is* the token. In
`docs/theming/design-tokens/`, a bare `<div class='bg-surface-card'>` is the better demo —
a component around it would hide the thing the reader came to see. Roughly 35 of the 36
component-free demos in the theming docs are legitimate for that reason. Raw palette classes
(`bg-blue-500`) are fine too, but only as labeled ✗ counter-examples.

So the test isn't "does this import `frontile`", it's **"would a reader copying this end up
reimplementing something we already give them?"**

## Shortening a doc

You have editorial authority over prose. Length is a real defect — `form.md` was 1,903 lines
— and most of that weight is text: restated types, marketing adjectives, orphaned notes, and
paragraphs explaining what the demo below already shows. Cut all of it freely.

**Demos are not prose, and the same authority does not extend to them.** Prose can be
rewritten from the source at any time; a demo is executable proof that a combination of
arguments does what the docs claim, it is what readers copy, and it is the only part of the
page the site runs. Replacing a demo with a sentence describing it converts checked behavior
into an unchecked assertion — and it's invisible in review, because the page gets shorter
and reads better while coverage drops.

The reduction you want comes from prose. Before removing any demo:

1. Name the state it exercises — which arguments, which mode, which interaction.
2. Find a demo you are **keeping** that exercises that same state.
3. If you can't name one, the demo stays.

"Both demos are about `@isOpen`" is not step 2. Two demos sharing an argument can still
exercise different states — controlled vs. uncontrolled, single vs. multiple selection, one
panel vs. several, nested vs. flat, initially-open vs. opening on interaction. Readers also
navigate by scenario: someone looking for an accordion won't recognize their problem in a
demo called "Basic".

When two demos genuinely do exercise the same state, **consolidate rather than delete** —
one demo with several instances, or an `{{#each}}` over the varying values. The duplication
goes, the coverage stays.

Keep footguns in prose: the `class` vs. `@class` note in `button.md` is a fact no demo
conveys, and it would be lost in an undifferentiated cut.

Then report demo count before → after, the retained demo covering each removal, and one line
on what prose you cut. If that list is uncomfortable to write, you removed coverage, not fat.

## Keep the change the size of the request

Reading the source surfaces adjacent problems — a wrong class in a neighbouring doc, a broken
theme variant, a missing test. Documenting one component is not licence to fix them. Report
what you found and leave it, unless your change is actually wrong without it. A docs edit
that also rewrites the theme package is hard to review and buries the part that was asked
for. When you must reach outside the doc and its component, say so and say why.

## Verify

```bash
node .claude/skills/frontile-docs/scripts/lint-docs.mjs                    # everything
node .claude/skills/frontile-docs/scripts/lint-docs.mjs --since HEAD FILE   # + demo loss
```

Zero dependencies, so it runs without `node_modules`, and it exits non-zero on errors for
CI. It covers required sections, fence languages, `<Signature>` wiring including tags naming
a component that doesn't exist, arguments used in demos that aren't in the signature,
arguments missing the JSDoc that fills the API table, numbered color utilities, raw palette
classes, inline `<svg>`, and — with `--since` — runnable demos removed since a git ref.

Demo loss warns, and errors only when more than a third of the page's demos are gone. A
warning isn't a verdict: removing one demo of seven is often real cleanup. It's a prompt to
say which retained demo covers the removed state. An error means the page lost most of its
executable coverage, which is not cleanup.

Then confirm the demos actually render, which the linter can't do:

```bash
cd site && pnpm build
```

If that didn't run, say the demos are unverified rather than implying they were checked.

## Repo facts

- Component source and docs live **only** in `packages/frontile/src/components/<category>/`.
  The `buttons/`, `forms/`, `collections/` packages are deprecation wrappers — never add
  docs there.
- Everything imports from one package: `import { Button } from 'frontile';`
- Docfy also sources the repo-root `docs/` (theming, migrations, accessibility). API changes
  with migration impact belong in `docs/migrations/` too.
- Notifications are the co-location exception: `NotificationCard` and
  `NotificationsContainer` are documented together in
  `packages/frontile/docs/notifications-usage.md`. The linter reports them as missing docs;
  that's expected.
- New components get `label: New` in frontmatter for a sidebar badge. Drop it after a
  release or two.
