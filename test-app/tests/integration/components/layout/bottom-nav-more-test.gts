import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  click,
  focus,
  triggerKeyEvent
} from '@ember/test-helpers';
import { BottomNav } from 'frontile';
import { registerCustomStyles, useStyles } from '@frontile/theme';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';
import type { TOC } from '@ember/component/template-only';

const TestIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <svg data-test-icon viewBox="0 0 16 16" width="16" height="16" ...attributes>
    <rect width="16" height="16" />
  </svg>
</template>;

const TAB = '[data-part="nav-item"][aria-haspopup="dialog"]';
const SHEET = '[role="dialog"]';
const SHEET_ITEM = `${SHEET} [data-part="nav-item"]`;

// The theme's placement classes name the side (`bottom-2`).
function isPlaced(dialog: Element, side: 'top' | 'bottom'): boolean {
  const other = side === 'top' ? 'bottom' : 'top';
  const names = [...dialog.classList];
  return (
    names.some((name) => name.includes(side)) &&
    !names.some((name) => name.includes(other))
  );
}

module(
  'Integration | Component | BottomNav More | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    let previous: Partial<ReturnType<typeof useStyles>>;

    // Other test files replace these with class markers; the geometry and
    // placement checks here need the shipped classes.
    hooks.beforeEach(function () {
      const current = useStyles();
      previous = {
        navItem: current.navItem,
        bottomNav: current.bottomNav,
        appLayout: current.appLayout,
        drawer: current.drawer,
        overlay: current.overlay,
        backdrop: current.backdrop
      };
      registerCustomStyles({
        navItem: realStyles.navItem,
        bottomNav: realStyles.bottomNav,
        appLayout: realStyles.appLayout,
        drawer: realStyles.drawer,
        overlay: realStyles.overlay,
        backdrop: realStyles.backdrop
      });
    });

    hooks.afterEach(function () {
      registerCustomStyles(previous);
    });

    test('renders a More tab with aria-haspopup=dialog and aria-expanded=false', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.Item @href="#home" @icon={{TestIcon}}>Home</bar.Item>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      assert.dom(TAB).exists({ count: 1 });
      assert.strictEqual(find(TAB)!.tagName, 'BUTTON');
      assert.dom(TAB).hasAttribute('data-layout', 'icon');
      assert.dom(TAB).hasAria('expanded', 'false');
      assert.dom(`${TAB} [data-part="nav-item-label"]`).hasText('More');
      assert.dom(SHEET).doesNotExist();
    });

    test('clicking opens a bottom sheet dialog with the items', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More @sheetLabel="More pages" as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
              <more.Item @href="#b" @icon={{TestIcon}}>B</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      await click(TAB);

      assert.dom(SHEET).exists({ count: 1 });
      assert.dom(SHEET).hasAttribute('aria-label', 'More pages');
      assert.dom(TAB).hasAria('expanded', 'true');
      assert.dom(TAB).hasAria('controls', find(SHEET)!.id);
      assert.dom(`${SHEET} nav`).hasAttribute('aria-label', 'More pages');
      assert.dom(SHEET_ITEM).exists({ count: 2 });
      assert.dom(SHEET_ITEM).isVisible();
    });

    test("the sheet's items are inline NavItems", async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      await click(TAB);
      assert.dom(SHEET_ITEM).hasAttribute('data-layout', 'inline');
      assert.dom(`${SHEET_ITEM} [data-part="nav-item-label"]`).isVisible();
    });

    test('navigating closes the sheet', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#go" @icon={{TestIcon}} id="go">Go</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      await click(TAB);
      await click(`${SHEET} #go`);

      assert.dom(SHEET).doesNotExist();
      assert.dom(TAB).hasAria('expanded', 'false');
      assert.dom(TAB).isFocused('focus returns to the More tab');
    });

    test('Escape closes the sheet and focuses the More tab', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      await click(TAB);
      assert.dom(SHEET).exists();
      await triggerKeyEvent(SHEET, 'keydown', 'Escape');

      assert.dom(SHEET).doesNotExist();
      assert.dom(TAB).isFocused();
    });

    test('active item inside a closed sheet marks More active', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
              <more.Item
                @href="#b"
                @icon={{TestIcon}}
                @isActive={{true}}
              >B</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      assert.dom(SHEET).doesNotExist('the sheet was never opened');
      assert.dom(TAB).hasAttribute('data-active', 'true');
    });

    test('More is never aria-current=page', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item
                @href="#a"
                @icon={{TestIcon}}
                @isActive={{true}}
              >A</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      assert.dom(TAB).hasAttribute('data-active', 'true');
      assert.dom(TAB).hasAttribute('aria-current', 'false');

      await click(TAB);
      assert.dom(TAB).hasAttribute('aria-current', 'false');
      assert
        .dom(SHEET_ITEM)
        .hasAttribute('aria-current', 'page', 'the item itself is current');
    });

    test('active item inside a folder in the sheet marks More active', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
              <more.Folder @label="Reports" @icon={{TestIcon}} as |folder|>
                <folder.Item @href="#r1" @isActive={{true}}>R1</folder.Item>
                <folder.Item @href="#r2">R2</folder.Item>
              </more.Folder>
            </bar.More>
          </BottomNav>
        </template>
      );

      assert.dom(TAB).hasAttribute('data-active', 'true');
    });

    test('folder inside the sheet is inline disclosure, never a flyout', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Folder @label="Reports" @icon={{TestIcon}} as |folder|>
                <folder.Item @href="#r1" id="r1">R1</folder.Item>
              </more.Folder>
            </bar.More>
          </BottomNav>
        </template>
      );

      await click(TAB);
      const trigger = `${SHEET} [data-part="nav-folder-trigger"]`;
      assert.dom(`${SHEET} [data-part="nav-folder-panel"]`).exists();
      assert.dom(`${SHEET} [data-part="nav-folder-flyout"]`).doesNotExist();
      assert.dom(trigger).hasAria('expanded', 'false');

      await click(trigger);
      assert.dom(trigger).hasAria('expanded', 'true');
      assert.dom(`${SHEET} #r1`).hasAttribute('data-layout', 'inline');

      await click(`${SHEET} #r1`);
      assert.dom(SHEET).doesNotExist('following a folder item closes it');
    });

    test('badge on an item inside marks the More tab with a dot and sr-only text', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}} @badge={{4}}>
                A
              </more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      const dot = `${TAB} [data-part="nav-item-badge"]`;
      assert.dom(dot).exists().hasNoText().hasAttribute('aria-hidden', 'true');
      assert
        .dom(`${TAB} [data-part="nav-item-badge-label"]`)
        .hasText(', has updates');
    });

    test('badge inside a folder propagates', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
              <more.Folder @label="Reports" as |folder|>
                <folder.Item @href="#r1" @badge="new">R1</folder.Item>
              </more.Folder>
            </bar.More>
          </BottomNav>
        </template>
      );

      assert.dom(`${TAB} [data-part="nav-item-badge"]`).exists();
      assert.dom(TAB).hasAttribute('data-active', 'false');
    });

    test('a hidden active item does not mark More active', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
              <more.Item
                @href="#b"
                @icon={{TestIcon}}
                @isActive={{true}}
                @isHidden={{true}}
              >B</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      assert.dom(TAB).exists();
      assert.dom(TAB).hasAttribute('data-active', 'false');
    });

    test('a hidden badged item does not badge More', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
              <more.Item
                @href="#b"
                @icon={{TestIcon}}
                @badge={{2}}
                @isHidden={{true}}
              >B</more.Item>
              <more.Folder @label="Reports" @isHidden={{true}} as |folder|>
                <folder.Item @href="#r1" @badge={{1}}>R1</folder.Item>
              </more.Folder>
            </bar.More>
          </BottomNav>
        </template>
      );

      assert.dom(TAB).exists();
      assert.dom(`${TAB} [data-part="nav-item-badge"]`).doesNotExist();
    });

    test('a disabled item inside the sheet is not followed and does not close it', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item
                @href="#x"
                @icon={{TestIcon}}
                @isDisabled={{true}}
                id="off"
              >Off</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      await click(TAB);
      assert.dom(`${SHEET} #off`).doesNotHaveAttribute('href');
      await click(`${SHEET} #off`);
      assert.dom(SHEET).exists('still open');
    });

    test('More renders nothing when every item inside is hidden', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.Item @href="#home" @icon={{TestIcon}}>Home</bar.Item>
            <bar.More as |more|>
              <more.Item @href="#a" @isHidden={{true}}>A</more.Item>
              <more.Folder @label="Reports" as |folder|>
                <folder.Item @href="#r1" @isHidden={{true}}>R1</folder.Item>
              </more.Folder>
            </bar.More>
          </BottomNav>
        </template>
      );

      assert.dom(TAB).doesNotExist();
      assert
        .dom('[data-part="bottom-nav"] > [data-part="nav-item"]')
        .exists({ count: 1 }, 'the other tab still renders');
    });

    test('More renders nothing with @isHidden', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More @isHidden={{true}} as |more|>
              <more.Item @href="#a">A</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      assert.dom(TAB).doesNotExist();
    });

    test('More shows inactive with no badge when nothing inside is active', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
              <more.Folder @label="Reports" as |folder|>
                <folder.Item @href="#r1">R1</folder.Item>
              </more.Folder>
            </bar.More>
          </BottomNav>
        </template>
      );

      assert.dom(TAB).hasAttribute('data-active', 'false');
      assert.dom(`${TAB} [data-part="nav-item-badge"]`).doesNotExist();
      assert
        .dom(`${TAB} [data-part="nav-item-label"]`)
        .hasText('More', 'no badge text');
    });

    test('the sheet pads for the safe-area inset', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      await click(TAB);
      const body = find(
        `${SHEET} [data-part="bottom-nav-more-body"]`
      ) as HTMLElement;
      body.style.setProperty('--bottomnav-safe-area', '24px');
      assert.strictEqual(getComputedStyle(body).paddingBottom, '24px');
      const sheet = find(SHEET)!;
      assert.true(
        sheet.className.includes('max-h-[80dvh]'),
        'the sheet is bounded to 80% of the viewport'
      );
    });

    test('the sheet is placed at the bottom', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      await click(TAB);
      assert.true(isPlaced(find(SHEET)!, 'bottom'));
      assert
        .dom(`${SHEET} [data-part="drag-handle"]`)
        .exists('it has a drag handle');
    });

    test("closing and reopening keeps the tab's active state", async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item
                @href="#a"
                @icon={{TestIcon}}
                @isActive={{true}}
              >A</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      await click(TAB);
      await triggerKeyEvent(SHEET, 'keydown', 'Escape');
      assert.dom(SHEET).doesNotExist();
      assert.dom(TAB).hasAttribute('data-active', 'true');

      await click(TAB);
      assert.dom(SHEET).exists();
      assert.dom(TAB).hasAttribute('data-active', 'true');
      await triggerKeyEvent(SHEET, 'keydown', 'Escape');
      assert.dom(TAB).hasAttribute('data-active', 'true');
    });

    test('the More tab shows no tooltip, so reopening after focus returns works', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      await focus(TAB);
      assert.dom('[role="tooltip"]').doesNotExist();

      await click(TAB);
      await click(SHEET_ITEM);
      assert.dom(TAB).isFocused();
      await click(TAB);
      assert.dom(SHEET).exists('opens again');
    });

    test('the hidden registry copy stays out of sight and out of the tab order', async function (assert) {
      await render(
        <template>
          <BottomNav as |bar|>
            <bar.More as |more|>
              <more.Item @href="#a" @icon={{TestIcon}}>A</more.Item>
            </bar.More>
          </BottomNav>
        </template>
      );

      const registry = '[data-part="bottom-nav-more-registry"]';
      assert.dom(registry).hasAttribute('hidden');
      assert.dom(registry).hasAttribute('inert');
      assert.dom(registry).hasAria('hidden', 'true');
      assert.dom(registry).isNotVisible();
    });
  }
);
