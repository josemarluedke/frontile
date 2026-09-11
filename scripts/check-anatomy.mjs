#!/usr/bin/env node
// Cross-file anatomy coverage check.
//
// The per-element half of the anatomy invariant (an element that renders a
// tv() slot must carry a matching data-part, kebab-cased) is enforced by the
// `frontile/require-data-part` ember-template-lint rule. This script enforces
// the cross-file half: every slot a theme config declares is actually
// rendered somewhere as a data-part, and every data-part rendered actually
// names a real slot.
//
// This has to be a Node script rather than a test-app test because
// test-app's QUnit tests run in the browser and cannot read source files off
// disk. This script reads:
//   - packages/theme/src/components/**/*.ts   (tv() slot configs)
//   - packages/frontile/src/components/**/*.gts (data-component/data-part usage)
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, extname, basename, dirname } from 'node:path';

const kebab = (s) => s.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();

// Files that hold no component anatomy of interest.
// - forms-legacy.ts: the legacy form package is out of scope for the whole
//   anatomy-attributes plan (it is not being migrated).
// - index.ts / shared.ts: barrels / shared helpers, not component configs.
const EXCLUDED_BASENAMES = new Set([
  'forms-legacy.ts',
  'index.ts',
  'shared.ts'
]);

function walk(dir, ext, out = []) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) walk(p, ext, out);
    else if (extname(p) === ext) out.push(p);
  }
  return out;
}

/**
 * Starting at `src[openIdx]` (which must be `{`), find the index of its
 * matching closing brace, skipping over braces that appear inside string
 * literals (single/double/backtick quoted, with backslash escapes) or
 * comments (`//…` and `/*…*\/`).
 *
 * Comments matter here, not just strings: this codebase's tv() configs carry
 * prose comments (e.g. "the column's skeleton preset"), and an apostrophe in
 * an ordinary English contraction is an *unbalanced* single quote. Tracking
 * strings without also skipping comments lets that stray quote flip the
 * scanner into "inside a string" for the rest of the file, so brace-counting
 * silently loses track and `findMatchingBrace` runs off the end.
 */
function findMatchingBrace(src, openIdx) {
  let depth = 0;
  let inString = null;
  for (let i = openIdx; i < src.length; i++) {
    const c = src[i];
    if (inString) {
      if (c === '\\') {
        i++; // skip escaped char
      } else if (c === inString) {
        inString = null;
      }
      continue;
    }
    if (c === '/' && src[i + 1] === '/') {
      i = src.indexOf('\n', i);
      if (i === -1) break;
      continue;
    }
    if (c === '/' && src[i + 1] === '*') {
      const end = src.indexOf('*/', i + 2);
      if (end === -1) break;
      i = end + 1;
      continue;
    }
    if (c === '"' || c === "'" || c === '`') {
      inString = c;
      continue;
    }
    if (c === '{') depth++;
    else if (c === '}') {
      depth--;
      if (depth === 0) return i;
    }
  }
  return -1;
}

/**
 * Parse every `const <name> = tv({ … })` config in a theme source file into
 * `{ name: { ownSlots: [kebabSlot, …] | null, extends: identifierOrNull } }`.
 *
 * `ownSlots` is `null` when the config has no top-level `slots: { … }` key at
 * all (e.g. `button`, `divider`) — as opposed to `[]`, which means it *has* a
 * `slots:` key but happens to declare zero keys under it. That distinction is
 * what `readThemeSlots` uses to decide whether a config counts as
 * slot-bearing on its own, independently of what it might inherit.
 *
 * Slots are looked up as a *top-level* key of the tv() config body (exactly
 * two-space indentation in this codebase) rather than requiring `slots` to
 * be the very first key — several real configs (e.g. `select` in
 * forms/forms.ts) declare `extend:` before `slots:`, which a
 * "slots must immediately follow tv({" regex would miss entirely.
 */
function parseThemeFile(src) {
  const configs = {};
  const declRe = /const\s+(\w+)\s*=\s*tv\(\s*\{/g;
  let m;
  while ((m = declRe.exec(src))) {
    const name = m[1];
    const openBrace = m.index + m[0].lastIndexOf('{');
    const closeBrace = findMatchingBrace(src, openBrace);
    if (closeBrace === -1) {
      throw new Error(
        `check-anatomy: could not find end of tv() config for "${name}"`
      );
    }
    const body = src.slice(openBrace + 1, closeBrace);

    const extendMatch = /^ {2}extend\s*:\s*(\w+)/m.exec(body);

    const slotsKeyRe = /^ {2}slots\s*:\s*\{/m;
    const slotsMatch = slotsKeyRe.exec(body);
    if (!slotsMatch) {
      configs[name] = { ownSlots: null, extends: extendMatch?.[1] ?? null };
      continue; // no `slots:` key -> not slot-bearing on its own
    }

    const slotsOpen = slotsMatch.index + slotsMatch[0].lastIndexOf('{');
    const slotsClose = findMatchingBrace(body, slotsOpen);
    if (slotsClose === -1) {
      throw new Error(
        `check-anatomy: could not find end of "slots" block for ${name}`
      );
    }
    const slotsBody = body.slice(slotsOpen + 1, slotsClose);

    const keyRe = /^ {4}(\w+)\s*:/gm;
    const ownSlots = [...slotsBody.matchAll(keyRe)].map((k) => kebab(k[1]));
    configs[name] = { ownSlots, extends: extendMatch?.[1] ?? null };
  }
  return configs;
}

/**
 * Resolve a config's full slot set: its own slot keys plus, when it
 * `extend`s another config, that config's own resolved slot set. A config
 * that uses `extend` to pull in shared variant logic (e.g. `checkbox`
 * extending `checkboxRadioBase`) genuinely renders its parent's slots too —
 * `checkboxRadioBase` supplies `base`/`labelContainer`/`label`, and `checkbox`
 * only re-declares the `input` slot it overrides. Treating each config's own
 * `slots:` object as the complete picture would under-report what a
 * migrated component actually has to render.
 */
function resolveSlots(name, raw, cache) {
  if (cache.has(name)) return cache.get(name);
  const entry = raw[name];
  if (!entry) return [];
  cache.set(name, []); // cycle guard: break `extend` loops, if any exist
  let keys = [...(entry.ownSlots ?? [])];
  if (entry.extends) {
    const parentKeys = resolveSlots(entry.extends, raw, cache);
    keys = [...new Set([...parentKeys, ...keys])];
  }
  cache.set(name, keys);
  return keys;
}

/**
 * Read every slot-bearing tv() config under `themeDir`: `{ configName:
 * [kebabSlot, …] }`. A config counts as slot-bearing when it either has its
 * own `slots:` key (see `parseThemeFile`) or its *resolved* slot set (own
 * slots plus anything inherited through `extend`) is non-empty.
 *
 * The resolved check matters on its own: several real configs (e.g.
 * `radioGroup`/`checkboxGroup` in forms/forms.ts) declare only
 * `extend: checkboxRadioGroupBase` with no own `slots:` key at all — they
 * inherit their entire slot set from the base they extend. Gating inclusion
 * on "has its own `slots:` key" alone (as an earlier version of this function
 * did) drops such configs from the map entirely: `checkAnatomy` never even
 * looks at them, so a component like `RadioGroup` that renders
 * `data-component="radio-group"` with zero `data-part` attributes reports
 * `{ missing: [], orphan: [] }` — silently passing a component that in fact
 * covers none of its inherited slots.
 */
/**
 * Parse every slot-bearing tv() config under `themeDir` into
 * `{ name: { ownSlots, extends } }` (see `parseThemeFile`'s doc for the
 * shape), skipping files this check has no interest in. Shared by
 * `readThemeSlots` (the cross-file coverage check) and
 * `readSlotlessConfigNames` (consulted by the `frontile/require-data-part`
 * lint rule, see that function's doc) so both stay in sync with exactly one
 * parse of the theme package.
 */
function readRawThemeConfigs(themeDir) {
  const raw = {};
  for (const file of walk(themeDir, '.ts')) {
    if (EXCLUDED_BASENAMES.has(basename(file))) continue;
    Object.assign(raw, parseThemeFile(readFileSync(file, 'utf8')));
  }
  return raw;
}

export function readThemeSlots(themeDir) {
  const raw = readRawThemeConfigs(themeDir);
  const cache = new Map();
  const configs = {};
  for (const [name, entry] of Object.entries(raw)) {
    const resolved = resolveSlots(name, raw, cache);
    // Include when the config declares its own `slots:` key (even if empty)
    // or when it inherits a non-empty slot set through `extend`.
    if (entry.ownSlots === null && resolved.length === 0) {
      // A config with no `slots:` key at all (e.g. `button`, `divider`) and
      // nothing *slot-shaped* inherited through `extend` is a
      // single-element component: it implicitly has one slot, `base`, even
      // though tv() never spells it out as a slots object. Without this,
      // such configs are invisible to this script -- a component that
      // forgets `data-component` (or puts it on the wrong element) entirely
      // on such a config passes silently. This applies even when the config
      // `extend`s another config (e.g. `button` extends `baseButton`): the
      // extend chain resolved to an empty slot set too (`baseButton` has no
      // `slots:` key either), so there is still no real, named slot
      // anywhere in the chain -- just a single implicit `base`. A config
      // that inherits a genuinely non-empty slot set via `extend` takes the
      // branch below instead and never reaches here.
      configs[name] = ['base'];
      continue;
    }
    configs[name] = resolved;
  }
  return configs;
}

/**
 * The set of top-level tv() config names (the literal JS identifier, e.g.
 * `skeleton`, `spinner`, `divider` -- NOT kebab-cased) that are "slotless":
 * no `slots:` key of their own, and nothing slot-shaped inherited through
 * `extend` either (the same condition `readThemeSlots` uses to decide a
 * config gets the implicit single `base` slot -- see the comment there).
 *
 * Consulted by the `frontile/require-data-part` ember-template-lint rule
 * (`lint/rules/require-data-part.mjs`) to resolve a real ambiguity: when a
 * template does `{{styles.skeleton class=@class ...}}` (or, destructured,
 * bare `{{divider ...}}`), the final path segment names the *whole config*
 * being invoked directly -- not a slot inside some other multi-slot config
 * that happens to be in scope under the same name. Confusing the two made
 * the rule demand `data-part="skeleton"` on Skeleton's root element, when
 * the correct, already-applied convention for a slotless config's one
 * element is `data-part="base"` (matching `readThemeSlots`'s own modeling).
 * The rule uses this export to tell "the whole config, called directly" apart
 * from "a slot of some other config", without duplicating the parsing logic
 * that already lives here.
 */
export function readSlotlessConfigNames(themeDir) {
  const raw = readRawThemeConfigs(themeDir);
  const cache = new Map();
  const names = new Set();
  for (const name of Object.keys(raw)) {
    const resolved = resolveSlots(name, raw, cache);
    if (raw[name].ownSlots === null && resolved.length === 0) {
      names.add(name);
    }
  }
  return names;
}

function extractAttrOccurrences(src, attrName) {
  const re = new RegExp(`${attrName}="([a-z0-9-]+)"`, 'g');
  const out = [];
  let m;
  while ((m = re.exec(src))) out.push({ value: m[1], index: m.index });
  return out;
}

/**
 * Attribute a .gts file's data-part occurrences to a component name when the
 * file itself carries no data-component (e.g. a sub-template like
 * `overlays/modal/body.gts`, invoked by `overlays/modal.gts`'s root element).
 *
 * We walk up the file's ancestor directories (starting at its immediate
 * parent) and return the first directory name that kebab-cases to a known
 * config name. This is deliberately a directory *name* search rather than
 * the brief sketch's "shares the exact same parent directory as some file
 * that has a data-component" check: that check breaks for exactly this
 * nested-directory shape, since `overlays/modal.gts` and
 * `overlays/modal/body.gts` do not share a parent directory at all. Walking
 * up by name instead correctly attributes `overlays/modal/body.gts` to
 * `modal` even though the two files live a directory level apart.
 *
 * Known limitation: a subdirectory that hosts multiple configs (e.g.
 * `collections/command/` holds both `command` and `command-dialog`) can only
 * ever resolve to the directory's own name, so a sub-template belonging to
 * the second config would be misattributed. No such case exists as of this
 * writing (nothing is migrated yet); flagged here for whoever hits it.
 */
// Directories whose own (kebab-cased) name doesn't match any theme config,
// but whose files still belong to one for anatomy-attribution purposes.
// `simple-table/` renders the same `table` theme config as `table/` --
// SimpleTable is split into its own directory purely for code organization
// (and is independently public: its own doc, its own test file), not
// because it is a different anatomy identity. Its non-root part files
// (header/footer/row/body/column/cell) correctly carry no `data-component`
// of their own (only their root, `simple-table/index.gts`'s `<table>`,
// conditionally does), so they rely entirely on this directory fallback.
const DIRECTORY_OWNER_ALIASES = {
  'simple-table': 'table',
  // tab-nav/ is a second renderer of the `tabs` theme config (a nav-link
  // variant of Tabs, sharing list/indicator/tab slot classes) -- not a
  // config of its own. Its root file (tab-nav.gts) carries
  // `data-component="tabs"` directly, but item.gts (the TabNavItem
  // sub-template) carries only `data-part="tab"` with no data-component in
  // its own file, so it needs the same directory-name fallback
  // `simple-table` gets.
  'tab-nav': 'tabs'
};

/**
 * Known, deliberate `(config, slot)` pairs that never render a `data-part`
 * and are therefore excluded from the `missing` report rather than treated
 * as an oversight. This is a narrow, named carve-out — it does not touch
 * `readThemeSlots`/`resolveSlots` and does not change what counts as a
 * config's full slot set (see those functions' docs for why inherited
 * slots must stay part of that set in general, e.g. for `radioGroup`).
 *
 * - `textarea`: the `textarea` tv config `extend`s `input` and therefore
 *   inherits all of `input`'s slots, including `inner-container`,
 *   `start-content`, and `end-content`. Textarea deliberately has no
 *   start/end adornments and renders no wrapper around its `<textarea>` —
 *   those three slots exist in `textarea`'s resolved slot set purely
 *   because they are inherited via `extend: input`, not because Textarea
 *   has ever intended to render them. Adding a wrapper element or
 *   start/end-content blocks to satisfy this check would be exactly the
 *   out-of-scope feature addition this migration is not authorized to make.
 */
const KNOWN_UNRENDERED_SLOTS = {
  textarea: new Set(['inner-container', 'start-content', 'end-content'])
};

/**
 * Manual `(file, data-part value) -> owning config` overrides, for a
 * data-part that genuinely renders but that neither the same-file
 * attribution (the file carries no data-component of its own) nor the
 * directory-name fallback can resolve.
 *
 * `overlays/popover.gts` renders the arrow `<span data-part="arrow">` shared
 * by every consumer of `Popover.Content` (Popover itself, Tooltip, Select,
 * Autocomplete, Dropdown, ...). It deliberately carries no data-component of
 * its own -- `popover`'s tv() config has no `slots:` key at all (see
 * `popover.ts`), so `popover` is not a slot-bearing config this script
 * tracks, and `overlay`/`popover`/`portal`/`backdrop` are explicitly out of
 * scope for the current migration (see Task 8's brief). Of `tooltip`'s two
 * slots (`base`, `arrow`), `base` is attributed automatically -- Tooltip's
 * own file (`tooltip.gts`) carries `data-component="tooltip"` on the
 * `<@PopoverContent>` invocation, whose attributes flow through onto
 * Overlay's rendered `<div>` via the ...attributes chain (see the comment
 * there) -- but `arrow` is physical markup that only exists in
 * `popover.gts`, one file away, so the same-file heuristic above cannot see
 * it. This is exactly the "sub-template whose owner cannot be inferred" case
 * the comment below already anticipates, made concrete for the one file
 * where it actually occurs today.
 */
const MANUAL_PART_OWNERS = {
  'overlays/popover.gts': [{ part: 'arrow', owner: 'tooltip' }]
};

function applyManualPartOwners(file, parts, ensure) {
  const relKey = Object.keys(MANUAL_PART_OWNERS).find((suffix) =>
    file.replace(/\\/g, '/').endsWith(suffix)
  );
  if (!relKey) return;
  for (const { part, owner: ownerName } of MANUAL_PART_OWNERS[relKey]) {
    if (!parts.some((p) => p.value === part)) continue;
    const entry = ensure(ownerName);
    entry.parts.add(part);
    entry.files.add(file);
  }
}

function findOwnerByDirectory(file, componentsDir, knownConfigNames) {
  let dir = dirname(file);
  for (;;) {
    const candidate = kebab(basename(dir));
    const resolved = DIRECTORY_OWNER_ALIASES[candidate] ?? candidate;
    if (knownConfigNames.has(resolved)) return resolved;
    if (dir === componentsDir || dir === dirname(dir)) return null;
    dir = dirname(dir);
  }
}

/**
 * Collect, for every component name, the set of data-part values rendered
 * for it and the files that rendered them: { name: { parts: Set, files: Set } }.
 *
 * Attribution within a single file: a data-part belongs to the nearest
 * data-component that precedes it in source order (falling back to the
 * file's first data-component if a part appears before any). This correctly
 * handles a file that renders more than one component's root (each part
 * lands on whichever root actually opened before it), which the brief
 * sketch's directory-equality approach cannot do at all.
 */
export function readRenderedParts(componentsDir, knownConfigNames) {
  const byComponent = {};
  const ensure = (name) =>
    (byComponent[name] ??= { parts: new Set(), files: new Set() });

  for (const file of walk(componentsDir, '.gts')) {
    const src = readFileSync(file, 'utf8');
    const components = extractAttrOccurrences(src, 'data-component');
    const parts = extractAttrOccurrences(src, 'data-part');

    if (components.length > 0) {
      for (const c of components) ensure(c.value).files.add(file);
      for (const part of parts) {
        let owner = components[0].value;
        for (const c of components) {
          if (c.index <= part.index) owner = c.value;
          else break;
        }
        const entry = ensure(owner);
        entry.parts.add(part.value);
        entry.files.add(file);
      }
    } else if (parts.length > 0) {
      const owner = findOwnerByDirectory(file, componentsDir, knownConfigNames);
      if (owner) {
        const entry = ensure(owner);
        for (const part of parts) entry.parts.add(part.value);
        entry.files.add(file);
      } else {
        // A sub-template whose owner cannot be inferred from its directory --
        // check the narrow manual override map before giving up on it.
        applyManualPartOwners(file, parts, ensure);
      }
    }
  }
  return byComponent;
}

/**
 * Config names that are never themselves rendered by any component under
 * their own name -- so they have no `data-component` of their own and no
 * element of their own to carry a `data-part`. Two distinct shapes land
 * here, both invisible under the old "not yet migrated" escape purely as a
 * side effect of that escape (Task 7b); removing the escape turns them red
 * for the wrong reason -- they were never going to get a `data-component`
 * because they are not components, not because migration work is
 * outstanding:
 *
 * 1. **`extend`-only base configs.** `checkboxRadioBase` supplies shared
 *    slots to `checkbox` and `radio`; `checkboxRadioGroupBase` supplies
 *    shared slots to `checkboxGroup` and `radioGroup`; `baseButton` supplies
 *    shared classes to `button` and `toggleButton`. None is exported from
 *    its theme file for any component to call directly.
 *
 *    This is a narrow, explicit exclusion from the "every config must have
 *    a renderer" check, deliberately shaped as "exclude non-rendered base
 *    configs" rather than a `KNOWN_UNRENDERED_SLOTS`-style per-slot
 *    exemption: a base config's slots (`base`, `input`, `labelContainer`,
 *    `label`, …) are never orphaned or missing on their own terms -- they
 *    are fully covered via the `extend` chain resolution in `resolveSlots`,
 *    through the configs that actually extend them. Exempting the *base
 *    config entry itself* says precisely "this name is not a component";
 *    exempting its slots one by one would instead say "these slots don't
 *    need coverage", which is false -- they do, just under their extending
 *    configs' names.
 *
 * 2. **Class-composition helpers and out-of-scope overlay/portal
 *    machinery**, which are genuinely slotless (no `slots:` key, so they'd
 *    otherwise demand an implicit `data-part="base"` renderer) but are
 *    consumed as plain strings merged into a *different* component's own
 *    output, never surfaced under their own `data-component`:
 *    - `buttonSpinner`: called directly (not `extend`ed) inside
 *      `Button#spinnerClassNames` and passed to `<Spinner @class=…>` --
 *      the resulting element keeps `data-component="spinner"`, Spinner's
 *      own identity, not `button-spinner`.
 *    - `popover`, `backdrop`, `overlayArrow`, `dropdownContent`: overlay and
 *      portal primitives explicitly out of scope for this migration (see
 *      Task 8's brief, and the scoping note already on
 *      `MANUAL_PART_OWNERS` below) -- `Overlay`/`Portal`/`Backdrop` are not
 *      migrated components, so none of these ever gets its own
 *      `data-component`.
 */
const NEVER_RENDERED_CONFIGS = new Set([
  'checkboxRadioBase',
  'checkboxRadioGroupBase',
  'baseButton',
  'buttonSpinner',
  'popover',
  'backdrop',
  'overlayArrow',
  'dropdownContent'
]);

export function checkAnatomy({ themeDir, componentsDir }) {
  const slotsByConfig = readThemeSlots(themeDir);
  const knownConfigNames = new Set(Object.keys(slotsByConfig).map(kebab));
  const rendered = readRenderedParts(componentsDir, knownConfigNames);

  const missing = [];
  const orphan = [];

  for (const [config, slotKeys] of Object.entries(slotsByConfig)) {
    if (NEVER_RENDERED_CONFIGS.has(config)) continue;
    const name = kebab(config);
    // No matching data-component anywhere: an unmigrated (or misnamed)
    // config, reported as missing every one of its slots rather than
    // silently skipped -- see NEVER_RENDERED_CONFIGS above for the
    // deliberate exceptions to "every config must have a renderer".
    const entry = rendered[name] ?? { parts: new Set(), files: new Set() };

    for (const slot of slotKeys) {
      if (KNOWN_UNRENDERED_SLOTS[name]?.has(slot)) continue;
      if (!entry.parts.has(slot)) missing.push({ config: name, slot });
    }
    for (const part of entry.parts) {
      if (!slotKeys.includes(part)) {
        orphan.push({ config: name, part, file: [...entry.files][0] });
      }
    }
  }

  return { missing, orphan };
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const r = checkAnatomy({
    themeDir: 'packages/theme/src/components',
    componentsDir: 'packages/frontile/src/components'
  });
  for (const m of r.missing) {
    console.error(`missing: ${m.config} slot "${m.slot}" is never rendered`);
  }
  for (const o of r.orphan) {
    console.error(
      `orphan:  ${o.config} renders data-part="${o.part}" with no slot (${o.file})`
    );
  }
  if (r.missing.length || r.orphan.length) {
    process.exit(1);
  }
  console.log('anatomy ok');
}
