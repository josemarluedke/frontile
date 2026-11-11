import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Route | overlays', function (hooks) {
  setupTest(hooks);

  test('it exists', function (assert) {
    const route = this.owner.lookup('route:overlays');
    assert.ok(route);
  });
});
