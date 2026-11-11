import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, fillIn, click, find } from '@ember/test-helpers';
import { Form } from 'frontile';

function noop(): void {}

function value(): string {
  return (find('input[name="name"]') as HTMLInputElement).value;
}

// Why the Form controls page's Live form clears by remounting the Form rather
// than with a reset button. `form.md` says a form with no `@data` "just
// clears the fields" on reset, but after a successful submit Form adopts the
// submitted data as its reset baseline (`initialDataSnapshot` in form.gts).
// If this starts failing, the library matches its docs again and the page
// can go back to a plain `type="reset"` button.
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
