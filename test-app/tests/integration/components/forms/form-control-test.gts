import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import { array } from '@ember/helper';
import { cell } from 'ember-resources';

import { FormControl } from 'frontile';

module(
  'Integration | Component | @frontile/forms/FormControl',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders the :description named block without @description', async function (assert) {
      await render(
        <template>
          <FormControl>
            <:description>My description block</:description>
          </FormControl>
        </template>
      );

      assert
        .dom('[data-component="form-description"]')
        .exists('the description region renders from the named block alone');
      assert
        .dom('[data-component="form-description"]')
        .hasText('My description block');
    });

    test('it renders the :label named block without @label', async function (assert) {
      await render(
        <template>
          <FormControl>
            <:label>My label block</:label>
          </FormControl>
        </template>
      );

      assert.dom('[data-component="label"]').exists();
      assert.dom('[data-component="label"]').hasText('My label block');
    });

    test('it renders both named blocks together', async function (assert) {
      await render(
        <template>
          <FormControl>
            <:label>The label</:label>
            <:description>The description</:description>
          </FormControl>
        </template>
      );

      assert.dom('[data-component="label"]').hasText('The label');
      assert
        .dom('[data-component="form-description"]')
        .hasText('The description');
    });

    test('it still renders the @label and @description arguments', async function (assert) {
      await render(
        <template>
          <FormControl @label="Arg label" @description="Arg description" />
        </template>
      );

      assert.dom('[data-component="label"]').hasText('Arg label');
      assert
        .dom('[data-component="form-description"]')
        .hasText('Arg description');
    });

    test('it renders neither region when no label or description is provided', async function (assert) {
      await render(<template><FormControl /></template>);

      assert.dom('[data-component="label"]').doesNotExist();
      assert.dom('[data-component="form-description"]').doesNotExist();
    });

    test('the error live region exists before the field becomes invalid', async function (assert) {
      const errors = cell<string[] | string | undefined>();

      await render(
        <template>
          <FormControl @label="Email" @errors={{errors.current}} as |c|>
            <input id={{c.id}} />
          </FormControl>
        </template>
      );

      // The live region has to be in the DOM *before* it gets content,
      // otherwise assistive technology is not observing it when the error
      // arrives and the message is never announced.
      assert
        .dom('[data-component="form-feedback-live-region"]')
        .exists('the live region is rendered while the field is still valid');
      assert
        .dom('[data-component="form-feedback-live-region"]')
        .hasAria('live', 'assertive');
      assert
        .dom('[data-component="form-feedback-live-region"]')
        .hasText('', 'the live region starts empty');
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('no visible feedback while the field is valid');

      errors.current = ['Email is required'];
      await settled();

      assert
        .dom('[data-component="form-feedback-live-region"]')
        .hasText(
          'Email is required',
          'the pre-existing live region is filled with the message'
        );
      assert
        .dom('[data-component="form-feedback"]')
        .hasText('Email is required', 'the visible feedback renders too');

      // The visible feedback must not also be a live region, or the message
      // would be announced twice.
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotHaveAttribute('aria-live');

      errors.current = undefined;
      await settled();

      assert
        .dom('[data-component="form-feedback-live-region"]')
        .hasText('', 'the live region empties again when the field is valid');
    });

    test('the live region joins multiple messages', async function (assert) {
      await render(
        <template>
          <FormControl
            @label="Email"
            @errors={{array "Email is required" "Email is invalid"}}
          />
        </template>
      );

      assert
        .dom('[data-component="form-feedback-live-region"]')
        .hasText('Email is required; Email is invalid');
    });

    test('the live region is still rendered with @preventErrorFeedback', async function (assert) {
      await render(
        <template>
          <FormControl
            @label="Email"
            @errors={{array "Email is required"}}
            @preventErrorFeedback={{true}}
          />
        </template>
      );

      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('the automatic visible feedback is suppressed');
      assert
        .dom('[data-component="form-feedback-live-region"]')
        .hasText(
          'Email is required',
          'the announcement is still made from the live region'
        );
    });

    /**
     * FormControl curries `announce=false` onto the yielded Feedback because its
     * own live region covers the `@errors` text. Custom block content is not in
     * that region, so the documented escape hatch is to pass `@announce={{true}}`
     * at the invocation site, which has to win over the curried value.
     */
    test('an invocation-site @announce overrides the curried announce=false', async function (assert) {
      await render(
        <template>
          <FormControl @label="Username" as |c|>
            <input id={{c.id}} />
            <c.Feedback @intent="success" @announce={{true}}>
              That username is available.
            </c.Feedback>
          </FormControl>
        </template>
      );

      assert
        .dom('[data-component="form-feedback"]')
        .hasAria(
          'live',
          'polite',
          'custom block content can opt back in to being announced'
        );
    });

    test('the yielded Feedback does not announce by default', async function (assert) {
      await render(
        <template>
          <FormControl @label="Username" as |c|>
            <input id={{c.id}} />
            <c.Feedback @intent="success">
              That username is available.
            </c.Feedback>
          </FormControl>
        </template>
      );

      assert
        .dom('[data-component="form-feedback"]')
        .doesNotHaveAttribute(
          'aria-live',
          'FormControl owns the announcement, so the yielded Feedback is silent'
        );
    });
  }
);
