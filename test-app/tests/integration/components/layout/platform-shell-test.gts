import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, findAll, click, settled } from '@ember/test-helpers';
import { registerCustomStyles, useStyles } from '@frontile/theme';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';
import {
  mockMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';
import PlatformShell from 'test-app/components/platform-shell';

const MOBILE = 500;
const DESKTOP = 1200;
const SIDEBAR = '[data-part="sidebar"]';
const BAR = 'nav[data-part="bottom-nav"]';
const MORE_TAB = `${BAR} [aria-haspopup="dialog"]`;
const SHEET = '[role="dialog"]';

module(
  'Integration | Component | platform shell | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    let media: MatchMediaMock | undefined;
    let previous: Partial<ReturnType<typeof useStyles>>;

    hooks.beforeEach(function () {
      const current = useStyles();
      previous = {
        navItem: current.navItem,
        sidebar: current.sidebar,
        bottomNav: current.bottomNav,
        appLayout: current.appLayout,
        drawer: current.drawer,
        overlay: current.overlay,
        backdrop: current.backdrop
      };
      registerCustomStyles({
        navItem: realStyles.navItem,
        sidebar: realStyles.sidebar,
        bottomNav: realStyles.bottomNav,
        appLayout: realStyles.appLayout,
        drawer: realStyles.drawer,
        overlay: realStyles.overlay,
        backdrop: realStyles.backdrop
      });
    });

    hooks.afterEach(function () {
      media?.restore();
      media = undefined;
      registerCustomStyles(previous);
    });

    test('desktop renders an 80px stacked rail with six items and no bottom bar', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(<template><PlatformShell /></template>);

      assert.dom(BAR).doesNotExist('no bottom bar at desktop width');
      assert.dom(SIDEBAR).exists();
      const items = findAll(`${SIDEBAR} [data-part="nav-item"]`);
      assert.strictEqual(items.length, 6, 'six rail items');
      items.forEach((item) =>
        assert.strictEqual(item.getAttribute('data-layout'), 'stacked')
      );
      // #ember-testing is scaled, so measure through computed style.
      const width = getComputedStyle(find(SIDEBAR)!).width;
      assert.strictEqual(parseFloat(width), 80, `rail is 80px wide (${width})`);
    });

    test('phone renders the top bar and the bottom bar, no rail', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(<template><PlatformShell /></template>);

      assert.dom(SIDEBAR).doesNotExist('no rail on a phone');
      assert.dom(BAR).exists();
      assert.dom('[data-component="navbar"], header').exists('top bar');
      assert.dom('[data-test-account-line]').exists();
      assert.dom('[data-test-avatar-top]').exists();
      const labels = findAll(
        `${BAR} [data-part="nav-item"]:not([aria-haspopup]) [data-part="nav-item-label"]`
      ).map((el) => el.firstChild?.textContent?.trim());
      assert.deepEqual(
        labels.slice(0, 5),
        ['Overview', 'Services', 'Billing', 'Marketplace', 'Referral program'],
        'five tabs before More'
      );
      assert.dom(MORE_TAB).exists('the More tab is the sixth');
    });

    test('the stacked items show short labels and expose full labels as names', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(<template><PlatformShell /></template>);

      const referrals = findAll(`${SIDEBAR} [data-part="nav-item"]`)[4]!;
      assert
        .dom('[data-part="nav-item-short-label"]', referrals)
        .hasText('Referrals');
      assert
        .dom('[data-part="nav-item-short-label"]', referrals)
        .hasAttribute('aria-hidden', 'true');
      assert
        .dom('[data-part="nav-item-label"]', referrals)
        .hasText('Referral program');
    });

    test('the Overview badge shows on the rail item and the tab', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(<template><PlatformShell /></template>);
      assert
        .dom(`${SIDEBAR} [data-part="nav-item"] [data-part="nav-item-badge"]`)
        .hasText('2');
      assert
        .dom(
          `${SIDEBAR} [data-part="nav-item"] [data-part="nav-item-badge-label"]`
        )
        .includesText('2 open orders');

      media.setWidth(MOBILE);
      await settled();
      assert
        .dom(`${BAR} [data-part="nav-item"] [data-part="nav-item-badge"]`)
        .hasText('2');
    });

    test('selecting an item inside More updates the page, closes the sheet and marks More active', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(<template><PlatformShell /></template>);

      assert.dom('[data-test-page]').hasText('Overview');
      await click(MORE_TAB);
      assert.dom(SHEET).exists('sheet opens');
      await click(`${SHEET} [data-part="nav-item"]:last-of-type`);

      assert.dom('[data-test-page]').hasText('Support');
      assert.dom(SHEET).doesNotExist('sheet closed');
      assert.dom(MORE_TAB).hasAttribute('data-active', 'true');
      assert.notStrictEqual(
        find(MORE_TAB)!.getAttribute('aria-current'),
        'page',
        'the tab is never the current page'
      );
    });

    test('the account tile and avatar markup render inside the sidebar header and footer unchanged', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(<template><PlatformShell /></template>);

      assert
        .dom('[data-part="sidebar-header"] [data-test-account-tile]')
        .hasAttribute('aria-label', 'Switch account · Sample Owner')
        .hasText('Sample Owner');
      assert.dom('[data-part="sidebar-header"] [data-test-brand]').exists();
      assert
        .dom('[data-part="sidebar-footer"] [data-test-avatar]')
        .hasAttribute('aria-label', 'Your account');
    });
  }
);
