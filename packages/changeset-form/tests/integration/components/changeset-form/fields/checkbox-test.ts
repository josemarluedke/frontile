import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import Changeset from 'ember-changeset';
import { run } from '@ember/runloop';

module('Integration | Component | ChangesetForm::Fields::Checkbox', function(
  hooks
) {
  setupRenderingTest(hooks);

  hooks.beforeEach(async function beforeEach(this: { set: Function }) {
    const model = {
      blue: true,
      green: false,
      red: false
    };
    this.set('changeset', new Changeset(model));

    await render(hbs`
        <ChangesetForm::Fields::Checkbox
          @changeset={{this.changeset}}
          @fieldName="blue"
          @label="blue"
          data-test-checkbox-blue
        />
        <ChangesetForm::Fields::Checkbox
          @changeset={{this.changeset}}
          @fieldName="green"
          @label="green"
          data-test-checkbox-green
        />
        <ChangesetForm::Fields::Checkbox
          @changeset={{this.changeset}}
          @fieldName="red"
          @label="red"
          data-test-checkbox-red
        />
    `);
  });

  test('it renders with initial model value', async function(assert) {
    assert.dom('[data-test-checkbox-blue]').isChecked();
    assert.dom('[data-test-checkbox-green]').isNotChecked();
    assert.dom('[data-test-checkbox-red]').isNotChecked();
  });

  test('it updates the changeset on input', async function(assert) {
    await click('[data-test-checkbox-blue]');
    await click('[data-test-checkbox-green]');
    await click('[data-test-checkbox-red]');

    assert.equal(this.get('changeset').get('blue'), false);
    assert.equal(this.get('changeset').get('green'), true);
    assert.equal(this.get('changeset').get('red'), true);
  });

  test('it receives original input values on rollback', async function(assert) {
    await click('[data-test-checkbox-green]');

    assert.dom('[data-test-checkbox-blue]').isChecked();
    assert.dom('[data-test-checkbox-red]').isNotChecked();

    run(() => {
      this.get('changeset').rollback();
    });
    assert.dom('[data-test-checkbox-blue]').isChecked();
    assert.dom('[data-test-checkbox-green]').isNotChecked();
    assert.dom('[data-test-checkbox-red]').isNotChecked();
  });
});
