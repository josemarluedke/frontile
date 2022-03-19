import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | Collapsible', function (hooks) {
  setupRenderingTest(hooks);

  test('renders content and starts closed', async function (assert) {
    this.set('isOpen', false);
    await render(
      hbs`<Collapsible
            @isOpen={{this.isOpen}}
            data-test-id="collapsible"
          >
            Content
          </Collapsible>`
    );

    assert.dom('[data-test-id=collapsible]').hasText('Content');
    assert.dom('[data-test-id=collapsible]').hasStyle({ height: '0px' });
    assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '0' });
    assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'hidden' });
  });

  test('renders content and starts open', async function (assert) {
    this.set('isOpen', true);
    await render(
      hbs`<Collapsible
            @isOpen={{this.isOpen}}
            data-test-id="collapsible"
          >
            Content
          </Collapsible>`
    );

    assert.dom('[data-test-id=collapsible]').hasText('Content');
    assert
      .dom('[data-test-id=collapsible]')
      .doesNotHaveStyle({ height: '0px' });
    assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
    assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'visible' });
  });

  test('expands content when opened; closes content when closed', async function (assert) {
    this.set('isOpen', false);
    await render(
      hbs`<Collapsible
            @isOpen={{this.isOpen}}
            data-test-id="collapsible"
          >
            Content
          </Collapsible>`
    );

    this.set('isOpen', true);
    await settled();

    assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
    assert.dom('[data-test-id=collapsible]').hasText('Content');
    assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'visible' });
    assert
      .dom('[data-test-id=collapsible]')
      .doesNotHaveStyle({ height: '0px' });

    this.set('isOpen', false);
    await settled();

    assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '0' });
    assert.dom('[data-test-id=collapsible]').hasStyle({ height: '0px' });
    assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'hidden' });
  });

  test('renders initial height when set', async function (assert) {
    this.set('isOpen', false);
    await render(
      hbs`<Collapsible
            @isOpen={{this.isOpen}}
            @initialHeight="2px"
            data-test-id="collapsible"
          >
            Content
          </Collapsible>`
    );

    assert.dom('[data-test-id=collapsible]').hasText('Content');
    assert.dom('[data-test-id=collapsible]').hasStyle({ height: '2px' });
    assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
    assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'hidden' });

    this.set('isOpen', true);
    await settled();

    assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
    assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'visible' });
    assert.dom('[data-test-id=collapsible]').hasText('Content');
    assert
      .dom('[data-test-id=collapsible]')
      .doesNotHaveStyle({ height: '2px' });

    this.set('isOpen', false);
    await settled();

    assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
    assert.dom('[data-test-id=collapsible]').hasStyle({ height: '2px' });
    assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'hidden' });
  });
});
