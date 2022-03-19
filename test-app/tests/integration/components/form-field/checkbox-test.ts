import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | FormField::Checkbox', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders with html attributes', async function (assert) {
    await render(hbs`<FormField::Checkbox
                      name="some-name"
                      data-test-checkbox />`);

    assert.dom('[data-test-checkbox]').exists();
    assert.dom('[name="some-name"]').exists();
  });

  test('it renders @id arg', async function (assert) {
    await render(hbs`<FormField::Checkbox @id="my-id" data-test-checkbox />`);

    assert.dom('[data-test-checkbox]').hasAttribute('id', 'my-id');
  });

  test('it adds size classes for @size', async function (assert) {
    this.set('size', 'sm');

    await render(
      hbs`<FormField::Checkbox data-test-input @size={{this.size}} />`
    );

    assert.dom('[data-test-input]').hasClass('form-field-checkbox--sm');

    this.set('size', 'lg');
    assert.dom('[data-test-input]').hasClass('form-field-checkbox--lg');
  });

  test('it renders id html attribute', async function (assert) {
    await render(hbs`<FormField::Checkbox id="my-id" data-test-checkbox />`);

    assert.dom('[data-test-checkbox]').hasAttribute('id', 'my-id');
  });

  test('it renders @name arg', async function (assert) {
    await render(
      hbs`<FormField::Checkbox @name="my-name" data-test-checkbox />`
    );

    assert.dom('[data-test-checkbox]').hasAttribute('name', 'my-name');
  });

  test('it renders name html attribute', async function (assert) {
    await render(
      hbs`<FormField::Checkbox name="my-name" data-test-checkbox />`
    );

    assert.dom('[data-test-checkbox]').hasAttribute('name', 'my-name');
  });

  test('renders @checed arg, does not mutate it by default', async function (assert) {
    this.set('value', true);

    await render(
      hbs`<FormField::Checkbox data-test-checkbox @checked={{this.value}} />`
    );

    assert.dom('[data-test-checkbox]').isChecked();
    await click('[data-test-checkbox]');

    assert.equal(this.value, true, 'should have not mutated the value');
  });

  test('should call @onChange function arg', async function (assert) {
    assert.expect(4);
    this.set('value', undefined);

    this.set('setName', (value: string) => {
      this.set('value', value);
      assert.ok(true, 'should have called function');
    });

    await render(
      hbs`<FormField::Checkbox
            data-test-checkbox
            @value={{this.value}}
            @onChange={{this.setName}}
          />`
    );

    assert.dom('[data-test-checkbox]').isNotChecked();

    await click('[data-test-checkbox]');

    assert.dom('[data-test-checkbox]').isChecked();
    assert.equal(this.value, true, 'should have mutated the value');
  });

  test('it sets as checked if value is truthy', async function (assert) {
    this.set('value', undefined);

    await render(
      hbs`<FormField::Checkbox
            data-test-checkbox
            @checked={{this.value}}
          />`
    );

    assert.dom('[data-test-checkbox]').isNotChecked();

    this.set('value', true);
    assert.dom('[data-test-checkbox]').isChecked();

    this.set('value', false);
    assert.dom('[data-test-checkbox]').isNotChecked();
  });
});
