import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find } from '@ember/test-helpers';
import { array } from '@ember/helper';
import { AppLayout, SidebarBrand } from 'frontile';
import { mockMatchMedia } from 'test-app/tests/helpers/match-media';
import type { TOC } from '@ember/component/template-only';

const TestLogo: TOC<{ Element: SVGSVGElement }> = <template>
  <svg data-test-logo viewBox="0 0 16 16" width="16" height="16" ...attributes>
    <rect width="16" height="16" />
  </svg>
</template>;

function isVisiblyHidden(el: Element): boolean {
  const rect = el.getBoundingClientRect();
  return rect.width <= 1 && rect.height <= 1;
}

function isTransparent(color: string): boolean {
  return color === 'transparent' || color === 'rgba(0, 0, 0, 0)';
}

module(
  'Integration | Component | SidebarBrand | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    test('renders the title and the subtitle', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Header>
                <sidebar.Brand @title="Acme" @subtitle="Workspace" />
              </sidebar.Header>
            </layout.Sidebar>
          </AppLayout>
        </template>
      );

      assert
        .dom('[data-part="sidebar-header"] [data-part="sidebar-brand"]')
        .exists();
      assert.dom('[data-part="sidebar-brand-title"]').hasText('Acme');
      assert.dom('[data-part="sidebar-brand-subtitle"]').hasText('Workspace');
    });

    test('without @subtitle no subtitle is rendered', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Header>
                <sidebar.Brand @title="Acme" />
              </sidebar.Header>
            </layout.Sidebar>
          </AppLayout>
        </template>
      );

      assert.dom('[data-part="sidebar-brand-title"]').hasText('Acme');
      assert.dom('[data-part="sidebar-brand-subtitle"]').doesNotExist();
    });

    test('@href makes the whole brand one link', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Header>
                <sidebar.Brand @title="Acme" @subtitle="Workspace" @href="/">
                  <:logo><TestLogo /></:logo>
                </sidebar.Brand>
              </sidebar.Header>
            </layout.Sidebar>
          </AppLayout>
        </template>
      );

      assert.dom('a[data-part="sidebar-brand"]').hasAttribute('href', '/');
      assert
        .dom('a[data-part="sidebar-brand"] [data-test-logo]')
        .exists('the logo is inside the link');
      assert
        .dom('a[data-part="sidebar-brand"] [data-part="sidebar-brand-title"]')
        .hasText('Acme');
      assert.dom('a[data-part="sidebar-brand"]').hasText('Acme Workspace');
    });

    test('without @href the brand is not a link', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Header>
                <sidebar.Brand @title="Acme">
                  <:logo><TestLogo /></:logo>
                </sidebar.Brand>
              </sidebar.Header>
            </layout.Sidebar>
          </AppLayout>
        </template>
      );

      assert.dom('div[data-part="sidebar-brand"]').exists();
      assert.dom('[data-part="sidebar"] a').doesNotExist();
    });

    test('the logo sits in a sized square, tinted unless @tile is false', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Header>
                <sidebar.Brand @title="Tinted" id="tinted">
                  <:logo><TestLogo /></:logo>
                </sidebar.Brand>
                <sidebar.Brand @title="Plain" @tile={{false}} id="plain">
                  <:logo><TestLogo /></:logo>
                </sidebar.Brand>
              </sidebar.Header>
            </layout.Sidebar>
          </AppLayout>
        </template>
      );

      const tinted = find('#tinted [data-part="sidebar-brand-logo"]')!;
      const plain = find('#plain [data-part="sidebar-brand-logo"]')!;
      assert.dom('[data-test-logo]', tinted).exists('the logo renders inside');

      const rect = tinted.getBoundingClientRect();
      assert.true(rect.width > 0, 'the square has a size');
      assert.strictEqual(rect.width, rect.height, 'the logo slot is square');
      assert.strictEqual(
        plain.getBoundingClientRect().width,
        rect.width,
        'the same size with or without the tile'
      );

      assert.false(
        isTransparent(getComputedStyle(tinted).backgroundColor),
        'the tile is tinted'
      );
      assert.true(
        isTransparent(getComputedStyle(plain).backgroundColor),
        '@tile={{false}} shows the logo as is'
      );
    });

    test('without a logo block no logo slot is rendered', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Header>
                <sidebar.Brand @title="Acme" />
              </sidebar.Header>
            </layout.Sidebar>
          </AppLayout>
        </template>
      );

      assert.dom('[data-part="sidebar-brand-logo"]').doesNotExist();
    });

    test('expanded, the title and subtitle are shown', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Header>
                <sidebar.Brand @title="Acme" @subtitle="Workspace">
                  <:logo><TestLogo /></:logo>
                </sidebar.Brand>
              </sidebar.Header>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      for (const part of ['sidebar-brand-title', 'sidebar-brand-subtitle']) {
        const el = find(`[data-part="${part}"]`)!;
        assert.false(isVisiblyHidden(el), `${part} is visible`);
        assert.notStrictEqual(getComputedStyle(el).position, 'absolute');
      }
    });

    test('in the icon rail the logo stays and the text is visually hidden', async function (assert) {
      await render(
        <template>
          <AppLayout @defaultSidebarCollapsed={{true}} as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Header>
                <sidebar.Brand @title="Acme" @subtitle="Workspace" @href="/">
                  <:logo><TestLogo /></:logo>
                </sidebar.Brand>
              </sidebar.Header>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      for (const part of ['sidebar-brand-title', 'sidebar-brand-subtitle']) {
        const el = find(`[data-part="${part}"]`)!;
        const style = getComputedStyle(el);
        assert.notStrictEqual(style.display, 'none', `${part} display`);
        assert.notStrictEqual(style.visibility, 'hidden', `${part} visibility`);
        assert.strictEqual(style.position, 'absolute', `${part} sr-only`);
        assert.true(isVisiblyHidden(el), `${part} visually hidden`);
      }

      assert
        .dom('a[data-part="sidebar-brand"]')
        .hasText('Acme Workspace', 'the link keeps its name');
      assert.false(
        isVisiblyHidden(find('[data-part="sidebar-brand-logo"]')!),
        'the logo stays visible'
      );
    });

    test('the tile fits the collapsed rail, centered, in both variants', async function (assert) {
      await render(
        <template>
          {{#each (array "inset" "attached") as |variant|}}
            <AppLayout
              @variant={{variant}}
              @defaultSidebarCollapsed={{true}}
              @toggleShortcut={{false}}
              @skipLink={{false}}
              data-test-variant={{variant}}
              as |layout|
            >
              <layout.Sidebar as |sidebar|>
                <sidebar.Header>
                  <sidebar.Brand @title="Acme" @subtitle="Workspace">
                    <:logo><TestLogo /></:logo>
                  </sidebar.Brand>
                </sidebar.Header>
              </layout.Sidebar>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          {{/each}}
        </template>
      );

      for (const variant of ['inset', 'attached']) {
        const root = `[data-test-variant="${variant}"]`;
        const sidebarEl = find(`${root} [data-part="sidebar"]`) as HTMLElement;
        sidebarEl.style.transition = 'none';
        const header = find(`${root} [data-part="sidebar-header"]`)!;
        const brand = find(`${root} [data-part="sidebar-brand"]`)!;
        const logo = find(`${root} [data-part="sidebar-brand-logo"]`)!;

        const h = header.getBoundingClientRect();
        const l = logo.getBoundingClientRect();
        assert.true(l.width > 0, `${variant}: the tile is drawn`);
        assert.true(
          l.left >= h.left - 0.5 && l.right <= h.right + 0.5,
          `${variant}: the tile (${l.left}-${l.right}) is inside the header (${h.left}-${h.right})`
        );
        assert.true(
          header.scrollWidth <= header.clientWidth,
          `${variant}: the header does not overflow`
        );
        assert.true(
          brand.scrollWidth <= brand.clientWidth,
          `${variant}: the brand does not overflow`
        );

        const headerCenter = (h.left + h.right) / 2;
        const logoCenter = (l.left + l.right) / 2;
        assert.true(
          Math.abs(headerCenter - logoCenter) <= 1,
          `${variant}: the tile is centered (${logoCenter} vs ${headerCenter})`
        );
      }
    });

    test('in the mobile drawer it is always expanded', async function (assert) {
      const media = mockMatchMedia(500);

      try {
        await render(
          <template>
            <AppLayout
              @defaultSidebarCollapsed={{true}}
              @defaultMobileSidebarOpen={{true}}
              as |layout|
            >
              <layout.Sidebar as |sidebar|>
                <sidebar.Header>
                  <sidebar.Brand @title="Acme" @subtitle="Workspace">
                    <:logo><TestLogo /></:logo>
                  </sidebar.Brand>
                </sidebar.Header>
              </layout.Sidebar>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </template>
        );

        const title = find('[data-part="sidebar-brand-title"]')!;
        assert.dom('[data-part="mobile-sidebar"]').exists('in the drawer');
        assert.false(isVisiblyHidden(title), 'the title is shown');
      } finally {
        media.restore();
      }
    });

    test('renders on its own, outside a Sidebar', async function (assert) {
      await render(
        <template>
          <SidebarBrand @title="Acme" @subtitle="Workspace" @href="/">
            <:logo><TestLogo /></:logo>
          </SidebarBrand>
        </template>
      );

      assert.dom('a[data-part="sidebar-brand"]').hasAttribute('class');
      assert.dom('[data-part="sidebar-brand-logo"]').hasAttribute('class');
      assert.dom('[data-part="sidebar-brand-title"]').hasText('Acme');
      assert.false(
        isVisiblyHidden(find('[data-part="sidebar-brand-title"]')!),
        'standalone, the title is shown'
      );
    });
  }
);
