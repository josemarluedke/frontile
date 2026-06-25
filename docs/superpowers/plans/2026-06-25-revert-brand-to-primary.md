# Revert `brand` → `primary` Color Naming Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the Frontile semantic color category `brand` (and its contrast pair `on-brand`) back to `primary`/`on-primary` across source, theme components, docs, the site, and the test-app — a clean replacement with no backward-compat alias.

**Architecture:** The color category name lives in three source-of-truth files (`semantic.ts` defines the values, `types.ts` defines the type, `resolve.ts` lists the prefix that drives Tailwind class + CSS-variable generation). Everything else *consumes* generated Tailwind classes (`bg-brand-*`, `text-on-brand-*`, etc.) or `colors.brand.*` / `--color-brand-*` references. We flip the source of truth, then sweep all consumer usages with targeted token replacements, handling object/map **keys** and the migration guide explicitly. Prose uses of the English word "brand" are deliberately left untouched.

**Tech Stack:** Ember Octane + Glimmer, TypeScript/Glint, Tailwind CSS + Tailwind Variants, `@frontile/theme` plugin, pnpm workspaces, docfy (renders markdown code fences as live demos).

**Reference spec:** `docs/superpowers/specs/2026-06-25-revert-brand-to-primary-design.md`

**Branch:** Work on `revert/brand-to-primary` (already created).

---

## Token replacement reference (used by Task 2)

The following `sed` substitution set is the canonical "token sweep". It only matches token-shaped strings and CSS-variable names, never the English word "brand" in prose. macOS `sed` requires `-i ''`.

```
-e 's/bg-brand/bg-primary/g'
-e 's/text-brand/text-primary/g'
-e 's/border-brand/border-primary/g'
-e 's/ring-brand/ring-primary/g'
-e 's/fill-brand/fill-primary/g'
-e 's/from-brand/from-primary/g'
-e 's/to-brand/to-primary/g'
-e 's/on-brand/on-primary/g'
-e 's/--color-brand/--color-primary/g'
-e 's/--frontile-brand/--frontile-primary/g'
-e 's/--brand-/--primary-/g'
-e 's/colors\.brand/colors.primary/g'
-e 's/hero-glow-orb--brand/hero-glow-orb--primary/g'
```

These substitutions are disjoint (no pattern corrupts another's output), so order does not matter.

---

### Task 1: Flip the source-of-truth color category

**Files:**
- Modify: `packages/theme/src/colors/semantic.ts` (lines 24, 200)
- Modify: `packages/theme/src/colors/types.ts` (lines ~51, 53, 58, 322, 332)
- Modify: `packages/theme/src/plugin/resolve.ts` (line 64)

- [ ] **Step 1: Rename the `brand` key in `semantic.ts` (both themes)**

There are exactly two occurrences, the `brand:` block in `themeColorsLight` (line 24) and in `themeColorsDark` (line 200). Both are indented two spaces. Change each `  brand: {` to `  primary: {`. Leave every color value (oklch strings, `palette.*` refs) unchanged.

Run this scoped replacement:

```bash
cd /Users/jluedke/code/oss/frontile
sed -i '' -e 's/^  brand: {/  primary: {/' packages/theme/src/colors/semantic.ts
```

- [ ] **Step 2: Verify exactly two lines changed in `semantic.ts`**

Run:
```bash
grep -n -E '^\s*(brand|primary): {' packages/theme/src/colors/semantic.ts
```
Expected: two `primary: {` lines (24, 200), zero `brand: {` lines.

- [ ] **Step 3: Update the type definition and doc-comment example in `types.ts`**

Make these edits (use the Edit tool, matching exact text):

1. Type key — change:
```ts
  brand: SemanticColorCategory;
```
to:
```ts
  primary: SemanticColorCategory;
```

2. Optional on-color key — change:
```ts
  'on-brand'?: OnColorCategory;
```
to:
```ts
  'on-primary'?: OnColorCategory;
```

3. Doc-comment example — change:
```ts
 * // Override on-colors for brand
 * const colors: Partial<ThemeColors> = {
 *   brand: {
```
to:
```ts
 * // Override on-colors for primary
 * const colors: Partial<ThemeColors> = {
 *   primary: {
```

4. Doc-comment example on-color key — change:
```ts
 *   'on-brand': {
```
to:
```ts
 *   'on-primary': {
```

**Leave line ~48 untouched** — `* that match your brand or design requirements.` is prose.

- [ ] **Step 4: Update the prefix list in `resolve.ts`**

In the `SEMANTIC_COLOR_PREFIXES` array, change:
```ts
  'brand',
```
to:
```ts
  'primary',
```

- [ ] **Step 5: Verify no `brand` category key remains in the three source files**

Run:
```bash
grep -nE "brand" packages/theme/src/colors/semantic.ts packages/theme/src/colors/types.ts packages/theme/src/plugin/resolve.ts
```
Expected: a single match — the prose line in `types.ts` ("...match your brand or design requirements."). Nothing else.

- [ ] **Step 6: Build the theme package to confirm it compiles**

Run:
```bash
pnpm --filter @frontile/theme build
```
Expected: build succeeds (no TypeScript errors). Component theme styles still reference `bg-brand-*` at this point — that is expected and fixed in Task 2; the build does not fail on unknown utility class strings.

- [ ] **Step 7: Commit**

```bash
git add packages/theme/src/colors/semantic.ts packages/theme/src/colors/types.ts packages/theme/src/plugin/resolve.ts
git commit -m "refactor(theme): rename brand color category back to primary

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: Sweep all token-class and CSS-variable usages

**Files:** All tracked files under `packages/`, `site/`, `test-app/`, `docs/` that reference a brand token — **excluding** `docs/superpowers/**` (the spec/plan) and `docs/migrations/v0.18/semantic-colors.md` (rewritten explicitly in Task 4). Object/map **keys** (e.g. `brand: {`, `'brand-soft'`) are NOT touched here and are handled in Task 3.

- [ ] **Step 1: Build the list of files to sweep**

```bash
cd /Users/jluedke/code/oss/frontile
git grep -lE '(bg|text|border|ring|fill|from|to)-brand|on-brand|--color-brand|--frontile-brand|--brand-|colors\.brand|hero-glow-orb--brand' -- packages site test-app docs \
  | grep -vE '^docs/superpowers/|^docs/migrations/v0\.18/semantic-colors\.md$' \
  > /tmp/brand-sweep-files.txt
cat /tmp/brand-sweep-files.txt
```
Expected: a list including `packages/theme/src/components/*.ts`, several `docs/theming/**/*.md`, `docs/migrations/v0.18/{index,theme-configuration}.md`, `packages/theme/README.md`, `packages/frontile/src/**/*.md`, `site/app/**`, and `test-app/app/**`. Confirm `docs/superpowers/` and `semantic-colors.md` are absent.

- [ ] **Step 2: Apply the token sweep to every listed file**

```bash
cd /Users/jluedke/code/oss/frontile
while IFS= read -r f; do
  sed -i '' \
    -e 's/bg-brand/bg-primary/g' \
    -e 's/text-brand/text-primary/g' \
    -e 's/border-brand/border-primary/g' \
    -e 's/ring-brand/ring-primary/g' \
    -e 's/fill-brand/fill-primary/g' \
    -e 's/from-brand/from-primary/g' \
    -e 's/to-brand/to-primary/g' \
    -e 's/on-brand/on-primary/g' \
    -e 's/--color-brand/--color-primary/g' \
    -e 's/--frontile-brand/--frontile-primary/g' \
    -e 's/--brand-/--primary-/g' \
    -e 's/colors\.brand/colors.primary/g' \
    -e 's/hero-glow-orb--brand/hero-glow-orb--primary/g' \
    "$f"
done < /tmp/brand-sweep-files.txt
```

- [ ] **Step 3: Confirm no token-class brand usages remain in swept files**

```bash
git grep -nE '(bg|text|border|ring|fill|from|to)-brand|on-brand|--color-brand|--frontile-brand|--brand-|colors\.brand|hero-glow-orb--brand' -- packages site test-app docs \
  | grep -vE '^docs/superpowers/|^docs/migrations/v0\.18/semantic-colors\.md'
```
Expected: **no output**. (Remaining `brand` references are object keys handled in Task 3, the migration guide handled in Task 4, and prose.)

- [ ] **Step 4: Commit (stage only the swept files)**

```bash
cd /Users/jluedke/code/oss/frontile
git add $(cat /tmp/brand-sweep-files.txt)
git commit -m "refactor: sweep brand token classes and CSS vars to primary

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: Rename remaining object/map keys

After Task 2, several files still contain the literal category **key** `brand` (in config objects, label maps, and the swatch key list). These are not token-shaped, so the sweep skipped them.

**Files:**
- Modify: `site/app/utils/theme-colors.ts` (lines 37, 81, 96)
- Modify: `site/app/components/theme-docs/color-swatch.gts` (lines 40-47, 92-99)
- Modify: `site/app/templates/index.gts` (lines 894, 910 — CodeBlock config sample)
- Modify: `packages/theme/README.md` (lines 88, 97, 117, 142, 170 — config examples)

- [ ] **Step 1: `theme-colors.ts` — rename category key, array entry, and label (keep descriptions)**

Make three edits with the Edit tool:

1. Array entry — change:
```ts
  'brand',
```
to:
```ts
  'primary',
```

2. Display label — change:
```ts
    brand: 'Brand',
```
to:
```ts
    primary: 'Primary',
```

3. Description key only — change:
```ts
    brand: 'Primary brand colors for important actions and brand elements',
```
to:
```ts
    primary: 'Primary brand colors for important actions and brand elements',
```
(The description text intentionally keeps the word "brand" — only the key changes.)

- [ ] **Step 2: `color-swatch.gts` — rename the `'brand-*'` map keys**

The values (`bg-brand-*`, `text-on-brand-*`) were already converted to `primary` in Task 2; only the quoted keys remain. Apply a file-scoped replacement of quoted keys beginning with `brand-`:

```bash
cd /Users/jluedke/code/oss/frontile
sed -i '' -e "s/'brand-/'primary-/g" site/app/components/theme-docs/color-swatch.gts
```

- [ ] **Step 3: `index.gts` — rename the `brand: {` keys inside the CodeBlock config sample**

These appear at lines 894 and 910 inside the `@code="..."` string (light and dark theme samples). Apply a file-scoped replacement:

```bash
cd /Users/jluedke/code/oss/frontile
sed -i '' -e 's/        brand: {/        primary: {/g' site/app/templates/index.gts
```
Expected: two replacements. (The displayed token `bg-primary-medium` in the trailing `<code>` was already handled by Task 2.)

- [ ] **Step 4: `README.md` — rename the `brand: {` config keys**

Apply a file-scoped replacement of the config object key (8-space indent in the override examples). Inspect first, then replace:

```bash
cd /Users/jluedke/code/oss/frontile
grep -nE '^\s*brand: \{' packages/theme/README.md
sed -i '' -E 's/^([[:space:]]*)brand: \{/\1primary: {/g' packages/theme/README.md
```
Expected: the 5 config-example `brand: {` keys become `primary: {`. The `'on-brand': {` keys were already converted to `'on-primary': {` in Task 2, and the prose "match your brand or design requirements" (line ~132) is untouched.

- [ ] **Step 5: Verify only intentional prose `brand` remains in these files**

```bash
git grep -n -i brand -- site/app/utils/theme-colors.ts site/app/components/theme-docs/color-swatch.gts site/app/templates/index.gts packages/theme/README.md
```
Expected: only the two description strings in `theme-colors.ts` ("Primary brand colors…", "Secondary brand colors…") and the README prose line ("…match your brand or design requirements"). No keys, no token classes.

- [ ] **Step 6: Commit**

```bash
git add site/app/utils/theme-colors.ts site/app/components/theme-docs/color-swatch.gts site/app/templates/index.gts packages/theme/README.md
git commit -m "refactor: rename remaining brand object/map keys to primary

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: Rewrite the v0.18 migration guide

The migration guide currently documents `primary-* → brand-*` as a v0.18 breaking change. Since `brand` is reverted to `primary`, the guide must read as if `brand` never existed: the new system documented with `primary`, mapping the *old numbered* `primary-{n}` scale to the *new* `primary-{level}` levels.

**Files:**
- Modify: `docs/migrations/v0.18/semantic-colors.md`
- Modify: `docs/migrations/v0.18/index.md` (line 66)

- [ ] **Step 1: `semantic-colors.md` — fix the "Color Categories Renamed" table**

Change the `primary-* → brand-*` row. Replace:
```md
| `primary-*` | `brand-*`   | Renamed to distinguish brand colors from semantic intent |
```
with:
```md
| `primary-*` | `primary-*` | ✓ Name unchanged — only the numbered scale moved to named levels |
```

- [ ] **Step 2: `semantic-colors.md` — rewrite the "Brand (formerly Primary)" mapping section**

Replace the entire section heading and table (the `#### Brand (formerly Primary)` block, originally lines ~86-98) with:

```md
#### Primary

| Old Class                 | New Class                                  | Context                |
| ------------------------- | ------------------------------------------ | ---------------------- |
| `bg-primary`              | `bg-primary-medium` or `bg-primary`        | Standard primary color |
| `bg-primary-500`          | `bg-primary-soft` or `bg-primary-medium`   | Hover states           |
| `bg-primary-600`          | `bg-primary-medium`                        | Default buttons        |
| `bg-primary-700`          | `bg-primary-medium` or `bg-primary-strong` | Strong emphasis        |
| `bg-primary-800`          | `bg-primary-strong`                        | Active/pressed states  |
| `text-primary`            | `text-primary-medium` or `text-primary`    | Primary text           |
| `text-primary-foreground` | `text-on-primary-medium`                   | Contrasting text on bg |
| `border-primary`          | `border-primary-medium`                    | Primary borders        |
| `ring-primary-500`        | `ring-primary-soft`                        | Focus rings            |
```

- [ ] **Step 3: `semantic-colors.md` — fix the "Primary/Brand Button" example**

Replace:
```md
#### Primary/Brand Button

```gts
// Before
<button class="bg-primary text-primary-foreground hover:bg-primary-500">
  Submit
</button>

// After
<button class="bg-brand text-on-brand hover:bg-brand-soft">
  Submit
</button>
```
```
with:
```md
#### Primary Button

```gts
// Before
<button class="bg-primary text-primary-foreground hover:bg-primary-500">
  Submit
</button>

// After
<button class="bg-primary text-on-primary hover:bg-primary-soft">
  Submit
</button>
```
```

- [ ] **Step 4: `semantic-colors.md` — fix the "Outlined Button", "Form Inputs", theme-config, and `sed` examples**

1. Outlined button "After" — replace:
```gts
<button class="border-brand text-brand hover:bg-brand hover:text-on-brand">
  Cancel
</button>
```
with:
```gts
<button class="border-primary text-primary hover:bg-primary hover:text-on-primary">
  Cancel
</button>
```

2. Form input "After" — replace:
```gts
<input class="border-neutral-soft focus:border-brand text-neutral-strong" />
```
with:
```gts
<input class="border-neutral-soft focus:border-primary text-neutral-strong" />
```

3. Theme-config "After" example — replace:
```typescript
colors: {
  neutral: semanticColors.light.neutral,
  brand: semanticColors.light.brand,
}
```
with:
```typescript
colors: {
  neutral: semanticColors.light.neutral,
  primary: semanticColors.light.primary,
}
```

4. Automated-migration `sed` snippet — replace the three brand lines:
```bash
  -e 's/bg-primary/bg-brand/g' \
  -e 's/text-primary/text-brand/g' \
  -e 's/border-primary/border-brand/g' \
```
with the numbered-scale guidance (the category name no longer changes, only the numbered scale → levels, which can't be safely automated). Replace those three lines with:
```bash
  -e 's/bg-primary-[0-9]\{2,3\}/bg-primary-medium/g' \
  -e 's/text-primary-[0-9]\{2,3\}/text-primary-medium/g' \
  -e 's/border-primary-[0-9]\{2,3\}/border-primary-medium/g' \
```

- [ ] **Step 5: `index.md` — fix the rename-summary line**

Replace (line 66):
```md
- Renamed `default-*` to `neutral-*` and `primary-*` to `brand-*`
```
with:
```md
- Renamed `default-*` to `neutral-*` (the `primary-*` category name is unchanged; only its numbered scale moved to named levels)
```

- [ ] **Step 6: Verify no stray `brand` token/example remains in the migration guide**

```bash
git grep -n -i brand -- docs/migrations/v0.18/
```
Expected: no token classes and no `brand-*` mapping cells. Any remaining hit should be reviewed and, if it's a token/example, fixed; pure prose ("brand colors") is acceptable only if it reads correctly.

- [ ] **Step 7: Commit**

```bash
git add docs/migrations/v0.18/semantic-colors.md docs/migrations/v0.18/index.md
git commit -m "docs: rewrite v0.18 migration guide for primary color naming

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 5: Fix the stale numbered token in `simple-table.md`

`packages/frontile/src/components/collections/simple-table.md:486` references `border-primary-200`, a leftover from the removed numbered scale. The named-level system has no `-200`; this renders as an invalid utility.

**Files:**
- Modify: `packages/frontile/src/components/collections/simple-table.md:486`

- [ ] **Step 1: Replace the stale token**

Change:
```md
        th='font-bold text-primary-strong border-b border-primary-200'
```
to:
```md
        th='font-bold text-primary-strong border-b border-primary-soft'
```
(`text-primary-strong` is already correct from the Task 2 sweep.)

- [ ] **Step 2: Verify no numbered primary tokens remain anywhere**

```bash
git grep -nE '(bg|text|border|ring|fill)-primary-[0-9]' -- packages site test-app docs | grep -vE '^docs/superpowers/|^docs/migrations/'
```
Expected: **no output**. (Numbered classes inside the migration guide's "Old Class" columns are intentional historical references.)

- [ ] **Step 3: Commit**

```bash
git add packages/frontile/src/components/collections/simple-table.md
git commit -m "docs(table): fix stale numbered primary token in simple-table example

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 6: Build, test, lint, and type-check (verification gate)

**Files:** none (verification only).

- [ ] **Step 1: Build all packages**

```bash
cd /Users/jluedke/code/oss/frontile
pnpm build
```
Expected: all packages build successfully.

- [ ] **Step 2: Run the full test suite**

```bash
cd /Users/jluedke/code/oss/frontile/test-app && pnpm ember test
```
Expected: all tests pass. (No tests assert on `brand` classes — confirmed during planning — so this validates that components still render with the renamed tokens.)

- [ ] **Step 3: Lint templates and JS/TS**

```bash
cd /Users/jluedke/code/oss/frontile
pnpm lint:hbs --fix
pnpm lint:js --fix
```
Expected: no remaining errors. If `--fix` changes files, review and include them in the Task 6 commit.

- [ ] **Step 4: Type-check the theme package and test-app**

```bash
cd /Users/jluedke/code/oss/frontile
pnpm --filter @frontile/theme lint:types
cd test-app && pnpm lint:types
```
Expected: no type errors. (`ThemeColors.primary` now replaces `ThemeColors.brand`; any consumer referencing `.brand` in TS would surface here.)

- [ ] **Step 5: Commit any lint/format fixes**

First review what changed:
```bash
cd /Users/jluedke/code/oss/frontile
git status --short
```
Then stage only the listed modified files explicitly (substitute the actual paths from `git status`) and commit:
```bash
git add <paths shown by git status>
git commit -m "style: apply lint/format fixes after brand->primary rename

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```
(Skip this step if Steps 3-4 produced no changes.)

---

### Task 7: Final sweep and visual verification

**Files:** none (verification only).

- [ ] **Step 1: Global confirmation that only intentional prose `brand` remains**

```bash
cd /Users/jluedke/code/oss/frontile
git grep -n -i brand -- packages site test-app docs | grep -vE '^docs/superpowers/'
```
Expected: only the deliberately-kept prose:
- `packages/theme/src/colors/types.ts` — "…match your brand or design requirements."
- `packages/theme/README.md` — same phrase.
- `docs/theming/configuration/css-variables.md` — comments about brand guidelines.
- `site/app/utils/theme-colors.ts` — the two swatch descriptions.
- Any natural-language "brand colors" wording inside the migration guide that still reads correctly.

Review each remaining hit; if any is a token class, `colors.*`, CSS var, or object key, fix it and re-run.

- [ ] **Step 2: Run the docs site and visually verify rendered demos**

```bash
cd /Users/jluedke/code/oss/frontile && pnpm start
```
Then open the site and confirm the **rendered** code-fence demos show primary colors correctly on:
- Theming → Design Tokens → Colors (incl. `<ColorPaletteGrid @category="primary" />`)
- Theming → Design Tokens → Icons / Borders / Typography / Elevation / Surfaces
- Theming → Overview
- Migrations → v0.18 → Semantic Colors

Expected: all brand/primary swatches, buttons, and accents render with the blue primary color in both light and dark mode; no missing/transparent colors (which would indicate an unconverted `brand-*` class). Stop the server when done.

- [ ] **Step 3: Final completion check**

Confirm: Tasks 1-6 committed, working tree clean (`git status`), and the branch `revert/brand-to-primary` contains the full rename. The work is ready for a PR.

---

## Notes for the implementer

- **Never** convert prose uses of the word "brand" — only token classes, CSS variables, `colors.*` paths, and the category object/map keys.
- Component **variant keys** already named `primary` (e.g. `button.ts` `primary: 'focus-visible:ring-brand-soft'`) keep their key; only the token value flips — the Task 2 sweep handles the value automatically.
- Do not add a backward-compat `brand` alias; this is a clean replacement (`brand` shipped only in v0.18 pre-release).
- If `git grep` in any verification step returns an unexpected hit, treat it as a real gap: fix it, re-run the step, then continue.
