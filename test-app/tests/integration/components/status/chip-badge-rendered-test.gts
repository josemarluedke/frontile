import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { Badge, Chip, Select } from 'frontile';
import { array } from '@ember/helper';

const SIZES = ['2xs', 'xs', 'sm', 'md', 'lg', 'xl', '2xl'] as const;

// Renders with the shipped theme and reads computed styles, since class-string
// tests can't show which utility wins in the compiled CSS.
module('Integration | Rendered | Chip and Badge sizes', function (hooks) {
  setupRenderingTest(hooks);

  for (const size of SIZES) {
    test(`${size}: Chip and Badge render regular weight, Badge value bold`, async function (assert) {
      await render(
        <template>
          <Chip @size={{size}} data-test-id="chip">x</Chip>
          <Badge @size={{size}} @value="4" data-test-id="badge">x</Badge>
        </template>
      );

      const weight = (selector: string) =>
        Number(getComputedStyle(document.querySelector(selector)!).fontWeight);

      assert.strictEqual(weight('[data-test-id="chip"]'), 400, 'chip');
      assert.strictEqual(weight('[data-test-id="badge"]'), 400, 'badge');
      assert.true(weight('[data-part="value"]') >= 700, 'badge value');
    });

    test(`${size}: Chip and Badge label size matches Badge's`, async function (assert) {
      await render(
        <template>
          <Chip @size={{size}} data-test-id="chip">x</Chip>
          <Badge @size={{size}} data-test-id="badge">x</Badge>
        </template>
      );
      const px = (selector: string) =>
        getComputedStyle(document.querySelector(selector)!).fontSize;
      assert.strictEqual(
        px('[data-test-id="chip"]'),
        px('[data-test-id="badge"]')
      );
    });

    test(`${size}: the Chip close button stays a circle inside the chip`, async function (assert) {
      const noop = () => {};
      await render(
        <template>
          <Chip @size={{size}} @onClose={{noop}} data-test-id="chip">x</Chip>
        </template>
      );
      const chip = document.querySelector('[data-test-id="chip"]')!;
      const button = chip.querySelector('button')!.getBoundingClientRect();
      const chipRect = chip.getBoundingClientRect();
      assert.ok(
        Math.abs(button.width - button.height) <= 1,
        `close button ${button.width}x${button.height} is round`
      );
      assert.ok(button.height <= chipRect.height, 'fits inside the chip');
    });
  }

  for (const inputSize of ['sm', 'md', 'lg'] as const) {
    test(`Select chips (${inputSize}) keep the field as tall as a single select`, async function (assert) {
      await render(
        <template>
          <div style="width: 320px">
            <Select
              @items={{array "apple" "banana"}}
              @selectionMode="multiple"
              @selectedKeys={{array "apple"}}
              @inputSize={{inputSize}}
            />
          </div>
          <div style="width: 320px">
            <Select
              @items={{array "apple" "banana"}}
              @selectedKeys={{array "apple"}}
              @inputSize={{inputSize}}
            />
          </div>
        </template>
      );
      const multi = document
        .querySelector('[data-test-id="chips-field"]')!
        .getBoundingClientRect().height;
      const single = document
        .querySelectorAll(
          '[data-component="select"] [data-part="input"]:not(select)'
        )[1]!
        .getBoundingClientRect().height;
      assert.ok(
        Math.abs(multi - single) <= 1,
        `chips field ${multi} vs single select ${single}`
      );
    });
  }
});
