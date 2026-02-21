import path from 'path';
import { fileURLToPath } from 'url';
import autolinkHeadings from 'remark-autolink-headings';
import highlight from 'rehype-highlight';
import codeImport from 'remark-code-import';
import withProse from '@docfy/plugin-with-prose';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * @type {import('@docfy/core/lib/types').DocfyConfig}
 */
export default {
  repository: {
    url: 'https://github.com/josemarluedke/frontile',
    editBranch: 'main'
  },
  tocMaxDepth: 3,
  plugins: [withProse({ className: 'prose max-w-none dark:prose-invert' })],
  remarkPlugins: [autolinkHeadings, codeImport],
  rehypePlugins: [
    [
      highlight,
      {
        aliases: { javascript: 'gjs', typescript: 'gts' }
      }
    ]
  ],
  sources: [
    {
      root: path.resolve(__dirname, '../docs'),
      pattern: '**/*.md',
      urlPrefix: 'docs'
    },
    ...['buttons', 'utilities', 'status', 'collections', 'forms',
        'notifications', 'overlays'].map((scope) => ({
      root: path.resolve(__dirname, '../packages/frontile'),
      pattern: `src/components/${scope}/**/*.md`,
      urlPrefix: `docs/components/${scope}`,
      urlSchema: 'manual'
    })),
    {
      root: path.resolve(__dirname, '../packages/frontile'),
      pattern: 'src/{modifiers,utils}/**/*.md',
      urlPrefix: 'docs/components/utilities',
      urlSchema: 'manual'
    },
    {
      root: path.resolve(__dirname, '../packages/frontile'),
      pattern: 'docs/**/*.md',
      urlPrefix: 'docs/components/notifications',
      urlSchema: 'manual'
    },
    {
      root: path.resolve(__dirname, '../packages/forms-legacy'),
      pattern: '(docs|src)/**/**/*.md',
      urlPrefix: 'docs/components/forms-legacy',
      urlSchema: 'manual'
    }
  ],
  sections: {
    // Top-level sections
    'get-started': { label: 'Get Started', order: 1 },
    'theming': { label: 'Theming & Styles', order: 2 },
    'components': { label: 'Components', order: 3 },
    'accessibility': { label: 'Accessibility', order: 4 },
    'migrations': { label: 'Migrations', order: 5 },

    // Theming subsections
    'design-tokens': { label: 'Design Tokens', order: 1 },
    'configuration': { label: 'Configuration', order: 2 },

    // Component packages
    'buttons': { label: 'Buttons', order: 1 },
    'utilities': { label: 'Utilities', order: 2 },
    'status': { label: 'Status', order: 3 },
    'collections': { label: 'Collections', order: 4 },
    'forms': { label: 'Forms', order: 5 },
    'forms-legacy': { label: 'Forms (Legacy)', order: 6 },
    'notifications': { label: 'Notifications', order: 7 },
    'overlays': { label: 'Overlays', order: 8 },
    'changeset-form': { label: 'Changeset Form', order: 9 }
  }
};
