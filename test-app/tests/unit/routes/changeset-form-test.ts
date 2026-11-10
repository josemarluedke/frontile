import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Route | changeset-form', function (hooks) {
  setupTest(hooks);

  test('it exists', function (assert) {
    const route = this.owner.lookup('route:changeset-form');
    assert.ok(route);
  });
});
