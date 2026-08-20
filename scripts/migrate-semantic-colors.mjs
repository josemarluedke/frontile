#!/usr/bin/env node

/**
 * Semantic Colors v2 Migration Script
 *
 * Migrates from the old numbered color system (default-100, primary-500) to the
 * named semantic levels (neutral-subtle, primary-soft, ...).
 *
 * Mappings mirror docs/migrations/v0.18/semantic-colors.md and are validated
 * against the theme on every run, so a target that the theme does not define
 * fails the script instead of producing dead classes.
 *
 * Usage:
 *   node scripts/migrate-semantic-colors.mjs              # Dry run
 *   node scripts/migrate-semantic-colors.mjs --write      # Write changes
 *   node scripts/migrate-semantic-colors.mjs --path="packages/theme"  # Specific path
 */

import { readFileSync, writeFileSync, readdirSync, statSync } from 'fs';
import { resolve, dirname, join, extname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ROOT = resolve(__dirname, '..');

// Parse CLI arguments
const args = process.argv.slice(2);
const shouldWrite = args.includes('--write');
const pathArg = args.find((arg) => arg.startsWith('--path='));
const targetPath = pathArg ? pathArg.split('=')[1] : '.';

console.log(`\n🎨 Semantic Colors v2 Migration Script`);
console.log(`Mode: ${shouldWrite ? '✍️  WRITE' : '🔍 DRY RUN'}`);
console.log(`Path: ${targetPath}\n`);

/**
 * Levels the theme actually defines, and the categories that carry them.
 * Kept in sync with packages/theme/src/colors/semantic.ts by validateTargets()
 * below rather than by hand — an earlier version of this script migrated code
 * to `brand-*` and `*-medium`, neither of which has ever existed, and nothing
 * caught it because the output is only ever dead CSS.
 */
const THEME_SOURCE = 'packages/theme/src/colors/types.ts';

/**
 * Old class fragment -> new class fragment.
 *
 * These mirror the mapping tables in
 * docs/migrations/v0.18/semantic-colors.md. Where the old numbered scale is
 * genuinely ambiguous the table offers two levels; this script takes the lower
 * one and reports the line so it can be reviewed, because guessing high makes
 * an element louder than it was and that is the harder error to notice.
 */
const colorMigrations = {
  // `{color}-foreground` became the automatic contrast colour. DEFAULT level,
  // matching the docs table (`text-default-foreground` -> `text-on-neutral`).
  'default-foreground': 'on-neutral',
  'primary-foreground': 'on-primary',
  'secondary-foreground': 'on-secondary',
  'tertiary-foreground': 'on-tertiary',
  'success-foreground': 'on-success',
  'warning-foreground': 'on-warning',
  'danger-foreground': 'on-danger',

  // The `default` category was renamed to `neutral`.
  'default-50': 'neutral-subtle',
  'default-100': 'neutral-subtle',
  'default-200': 'neutral-subtle',
  'default-300': 'neutral-soft',
  'default-400': 'neutral-soft',
  'default-500': 'neutral-soft',
  'default-600': 'neutral',
  'default-700': 'neutral',
  'default-800': 'neutral-strong',
  'default-900': 'neutral-strong',
  'default-950': 'neutral-strong',

  // `primary` kept its name; only the scale changed. Note there is no
  // `primary-*` -> `primary-*` identity entry here: the category rename that
  // once made those necessary was reverted before 0.18 shipped.
  'primary-500': 'primary-soft',
  'primary-600': 'primary',
  'primary-700': 'primary',
  'primary-800': 'primary-strong',
  'primary-900': 'primary-strong',

  'secondary-500': 'secondary-soft',
  'secondary-600': 'secondary',
  'secondary-700': 'secondary',
  'secondary-800': 'secondary-strong',
  'secondary-900': 'secondary-strong',

  'success-100': 'success-subtle',
  'success-200': 'success-subtle',
  'success-400': 'success-subtle',
  'success-500': 'success-soft',
  'success-600': 'success',
  'success-700': 'success',
  'success-800': 'success-strong',
  'success-900': 'success-strong',

  'warning-100': 'warning-subtle',
  'warning-200': 'warning-subtle',
  'warning-500': 'warning-soft',
  'warning-600': 'warning',
  'warning-700': 'warning',
  'warning-800': 'warning-strong',
  'warning-900': 'warning-strong',

  'danger-100': 'danger-subtle',
  'danger-200': 'danger-subtle',
  'danger-500': 'danger-soft',
  'danger-600': 'danger',
  'danger-700': 'danger',
  'danger-800': 'danger-strong',
  'danger-900': 'danger-strong',

  // Surface rename.
  'bg-background': 'bg-surface-canvas',

  // Unnumbered `default`. `text-default` goes to the ink band, since text needs
  // a legible foreground rather than a fill.
  'bg-default': 'bg-neutral',
  'text-default': 'text-neutral-strong',
  'border-default': 'border-neutral-soft'
};

/**
 * Old numbers whose docs mapping offers a choice. Migrated to the lower level
 * and reported, rather than silently picked.
 */
const AMBIGUOUS = new Set([
  'default-500',
  'default-700',
  'primary-500',
  'primary-700',
  'secondary-500',
  'secondary-700',
  'success-500',
  'success-600',
  'success-700',
  'warning-500',
  'warning-600',
  'warning-700',
  'danger-500',
  'danger-600',
  'danger-700'
]);

/**
 * Fails the run if any replacement targets a token the theme does not define.
 * This is the check whose absence let `brand-*` and `*-medium` sit here across
 * releases: a bad target produces a class Tailwind cannot resolve, which emits
 * no CSS and no error, so the damage is invisible in the diff and on the page.
 */
function validateTargets() {
  const typesPath = resolve(ROOT, THEME_SOURCE);
  const source = readFileSync(typesPath, 'utf-8');

  const categories = new Set();
  for (const match of source.matchAll(
    /^\s{2}'?(on-[\w-]+|[a-z]+)'?\??:\s*(SemanticColorCategory|OnColorCategory|SurfaceColors)/gm
  )) {
    categories.add(match[1]);
  }

  const levels = new Set([
    'subtle',
    'muted',
    'soft',
    'mild',
    'firm',
    'strong',
    'bolder'
  ]);

  // `surface` does not use the emphasis levels — it has named roles of its own
  // (canvas, card, input, …) plus two translucent families that do take levels.
  const surfaceBlock = source.slice(source.indexOf('interface SurfaceColors'));
  const surfaceRoles = new Set(
    [
      ...surfaceBlock
        .slice(0, surfaceBlock.indexOf('\n}'))
        .matchAll(/^\s{2}(\w+):/gm)
    ].map((m) => m[1])
  );

  const bad = [];
  for (const [from, to] of Object.entries(colorMigrations)) {
    // Strip any leading utility so we are left with `category` or
    // `category-level`.
    const token = to.replace(
      /^(bg|text|border|ring|placeholder|divide|outline|decoration|shadow|from|to|via)-/,
      ''
    );
    const [category, ...rest] = token.split('-');
    const level = rest.join('-');

    if (category === 'surface') {
      const [role, ...roleRest] = rest;
      if (!surfaceRoles.has(role)) {
        bad.push(`${from} -> ${to} (unknown surface role "${role}")`);
      } else if (roleRest.length > 0 && !levels.has(roleRest.join('-'))) {
        bad.push(
          `${from} -> ${to} (unknown level "${roleRest.join('-')}" on surface-${role})`
        );
      }
      if (from === to) {
        bad.push(`${from} -> ${to} (no-op mapping)`);
      }
      continue;
    }

    const known =
      categories.has(token) ||
      categories.has(category) ||
      categories.has(`${category}-${rest[0]}`);

    if (!known) {
      bad.push(`${from} -> ${to} (unknown category "${category}")`);
      continue;
    }
    if (level && !levels.has(level) && !categories.has(token)) {
      bad.push(`${from} -> ${to} (unknown level "${level}")`);
    }
    if (from === to) {
      bad.push(`${from} -> ${to} (no-op mapping)`);
    }
  }

  if (bad.length > 0) {
    console.error(
      `\n❌ ${bad.length} mapping(s) target tokens this theme does not define:\n`
    );
    bad.forEach((b) => console.error(`   ${b}`));
    console.error(
      `\nChecked against ${THEME_SOURCE}. Fix the mappings before running.\n`
    );
    process.exit(1);
  }

  console.log(
    `✓ ${Object.keys(colorMigrations).length} mappings validated against ${THEME_SOURCE}\n`
  );
}

/**
 * Build regex patterns from migration map
 * Sort by length (longest first) to match more specific patterns first
 */
function buildMigrationPatterns() {
  const entries = Object.entries(colorMigrations).sort(
    (a, b) => b[0].length - a[0].length
  );

  const patterns = [];

  for (const [oldColor, newColor] of entries) {
    // Handle both Tailwind classes and potential TypeScript color references
    // Match patterns like:
    // - 'bg-default-100'
    // - 'text-primary-500'
    // - "border-success-600"
    // - dark:bg-default-200
    const pattern = new RegExp(
      `(^|[\\s'"\`\\-:])((bg|text|border|ring|placeholder|divide|outline|decoration|shadow|from|to|via)-)?${oldColor.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}(?=[\\s'"\`/}]|$)`,
      'g'
    );

    patterns.push({ pattern, oldColor, newColor });
  }

  return patterns;
}

/**
 * Migrate content using defined patterns
 */
function migrateContent(content, filename) {
  let modified = content;
  const changes = [];
  const patterns = buildMigrationPatterns();

  for (const { pattern, oldColor, newColor } of patterns) {
    const matches = [...modified.matchAll(pattern)];

    if (matches.length > 0) {
      for (const match of matches) {
        const fullMatch = match[0];
        const prefix = match[1] || '';
        const utilityPrefix = match[2] || '';

        // Construct the replacement
        const oldText = `${utilityPrefix}${oldColor}`;
        const newText = `${utilityPrefix}${newColor}`;
        const replacement = `${prefix}${newText}`;

        // Track the change
        changes.push({
          old: oldText,
          new: newText,
          line: getLineNumber(content, match.index)
        });
      }

      // Apply the replacement
      modified = modified.replace(pattern, (match, p1, p2) => {
        const prefix = p1 || '';
        const utilityPrefix = p2 || '';
        return `${prefix}${utilityPrefix}${newColor}`;
      });
    }
  }

  return { modified, changes };
}

/**
 * Get line number for a character index
 */
function getLineNumber(content, index) {
  return content.substring(0, index).split('\n').length;
}

/**
 * Process a single file
 */
function processFile(filepath) {
  const content = readFileSync(filepath, 'utf-8');
  const { modified, changes } = migrateContent(content, filepath);

  if (changes.length === 0) {
    return null;
  }

  if (shouldWrite) {
    writeFileSync(filepath, modified, 'utf-8');
  }

  return {
    filepath: filepath.replace(ROOT + '/', ''),
    changes,
    modified: content !== modified
  };
}

/**
 * Recursively find files with specific extensions
 */
function findFiles(dir, extensions = ['.ts', '.gts', '.gjs', '.md', '.css']) {
  const results = [];
  const ignoreNames = [
    'node_modules',
    'dist',
    'tmp',
    '.git',
    // transient git worktrees and agent scratch space
    '.claude',
    'declarations'
  ];

  // The migration guides quote the old class names on purpose, in their "before"
  // columns and mapping tables. Rewriting those turns the document that explains
  // the migration into one that shows the same class on both sides — which is
  // exactly the no-op-row problem the guide was just cleaned of. The generated
  // site templates are derived from those files, so they go too.
  const ignorePaths = [
    join(ROOT, 'docs/migrations'),
    // Agent instruction files name the old tokens in prose to explain that they
    // no longer exist ("there is no `primary-500`-style class"). Rewriting those
    // sentences inverts their meaning.
    join(ROOT, 'AGENTS.md'),
    join(ROOT, 'CLAUDE.md'),
    join(ROOT, 'site/app/templates/docs/migrations'),
    join(ROOT, 'scripts/migrate-semantic-colors.mjs')
  ];

  if (
    ignorePaths.some(
      (ignored) => dir === ignored || dir.startsWith(ignored + '/')
    )
  ) {
    return results;
  }

  try {
    const entries = readdirSync(dir, { withFileTypes: true });

    for (const entry of entries) {
      const fullPath = join(dir, entry.name);

      if (ignoreNames.includes(entry.name)) {
        continue;
      }

      if (entry.isDirectory()) {
        results.push(...findFiles(fullPath, extensions));
      } else if (entry.isFile() && extensions.includes(extname(entry.name))) {
        if (ignorePaths.includes(fullPath)) {
          continue;
        }
        results.push(fullPath);
      }
    }
  } catch (error) {
    // Skip directories we can't read
  }

  return results;
}

/**
 * Main execution
 */
function main() {
  // Before touching anything: a mapping that points at a token the theme does
  // not define is worse than no migration, because the result is silent.
  validateTargets();

  const searchPath = resolve(ROOT, targetPath);
  const files = findFiles(searchPath);

  console.log(`Found ${files.length} files to process\n`);

  const results = [];
  let totalChanges = 0;

  for (const file of files) {
    const result = processFile(file);
    if (result) {
      results.push(result);
      totalChanges += result.changes.length;
    }
  }

  // Print results
  if (results.length === 0) {
    console.log(
      '✅ No migrations needed! All files already use semantic colors v2.\n'
    );
    return;
  }

  console.log(`\n📊 Summary:`);
  console.log(`   Files modified: ${results.length}`);
  console.log(`   Total changes: ${totalChanges}\n`);

  // Group changes by type
  const changesByType = {};

  for (const result of results) {
    for (const change of result.changes) {
      const key = `${change.old} → ${change.new}`;
      if (!changesByType[key]) {
        changesByType[key] = { count: 0, files: new Set() };
      }
      changesByType[key].count++;
      changesByType[key].files.add(result.filepath);
    }
  }

  console.log(`📝 Changes by type:\n`);
  const sortedChanges = Object.entries(changesByType).sort(
    (a, b) => b[1].count - a[1].count
  );

  for (const [change, { count, files }] of sortedChanges) {
    console.log(`   ${change}`);
    console.log(
      `      ${count} occurrence${count > 1 ? 's' : ''} in ${files.size} file${files.size > 1 ? 's' : ''}`
    );
  }

  // Surface the changes whose old number mapped to more than one plausible
  // level. Migrating low is the safe direction, but these are the lines where a
  // human has to decide.
  const ambiguous = sortedChanges.filter(([change]) =>
    [...AMBIGUOUS].some(
      (key) =>
        change.startsWith(`${key} →`) ||
        (/^(bg|text|border|ring|placeholder|divide|outline|decoration|shadow|from|to|via)-/.test(
          change
        ) &&
          change.split(' →')[0].endsWith(key))
    )
  );

  if (ambiguous.length > 0) {
    console.log(
      `\n⚠️  ${ambiguous.length} change type(s) had more than one reasonable level.`
    );
    console.log(
      `   Migrated to the lower level; review these and raise where the element`
    );
    console.log(`   should carry more emphasis:\n`);
    ambiguous.forEach(([change, { count }]) =>
      console.log(`   ${change}  (${count})`)
    );
  }

  console.log(`\n📁 Modified files:\n`);
  for (const result of results.slice(0, 20)) {
    console.log(
      `   ${result.filepath} (${result.changes.length} change${result.changes.length > 1 ? 's' : ''})`
    );
  }

  if (results.length > 20) {
    console.log(`   ... and ${results.length - 20} more files`);
  }

  if (!shouldWrite) {
    console.log(
      `\n💡 This was a dry run. Run with --write to apply changes.\n`
    );
  } else {
    console.log(`\n✅ Migration complete! Remember to:\n`);
    console.log(`   1. Review the changes with git diff`);
    console.log(`   2. Build the theme: pnpm --filter theme build`);
    console.log(`   3. Test the application: pnpm start`);
    console.log(`   4. Run tests: cd test-app && pnpm ember test\n`);
  }
}

// Run the script
try {
  main();
} catch (error) {
  console.error(`\n❌ Error: ${error.message}\n`);
  process.exit(1);
}
