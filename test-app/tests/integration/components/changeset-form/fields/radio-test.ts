import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { Changeset } from 'ember-changeset';
import { run } from '@ember/runloop';

module(
  'Integration | Component | @frontile/changeset-form/ChangesetForm::Fields::Radio',
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(async function beforeEach(this: {
      set: (key: string, val: unknown) => void;
    }) {
      const model = {
        color: 'blue'
      };
      this.set('changeset', Changeset(model));

      await render(hbs`
        <ChangesetForm::Fields::Radio
          @changeset={{this.changeset}}
          @fieldName="color"
          @value="blue"
          name="color"
          data-test-radio-blue
        />
        <ChangesetForm::Fields::Radio
          @changeset={{this.changeset}}
          @fieldName="color"
          @value="green"
          name="color"
          data-test-radio-green
        />
        <ChangesetForm::Fields::Radio
          @changeset={{this.changeset}}
          @fieldName="color"
          @value="red"
          name="color"
          data-test-radio-red
        />
    `);
    });

    test('it renders with initial model value', async function (assert) {
      assert.dom('[data-test-radio-blue]').isChecked();
      assert.dom('[data-test-radio-green]').isNotChecked();
      assert.dom('[data-test-radio-red]').isNotChecked();
    });

    test('it updates the changeset on input', async function (assert) {
      await click('[data-test-radio-green]');
      await click('[data-test-radio-red]');

      assert.equal(this.changeset.get('color'), 'red');
    });

    test('it receives original input values on rollback', async function (assert) {
      await click('[data-test-radio-green]');

      assert.dom('[data-test-radio-blue]').isNotChecked();
      assert.dom('[data-test-radio-red]').isNotChecked();

      run(() => {
        this.changeset.rollback();
      });
      assert.dom('[data-test-radio-blue]').isChecked();
    });
  }
);
