import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, triggerEvent, click } from '@ember/test-helpers';
import { AppLayout, Sidebar, AppLayoutState } from 'frontile';
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

module(
  'Integration | Component | Sidebar.Item | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    test('href item renders an anchor', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Item @href="/reports">Reports</sidebar.Item>
              </sidebar.Body>
            </layout.Sidebar>
          </AppLayout>
        </template>
      );

      assert.dom('a[data-part="sidebar-item"]').exists({ count: 1 });
      assert
        .dom('a[data-part="sidebar-item"]')
        .hasAttribute('href', '/reports');
      assert.dom('a[data-part="sidebar-item"]').hasText('Reports');
      assert
        .dom('a[data-part="sidebar-item"]')
        .doesNotHaveAttribute('aria-current');
      assert
        .dom('a[data-part="sidebar-item"]')
        .hasAttribute('aria-disabled', 'false');
    });

    test('active item has aria-current="page"', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Item @href="/a" @isActive={{true}} id="item-a">
                  A
                </sidebar.Item>
                <sidebar.Item @href="/b" id="item-b">B</sidebar.Item>
              </sidebar.Body>
            </layout.Sidebar>
          </AppLayout>
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
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Item @href="/a" @isDisabled={{true}} id="item-a">
                  A
                </sidebar.Item>
                <sidebar.Item
                  @route="index"
                  @isDisabled={{true}}
                  id="item-route"
                >
                  Route
                </sidebar.Item>
              </sidebar.Body>
            </layout.Sidebar>
          </AppLayout>
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
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Item @href="/a" @isHidden={{true}} @icon={{TestIcon}}>
                  Hidden
                </sidebar.Item>
                <sidebar.Item @href="/b">Shown</sidebar.Item>
              </sidebar.Body>
            </layout.Sidebar>
          </AppLayout>
        </template>
      );

      assert.dom('[data-part="sidebar-item"]').exists({ count: 1 });
      assert.dom('[data-part="sidebar-item"]').hasText('Shown');
      assert.dom('[data-test-icon]').doesNotExist();
      assert
        .dom('[data-part="sidebar-body"]')
        .doesNotContainText('Hidden', 'not even the label is rendered');
    });

    test('renders @icon before the label, hidden from assistive technology', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Item @href="/a" @icon={{TestIcon}}>
                  Reports
                </sidebar.Item>
              </sidebar.Body>
            </layout.Sidebar>
          </AppLayout>
        </template>
      );

      assert
        .dom('[data-part="sidebar-item"] [data-part="sidebar-item-icon"]')
        .hasAttribute('aria-hidden', 'true');
      assert
        .dom('[data-part="sidebar-item-icon"] [data-test-icon]')
        .exists('the icon component renders inside the icon slot');
      assert
        .dom('[data-part="sidebar-item"] [data-part="sidebar-label"]')
        .hasText('Reports');
    });

    test('Group renders its label and labels its list', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Group @label="Projects">
                  <sidebar.Item @href="/a">Apollo</sidebar.Item>
                  <sidebar.Item @href="/b">Gemini</sidebar.Item>
                </sidebar.Group>
              </sidebar.Body>
            </layout.Sidebar>
          </AppLayout>
        </template>
      );

      const label = find('[data-part="sidebar-group-label"]') as HTMLElement;
      assert.dom(label).hasText('Projects');
      assert.ok(label.id, 'the label has an id');

      assert
        .dom('[data-part="sidebar-group"]')
        .hasAttribute('role', 'group')
        .hasAttribute('aria-labelledby', label.id);
      assert
        .dom('[data-part="sidebar-group"] [data-part="sidebar-item"]')
        .exists({ count: 2 }, 'the items are inside the labelled group');
    });

    test('two groups get distinct label ids', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Group @label="One">
                  <sidebar.Item @href="/a">A</sidebar.Item>
                </sidebar.Group>
                <sidebar.Group @label="Two">
                  <sidebar.Item @href="/b">B</sidebar.Item>
                </sidebar.Group>
              </sidebar.Body>
            </layout.Sidebar>
          </AppLayout>
        </template>
      );

      const groups = document.querySelectorAll('[data-part="sidebar-group"]');
      assert.notStrictEqual(
        groups[0]!.getAttribute('aria-labelledby'),
        groups[1]!.getAttribute('aria-labelledby')
      );
    });

    test('collapsed rail keeps the label accessible', async function (assert) {
      await render(
        <template>
          <AppLayout @defaultSidebarCollapsed={{true}} as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Group @label="Workspace">
                  <sidebar.Item @href="/reports" @icon={{TestIcon}} id="item">
                    Reports
                  </sidebar.Item>
                </sidebar.Group>
              </sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      for (const selector of [
        '#item [data-part="sidebar-label"]',
        '[data-part="sidebar-group-label"]'
      ]) {
        const label = find(selector)!;
        const style = getComputedStyle(label);
        assert.notStrictEqual(style.display, 'none', `${selector} display`);
        assert.notStrictEqual(
          style.visibility,
          'hidden',
          `${selector} visibility`
        );
        assert.strictEqual(style.position, 'absolute', `${selector} sr-only`);
        assert.true(isVisiblyHidden(label), `${selector} visually hidden`);
      }

      assert.dom('#item').hasText('Reports', 'the link keeps its name');
      const icon = find('#item [data-test-icon]')!;
      assert.false(isVisiblyHidden(icon), 'the icon stays visible');
    });

    test('in the icon rail the label is shown as a tooltip', async function (assert) {
      await render(
        <template>
          <AppLayout @defaultSidebarCollapsed={{true}} as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Item @href="/reports" @icon={{TestIcon}} id="item">
                  Reports
                </sidebar.Item>
              </sidebar.Body>
            </layout.Sidebar>
            <layout.SidebarToggle />
          </AppLayout>
        </template>
      );

      await triggerEvent('#item', 'mouseenter');
      assert.dom('[role="tooltip"]').exists();
      assert.dom('[role="tooltip"]').hasText('Reports');
      await triggerEvent('#item', 'mouseleave');

      await click('[data-part="sidebar-toggle"]');
      await triggerEvent('#item', 'mouseenter');
      assert
        .dom('[role="tooltip"]')
        .doesNotExist('no tooltip while the sidebar is expanded');
    });

    test('Item and Group work in a standalone Sidebar', async function (assert) {
      const state = new AppLayoutState();
      await render(
        <template>
          <Sidebar @state={{state}} as |sidebar|>
            <sidebar.Body>
              <sidebar.Group @label="Reports">
                <sidebar.Item @href="/daily" @isActive={{true}}>
                  Daily
                </sidebar.Item>
              </sidebar.Group>
            </sidebar.Body>
          </Sidebar>
        </template>
      );

      assert
        .dom('[data-part="sidebar-group"] a[href="/daily"]')
        .hasAttribute('aria-current', 'page');
    });
  }
);
