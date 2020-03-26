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

  test('it adds size classes for @isSmall and @isLarge', async function (assert) {
    this.set('isSmall', true);
    this.set('isLarge', false);

    await render(
      hbs`<FormField::Checkbox data-test-input @isSmall={{this.isSmall}} @isLarge={{this.isLarge}} />`
    );

    assert.dom('[data-test-input]').hasClass('form-checkbox-sm');
    this.set('isSmall', false);
    this.set('isLarge', true);
    assert.dom('[data-test-input]').hasClass('form-checkbox-lg');

    // should only add one size class
    this.set('isSmall', true);
    this.set('isLarge', true);
    assert.dom('[data-test-input]').hasClass('form-checkbox-sm');
    assert.dom('[data-test-input]').doesNotHaveClass('form-checkbox-lg');
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

    assert.equal(this.get('value'), true, 'should have not mutated the value');
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
    assert.equal(this.get('value'), true, 'should have mutated the value');
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
