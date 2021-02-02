const path = require('path');
const autolinkHeadings = require('remark-autolink-headings');
const highlight = require('remark-highlight.js');
const codeImport = require('remark-code-import');
const withProse = require('@docfy/plugin-with-prose');

module.exports = {
  tocMaxDepth: 3,
  plugins: [withProse({ className: 'prose dark:prose-light' })],
  remarkPlugins: [autolinkHeadings, codeImport, highlight],
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
