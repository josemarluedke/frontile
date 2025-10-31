import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';

import { FormDescription } from 'frontile';

module(
  'Integration | Component | @frontile/forms/FormDescription',
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(async function () {
      await render(
        <template>
          <FormDescription @id="description">
            My content
          </FormDescription>
        </template>
      );
    });

    test('it renders', async function (assert) {
      assert.dom('[data-component="form-description"]').hasText('My content');
      assert
        .dom('[data-component="form-description"]')
        .hasAttribute('id', 'description');
    });
  }
);
