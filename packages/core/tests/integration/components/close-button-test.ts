import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | CloseButton', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders title', async function (assert) {
    await render(hbs`<CloseButton @title={{this.title}} />`);

    assert.equal(this.element.textContent?.trim(), 'Close');

    this.set('title', 'Fechar Menu');
    assert.equal(this.element.textContent?.trim(), 'Fechar Menu');
  });

  test('it allows to yield', async function (assert) {
    await render(
      hbs`<CloseButton><div class="icon">Here is my icon</div></CloseButton>`
    );
    assert.dom('.close-button .icon').exists();

    assert.dom('.close-button .icon').hasText('Here is my icon');
  });

  test('it yields the icon classes', async function (assert) {
    await render(
      hbs`<CloseButton as |class|><div class="icon">{{class}}</div></CloseButton>`
    );
    assert
      .dom('.close-button .icon')
      .hasText('close-button__icon close-button--sm__icon');
  });

  test('it adds size classes', async function (assert) {
    await render(hbs`<CloseButton @size={{this.size}} />`);

    assert.dom('.close-button').hasClass('close-button--sm');
    assert
      .dom('.close-button .close-button__icon')
      .hasClass('close-button--sm__icon');

    this.set('size', 'xm');
    assert.dom('.close-button').hasClass('close-button--xm');
    assert
      .dom('.close-button .close-button__icon')
      .hasClass('close-button--xm__icon');

    this.set('size', 'sm');
    assert.dom('.close-button').hasClass('close-button--sm');
    assert
      .dom('.close-button .close-button__icon')
      .hasClass('close-button--sm__icon');

    this.set('size', 'md');
    assert.dom('.close-button').hasClass('close-button--md');
    assert
      .dom('.close-button .close-button__icon')
      .hasClass('close-button--md__icon');

    this.set('size', 'lg');
    assert.dom('.close-button').hasClass('close-button--lg');
    assert
      .dom('.close-button .close-button__icon')
      .hasClass('close-button--lg__icon');

    this.set('size', 'xl');
    assert.dom('.close-button').hasClass('close-button--xl');
    assert
      .dom('.close-button .close-button__icon')
      .hasClass('close-button--xl__icon');
  });
});
