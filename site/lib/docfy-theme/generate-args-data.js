const docgen = require('glimmer-docgen-typescript');
const fs = require('fs');
const path = require('path');
const lowlight = require('lowlight');
const unified = require('unified');
const rehypeStringify = require('rehype-stringify');

const processor = unified().use(rehypeStringify);

const components = docgen.parse([
  {
    root: path.resolve(path.join(__dirname, '../../../')),
    pattern: 'packages/**/addon/components/**/*.ts'
  }
]);

components.forEach((component) => {
  component.args.forEach((arg) => {
    let type = arg.type.name;

    if (type === 'enum') {
      type = arg.type.raw.replace(/"/g, "'");
    }

    const typeTree = lowlight.highlight('ts', type).value;
    const typeHTML = processor
      .stringify({ type: 'root', children: typeTree })
      .toString();

    arg.highlightedType = typeHTML;

    if (arg.defaultValue) {
      const defaultValueTree = lowlight.highlight('ts', arg.defaultValue).value;
      const defaultValueHTML = processor
        .stringify({ type: 'root', children: defaultValueTree })
        .toString();

      arg.highlightedDefaultValue = defaultValueHTML;
    }
  });
});

fs.writeFileSync(
  path.join(__dirname, 'addon/components/args-data.js'),
  `export default ${JSON.stringify(components)};`
);
