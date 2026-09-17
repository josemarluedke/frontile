import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, findAll } from '@ember/test-helpers';
import { hash } from '@ember/helper';
import { Breadcrumbs } from 'frontile';

module(
  'Integration | Component | Breadcrumbs | frontile/navigation',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders a labelled nav landmark wrapping an ordered list', async function (assert) {
      await render(
        <template>
          <Breadcrumbs as |b|>
            <b.Item @href="/">Home</b.Item>
            <b.Item>Current</b.Item>
          </Breadcrumbs>
        </template>
      );

      assert.dom('nav').exists('renders a nav landmark');
      assert
        .dom('nav')
        .hasAria('label', 'Breadcrumb', 'defaults its accessible name');
      assert.dom('nav > ol').exists('the trail is an ordered list');
      assert.dom('nav ol > li').exists({ count: 2 });
      assert.dom('nav').hasAttribute('data-component', 'breadcrumbs');
    });

    test('@label overrides the accessible name', async function (assert) {
      await render(
        <template>
          <Breadcrumbs @label="You are here" as |b|>
            <b.Item>Current</b.Item>
          </Breadcrumbs>
        </template>
      );

      assert.dom('nav').hasAria('label', 'You are here');
    });

    test('a crumb with no link target is the current page and is not a link', async function (assert) {
      await render(
        <template>
          <Breadcrumbs as |b|>
            <b.Item @href="/">Home</b.Item>
            <b.Item>Current</b.Item>
          </Breadcrumbs>
        </template>
      );

      const links = findAll('[data-part="link"]');

      assert.dom(links[0]!).hasTagName('a');
      assert
        .dom(links[0]!)
        .doesNotHaveAttribute('aria-current', 'a linked crumb is not current');
      assert.dom(links[0]!).hasAttribute('data-current', 'false');

      assert
        .dom(links[1]!)
        .hasTagName('span', 'the current crumb is not a link');
      assert.dom(links[1]!).hasAttribute('aria-current', 'page');
      assert.dom(links[1]!).hasAttribute('data-current', 'true');
    });

    test('@isCurrent overrides the no-link-target rule in both directions', async function (assert) {
      await render(
        <template>
          <Breadcrumbs as |b|>
            <b.Item @href="/" @isCurrent={{true}}>Forced current</b.Item>
            <b.Item @isCurrent={{false}}>Forced not current</b.Item>
          </Breadcrumbs>
        </template>
      );

      const links = findAll('[data-part="link"]');

      assert.dom(links[0]!).hasAttribute('aria-current', 'page');
      assert.dom(links[1]!).doesNotHaveAttribute('aria-current');
      assert.dom(links[1]!).hasAttribute('data-current', 'false');
    });

    test('a separator follows every crumb but the last', async function (assert) {
      await render(
        <template>
          <Breadcrumbs as |b|>
            <b.Item @href="/">Home</b.Item>
            <b.Item @href="/posts">Posts</b.Item>
            <b.Item>Current</b.Item>
          </Breadcrumbs>
        </template>
      );

      // Every item renders one; the last one's is hidden by CSS
      // (`group-last/item:hidden`) rather than omitted, which is what lets
      // neither authoring form need to know which crumb is last.
      const separators = findAll('[data-part="separator"]');
      assert.strictEqual(separators.length, 3, 'one separator per crumb');

      separators.forEach((separator) => {
        assert.dom(separator).hasAttribute('aria-hidden', 'true');
        assert.dom(separator).hasClass('group-last/item:hidden');
      });

      assert.dom('[data-part="separator"] svg').exists('renders a glyph');
    });

    test('@separator replaces the glyph', async function (assert) {
      const Slash = <template>
        <span data-test-slash>/</span>
      </template>;

      await render(
        <template>
          <Breadcrumbs @separator={{Slash}} as |b|>
            <b.Item @href="/">Home</b.Item>
            <b.Item>Current</b.Item>
          </Breadcrumbs>
        </template>
      );

      assert.dom('[data-part="separator"] [data-test-slash]').exists();
      assert
        .dom('[data-part="separator"] svg')
        .doesNotExist('the default chevron is replaced, not joined');
    });

    test('@isDisabled drops the href and marks the crumb', async function (assert) {
      await render(
        <template>
          <Breadcrumbs as |b|>
            <b.Item @href="/posts" @isDisabled={{true}}>Posts</b.Item>
            <b.Item>Current</b.Item>
          </Breadcrumbs>
        </template>
      );

      const link = findAll('[data-part="link"]')[0]!;

      assert.dom(link).hasTagName('a');
      assert
        .dom(link)
        .doesNotHaveAttribute(
          'href',
          'aria-disabled alone leaves an anchor clickable, so the href goes'
        );
      assert.dom(link).hasAttribute('aria-disabled', 'true');
      assert.dom(link).hasAttribute('data-disabled', 'true');
    });

    test('@size, @color and @underline reach the rendered classes', async function (assert) {
      await render(
        <template>
          <Breadcrumbs @size="lg" @color="primary" @underline="always" as |b|>
            <b.Item @href="/">Home</b.Item>
          </Breadcrumbs>
        </template>
      );

      assert.dom('[data-part="list"]').hasClass('text-body-md');
      assert.dom('[data-part="link"]').hasClass('hover:text-primary');
      assert.dom('[data-part="link"]').hasClass('underline');
    });

    test('defaults are md / neutral / hover', async function (assert) {
      await render(
        <template>
          <Breadcrumbs as |b|>
            <b.Item @href="/">Home</b.Item>
          </Breadcrumbs>
        </template>
      );

      assert.dom('[data-part="list"]').hasClass('text-body-sm');
      assert.dom('[data-part="link"]').hasClass('hover:text-neutral-strong');
      assert.dom('[data-part="link"]').hasClass('hover:underline');
    });

    test('@classes overrides reach every slot', async function (assert) {
      await render(
        <template>
          <Breadcrumbs
            @classes={{hash
              base="custom-base"
              list="custom-list"
              item="custom-item"
              link="custom-link"
              separator="custom-separator"
            }}
            as |b|
          >
            <b.Item @href="/">Home</b.Item>
            <b.Item>Current</b.Item>
          </Breadcrumbs>
        </template>
      );

      assert.dom('[data-part="base"]').hasClass('custom-base');
      assert.dom('[data-part="list"]').hasClass('custom-list');
      assert.dom('[data-part="item"]').hasClass('custom-item');
      assert.dom('[data-part="link"]').hasClass('custom-link');
      assert.dom('[data-part="separator"]').hasClass('custom-separator');
    });

    test('@class on an item is appended to its link classes', async function (assert) {
      await render(
        <template>
          <Breadcrumbs as |b|>
            <b.Item @href="/" @class="mine">Home</b.Item>
          </Breadcrumbs>
        </template>
      );

      assert.dom('[data-part="link"]').hasClass('mine');
      assert.dom('[data-part="link"]').hasClass('text-neutral');
    });

    test('a consumer-supplied element gets the same classes and ARIA via the yielded pieces', async function (assert) {
      await render(
        <template>
          <Breadcrumbs as |b|>
            <li class={{b.itemClass}}>
              <a href="/" class={{b.linkClass}} {{b.setupItem false}}>Home</a>
              <span class={{b.separatorClass}} aria-hidden="true">/</span>
            </li>
            <li class={{b.itemClass}}>
              <span class={{b.linkClass}} {{b.setupItem true}}>Current</span>
            </li>
          </Breadcrumbs>
        </template>
      );

      const crumbs = findAll('nav ol li > :first-child');

      assert.dom(crumbs[0]!).hasClass('text-neutral');
      assert.dom(crumbs[0]!).hasAttribute('data-current', 'false');
      assert.dom(crumbs[0]!).doesNotHaveAttribute('aria-current');
      assert.dom(crumbs[1]!).hasAttribute('data-current', 'true');
      assert.dom(crumbs[1]!).hasAttribute('aria-current', 'page');
    });

    test('...attributes land on the crumb, not the list item', async function (assert) {
      await render(
        <template>
          <Breadcrumbs as |b|>
            <b.Item @href="/" data-test-crumb="home">Home</b.Item>
          </Breadcrumbs>
        </template>
      );

      assert.dom('[data-part="link"]').hasAttribute('data-test-crumb', 'home');
      assert.dom('li').doesNotHaveAttribute('data-test-crumb');
    });

    test('a falsy @model is not dropped from models', async function (assert) {
      // The acceptance test routes through a string segment, which is truthy
      // and so does not exercise `!= null`. This one hits the getter directly.
      await render(
        <template>
          <Breadcrumbs as |b|>
            <b.Item @route="breadcrumbs-demo.item" @model={{0}}>Zero</b.Item>
          </Breadcrumbs>
        </template>
      );

      assert
        .dom('[data-part="link"]')
        .hasAttribute(
          'href',
          '/breadcrumbs-demo/item/0',
          'a 0 dynamic segment survives the != null check'
        );
    });

    test('an author-placed Ellipsis renders the same li shape as a crumb', async function (assert) {
      await render(
        <template>
          <Breadcrumbs as |b|>
            <b.Item @href="/">Home</b.Item>
            <b.Ellipsis />
            <b.Item>Current</b.Item>
          </Breadcrumbs>
        </template>
      );

      assert.dom('nav ol > li').exists({ count: 3 });
      assert.dom('[data-part="ellipsis"]').exists();
      assert.dom('[data-part="ellipsis"]').hasAttribute('aria-hidden', 'true');
      assert
        .dom('[data-part="separator"]')
        .exists(
          { count: 3 },
          'the ellipsis carries a separator like any other crumb'
        );
      assert
        .dom('[data-part="ellipsis"]')
        .hasClass('select-none', 'it is a gap marker, not an affordance');
    });

    test('Ellipsis announces the gap, with and without @hiddenCount', async function (assert) {
      await render(
        <template>
          <Breadcrumbs as |b|>
            <b.Ellipsis @hiddenCount={{3}} data-test-counted />
            <b.Ellipsis data-test-uncounted />
          </Breadcrumbs>
        </template>
      );

      const items = findAll('nav ol > li');

      assert.dom(items[0]!).containsText('3 more levels');
      assert.dom(items[1]!).containsText('More levels');
    });

    test('an Ellipsis block replaces the glyph and owns the announcement', async function (assert) {
      await render(
        <template>
          <Breadcrumbs as |b|>
            <b.Ellipsis @hiddenCount={{2}} as |e|>
              <button type="button" data-test-menu>Show
                {{e.hiddenCount}}
                more</button>
            </b.Ellipsis>
          </Breadcrumbs>
        </template>
      );

      assert.dom('[data-test-menu]').exists();
      assert.dom('[data-test-menu]').hasText('Show 2 more');
      assert
        .dom('nav ol > li')
        .doesNotContainText(
          'more levels',
          'a supplied block carries its own accessible name, so a second announcement would be read twice'
        );
    });

    test('the Ellipsis block receives the crumbs it stands in for', async function (assert) {
      const hidden = [{ label: 'B' }, { label: 'C' }];

      await render(
        <template>
          <Breadcrumbs as |b|>
            <b.Ellipsis @hiddenItems={{hidden}} as |e|>
              {{#each e.hiddenItems as |item|}}
                <span data-test-hidden>{{item.label}}</span>
              {{/each}}
            </b.Ellipsis>
          </Breadcrumbs>
        </template>
      );

      assert.dom('[data-test-hidden]').exists({ count: 2 });
      assert.strictEqual(
        findAll('[data-test-hidden]')
          .map((el) => el.textContent?.trim())
          .join(' '),
        'B C'
      );
    });

    test('@classes.ellipsis reaches the Ellipsis', async function (assert) {
      await render(
        <template>
          <Breadcrumbs @classes={{hash ellipsis="custom-ellipsis"}} as |b|>
            <b.Ellipsis />
          </Breadcrumbs>
        </template>
      );

      assert.dom('[data-part="ellipsis"]').hasClass('custom-ellipsis');
    });

    const TRAIL = [
      { label: 'Home', href: '/' },
      { label: 'Library', href: '/library' },
      { label: 'Data', href: '/library/data' },
      { label: 'Reports', href: '/library/data/reports' },
      { label: 'Q3' }
    ];

    test('the @items form renders the same DOM as the equivalent block form', async function (assert) {
      await render(<template><Breadcrumbs @items={{TRAIL}} /></template>);

      assert.dom('nav ol > li').exists({ count: 5 });
      assert.dom('[data-part="separator"]').exists({ count: 5 });

      const links = findAll('[data-part="link"]');
      assert.dom(links[0]!).hasTagName('a');
      assert.dom(links[0]!).hasAttribute('href', '/');
      assert.dom(links[0]!).hasText('Home');

      assert.dom(links[4]!).hasTagName('span', 'the unlinked last crumb');
      assert.dom(links[4]!).hasAttribute('aria-current', 'page');
    });

    test('@maxItems collapses the middle of the trail', async function (assert) {
      await render(
        <template><Breadcrumbs @items={{TRAIL}} @maxItems={{3}} /></template>
      );

      assert.dom('nav ol > li').exists({ count: 3 });
      assert.dom('[data-part="ellipsis"]').exists({ count: 1 });

      const links = findAll('[data-part="link"]');
      assert.strictEqual(links.length, 2);
      assert.dom(links[0]!).hasText('Home');
      assert.dom(links[1]!).hasText('Q3');
      assert.dom('nav').containsText('3 more levels');
    });

    test('without @maxItems nothing collapses', async function (assert) {
      await render(<template><Breadcrumbs @items={{TRAIL}} /></template>);

      assert.dom('[data-part="ellipsis"]').doesNotExist();
    });

    test('@itemsBeforeCollapse and @itemsAfterCollapse move the split', async function (assert) {
      await render(
        <template>
          <Breadcrumbs
            @items={{TRAIL}}
            @maxItems={{4}}
            @itemsBeforeCollapse={{2}}
            @itemsAfterCollapse={{1}}
          />
        </template>
      );

      const links = findAll('[data-part="link"]');
      assert.strictEqual(links.length, 3);
      assert.dom(links[0]!).hasText('Home');
      assert.dom(links[1]!).hasText('Library');
      assert.dom(links[2]!).hasText('Q3');
    });

    test('only the last statically-current crumb keeps aria-current', async function (assert) {
      const ambiguous = [
        { label: 'Home', href: '/' },
        { label: 'Orphan' },
        { label: 'Current' }
      ];

      await render(<template><Breadcrumbs @items={{ambiguous}} /></template>);

      assert
        .dom('[aria-current="page"]')
        .exists(
          { count: 1 },
          'two unlinked crumbs would otherwise produce two current pages'
        );
      assert.dom('[aria-current="page"]').hasText('Current');
    });

    test('an explicit isCurrent false on an unlinked crumb is honoured', async function (assert) {
      // "Not current" is last and unlinked -- if the no-target fallback
      // ignored its explicit `isCurrent: false`, last-wins would hand it
      // `aria-current`, overriding the crumb that actually claims it.
      const optOut = [
        { label: 'Home', href: '/' },
        { label: 'Current', isCurrent: true },
        { label: 'Not current', isCurrent: false }
      ];

      await render(<template><Breadcrumbs @items={{optOut}} /></template>);

      assert.dom('[aria-current="page"]').exists({ count: 1 });
      assert.dom('[aria-current="page"]').hasText('Current');
    });

    test('the item block renders each crumb and receives the original object', async function (assert) {
      await render(
        <template>
          <Breadcrumbs @items={{TRAIL}} @maxItems={{3}}>
            <:item as |ctx|>
              <li class={{ctx.itemClass}}>
                <span
                  class={{ctx.linkClass}}
                  data-test-crumb={{ctx.index}}
                >{{ctx.item.label}}</span>
              </li>
            </:item>
          </Breadcrumbs>
        </template>
      );

      const crumbs = findAll('[data-test-crumb]');
      assert.strictEqual(crumbs.length, 2);
      assert.dom(crumbs[0]!).hasAttribute('data-test-crumb', '0');
      assert
        .dom(crumbs[1]!)
        .hasAttribute(
          'data-test-crumb',
          '4',
          'the index is the position in @items, not in the rendered list'
        );
      assert.dom(crumbs[1]!).hasText('Q3');
    });

    test('the ellipsis block reaches the auto-placed Ellipsis', async function (assert) {
      await render(
        <template>
          <Breadcrumbs @items={{TRAIL}} @maxItems={{3}}>
            <:ellipsis as |e|>
              <button type="button" data-test-menu>{{e.hiddenCount}}
                hidden</button>
            </:ellipsis>
          </Breadcrumbs>
        </template>
      );

      assert.dom('[data-test-menu]').hasText('3 hidden');
      assert.dom('nav').doesNotContainText('more levels');
    });

    test('an empty @items renders an empty list, not a broken one', async function (assert) {
      const none: { label: string }[] = [];

      await render(<template><Breadcrumbs @items={{none}} /></template>);

      assert.dom('nav ol').exists();
      assert.dom('nav ol > li').doesNotExist();
    });
  }
);
