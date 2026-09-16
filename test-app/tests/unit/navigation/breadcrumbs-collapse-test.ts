import { module, test } from 'qunit';
import {
  collapseBreadcrumbs,
  type BreadcrumbsItemData,
  type BreadcrumbsSlot
} from 'frontile/components/navigation/breadcrumbs/collapse';

/**
 * Renders a slot list as the string a user would read, so the expectations
 * below are legible at a glance: `'A … D'` rather than a nest of objects.
 * Mirrors the `shape()` helper in `pagination-range-test.ts`.
 */
function shape(slots: BreadcrumbsSlot<BreadcrumbsItemData>[]): string {
  return slots
    .map((slot) => (slot.type === 'ellipsis' ? '…' : String(slot.item.label)))
    .join(' ');
}

function items(...labels: string[]): BreadcrumbsItemData[] {
  return labels.map((label) => ({ label }));
}

module('Unit | navigation/breadcrumbs/collapse', function () {
  test('without maxItems every crumb renders', function (assert) {
    assert.strictEqual(
      shape(collapseBreadcrumbs(items('A', 'B', 'C', 'D', 'E'))),
      'A B C D E'
    );
  });

  test('a trail at or under maxItems is not collapsed', function (assert) {
    assert.strictEqual(
      shape(collapseBreadcrumbs(items('A', 'B', 'C'), { maxItems: 3 })),
      'A B C'
    );
    assert.strictEqual(
      shape(collapseBreadcrumbs(items('A', 'B'), { maxItems: 3 })),
      'A B'
    );
  });

  test('a trail over maxItems keeps the default one crumb at each end', function (assert) {
    assert.strictEqual(
      shape(
        collapseBreadcrumbs(items('A', 'B', 'C', 'D', 'E'), { maxItems: 3 })
      ),
      'A … E'
    );
  });

  test('itemsBeforeCollapse and itemsAfterCollapse move the split', function (assert) {
    assert.strictEqual(
      shape(
        collapseBreadcrumbs(items('A', 'B', 'C', 'D', 'E', 'F'), {
          maxItems: 4,
          itemsBeforeCollapse: 2,
          itemsAfterCollapse: 2
        })
      ),
      'A B … E F'
    );
  });

  test('a zero on either side is honoured', function (assert) {
    assert.strictEqual(
      shape(
        collapseBreadcrumbs(items('A', 'B', 'C', 'D'), {
          maxItems: 2,
          itemsBeforeCollapse: 0,
          itemsAfterCollapse: 1
        })
      ),
      '… D'
    );
    assert.strictEqual(
      shape(
        collapseBreadcrumbs(items('A', 'B', 'C', 'D'), {
          maxItems: 2,
          itemsBeforeCollapse: 1,
          itemsAfterCollapse: 0
        })
      ),
      'A …'
    );
  });

  test('negative before/after counts are clamped to zero', function (assert) {
    assert.strictEqual(
      shape(
        collapseBreadcrumbs(items('A', 'B', 'C', 'D'), {
          maxItems: 2,
          itemsBeforeCollapse: -3,
          itemsAfterCollapse: 1
        })
      ),
      '… D'
    );
  });

  test('a maxItems below the always-kept crumbs is clamped, not honoured', function (assert) {
    // before + after + 1 = 5, so maxItems 1 is unsatisfiable and clamps to 5.
    // With 6 crumbs that still collapses; with 5 it would not.
    assert.strictEqual(
      shape(
        collapseBreadcrumbs(items('A', 'B', 'C', 'D', 'E', 'F'), {
          maxItems: 1,
          itemsBeforeCollapse: 2,
          itemsAfterCollapse: 2
        })
      ),
      'A B … E F'
    );
    assert.strictEqual(
      shape(
        collapseBreadcrumbs(items('A', 'B', 'C', 'D', 'E'), {
          maxItems: 1,
          itemsBeforeCollapse: 2,
          itemsAfterCollapse: 2
        })
      ),
      'A B C D E',
      'clamped maxItems of 5 is not exceeded by 5 crumbs'
    );
  });

  test('the ellipsis carries the crumbs it stands in for', function (assert) {
    const slots = collapseBreadcrumbs(items('A', 'B', 'C', 'D', 'E'), {
      maxItems: 3
    });
    const ellipsis = slots.find((slot) => slot.type === 'ellipsis');

    assert.ok(ellipsis, 'an ellipsis slot exists');
    assert.deepEqual(
      ellipsis?.type === 'ellipsis'
        ? ellipsis.hiddenItems.map((item) => item.label)
        : [],
      ['B', 'C', 'D']
    );
  });

  test('an ellipsis never stands in for fewer than two crumbs', function (assert) {
    // L > M and M >= B + A + 1 together give L >= B + A + 2, so the degenerate
    // one-crumb ellipsis pagination has to special-case cannot arise here.
    for (let length = 1; length <= 12; length++) {
      for (let maxItems = 1; maxItems <= 12; maxItems++) {
        const labels = Array.from({ length }, (_, i) => `C${i}`);
        const slots = collapseBreadcrumbs(items(...labels), { maxItems });
        const ellipsis = slots.find((slot) => slot.type === 'ellipsis');

        if (ellipsis && ellipsis.type === 'ellipsis') {
          assert.ok(
            ellipsis.hiddenItems.length >= 2,
            `length=${length} maxItems=${maxItems} hid ${ellipsis.hiddenItems.length}`
          );
        }
      }
    }
  });

  test('kept crumbs carry their original index', function (assert) {
    const slots = collapseBreadcrumbs(items('A', 'B', 'C', 'D', 'E'), {
      maxItems: 3
    });
    const indices = slots
      .filter((slot) => slot.type === 'item')
      .map((slot) => (slot.type === 'item' ? slot.index : -1));

    assert.deepEqual(indices, [0, 4], 'the tail keeps index 4, not 1');
  });

  test('an empty trail produces no slots', function (assert) {
    assert.deepEqual(collapseBreadcrumbs([], { maxItems: 3 }), []);
  });
});
