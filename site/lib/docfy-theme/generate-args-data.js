const docgen = require('glimmer-docgen-typescript');
const fs = require('fs');
const path = require('path');

const components = docgen.parse([
  {
    root: path.resolve(path.join(__dirname, '../../../')),
    pattern: 'packages/**/addon/components/**/*.ts'
  }
]);

fs.writeFileSync(
  path.join(__dirname, 'addon/components/args-data.js'),
  `export default ${JSON.stringify(components)};`
);
