import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module(
  'Integration | Component | @frontile/forms/FormField::Radio',
  function(hooks) {
    setupRenderingTest(hooks);

    test('it renders with html attributes', async function(assert) {
      await render(hbs`<FormField::Radio
                      name="some-name"
                      data-test-radio />`);

      assert.dom('[data-test-radio]').exists();
      assert.dom('[name="some-name"]').exists();
    });

    test('it renders @id arg', async function(assert) {
      await render(hbs`<FormField::Radio @id="my-id" data-test-radio />`);

      assert.dom('[data-test-radio]').hasAttribute('id', 'my-id');
    });

    test('it renders id html attribute', async function(assert) {
      await render(hbs`<FormField::Radio id="my-id" data-test-radio />`);

      assert.dom('[data-test-radio]').hasAttribute('id', 'my-id');
    });

    test('it renders @name arg', async function(assert) {
      await render(hbs`<FormField::Radio @name="my-name" data-test-radio />`);

      assert.dom('[data-test-radio]').hasAttribute('name', 'my-name');
    });

    test('it renders name html attribute', async function(assert) {
      await render(hbs`<FormField::Radio name="my-name" data-test-radio />`);

      assert.dom('[data-test-radio]').hasAttribute('name', 'my-name');
    });

    test('it sets as checked if @value and @checked are equal', async function(assert) {
      this.set('value', 'something-else');

      await render(
        hbs`<FormField::Radio
            data-test-radio
            @checked={{this.value}}
            @value="something"
          />`
      );

      assert.dom('[data-test-radio]').isNotChecked();

      this.set('value', 'something');
      assert.dom('[data-test-radio]').isChecked();
    });

    test('renders @checed arg, does not mutate it by default', async function(assert) {
      this.set('value', undefined);

      await render(
        hbs`<FormField::Radio data-test-radio @checked={{this.value}} @value="something" />`
      );

      assert.dom('[data-test-radio]').isNotChecked();
      await click('[data-test-radio]');

      assert.equal(this.value, undefined, 'should have not mutated the value');
    });

    test('should call @onChange function arg', async function(assert) {
      assert.expect(4);
      this.set('value', undefined);

      this.set('setName', (value: string) => {
        this.set('value', value);
        assert.ok(true, 'should have called function');
      });

      await render(
        hbs`<FormField::Radio
            data-test-radio
            @value={{"my-value"}}
            @checked={{this.value}}
            @onChange={{this.setName}}
          />`
      );

      assert.dom('[data-test-radio]').isNotChecked();

      await click('[data-test-radio]');

      assert.dom('[data-test-radio]').isChecked();
      assert.equal(this.value, 'my-value', 'should have mutated the value');
    });
  }
);
