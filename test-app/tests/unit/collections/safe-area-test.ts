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

    // The convex hull of the six candidate points drops exactly one of them
    // here (the content's near-top corner, which sits inside the hull of the
    // other five), leaving five vertices rather than the hand-picked four.
    assert.strictEqual(polygon.length, 5, 'five vertices');
    assert.deepEqual(
      polygon[0],
      { x: 100, y: 0 },
      'starts at the trigger top-right'
    );
    assert.deepEqual(
      polygon[polygon.length - 1],
      { x: 100, y: 20 },
      'ends at the trigger bottom-right'
    );
    assert.deepEqual(
      polygon[3],
      { x: 120, y: 240 },
      'keeps the content near-bottom corner, which the old hand-picked ' +
        'quad dropped even though it is a real hull vertex'
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
    assert.true(
      isPointInSafeArea({ x: 200, y: 30 }, trigger, contentRight),
      'in the gap band above the content, heading for the submenu'
    );
    assert.true(
      isPointInSafeArea({ x: 120, y: 28 }, trigger, contentRight),
      'on a straight diagonal from the trigger toward the submenu'
    );
  });

  test('a mid-gap point stays safe when the content is much taller than the trigger', function (assert) {
    const shortTrigger: Rect = { left: 0, right: 50, top: 100, bottom: 120 };
    const tallContent: Rect = { left: 60, right: 200, top: 100, bottom: 400 };

    assert.true(
      isPointInSafeArea({ x: 55, y: 250 }, shortTrigger, tallContent),
      'in the gap, roughly level with the middle of a tall submenu'
    );
  });

  // Near-vertical descent is deliberately unsafe, and this pins it.
  //
  // At x = 110 the hull's lower boundary is the edge from the trigger's
  // bottom-right corner (100, 20) to the content's near-bottom corner
  // (120, 240) — both genuine, non-redundant hull vertices — which sits at
  // y = 130. So (110, 150) is outside the safe area.
  //
  // That is the right answer, not a shortfall of the hull. Reaching it means
  // descending 130px while travelling only 10px toward the submenu: the
  // pointer is heading down the parent menu onto a sibling row, not across
  // the gap. Widening the area to admit it would break the sibling-row
  // behaviour the safe area exists to preserve — hovering a sibling must
  // close the submenu. Only a concave shape could cover it, which is what
  // this module deliberately does not build.
  test('a near-vertical descent through the gap is not safe', function (assert) {
    assert.false(
      isPointInSafeArea({ x: 110, y: 150 }, trigger, contentRight),
      'descending onto a sibling row rather than crossing to the submenu'
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

    // The hull's starting vertex is whichever candidate point is leftmost
    // overall, which for the flipped fixture is the content's far-top
    // corner rather than the trigger — so this asserts by content instead
    // of assuming index 0 is always the trigger corner.
    assert.strictEqual(polygon.length, 5, 'five vertices when flipped too');
    assert.deepEqual(
      polygon[1],
      { x: 0, y: 0 },
      'includes the trigger top-left corner when flipped'
    );
    assert.deepEqual(
      polygon[2],
      { x: 0, y: 20 },
      'includes the trigger bottom-left corner when flipped'
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
