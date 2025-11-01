import fs from 'fs';
import path from 'path';

const testFiles = [
  {
    path: 'tests/integration/components/overlays/modal-test.ts',
    component: 'Modal',
    componentImport: "import Modal from '@frontile/overlays/components/modal';",
  },
  {
    path: 'tests/integration/components/overlays/overlay-test.ts',
    component: 'Overlay',
    componentImport: "import Overlay from '@frontile/overlays/components/overlay';",
  },
  {
    path: 'tests/integration/components/forms-legacy/form-select-test.ts',
    component: 'FormSelect',
    componentImport: "import { FormSelect } from '@frontile/forms-legacy';",
  },
  {
    path: 'tests/integration/components/forms-legacy/form-radio-group-test.ts',
    component: 'FormRadioGroup',
    componentImport: "import { FormRadioGroup } from '@frontile/forms-legacy';",
  },
  {
    path: 'tests/integration/components/forms-legacy/form-field-test.ts',
    component: 'FormField',
    componentImport: "import { FormField } from '@frontile/forms-legacy';",
  },
  {
    path: 'tests/integration/components/forms-legacy/form-field/feedback-test.ts',
    component: 'FormFieldFeedback',
    componentImport: "import { FormField } from '@frontile/forms-legacy';",
  },
  {
    path: 'tests/integration/components/forms-legacy/form-checkbox-group-test.ts',
    component: 'FormCheckboxGroup',
    componentImport: "import { FormCheckboxGroup } from '@frontile/forms-legacy';",
  },
];

function migrateTestFile(fileInfo) {
  const filePath = fileInfo.path;
  const newPath = filePath.replace('.ts', '.gts');

  console.log(`Migrating ${filePath} to ${newPath}...`);

  // Read file
  let content = fs.readFileSync(filePath, 'utf-8');

  // Remove hbs import
  content = content.replace(
    /import hbs from ['"]htmlbars-inline-precompile['"];?\n/,
    ''
  );

  // Add component import after other imports
  const importSection = content.match(/(import.*\n)+/);
  if (importSection && !content.includes(fileInfo.componentImport)) {
    const lastImport = importSection[0];
    content = content.replace(
      lastImport,
      lastImport + fileInfo.componentImport + '\n'
    );
  }

  // Find template definition
  const templateMatch = content.match(/const template = hbs`([\s\S]*?)`;/);
  if (templateMatch) {
    const templateContent = templateMatch[1];

    // Remove the template definition
    content = content.replace(/const template = hbs`[\s\S]*?`;/, '');

    // Replace all render(template) calls with inline templates
    content = content.replace(/await render\(template\);?/g, `await render(<template>${templateContent}</template>);`);
  }

  // Write the new file
  fs.writeFileSync(newPath, content);

  // Remove old file if different
  if (filePath !== newPath && fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
  }

  console.log(`✓ Migrated ${filePath}`);
}

// Migrate all files
testFiles.forEach(migrateTestFile);

console.log('\\nAll test files migrated successfully!');
