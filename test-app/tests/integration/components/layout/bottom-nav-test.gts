import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find } from '@ember/test-helpers';
import { BottomNav } from 'frontile';
import { registerCustomStyles, useStyles } from '@frontile/theme';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';
import type { TOC } from '@ember/component/template-only';

const TestIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <svg data-test-icon viewBox="0 0 16 16" width="16" height="16" ...attributes>
    <rect width="16" height="16" />
  </svg>
</template>;

// `#ember-testing` is scaled, so measure with computed styles, which are
// unaffected by the transform.
function px(el: HTMLElement, prop: 'height' | 'padding-bottom'): number {
  return parseFloat(getComputedStyle(el).getPropertyValue(prop));
}

module(
  'Integration | Component | BottomNav | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    let previous: Partial<ReturnType<typeof useStyles>>;

    hooks.beforeEach(function () {
      previous = {
        navItem: useStyles().navItem,
        bottomNav: useStyles().bottomNav,
        appLayout: useStyles().appLayout
      };
      registerCustomStyles({
        navItem: realStyles.navItem,
        bottomNav: realStyles.bottomNav,
        appLayout: realStyles.appLayout
      });
    });

    hooks.afterEach(function () {
      registerCustomStyles(previous);
    });

    test('renders a nav landmark with the default name Main', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.Item @href="/a" @icon={{TestIcon}}>A</bar.Item>
          </BottomNav>
        </template>
      );

      assert.dom('nav[data-part="bottom-nav"]').exists({ count: 1 });
      assert
        .dom('nav[data-part="bottom-nav"]')
        .hasAttribute('aria-label', 'Main');
    });

    test('label sets the landmark name', async function (assert) {
      await render(
        <template>
          <BottomNav @label="Primary" as |bar|>
            <bar.Item @href="/a" @icon={{TestIcon}}>A</bar.Item>
          </BottomNav>
        </template>
      );

      assert
        .dom('nav[data-part="bottom-nav"]')
        .hasAttribute('aria-label', 'Primary');
    });

    test('Item renders an icon-layout NavItem', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.Item @href="/a" @icon={{TestIcon}}>Home</bar.Item>
          </BottomNav>
        </template>
      );

      assert.dom('[data-part="nav-item"]').hasAttribute('data-layout', 'icon');
      assert.dom('[data-part="nav-item"]').hasText('Home');
    });

    test('Item marks the active tab aria-current and data-active', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.Item @href="/a" @icon={{TestIcon}} @isActive={{true}} id="a">
              A
            </bar.Item>
            <bar.Item @href="/b" @icon={{TestIcon}} id="b">B</bar.Item>
          </BottomNav>
        </template>
      );

      assert.dom('#a').hasAttribute('aria-current', 'page');
      assert.dom('#a').hasAttribute('data-active', 'true');
      assert.dom('#b').doesNotHaveAttribute('aria-current');
    });

    test('bar pads the bottom by the safe-area inset', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.Item @href="/a" @icon={{TestIcon}}>A</bar.Item>
          </BottomNav>
        </template>
      );

      const bar = find('[data-part="bottom-nav"]') as HTMLElement;
      bar.style.setProperty('--bottomnav-safe-area', '20px');
      assert.strictEqual(px(bar, 'padding-bottom'), 20);
      assert.strictEqual(px(bar, 'height'), 80, 'row height plus the inset');
    });

    test('with no inset the bar is exactly the row height', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.Item @href="/a" @icon={{TestIcon}}>A</bar.Item>
          </BottomNav>
        </template>
      );

      const bar = find('[data-part="bottom-nav"]') as HTMLElement;
      bar.style.setProperty('--bottomnav-safe-area', '0px');
      assert.strictEqual(px(bar, 'height'), 60);
    });

    test('tab badge renders', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.Item
              @href="/a"
              @icon={{TestIcon}}
              @badge={{3}}
            >Inbox</bar.Item>
          </BottomNav>
        </template>
      );

      assert.dom('[data-part="nav-item-badge"]').hasText('3');
    });

    test('standalone bar is fixed to the bottom', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.Item @href="/a" @icon={{TestIcon}}>A</bar.Item>
          </BottomNav>
        </template>
      );

      const style = getComputedStyle(find('[data-part="bottom-nav"]')!);
      assert.strictEqual(style.position, 'fixed');
      assert.strictEqual(style.bottom, '0px');
    });
  }
);
