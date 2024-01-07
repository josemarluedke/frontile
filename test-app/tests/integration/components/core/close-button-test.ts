import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, RenderingTestContext } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

registerCustomStyles({
  closeButton: tv({
    slots: {
      base: 'close-button',
      icon: 'close-button__icon'
    },

    variants: {
      size: {
        xs: 'close-button--xs',
        sm: 'close-button--sm',
        md: 'close-button--md',
        lg: 'close-button--lg',
        xl: 'close-button--xl'
      }
    },
    defaultVariants: {
      size: 'md'
    }
  })
});

module(
  'Integration | Component | @frontile/core/CloseButton',
  function(hooks) {
    setupRenderingTest(hooks);

    test('it renders title', async function(this: RenderingTestContext, assert) {
      await render(hbs`<CloseButton @title={{this.title}} />`);

      assert.equal(this.element.textContent?.trim(), 'Close');

      this.set('title', 'Fechar Menu');
      assert.equal(this.element.textContent?.trim(), 'Fechar Menu');
    });

    test('it allows to yield', async function(assert) {
      await render(
        hbs`<CloseButton><div class="icon">Here is my icon</div></CloseButton>`
      );
      assert.dom('.close-button .icon').exists();

      assert.dom('.close-button .icon').hasText('Here is my icon');
    });

    test('it yields the icon classes', async function(assert) {
      await render(
        hbs`<CloseButton as |class|><div class="icon">{{class}}</div></CloseButton>`
      );
      assert.dom('.close-button .icon').hasText('close-button__icon');
    });

    test('it adds size classes', async function(assert) {
      await render(hbs`<CloseButton @size={{this.size}} />`);

      assert.dom('.close-button').hasClass('close-button--md');

      this.set('size', 'xs');
      assert.dom('.close-button').hasClass('close-button--xs');

      this.set('size', 'sm');
      assert.dom('.close-button').hasClass('close-button--sm');

      this.set('size', 'md');
      assert.dom('.close-button').hasClass('close-button--md');

      this.set('size', 'lg');
      assert.dom('.close-button').hasClass('close-button--lg');

      this.set('size', 'xl');
      assert.dom('.close-button').hasClass('close-button--xl');
    });

    test('it allows to pass @class for component curlying', async function(assert) {
      await render(hbs`<CloseButton @class="some-class" />`);
      assert.dom('.close-button').hasClass('some-class');
    });
  }
);
