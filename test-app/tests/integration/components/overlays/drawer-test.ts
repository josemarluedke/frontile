import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, click, triggerKeyEvent } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

registerCustomStyles({
  overlay: tv({
    slots: {
      base: '',
      backdrop: 'overlay__backdrop',
      content: 'overlay__content'
    },
    variants: {
      inPlace: {
        true: {
          backdrop: '',
          content: ''
        }
      }
    }
  }),
  drawer: tv({
    slots: {
      base: '',
      closeButton: 'drawer__close-btn',
      header: 'drawer__header',
      body: 'drawer__body',
      footer: 'drawer__footer'
    },
    variants: {
      size: {
        xs: '',
        sm: '',
        md: '',
        lg: '',
        xl: '',
        full: ''
      },
      placement: {
        top: 'drawer--top',
        bottom: 'drawer--bottom',
        left: 'drawer--left',
        right: 'drawer--right'
      }
    },
    compoundVariants: [
      // vertical
      {
        placement: ['top', 'bottom'],
        size: 'xs',
        class: 'drawer--xs-vertical'
      },
      {
        placement: ['top', 'bottom'],
        size: 'sm',
        class: 'drawer--sm-vertical'
      },
      {
        placement: ['top', 'bottom'],
        size: 'md',
        class: 'drawer--md-vertical'
      },
      {
        placement: ['top', 'bottom'],
        size: 'lg',
        class: 'drawer--lg-vertical'
      },
      {
        placement: ['top', 'bottom'],
        size: 'xl',
        class: 'drawer--xl-vertical'
      },
      {
        placement: ['top', 'bottom'],
        size: 'full',
        class: 'drawer--full-vertical'
      },

      // horizontal
      {
        placement: ['right', 'left'],
        size: 'xs',
        class: 'drawer--xs-horizontal'
      },
      {
        placement: ['right', 'left'],
        size: 'sm',
        class: 'drawer--sm-horizontal'
      },
      {
        placement: ['right', 'left'],
        size: 'md',
        class: 'drawer--md-horizontal'
      },
      {
        placement: ['right', 'left'],
        size: 'lg',
        class: 'drawer--lg-horizontal'
      },
      {
        placement: ['right', 'left'],
        size: 'xl',
        class: 'drawer--xl-horizontal'
      },
      {
        placement: ['right', 'left'],
        size: 'full',
        class: 'drawer--full-horizontal'
      }
    ]
  })
});

module('Integration | Component | @frontile/overlays/Drawer', function(hooks) {
  setupRenderingTest(hooks);

  const template = hbs`
    <div id="my-destination"></div>
    <Drawer
      @isOpen={{this.isOpen}}
      @onClose={{this.onClose}}
      @onOpen={{this.onOpen}}
      @size={{this.size}}
      @placement={{this.placement}}
      @allowClosing={{this.allowClosing}}
      @renderInPlace={{this.renderInPlace}}
      @destinationElementId="my-destination"
      @disableTransitions={{true}}
      @closeOnOutsideClick={{this.closeOnOutsideClick}}
      @closeOnEscapeKey={{this.closeOnEscapeKey}}
      @allowCloseButton={{this.allowCloseButton}}
      data-test-id="drawer"
      as |m|
    >
      <m.Header>My Header</m.Header>
      <m.Body>My Content</m.Body>
      <m.Footer>My Footer</m.Footer>
    </Drawer>
  `;

  test('it renders, header, body, footer, and close-btn', async function(assert) {
    this.set('isOpen', true);
    await render(template);

    assert.dom('[data-test-id="drawer"]').exists();
    assert.dom('[data-test-id="drawer"] .drawer__header').hasText('My Header');
    assert.dom('[data-test-id="drawer"] .drawer__body').hasText('My Content');
    assert.dom('[data-test-id="drawer"] .drawer__footer').hasText('My Footer');
    assert.dom('[data-test-id="drawer"] .drawer__close-btn').hasText('Close');
  });

  test('it renders accessibility attributes', async function(assert) {
    this.set('isOpen', true);
    await render(template);

    assert.dom('[data-test-id="drawer"]').hasAttribute('tabindex', '0');
    assert.dom('[data-test-id="drawer"]').hasAttribute('role', 'dialog');
    assert.dom('[data-test-id="drawer"]').hasAttribute('aria-labelledby');

    const ariaLablledBy =
      find('[data-test-id="drawer"]')?.getAttribute('aria-labelledby') || '';
    assert
      .dom('[data-test-id="drawer"] .drawer__header')
      .hasAttribute('id', ariaLablledBy);
  });

  test('it adds modifier class for size', async function(assert) {
    this.set('isOpen', true);
    await render(template);
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--md-horizontal');

    this.set('size', 'xs');
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--xs-horizontal');

    this.set('size', 'sm');
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--sm-horizontal');

    this.set('size', 'md');
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--md-horizontal');

    this.set('size', 'lg');
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--lg-horizontal');

    this.set('size', 'xl');
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--xl-horizontal');

    this.set('size', 'full');
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--full-horizontal');

    this.set('placement', 'top');
    this.set('size', 'lg');
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--lg-vertical');
  });

  test('it adds modifier class for placement', async function(assert) {
    this.set('isOpen', true);

    await render(template);
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--right');

    this.set('placement', 'top');
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--top');

    this.set('placement', 'bottom');
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--bottom');

    this.set('placement', 'left');
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--left');
  });

  test('it closes drawer when close button is clicked', async function(assert) {
    assert.expect(3);

    this.set('disableTransitions', true);
    this.set('isOpen', true);

    this.set('onClose', () => {
      assert.ok(true);
      this.set('isOpen', false);
    });

    await render(template);

    assert.dom('[data-test-id="drawer"]').exists();

    await click('[data-test-id="drawer"] .drawer__close-btn');
    assert.dom('[data-test-id="drawer"]').doesNotExist();
  });

  test('it does not render close button when @allowCloseButton=false', async function(assert) {
    this.set('disableTransitions', true);
    this.set('isOpen', true);
    this.set('allowCloseButton', false);

    this.set('onClose', () => {
      this.set('isOpen', false);
    });

    await render(template);

    assert.dom('[data-test-id="drawer"]').exists();
    assert.dom('[data-test-id="drawer"] .drawer__close-btn').doesNotExist();
  });

  test('it closes drawer when backdrop is clicked', async function(assert) {
    assert.expect(3);

    this.set('disableTransitions', true);
    this.set('isOpen', true);

    this.set('onClose', () => {
      assert.ok(true);
      this.set('isOpen', false);
    });

    await render(template);

    assert.dom('[data-test-id="drawer"]').exists();
    await click('.overlay__backdrop');
    assert.dom('[data-test-id="drawer"]').doesNotExist();
  });

  test('when @closeOnOutsideClick={{false}} does not close drawer', async function(assert) {
    assert.expect(1);

    this.set('closeOnOutsideClick', false);
    this.set('isOpen', true);

    this.set('onClose', () => {
      assert.ok(false, 'should not have been called');
      this.set('isOpen', false);
    });

    await render(template);
    await click('.overlay__backdrop');
    assert.dom('[data-test-id="drawer"]').exists();
  });

  test('it closes drawer when pressing Escape', async function(assert) {
    assert.expect(2);

    this.set('isOpen', true);

    this.set('onClose', () => {
      assert.ok(true);
      this.set('isOpen', false);
    });

    await render(template);
    await triggerKeyEvent(
      find('.overlay__content') as Element,
      'keydown',
      'Escape'
    );
    assert.dom('[data-test-id="drawer"]').doesNotExist();
  });

  test('when @closeOnEscapeKey={{false}} does not close drawer', async function(assert) {
    assert.expect(1);

    this.set('closeOnEscapeKey', false);
    this.set('isOpen', true);

    this.set('onClose', () => {
      assert.ok(false, 'should not have been called');
      this.set('isOpen', false);
    });

    await render(template);
    await triggerKeyEvent(document as never, 'keydown', 'Escape');
    assert.dom('[data-test-id="drawer"]').exists();
  });

  test('when @allowClosing={{false}} does not close drawer', async function(assert) {
    assert.expect(4);

    this.set('allowClosing', false);
    this.set('isOpen', true);

    this.set('onClose', () => {
      assert.ok(false, 'should not have been called');
      this.set('isOpen', false);
    });

    await render(template);

    assert.dom('[data-test-id="drawer"]').exists();
    assert.dom('[data-test-id="drawer"] .drawer__close-btn').doesNotExist();

    await click('.overlay__backdrop');
    assert.dom('[data-test-id="drawer"]').exists();

    await triggerKeyEvent(document as never, 'keydown', 'Escape');
    assert.dom('[data-test-id="drawer"]').exists();
  });

  test('when @renderInPlace={{true}} renders in place', async function(assert) {
    this.set('renderInPlace', true);
    this.set('isOpen', true);

    await render(template);
    assert.dom('.my-destination > [data-test-id="drawer"]').doesNotExist();
    // @ts-ignore
    assert.dom('[data-test-id="drawer"]', this.element).exists();
  });

  test('it executes onOpen when drawer is opened', async function(assert) {
    assert.expect(1);
    this.set('isOpen', true);
    this.set('onOpen', () => {
      assert.ok(true);
    });
    await render(template);
  });
});
