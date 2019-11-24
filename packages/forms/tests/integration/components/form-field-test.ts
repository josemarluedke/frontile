import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | FormField', function(hooks) {
  setupRenderingTest(hooks);
  const template = hbs`
                 <FormField
                   @hasMargin={{this.hasMargin}}
                   @isSmall={{this.isSmall}}
                   data-test-id="form-field"
                   as |f|
                 >
                  <div class="id">{{f.id}}</div>
                  <div class="hintId">{{f.hintId}}</div>
                  <div class="feedbackId">{{f.feedbackId}}</div>

                  <f.Label>My Label</f.Label>
                  <f.Hint>My Hint</f.Hint>
                  <f.Feedback>My Feedback</f.Feedback>
                </FormField>`;

  test('it generates unique id for the component and yield ids', async function(assert) {
    await render(template);

    assert.dom('[data-test-id="form-field"] .id').matchesText(/ember[1-9.]/);
    assert.dom('[data-test-id="form-field"] .hintId').matchesText(/(.)-hint/);
    assert
      .dom('[data-test-id="form-field"] .feedbackId')
      .matchesText(/(.)-feedback/);
  });

  test('it yields Label, Hint and Feedback components with pre-defined ids', async function(assert) {
    await render(template);

    const id =
      find('[data-test-id="form-field"] .id')!.textContent || 'id-not-found';

    assert
      .dom('[data-test-id="form-field-label"]')
      .hasTextContaining('My Label');
    assert.dom('[data-test-id="form-field-label"]').hasAttribute('for', id);

    assert.dom('[data-test-id="field-hint"]').hasTextContaining('My Hint');
    assert.dom('[data-test-id="field-hint"]').hasAttribute('id', `${id}-hint`);

    assert
      .dom('[data-test-id="field-feedback"]')
      .hasTextContaining('My Feedback');
    assert
      .dom('[data-test-id="field-feedback"]')
      .hasAttribute('id', `${id}-feedback`);
  });

  test('it adds style classes for hasMargin & isSmall', async function(assert) {
    await render(template);

    assert.dom('[data-test-id="form-field"]').hasNoClass('has-margin');
    assert.dom('[data-test-id="form-field"]').hasNoClass('is-small');

    this.set('hasMargin', true);
    assert.dom('[data-test-id="form-field"]').hasClass('has-margin');

    this.set('isSmall', true);
    assert.dom('[data-test-id="form-field"]').hasClass('is-small');
  });
});
