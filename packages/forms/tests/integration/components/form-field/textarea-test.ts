import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, fillIn } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | FormField::Textarea', function(hooks) {
  setupRenderingTest(hooks);

  test('it renders with html attributes', async function(assert) {
    await render(hbs`<FormField::Textarea
                      name="some-name"
                      data-test-textarea />`);

    assert.dom('[data-test-textarea]').exists();
    assert.dom('[name="some-name"]').exists();
  });

  test('it renders @id arg', async function(assert) {
    await render(hbs`<FormField::Textarea @id="my-id" data-test-textarea />`);

    assert.dom('[data-test-textarea]').hasAttribute('id', 'my-id');
  });

  test('it renders id html attribute', async function(assert) {
    await render(hbs`<FormField::Textarea id="my-id" data-test-textarea />`);

    assert.dom('[data-test-textarea]').hasAttribute('id', 'my-id');
  });

  test('it adds size classes for @isSmall and @isLarge', async function(assert) {
    this.set('isSmall', true);
    this.set('isLarge', false);

    await render(
      hbs`<FormField::Textarea data-test-input @isSmall={{this.isSmall}} @isLarge={{this.isLarge}} />`
    );

    assert.dom('[data-test-input]').hasClass('form-textarea-sm');
    this.set('isSmall', false);
    this.set('isLarge', true);
    assert.dom('[data-test-input]').hasClass('form-textarea-lg');

    // should only add one size class
    this.set('isSmall', true);
    this.set('isLarge', true);
    assert.dom('[data-test-input]').hasClass('form-textarea-sm');
    assert.dom('[data-test-input]').doesNotHaveClass('form-textarea-lg');
  });

  test('renders @value arg, does not mutate it by default', async function(assert) {
    this.set('value', 'Josemar');

    await render(
      hbs`<FormField::Textarea class="my-input" @value={{this.value}} />`
    );

    assert.dom('.my-input').hasValue('Josemar');

    await fillIn('.my-input', 'Sam');

    assert.equal(
      this.get('value'),
      'Josemar',
      'should have not mutated the value'
    );
  });

  test('should call @onInput function arg', async function(assert) {
    assert.expect(4);
    this.set('value', 'Josemar');

    this.set('setName', (value: string) => {
      this.set('value', value);
      assert.ok(true, 'should have called function');
    });

    await render(
      hbs`<FormField::Textarea
            class="my-input"
            @value={{this.value}}
            @onInput={{this.setName}}
          />`
    );

    assert.dom('.my-input').hasValue('Josemar');

    await fillIn('.my-input', 'Sam');

    assert.dom('.my-input').hasValue('Sam');
    assert.equal(this.get('value'), 'Sam', 'should have mutated the value');
  });

  test('should call @onChange function arg', async function(assert) {
    assert.expect(4);
    this.set('value', 'Josemar');

    this.set('setName', (value: string) => {
      this.set('value', value);
      assert.ok(true, 'should have called function');
    });

    await render(
      hbs`<FormField::Textarea
            class="my-input"
            @value={{this.value}}
            @onChange={{this.setName}}
          />`
    );

    assert.dom('.my-input').hasValue('Josemar');

    await fillIn('.my-input', 'Sam');

    assert.dom('.my-input').hasValue('Sam');
    assert.equal(this.get('value'), 'Sam', 'should have mutated the value');
  });
});
