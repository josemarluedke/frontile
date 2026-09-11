import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  findAll,
  click,
  triggerKeyEvent,
  settled
} from '@ember/test-helpers';
import { registerCustomStyles, useStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { Drawer } from 'frontile/overlays';
import { cell } from 'ember-resources';
import {
  captureFrontileWarnings,
  observeWarningsBelowCapture
} from 'test-app/tests/helpers/frontile-warnings';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';
import { warn } from '@ember/debug';

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
        headerCloseButton: 'drawer__header-close-btn',
        headerContent: 'drawer__header-content',
        headerActions: 'drawer__header-actions',
        header: 'drawer__header',
        body: 'drawer__body',
        footer: 'drawer__footer',
        icon: 'drawer__icon',
        title: 'drawer__title',
        description: 'drawer__description',
        dragHandle: 'drawer__drag-handle',
        dragHandleBar: 'drawer__drag-handle-bar'
      },
      variants: {
        appearance: {
          default: 'drawer--default',
          ghost: 'drawer--ghost'
        },
        hasCloseButton: {
          true: { header: 'drawer__header--has-close-btn' }
        },
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
    // The header now also contains the visually-hidden "Close" text of the
    // close button rendered inside it, so this checks for the title text
    // rather than an exact match.
    assert
      .dom('[data-test-id="drawer"] .drawer__header')
      .includesText('My Header');
    assert.dom('[data-test-id="drawer"] .drawer__body').hasText('My Content');
    assert.dom('[data-test-id="drawer"] .drawer__footer').hasText('My Footer');
    // A header is present, so the close button renders inside it (see
    // `DrawerHeader`'s `@closeButton`) rather than as the standalone,
    // absolutely-positioned button.
    assert
      .dom('[data-test-id="drawer"] .drawer__header-close-btn')
      .hasText('Close');
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

    // A header is present, so the close button renders inside it.
    await click('[data-test-id="drawer"] .drawer__header-close-btn');
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
    assert
      .dom('[data-test-id="drawer"] .drawer__header-close-btn')
      .doesNotExist();
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
    assert.expect(5);

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
    assert
      .dom('[data-test-id="drawer"] .drawer__header-close-btn')
      .doesNotExist();

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

  test('it renders aria-modal when the focus trap is active', async function (assert) {
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
        </Drawer>
      </template>
    );

    assert.dom('[data-test-id="drawer"]').hasAttribute('aria-modal', 'true');
  });

  test('it does not render aria-modal when @disableFocusTrap={{true}}', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @disableFocusTrap={{true}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
        </Drawer>
      </template>
    );

    assert.dom('[data-test-id="drawer"]').doesNotHaveAttribute('aria-modal');
  });

  test('it auto focuses when @disableFocusTrap={{true}}, unless @preventAutoFocus={{true}}', async function (assert) {
    const isOpen = cell(false);
    const preventAutoFocus = cell<boolean | undefined>(undefined);

    await render(
      <template>
        <button type="button" data-test-id="some-button">Button</button>
        <Drawer
          @isOpen={{isOpen.current}}
          @disableFocusTrap={{true}}
          @preventAutoFocus={{preventAutoFocus.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Body>My Content</m.Body>
        </Drawer>
      </template>
    );

    (find('[data-test-id="some-button"]') as HTMLButtonElement).focus();
    isOpen.current = true;
    await settled();
    assert
      .dom(document.activeElement)
      .hasAttribute(
        'data-component',
        'overlay',
        'auto focuses the drawer by default'
      );

    isOpen.current = false;
    await settled();

    preventAutoFocus.current = true;
    (find('[data-test-id="some-button"]') as HTMLButtonElement).focus();
    isOpen.current = true;
    await settled();
    assert
      .dom(document.activeElement)
      .hasAttribute(
        'data-test-id',
        'some-button',
        'does not steal focus when @preventAutoFocus={{true}}'
      );
  });

  test('it does not render aria-labelledby when no header is rendered, and warns', async function (assert) {
    const isOpen = cell(true);

    const warnings = await captureFrontileWarnings(async () => {
      await render(
        <template>
          <Drawer
            @isOpen={{isOpen.current}}
            @disableTransitions={{true}}
            data-test-id="drawer"
            as |m|
          >
            <m.Body>My Content</m.Body>
          </Drawer>
        </template>
      );
    });

    assert
      .dom('[data-test-id="drawer"]')
      .doesNotHaveAttribute(
        'aria-labelledby',
        'no dangling reference when there is no header'
      );
    assert.deepEqual(
      warnings,
      ['frontile.drawer.missing-accessible-name'],
      'the missing accessible name is warned about in development'
    );
  });

  test('it does not warn when a header supplies the accessible name', async function (assert) {
    const isOpen = cell(true);

    const warnings = await captureFrontileWarnings(async () => {
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
          </Drawer>
        </template>
      );
    });

    assert.deepEqual(warnings, [], 'a header is an accessible name');
  });

  test('it warns when the yielded headerId is on your own heading but nothing points at it', async function (assert) {
    const isOpen = cell(true);

    const warnings = await captureFrontileWarnings(async () => {
      await render(
        <template>
          <Drawer
            @isOpen={{isOpen.current}}
            @disableTransitions={{true}}
            data-test-id="drawer"
            as |m|
          >
            <h2 id={{m.headerId}}>My Own Heading</h2>
            <m.Body>My Content</m.Body>
          </Drawer>
        </template>
      );
    });

    assert
      .dom('[data-test-id="drawer"]')
      .doesNotHaveAttribute(
        'aria-labelledby',
        'the dialog does not point at a heading it never registered'
      );
    assert.deepEqual(
      warnings,
      ['frontile.drawer.missing-accessible-name'],
      'a heading carrying headerId is not a name until aria-labelledby points at it'
    );
  });

  test('it does not warn when a consumer supplies aria-label', async function (assert) {
    const isOpen = cell(true);

    const warnings = await captureFrontileWarnings(async () => {
      await render(
        <template>
          <Drawer
            @isOpen={{isOpen.current}}
            @disableTransitions={{true}}
            data-test-id="drawer"
            aria-label="My Dialog"
            as |m|
          >
            <m.Body>My Content</m.Body>
          </Drawer>
        </template>
      );
    });

    assert.deepEqual(warnings, [], 'aria-label is an accessible name');
  });

  test('it renders aria-labelledby pointing at the header when a header is rendered later', async function (assert) {
    const isOpen = cell(true);
    const showHeader = cell(false);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          aria-label="My Dialog"
          as |m|
        >
          {{#if showHeader.current}}
            <m.Header>My Header</m.Header>
          {{/if}}
          <m.Body>My Content</m.Body>
        </Drawer>
      </template>
    );

    assert
      .dom('[data-test-id="drawer"]')
      .doesNotHaveAttribute('aria-labelledby');

    showHeader.current = true;
    await settled();

    const labelledBy =
      find('[data-test-id="drawer"]')?.getAttribute('aria-labelledby') || '';
    assert.ok(labelledBy, 'aria-labelledby is applied once a header exists');
    assert
      .dom('[data-test-id="drawer"] .drawer__header')
      .hasAttribute('id', labelledBy);

    showHeader.current = false;
    await settled();
    assert
      .dom('[data-test-id="drawer"]')
      .doesNotHaveAttribute(
        'aria-labelledby',
        'the reference is dropped again when the header is removed'
      );
  });

  test('a consumer supplied aria-label is preserved when there is no header', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          aria-label="My Dialog"
          as |m|
        >
          <m.Body>My Content</m.Body>
        </Drawer>
      </template>
    );

    assert
      .dom('[data-test-id="drawer"]')
      .hasAttribute('aria-label', 'My Dialog');
    assert
      .dom('[data-test-id="drawer"]')
      .doesNotHaveAttribute('aria-labelledby');
  });

  test('a consumer supplied aria-labelledby wins over the header id', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <span id="my-own-label">My Own Label</span>
        <Drawer
          @isOpen={{isOpen.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          aria-labelledby="my-own-label"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
        </Drawer>
      </template>
    );

    assert
      .dom('[data-test-id="drawer"]')
      .hasAttribute('aria-labelledby', 'my-own-label');
  });

  test('it does not warn when a consumer supplies aria-labelledby and there is no header', async function (assert) {
    const isOpen = cell(true);

    const warnings = await captureFrontileWarnings(async () => {
      await render(
        <template>
          <span id="my-own-label">My Own Label</span>
          <Drawer
            @isOpen={{isOpen.current}}
            @disableTransitions={{true}}
            data-test-id="drawer"
            aria-labelledby="my-own-label"
            as |d|
          >
            <d.Body>My Content</d.Body>
          </Drawer>
        </template>
      );
    });

    assert
      .dom('[data-test-id="drawer"]')
      .hasAttribute(
        'aria-labelledby',
        'my-own-label',
        'the consumer reference survives with no header to compete with'
      );
    assert.deepEqual(
      warnings,
      [],
      'a consumer supplied aria-labelledby is an accessible name'
    );
  });

  test('the warning capture window does not outlive the test that opened it', async function (assert) {
    const inside = await captureFrontileWarnings(async () => {
      warn('inside the window', false, {
        id: 'frontile.drawer.missing-accessible-name'
      });
    });

    assert.deepEqual(
      inside,
      ['frontile.drawer.missing-accessible-name'],
      'the open window captures the warning'
    );

    const escaped = await observeWarningsBelowCapture(async () => {
      warn('after the window closed', false, {
        id: 'frontile.drawer.missing-accessible-name'
      });
    });

    assert.deepEqual(
      escaped,
      ['frontile.drawer.missing-accessible-name'],
      'a frontile.* warning raised after restore still reaches the handler below'
    );
  });

  test('it applies appearance classes', async function (assert) {
    const isOpen = cell(true);
    const appearance = cell<string | undefined>(undefined);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @appearance={{appearance.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
        </Drawer>
      </template>
    );

    assert
      .dom('[data-test-id="drawer"]')
      .hasClass('drawer--default', 'defaults to the default appearance');

    appearance.current = 'ghost';
    await settled();

    assert.dom('[data-test-id="drawer"]').hasClass('drawer--ghost');
    assert.dom('[data-test-id="drawer"]').doesNotHaveClass('drawer--default');
  });

  test('the header reserves the close-button lane only when it has one', async function (assert) {
    const isOpen = cell(true);
    const allowCloseButton = cell<boolean | undefined>(undefined);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @allowCloseButton={{allowCloseButton.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
        </Drawer>
      </template>
    );

    assert
      .dom('[data-test-id="drawer"] .drawer__header')
      .hasClass(
        'drawer__header--has-close-btn',
        'reserves the lane while a close button is rendered'
      );

    allowCloseButton.current = false;
    await settled();

    assert
      .dom('[data-test-id="drawer"] .drawer__header')
      .doesNotHaveClass(
        'drawer__header--has-close-btn',
        'drops the reservation when there is no close button to reserve for'
      );
  });

  test('it renders the drag handle per placement and @allowDragToClose', async function (assert) {
    const isOpen = cell(true);
    const placement = cell<string | undefined>(undefined);
    const allowDragToClose = cell<boolean | undefined>(undefined);
    const allowClosing = cell<boolean | undefined>(undefined);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @placement={{placement.current}}
          @allowDragToClose={{allowDragToClose.current}}
          @allowClosing={{allowClosing.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
        </Drawer>
      </template>
    );

    assert
      .dom('[data-drawer-drag-handle]')
      .doesNotExist('right placement is off by default');

    placement.current = 'bottom';
    await settled();
    assert.dom('[data-drawer-drag-handle]').exists('bottom is on by default');

    placement.current = 'top';
    await settled();
    assert.dom('[data-drawer-drag-handle]').exists('top is on by default');

    allowDragToClose.current = false;
    await settled();
    assert.dom('[data-drawer-drag-handle]').doesNotExist('explicit false wins');

    placement.current = 'left';
    allowDragToClose.current = true;
    await settled();
    assert
      .dom('[data-drawer-drag-handle]')
      .exists('explicit true opts a side drawer in');

    allowDragToClose.current = undefined;
    allowClosing.current = false;
    placement.current = 'bottom';
    await settled();
    assert
      .dom('[data-drawer-drag-handle]')
      .doesNotExist('allowClosing=false forces the handle off');
  });

  test('pressing the drag handle closes the drawer', async function (assert) {
    const isOpen = cell(true);
    let closed = 0;
    const onClose = () => {
      closed += 1;
    };

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @placement="bottom"
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
        </Drawer>
      </template>
    );

    await click('[data-drawer-drag-handle]');
    assert.strictEqual(closed, 1, 'onClose fired');
  });

  test('it passes header args through the yielded Header', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header @title="Drawer title" @description="Supporting text" />
          <m.Body>My Content</m.Body>
        </Drawer>
      </template>
    );

    assert
      .dom('[data-test-id="drawer"] .drawer__title')
      .hasText('Drawer title');
    assert
      .dom('[data-test-id="drawer"] .drawer__description')
      .hasText('Supporting text');
  });

  test('it renders exactly one close button when a header is present', async function (assert) {
    // Guards against the double-render risk of rendering the close button
    // inside the header (for centring) while also conditionally rendering
    // the standalone, absolutely-positioned one based on the same `hasHeader`
    // flag the header's own registration modifier sets.
    const isOpen = cell(true);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @disableTransitions={{true}}
          data-test-id="drawer"
          as |m|
        >
          <m.Header @title="Drawer title" />
          <m.Body>My Content</m.Body>
        </Drawer>
      </template>
    );

    const closeButtons = findAll('[data-test-id="drawer"] button').filter(
      (button) => button.textContent?.trim() === 'Close'
    );
    assert.strictEqual(
      closeButtons.length,
      1,
      'exactly one close button renders'
    );
    assert
      .dom('[data-test-id="drawer"] .drawer__close-btn')
      .doesNotExist('the standalone close button does not also render');
    assert
      .dom('[data-test-id="drawer"] .drawer__header-close-btn')
      .exists({ count: 1 }, 'the header-embedded close button renders');
  });

  test('the real theme keeps the drawer flush with its inset, without a phantom cross-axis scroll', async function (assert) {
    // Regression test: the `base` slot used to carry `w-full h-full`
    // unconditionally. On the cross axis (e.g. `left-2`/`right-2` for a
    // `bottom` placement) the element is already stretched between two
    // insets, and `w-full`/`h-full` then override that stretch with 100% of
    // the containing block -- 16px wider/taller than the box the insets
    // describe -- silently consuming the intended 8px outside margin as an
    // 8px auto-scroll instead of leaving it visible.
    //
    // This has to be checked against the *real*, shipped theme, not this
    // file's own `registerCustomStyles` mock above (needed by the
    // class-name assertions elsewhere in this file), which replaces
    // `drawer`/`overlay` with plain test markers that carry none of the real
    // utilities (`top-2`, `w-full`, `fixed`, `overflow-auto`, ...) and so
    // could not exercise this bug either way. `realStyles` is captured in
    // `tests/helpers/real-theme-styles.ts` before any test file's
    // module-level `registerCustomStyles` call can replace it (see that
    // file), so it stays the genuine shipped theme regardless of which test
    // file happens to load first.
    const previousDrawerStyles = useStyles().drawer;
    const previousOverlayStyles = useStyles().overlay;
    registerCustomStyles({
      drawer: realStyles.drawer,
      overlay: realStyles.overlay
    });

    try {
      const isOpen = cell(true);

      await render(
        <template>
          <Drawer
            @isOpen={{isOpen.current}}
            @placement="bottom"
            @size="md"
            @disableTransitions={{true}}
            data-test-id="drawer"
            as |m|
          >
            <m.Body>My Content</m.Body>
          </Drawer>
        </template>
      );

      const bottomDrawer = find('[data-test-id="drawer"]') as HTMLElement;
      assert.ok(bottomDrawer, 'the bottom-placement drawer renders');

      // The drawer itself (`role="dialog"`) is `position: absolute` and its
      // own content is small, so it never scrolls itself -- the bug instead
      // shows up on its containing block: `<Overlay>`'s outer
      // `[data-component="overlay"]` div, which is `fixed inset-0
      // overflow-auto`. The CSS scrollable-overflow area of an `overflow:
      // auto` container includes absolutely-positioned descendants whose
      // containing block it is, so when the drawer's cross-axis size
      // ignores its insets (the bug) and renders wider/taller than that
      // container, the container itself gains a real, measurable scrollbar.
      const bottomOverlay = bottomDrawer.closest(
        '[data-component="overlay"]'
      ) as HTMLElement;
      assert.ok(bottomOverlay, 'the drawer has an overlay container');

      assert.true(
        bottomOverlay.scrollWidth <= bottomOverlay.clientWidth,
        `bottom placement: no phantom horizontal scroll on the overlay container (scrollWidth=${bottomOverlay.scrollWidth}, clientWidth=${bottomOverlay.clientWidth})`
      );

      // `getBoundingClientRect()` is not usable here: `#ember-testing-container`
      // is rendered under a test-harness `zoom` style, which rescales the
      // *visual* pixels a rect reports without changing the resolved CSS
      // length values. `getComputedStyle()` reports those resolved values
      // directly, so it stays a reliable "8px" regardless of the harness's
      // zoom.
      const bottomStyle = getComputedStyle(bottomDrawer);
      assert.strictEqual(
        bottomStyle.left,
        '8px',
        'bottom placement: sits exactly 8px from the left edge it is inset from'
      );
      assert.strictEqual(
        bottomStyle.right,
        '8px',
        'bottom placement: sits exactly 8px from the right edge it is inset from'
      );

      const isOpenLeft = cell(true);

      await render(
        <template>
          <Drawer
            @isOpen={{isOpenLeft.current}}
            @placement="left"
            @size="md"
            @disableTransitions={{true}}
            data-test-id="drawer"
            as |m|
          >
            <m.Body>My Content</m.Body>
          </Drawer>
        </template>
      );

      const leftDrawer = find('[data-test-id="drawer"]') as HTMLElement;
      assert.ok(leftDrawer, 'the left-placement drawer renders');

      const leftOverlay = leftDrawer.closest(
        '[data-component="overlay"]'
      ) as HTMLElement;
      assert.ok(leftOverlay, 'the drawer has an overlay container');

      assert.true(
        leftOverlay.scrollHeight <= leftOverlay.clientHeight,
        `left placement: no phantom vertical scroll on the overlay container (scrollHeight=${leftOverlay.scrollHeight}, clientHeight=${leftOverlay.clientHeight})`
      );

      const leftStyle = getComputedStyle(leftDrawer);
      assert.strictEqual(
        leftStyle.top,
        '8px',
        'left placement: sits exactly 8px from the top edge it is inset from'
      );
      assert.strictEqual(
        leftStyle.bottom,
        '8px',
        'left placement: sits exactly 8px from the bottom edge it is inset from'
      );
    } finally {
      registerCustomStyles({
        drawer: previousDrawerStyles,
        overlay: previousOverlayStyles
      });
    }
  });

  test('renders data-component="drawer" on the root only, with data-part on every slot', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @placement="bottom"
          @disableTransitions={{true}}
          as |d|
        >
          <d.Header @description="My description">
            <:default as |h|>
              <h.Icon>I</h.Icon>
              <h.Title>My Header</h.Title>
              <h.Description />
            </:default>
            <:actions>
              <button type="button">Action</button>
            </:actions>
          </d.Header>
          <d.Body>My Content</d.Body>
          <d.Footer>My Footer</d.Footer>
        </Drawer>
      </template>
    );

    const root = document.querySelector('[data-component="drawer"]') as Element;
    assert.ok(root, 'the drawer root renders');
    assert.strictEqual(root.getAttribute('data-part'), 'base');

    // A header is present, so the close button renders inside it (as
    // header-close-button) rather than as the standalone base close-button
    // -- see the separate "no header" assertion below for that case.
    assert
      .dom('[data-component="drawer"] [data-part="header-close-button"]')
      .exists();
    assert.dom('[data-component="drawer"] [data-part="header"]').exists();
    assert
      .dom('[data-component="drawer"] [data-part="header-content"]')
      .exists();
    assert
      .dom('[data-component="drawer"] [data-part="header-actions"]')
      .exists();
    assert.dom('[data-component="drawer"] [data-part="icon"]').exists();
    assert.dom('[data-component="drawer"] [data-part="title"]').exists();
    assert.dom('[data-component="drawer"] [data-part="description"]').exists();
    assert.dom('[data-component="drawer"] [data-part="body"]').exists();
    assert.dom('[data-component="drawer"] [data-part="footer"]').exists();
    // `top`/`bottom` placements default @allowDragToClose to true.
    assert.dom('[data-component="drawer"] [data-part="drag-handle"]').exists();
    assert
      .dom('[data-component="drawer"] [data-part="drag-handle-bar"]')
      .exists();

    assert.strictEqual(
      document.querySelectorAll('[data-component="drawer"]').length,
      1,
      'data-component="drawer" marks the root only, never a part'
    );
  });

  test('renders data-part="close-button" on the standalone close button when there is no header', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <Drawer @isOpen={{isOpen.current}} @disableTransitions={{true}} as |d|>
          <d.Body>My Content</d.Body>
        </Drawer>
      </template>
    );

    assert.dom('[data-component="drawer"] [data-part="close-button"]').exists();
  });

  test('a consumer-rendered yielded d.CloseButton carries data-part="close-button" when the consumer adds it explicitly (the documented custom-close-button pattern)', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <Drawer
          @isOpen={{isOpen.current}}
          @disableTransitions={{true}}
          @allowCloseButton={{false}}
          as |d|
        >
          <d.Header>
            Custom Close Button
            <d.CloseButton data-part="close-button" />
          </d.Header>
          <d.Body>My Content</d.Body>
        </Drawer>
      </template>
    );

    // Same rationale as Modal's equivalent test: Drawer cannot inject
    // data-part into a consumer's own <d.CloseButton /> invocation, so the
    // consumer adds it themselves, same as drawer.md's "Custom Close
    // Button" demo now does -- and it does land, via CloseButton's own
    // ...attributes splat.
    assert.dom('[data-component="drawer"] [data-part="close-button"]').exists();
    assert.strictEqual(
      document.querySelectorAll(
        '[data-component="drawer"] [data-part="close-button"]'
      ).length,
      1,
      'exactly one close-button part renders (no duplicate from the default close button, since @allowCloseButton={{false}})'
    );
  });
});
