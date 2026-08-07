const docgen = require('glimmer-docgen-typescript');
const fs = require('fs');
const path = require('path');
const lowlight = require('lowlight');
const unified = require('unified');
const rehypeStringify = require('rehype-stringify');
const { collectBoundArgs, applyBoundArgs } = require('./bound-args');

const processor = unified().use(rehypeStringify);

const root = path.resolve(path.join(__dirname, '../../'));
const pattern = 'packages/*/declarations/components/**/*.ts';

const components = docgen.parse([{ root, pattern }]);

// `WithBoundArgs<…>` renders as `never` (or an unreadable `Invokable<…>` blob) through
// the docgen type checker, so render it from the declaration source instead.
// See ./bound-args.js.
const boundArgs = collectBoundArgs(
  [...new Set(components.map((c) => path.join(root, c.fileName)))],
  root
);
components.forEach((component) => applyBoundArgs(component, boundArgs));

function highlight(property) {
  if (!property) {
    return;
  }
  if (property.type) {
    let type = property.type.type;

    type = property.type.type.replace(/"/g, "'");
    const typeTree = lowlight.highlight('ts', type).value;
    const typeHTML = processor
      .stringify({ type: 'root', children: typeTree })
      .toString();

    property.type.type = typeHTML;

    if (property.type.raw) {
      const raw = property.type.raw.replace(/"/g, "'");
      const rawTree = lowlight.highlight('ts', raw).value;
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
      property.defaultValue
    ).value;
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
});

fs.writeFileSync(
  path.join(__dirname, '../app/components/signature-data.ts'),
  `import type { ComponentDoc } from 'glimmer-docgen-typescript';
const data: ComponentDoc[] = ${JSON.stringify(components)};
export type { ComponentDoc };
export default data;`
);
