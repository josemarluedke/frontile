import path from 'path';
import { fileURLToPath } from 'url';
import autolinkHeadings from 'rehype-autolink-headings';
import highlight from 'rehype-highlight';
import codeImport from 'remark-code-import';
import { glimmer, glimmerJavascript } from 'highlightjs-glimmer';
import { common } from 'lowlight';
import withProse from '@docfy/plugin-with-prose';
import docfyPluginSignatureMarkdown, {
  loadSignatureData,
} from './lib/docfy-plugin-signature-markdown.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// gts is gjs with TypeScript inside; the grammar takes the sublanguage to
// delegate to as its second argument, so the TS flavour is a thin wrapper.
// Registering it under its own name (rather than through `registerInjections`)
// leaves plain js/ts fences on the stock grammars.
function glimmerTypescript(hljs) {
  return {
    ...glimmerJavascript(hljs, 'typescript'),
    name: 'glimmer-typescript',
    aliases: ['glimmer-ts', 'gts'],
  };
}

const signatureData = loadSignatureData(
  path.resolve(__dirname, 'app/components/signature-data.ts'),
);

/**
 * @type {import('@docfy/core/lib/types').DocfyConfig}
 */
export default {
  repository: {
    url: 'https://github.com/josemarluedke/frontile',
    editBranch: 'main',
  },
  tocMaxDepth: 3,
  plugins: [
    withProse({ className: 'prose max-w-none dark:prose-invert' }),
    docfyPluginSignatureMarkdown(signatureData),
  ],
  remarkPlugins: [
    // Every source below lives outside this app (../docs, ../packages/*), and
    // remark-code-import v1 refuses to read anything outside `rootDir`
    // (default: cwd), so point it at the repo root.
    [codeImport, { rootDir: path.resolve(__dirname, '..') }],
  ],
  rehypePlugins: [
    autolinkHeadings,
    [
      highlight,
      {
        // `languages` replaces rehype-highlight's default set, so lowlight's
        // `common` has to be spread back in or every other language stops
        // highlighting. highlightjs-glimmer is what finally highlights the
        // fences the docs are actually written in: `glimmer` claims hbs and
        // htmlbars, and the two glimmer-javascript grammars claim gjs/gts —
        // `<template>` tags and hbs`` literals included, instead of the plain
        // js/ts they used to fall back to.
        languages: {
          ...common,
          glimmer,
          'glimmer-javascript': glimmerJavascript,
          'glimmer-typescript': glimmerTypescript,
        },
        aliases: { glimmer: ['handlebars'] },
      },
    ],
  ],
  sources: [
    {
      root: path.resolve(__dirname, '../docs'),
      pattern: '**/*.md',
      // `docs/superpowers/` holds working documents for in-flight work (plans
      // and design specs), not published documentation. Ignored as a directory
      // so anything added there later stays unpublished too.
      ignore: ['superpowers/**'],
      urlPrefix: 'docs',
    },
    ...[
      'buttons',
      'utilities',
      'status',
      'collections',
      'forms',
      'notifications',
      'overlays',
    ].map((scope) => ({
      root: path.resolve(__dirname, '../packages/frontile'),
      pattern: `src/components/${scope}/**/*.md`,
      urlPrefix: `docs/components/${scope}`,
      urlSchema: 'manual',
    })),
    {
      root: path.resolve(__dirname, '../packages/frontile'),
      pattern: 'src/{modifiers,utils}/**/*.md',
      urlPrefix: 'docs/components/utilities',
      urlSchema: 'manual',
    },
    {
      root: path.resolve(__dirname, '../packages/frontile'),
      pattern: 'docs/**/*.md',
      urlPrefix: 'docs/components/notifications',
      urlSchema: 'manual',
    },
    {
      root: path.resolve(__dirname, '../packages/forms-legacy'),
      pattern: '(docs|src)/**/**/*.md',
      urlPrefix: 'docs/components/forms-legacy',
      urlSchema: 'manual',
    },
  ],
  sections: {
    // Top-level sections
    'get-started': { label: 'Get Started', order: 1 },
    theming: { label: 'Theming & Styles', order: 2 },
    components: { label: 'Components', order: 3 },
    accessibility: { label: 'Accessibility', order: 4 },
    migrations: { label: 'Migrations', order: 5 },

    // Theming subsections
    'design-tokens': { label: 'Design Tokens', order: 1 },
    configuration: { label: 'Configuration', order: 2 },

    // Component packages
    buttons: { label: 'Buttons', order: 1 },
    utilities: { label: 'Utilities', order: 2 },
    status: { label: 'Status', order: 3 },
    collections: { label: 'Collections', order: 4 },
    forms: { label: 'Forms', order: 5 },
    'forms-legacy': { label: 'Forms (Legacy)', order: 6 },
    notifications: { label: 'Notifications', order: 7 },
    overlays: { label: 'Overlays', order: 8 },
    'changeset-form': { label: 'Changeset Form', order: 9 },
  },
};
