import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';
import { scrollTargetFor } from 'site/routes/application';

module('Unit | Route | application', function (hooks) {
  setupTest(hooks);

  module('scrollTargetFor', function (innerHooks) {
    let heading: HTMLElement;

    innerHooks.beforeEach(function () {
      heading = document.createElement('h2');
      heading.id = 'accessibility';
      document.body.append(heading);
    });

    innerHooks.afterEach(function () {
      heading.remove();
    });

    test('a page change with no anchor goes to the top', function (assert) {
      assert.strictEqual(scrollTargetFor(''), 'top');
    });

    test('a bare hash goes to the top', function (assert) {
      assert.strictEqual(scrollTargetFor('#'), 'top');
    });

    test('an anchor that names a heading goes to that heading', function (assert) {
      assert.strictEqual(
        scrollTargetFor('#accessibility'),
        heading,
        'landing on /page#accessibility must not be dragged to the top'
      );
    });

    test('an anchor naming nothing on the page goes to the top', function (assert) {
      assert.strictEqual(scrollTargetFor('#no-such-heading'), 'top');
    });
  });
});
