import { test } from 'node:test';
import assert from 'node:assert/strict';
import { resolveSignatureTags } from './docfy-plugin-signature-markdown.mjs';

const fixtureData = [
  {
    package: 'buttons',
    module: 'button',
    name: 'Button',
    description: 'A clickable button.',
    Element: { type: { type: 'HTMLButtonElement' } },
    Args: [
      {
        identifier: 'appearance',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'The button appearance',
        tags: {},
        defaultValue: "'default'",
      },
      {
        identifier: 'internalOnly',
        type: { type: 'boolean' },
        isRequired: false,
        isInternal: true,
        description: 'Internal flag',
        tags: {},
      },
      {
        identifier: 'hiddenArg',
        type: { type: 'string' },
        isRequired: false,
        isInternal: false,
        description: 'Should not appear',
        tags: { ignore: true },
      },
    ],
    Blocks: [],
  },
  {
    package: 'overlays',
    module: 'popover',
    name: 'Content',
    description: 'Popover content.',
    Args: [
      {
        identifier: 'size',
        type: { type: "'sm' | 'lg'", raw: "'sm' | 'lg'" },
        isRequired: true,
        isInternal: false,
        description: 'Content size',
        tags: {},
      },
    ],
    Blocks: [
      {
        identifier: 'default',
        type: { type: 'Block' },
        isRequired: false,
        isInternal: false,
        description: 'Default block',
        tags: {},
      },
    ],
  },
  {
    package: 'overlays',
    module: 'modal',
    name: 'Content',
    description: 'Modal content.',
    Args: [],
    Blocks: [],
  },
];

test('replaces a single <Signature> tag with its Markdown block', () => {
  const markdown = 'Intro\n\n<Signature @component="Button" />\n\nOutro';
  const result = resolveSignatureTags(
    markdown,
    fixtureData,
    '/docs/components/buttons/button'
  );

  assert.ok(result.includes('### Button'));
  assert.ok(result.includes('A clickable button.'));
  assert.ok(result.includes('**Element:** `HTMLButtonElement`'));
  assert.ok(result.includes('`appearance`'));
  assert.ok(result.startsWith('Intro'));
  assert.ok(result.endsWith('Outro'));
});

test('replaces multiple <Signature> tags in one page', () => {
  const markdown =
    '<Signature @component="Button" />\n\n<Signature @package="overlays" @module="popover" @component="Content" />';
  const result = resolveSignatureTags(markdown, fixtureData, '/docs/page');

  assert.ok(result.includes('### Button'));
  assert.ok(result.includes('### Content'));
});

test('disambiguates same-named components via @package/@module', () => {
  const markdown =
    '<Signature @package="overlays" @module="popover" @component="Content" />';
  const result = resolveSignatureTags(markdown, fixtureData, '/docs/page');

  assert.ok(result.includes('Popover content.'));
  assert.ok(!result.includes('Modal content.'));
});

test('logs a warning and leaves an unmatched tag unresolved', () => {
  const markdown = '<Signature @component="DoesNotExist" />';
  const originalWarn = console.warn;
  const warnings = [];
  console.warn = (message) => warnings.push(message);

  let result;
  try {
    result = resolveSignatureTags(markdown, fixtureData, '/docs/missing');
  } finally {
    console.warn = originalWarn;
  }

  assert.strictEqual(result, markdown);
  assert.strictEqual(warnings.length, 1);
  assert.ok(warnings[0].includes('DoesNotExist'));
  assert.ok(warnings[0].includes('/docs/missing'));
});

test('excludes ignore-tagged args from the Arguments table', () => {
  const result = resolveSignatureTags(
    '<Signature @component="Button" />',
    fixtureData,
    '/docs/page'
  );

  assert.ok(!result.includes('hiddenArg'));
});

test('omits the Blocks section when a component has no blocks', () => {
  const result = resolveSignatureTags(
    '<Signature @component="Button" />',
    fixtureData,
    '/docs/page'
  );

  assert.ok(!result.includes('**Blocks**'));
});

test('includes a Blocks table when a component has blocks', () => {
  const result = resolveSignatureTags(
    '<Signature @package="overlays" @module="popover" @component="Content" />',
    fixtureData,
    '/docs/page'
  );

  assert.ok(result.includes('**Blocks**'));
  assert.ok(result.includes('`default`'));
});

test('appends an (internal) marker to internal args', () => {
  const result = resolveSignatureTags(
    '<Signature @component="Button" />',
    fixtureData,
    '/docs/page'
  );

  assert.ok(result.includes('_(internal)_'));
});
