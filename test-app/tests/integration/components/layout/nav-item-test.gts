import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  triggerEvent,
  click,
  focus,
  settled
} from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import { NavItem } from 'frontile';
import type { TOC } from '@ember/component/template-only';

const TestIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <svg data-test-icon viewBox="0 0 16 16" width="16" height="16" ...attributes>
    <rect width="16" height="16" />
  </svg>
</template>;

function isVisiblyHidden(el: Element): boolean {
  const rect = el.getBoundingClientRect();
  return rect.width <= 1 && rect.height <= 1;
}

module('Integration | Component | NavItem | frontile/layout', function (hooks) {
  setupRenderingTest(hooks);

  test('a standalone NavItem renders an anchor with data-part="nav-item"', async function (assert) {
    await render(
      <template>
        <NavItem @href="/reports">Reports</NavItem>
      </template>
    );

    assert.dom('a[data-part="nav-item"]').exists({ count: 1 });
    assert.dom('a[data-part="nav-item"]').hasAttribute('href', '/reports');
    assert.dom('a[data-part="nav-item"]').hasText('Reports');
    assert.dom('a[data-part="nav-item"]').hasAttribute('class');
    assert.dom('a[data-part="nav-item"]').doesNotHaveAttribute('aria-current');
    assert
      .dom('a[data-part="nav-item"]')
      .hasAttribute('aria-disabled', 'false');
  });

  test('layout defaults to inline (data-layout="inline")', async function (assert) {
    await render(
      <template>
        <NavItem @href="/a">A</NavItem>
      </template>
    );

    assert.dom('[data-part="nav-item"]').hasAttribute('data-layout', 'inline');
  });

  test('@class is appended to the item classes', async function (assert) {
    await render(
      <template>
        <NavItem @href="/a" @class="extra-one">A</NavItem>
      </template>
    );

    assert.dom('[data-part="nav-item"]').hasClass('extra-one');
    assert.ok(
      (find('[data-part="nav-item"]') as HTMLElement).classList.length > 1,
      'keeps the theme classes'
    );
  });

  test('@class wins over a conflicting theme class', async function (assert) {
    await render(
      <template>
        <NavItem @href="/a" @class="text-primary" id="custom">A</NavItem>
        <span class="text-primary" id="reference">R</span>
      </template>
    );

    const item = find('#custom') as HTMLElement;
    assert.dom(item).hasClass('text-primary');
    assert
      .dom(item)
      .doesNotHaveClass('text-neutral-firm', 'the theme color is merged away');
    assert.true(item.classList.length > 1, 'keeps the other theme classes');
    assert.strictEqual(
      getComputedStyle(item).color,
      getComputedStyle(find('#reference')!).color,
      'the item renders in the consumer color'
    );
  });

  test('active item has aria-current="page"', async function (assert) {
    await render(
      <template>
        <NavItem @href="/a" @isActive={{true}} id="item-a">A</NavItem>
        <NavItem @href="/b" id="item-b">B</NavItem>
      </template>
    );

    assert.dom('#item-a').hasAttribute('aria-current', 'page');
    assert.dom('#item-a').hasAttribute('data-active', 'true');
    assert.dom('#item-b').doesNotHaveAttribute('aria-current');
    assert.dom('#item-b').hasAttribute('data-active', 'false');
  });

  test('isDisabled drops the href and sets aria-disabled', async function (assert) {
    await render(
      <template>
        <NavItem @href="/a" @isDisabled={{true}} id="item-a">A</NavItem>
        <NavItem @route="index" @isDisabled={{true}} id="item-route">
          Route
        </NavItem>
      </template>
    );

    assert.dom('#item-a').doesNotHaveAttribute('href');
    assert.dom('#item-a').hasAttribute('aria-disabled', 'true');
    assert.dom('#item-a').hasAttribute('data-disabled', 'true');
    assert
      .dom('#item-route')
      .doesNotHaveAttribute('href', 'a disabled route item is no LinkTo');
    assert.dom('#item-route').hasAttribute('aria-disabled', 'true');
  });

  test('isHidden renders nothing', async function (assert) {
    await render(
      <template>
        <NavItem @href="/a" @isHidden={{true}} @icon={{TestIcon}}>
          Hidden
        </NavItem>
        <NavItem @href="/b">Shown</NavItem>
      </template>
    );

    assert.dom('[data-part="nav-item"]').exists({ count: 1 });
    assert.dom('[data-part="nav-item"]').hasText('Shown');
    assert.dom('[data-test-icon]').doesNotExist();
    assert.dom(this.element).doesNotContainText('Hidden');
  });

  test('renders @icon before the label, hidden from assistive technology', async function (assert) {
    await render(
      <template>
        <NavItem @href="/a" @icon={{TestIcon}}>Reports</NavItem>
      </template>
    );

    assert
      .dom('[data-part="nav-item"] [data-part="nav-item-icon"]')
      .hasAttribute('aria-hidden', 'true');
    assert
      .dom('[data-part="nav-item-icon"] [data-test-icon]')
      .exists('the icon component renders inside the icon slot');
    assert
      .dom('[data-part="nav-item"] [data-part="nav-item-label"]')
      .hasText('Reports')
      .hasAttribute('data-sidebar-label');
  });

  test('@rail shows the label as a tooltip on hover and focus', async function (assert) {
    await render(
      <template>
        <NavItem @href="/reports" @icon={{TestIcon}} @rail={{true}} id="item">
          Reports
        </NavItem>
      </template>
    );

    await triggerEvent('#item', 'mouseenter');
    assert.dom('[role="tooltip"]').exists();
    assert.dom('[role="tooltip"]').hasText('Reports');
    await triggerEvent('#item', 'mouseleave');
    assert.dom('[role="tooltip"]').doesNotExist();

    await focus('#item');
    assert.dom('[role="tooltip"]').hasText('Reports');
  });

  test('without @rail there is no tooltip', async function (assert) {
    await render(
      <template>
        <NavItem @href="/reports" id="item">Reports</NavItem>
      </template>
    );

    await triggerEvent('#item', 'mouseenter');
    assert.dom('[role="tooltip"]').doesNotExist();
  });

  test('@tooltipPlacement is accepted', async function (assert) {
    await render(
      <template>
        <NavItem
          @href="/reports"
          @rail={{true}}
          @tooltipPlacement="left"
          id="item"
        >
          Reports
        </NavItem>
      </template>
    );

    await triggerEvent('#item', 'mouseenter');
    assert.dom('[role="tooltip"]').exists();
  });

  test('@onActivate is called on click, but not when disabled', async function (assert) {
    let calls = 0;
    const onActivate = () => {
      calls++;
    };
    await render(
      <template>
        <NavItem @href="#a" @onActivate={{onActivate}} id="on">On</NavItem>
        <NavItem
          @href="#b"
          @isDisabled={{true}}
          @onActivate={{onActivate}}
          id="off"
        >
          Off
        </NavItem>
      </template>
    );

    await click('#on');
    assert.strictEqual(calls, 1);
    await click('#off');
    assert.strictEqual(calls, 1, 'a disabled item does not activate');
  });

  test('the label is visually hidden in a collapsed sidebar context', async function (assert) {
    await render(
      <template>
        <div class="group/sidebar" data-collapsed="true">
          <NavItem @href="/reports" @icon={{TestIcon}} id="item">
            Reports
          </NavItem>
        </div>
      </template>
    );

    const label = find('#item [data-part="nav-item-label"]')!;
    assert.strictEqual(getComputedStyle(label).position, 'absolute');
    assert.true(isVisiblyHidden(label));
    assert.dom('#item').hasText('Reports');
  });

  test('with a @folder it registers once and unregisters on destroy', async function (assert) {
    const handles: { isActive: boolean; isHidden: boolean }[] = [];
    let unregistered = 0;
    const folder = {
      registerItem(item: {
        readonly isActive: boolean;
        readonly isHidden: boolean;
      }) {
        handles.push(item);
        return () => {
          unregistered++;
        };
      }
    };
    const state = new (class {
      @tracked show = true;
      @tracked active = true;
      @tracked hidden = false;
    })();

    await render(
      <template>
        {{#if state.show}}
          <NavItem
            @href="/a"
            @isActive={{state.active}}
            @isHidden={{state.hidden}}
            @folder={{folder}}
          >A</NavItem>
        {{/if}}
      </template>
    );

    assert.strictEqual(handles.length, 1, 'registered once');
    assert.true(handles[0]!.isActive, 'reflects @isActive');
    assert.false(handles[0]!.isHidden, 'reflects @isHidden');

    state.active = false;
    state.hidden = true;
    await settled();
    assert.strictEqual(handles.length, 1, 'does not re-register');
    assert.false(handles[0]!.isActive, 'follows @isActive');
    assert.true(handles[0]!.isHidden, 'follows @isHidden');
    assert.strictEqual(unregistered, 0);

    state.show = false;
    await settled();
    assert.strictEqual(unregistered, 1, 'unregistered on destroy');
  });
});
