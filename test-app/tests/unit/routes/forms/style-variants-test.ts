import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Route | forms/style-variants', function (hooks) {
  setupTest(hooks);

  test('it exists', function (assert) {
    const route = this.owner.lookup('route:forms/style-variants');
    assert.ok(route);
  });
});
