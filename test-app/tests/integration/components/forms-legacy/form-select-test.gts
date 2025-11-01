import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, focus, blur } from '@ember/test-helpers';
import { selectChoose } from 'ember-power-select/test-support';
import { clickTrigger } from 'ember-power-select/test-support/helpers';
import { FormSelect } from '@frontile/forms-legacy';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/forms-legacy/FormSelect',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders the label', async function (assert) {
      const value = cell<string | undefined>(undefined);
      const setValue = (val: string) => {
        value.current = val;
      };
      await render(
        <template>
          <FormSelect
            @containerClass="my-container"
            @label="Select Countries"
            @hint="The countries where you have lived"
            @onChange={{setValue}}
            @triggerClass="test-select"
            @selected={{value.current}}
            @renderInPlace={{true}}
            as |option|
          >
            {{option}}
          </FormSelect>
        </template>
      );

      assert
        .dom('[data-test-id="form-field-label"]')
        .hasText('Select Countries');
    });

    test('show the select option', async function (assert) {
      const value = cell('Brazil');
      const options = cell(['Brazil', 'United States of America']);
      const setValue = (val: string) => {
        value.current = val;
      };
      await render(
        <template>
          <FormSelect
            @containerClass="my-container"
            @label="Select Countries"
            @hint="The countries where you have lived"
            @onChange={{setValue}}
            @triggerClass="test-select"
            @options={{options.current}}
            @selected={{value.current}}
            @renderInPlace={{true}}
            as |option|
          >
            {{option}}
          </FormSelect>
        </template>
      );

      assert.dom('.test-select').containsText('Brazil');
    });

    test('it renders the hint', async function (assert) {
      const value = cell<string | undefined>(undefined);
      const setValue = (val: string) => {
        value.current = val;
      };
      await render(
        <template>
          <FormSelect
            @containerClass="my-container"
            @label="Select Countries"
            @hint="The countries where you have lived"
            @onChange={{setValue}}
            @triggerClass="test-select"
            @selected={{value.current}}
            @renderInPlace={{true}}
            as |option|
          >
            {{option}}
          </FormSelect>
        </template>
      );

      assert
        .dom('[data-test-id="form-field-hint"]')
        .containsText('The countries where you have lived');
    });

    test('it calls onOpen & onClose', async function (assert) {
      const value = cell<string | undefined>(undefined);
      const setValue = (val: string) => {
        value.current = val;
      };
      assert.expect(2);

      const onOpen = () => {
        assert.ok(true, 'should have called onOpen');
      };

      const onClose = () => {
        assert.ok(true, 'should have called onClose');
      };
      await render(
        <template>
          <FormSelect
            @containerClass="my-container"
            @label="Select Countries"
            @hint="The countries where you have lived"
            @onChange={{setValue}}
            @triggerClass="test-select"
            @selected={{value.current}}
            @onOpen={{onOpen}}
            @onClose={{onClose}}
            @renderInPlace={{true}}
            as |option|
          >
            {{option}}
          </FormSelect>
        </template>
      );

      await clickTrigger('.my-container');
      await clickTrigger('.my-container');
    });

    test('it calls onFocusIn/onFocus & onFocusOut/onBlur', async function (assert) {
      assert.expect(4);
      const value = cell<string | undefined>(undefined);
      const setValue = (val: string) => {
        value.current = val;
      };

      const onFocusIn = () => {
        assert.ok(true, 'should have called onFocusIn');
      };

      const onFocus = () => {
        assert.ok(true, 'should have called onFocus');
      };

      const onFocusOut = () => {
        assert.ok(true, 'should have called onFocusOut');
      };

      const onBlur = () => {
        assert.ok(true, 'should have called onBlur');
      };

      await render(
        <template>
          <FormSelect
            @containerClass="my-container"
            @label="Select Countries"
            @hint="The countries where you have lived"
            @onChange={{setValue}}
            @triggerClass="test-select"
            @selected={{value.current}}
            @onFocusIn={{onFocusIn}}
            @onFocusOut={{onFocusOut}}
            @onFocus={{onFocus}}
            @onBlur={{onBlur}}
            @renderInPlace={{true}}
            as |option|
          >
            {{option}}
          </FormSelect>
        </template>
      );

      await focus('.test-select');
      await blur('.test-select');
    });

    test('mutates the value using onChange', async function (assert) {
      const value = cell<string | undefined>(undefined);
      const options = cell(['Brazil', 'China']);
      const setValue = (val: string) => {
        value.current = val;
      };
      await render(
        <template>
          <FormSelect
            @containerClass="my-container"
            @label="Select Countries"
            @hint="The countries where you have lived"
            @onChange={{setValue}}
            @triggerClass="test-select"
            @options={{options.current}}
            @selected={{value.current}}
            @renderInPlace={{true}}
            as |option|
          >
            {{option}}
          </FormSelect>
        </template>
      );

      await clickTrigger('.my-container');
      await selectChoose('.test-select', 'Brazil');

      assert.deepEqual(value.current, 'Brazil');
    });

    test('it handle multiple options', async function (assert) {
      const value = cell<string[]>([]);
      const options = cell(['Brazil', 'China', 'United States of America']);
      const isMultiple = cell(true);
      const setValue = (val: string[]) => {
        value.current = val;
      };

      await render(
        <template>
          <FormSelect
            @isMultiple={{isMultiple.current}}
            @containerClass="my-container"
            @label="Select Countries"
            @hint="The countries where you have lived"
            @onChange={{setValue}}
            @triggerClass="test-select"
            @options={{options.current}}
            @selected={{value.current}}
            @renderInPlace={{true}}
            as |option|
          >
            {{option}}
          </FormSelect>
        </template>
      );
      assert
        .dom('.my-container .ember-power-select-multiple-trigger')
        .exists('should have rendered the multiple power select');

      await clickTrigger('.my-container');
      await selectChoose('.my-container .ember-power-select-trigger', 'Brazil');

      await clickTrigger('.my-container');
      await selectChoose('.my-container .ember-power-select-trigger', 'China');
      assert.deepEqual(value.current, ['Brazil', 'China']);
    });

    test('shows error messages and adds aria-invalid on close', async function (assert) {
      const value = cell<string | undefined>(undefined);
      const errors = cell(['This field is required']);
      const setValue = (val: string) => {
        value.current = val;
      };
      await render(
        <template>
          <FormSelect
            @containerClass="my-container"
            @label="Select Countries"
            @hint="The countries where you have lived"
            @onChange={{setValue}}
            @errors={{errors.current}}
            @triggerClass="test-select"
            @selected={{value.current}}
            @renderInPlace={{true}}
            as |option|
          >
            {{option}}
          </FormSelect>
        </template>
      );

      assert.dom('.test-select').hasNoAttribute('aria-invalid');
      await focus('.test-select');
      await blur('.test-select');

      assert.dom('.test-select').hasAttribute('aria-invalid', 'true');
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasText('This field is required');
    });

    test('do not show errors if errors are empty', async function (assert) {
      const value = cell<string | undefined>(undefined);
      const errors = cell<string[]>([]);
      const setValue = (val: string) => {
        value.current = val;
      };
      await render(
        <template>
          <FormSelect
            @containerClass="my-container"
            @label="Select Countries"
            @hint="The countries where you have lived"
            @onChange={{setValue}}
            @errors={{errors.current}}
            @triggerClass="test-select"
            @selected={{value.current}}
            @renderInPlace={{true}}
            as |option|
          >
            {{option}}
          </FormSelect>
        </template>
      );

      assert.dom('.test-select').hasNoAttribute('aria-invalid');

      await focus('.test-select');
      await blur('.test-select');

      assert.dom('.test-select').hasNoAttribute('aria-invalid');
      assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
    });

    test('do not show errors if hasError is false even if errors has elements', async function (assert) {
      const value = cell<string | undefined>(undefined);
      const hasError = cell(false);
      const errors = cell(['Some error']);
      const setValue = (val: string) => {
        value.current = val;
      };
      await render(
        <template>
          <FormSelect
            @containerClass="my-container"
            @label="Select Countries"
            @hint="The countries where you have lived"
            @onChange={{setValue}}
            @hasError={{hasError.current}}
            @errors={{errors.current}}
            @triggerClass="test-select"
            @selected={{value.current}}
            @renderInPlace={{true}}
            as |option|
          >
            {{option}}
          </FormSelect>
        </template>
      );

      await focus('.test-select');
      await blur('.test-select');

      assert.dom('.test-select').hasNoAttribute('aria-invalid');
      assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
    });

    test('always show error messages when showError is true', async function (assert) {
      const value = cell<string | undefined>(undefined);
      const errors = cell(['This field is required']);
      const showError = cell(true);
      const setValue = (val: string) => {
        value.current = val;
      };
      await render(
        <template>
          <FormSelect
            @containerClass="my-container"
            @label="Select Countries"
            @hint="The countries where you have lived"
            @onChange={{setValue}}
            @showError={{showError.current}}
            @errors={{errors.current}}
            @triggerClass="test-select"
            @selected={{value.current}}
            @renderInPlace={{true}}
            as |option|
          >
            {{option}}
          </FormSelect>
        </template>
      );

      assert.dom('.test-select').hasAttribute('aria-invalid', 'true');
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasText('This field is required');
    });

    test('always show error messages when hasSubmitted is true', async function (assert) {
      const value = cell<string | undefined>(undefined);
      const errors = cell(['This field is required']);
      const hasSubmitted = cell(true);
      const setValue = (val: string) => {
        value.current = val;
      };
      await render(
        <template>
          <FormSelect
            @containerClass="my-container"
            @label="Select Countries"
            @hint="The countries where you have lived"
            @onChange={{setValue}}
            @errors={{errors.current}}
            @hasSubmitted={{hasSubmitted.current}}
            @triggerClass="test-select"
            @selected={{value.current}}
            @renderInPlace={{true}}
            as |option|
          >
            {{option}}
          </FormSelect>
        </template>
      );

      assert.dom('.test-select').hasAttribute('aria-invalid', 'true');
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasText('This field is required');
    });
  }
);
