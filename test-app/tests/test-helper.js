import Application from 'test-app/app';
import QUnit from 'qunit';
import config from 'test-app/config/environment';
import { setApplication } from '@ember/test-helpers';
import { setup } from 'qunit-dom';
import { setupEmberOnerrorValidation } from 'ember-qunit';
import { start as startEmberExam } from 'ember-exam/addon-test-support';
// Must be imported before any test file is loaded (ember-exam loads them from
// `start()`, below): it captures `@frontile/theme`'s shipped, unmocked styles
// before a `*-test.gts` file's module-level `registerCustomStyles` call can
// replace them. See the comment in that module for why this can't just be
// done from within a test file.
import 'test-app/tests/helpers/real-theme-styles';

// `options` carries `availableModules` (see `tests/index.html`); ember-exam
// uses it to load only the test files this run (or `--partition`) owns, then
// hands the remaining options to ember-qunit's `start`.
export async function start(options) {
  setupEmberOnerrorValidation();

  setApplication(Application.create(config.APP));

  setup(QUnit.assert);
  await startEmberExam(options);
}
