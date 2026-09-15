import Application from 'test-app/app';
import QUnit from 'qunit';
import config from 'test-app/config/environment';
import { setApplication } from '@ember/test-helpers';
import { setup } from 'qunit-dom';
import { start as qunitStart, setupEmberOnerrorValidation } from 'ember-qunit';
// Must be imported before `tests/index.html`'s `import.meta.glob(...,
// { eager: true })` runs: it captures `@frontile/theme`'s shipped, unmocked
// styles before any `*-test.gts` file's module-level `registerCustomStyles`
// call (which that glob is what triggers) can replace them. See the comment
// in that module for why this can't just be done from within a test file.
import 'test-app/tests/helpers/real-theme-styles';

export function start() {
  setupEmberOnerrorValidation();

  setApplication(Application.create(config.APP));

  setup(QUnit.assert);
  qunitStart();
}
