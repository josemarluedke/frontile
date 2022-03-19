import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, click, triggerKeyEvent } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | modal', function (hooks) {
  setupRenderingTest(hooks);

  const template = hbs`
    <div id="my-destination"></div>
    <Modal
      @isOpen={{this.isOpen}}
      @onClose={{this.onClose}}
      @onOpen={{this.onOpen}}
      @isCentered={{this.isCentered}}
      @allowClosing={{this.allowClosing}}
      @renderInPlace={{this.renderInPlace}}
      @destinationElementId="my-destination"
      @disableTransitions={{true}}
      @closeOnOutsideClick={{this.closeOnOutsideClick}}
      @closeOnEscapeKey={{this.closeOnEscapeKey}}
      @size={{this.size}}
      @allowCloseButton={{this.allowCloseButton}}
      data-test-id="modal"
      as |m|
    >
      <m.Header>My Header</m.Header>
      <m.Body>My Content</m.Body>
      <m.Footer>My Footer</m.Footer>
    </Modal>
  `;

  test('it renders, header, body, footer, and close-btn', async function (assert) {
    this.set('isOpen', true);
    await render(template);

    assert.dom('[data-test-id="modal"]').exists();
    assert.dom('[data-test-id="modal"] .modal__header').hasText('My Header');
    assert.dom('[data-test-id="modal"] .modal__body').hasText('My Content');
    assert.dom('[data-test-id="modal"] .modal__footer').hasText('My Footer');
    assert.dom('[data-test-id="modal"] .modal__close-btn').hasText('Close');
  });

  test('it renders accessibility attributes', async function (assert) {
    this.set('isOpen', true);
    await render(template);

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
    this.set('isOpen', true);
    this.set('isCentered', true);
    await render(template);

    assert.dom('[data-test-id="modal"]').hasClass('modal--centered');
  });

  test('it adds modifier class for size', async function (assert) {
    this.set('isOpen', true);

    await render(template);
    assert.dom('[data-test-id="modal"]').hasClass('modal--lg');

    this.set('size', 'xs');
    assert.dom('[data-test-id="modal"]').hasClass('modal--xs');

    this.set('size', 'sm');
    assert.dom('[data-test-id="modal"]').hasClass('modal--sm');

    this.set('size', 'md');
    assert.dom('[data-test-id="modal"]').hasClass('modal--md');

    this.set('size', 'lg');
    assert.dom('[data-test-id="modal"]').hasClass('modal--lg');

    this.set('size', 'xl');
    assert.dom('[data-test-id="modal"]').hasClass('modal--xl');

    this.set('size', 'full');
    assert.dom('[data-test-id="modal"]').hasClass('modal--full');
  });

  test('it closes modal when close button is clicked', async function (assert) {
    assert.expect(3);

    this.set('disableTransitions', true);
    this.set('isOpen', true);

    this.set('onClose', () => {
      assert.ok(true);
      this.set('isOpen', false);
    });

    await render(template);

    assert.dom('[data-test-id="modal"]').exists();
    await click('[data-test-id="modal"] .modal__close-btn');
    assert.dom('[data-test-id="modal"]').doesNotExist();
  });

  test('it does not render close button when @allowCloseButton=false', async function (assert) {
    this.set('disableTransitions', true);
    this.set('isOpen', true);
    this.set('allowCloseButton', false);

    this.set('onClose', () => {
      this.set('isOpen', false);
    });

    await render(template);

    assert.dom('[data-test-id="modal"]').exists();
    assert.dom('[data-test-id="modal"] .modal__close-btn').doesNotExist();
  });

  test('it closes modal when backdrop is clicked', async function (assert) {
    assert.expect(3);

    this.set('disableTransitions', true);
    this.set('isOpen', true);

    this.set('onClose', () => {
      assert.ok(true);
      this.set('isOpen', false);
    });

    await render(template);

    assert.dom('[data-test-id="modal"]').exists();
    await click('.overlay__backdrop');
    assert.dom('[data-test-id="modal"]').doesNotExist();
  });

  test('when @closeOnOutsideClick={{false}} does not close modal', async function (assert) {
    assert.expect(1);

    this.set('closeOnOutsideClick', false);
    this.set('isOpen', true);

    this.set('onClose', () => {
      assert.ok(false, 'should not have been called');
      this.set('isOpen', false);
    });

    await render(template);
    await click('.overlay__backdrop');
    assert.dom('[data-test-id="modal"]').exists();
  });

  test('it closes modal when pressing Escape', async function (assert) {
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
    assert.dom('[data-test-id="modal"]').doesNotExist();
  });

  test('when @closeOnEscapeKey={{false}} does not close modal', async function (assert) {
    assert.expect(1);

    this.set('closeOnEscapeKey', false);
    this.set('isOpen', true);

    this.set('onClose', () => {
      assert.ok(false, 'should not have been called');
      this.set('isOpen', false);
    });

    await render(template);
    await triggerKeyEvent(document as never, 'keydown', 'Escape');
    assert.dom('[data-test-id="modal"]').exists();
  });

  test('when @allowClosing={{false}} does not close modal', async function (assert) {
    assert.expect(4);

    this.set('allowClosing', false);
    this.set('isOpen', true);

    this.set('onClose', () => {
      assert.ok(false, 'should not have been called');
      this.set('isOpen', false);
    });

    await render(template);

    assert.dom('[data-test-id="modal"]').exists();
    assert.dom('[data-test-id="modal"] .modal__close-btn').doesNotExist();

    await click('.overlay__backdrop');
    assert.dom('[data-test-id="modal"]').exists();

    await triggerKeyEvent(document as never, 'keydown', 'Escape');
    assert.dom('[data-test-id="modal"]').exists();
  });

  test('when @renderInPlace={{true}} renders in place', async function (assert) {
    this.set('renderInPlace', true);
    this.set('isOpen', true);

    await render(template);
    assert.dom('.my-destination > [data-test-id="modal"]').doesNotExist();
    // @ts-ignore
    assert.dom('[data-test-id="modal"]', this.element).exists();
  });

  test('it executes onOpen when modal is opened', async function (assert) {
    assert.expect(1);
    this.set('isOpen', true);
    this.set('onOpen', () => {
      assert.ok(true);
    });
    await render(template);
  });
});
