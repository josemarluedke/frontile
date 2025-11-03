import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find } from '@ember/test-helpers';
import { FormField } from '@frontile/forms-legacy';

module(
  'Integration | Component | @frontile/forms-legacy/FormField',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it generates unique id for the component and yield ids', async function (assert) {
      await render(
        <template>
          <FormField data-test-id="form-field" as |f|>
            <div class="id">{{f.id}}</div>
            <div class="hintId">{{f.hintId}}</div>
            <div class="feedbackId">{{f.feedbackId}}</div>

            <f.Label>My Label</f.Label>
            <f.Hint>My Hint</f.Hint>
            <f.Feedback>My Feedback</f.Feedback>
          </FormField>
        </template>
      );

      assert.dom('[data-test-id="form-field"] .id').matchesText(/ember[1-9.]/);
      assert.dom('[data-test-id="form-field"] .hintId').matchesText(/(.)-hint/);
      assert
        .dom('[data-test-id="form-field"] .feedbackId')
        .matchesText(/(.)-feedback/);
    });

    test('it yields Label, Hint and Feedback components with pre-defined ids', async function (assert) {
      await render(
        <template>
          <FormField data-test-id="form-field" as |f|>
            <div class="id">{{f.id}}</div>
            <div class="hintId">{{f.hintId}}</div>
            <div class="feedbackId">{{f.feedbackId}}</div>

            <f.Label>My Label</f.Label>
            <f.Hint>My Hint</f.Hint>
            <f.Feedback>My Feedback</f.Feedback>
          </FormField>
        </template>
      );

      const id =
        find('[data-test-id="form-field"] .id')?.textContent || 'id-not-found';

      assert
        .dom('[data-test-id="form-field-label"]')
        .hasTextContaining('My Label');
      assert.dom('[data-test-id="form-field-label"]').hasAttribute('for', id);

      assert
        .dom('[data-test-id="form-field-hint"]')
        .hasTextContaining('My Hint');
      assert
        .dom('[data-test-id="form-field-hint"]')
        .hasAttribute('id', `${id}-hint`);

      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasTextContaining('My Feedback');
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasAttribute('id', `${id}-feedback`);
    });
  }
);
