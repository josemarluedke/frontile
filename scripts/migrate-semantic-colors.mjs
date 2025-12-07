#!/usr/bin/env node

/**
 * Semantic Colors v2 Migration Script
 *
 * Migrates Frontile codebase from old numbered color system (default-100, primary-500)
 * to new semantic color levels (neutral-subtle, brand-soft, etc.)
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
const pathArg = args.find(arg => arg.startsWith('--path='));
const targetPath = pathArg ? pathArg.split('=')[1] : '.';

console.log(`\n🎨 Semantic Colors v2 Migration Script`);
console.log(`Mode: ${shouldWrite ? '✍️  WRITE' : '🔍 DRY RUN'}`);
console.log(`Path: ${targetPath}\n`);

/**
 * Color migration mappings
 */
const colorMigrations = {
  // Foreground colors (text on colored backgrounds) - highest priority, most specific
  // Note: -foreground colors typically map to on-{color}-medium as that's the most common usage
  'default-foreground': 'on-neutral-medium',
  'primary-foreground': 'on-brand-medium',
  'success-foreground': 'on-success-medium',
  'warning-foreground': 'on-warning-medium',
  'danger-foreground': 'on-danger-medium',

  // Default/Neutral numbered scales
  'default-50': 'neutral-subtle',
  'default-100': 'neutral-subtle',
  'default-200': 'neutral-subtle',
  'default-300': 'neutral-soft',
  'default-400': 'neutral-soft',
  'default-500': 'neutral-soft',
  'default-600': 'neutral-medium',
  'default-700': 'neutral-medium',
  'default-800': 'neutral-strong',
  'default-900': 'neutral-strong',
  'default-950': 'neutral-strong',

  // Primary/Brand numbered scales
  'primary-500': 'brand-soft',
  'primary-600': 'brand-medium',
  'primary-700': 'brand-medium',
  'primary-800': 'brand-strong',
  'primary-900': 'brand-strong',
  'primary-1000': 'brand-strong',

  // Success numbered scales
  'success-100': 'success-subtle',
  'success-200': 'success-subtle',
  'success-400': 'success-subtle',
  'success-500': 'success-soft',
  'success-600': 'success-medium',
  'success-700': 'success-medium',
  'success-800': 'success-strong',
  'success-900': 'success-strong',

  // Warning numbered scales
  'warning-100': 'warning-subtle',
  'warning-200': 'warning-subtle',
  'warning-500': 'warning-soft',
  'warning-600': 'warning-medium',
  'warning-700': 'warning-medium',
  'warning-800': 'warning-strong',
  'warning-900': 'warning-strong',

  // Danger numbered scales
  'danger-100': 'danger-subtle',
  'danger-200': 'danger-subtle',
  'danger-500': 'danger-soft',
  'danger-600': 'danger-medium',
  'danger-700': 'danger-medium',
  'danger-800': 'danger-strong',
  'danger-900': 'danger-strong',

  // Special dark mode patterns
  'dark:bg-default-200': 'dark:bg-inverse-subtle',
  'dark:bg-default-300': 'dark:bg-inverse-soft',
  'dark:hover:bg-default-300': 'dark:hover:bg-inverse-soft',
  'dark:text-default-950': 'dark:text-inverse-strong',

  // Base color names without numbers (lower priority, handle after numbered ones)
  'bg-default': 'bg-neutral',
  'text-default': 'text-neutral-medium',
  'border-default': 'border-neutral-soft',
  'bg-primary': 'bg-brand',
  'text-primary': 'text-brand',
  'border-primary': 'border-brand-medium',
  'ring-primary': 'ring-brand-soft',
  'focus-visible:ring-primary-500': 'focus-visible:ring-brand-soft',
};

/**
 * Patterns that need special handling based on context
 */
const contextualPatterns = [
  // Text colors often need -medium or -strong suffix
  {
    pattern: /text-default(?!-)/g,
    check: (line) => {
      // If it's a heading or strong emphasis context, use strong
      if (line.includes('font-bold') || line.includes('font-semibold') || line.includes('heading')) {
        return 'text-neutral-strong';
      }
      // Default to medium for body text
      return 'text-neutral-medium';
    }
  },
  // Hover states for default backgrounds
  {
    pattern: /hover:bg-default(?!-)/g,
    replacement: 'hover:bg-neutral-soft'
  }
];

/**
 * Build regex patterns from migration map
 * Sort by length (longest first) to match more specific patterns first
 */
function buildMigrationPatterns() {
  const entries = Object.entries(colorMigrations)
    .sort((a, b) => b[0].length - a[0].length);

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
  const ignoreNames = ['node_modules', 'dist', 'tmp', '.git', 'declarations'];

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
    console.log('✅ No migrations needed! All files already use semantic colors v2.\n');
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
  const sortedChanges = Object.entries(changesByType)
    .sort((a, b) => b[1].count - a[1].count);

  for (const [change, { count, files }] of sortedChanges) {
    console.log(`   ${change}`);
    console.log(`      ${count} occurrence${count > 1 ? 's' : ''} in ${files.size} file${files.size > 1 ? 's' : ''}`);
  }

  console.log(`\n📁 Modified files:\n`);
  for (const result of results.slice(0, 20)) {
    console.log(`   ${result.filepath} (${result.changes.length} change${result.changes.length > 1 ? 's' : ''})`);
  }

  if (results.length > 20) {
    console.log(`   ... and ${results.length - 20} more files`);
  }

  if (!shouldWrite) {
    console.log(`\n💡 This was a dry run. Run with --write to apply changes.\n`);
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
