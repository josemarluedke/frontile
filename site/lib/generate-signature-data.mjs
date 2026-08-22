// ESM, not CJS: unified 11 and the remark/rehype packages @docfy/core 0.13
// pulled us up to ship as ES modules only.
import docgen from 'glimmer-docgen-typescript';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { common, createLowlight } from 'lowlight';
import { unified } from 'unified';
import rehypeStringify from 'rehype-stringify';
import remarkParse from 'remark-parse';
import remarkRehype from 'remark-rehype';
import { collectBoundArgs, applyBoundArgs } from './bound-args.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const lowlight = createLowlight(common);
const processor = unified().use(rehypeStringify);

// JSDoc descriptions are markdown — inline code especially, which 130+ of the
// argument descriptions rely on. They used to reach the page as raw text, so
// `` `none` `` rendered with its backticks showing. Convert them here, the same
// way types are converted to highlighted HTML above, and keep the docfy
// markdown plugin's stripHtml step as the inverse.
const markdownProcessor = unified()
  .use(remarkParse)
  .use(remarkRehype)
  .use(rehypeStringify);

function renderMarkdown(value, { inline } = {}) {
  if (typeof value !== 'string' || value.trim() === '') {
    return value;
  }

  const html = markdownProcessor.processSync(value).toString().trim();

  // A one-line description becomes a single <p>. Inside a table cell that just
  // contributes stray block margins, so unwrap it; multi-paragraph component
  // descriptions keep their structure.
  if (inline) {
    const single = /^<p>([\s\S]*)<\/p>$/.exec(html);
    if (single && !single[1].includes('<p>')) {
      return single[1];
    }
  }

  return html;
}

const root = path.resolve(path.join(__dirname, '../../'));
const pattern = 'packages/*/declarations/components/**/*.ts';

const components = docgen.parse([{ root, pattern }]);

// `WithBoundArgs<…>` renders as `never` (or an unreadable `Invokable<…>` blob) through
// the docgen type checker, so render it from the declaration source instead.
// See ./bound-args.js.
const boundArgs = collectBoundArgs(
  [...new Set(components.map((c) => path.join(root, c.fileName)))],
  root,
);
const applyTally = components.reduce(
  (total, component) => {
    const { expected, applied } = applyBoundArgs(component, boundArgs);
    return {
      expected: total.expected + expected,
      applied: total.applied + applied,
    };
  },
  { expected: 0, applied: 0 },
);

if (applyTally.applied !== applyTally.expected) {
  throw new Error(
    `bound-args: resolved ${applyTally.expected} bound components but only rewrote ` +
      `${applyTally.applied}. glimmer-docgen-typescript's output shape likely changed — ` +
      `the unrewritten entries are rendering as \`never\`.`,
  );
}

function highlight(property) {
  if (!property) {
    return;
  }
  if (property.type) {
    const type = property.type.type.replace(/"/g, "'");
    const typeTree = lowlight.highlight('ts', type).children;
    const typeHTML = processor
      .stringify({ type: 'root', children: typeTree })
      .toString();

    property.type.type = typeHTML;

    if (property.type.raw) {
      const raw = property.type.raw.replace(/"/g, "'");
      const rawTree = lowlight.highlight('ts', raw).children;
      const rawHTML = processor
        .stringify({ type: 'root', children: rawTree })
        .toString();

      property.type.raw = rawHTML;
    }

    if (property.type.items && property.type.items.length > 0) {
      property.type.items.forEach(highlight);
    }
  }

  if (property.defaultValue) {
    const defaultValueTree = lowlight.highlight(
      'ts',
      property.defaultValue,
    ).children;
    const defaultValueHTML = processor
      .stringify({ type: 'root', children: defaultValueTree })
      .toString();

    property.defaultValue = defaultValueHTML;
  }
}

components.forEach((component) => {
  component.Args.forEach(highlight);
  component.Blocks.forEach(highlight);
  highlight(component.Element);

  component.description = renderMarkdown(component.description);
  for (const property of [...component.Args, ...component.Blocks]) {
    property.description = renderMarkdown(property.description, {
      inline: true,
    });
  }
});

fs.writeFileSync(
  path.join(__dirname, '../app/components/signature-data.ts'),
  `import type { ComponentDoc } from 'glimmer-docgen-typescript';
const data: ComponentDoc[] = ${JSON.stringify(components)};
export type { ComponentDoc };
export default data;`,
);
