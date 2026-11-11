import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find } from '@ember/test-helpers';
import { Button, Input } from 'frontile';
import { useRealStyles } from '../../helpers/scoped-styles';

// The workbench renders interaction states without interaction. `tw.css`
// extends Tailwind's `hover`, `active`, `focus` and `focus-within` variants so
// `data-force-hover`, `data-force-active` and `data-focus-visible-added`
// trigger them. Each test compares against a probe that uses the target token
// directly, so the assertions follow the theme rather than literal colors.

function style(selector: string): CSSStyleDeclaration {
  const el = find(selector);
  if (!el) {
    throw new Error(`No element matches ${selector}`);
  }
  return window.getComputedStyle(el);
}

module('Integration | Workbench | frozen states', function (hooks) {
  setupRenderingTest(hooks);

  // Compares computed styles, so render against the shipped classes.
  useRealStyles(hooks, ['button', 'input']);

  test('forced hover renders the hover fill', async function (assert) {
    await render(
      <template>
        <Button @color="primary" data-test-plain>Plain</Button>
        <Button @color="primary" data-test-forced data-force-hover>
          Hover
        </Button>
        <div class="bg-primary-mild" data-test-probe></div>
      </template>
    );

    const forced = style('[data-test-forced]').backgroundColor;
    assert.strictEqual(
      forced,
      style('[data-test-probe]').backgroundColor,
      'forced hover matches bg-primary-mild'
    );
    assert.notStrictEqual(
      forced,
      style('[data-test-plain]').backgroundColor,
      'forced hover differs from the resting fill'
    );
  });

  test('forced active renders the pressed fill', async function (assert) {
    await render(
      <template>
        <Button @color="primary" data-test-plain>Plain</Button>
        <Button @color="primary" data-test-forced data-force-active>
          Active
        </Button>
        <div class="bg-primary-firm" data-test-probe></div>
      </template>
    );

    const forced = style('[data-test-forced]').backgroundColor;
    assert.strictEqual(
      forced,
      style('[data-test-probe]').backgroundColor,
      'forced active matches bg-primary-firm'
    );
    assert.notStrictEqual(
      forced,
      style('[data-test-plain]').backgroundColor,
      'forced active differs from the resting fill'
    );
  });

  test('forced focus renders the focus ring', async function (assert) {
    await render(
      <template>
        <Button @color="primary" data-test-plain>Plain</Button>
        <Button @color="primary" data-test-forced data-focus-visible-added>
          Focus
        </Button>
      </template>
    );

    const forced = style('[data-test-forced]').boxShadow;
    assert.notStrictEqual(forced, 'none', 'forced focus draws a ring');
    assert.notStrictEqual(
      forced,
      style('[data-test-plain]').boxShadow,
      'forced focus differs from an unforced button'
    );
  });

  test('forced focus on an Input', async function (assert) {
    await render(
      <template>
        <Input @label="Plain" data-test-plain />
        <Input @label="Focus" data-test-forced data-focus-visible-added />
      </template>
    );

    const forced = style('input[data-test-forced]');
    const plain = style('input[data-test-plain]');
    assert.true(
      forced.boxShadow !== plain.boxShadow ||
        forced.borderColor !== plain.borderColor,
      `forced focus changes the control (box-shadow ${forced.boxShadow} vs ${plain.boxShadow}; border ${forced.borderColor} vs ${plain.borderColor})`
    );
  });
});
