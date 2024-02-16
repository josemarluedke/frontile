const docgen = require('glimmer-docgen-typescript');
const fs = require('fs');
const path = require('path');
const lowlight = require('lowlight');
const unified = require('unified');
const rehypeStringify = require('rehype-stringify');

const processor = unified().use(rehypeStringify);

const components = docgen.parse([
  {
    root: path.resolve(path.join(__dirname, '../../')),
    pattern: 'packages/*/declarations/components/**/*.ts'
  }
]);

function highlight(property) {
  if (!property) {
    return;
  }
  if (property.type) {
    let type = property.type.type;

    if (type === 'enum') {
      type = property.type.raw.replace(/"/g, "'");
    }

    const typeTree = lowlight.highlight('ts', type).value;
    const typeHTML = processor
      .stringify({ type: 'root', children: typeTree })
      .toString();

    property.type.type = typeHTML;

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
