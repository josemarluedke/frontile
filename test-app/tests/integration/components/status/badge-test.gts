import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { Badge } from 'frontile';
import { badgeStubStyles } from '../../../helpers/badge-stub-styles';
import { realStyles } from '../../../helpers/real-theme-styles';

registerCustomStyles({ badge: badgeStubStyles });

const COLORS = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'danger'
] as const;
const SIZES = ['xs', 'sm', 'md', 'lg'] as const;

module('Integration | Component | Badge | @frontile/status', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    await render(
      <template>
        <Badge data-test-id="badge">Paid</Badge>
      </template>
    );

    assert.dom('[data-test-id="badge"]').hasText('Paid');
  });

  test('it is a span with data-component and no interactive semantics', async function (assert) {
    await render(
      <template>
        <Badge data-test-id="badge">Paid</Badge>
      </template>
    );

    assert.dom('[data-test-id="badge"]').hasTagName('span');
    assert
      .dom('[data-test-id="badge"]')
      .hasAttribute('data-component', 'badge');
    assert.dom('[data-test-id="badge"]').doesNotHaveAttribute('role');
    assert.dom('[data-test-id="badge"]').doesNotHaveAttribute('tabindex');
  });

  module('Content', () => {
    test('it renders a value and unit after the label', async function (assert) {
      await render(
        <template>
          <Badge @value="$24.00" @unit="/mo" data-test-id="badge">Pro</Badge>
        </template>
      );

      assert.dom('[data-test-id="badge"]').hasText('Pro $24.00 /mo');
      assert.dom('[data-part="value"]').hasText('$24.00');
      assert.dom('[data-part="unit"]').hasText('/mo');
    });

    test('it renders with only a value', async function (assert) {
      await render(
        <template><Badge @value="$24.00" data-test-id="badge" /></template>
      );

      assert.dom('[data-test-id="badge"]').hasText('$24.00');
      assert.dom('[data-part="unit"]').doesNotExist();
    });

    test('it renders start and end icon blocks', async function (assert) {
      await render(
        <template>
          <Badge @value="$24.00" @unit="/mo" data-test-id="badge">
            <:startIcon><svg data-test-icon="start"></svg></:startIcon>
            <:default>Pro</:default>
            <:endIcon><svg data-test-icon="end"></svg></:endIcon>
          </Badge>
        </template>
      );

      assert
        .dom(
          '[data-part="icon"][data-position="start"] svg[data-test-icon="start"]'
        )
        .exists();
      assert
        .dom(
          '[data-part="icon"][data-position="end"] svg[data-test-icon="end"]'
        )
        .exists();

      const parts = Array.from(
        document.querySelectorAll('[data-test-id="badge"] > [data-part]')
      ).map((el) =>
        [el.getAttribute('data-part'), el.getAttribute('data-position')]
          .filter(Boolean)
          .join(':')
      );
      assert.deepEqual(parts, ['icon:start', 'value', 'unit', 'icon:end']);

      const badge = document.querySelector('[data-test-id="badge"]')!;
      const startIcon = badge.querySelector(
        '[data-part="icon"][data-position="start"]'
      )!;
      const label = Array.from(badge.childNodes).find(
        (n) => n.nodeType === Node.TEXT_NODE && n.textContent?.includes('Pro')
      )!;
      assert.true(
        Boolean(
          startIcon.compareDocumentPosition(label) &
          Node.DOCUMENT_POSITION_FOLLOWING
        ),
        'start icon precedes the label'
      );
      assert.true(
        Boolean(
          label.compareDocumentPosition(
            badge.querySelector('[data-part="icon"][data-position="end"]')!
          ) & Node.DOCUMENT_POSITION_FOLLOWING
        ),
        'end icon follows the label'
      );
    });

    test('it does not render unit or icon wrappers when absent', async function (assert) {
      await render(
        <template>
          <Badge data-test-id="badge">Paid</Badge>
        </template>
      );

      assert.dom('[data-part="value"]').doesNotExist();
      assert.dom('[data-part="unit"]').doesNotExist();
      assert.dom('[data-part="icon"][data-position="start"]').doesNotExist();
      assert.dom('[data-part="icon"][data-position="end"]').doesNotExist();
    });
  });

  module('Style classes', () => {
    test('variant defaults to soft', async function (assert) {
      await render(
        <template>
          <Badge data-test-id="badge">Paid</Badge>
        </template>
      );

      assert.dom('[data-test-id="badge"]').hasClass('badge-soft');
      assert.dom('[data-test-id="badge"]').doesNotHaveClass('badge-outline');
    });

    test('it adds class for outline variant', async function (assert) {
      await render(
        <template>
          <Badge @variant="outline" data-test-id="badge">Paid</Badge>
        </template>
      );

      assert.dom('[data-test-id="badge"]').hasClass('badge-outline');
      assert.dom('[data-test-id="badge"]').doesNotHaveClass('badge-soft');
    });

    test('color defaults to neutral', async function (assert) {
      await render(
        <template>
          <Badge data-test-id="badge">Paid</Badge>
        </template>
      );

      assert.dom('[data-test-id="badge"]').hasClass('badge-neutral');
    });

    for (const color of COLORS) {
      test(`it adds class for ${color} color`, async function (assert) {
        await render(
          <template>
            <Badge @color={{color}} data-test-id="badge">Paid</Badge>
          </template>
        );

        assert.dom('[data-test-id="badge"]').hasClass(`badge-${color}`);
      });
    }

    test('size defaults to md', async function (assert) {
      await render(
        <template>
          <Badge data-test-id="badge">Paid</Badge>
        </template>
      );

      assert.dom('[data-test-id="badge"]').hasClass('badge-md');
    });

    for (const size of SIZES) {
      test(`it adds class for ${size} size`, async function (assert) {
        await render(
          <template>
            <Badge @size={{size}} data-test-id="badge">Paid</Badge>
          </template>
        );

        assert.dom('[data-test-id="badge"]').hasClass(`badge-${size}`);
      });
    }

    test('@class merges onto the base', async function (assert) {
      await render(
        <template>
          <Badge @class="my-class" data-test-id="badge">Paid</Badge>
        </template>
      );

      assert.dom('[data-test-id="badge"]').hasClass('my-class');
      assert.dom('[data-test-id="badge"]').hasClass('badge');
    });
  });

  module('Shipped theme', () => {
    test('radius tiers by size, never a pill', function (assert) {
      for (const size of ['xs', 'sm'] as const) {
        assert.true(
          realStyles.badge({ size }).base().includes('rounded-sm'),
          `${size} is rounded-sm`
        );
      }
      for (const size of ['md', 'lg'] as const) {
        assert.true(
          realStyles.badge({ size }).base().includes('rounded-md'),
          `${size} is rounded-md`
        );
      }
      for (const size of SIZES) {
        assert.false(
          realStyles.badge({ size }).base().includes('rounded-full'),
          `${size} is not rounded-full`
        );
      }
    });

    test('soft fill is -muted with on-muted text', function (assert) {
      const base = realStyles
        .badge({ variant: 'soft', color: 'primary' })
        .base();

      assert.true(base.includes('bg-primary-muted'));
      assert.true(base.includes('text-on-primary-muted'));
    });

    test('outline uses border-current with -strong text', function (assert) {
      const base = realStyles
        .badge({ variant: 'outline', color: 'danger' })
        .base();

      assert.true(base.includes('border-current'));
      assert.true(base.includes('text-danger-strong'));
    });

    test('md is 28px tall', function (assert) {
      assert.true(realStyles.badge({ size: 'md' }).base().includes('h-7'));
    });
  });
});
