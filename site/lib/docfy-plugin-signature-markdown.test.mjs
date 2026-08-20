import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import {
  resolveSignatureTags,
  docfyPluginSignatureMarkdown,
  loadSignatureData,
} from './docfy-plugin-signature-markdown.mjs';

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
    '/docs/components/buttons/button',
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
    '/docs/page',
  );

  assert.ok(!result.includes('hiddenArg'));
});

test('omits the Blocks section when a component has no blocks', () => {
  const result = resolveSignatureTags(
    '<Signature @component="Button" />',
    fixtureData,
    '/docs/page',
  );

  assert.ok(!result.includes('**Blocks**'));
});

test('includes a Blocks table when a component has blocks', () => {
  const result = resolveSignatureTags(
    '<Signature @package="overlays" @module="popover" @component="Content" />',
    fixtureData,
    '/docs/page',
  );

  assert.ok(result.includes('**Blocks**'));
  assert.ok(result.includes('`default`'));
});

test('appends an (internal) marker to internal args', () => {
  const result = resolveSignatureTags(
    '<Signature @component="Button" />',
    fixtureData,
    '/docs/page',
  );

  assert.ok(result.includes('_(internal)_'));
});

test('docfyPluginSignatureMarkdown returns an object with a runAfter function', () => {
  const plugin = docfyPluginSignatureMarkdown(fixtureData);

  assert.strictEqual(typeof plugin, 'object');
  assert.strictEqual(typeof plugin.runAfter, 'function');
});

test('runAfter sets pluginData.staticMarkdown on a matched page without touching page.markdown', () => {
  const originalMarkdown =
    'Intro\n\n<Signature @component="Button" />\n\nOutro';
  const page = {
    markdown: originalMarkdown,
    meta: { url: '/docs/components/buttons/button' },
    pluginData: {},
  };
  const plugin = docfyPluginSignatureMarkdown(fixtureData);

  plugin.runAfter({ pages: [page] });

  assert.strictEqual(typeof page.pluginData.staticMarkdown, 'string');
  assert.ok(page.pluginData.staticMarkdown.includes('### Button'));
  assert.strictEqual(page.markdown, originalMarkdown);
});

test('runAfter leaves pluginData.staticMarkdown unset on a page with no <Signature> tag', () => {
  const originalMarkdown = 'Just some regular prose, no signature tags here.';
  const page = {
    markdown: originalMarkdown,
    meta: { url: '/docs/page-without-signature' },
    pluginData: {},
  };
  const plugin = docfyPluginSignatureMarkdown(fixtureData);

  plugin.runAfter({ pages: [page] });

  assert.strictEqual(page.pluginData.staticMarkdown, undefined);
  assert.ok(!('staticMarkdown' in page.pluginData));
  assert.strictEqual(page.markdown, originalMarkdown);
});

test('escapes a `|` in a union type.raw so it does not break the Markdown table cell', () => {
  const unionFixture = [
    {
      package: 'buttons',
      module: 'button',
      name: 'SizedButton',
      Args: [
        {
          identifier: 'size',
          type: { type: 'enum', raw: "'sm' | 'lg'" },
          isRequired: false,
          isInternal: false,
          description: 'Size',
          tags: {},
        },
      ],
      Blocks: [],
    },
  ];

  const result = resolveSignatureTags(
    '<Signature @component="SizedButton" />',
    unionFixture,
    '/docs/page',
  );

  assert.ok(result.includes("`'sm' \\| 'lg'`"));

  const row = result.split('\n').find((line) => line.includes('`size`'));

  assert.ok(row, 'expected to find the row for the `size` argument');
  assert.strictEqual(row, "| `size` | `'sm' \\| 'lg'` | - | Size |");
});

test('loadSignatureData parses the generated .ts file and strips HTML highlighting', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'signature-data-'));
  const filePath = path.join(dir, 'signature-data.ts');
  const data = [
    {
      package: 'buttons',
      module: 'button',
      name: 'Button',
      description: 'A button.',
      Element: {
        type: {
          type: '<span class="hljs-built_in">HTMLButtonElement</span>',
        },
      },
      Args: [
        {
          identifier: 'appearance',
          type: {
            type: '<span class="hljs-built_in">enum</span>',
            raw: '<span class="hljs-string">\'default\'</span> | <span class="hljs-string">\'outlined\'</span>',
            // items are plain strings in the real generated data - they're
            // never HTML-highlighted in the first place.
            items: ["'default'", "'outlined'"],
          },
          isRequired: false,
          isInternal: false,
          description: 'The appearance',
          tags: {},
          defaultValue: '<span class="hljs-string">\'default\'</span>',
        },
      ],
      Blocks: [],
    },
  ];

  try {
    writeFileSync(
      filePath,
      `import type { ComponentDoc } from 'glimmer-docgen-typescript';\nconst data: ComponentDoc[] = ${JSON.stringify(data)};\nexport type { ComponentDoc };\nexport default data;`,
    );

    const result = loadSignatureData(filePath);

    assert.strictEqual(result[0].Element.type.type, 'HTMLButtonElement');
    assert.strictEqual(result[0].Args[0].type.type, 'enum');
    assert.strictEqual(result[0].Args[0].type.raw, "'default' | 'outlined'");
    assert.deepStrictEqual(result[0].Args[0].type.items, [
      "'default'",
      "'outlined'",
    ]);
    assert.strictEqual(result[0].Args[0].defaultValue, "'default'");
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
});

test('loadSignatureData parses the Prettier-reformatted single-quoted syntax the real script produces', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'signature-data-'));
  const filePath = path.join(dir, 'signature-data.ts');

  try {
    // This is not valid JSON (single-quoted strings, unquoted keys, a
    // trailing comma) - it's what Prettier actually turns the generator's
    // JSON.stringify output into. JSON.parse would reject this.
    writeFileSync(
      filePath,
      `import type { ComponentDoc } from 'glimmer-docgen-typescript';
const data: ComponentDoc[] = [
  {
    package: 'buttons',
    module: 'button',
    name: 'Button',
    description: 'A button.',
    Args: [
      {
        identifier: 'appearance',
        type: { type: '<span class="hljs-built_in">string</span>' },
        isRequired: false,
        isInternal: false,
        description: 'The appearance',
        tags: {},
      },
    ],
    Blocks: [],
  },
];
export type { ComponentDoc };
export default data;`,
    );

    const result = loadSignatureData(filePath);

    assert.strictEqual(result[0].name, 'Button');
    assert.strictEqual(result[0].Args[0].type.type, 'string');
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
});

test('loadSignatureData throws a clear error when the file does not match the expected format', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'signature-data-'));
  const filePath = path.join(dir, 'signature-data.ts');

  try {
    writeFileSync(filePath, 'export default [];');

    assert.throws(
      () => loadSignatureData(filePath),
      /Could not find the generated data array/,
    );
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
});

test('descriptions stored as rendered HTML are reduced to text in the markdown output', () => {
  // generate-signature-data.js renders JSDoc markdown to HTML for the browser
  // table. The markdown output has to undo that, or inline code arrives as
  // literal <code> tags inside a markdown cell.
  const data = [
    {
      package: 'overlays',
      module: 'overlay',
      name: 'Overlay',
      description:
        '<p>An overlay built on <code>Portal</code>.</p>\n<p>Second paragraph.</p>',
      Element: { type: { type: 'HTMLDivElement' } },
      Args: [
        {
          identifier: 'backdrop',
          type: { type: 'string' },
          isRequired: false,
          isInternal: false,
          description:
            'How it renders: <code>none</code> omits it, <code>blur</code> blurs.',
          tags: {},
        },
      ],
      Blocks: [],
    },
  ];

  const markdown = resolveSignatureTags(
    '<Signature @component="Overlay" />',
    data,
  );

  assert.ok(
    !markdown.includes('<code>'),
    'no HTML tags survive into the markdown',
  );
  assert.ok(
    !markdown.includes('<p>'),
    'paragraph wrappers are stripped as well',
  );
  assert.match(markdown, /How it renders: none omits it, blur blurs\./);
  assert.match(markdown, /An overlay built on Portal\./);
});

test('HTML entities are decoded, not left as escapes', () => {
  // Both lowlight (types) and remark (descriptions) escape `<` on the way out,
  // so stripping tags alone leaves `SlotsToClasses&#x3C;'base'>` in the cell.
  const data = [
    {
      package: 'utilities',
      module: 'avatar',
      name: 'Avatar',
      description: '<p>Renders a <code>&#x3C;span></code> wrapper.</p>',
      Element: { type: { type: 'HTMLDivElement' } },
      Args: [
        {
          identifier: 'classes',
          type: { type: "SlotsToClasses&#x3C;'base' | 'img'>" },
          isRequired: false,
          isInternal: false,
          description: 'Slot classes',
          tags: {},
        },
      ],
      Blocks: [],
    },
  ];

  const markdown = resolveSignatureTags(
    '<Signature @component="Avatar" />',
    data,
  );

  assert.match(
    markdown,
    /Renders a <span> wrapper\./,
    'the escaped < in a description is decoded, not left as &#x3C;',
  );
});
