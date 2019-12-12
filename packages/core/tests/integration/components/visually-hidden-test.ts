import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | visually-hidden', function(hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function(assert) {
    await render(hbs`
      <VisuallyHidden data-test-id="my-element">
        This text will be visually hidden
      </VisuallyHidden>
    `);

    assert.equal(
      this.element.textContent!.trim(),
      'This text will be visually hidden'
    );
    assert.dom('[data-test-id="my-element"]').hasClass('visually-hidden');
  });
});
