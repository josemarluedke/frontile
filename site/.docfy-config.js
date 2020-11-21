const path = require('path');
const autolinkHeadings = require('remark-autolink-headings');
const highlight = require('remark-highlight.js');
const codeImport = require('remark-code-import');

const shouldUnproseNode = (node) => {
  return (
    ['html'].includes(node.type) ||
    (node.type === 'code' &&
      ['component', 'template', 'preview-template'].includes(node.meta))
  );
};

// Credit: https://github.com/tailwindlabs/tailwindcss.com/blob/1234b4faded6c7a06b734c49c61257137b4acc9b/remark/withProse.js
const withProse = (tree) => {
  let insideProse = false;
  tree.children = tree.children.flatMap((node, i) => {
    if (insideProse && shouldUnproseNode(node)) {
      insideProse = false;
      return [{ type: 'html', value: '</div>' }, node];
    }
    if (!insideProse && !shouldUnproseNode(node)) {
      insideProse = true;
      return [
        { type: 'html', value: '<div class="prose">' },
        node,
        ...(i === tree.children.length - 1
          ? [{ type: 'html', value: '</div>' }]
          : [])
      ];
    }
    if (i === tree.children.length - 1 && insideProse) {
      return [node, { type: 'html', value: '</div>' }];
    }
    return [node];
  });
};

const docfyWithProse = (ctx) => {
  ctx.pages.forEach((page) => {
    withProse(page.ast);
  });
};

module.exports = {
  tocMaxDepth: 3,
  remarkPlugins: [
    [
      autolinkHeadings,
      {
        behavior: 'wrap'
      }
    ],
    codeImport,
    highlight
  ],
  plugins: [docfyWithProse],
  sources: [
    {
      root: path.resolve(__dirname, '../docs'),
      pattern: '**/*.md',
      urlPrefix: 'docs'
    },
    {
      root: path.resolve(__dirname, '../packages/core/docs'),
      pattern: '**/*.md',
      urlPrefix: 'docs/core',
      urlSchema: 'manual'
    },
    {
      root: path.resolve(__dirname, '../packages/core/addon'),
      pattern: '**/*.md',
      urlPrefix: 'docs/core',
      urlSchema: 'manual'
    }
  ],
  labels: {
    components: 'Components',
    docs: 'Documentation',
    core: '@frontile/core',
    accessibility: 'Accessibility'
  }
};
