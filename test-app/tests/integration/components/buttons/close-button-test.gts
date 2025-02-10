import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { CloseButton } from '@frontile/buttons';
import { cell } from 'ember-resources';
import { settled } from '@ember/test-helpers';

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
  } as never)
});

module(
  'Integration | Component | @frontile/utilities/CloseButton',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders title', async function (assert) {
      const title = cell('');
      await render(
        <template>
          <div data-test-element><CloseButton @title={{title.current}} /></div>
        </template>
      );

      assert.dom('[data-test-element]').hasText('Close');

      title.current = 'Fechar Menu';
      await settled();

      assert.dom('[data-test-element]').hasText('Fechar Menu');
    });

    test('it allows to yield', async function (assert) {
      await render(
        <template>
          <CloseButton><div class="icon">Here is my icon</div></CloseButton>
        </template>
      );
      assert.dom('.close-button .icon').exists();

      assert.dom('.close-button .icon').hasText('Here is my icon');
    });

    test('it yields the icon classes', async function (assert) {
      await render(
        <template>
          <CloseButton as |class|><div
              class="icon"
            >{{class}}</div></CloseButton>
        </template>
      );
      assert.dom('.close-button .icon').hasText('close-button__icon');
    });

    test('it adds size classes', async function (assert) {
      const size = cell<undefined | 'xs' | 'sm' | 'md' | 'lg' | 'xl'>();
      await render(<template><CloseButton @size={{size.current}} /></template>);

      assert.dom('.close-button').hasClass('close-button--md');

      size.current = 'xs';
      await settled();
      assert.dom('.close-button').hasClass('close-button--xs');

      size.current = 'sm';
      await settled();
      assert.dom('.close-button').hasClass('close-button--sm');

      size.current = 'md';
      await settled();
      assert.dom('.close-button').hasClass('close-button--md');

      size.current = 'lg';
      await settled();
      assert.dom('.close-button').hasClass('close-button--lg');

      size.current = 'xl';
      await settled();
      assert.dom('.close-button').hasClass('close-button--xl');
    });

    test('it allows to pass @class for component curlying', async function (assert) {
      await render(<template><CloseButton @class="some-class" /></template>);
      assert.dom('.close-button').hasClass('some-class');
    });
  }
);
