import Application from 'test-app/app';
import QUnit from 'qunit';
import config from 'test-app/config/environment';
import { setApplication } from '@ember/test-helpers';
import { setup } from 'qunit-dom';
import { setupEmberOnerrorValidation } from 'ember-qunit';
import { start as startEmberExam } from 'ember-exam/addon-test-support';
// Must be imported before any test file is loaded (ember-exam loads them from
// `start()`, below): it captures `@frontile/theme`'s shipped, unmocked styles
// before any test can replace them. See the comment in that module.
import 'test-app/tests/helpers/real-theme-styles';
import {
  leakedStyleKeys,
  restoreRealStyles
} from 'test-app/tests/helpers/scoped-styles';

// Every test must undo the style overrides it registers (use
// `useCustomStyles`/`useRealStyles` from `helpers/scoped-styles`, or restore
// in a `finally`), or later tests render against its stubs and results depend
// on test order. Global `afterEach` hooks run after the module's own, so by
// now everything should be back to the shipped styles.
QUnit.hooks.afterEach(function (assert) {
  const keys = leakedStyleKeys();
  if (keys.length > 0) {
    restoreRealStyles();
    assert.pushResult({
      result: false,
      actual: keys,
      expected: [],
      message: `test left style overrides registered for: ${keys.join(', ')}`
    });
  }
});

// A test that lets an error escape a render (even one `setupOnerror` catches)
// leaves Ember's renderer re-running the failed root on every later run loop,
// for the rest of the run, each time warning "Attempted to rerender, but the
// Ember application has had an unrecoverable error". Fail the test where that
// first shows up, once. Test a development assertion with `collectAssertions`
// (`helpers/collect-assertions`), which records it instead of throwing.
const POISONED_RENDERER = /^Attempted to rerender, but the Ember application/;
let rendererPoisoned = false;
let rendererPoisonReported = false;
const originalWarn = console.warn;
console.warn = function (...args) {
  if (typeof args[0] === 'string' && POISONED_RENDERER.test(args[0])) {
    rendererPoisoned = true;
  }
  return originalWarn.apply(this, args);
};
QUnit.hooks.afterEach(function (assert) {
  if (rendererPoisoned && !rendererPoisonReported) {
    rendererPoisonReported = true;
    assert.pushResult({
      result: false,
      actual: 'renderer re-running a failed root',
      expected: 'no render errors left behind',
      message:
        'an error escaped a render in this test (or the one before it); every later render now warns "Attempted to rerender..."'
    });
  }
});

// `options` carries `availableModules` (see `tests/index.html`); ember-exam
// uses it to load only the test files this run (or `--partition`) owns, then
// hands the remaining options to ember-qunit's `start`.
export async function start(options) {
  setupEmberOnerrorValidation();

  setApplication(Application.create(config.APP));

  setup(QUnit.assert);
  await startEmberExam(options);
}
