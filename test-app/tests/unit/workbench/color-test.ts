import { module, test } from 'qunit';
import {
  compositeOver,
  contrastRatio,
  parseColor,
  toHex
} from 'test-app/utils/workbench/color';

const BLACK = { r: 0, g: 0, b: 0, a: 1 };
const WHITE = { r: 255, g: 255, b: 255, a: 1 };

module('Unit | workbench | color', function () {
  test('contrastRatio follows WCAG 2.x', function (assert) {
    assert.strictEqual(contrastRatio(BLACK, WHITE), 21, 'black on white');
    assert.strictEqual(contrastRatio(WHITE, BLACK), 21, 'order-independent');
    assert.strictEqual(contrastRatio(WHITE, WHITE), 1, 'white on white');

    const grey = { r: 0x76, g: 0x76, b: 0x76, a: 1 };
    assert.strictEqual(
      Math.round(contrastRatio(grey, WHITE) * 100) / 100,
      4.54,
      '#767676 on white'
    );
  });

  test('compositeOver blends alpha onto an opaque background', function (assert) {
    const out = compositeOver({ r: 0, g: 0, b: 0, a: 0.5 }, WHITE);

    assert.strictEqual(out.a, 1, 'result is opaque');
    for (const channel of [out.r, out.g, out.b]) {
      assert.ok(
        channel === 127 || channel === 128,
        `channel is half-way (got ${channel})`
      );
    }
    assert.deepEqual(compositeOver(WHITE, BLACK), WHITE, 'opaque fg wins');
  });

  test('parseColor normalizes computed color syntaxes', function (assert) {
    assert.deepEqual(parseColor('oklch(0% 0 0)'), BLACK, 'oklch black');
    assert.deepEqual(parseColor('#ff0000'), { r: 255, g: 0, b: 0, a: 1 });

    const half = parseColor('rgb(255 0 0 / 0.5)');
    assert.ok(Math.abs(half.a - 0.5) < 0.01, `alpha ~0.5 (got ${half.a})`);
    assert.strictEqual(half.r, 255, 'channel is un-premultiplied');

    const srgb = parseColor('color(srgb 0 0 1)');
    assert.deepEqual(srgb, { r: 0, g: 0, b: 255, a: 1 }, 'color(srgb …)');
  });

  test('toHex prints 6 digits when opaque and 8 when not', function (assert) {
    assert.strictEqual(toHex({ r: 255, g: 0, b: 0, a: 1 }), '#ff0000');
    assert.strictEqual(toHex({ r: 255, g: 0, b: 0, a: 0.5 }), '#ff000080');
  });
});
