import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { Button } from 'frontile';

// Separate from buttons-test.gts, which swaps in a stub style recipe and so
// never sees the real classes.
module('Integration | Component | Button | cursor', function (hooks) {
  setupRenderingTest(hooks);

  test('it shows a pointer, and not-allowed once disabled', async function (assert) {
    await render(
      <template>
        <Button data-test-id="on">Save</Button>
        <Button disabled data-test-id="off">Save</Button>
      </template>
    );

    const cursor = (id: string) =>
      getComputedStyle(document.querySelector(`[data-test-id="${id}"]`)!)
        .cursor;
    assert.strictEqual(cursor('on'), 'pointer');
    assert.strictEqual(cursor('off'), 'not-allowed');
  });
});
