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
import { Modal } from 'frontile/overlays';
import { cell } from 'ember-resources';
import {
  captureFrontileWarnings,
  observeWarningsBelowCapture
} from 'test-app/tests/helpers/frontile-warnings';
import { warn } from '@ember/debug';

module('Integration | Component | @frontile/overlays/modal', function (hooks) {
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
    modal: tv({
      slots: {
        base: '',
        closeButton: 'modal__close-btn',
        header: 'modal__header',
        body: 'modal__body',
        footer: 'modal__footer'
      },
      variants: {
        size: {
          xs: 'modal--xs',
          sm: 'modal--sm',
          md: 'modal--md',
          lg: 'modal--lg',
          xl: 'modal--xl',
          full: 'modal--full'
        },
        isCentered: {
          true: 'modal--centered'
        }
      }
    }) as never
  });

  test('it renders, header, body, footer, and close-btn', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Modal>
      </template>
    );

    assert.dom('[data-test-id="modal"]').exists();
    assert.dom('[data-test-id="modal"] .modal__header').hasText('My Header');
    assert.dom('[data-test-id="modal"] .modal__body').hasText('My Content');
    assert.dom('[data-test-id="modal"] .modal__footer').hasText('My Footer');
    assert.dom('[data-test-id="modal"] .modal__close-btn').hasText('Close');
  });

  test('it renders accessibility attributes', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Modal>
      </template>
    );

    assert.dom('[data-test-id="modal"]').hasAttribute('tabindex', '0');
    assert.dom('[data-test-id="modal"]').hasAttribute('role', 'dialog');
    assert.dom('[data-test-id="modal"]').hasAttribute('aria-labelledby');

    const ariaLablledBy =
      find('[data-test-id="modal"]')?.getAttribute('aria-labelledby') || '';
    assert
      .dom('[data-test-id="modal"] .modal__header')
      .hasAttribute('id', ariaLablledBy);
  });

  test('it adds modifier class if @isCentered is set to true', async function (assert) {
    const isOpen = cell(true);
    const isCentered = cell(true);

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @isCentered={{isCentered.current}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Modal>
      </template>
    );

    assert.dom('[data-test-id="modal"]').hasClass('modal--centered');
  });

  test('it adds modifier class for size', async function (assert) {
    const isOpen = cell(true);
    const size = cell<string | undefined>(undefined);

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @size={{size.current}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Modal>
      </template>
    );
    assert.dom('[data-test-id="modal"]').hasClass('modal--lg');

    size.current = 'xs';
    await settled();
    assert.dom('[data-test-id="modal"]').hasClass('modal--xs');

    size.current = 'sm';
    await settled();
    assert.dom('[data-test-id="modal"]').hasClass('modal--sm');

    size.current = 'md';
    await settled();
    assert.dom('[data-test-id="modal"]').hasClass('modal--md');

    size.current = 'lg';
    await settled();
    assert.dom('[data-test-id="modal"]').hasClass('modal--lg');

    size.current = 'xl';
    await settled();
    assert.dom('[data-test-id="modal"]').hasClass('modal--xl');

    size.current = 'full';
    await settled();
    assert.dom('[data-test-id="modal"]').hasClass('modal--full');
  });

  test('it closes modal when close button is clicked', async function (assert) {
    assert.expect(3);

    const isOpen = cell(true);
    const onClose = () => {
      assert.ok(true);
      isOpen.current = false;
    };

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Modal>
      </template>
    );

    assert.dom('[data-test-id="modal"]').exists();

    await click('[data-test-id="modal"] .modal__close-btn');
    assert.dom('[data-test-id="modal"]').doesNotExist();
  });

  test('it does not render close button when @allowCloseButton=false', async function (assert) {
    const isOpen = cell(true);
    const allowCloseButton = cell(false);
    const onClose = () => {
      isOpen.current = false;
    };

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @allowCloseButton={{allowCloseButton.current}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Modal>
      </template>
    );

    assert.dom('[data-test-id="modal"]').exists();
    assert.dom('[data-test-id="modal"] .modal__close-btn').doesNotExist();
  });

  test('it closes modal when backdrop is clicked', async function (assert) {
    assert.expect(3);

    const isOpen = cell(true);
    const onClose = () => {
      assert.ok(true);
      isOpen.current = false;
    };

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Modal>
      </template>
    );

    assert.dom('[data-test-id="modal"]').exists();
    await click('.overlay__backdrop');
    assert.dom('[data-test-id="modal"]').doesNotExist();
  });

  test('when @closeOnOutsideClick={{false}} does not close modal', async function (assert) {
    assert.expect(1);

    const isOpen = cell(true);
    const closeOnOutsideClick = cell(false);
    const onClose = () => {
      assert.ok(false, 'should not have been called');
      isOpen.current = false;
    };

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @closeOnOutsideClick={{closeOnOutsideClick.current}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Modal>
      </template>
    );
    await click('.overlay__backdrop');
    assert.dom('[data-test-id="modal"]').exists();
  });

  test('it closes modal when pressing Escape', async function (assert) {
    assert.expect(2);

    const isOpen = cell(true);
    const onClose = () => {
      assert.ok(true);
      isOpen.current = false;
    };

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Modal>
      </template>
    );
    await triggerKeyEvent('.overlay__content', 'keydown', 'Escape');
    assert.dom('[data-test-id="modal"]').doesNotExist();
  });

  test('when @closeOnEscapeKey={{false}} does not close modal', async function (assert) {
    assert.expect(1);

    const isOpen = cell(true);
    const closeOnEscapeKey = cell(false);
    const onClose = () => {
      assert.ok(false, 'should not have been called');
      isOpen.current = false;
    };

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @closeOnEscapeKey={{closeOnEscapeKey.current}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Modal>
      </template>
    );
    await triggerKeyEvent(document as never, 'keydown', 'Escape');
    assert.dom('[data-test-id="modal"]').exists();
  });

  test('when @allowClosing={{false}} does not close modal', async function (assert) {
    assert.expect(4);

    const isOpen = cell(true);
    const allowClosing = cell(false);
    const onClose = () => {
      assert.ok(false, 'should not have been called');
      isOpen.current = false;
    };

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @onClose={{onClose}}
          @allowClosing={{allowClosing.current}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Modal>
      </template>
    );

    assert.dom('[data-test-id="modal"]').exists();
    assert.dom('[data-test-id="modal"] .modal__close-btn').doesNotExist();

    await click('.overlay__backdrop');
    assert.dom('[data-test-id="modal"]').exists();

    await triggerKeyEvent(document as never, 'keydown', 'Escape');
    assert.dom('[data-test-id="modal"]').exists();
  });

  test('when @renderInPlace={{true}} renders in place', async function (assert) {
    const isOpen = cell(true);
    const renderInPlace = cell(true);

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @renderInPlace={{renderInPlace.current}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Modal>
      </template>
    );
    assert.dom('[data-portal-target] > [data-test-id="modal"]').doesNotExist();
    assert.dom('[data-test-id="modal"]').exists();
  });

  test('it executes onOpen when modal is opened', async function (assert) {
    assert.expect(1);

    const isOpen = cell(true);
    const onOpen = () => {
      assert.ok(true);
    };

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @onOpen={{onOpen}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
          <m.Footer>My Footer</m.Footer>
        </Modal>
      </template>
    );
  });

  test('it renders aria-modal when the focus trap is active', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
        </Modal>
      </template>
    );

    assert.dom('[data-test-id="modal"]').hasAttribute('aria-modal', 'true');
  });

  test('it does not render aria-modal when @disableFocusTrap={{true}}', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @disableFocusTrap={{true}}
          @disableTransitions={{true}}
          data-test-id="modal"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
        </Modal>
      </template>
    );

    assert.dom('[data-test-id="modal"]').doesNotHaveAttribute('aria-modal');
  });

  test('it does not render aria-labelledby when no header is rendered, and warns', async function (assert) {
    const isOpen = cell(true);

    const warnings = await captureFrontileWarnings(async () => {
      await render(
        <template>
          <Modal
            @isOpen={{isOpen.current}}
            @disableTransitions={{true}}
            data-test-id="modal"
            as |m|
          >
            <m.Body>My Content</m.Body>
          </Modal>
        </template>
      );
    });

    assert
      .dom('[data-test-id="modal"]')
      .doesNotHaveAttribute(
        'aria-labelledby',
        'no dangling reference when there is no header'
      );
    assert.deepEqual(
      warnings,
      ['frontile.modal.missing-accessible-name'],
      'the missing accessible name is warned about in development'
    );
  });

  test('it does not warn when a header supplies the accessible name', async function (assert) {
    const isOpen = cell(true);

    const warnings = await captureFrontileWarnings(async () => {
      await render(
        <template>
          <Modal
            @isOpen={{isOpen.current}}
            @disableTransitions={{true}}
            data-test-id="modal"
            as |m|
          >
            <m.Header>My Header</m.Header>
            <m.Body>My Content</m.Body>
          </Modal>
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
          <Modal
            @isOpen={{isOpen.current}}
            @disableTransitions={{true}}
            data-test-id="modal"
            as |m|
          >
            <h2 id={{m.headerId}}>My Own Heading</h2>
            <m.Body>My Content</m.Body>
          </Modal>
        </template>
      );
    });

    assert
      .dom('[data-test-id="modal"]')
      .doesNotHaveAttribute(
        'aria-labelledby',
        'the dialog does not point at a heading it never registered'
      );
    assert.deepEqual(
      warnings,
      ['frontile.modal.missing-accessible-name'],
      'a heading carrying headerId is not a name until aria-labelledby points at it'
    );
  });

  test('it does not warn when a consumer supplies aria-label', async function (assert) {
    const isOpen = cell(true);

    const warnings = await captureFrontileWarnings(async () => {
      await render(
        <template>
          <Modal
            @isOpen={{isOpen.current}}
            @disableTransitions={{true}}
            data-test-id="modal"
            aria-label="My Dialog"
            as |m|
          >
            <m.Body>My Content</m.Body>
          </Modal>
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
        <Modal
          @isOpen={{isOpen.current}}
          @disableTransitions={{true}}
          data-test-id="modal"
          aria-label="My Dialog"
          as |m|
        >
          {{#if showHeader.current}}
            <m.Header>My Header</m.Header>
          {{/if}}
          <m.Body>My Content</m.Body>
        </Modal>
      </template>
    );

    assert
      .dom('[data-test-id="modal"]')
      .doesNotHaveAttribute('aria-labelledby');

    showHeader.current = true;
    await settled();

    const labelledBy =
      find('[data-test-id="modal"]')?.getAttribute('aria-labelledby') || '';
    assert.ok(labelledBy, 'aria-labelledby is applied once a header exists');
    assert
      .dom('[data-test-id="modal"] .modal__header')
      .hasAttribute('id', labelledBy);

    showHeader.current = false;
    await settled();
    assert
      .dom('[data-test-id="modal"]')
      .doesNotHaveAttribute(
        'aria-labelledby',
        'the reference is dropped again when the header is removed'
      );
  });

  test('a consumer supplied aria-label is preserved when there is no header', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <Modal
          @isOpen={{isOpen.current}}
          @disableTransitions={{true}}
          data-test-id="modal"
          aria-label="My Dialog"
          as |m|
        >
          <m.Body>My Content</m.Body>
        </Modal>
      </template>
    );

    assert
      .dom('[data-test-id="modal"]')
      .hasAttribute('aria-label', 'My Dialog');
    assert
      .dom('[data-test-id="modal"]')
      .doesNotHaveAttribute('aria-labelledby');
  });

  test('a consumer supplied aria-labelledby wins over the header id', async function (assert) {
    const isOpen = cell(true);

    await render(
      <template>
        <span id="my-own-label">My Own Label</span>
        <Modal
          @isOpen={{isOpen.current}}
          @disableTransitions={{true}}
          data-test-id="modal"
          aria-labelledby="my-own-label"
          as |m|
        >
          <m.Header>My Header</m.Header>
          <m.Body>My Content</m.Body>
        </Modal>
      </template>
    );

    assert
      .dom('[data-test-id="modal"]')
      .hasAttribute('aria-labelledby', 'my-own-label');
  });

  test('it does not warn when a consumer supplies aria-labelledby and there is no header', async function (assert) {
    const isOpen = cell(true);

    const warnings = await captureFrontileWarnings(async () => {
      await render(
        <template>
          <span id="my-own-label">My Own Label</span>
          <Modal
            @isOpen={{isOpen.current}}
            @disableTransitions={{true}}
            data-test-id="modal"
            aria-labelledby="my-own-label"
            as |m|
          >
            <m.Body>My Content</m.Body>
          </Modal>
        </template>
      );
    });

    assert
      .dom('[data-test-id="modal"]')
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
        id: 'frontile.modal.missing-accessible-name'
      });
    });

    assert.deepEqual(
      inside,
      ['frontile.modal.missing-accessible-name'],
      'the open window captures the warning'
    );

    const escaped = await observeWarningsBelowCapture(async () => {
      warn('after the window closed', false, {
        id: 'frontile.modal.missing-accessible-name'
      });
    });

    assert.deepEqual(
      escaped,
      ['frontile.modal.missing-accessible-name'],
      'a frontile.* warning raised after restore still reaches the handler below'
    );
  });
});
