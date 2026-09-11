import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, findAll, waitUntil } from '@ember/test-helpers';
import { TabNav } from 'frontile';

module(
  'Integration | Component | TabNav | frontile/navigation',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders a labelled nav landmark', async function (assert) {
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <a
              href="/one"
              class={{nav.itemClass}}
              {{nav.setupItem true}}
            >One</a>
          </TabNav>
        </template>
      );

      assert.dom('nav').exists('renders a nav landmark');
      assert.dom('nav').hasAria('label', 'Sections');
    });

    test('a consumer-supplied element gets aria-current, data-selected and the indicator', async function (assert) {
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <a
              href="/one"
              class={{nav.itemClass}}
              {{nav.setupItem false}}
            >One</a>
            <a
              href="/two"
              class={{nav.itemClass}}
              {{nav.setupItem true}}
            >Two</a>
          </TabNav>
        </template>
      );

      const links = findAll('nav a');
      assert.dom(links[1]!).hasAttribute('aria-current', 'page');
      assert.dom(links[1]!).hasAttribute('data-selected', 'true');
      assert.dom(links[0]!).hasAttribute('data-selected', 'false');
      assert
        .dom(links[0]!)
        .doesNotHaveAttribute(
          'aria-current',
          'inactive links carry no aria-current at all'
        );

      const nav = find('nav')!;
      await waitUntil(() => nav.hasAttribute('data-fr-si-ready'), {
        timeout: 1000
      });
      assert.strictEqual(
        nav.style.getPropertyValue('--fr-si-width'),
        `${(links[1] as HTMLElement).offsetWidth}px`,
        'the indicator measured the active link'
      );
    });

    test('the hover rule reaches a link that never declares data-disabled', async function (assert) {
      // The theme expresses "not disabled" as `not-data-[disabled=true]` rather
      // than `data-[disabled=false]`, precisely so a consumer bringing their own
      // element does not have to know the theme wants an attribute written onto
      // it. Asserting on the generated rule rather than on a written attribute
      // is what keeps that promise honest: it fails if the theme ever goes back
      // to a selector that requires the attribute to be present.
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <a
              href="/one"
              class={{nav.itemClass}}
              {{nav.setupItem false}}
            >One</a>
          </TabNav>
        </template>
      );

      const link = find('nav a') as HTMLElement;

      assert
        .dom(link)
        .doesNotHaveAttribute(
          'data-disabled',
          'setupItem no longer has to write the attribute at all'
        );

      // Tailwind wraps hover in `@media (hover: hover)` and uses CSS nesting,
      // so the selector is not on a top-level rule -- walk grouping and nested
      // rules too, or this finds nothing and passes for the wrong reason.
      const hoverSelectors: string[] = [];
      const collect = (rules: CSSRuleList): void => {
        for (const rule of Array.from(rules)) {
          const nested = (rule as CSSGroupingRule).cssRules;
          if (nested) {
            collect(nested);
          }
          const selector = (rule as CSSStyleRule).selectorText;
          if (selector && selector.includes('data-disabled')) {
            hoverSelectors.push(selector);
          }
        }
      };
      for (const sheet of Array.from(document.styleSheets)) {
        try {
          collect(sheet.cssRules);
        } catch {
          continue; // cross-origin sheet
        }
      }

      assert.ok(
        hoverSelectors.length > 0,
        `the theme emits disabled-scoped rules (${hoverSelectors.length})`
      );

      // Only the "not disabled" rules matter here; drop `:hover` and the
      // nesting `&` so the selector can be matched without a real pointer.
      const notDisabled = hoverSelectors.filter((selector) =>
        selector.includes(':not(')
      );

      assert.ok(
        notDisabled.length > 0,
        `and expresses "not disabled" as :not(...) (${notDisabled.join(' | ')})`
      );

      // Strip only the trailing `:hover` pseudo-class. A blanket replace would
      // also gut the escaped `\:hover\:` inside Tailwind's own class name and
      // leave a selector that matches nothing -- which would fail for a reason
      // that has nothing to do with the rule under test.
      const matched = notDisabled.some((selector) =>
        selector.split(',').some((part) => {
          const cleaned = part.trim().replace(/:hover$/, '');
          try {
            return cleaned !== '' && link.matches(cleaned);
          } catch {
            return false;
          }
        })
      );

      assert.true(
        matched,
        'the link matches a hover rule despite carrying no data-disabled attribute'
      );
    });

    test('every link stays in the tab order and arrow keys are not intercepted', async function (assert) {
      // The deliberate opposite of Tabs. Nav links are links: removing them
      // from the tab order or hijacking the arrow keys would be a regression.
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <a
              href="/one"
              class={{nav.itemClass}}
              {{nav.setupItem true}}
            >One</a>
            <a
              href="/two"
              class={{nav.itemClass}}
              {{nav.setupItem false}}
            >Two</a>
          </TabNav>
        </template>
      );

      for (const link of findAll('nav a')) {
        assert
          .dom(link)
          .doesNotHaveAttribute('tabindex', 'no roving tabindex is applied');
      }

      const first = findAll('nav a')[0]!;
      const event = new KeyboardEvent('keydown', {
        key: 'ArrowRight',
        bubbles: true,
        cancelable: true
      });
      first.dispatchEvent(event);

      assert.false(event.defaultPrevented, 'ArrowRight is left to the browser');
    });

    test('Item with @href renders a plain anchor and honours @isActive', async function (assert) {
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <nav.Item @href="/one" @isActive={{false}}>One</nav.Item>
            <nav.Item @href="/two" @isActive={{true}}>Two</nav.Item>
          </TabNav>
        </template>
      );

      const links = findAll('nav a');
      assert.dom(links[0]!).hasAttribute('href', '/one');
      assert.dom(links[1]!).hasAttribute('aria-current', 'page');
      assert.dom(links[1]!).hasAttribute('data-selected', 'true');
      assert.dom(links[0]!).hasAttribute('data-selected', 'false');
    });

    test('Item with @isDisabled is marked disabled and is not activatable', async function (assert) {
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <nav.Item @href="/one" @isDisabled={{true}}>One</nav.Item>
          </TabNav>
        </template>
      );

      const link = find('nav a')!;
      assert.dom(link).hasAria('disabled', 'true');
      assert.dom(link).hasAttribute('data-disabled', 'true');
      // An <a> cannot be natively disabled, so the href is dropped instead --
      // aria-disabled alone would still leave it clickable.
      assert.dom(link).doesNotHaveAttribute('href');
    });

    test('Item with @route and @isDisabled renders a plain, href-less anchor -- not a disabled LinkTo', async function (assert) {
      // `LinkTo`'s `@disabled` only short-circuits its click handler; the
      // element it renders still carries a real, middle-clickable href and an
      // un-themed "disabled" class. A disabled `@route` item must be exactly
      // as non-navigable as a disabled `@href` item.
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <nav.Item
              @route="tab-nav-demo.index"
              @isDisabled={{true}}
            >One</nav.Item>
          </TabNav>
        </template>
      );

      const link = find('nav a')!;
      assert.dom(link).hasAria('disabled', 'true');
      assert.dom(link).hasAttribute('data-disabled', 'true');
      assert.dom(link).doesNotHaveAttribute('href');
      assert
        .dom(link)
        .doesNotHaveClass(
          'disabled',
          'no stray un-themed class leaks in from LinkTo'
        );
    });

    test('Item with @route and a falsy @model reaches the dynamic segment', async function (assert) {
      // `@model={{0}}` is a legitimate dynamic segment value. A truthiness
      // check on `@model` would silently drop it, leaving `LinkTo` with no
      // model for a route that requires one.
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <nav.Item @route="tab-nav-demo.item" @model={{0}}>Item</nav.Item>
          </TabNav>
        </template>
      );

      const link = find('nav a')!;
      assert.ok(
        link.getAttribute('href')?.includes('/tab-nav-demo/item/0'),
        `href resolves the dynamic segment to 0, got: ${link.getAttribute('href')}`
      );
    });

    // TabNav is a second renderer of the shared `tabs` theme config (a
    // nav-link variant of Tabs), not a config of its own -- so its root
    // <nav> carries data-component="tabs" with data-part="list" (it plays
    // the list role directly; there is no separate base wrapper the way
    // Tabs has one), and its indicator/items carry the same
    // indicator/tab parts Tabs itself uses.
    test('renders data-component="tabs" on the root only, with data-part on every slot it renders', async function (assert) {
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <nav.Item @href="/one" @isActive={{true}}>One</nav.Item>
            <nav.Item @href="/two" @isActive={{false}}>Two</nav.Item>
          </TabNav>
        </template>
      );

      assert.dom('[data-component="tabs"]').hasAttribute('data-part', 'list');
      assert.dom('[data-component="tabs"] [data-part="indicator"]').exists();
      assert
        .dom('[data-component="tabs"] [data-part="tab"]')
        .exists({ count: 2 });
      assert.strictEqual(
        document.querySelectorAll('[data-component="tabs"]').length,
        1,
        'data-component="tabs" marks the root only, never a part'
      );
    });
  }
);
