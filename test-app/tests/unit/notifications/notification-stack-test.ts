import { module, test } from 'qunit';
import { NotificationStack } from 'frontile/notifications';
import type { NotificationStackInput } from 'frontile/notifications';

function build(overrides: Partial<NotificationStackInput> = {}) {
  return new NotificationStack({
    heights: [60, 80, 100],
    isExpanded: false,
    gap: 16,
    visibleToasts: 3,
    placement: 'bottom-right',
    ...overrides
  });
}

module('Unit | @frontile/notifications/NotificationStack', function () {
  test('collapsed: front card is unscaled and unmoved', function (assert) {
    const geometry = build().geometryFor(0);

    assert.strictEqual(geometry.transform, 'translateY(0px) scale(1)');
    assert.strictEqual(geometry.opacity, 1);
    assert.strictEqual(
      geometry.height,
      null,
      'front card sizes to its own content, not clamped to its own measurement'
    );
  });

  test('collapsed: cards behind peek by gap and scale down by 0.05 each', function (assert) {
    const stack = build();

    assert.strictEqual(
      stack.geometryFor(1).transform,
      'translateY(-16px) scale(0.95)'
    );
    assert.strictEqual(
      stack.geometryFor(2).transform,
      'translateY(-32px) scale(0.9)'
    );
  });

  test('collapsed: cards behind the front are clamped to the front card height, but the front card itself is not', function (assert) {
    const stack = build();

    assert.strictEqual(
      stack.geometryFor(0).height,
      null,
      'front card sizes to content'
    );
    assert.strictEqual(stack.geometryFor(1).height, 60);
    assert.strictEqual(stack.geometryFor(2).height, 60);
  });

  test('collapsed: cards past visibleToasts are transparent', function (assert) {
    const stack = build({ heights: [60, 80, 100, 40], visibleToasts: 3 });

    assert.strictEqual(stack.geometryFor(2).opacity, 1);
    assert.strictEqual(stack.geometryFor(3).opacity, 0);
  });

  test('collapsed: cards past visibleToasts are also excluded from the click path', function (assert) {
    const stack = build({ heights: [60, 80, 100, 40], visibleToasts: 3 });

    assert.strictEqual(
      stack.geometryFor(2).pointerEvents,
      'auto',
      'a visible card stays clickable'
    );
    assert.strictEqual(
      stack.geometryFor(3).pointerEvents,
      'none',
      'an invisible card cannot swallow clicks'
    );
  });

  test('expanded: every card is visible and clickable', function (assert) {
    const stack = build({
      heights: [60, 80, 100, 40],
      isExpanded: true,
      visibleToasts: 1
    });

    assert.strictEqual(stack.geometryFor(3).pointerEvents, 'auto');
  });

  test('expanded: cards offset by the summed heights of the cards in front', function (assert) {
    const stack = build({ isExpanded: true });

    assert.strictEqual(
      stack.geometryFor(0).transform,
      'translateY(0px) scale(1)'
    );
    assert.strictEqual(
      stack.geometryFor(1).transform,
      'translateY(-76px) scale(1)',
      '60 + 16 gap'
    );
    assert.strictEqual(
      stack.geometryFor(2).transform,
      'translateY(-172px) scale(1)',
      '60 + 16 + 80 + 16'
    );
  });

  test('expanded: heights are auto and every card is visible', function (assert) {
    const stack = build({ isExpanded: true, visibleToasts: 1 });

    assert.strictEqual(stack.geometryFor(2).height, null);
    assert.strictEqual(stack.geometryFor(2).opacity, 1);
  });

  test('top placements invert the direction and the transform origin', function (assert) {
    const stack = build({ placement: 'top-center' });

    assert.true(stack.isTopPlacement);
    assert.strictEqual(
      stack.geometryFor(1).transform,
      'translateY(16px) scale(0.95)'
    );
    assert.strictEqual(stack.geometryFor(1).transformOrigin, 'top center');
  });

  test('bottom placements anchor the transform origin to the bottom', function (assert) {
    const stack = build();

    assert.false(stack.isTopPlacement);
    assert.strictEqual(stack.geometryFor(0).transformOrigin, 'bottom center');
  });

  test('z-index descends from the front of the stack', function (assert) {
    const stack = build();

    assert.strictEqual(stack.geometryFor(0).zIndex, 3);
    assert.strictEqual(stack.geometryFor(2).zIndex, 1);
  });

  test('container height: collapsed shows the front card plus the peeks', function (assert) {
    assert.strictEqual(build().containerHeight, 60 + 2 * 16);
  });

  test('container height: collapsed peeks are capped at visibleToasts', function (assert) {
    const stack = build({ heights: [60, 80, 100, 40], visibleToasts: 2 });

    assert.strictEqual(stack.containerHeight, 60 + 1 * 16);
  });

  test('container height: expanded is the sum of heights plus gaps', function (assert) {
    const stack = build({ isExpanded: true });

    assert.strictEqual(stack.containerHeight, 60 + 80 + 100 + 2 * 16);
  });

  test('an empty stack has zero height', function (assert) {
    const stack = build({ heights: [] });

    assert.strictEqual(stack.containerHeight, 0);
  });

  test('a single card has no gaps in either state', function (assert) {
    assert.strictEqual(build({ heights: [60] }).containerHeight, 60);
    assert.strictEqual(
      build({ heights: [60], isExpanded: true }).containerHeight,
      60
    );
  });

  test('an unmeasured card does not produce NaN', function (assert) {
    const stack = build({ heights: [0, 0], isExpanded: true });

    assert.strictEqual(
      stack.geometryFor(1).transform,
      'translateY(-16px) scale(1)'
    );
    assert.strictEqual(stack.containerHeight, 16);
  });
});
