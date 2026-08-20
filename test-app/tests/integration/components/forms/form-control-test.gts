import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';

import { FormControl } from 'frontile';

module(
  'Integration | Component | @frontile/forms/FormControl',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders the :description named block without @description', async function (assert) {
      await render(
        <template>
          <FormControl>
            <:description>My description block</:description>
          </FormControl>
        </template>
      );

      assert
        .dom('[data-component="form-description"]')
        .exists('the description region renders from the named block alone');
      assert
        .dom('[data-component="form-description"]')
        .hasText('My description block');
    });

    test('it renders the :label named block without @label', async function (assert) {
      await render(
        <template>
          <FormControl>
            <:label>My label block</:label>
          </FormControl>
        </template>
      );

      assert.dom('[data-component="label"]').exists();
      assert.dom('[data-component="label"]').hasText('My label block');
    });

    test('it renders both named blocks together', async function (assert) {
      await render(
        <template>
          <FormControl>
            <:label>The label</:label>
            <:description>The description</:description>
          </FormControl>
        </template>
      );

      assert.dom('[data-component="label"]').hasText('The label');
      assert
        .dom('[data-component="form-description"]')
        .hasText('The description');
    });

    test('it still renders the @label and @description arguments', async function (assert) {
      await render(
        <template>
          <FormControl @label="Arg label" @description="Arg description" />
        </template>
      );

      assert.dom('[data-component="label"]').hasText('Arg label');
      assert
        .dom('[data-component="form-description"]')
        .hasText('Arg description');
    });

    test('it renders neither region when no label or description is provided', async function (assert) {
      await render(<template><FormControl /></template>);

      assert.dom('[data-component="label"]').doesNotExist();
      assert.dom('[data-component="form-description"]').doesNotExist();
    });
  }
);
