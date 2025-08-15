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
    ...[
      'buttons',
      // 'changeset-form',
      'utilities',
      'status',
      'collections',
      'forms',
      'forms-legacy',
      'notifications',
      'overlays'
    ].map((pkgName) => {
      return {
        root: path.resolve(__dirname, `../packages/${pkgName}`),
        pattern: '(docs|src)/**/**/*.md',
        urlPrefix: `docs/${pkgName}`,
        urlSchema: 'manual'
      };
    })
  ],
  labels: {
    accessibility: 'Accessibility',
    migration: 'Migration',
    customization: 'Customization',
    components: 'Components',
    docs: 'Documentation',
    utilities: 'Utilities',
    collections: 'Collections',
    status: 'Status',
    buttons: 'Buttons',
    overlays: 'Overlays',
    notifications: 'Notifications',
    forms: 'Forms',
    'forms-legacy': 'Forms (Legacy)',
    'changeset-form': 'Changeset Form'
  }
};
