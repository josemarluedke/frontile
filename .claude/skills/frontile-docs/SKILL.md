---
name: frontile-docs
description: Write, review, and audit Frontile component documentation — the co-located `.md` files next to each `.gts` under `packages/frontile/src/components/`. Use this whenever the user is documenting a new component, editing any component `.md`, adding or changing usage demos, or asking whether the docs are accurate, complete, or consistent. Also use it whenever a change touches a component's public arguments, yielded blocks, or styling, because the docs and the JSDoc that generates the API table have to move with the code — reach for it even when the user only asked for the code change and didn't mention docs at all.
---

# Frontile component documentation

Frontile's docs are not a description of the library sitting beside it — they *are* the
library's demo surface. Docfy renders every ` ```gts preview ` fence on frontile.dev as a
live, running component. A wrong class name is a broken demo, not a typo. An argument you
invent is a runtime error on a public page. That's the reason this skill leans so hard on
reading source before writing prose: in this repo, documentation is executable.

## The one thing that surprises people

**You do not hand-write the API table.** `## API` contains a single tag:

```md
<Signature @component="Button" />
```

That renders from `site/app/components/signature-data.ts`, which
`site/lib/generate-signature-data.js` generates by running `glimmer-docgen-typescript`
over `packages/*/declarations/`. So the description, type, and default of every argument
come from **JSDoc on the `Args` interface in the `.gts` file**. An argument with no JSDoc
renders as a blank row on the site.

This means documenting an argument is usually a change to the `.gts`, not the `.md`:

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

Use `@defaultValue` for anything with a default — it becomes its own column. Describe what
the argument *is for*, not what its type already says ("The button appearance", not "A
string that can be default, soft, outlined…"). After changing JSDoc, regenerate:

```bash
pnpm --filter frontile build && pnpm --filter site generate-signature-data
```

Never restate the full argument list as a prose table in the `.md` — it will drift from the
generated one, and readers get two conflicting sources. Prose earns its place by covering
what the type signature *can't* say: when to reach for one appearance over another, which
arguments interact, what happens on mobile.

## Workflow

### 1. Ground yourself in the source before writing a word

Docs that describe an API the model half-remembers are the main failure mode here, and they
are expensive because a wrong demo ships to a public site. Read, for the component you're
documenting:

- **`<name>.gts`** — the `Args` interface (every argument, which are required, which have
  `@defaultValue`), the `Blocks` type (what it yields, and with what), the `Element` type,
  and any yielded sub-components (`<Form.Input>`, `<Dropdown.Menu>`) it exposes.
- **The theme file** in `packages/theme/src/components/` — the real variant names. If the
  theme has no `size="xl"`, the docs must not either.
- **`test-app/tests/integration/components/`** — the tests encode the behaviors worth
  documenting, especially keyboard and ARIA behavior for the Accessibility section.
- **A sibling `.md` in the same category** — for house voice and section rhythm.

If the source and an existing doc disagree, the source wins and the doc is a bug. Say so
rather than quietly documenting the old behavior.

### 2. Follow the canonical structure

Full template, frontmatter schema, and the approved heading vocabulary are in
**`references/structure.md`** — read it before creating a new doc or reordering an existing
one. The shape in brief:

```
frontmatter (imports: Signature)
# ComponentName            ← one-sentence purpose, no marketing adjectives
## Import
## Usage                   ← the simplest thing that works, no options
## <Feature sections>      ← one per axis: appearances, intents, sizes, states…
## Accessibility           ← required; see step 4
## API                     ← <Signature @component="X" />
```

### 3. Write demos that actually run

Every demo is real code executing on the site. The rules that keep them running are in
**`references/demos.md`** — read it before writing your first fence. The traps that bite
most often:

- Fence ` ```gts preview `. Plain ` ```gts ` renders as a dead code block; ` ```gjs preview `
  is the legacy form and should be converted when you touch a file.
- Every demo is standalone: it must import everything it uses, including `frontile` itself.
- `eq` does not exist. Import `hash`, `array`, `fn`, `get`, `concat` from `@ember/helper`
  and `on` from `@ember/modifier`.
- Only semantic color utilities — `bg-primary`, `text-neutral-strong`, `text-on-primary-firm`.
  There is no numbered scale; `bg-primary-500` silently renders unstyled.
- Icons come from `site/components/icons`. Never paste an inline `<svg>` into a doc.

### Demos should be made of Frontile

A demo is an implicit recommendation. When a doc hand-rolls a `<button class='bg-primary
…'>` while the library ships a `<Button>`, it teaches the reader to rebuild the component —
and that markup then has to be maintained as the theme evolves. So if Frontile has a
component for the thing being shown, the demo uses it, and it's styled with our generated
utilities rather than raw Tailwind palette classes.

The honest exception is documentation whose subject *is* the token. In
`docs/theming/design-tokens/`, a bare `<div class='bg-surface-card'>` is the better demo:
putting a `<Button>` around it would obscure the one thing the reader came to see. Roughly
35 of the 36 component-free demos in the theming docs are legitimate for exactly this
reason. Raw palette classes (`bg-blue-500`, `bg-gray-300`) are likewise fine — but only as
explicitly labeled ✗ counter-examples, never as the recommended path.

So the test isn't "does this demo import `frontile`", it's **"would a reader copying this
end up reimplementing something we already give them?"** If yes, use the component.

### 4. Treat Accessibility as load-bearing

This is the section a type signature can never generate, and it's the largest gap in the
existing docs. A component library is chosen partly on whether someone can trust its
keyboard and screen-reader behavior without reading the implementation — so document what
you verified, not what you assume. Cover, where each applies:

- **Keyboard** — every key that does something, as a two-column table. Read the tests; if a
  key isn't tested, either try it or don't claim it.
- **ARIA and roles** — the roles the component sets, and any `aria-*` the consumer is
  responsible for supplying (a `@label` on an icon-only control, for instance).
- **Focus management** — where focus moves on open, where it returns on close, what is
  trapped. Link `docs/accessibility/focus-management.md` rather than restating it.
- **Screen reader notes** — announcements, live regions, anything visually implied that
  needs a text equivalent.

For a genuinely presentational component (Divider, Spinner, Skeleton) the honest section is
short — say what role it takes and what the consumer must label. Don't pad it.

### 5. Verify before you claim it's done

```bash
node .claude/skills/frontile-docs/scripts/lint-docs.mjs      # all component docs
node .claude/skills/frontile-docs/scripts/lint-docs.mjs packages/frontile/src/components/forms/input.md
```

The linter handles the mechanical half — required sections, fence languages, `<Signature>`
wiring (including a tag naming a component that isn't in the generated data, which renders
as an empty API entry and is otherwise only a line in the build log), arguments used in
demos that don't exist in the signature, arguments missing the JSDoc that populates the
API table. It exits non-zero on errors, so it can run in CI. Fix
what it reports, then re-run rather than assuming.

Then confirm the demos actually render, since the linter can't execute them:

```bash
cd site && pnpm build
```

Report honestly: if `pnpm build` didn't run, say the demos are unverified.

## Reviewing and auditing existing docs

You have editorial authority here — cut verbose prose, merge redundant examples, and shorten
bloated files. Length is itself a defect: `form.md` is 1,903 lines, and nobody reads to the
end of it. What earns its place is a runnable example or a fact the reader can't get from
the API table. What doesn't: restated types, marketing adjectives ("powerful", "flexible",
"modern"), and three examples demonstrating one idea.

Two things to be careful with, because they look like fat and aren't:

- **A demo that looks redundant may cover a distinct state.** Check what's different before
  merging — controlled vs. uncontrolled, single vs. multiple selection.
- **Prose explaining a footgun.** The `class` vs. `@class` note in `button.md` is exactly the
  kind of thing that belongs in prose and would be lost in a cut.

When you delete a substantial example or section, say what you removed and why in your
summary, so the user can push back on a specific call rather than re-reading the diff.

For a multi-file audit, run the linter across everything first and work from its output —
it's cheaper and more consistent than reading 31 files, and it won't miss the boring
mechanical failures while chasing the interesting editorial ones.

## Repo facts worth not re-deriving

- Component source and docs live **only** in `packages/frontile/src/components/<category>/`.
  The `buttons/`, `forms/`, `collections/`, etc. packages are deprecation wrappers — never
  add docs there.
- Everything imports from the single `frontile` package: `import { Button } from 'frontile';`
- Docfy sources the repo-root `docs/` directory too (theming, migrations, accessibility).
  Component API changes with migration impact belong in `docs/migrations/` as well.
- Notifications are the exception to co-location: `NotificationCard` and
  `NotificationsContainer` are documented together in
  `packages/frontile/docs/notifications-usage.md`, because they're only ever used as a pair.
  The linter reports them as missing docs — that's expected, not a gap.
- New components get `label: New` in frontmatter, which renders a sidebar badge. Remove it
  once the component has shipped for a release or two.
