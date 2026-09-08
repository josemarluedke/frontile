import { module, test } from 'qunit';
import {
  isPointInRect,
  buildSafeAreaPolygon,
  isPointInPolygon,
  isPointInSafeArea,
  type Rect
} from 'frontile/utils/safe-area';

// A trigger row at x 0..100, y 0..20, with its submenu opened to the right
// and running further down the page than the row itself.
const trigger: Rect = { left: 0, right: 100, top: 0, bottom: 20 };
const contentRight: Rect = { left: 120, right: 320, top: 40, bottom: 240 };
// The flipped case: the submenu opened to the left of the trigger.
const contentLeft: Rect = { left: -220, right: -20, top: 40, bottom: 240 };

module('Unit | Utils | safe-area', function () {
  test('isPointInRect covers inside, edges and outside', function (assert) {
    assert.true(isPointInRect({ x: 50, y: 10 }, trigger), 'inside');
    assert.true(isPointInRect({ x: 0, y: 0 }, trigger), 'top-left edge');
    assert.true(isPointInRect({ x: 100, y: 20 }, trigger), 'bottom-right edge');
    assert.false(isPointInRect({ x: 101, y: 10 }, trigger), 'past the right');
    assert.false(isPointInRect({ x: 50, y: 21 }, trigger), 'below');
  });

  test('isPointInPolygon uses ray casting on a simple square', function (assert) {
    const square: { x: number; y: number }[] = [
      { x: 0, y: 0 },
      { x: 10, y: 0 },
      { x: 10, y: 10 },
      { x: 0, y: 10 }
    ];

    assert.true(isPointInPolygon({ x: 5, y: 5 }, square), 'centre');
    assert.false(isPointInPolygon({ x: 15, y: 5 }, square), 'outside');
    assert.false(isPointInPolygon({ x: 5, y: -1 }, square), 'above');
  });

  test('the polygon bridges the trigger edge to the content when opened right', function (assert) {
    const polygon = buildSafeAreaPolygon(trigger, contentRight);

    assert.strictEqual(polygon.length, 6, 'six vertices');
    assert.deepEqual(
      polygon[0],
      { x: 100, y: 0 },
      'starts at the trigger top-right'
    );
    assert.deepEqual(
      polygon[5],
      { x: 100, y: 20 },
      'ends at the trigger bottom-right'
    );
  });

  test('a pointer travelling diagonally toward the submenu stays in the safe area', function (assert) {
    // Leaves the trigger's right edge and heads down-right toward the content.
    assert.true(
      isPointInSafeArea({ x: 110, y: 25 }, trigger, contentRight),
      'in the gap, aimed at the submenu'
    );
    assert.true(
      isPointInSafeArea({ x: 200, y: 100 }, trigger, contentRight),
      'inside the submenu itself'
    );
    assert.true(
      isPointInSafeArea({ x: 50, y: 10 }, trigger, contentRight),
      'still on the trigger'
    );
  });

  test('a pointer leaving toward a sibling row is outside the safe area', function (assert) {
    assert.false(
      isPointInSafeArea({ x: 50, y: 40 }, trigger, contentRight),
      'straight down onto a sibling row'
    );
    assert.false(
      isPointInSafeArea({ x: -30, y: 10 }, trigger, contentRight),
      'off to the left, away from the submenu'
    );
  });

  test('it mirrors when the submenu is flipped to the left', function (assert) {
    const polygon = buildSafeAreaPolygon(trigger, contentLeft);

    assert.deepEqual(
      polygon[0],
      { x: 0, y: 0 },
      'starts at the trigger top-left when flipped'
    );
    assert.true(
      isPointInSafeArea({ x: -10, y: 25 }, trigger, contentLeft),
      'in the gap on the left'
    );
    assert.false(
      isPointInSafeArea({ x: 110, y: 25 }, trigger, contentLeft),
      'the right-hand gap is not safe when flipped'
    );
  });

  test('a degenerate content rect does not throw and is simply unsafe', function (assert) {
    const empty: Rect = { left: 0, right: 0, top: 0, bottom: 0 };

    assert.false(
      isPointInSafeArea({ x: 500, y: 500 }, trigger, empty),
      'far away from a zero-sized submenu'
    );
  });
});
