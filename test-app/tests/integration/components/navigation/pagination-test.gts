import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, findAll, find } from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { Pagination } from 'frontile';

/** The text of every page chip, in order, so a row reads as `['1','2','…']`. */
function chips(): string[] {
  return findAll('[data-test-page]').map((el) => el.textContent!.trim());
}

class ControlledState {
  @tracked page = 2;
}

module(
  'Integration | Component | Pagination | frontile/navigation',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders a labelled nav landmark with a default label', async function (assert) {
      await render(<template><Pagination @total={{50}} /></template>);

      assert.dom('nav').exists('renders a nav landmark');
      assert.dom('nav').hasAria('label', 'pagination');
    });

    test('@label overrides the landmark name', async function (assert) {
      await render(
        <template>
          <Pagination @total={{50}} @label="Search results" />
        </template>
      );

      assert.dom('nav').hasAria('label', 'Search results');
    });

    test('it derives the page count from @total and @pageSize', async function (assert) {
      await render(
        <template><Pagination @total={{50}} @pageSize={{10}} /></template>
      );

      assert.deepEqual(chips(), ['1', '2', '3', '4', '5']);
    });

    test('@total of 0 still renders a single page', async function (assert) {
      await render(<template><Pagination @total={{0}} /></template>);

      assert.deepEqual(chips(), ['1']);
    });

    test('the active chip carries aria-current and nothing else does', async function (assert) {
      await render(
        <template><Pagination @total={{50}} @defaultPage={{3}} /></template>
      );

      const active = findAll('[aria-current="page"]');
      assert.strictEqual(active.length, 1, 'exactly one chip is current');
      assert.dom(active[0]!).hasText('3');
      assert.dom(active[0]!).hasAttribute('data-active', 'true');
    });

    test('uncontrolled: clicking a chip moves the page and still calls @onChange', async function (assert) {
      const calls: number[] = [];
      const onChange = (page: number): void => {
        calls.push(page);
      };

      await render(
        <template><Pagination @total={{50}} @onChange={{onChange}} /></template>
      );

      await click('[data-test-page="4"]');

      assert.dom('[aria-current="page"]').hasText('4', 'the row moved itself');
      assert.deepEqual(calls, [4], 'and reported the new page');
    });

    test('controlled: the rendered page only ever reflects @page', async function (assert) {
      const calls: number[] = [];
      const state = new ControlledState();
      const onChange = (page: number): void => {
        calls.push(page);
      };

      await render(
        <template>
          <Pagination
            @total={{50}}
            @page={{state.page}}
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-test-page="4"]');

      assert
        .dom('[aria-current="page"]')
        .hasText('2', 'ignored until the owner updates');
      assert.deepEqual(calls, [4], 'but the intent was reported');

      state.page = 4;
      await render(
        <template>
          <Pagination
            @total={{50}}
            @page={{state.page}}
            @onChange={{onChange}}
          />
        </template>
      );

      assert.dom('[aria-current="page"]').hasText('4');
    });

    test('controlled mode ignores @defaultPage', async function (assert) {
      await render(
        <template>
          <Pagination @total={{50}} @page={{2}} @defaultPage={{5}} />
        </template>
      );

      assert.dom('[aria-current="page"]').hasText('2');
    });

    test('previous is disabled on the first page, next on the last', async function (assert) {
      await render(<template><Pagination @total={{30}} /></template>);

      assert.dom('[data-test-prev]').isDisabled();
      assert.dom('[data-test-next]').isNotDisabled();

      await click('[data-test-page="3"]');

      assert.dom('[data-test-prev]').isNotDisabled();
      assert.dom('[data-test-next]').isDisabled();
    });

    test('previous and next step by one', async function (assert) {
      await render(
        <template><Pagination @total={{50}} @defaultPage={{3}} /></template>
      );

      await click('[data-test-next]');
      assert.dom('[aria-current="page"]').hasText('4');

      await click('[data-test-prev]');
      assert.dom('[aria-current="page"]').hasText('3');
    });

    test('@onChange is not called when the page would not change', async function (assert) {
      let calls = 0;
      const onChange = (): void => {
        calls += 1;
      };

      await render(
        <template>
          <Pagination @total={{50}} @defaultPage={{2}} @onChange={{onChange}} />
        </template>
      );

      await click('[data-test-page="2"]');

      assert.strictEqual(calls, 0, 'clicking the current page is a no-op');
    });

    test('an out-of-range @page is clamped rather than rendering a broken row', async function (assert) {
      await render(
        <template><Pagination @total={{30}} @page={{99}} /></template>
      );

      assert
        .dom('[aria-current="page"]')
        .hasText('3', 'clamped to the last page');
    });

    test('a @pageSize below 1 is treated as 1', async function (assert) {
      await render(
        <template><Pagination @total={{3}} @pageSize={{0}} /></template>
      );

      assert.deepEqual(chips(), ['1', '2', '3'], 'three items, one per page');
    });

    test('the summary reports zeroes when @total is negative', async function (assert) {
      await render(
        <template>
          <Pagination @total={{-5}}>
            <:summary as |s|>{{s.from}}-{{s.to}} of {{s.total}}</:summary>
          </Pagination>
        </template>
      );

      assert
        .dom('nav')
        .containsText('0-0 of 0', 'negative total behaves like zero');
    });

    test('a @siblingCount below 0 is treated as 0', async function (assert) {
      await render(
        <template>
          <Pagination
            @total={{120}}
            @pageSize={{10}}
            @page={{6}}
            @siblingCount={{-2}}
          />
        </template>
      );

      assert.deepEqual(
        chips(),
        ['1', '6', '12'],
        'negative siblingCount behaves like 0'
      );
    });

    test('a @page below 1 clamps up to the first page', async function (assert) {
      await render(
        <template><Pagination @total={{30}} @page={{-5}} /></template>
      );

      assert
        .dom('[aria-current="page"]')
        .hasText('1', 'negative page clamped up to the first page');
    });

    test('the ellipsis is hidden from assistive tech but announced as more pages', async function (assert) {
      await render(<template><Pagination @total={{200}} /></template>);

      assert.dom('[data-test-ellipsis]').hasAttribute('aria-hidden', 'true');
      assert.dom('[data-test-ellipsis]').hasText('…');
      assert
        .dom('.sr-only')
        .hasText('More pages', 'screen readers still get a name for the gap');
    });

    test('every control has an accessible name', async function (assert) {
      await render(
        <template><Pagination @total={{50}} @defaultPage={{2}} /></template>
      );

      assert.dom('[data-test-prev]').hasAria('label', 'Go to previous page');
      assert.dom('[data-test-next]').hasAria('label', 'Go to next page');
      assert.dom('[data-test-page="3"]').hasAria('label', 'Go to page 3');
    });

    test('@showEdges renders first and last controls, disabled at the boundaries', async function (assert) {
      await render(
        <template><Pagination @total={{200}} @showEdges={{true}} /></template>
      );

      assert.dom('[data-test-first]').exists();
      assert.dom('[data-test-first]').hasAria('label', 'Go to first page');
      assert.dom('[data-test-first]').isDisabled();
      assert.dom('[data-test-last]').hasAria('label', 'Go to last page');
      assert.dom('[data-test-last]').isNotDisabled();

      await click('[data-test-last]');

      assert.dom('[aria-current="page"]').hasText('20');
      assert.dom('[data-test-last]').isDisabled();
    });

    test('edge controls are absent by default', async function (assert) {
      await render(<template><Pagination @total={{200}} /></template>);

      assert.dom('[data-test-first]').doesNotExist();
      assert.dom('[data-test-last]').doesNotExist();
    });

    test('@showPages={{false}} leaves only previous and next', async function (assert) {
      await render(
        <template><Pagination @total={{50}} @showPages={{false}} /></template>
      );

      assert.deepEqual(chips(), [], 'no page chips');
      assert.dom('[data-test-prev]').exists();
      assert.dom('[data-test-next]').exists();
    });

    test('@isDisabled disables every control', async function (assert) {
      await render(
        <template>
          <Pagination
            @total={{50}}
            @defaultPage={{3}}
            @showEdges={{true}}
            @isDisabled={{true}}
          />
        </template>
      );

      for (const button of findAll('nav button')) {
        assert.dom(button).isDisabled();
      }
    });

    test('the summary block receives the current item range', async function (assert) {
      await render(
        <template>
          <Pagination @total={{120}} @pageSize={{10}} @defaultPage={{2}}>
            <:summary as |s|>
              Showing
              {{s.from}}-{{s.to}}
              of
              {{s.total}}
              ({{s.page}}/{{s.totalPages}})
            </:summary>
          </Pagination>
        </template>
      );

      assert.dom('nav').containsText('Showing 11-20 of 120 (2/12)');
    });

    test('the summary clamps to the total on a partial final page', async function (assert) {
      await render(
        <template>
          <Pagination @total={{118}} @pageSize={{10}} @page={{12}}>
            <:summary as |s|>{{s.from}}-{{s.to}} of {{s.total}}</:summary>
          </Pagination>
        </template>
      );

      assert.dom('nav').containsText('111-118 of 118');
    });

    test('the summary reports zeroes when there is nothing to page', async function (assert) {
      await render(
        <template>
          <Pagination @total={{0}}>
            <:summary as |s|>{{s.from}}-{{s.to}} of {{s.total}}</:summary>
          </Pagination>
        </template>
      );

      assert.dom('nav').containsText('0-0 of 0');
    });

    test('the summary element is marked so the row can justify around it', async function (assert) {
      await render(
        <template>
          <Pagination @total={{50}}>
            <:summary as |s|>{{s.total}} results</:summary>
          </Pagination>
        </template>
      );

      assert
        .dom('[data-pagination-summary]')
        .exists(
          'the summary carries the hook the theme keys its :has() rule off'
        );
    });

    test('no summary element is rendered without the block', async function (assert) {
      await render(<template><Pagination @total={{50}} /></template>);

      assert
        .dom('[data-pagination-summary]')
        .doesNotExist(
          'nothing for the :has() rule to match, so the row stays centred'
        );
    });

    test('the item block replaces the chips and setupItem writes the ARIA', async function (assert) {
      await render(
        <template>
          <Pagination @total={{50}} @defaultPage={{2}}>
            <:item as |i|>
              <a
                href="/results?page={{i.page}}"
                class={{i.classNames}}
                {{i.setupItem i.isActive}}
              >
                {{i.page}}
              </a>
            </:item>
          </Pagination>
        </template>
      );

      const links = findAll('nav a');
      assert.strictEqual(links.length, 5, 'one link per page');
      assert.dom(links[1]!).hasAttribute('aria-current', 'page');
      assert.dom(links[1]!).hasAttribute('data-active', 'true');
      assert.dom(links[0]!).hasAttribute('data-active', 'false');
      assert
        .dom(links[0]!)
        .doesNotHaveAttribute(
          'aria-current',
          'inactive links carry none at all'
        );
      assert.dom(links[0]!).hasAttribute('href', '/results?page=1');
    });

    test('splattributes and @classes reach the nav', async function (assert) {
      await render(
        <template>
          <Pagination
            @total={{50}}
            @classes={{hash base="custom-base"}}
            data-test-custom
          />
        </template>
      );

      assert.dom('nav').hasAttribute('data-test-custom');
      assert.dom('nav').hasClass('custom-base');
    });

    test('every control is individually tabbable', async function (assert) {
      await render(
        <template><Pagination @total={{50}} @defaultPage={{3}} /></template>
      );

      const buttons = findAll('nav button');
      assert.ok(buttons.length > 1);

      for (const button of buttons) {
        assert
          .dom(button)
          .doesNotHaveAttribute(
            'tabindex',
            'no roving focus: these are navigation targets, each reachable by Tab'
          );
      }

      assert.ok(find('nav ul'), 'the controls sit in a list');
    });

    test('renders data-component="pagination" on the root only, with data-part on every slot', async function (assert) {
      await render(
        <template>
          <Pagination @total={{120}} @defaultPage={{2}} @showEdges={{true}}>
            <:summary as |s|>{{s.from}}-{{s.to}}</:summary>
          </Pagination>
        </template>
      );

      assert
        .dom('[data-component="pagination"]')
        .hasAttribute('data-part', 'base');
      assert
        .dom('[data-component="pagination"] [data-part="summary"]')
        .exists();
      assert.dom('[data-component="pagination"] [data-part="list"]').exists();
      assert.dom('[data-component="pagination"] [data-part="item"]').exists();
      assert.dom('[data-component="pagination"] [data-part="page"]').exists();
      assert.dom('[data-component="pagination"] [data-part="prev"]').exists();
      assert.dom('[data-component="pagination"] [data-part="next"]').exists();
      assert.strictEqual(
        document.querySelectorAll('[data-component="pagination"]').length,
        1,
        'data-component="pagination" marks the root only, never a part'
      );
    });

    test('renders data-part="ellipsis" on the gap marker', async function (assert) {
      await render(
        <template>
          <Pagination @total={{200}} @defaultPage={{10}} @siblingCount={{0}} />
        </template>
      );

      assert
        .dom('[data-component="pagination"] [data-part="ellipsis"]')
        .exists();
    });
  }
);
