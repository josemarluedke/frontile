import assert from 'node:assert/strict';
import {
  existsSync,
  mkdtempSync,
  readdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { test } from 'node:test';
import { unified } from 'unified';
import remarkParse from 'remark-parse';
import docfyConfig from '../docfy.config.mjs';

const siteDir = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  '..',
);
const repoRoot = path.resolve(siteDir, '..');
const markdownParser = unified().use(remarkParse);

const componentScopes = [
  'buttons',
  'utilities',
  'status',
  'collections',
  'forms',
  'notifications',
  'overlays',
  'navigation',
  'disclosure',
];

const expectedSourceInventory = [
  {
    root: 'docs',
    pattern: '**/*.md',
    ignore: ['superpowers/**'],
  },
  ...componentScopes.map((scope) => ({
    root: 'packages/frontile',
    pattern: `src/components/${scope}/**/*.md`,
    ignore: [],
  })),
  {
    root: 'packages/frontile',
    pattern: 'src/{modifiers,utils}/**/*.md',
    ignore: [],
  },
  {
    root: 'packages/frontile',
    pattern: 'docs/**/*.md',
    ignore: [],
  },
  {
    root: 'packages/forms-legacy',
    pattern: '(docs|src)/**/**/*.md',
    ignore: [],
  },
];

/** @returns {Array<{ root: string, pattern: string, ignore: string[] }>} */
function configuredSourceInventory() {
  return docfyConfig.sources.map(({ root, pattern, ignore = [] }) => ({
    root: path.relative(repoRoot, root),
    pattern,
    ignore,
  }));
}

/** @returns {boolean} */
function matchesSourcePattern(file, pattern) {
  if (!file.endsWith('.md')) {
    return false;
  }

  if (pattern === '**/*.md') {
    return true;
  }

  const componentMatch = /^src\/components\/([^/]+)\/\*\*\/\*\.md$/.exec(
    pattern,
  );

  if (componentMatch) {
    return file.startsWith(`src/components/${componentMatch[1]}/`);
  }

  if (pattern === 'src/{modifiers,utils}/**/*.md') {
    return /^src\/(?:modifiers|utils)\//.test(file);
  }

  if (pattern === 'docs/**/*.md') {
    return file.startsWith('docs/');
  }

  if (pattern === '(docs|src)/**/**/*.md') {
    return /^(?:docs|src)\//.test(file);
  }

  throw new Error(`Unsupported Docfy source pattern: ${pattern}`);
}

/** @returns {boolean} */
function isIgnored(file, ignore) {
  return ignore.some((pattern) => {
    if (pattern === 'superpowers/**') {
      return file.startsWith('superpowers/');
    }

    throw new Error(`Unsupported Docfy ignore pattern: ${pattern}`);
  });
}

/** @returns {string[]} */
function markdownFiles({ root, pattern, ignore }) {
  const directory = path.join(repoRoot, root);
  const files = [];

  assert.ok(existsSync(directory), `Configured Docfy root is missing: ${root}`);

  /** @returns {void} */
  function visit(currentDirectory) {
    for (const entry of readdirSync(currentDirectory, {
      withFileTypes: true,
    })) {
      const absolutePath = path.join(currentDirectory, entry.name);
      const relativePath = path.relative(directory, absolutePath);

      if (isIgnored(relativePath, ignore)) {
        continue;
      }

      if (entry.isDirectory()) {
        visit(absolutePath);
      } else if (
        entry.isFile() &&
        matchesSourcePattern(relativePath, pattern)
      ) {
        files.push(absolutePath);
      }
    }
  }

  visit(directory);
  return files;
}

/** @returns {string[]} */
export function longUncollapsedPreviews(file) {
  const tree = markdownParser.parse(readFileSync(file, 'utf8'));
  const violations = [];

  /** @returns {void} */
  function visit(node) {
    if (node.type === 'code') {
      const metadata = (node.meta ?? '').trim().split(/\s+/).filter(Boolean);
      const sourceLineCount =
        node.value === '' ? 0 : node.value.split('\n').length;

      if (
        metadata.includes('preview') &&
        sourceLineCount > 30 &&
        !metadata.includes('collapsible')
      ) {
        violations.push(
          `${path.relative(repoRoot, file)}:${node.position.start.line} ` +
            `[${node.lang ?? 'plain'}] (${sourceLineCount} lines)`,
        );
      }
    }

    for (const child of node.children ?? []) {
      visit(child);
    }
  }

  visit(tree);
  return violations;
}

/** @returns {void} */
function withMarkdownFixture(markdown, callback) {
  const directory = mkdtempSync(path.join(tmpdir(), 'frontile-code-policy-'));
  const file = path.join(directory, 'fixture.md');

  try {
    writeFileSync(file, markdown);
    callback(file);
  } finally {
    rmSync(directory, { recursive: true });
  }
}

test('detects a long preview fence indented by three spaces', () => {
  const code = Array.from({ length: 31 }, (_, index) => `line ${index}`).join(
    '\n',
  );

  withMarkdownFixture(`   \`\`\`gts preview\n${code}\n   \`\`\`\n`, (file) => {
    assert.match(
      longUncollapsedPreviews(file)[0],
      /fixture\.md:1 \[gts\] \(31 lines\)$/,
    );
  });
});

test('detects long preview fences nested in blockquotes and lists', () => {
  const quotedCode = Array.from(
    { length: 31 },
    (_, index) => `> line ${index}`,
  ).join('\n');
  const listedCode = Array.from(
    { length: 31 },
    (_, index) => `    line ${index}`,
  ).join('\n');
  const markdown = [
    '> ```gts preview',
    quotedCode,
    '> ```',
    '',
    '- example',
    '',
    '  ```gts preview',
    listedCode,
    '  ```',
  ].join('\n');

  withMarkdownFixture(markdown, (file) => {
    const violations = longUncollapsedPreviews(file);

    assert.match(violations[0], /fixture\.md:1 \[gts\] \(31 lines\)$/);
    assert.match(violations[1], /fixture\.md:37 \[gts\] \(31 lines\)$/);
  });
});

test('policy source inventory matches the Docfy configuration', () => {
  assert.deepStrictEqual(configuredSourceInventory(), expectedSourceInventory);
});

test('published preview fences over 30 source lines are collapsible', () => {
  const violations = expectedSourceInventory
    .flatMap(markdownFiles)
    .flatMap((file) => longUncollapsedPreviews(file));

  assert.deepStrictEqual(
    violations,
    [],
    `Add the collapsible token to these long preview fences:\n${violations.join('\n')}`,
  );
});
