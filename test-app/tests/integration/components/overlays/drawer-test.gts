import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  click,
  triggerKeyEvent,
  settled
} from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import Drawer from '@frontile/overlays/components/drawer';
import { cell } from 'ember-resources';

module('Integration | Component | @frontile/overlays/Drawer', function (hooks) {
  setupRenderingTest(hooks);

  registerCustomStyles({
    backdrop: tv({ base: 'overlay__backdrop' }) as never,
    overlay: tv({
      base: 'overlay__content',
      variants: {
        inPlace: {
          true: 'overlay--in-place'
        }
      }
    }) as never,
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

  test('it renders, header, body, footer, and close-btn', async function (assert) {
    const isOpen = cell(true);
    const onClose = () => {};
    const onOpen = () => {};
    const size = cell<string | undefined>(undefined);
    const placement = cell<string | undefined>(undefined);
    const allowClosing = cell<boolean | undefined>(undefined);
    const renderInPlace = cell<boolean | undefined>(undefined);
    const closeOnOutsideClick = cell<boolean | undefined>(undefined);
    const closeOnEscapeKey = cell<boolean | undefined>(undefined);
    const allowCloseButton = cell<boolean | undefined>(undefined);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @onOpen={{onOpen}}
          @size={{size.current}}
          @placement={{placement.current}}
          @allowClosing={{allowClosing.current}}
          @renderInPlace={{renderInPlace.current}}
          @disableTransitions={{true}}
          @closeOnOutsideClick={{closeOnOutsideClick.current}}
          @closeOnEscapeKey={{closeOnEscapeKey.current}}
          @allowCloseButton={{allowCloseButton.current}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Drawer>
      </template>
    );

    assert.dom('[data-test-id="drawer"]').exists();
    assert.dom('[data-test-id="drawer"] .drawer__header').hasText('My Header');
    assert.dom('[data-test-id="drawer"] .drawer__body').hasText('My Content');
    assert.dom('[data-test-id="drawer"] .drawer__footer').hasText('My Footer');
    assert.dom('[data-test-id="drawer"] .drawer__close-btn').hasText('Close');
  });

  test('it renders accessibility attributes', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Drawer>
      </template>
    );

    assert.dom('[data-test-id="drawer"]').hasAttribute('tabindex', '0');
    assert.dom('[data-test-id="drawer"]').hasAttribute('role', 'dialog');
    assert.dom('[data-test-id="drawer"]').hasAttribute('aria-labelledby');

    const ariaLablledBy =
      find('[data-test-id="drawer"]')?.getAttribute('aria-labelledby') || '';
    assert
      .dom('[data-test-id="drawer"] .drawer__header')
      .hasAttribute('id', ariaLablledBy);
  });

  test('it adds modifier class for size', async function (assert) {
    const isOpen = cell(true);
    const size = cell<string | undefined>(undefined);
    const placement = cell<string | undefined>(undefined);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @size={{size.current}}
          @placement={{placement.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Drawer>
      </template>
    );
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--md-horizontal');

    size.current = 'xs';
    await settled();
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--xs-horizontal');

    size.current = 'sm';
    await settled();
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--sm-horizontal');

    size.current = 'md';
    await settled();
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--md-horizontal');

    size.current = 'lg';
    await settled();
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--lg-horizontal');

    size.current = 'xl';
    await settled();
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--xl-horizontal');

    size.current = 'full';
    await settled();
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--full-horizontal');

    placement.current = 'top';
    size.current = 'lg';
    await settled();
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--lg-vertical');
  });

  test('it adds modifier class for placement', async function (assert) {
    const isOpen = cell(true);
    const placement = cell<string | undefined>(undefined);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @placement={{placement.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Drawer>
      </template>
    );
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--right');

    placement.current = 'top';
    await settled();
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--top');

    placement.current = 'bottom';
    await settled();
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--bottom');

    placement.current = 'left';
    await settled();
    assert.dom('[data-test-id="drawer"]').hasClass('drawer--left');
  });

  test('it closes drawer when close button is clicked', async function (assert) {
    assert.expect(3);

    const isOpen = cell(true);
    const onClose = () => {
      assert.ok(true);
      isOpen.current = false;
    };

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Drawer>
      </template>
    );

    assert.dom('[data-test-id="drawer"]').exists();

    await click('[data-test-id="drawer"] .drawer__close-btn');
    assert.dom('[data-test-id="drawer"]').doesNotExist();
  });

  test('it does not render close button when @allowCloseButton=false', async function (assert) {
    const isOpen = cell(true);
    const allowCloseButton = cell(false);
    const onClose = () => {
      isOpen.current = false;
    };

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @allowCloseButton={{allowCloseButton.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Drawer>
      </template>
    );

    assert.dom('[data-test-id="drawer"]').exists();
    assert.dom('[data-test-id="drawer"] .drawer__close-btn').doesNotExist();
  });

  test('it closes drawer when backdrop is clicked', async function (assert) {
    assert.expect(3);

    const isOpen = cell(true);
    const onClose = () => {
      assert.ok(true);
      isOpen.current = false;
    };

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Drawer>
      </template>
    );

    assert.dom('[data-test-id="drawer"]').exists();
    await click('.overlay__backdrop');
    assert.dom('[data-test-id="drawer"]').doesNotExist();
  });

  test('when @closeOnOutsideClick={{false}} does not close drawer', async function (assert) {
    assert.expect(1);

    const isOpen = cell(true);
    const closeOnOutsideClick = cell(false);
    const onClose = () => {
      assert.ok(false, 'should not have been called');
      isOpen.current = false;
    };

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @closeOnOutsideClick={{closeOnOutsideClick.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Drawer>
      </template>
    );
    await click('.overlay__backdrop');
    assert.dom('[data-test-id="drawer"]').exists();
  });

  test('it closes drawer when pressing Escape', async function (assert) {
    assert.expect(2);

    const isOpen = cell(true);
    const onClose = () => {
      assert.ok(true);
      isOpen.current = false;
    };

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Drawer>
      </template>
    );
    await triggerKeyEvent('.overlay__content', 'keydown', 'Escape');
    assert.dom('[data-test-id="drawer"]').doesNotExist();
  });

  test('when @closeOnEscapeKey={{false}} does not close drawer', async function (assert) {
    assert.expect(1);

    const isOpen = cell(true);
    const closeOnEscapeKey = cell(false);
    const onClose = () => {
      assert.ok(false, 'should not have been called');
      isOpen.current = false;
    };

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @closeOnEscapeKey={{closeOnEscapeKey.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Drawer>
      </template>
    );
    await triggerKeyEvent(document as never, 'keydown', 'Escape');
    assert.dom('[data-test-id="drawer"]').exists();
  });

  test('when @allowClosing={{false}} does not close drawer', async function (assert) {
    assert.expect(4);

    const isOpen = cell(true);
    const allowClosing = cell(false);
    const onClose = () => {
      assert.ok(false, 'should not have been called');
      isOpen.current = false;
    };

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @allowClosing={{allowClosing.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Drawer>
      </template>
    );

    assert.dom('[data-test-id="drawer"]').exists();
    assert.dom('[data-test-id="drawer"] .drawer__close-btn').doesNotExist();

    await click('.overlay__backdrop');
    assert.dom('[data-test-id="drawer"]').exists();

    await triggerKeyEvent(document as never, 'keydown', 'Escape');
    assert.dom('[data-test-id="drawer"]').exists();
  });

  test('when @renderInPlace={{true}} renders in place', async function (assert) {
    const isOpen = cell(true);
    const renderInPlace = cell(true);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @renderInPlace={{renderInPlace.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Drawer>
      </template>
    );
    assert.dom('[data-portal-target] > [data-test-id="drawer"]').doesNotExist();
    assert.dom('[data-test-id="drawer"]').exists();
  });

  test('it executes onOpen when drawer is opened', async function (assert) {
    assert.expect(1);

    const isOpen = cell(true);
    const onOpen = () => {
      assert.ok(true);
    };

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @onOpen={{onOpen}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Drawer>
      </template>
    );
  });
});
