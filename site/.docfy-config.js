const path = require('path');
const autolinkHeadings = require('remark-autolink-headings');
const highlight = require('rehype-highlight');
const codeImport = require('remark-code-import');
const withProse = require('@docfy/plugin-with-prose');

/**
 * @type {import('@docfy/core/lib/types').DocfyConfig}
 */
module.exports = {
  repository: {
    url: 'https://github.com/josemarluedke/frontile',
    editBranch: 'main'
  },
  tocMaxDepth: 3,
  plugins: [withProse({ className: 'prose dark:prose-light' })],
  remarkPlugins: [autolinkHeadings, codeImport],
  rehypePlugins: [
    [
      highlight
      // {
      // languages: {
      // glimmer: require('highlightjs-glimmer').glimmer
      // }
      // }
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
      'changeset-form',
      'core',
      'forms',
      'notifications',
      'overlays'
    ].map((pkgName) => {
      return {
        root: path.resolve(__dirname, `../packages/${pkgName}`),
        pattern: '(docs|addon)/**/**/*.md',
        urlPrefix: `docs/${pkgName}`,
        urlSchema: 'manual'
      };
    })
  ],
  labels: {
    accessibility: 'Accessibility',
    components: 'Components',
    docs: 'Documentation',
    core: 'Core',
    buttons: 'Buttons',
    overlays: 'Overlays',
    notifications: 'Notifications',
    forms: 'Forms',
    'changeset-form': 'Changeset Form'
  }
};
