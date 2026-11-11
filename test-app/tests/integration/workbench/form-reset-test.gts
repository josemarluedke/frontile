import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, fillIn, click, find } from '@ember/test-helpers';
import { Form } from 'frontile';

function noop(): void {}

function value(): string {
  return (find('input[name="name"]') as HTMLInputElement).value;
}

// Why the Form controls page's Live form clears by remounting the Form rather
// than with a reset button. By design, a successful submit makes the submitted
// data Form's reset baseline (`initialDataSnapshot` in form.gts, documented
// under "Resetting Forms" in form.md), so reset reverts unsaved edits rather
// than emptying the form. Before any submit, a form with no `@data` clears.
// If this starts failing, Form's reset semantics changed: update form.md and
// the Live form card with it.
module('Integration | Workbench | form reset', function (hooks) {
  setupRenderingTest(hooks);

  test('without @data, reset clears before a submit but restores the submitted values after one', async function (assert) {
    await render(
      <template>
        <Form @onSubmit={{noop}} as |form|>
          <form.Field @name="name" as |field|>
            <field.Input @label="Name" />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
          <button type="reset" data-test-reset>Reset</button>
        </Form>
      </template>
    );

    await fillIn('input[name="name"]', 'Before');
    await click('[data-test-reset]');
    assert.strictEqual(value(), '', 'reset before any submit clears');

    await fillIn('input[name="name"]', 'Submitted');
    await click('[data-test-submit]');
    await fillIn('input[name="name"]', 'Edited');
    await click('[data-test-reset]');
    assert.strictEqual(
      value(),
      'Submitted',
      'reset after a submit restores the submitted value, not empty'
    );
  });
});
