#!/usr/bin/env node
/**
 * Lints Frontile component docs against the conventions in
 * .claude/skills/frontile-docs/references/structure.md.
 *
 * The point of this script is to take the mechanical half of a docs review off the
 * model's plate: required sections, fence languages, <Signature> wiring, and drift
 * between a doc's demos and the component's actual Args. Those checks are boring,
 * easy to get wrong by eye across 30+ files, and identical every time — exactly the
 * shape of thing that should be code rather than a checklist item.
 *
 * Usage:
 *   node .claude/skills/frontile-docs/scripts/lint-docs.mjs
 *   node .claude/skills/frontile-docs/scripts/lint-docs.mjs path/to/one.md [more.md]
 *   node .claude/skills/frontile-docs/scripts/lint-docs.mjs --json
 *
 * Exits 1 when there is at least one error, so it can gate CI.
 */

import { readFileSync, readdirSync, existsSync, statSync } from 'node:fs';
import { join, dirname, relative, resolve, basename } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';

const REPO_ROOT = resolve(
  dirname(fileURLToPath(import.meta.url)),
  '../../../..'
);
const COMPONENTS_DIR = join(REPO_ROOT, 'packages/frontile/src/components');

const REQUIRED_SECTIONS = ['Import', 'Usage', 'API'];
const DISCOURAGED_HEADINGS = {
  'Basic Usage': 'use `## Usage`',
  'Key Features': 'fold each feature into the section that demonstrates it',
  'Important Notes': 'move each note next to the thing it describes',
  'Best Practices': 'move guidance into the section it applies to'
};
const SEMANTIC_CATEGORIES =
  'neutral|primary|secondary|tertiary|success|warning|danger|inverse|surface';
const UTILITY_PREFIXES =
  'bg|text|border|ring|from|to|via|fill|stroke|divide|outline|shadow|accent|caret|decoration|placeholder';

// ---------------------------------------------------------------------------
// Tiny TS parsing. Deliberately tolerant: when it can't confidently resolve an
// Args type it reports that it gave up rather than inventing findings. A linter
// that cries wolf on valid docs gets switched off.
// ---------------------------------------------------------------------------

/** Returns the source spanning the braces of the block starting at `openIndex` (the `{`). */
function readBlock(source, openIndex) {
  let depth = 0;
  for (let i = openIndex; i < source.length; i++) {
    const ch = source[i];
    if (ch === '{') depth++;
    else if (ch === '}') {
      depth--;
      if (depth === 0) return source.slice(openIndex + 1, i);
    }
  }
  return null;
}

function findInterfaceBlock(source, name) {
  const re = new RegExp(`interface\\s+${name}\\b[^{]*\\{`, 'm');
  const match = re.exec(source);
  if (!match) return null;
  return {
    body: readBlock(source, match.index + match[0].length - 1),
    extends: /\bextends\b/.test(match[0])
  };
}

/**
 * Top-level members of an interface body, with whether each carries a JSDoc block.
 * Members are only counted at brace depth 0 so nested object types don't leak in.
 */
function parseMembers(body) {
  const members = [];
  let depth = 0;
  let lineStart = 0;
  const lines = body.split('\n');
  let pendingDoc = false;
  let inDoc = false;

  for (const rawLine of lines) {
    const line = rawLine.trim();

    if (inDoc) {
      if (line.includes('*/')) inDoc = false;
      continue;
    }
    if (line.startsWith('/**')) {
      pendingDoc = true;
      if (!line.includes('*/')) inDoc = true;
      continue;
    }

    if (depth === 0) {
      const m = /^(?:readonly\s+)?(\w+)\s*\??\s*:/.exec(line);
      if (m) members.push({ name: m[1], documented: pendingDoc });
      if (m || line !== '') pendingDoc = line === '' ? pendingDoc : false;
    }

    for (const ch of rawLine) {
      if (ch === '{' || ch === '(' || ch === '[') depth++;
      else if (ch === '}' || ch === ')' || ch === ']') depth--;
    }
    lineStart += rawLine.length;
  }
  return members;
}

/**
 * Collects every argument declared by the component file, plus whether we're
 * confident the list is complete. Incomplete lists suppress "unknown argument"
 * errors — a false positive there sends someone chasing a bug that isn't there.
 */
function parseComponentArgs(gtsSource) {
  const args = new Map();
  let complete = true;
  let found = false;

  const argsTypeNames = new Set();
  const signatureRe = /interface\s+(\w*Signature)\b[^{]*\{/g;
  let sig;
  while ((sig = signatureRe.exec(gtsSource))) {
    const body = readBlock(gtsSource, sig.index + sig[0].length - 1);
    if (!body) continue;
    const inline = /Args\s*:\s*\{/.exec(body);
    if (inline) {
      const inlineBody = readBlock(body, inline.index + inline[0].length - 1);
      if (inlineBody) {
        found = true;
        for (const m of parseMembers(inlineBody)) args.set(m.name, m);
      }
      continue;
    }
    const named = /Args\s*:\s*(\w+)/.exec(body);
    if (named) argsTypeNames.add(named[1]);
  }

  // Any interface named *Args counts too — several components declare and export
  // one without ever naming it in a Signature in the same file.
  const namedRe = /interface\s+(\w*Args)\b/g;
  let named;
  while ((named = namedRe.exec(gtsSource))) argsTypeNames.add(named[1]);

  for (const typeName of argsTypeNames) {
    const block = findInterfaceBlock(gtsSource, typeName);
    if (!block || !block.body) {
      complete = false; // imported from elsewhere; we can't see its members
      continue;
    }
    found = true;
    if (block.extends) complete = false;
    for (const m of parseMembers(block.body)) args.set(m.name, m);
  }

  if (!found) complete = false;
  return { args, complete };
}

// ---------------------------------------------------------------------------
// Markdown inspection
// ---------------------------------------------------------------------------

function parseFrontmatter(source) {
  if (!source.startsWith('---\n')) return { body: source, raw: '', offset: 0 };
  const end = source.indexOf('\n---', 4);
  if (end === -1) return { body: source, raw: '', offset: 0 };
  const raw = source.slice(4, end);
  const offset = source.slice(0, end + 4).split('\n').length;
  return { body: source.slice(end + 4), raw, offset };
}

function collectFences(source) {
  const fences = [];
  const lines = source.split('\n');
  let open = null;
  lines.forEach((line, i) => {
    const m = /^```(.*)$/.exec(line);
    if (!m) return;
    if (open) {
      fences.push({
        ...open,
        endLine: i + 1,
        content: lines.slice(open.line, i).join('\n')
      });
      open = null;
    } else {
      open = { info: m[1].trim(), line: i + 1 };
    }
  });
  return fences;
}

/** Argument names applied to `<Tag ...>` anywhere in the doc. */
function argsUsedOnTag(source, tag) {
  const used = new Map();
  const re = new RegExp(`<${tag}\\b`, 'g');
  let m;
  while ((m = re.exec(source))) {
    const end = source.indexOf('>', m.index);
    if (end === -1) continue;
    const attrs = source.slice(m.index, end);
    const argRe = /@(\w+)\s*=/g;
    let a;
    while ((a = argRe.exec(attrs))) {
      const line = source.slice(0, m.index).split('\n').length;
      if (!used.has(a[1])) used.set(a[1], line);
    }
  }
  return used;
}

function lineOf(source, index) {
  return source.slice(0, index).split('\n').length;
}

/**
 * Component names present in the generated signature data, or null when it
 * hasn't been generated. Entries are emitted as package/module/name/fileName
 * groups; anchoring on the preceding `module:` avoids picking up the `name`
 * keys that appear inside Blocks metadata.
 */
let signatureNamesCache;
function knownSignatureComponents() {
  if (signatureNamesCache !== undefined) return signatureNamesCache;
  const dataPath = join(REPO_ROOT, 'site/app/components/signature-data.ts');
  if (!existsSync(dataPath)) return (signatureNamesCache = null);
  const source = readFileSync(dataPath, 'utf8');
  const names = new Set();
  for (const m of source.matchAll(/module:\s*'[^']*',\s*name:\s*'([^']+)'/g)) {
    names.add(m[1]);
  }
  return (signatureNamesCache = names.size > 0 ? names : null);
}

// ---------------------------------------------------------------------------
// The checks
// ---------------------------------------------------------------------------

function lintDoc(mdPath) {
  const findings = [];
  const source = readFileSync(mdPath, 'utf8');
  const { raw: frontmatter } = parseFrontmatter(source);
  const rel = relative(REPO_ROOT, mdPath);
  const add = (level, line, message, hint) =>
    findings.push({ file: rel, level, line, message, hint });

  const headings = [...source.matchAll(/^(#{1,6})\s+(.+)$/gm)].map((m) => ({
    depth: m[1].length,
    text: m[2].trim(),
    line: lineOf(source, m.index)
  }));
  const topLevel = new Set(
    headings.filter((h) => h.depth === 2).map((h) => h.text)
  );

  if (!headings.some((h) => h.depth === 1)) {
    add(
      'warn',
      1,
      'No H1 title',
      'the H1 is the page title; there is no `title` frontmatter key'
    );
  }

  for (const section of REQUIRED_SECTIONS) {
    if (topLevel.has(section)) continue;
    // A file using `## Basic Usage` already gets the rename warning below; reporting
    // it as a missing section too would send someone looking for content that's there.
    if (section === 'Usage' && topLevel.has('Basic Usage')) continue;
    add(
      'error',
      1,
      `Missing \`## ${section}\` section`,
      'see references/structure.md'
    );
  }
  if (!topLevel.has('Accessibility')) {
    add(
      'warn',
      1,
      'Missing `## Accessibility` section',
      'keyboard, roles/ARIA, focus management — the part a type signature can never generate'
    );
  }

  for (const h of headings) {
    const advice = DISCOURAGED_HEADINGS[h.text];
    if (advice && h.depth <= 3)
      add('warn', h.line, `Heading \`${h.text}\``, advice);
  }

  // --- <Signature> wiring -------------------------------------------------
  const signatureTags = [
    ...source.matchAll(/<Signature\s+[^>]*@component="([^"]+)"/g)
  ];
  if (topLevel.has('API') && signatureTags.length === 0) {
    add(
      'error',
      headings.find((h) => h.text === 'API')?.line ?? 1,
      '`## API` has no `<Signature />` tag',
      'the API table is generated — see SKILL.md'
    );
  }
  if (signatureTags.length > 0 && !/import Signature from/.test(frontmatter)) {
    add(
      'error',
      1,
      '`<Signature />` used but not imported in frontmatter',
      "add `imports:\\n  - import Signature from 'site/components/signature';`"
    );
  }

  // A tag naming a component that isn't in the generated data renders as an
  // empty API entry — the site only logs "No component found" during the build,
  // which is easy to miss. Skipped when the data hasn't been generated yet,
  // since a missing file would otherwise condemn every tag in the repo.
  const known = knownSignatureComponents();
  if (known) {
    for (const tag of signatureTags) {
      if (!known.has(tag[1])) {
        add(
          'error',
          lineOf(source, tag.index),
          `\`<Signature @component="${tag[1]}" />\` matches no component in signature-data.ts`,
          'check the name, or run `pnpm --filter frontile build && pnpm --filter site generate-signature-data` if the component is new'
        );
      }
    }
  }

  // --- Fences -------------------------------------------------------------
  for (const fence of collectFences(source)) {
    if (fence.info === 'gjs preview') {
      add(
        'warn',
        fence.line,
        'Legacy ```gjs preview fence',
        'convert to ```gts preview'
      );
    }
    const isPreview = /\bpreview\b/.test(fence.info);
    if (!isPreview && /<template>/.test(fence.content) && fence.info !== '') {
      add(
        'warn',
        fence.line,
        `\`\`\`${fence.info} block contains a <template> but is not a preview`,
        'add ` preview` so it renders live, or confirm it is intentionally static'
      );
    }
    if (/<svg\b/.test(fence.content)) {
      add(
        'warn',
        fence.line,
        'Inline <svg> in a demo',
        'import from `site/components/icons` instead, adding the icon there if it is missing'
      );
    }
    const rawPalette =
      /\b(?:bg|text|border|ring|fill|stroke)-(?:slate|gray|zinc|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-\d{2,3}\b/.exec(
        fence.content
      );
    if (rawPalette) {
      add(
        'warn',
        fence.line,
        `Raw Tailwind palette class \`${rawPalette[0]}\``,
        'use semantic utilities so the demo adapts to dark mode — unless this demo is deliberately showing custom styling'
      );
    }
    const badColor = new RegExp(
      `\\b(?:${UTILITY_PREFIXES})-(?:${SEMANTIC_CATEGORIES})-\\d{2,3}\\b`
    ).exec(fence.content);
    if (badColor) {
      add(
        'error',
        fence.line,
        `Numbered color utility \`${badColor[0]}\``,
        'Frontile has no numeric scale; use named levels (subtle/muted/soft/mild/DEFAULT/firm/strong/bolder)'
      );
    }
  }

  // --- Args drift ---------------------------------------------------------
  const gtsPath = mdPath.replace(/\.md$/, '.gts');
  if (existsSync(gtsPath)) {
    const { args, complete } = parseComponentArgs(
      readFileSync(gtsPath, 'utf8')
    );
    const gtsRel = relative(REPO_ROOT, gtsPath);

    // Only check the component this file actually declares. Docs routinely document
    // sub-components that live in their own files (PortalTarget in portal.md), and
    // checking those against the wrong Args interface invents errors.
    const own = basename(mdPath, '.md').replace(/(^|-)(\w)/g, (_, __, c) =>
      c.toUpperCase()
    );
    const primary =
      signatureTags.map((t) => t[1]).find((name) => name === own) ?? null;
    if (primary && complete) {
      for (const [arg, line] of argsUsedOnTag(source, primary)) {
        if (!args.has(arg)) {
          add(
            'error',
            line,
            `\`<${primary} @${arg}>\` is not an argument of ${basename(gtsRel)}`,
            'renamed, removed, or a typo — check the Args interface'
          );
        }
      }
    }

    const undocumented = [...args.values()]
      .filter((a) => !a.documented)
      .map((a) => a.name);
    if (undocumented.length > 0) {
      add(
        'warn',
        1,
        `${undocumented.length} argument(s) have no JSDoc: ${undocumented.join(', ')}`,
        `they render as blank rows in the API table — document them in ${gtsRel}`
      );
    }
  }

  return findings;
}

// ---------------------------------------------------------------------------
// Discovery + reporting
// ---------------------------------------------------------------------------

/**
 * Compares a doc against a git ref and reports demos that disappeared.
 *
 * Shortening a page is usually an improvement, but the cheap way to shorten it
 * is to delete demos, which silently trades executable coverage for prose. That
 * loss is invisible in review — the page reads better — so it gets checked here
 * rather than left to judgment.
 */
function demoRegressions(mdPath, ref) {
  const rel = relative(REPO_ROOT, mdPath);
  let before;
  try {
    before = execSync(`git show ${ref}:${rel}`, {
      cwd: REPO_ROOT,
      stdio: ['ignore', 'pipe', 'ignore']
    }).toString();
  } catch {
    return []; // new file, or not in that ref — nothing to compare
  }
  const count = (s) => [...s.matchAll(/^```g[jt]s preview$/gm)].length;
  const was = count(before);
  const now = count(readFileSync(mdPath, 'utf8'));
  if (now >= was) return [];
  return [
    {
      file: rel,
      level: 'error',
      line: 1,
      message: `${was - now} runnable demo(s) removed since ${ref} (${was} → ${now})`,
      hint: 'name the retained demo covering each removed state, or consolidate instead of deleting — see SKILL.md'
    }
  ];
}

function walk(dir, out = []) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const full = join(dir, entry.name);
    if (entry.isDirectory()) walk(full, out);
    else out.push(full);
  }
  return out;
}

/**
 * A component is "expected to have docs" when its category barrel re-exports it —
 * that's what makes it public API. Internal parts (`drawer/body.gts`, `table/cell.gts`)
 * are documented inside their parent's page and shouldn't be reported as missing.
 */
function publiclyExported() {
  const exported = new Set();
  for (const category of readdirSync(COMPONENTS_DIR, { withFileTypes: true })) {
    if (!category.isDirectory()) continue;
    const barrel = join(COMPONENTS_DIR, category.name, 'index.ts');
    if (!existsSync(barrel)) continue;
    for (const m of readFileSync(barrel, 'utf8').matchAll(
      /from\s+'\.\/([\w-]+)'/g
    )) {
      exported.add(join(COMPONENTS_DIR, category.name, `${m[1]}.gts`));
    }
  }
  return exported;
}

function findOrphanComponents(files) {
  const orphans = [];
  const expected = publiclyExported();
  for (const file of files) {
    if (!expected.has(file)) continue;
    if (!existsSync(file.replace(/\.gts$/, '.md'))) {
      orphans.push({
        file: relative(REPO_ROOT, file),
        level: 'warn',
        line: 1,
        message: 'Component has no co-located `.md`',
        hint: 'add one, or confirm it is an internal component that should not be documented'
      });
    }
  }
  return orphans;
}

function main() {
  const argv = process.argv.slice(2);
  const json = argv.includes('--json');
  // `--since <ref>` additionally compares each doc against that ref and errors
  // when runnable demos have been removed.
  const sinceFlag = argv.indexOf('--since');
  const since = sinceFlag === -1 ? null : (argv[sinceFlag + 1] ?? 'HEAD');
  const paths = argv.filter(
    (a, i) => !a.startsWith('--') && i !== sinceFlag + 1
  );

  let docs;
  let findings = [];

  if (paths.length > 0) {
    docs = paths
      .map((p) => resolve(process.cwd(), p))
      .filter((p) => p.endsWith('.md'));
  } else {
    if (!existsSync(COMPONENTS_DIR)) {
      console.error(
        `Cannot find ${COMPONENTS_DIR} — run from inside the frontile repo.`
      );
      process.exit(2);
    }
    const all = walk(COMPONENTS_DIR);
    docs = all.filter((f) => f.endsWith('.md'));
    findings = findings.concat(findOrphanComponents(all));
  }

  for (const doc of docs) {
    if (!existsSync(doc) || !statSync(doc).isFile()) continue;
    findings = findings.concat(lintDoc(doc));
    if (since) findings = findings.concat(demoRegressions(doc, since));
  }

  const errors = findings.filter((f) => f.level === 'error');
  const warnings = findings.filter((f) => f.level === 'warn');

  if (json) {
    console.log(
      JSON.stringify({ docs: docs.length, errors, warnings }, null, 2)
    );
  } else {
    const byFile = new Map();
    for (const f of findings) {
      if (!byFile.has(f.file)) byFile.set(f.file, []);
      byFile.get(f.file).push(f);
    }
    for (const [file, items] of [...byFile].sort()) {
      console.log(`\n${file}`);
      for (const i of items.sort((a, b) => a.line - b.line)) {
        const tag = i.level === 'error' ? 'error' : 'warn ';
        console.log(`  ${tag} ${String(i.line).padStart(4)}  ${i.message}`);
        if (i.hint) console.log(`               ↳ ${i.hint}`);
      }
    }
    console.log(
      `\n${docs.length} doc(s) checked — ${errors.length} error(s), ${warnings.length} warning(s)`
    );
  }

  process.exit(errors.length > 0 ? 1 : 0);
}

main();
