import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find } from '@ember/test-helpers';
import {
  Checkbox,
  NativeSelect,
  Radio,
  Select,
  Switch,
  Textarea
} from 'frontile';
import { useRealStyles } from '../../helpers/scoped-styles';
import forceWithin from 'test-app/utils/workbench/force-within';

// The Form controls page forces focus with `data-focus-visible-added`. Where
// the attribute has to go differs per control: the `<input>` itself, an inner
// trigger, or a hidden input whose wrapper rings via `has-focus-visible`.
// Each test renders the control plain and forced, exactly as the page does,
// and checks the styled element actually draws a different ring.

const ITEMS = ['One', 'Two'];

function shadow(selector: string): string {
  const el = find(selector);
  if (!el) {
    throw new Error(`No element matches ${selector}`);
  }
  return window.getComputedStyle(el).boxShadow;
}

module('Integration | Workbench | form focus', function (hooks) {
  setupRenderingTest(hooks);

  // Compares computed rings, so render against the shipped classes.
  useRealStyles(hooks, [
    'textarea',
    'select',
    'nativeSelect',
    'checkbox',
    'radio',
    'switchInput'
  ]);

  test('Textarea: forced on the textarea', async function (assert) {
    await render(
      <template>
        <div data-test-plain><Textarea @label="Plain" /></div>
        <div data-test-forced>
          <Textarea @label="Focus" data-focus-visible-added />
        </div>
      </template>
    );
    const forced = shadow('[data-test-forced] textarea');
    assert.notStrictEqual(forced, 'none', 'draws a ring');
    assert.notStrictEqual(forced, shadow('[data-test-plain] textarea'));
  });

  test('NativeSelect: forced on the select', async function (assert) {
    await render(
      <template>
        <div data-test-plain><NativeSelect @items={{ITEMS}} /></div>
        <div data-test-forced>
          <NativeSelect @items={{ITEMS}} data-focus-visible-added />
        </div>
      </template>
    );
    const forced = shadow('[data-test-forced] select');
    assert.notStrictEqual(forced, 'none', 'draws a ring');
    assert.notStrictEqual(forced, shadow('[data-test-plain] select'));
  });

  test('Select: forced on the inner trigger, not the wrapper', async function (assert) {
    await render(
      <template>
        <div data-test-plain><Select @items={{ITEMS}} /></div>
        <div data-test-wrapper>
          <Select @items={{ITEMS}} data-focus-visible-added />
        </div>
        <div data-test-forced>
          <Select
            @items={{ITEMS}}
            {{forceWithin
              "data-focus-visible-added"
              '[data-part="chips-field"] > [data-part="input"]'
            }}
          />
        </div>
      </template>
    );
    const trigger = 'button[data-part="input"]';
    const plain = shadow(`[data-test-plain] ${trigger}`);
    assert.strictEqual(
      shadow(`[data-test-wrapper] ${trigger}`),
      plain,
      'the attribute on the wrapper (where ...attributes lands) shows nothing'
    );
    assert
      .dom(`[data-test-forced] ${trigger}`)
      .hasAttribute('data-focus-visible-added');
    const forced = shadow(`[data-test-forced] ${trigger}`);
    assert.notStrictEqual(forced, 'none', 'draws a ring');
    assert.notStrictEqual(forced, plain, 'differs from the plain trigger');
  });

  test('Checkbox and Radio: forced on the input', async function (assert) {
    await render(
      <template>
        <div data-test-plain>
          <Checkbox @label="Plain" />
          <Radio @value="a" @label="Plain" />
        </div>
        <div data-test-forced>
          <Checkbox @label="Focus" data-focus-visible-added />
          <Radio @value="a" @label="Focus" data-focus-visible-added />
        </div>
      </template>
    );
    for (const type of ['checkbox', 'radio']) {
      const sel = `input[type="${type}"]`;
      const forced = shadow(`[data-test-forced] ${sel}`);
      assert.notStrictEqual(forced, 'none', `${type} draws a ring`);
      assert.notStrictEqual(forced, shadow(`[data-test-plain] ${sel}`), type);
    }
  });

  // Why the page omits Switch's focus columns. If this starts failing, the
  // theme's ring colour follows the force attribute too, and the columns can
  // come back (`FORM_STATES_NO_READONLY_NO_FOCUS` in the page's states.ts).
  test('Switch: a forced ring is drawn, but not in the focus colour', async function (assert) {
    await render(
      <template>
        <div data-test-plain><Switch @label="Plain" /></div>
        <div data-test-forced>
          <Switch @label="Focus" data-focus-visible-added />
        </div>
        <span class="ring-focus ring-3" data-test-probe></span>
      </template>
    );
    const wrapper = '[data-part="wrapper"]';
    const forced = shadow(`[data-test-forced] ${wrapper}`);
    assert.notStrictEqual(forced, 'none', 'the wrapper draws a ring');
    assert.notStrictEqual(
      forced,
      shadow(`[data-test-plain] ${wrapper}`),
      'the forced ring differs from rest'
    );
    // The probe's shadow holds the `ring-focus` colour; the forced ring's
    // colour comes from `has-[:focus-visible]:`, which only real focus meets.
    // The probe's only visible layer is its 3px ring: take that colour.
    const focusColor = /(oklch\([^)]*\)|rgba?\([^)]*\)) 0px 0px 0px 3px/.exec(
      shadow('[data-test-probe]')
    )?.[1];
    assert.ok(focusColor, 'the probe has a ring colour');
    assert.false(
      forced.includes(focusColor!),
      `the forced ring is not ${focusColor}`
    );
  });
});
