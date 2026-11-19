import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';

// `size-icon-<step>` sizes an icon to the same pixel size as the Button label
// at that step, so an icon beside text at a step lines up. The reference is the
// shipped `text-strong-*` utility: an independent route to the same token.
// Classes are written out in full so Tailwind generates each one for the test
// build.
const STEPS = [
  ['4xs', 'size-icon-4xs', 'text-strong-4xs'],
  ['3xs', 'size-icon-3xs', 'text-strong-3xs'],
  ['2xs', 'size-icon-2xs', 'text-strong-2xs'],
  ['xs', 'size-icon-xs', 'text-strong-xs'],
  ['sm', 'size-icon-sm', 'text-strong-sm'],
  ['md', 'size-icon-md', 'text-strong-md'],
  ['lg', 'size-icon-lg', 'text-strong-lg'],
  ['xl', 'size-icon-xl', 'text-strong-xl'],
  ['2xl', 'size-icon-2xl', 'text-strong-2xl'],
  ['3xl', 'size-icon-3xl', 'text-strong-3xl']
] as const;

module('Integration | Theme | icon sizes', function (hooks) {
  setupRenderingTest(hooks);

  for (const [step, iconClass, textClass] of STEPS) {
    test(`size-icon-${step} is as large as text-strong-${step}`, async function (assert) {
      await render(
        <template>
          <span class={{textClass}} data-test-text>Aa</span>
          <span class="inline-block {{iconClass}}" data-test-icon></span>
        </template>
      );

      const text = getComputedStyle(
        document.querySelector('[data-test-text]') as HTMLElement
      ).fontSize;
      const icon = getComputedStyle(
        document.querySelector('[data-test-icon]') as HTMLElement
      );

      // Layout snaps lengths to 1/64px (17.0625 for a 17.072px font), so
      // compare within a hair rather than for string equality.
      const expected = parseFloat(text);
      assert.true(
        Math.abs(parseFloat(icon.width) - expected) < 0.02,
        `width ${icon.width} is ${text}`
      );
      assert.true(
        Math.abs(parseFloat(icon.height) - expected) < 0.02,
        `height ${icon.height} is ${text}`
      );
    });
  }

  test('the ten steps get progressively larger, so the comparison is not vacuous', async function (assert) {
    await render(
      <template>
        {{#each STEPS as |step|}}
          <span
            class="inline-block {{step.[1]}}"
            data-test-step={{step.[0]}}
          ></span>
        {{/each}}
      </template>
    );

    const px = STEPS.map(([step]) =>
      parseFloat(
        getComputedStyle(
          document.querySelector(`[data-test-step="${step}"]`) as HTMLElement
        ).width
      )
    );

    px.slice(1).forEach((value, index) => {
      assert.true(
        value > (px[index] as number),
        `${STEPS[index + 1]?.[0]} (${value}px) is larger than ${STEPS[index]?.[0]} (${px[index]}px)`
      );
    });
  });
});
