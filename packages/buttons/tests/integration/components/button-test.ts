import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | Button', function(hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function(assert) {
    await render(hbs`<Button data-test-id="button">My Button</Button>`);

    assert.dom('[data-test-id="button"]').hasText('My Button');
  });

  test('it accepts type attribute', async function(assert) {
    await render(
      hbs`<Button type="submit" data-test-id="button">My Button</Button>`
    );

    assert.dom('[data-test-id="button"]').hasAttribute('type', 'submit');
  });
});
