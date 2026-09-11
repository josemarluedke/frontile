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
 * [kebabSlot, …] }`. A config counts as slot-bearing when it has its own
 * `slots:` key (see `parseThemeFile`); its returned slot list also includes
 * anything inherited through `extend`.
 */
export function readThemeSlots(themeDir) {
  const raw = {};
  for (const file of walk(themeDir, '.ts')) {
    if (EXCLUDED_BASENAMES.has(basename(file))) continue;
    Object.assign(raw, parseThemeFile(readFileSync(file, 'utf8')));
  }
  const cache = new Map();
  const configs = {};
  for (const [name, entry] of Object.entries(raw)) {
    if (entry.ownSlots === null) continue; // no slots: key -> not slot-bearing
    configs[name] = resolveSlots(name, raw, cache);
  }
  return configs;
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
function findOwnerByDirectory(file, componentsDir, knownConfigNames) {
  let dir = dirname(file);
  for (;;) {
    const candidate = kebab(basename(dir));
    if (knownConfigNames.has(candidate)) return candidate;
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
      }
      // Else: a sub-template whose owner cannot be inferred. Left
      // unattributed rather than guessed at.
    }
  }
  return byComponent;
}

export function checkAnatomy({ themeDir, componentsDir }) {
  const slotsByConfig = readThemeSlots(themeDir);
  const knownConfigNames = new Set(Object.keys(slotsByConfig).map(kebab));
  const rendered = readRenderedParts(componentsDir, knownConfigNames);

  const missing = [];
  const orphan = [];

  for (const [config, slotKeys] of Object.entries(slotsByConfig)) {
    const name = kebab(config);
    const entry = rendered[name];
    // TEMPORARY escape: a config with no matching data-component anywhere is
    // a component that has not been migrated to the anatomy attributes yet,
    // so its slot coverage isn't this check's concern. Some components in
    // this codebase already carry a `data-component` attribute today (from
    // work that predates this migration plan) without yet carrying the
    // matching `data-part`s, so this escape is not currently a no-op — those
    // configs are the `missing` entries the baseline run reports. Task 12
    // deletes this `continue` once every component in the migration list
    // carries both attributes correctly, at which point an unmigrated config
    // should start failing the check instead of being silently skipped.
    if (!entry) continue;

    for (const slot of slotKeys) {
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
