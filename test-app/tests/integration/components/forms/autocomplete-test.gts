import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  click,
  render,
  triggerKeyEvent,
  fillIn,
  settled
} from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { Autocomplete } from 'frontile';
import { array } from '@ember/helper';
import { on } from '@ember/modifier';

module(
  'Integration | Component | Autocomplete | @frontile/forms',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders the combobox input with ARIA attributes', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];

      await render(
        <template>
          <Autocomplete @items={{items}} @placeholder="Search" />
        </template>
      );

      assert.dom('[data-component="autocomplete-trigger"]').exists();
      assert
        .dom('[data-component="autocomplete-trigger"]')
        .hasAttribute('role', 'combobox');
      assert
        .dom('[data-component="autocomplete-trigger"]')
        .hasAttribute('aria-autocomplete', 'list');
      assert
        .dom('[data-component="autocomplete-trigger"]')
        .hasAttribute('aria-expanded', 'false');
      assert
        .dom('[data-component="autocomplete-trigger"]')
        .hasAttribute('placeholder', 'Search');
    });

    test('it opens on click and renders items', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];

      await render(<template><Autocomplete @items={{items}} /></template>);

      await click('[data-component="autocomplete-trigger"]');

      assert.dom('[data-component="listbox"]').exists();
      assert.dom('[data-key="Apple"]').exists();
      assert.dom('[data-key="Banana"]').exists();
      assert.dom('[data-key="Cherry"]').exists();
      assert
        .dom('[data-component="autocomplete-trigger"]')
        .hasAttribute('aria-expanded', 'true');
    });

    test('typing filters the options and opens the dropdown', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];

      await render(<template><Autocomplete @items={{items}} /></template>);

      await fillIn('[data-test-id="trigger"]', 'App');

      assert.dom('[data-component="listbox"]').exists('typing opens dropdown');
      assert.dom('[data-key="Apple"]').exists();
      assert.dom('[data-key="Banana"]').doesNotExist();
      assert.dom('[data-key="Cherry"]').doesNotExist();

      await fillIn('[data-test-id="trigger"]', 'an');
      assert.dom('[data-key="Apple"]').doesNotExist();
      assert.dom('[data-key="Banana"]').exists();
    });

    test('it supports a custom filter function', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];
      const startsWith = (itemValue: string, inputValue: string) =>
        itemValue.toLowerCase().startsWith(inputValue.toLowerCase());

      await render(
        <template>
          <Autocomplete @items={{items}} @filter={{startsWith}} />
        </template>
      );

      await fillIn('[data-test-id="trigger"]', 'an');
      assert.dom('[data-key="Banana"]').doesNotExist('contains does not apply');
      assert.dom('[data-test-id="empty-content"]').exists();

      await fillIn('[data-test-id="trigger"]', 'ba');
      assert.dom('[data-key="Banana"]').exists();
    });

    test('selecting an option fills the input, closes the dropdown and calls onSelectionChange', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];
      const selectedKey = cell<string | null>(null);
      const onSelectionChange = (key: string | null) =>
        (selectedKey.current = key);

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @selectedKey={{selectedKey.current}}
            @onSelectionChange={{onSelectionChange}}
          />
        </template>
      );

      await fillIn('[data-test-id="trigger"]', 'Ban');
      await click('[data-component="listbox"] [data-key="Banana"]');

      assert.equal(selectedKey.current, 'Banana');
      assert.dom('[data-component="listbox"]').doesNotExist('dropdown closed');
      assert.dom('[data-test-id="trigger"]').hasValue('Banana');
    });

    test('keyboard navigation: arrows + Enter select the active option', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];
      const selectedKey = cell<string | null>(null);
      const onSelectionChange = (key: string | null) =>
        (selectedKey.current = key);

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @selectedKey={{selectedKey.current}}
            @onSelectionChange={{onSelectionChange}}
          />
        </template>
      );

      await fillIn('[data-test-id="trigger"]', 'a');
      assert.dom('[data-component="listbox"]').exists();

      // First matching option is auto-activated when filtering
      assert
        .dom('[data-component="listbox"] [data-key="Apple"]')
        .hasAttribute('data-active', 'true');
      assert
        .dom('[data-test-id="trigger"]')
        .hasAttribute('aria-activedescendant');

      await triggerKeyEvent('[data-test-id="trigger"]', 'keydown', 'ArrowDown');
      assert
        .dom('[data-component="listbox"] [data-key="Banana"]')
        .hasAttribute('data-active', 'true');

      await triggerKeyEvent('[data-test-id="trigger"]', 'keydown', 'Enter');

      assert.equal(selectedKey.current, 'Banana');
      assert.dom('[data-component="listbox"]').doesNotExist();
      assert.dom('[data-test-id="trigger"]').hasValue('Banana');
    });

    test('input reverts to the selected label when closed without selection', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];
      const selectedKey = cell<string | null>('Cherry');
      const onSelectionChange = (key: string | null) =>
        (selectedKey.current = key);

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @selectedKey={{selectedKey.current}}
            @onSelectionChange={{onSelectionChange}}
          />
          <div data-test-id="outside">outside</div>
        </template>
      );

      await fillIn('[data-test-id="trigger"]', 'Cher');
      assert.dom('[data-test-id="trigger"]').hasValue('Cher');

      await click('[data-test-id="outside"]');

      assert.dom('[data-component="listbox"]').doesNotExist();
      assert.dom('[data-test-id="trigger"]').hasValue('Cherry');
      assert.equal(selectedKey.current, 'Cherry', 'selection unchanged');
    });

    test('allowsCustomValue keeps the typed text when closed', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];
      const inputValue = cell<string>('');
      const onInputChange = (value: string) => (inputValue.current = value);

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @allowsCustomValue={{true}}
            @onInputChange={{onInputChange}}
          />
          <div data-test-id="outside">outside</div>
        </template>
      );

      await fillIn('[data-test-id="trigger"]', 'Dragonfruit');
      await click('[data-test-id="outside"]');

      assert.dom('[data-test-id="trigger"]').hasValue('Dragonfruit');
      assert.equal(inputValue.current, 'Dragonfruit');
    });

    test('onInputChange is called as the user types', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];
      const values: string[] = [];
      const onInputChange = (value: string) => values.push(value);

      await render(
        <template>
          <Autocomplete @items={{items}} @onInputChange={{onInputChange}} />
        </template>
      );

      await fillIn('[data-test-id="trigger"]', 'Ap');
      assert.deepEqual(values, ['Ap']);
    });

    test('disableFiltering renders items as-is', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];

      await render(
        <template>
          <Autocomplete @items={{items}} @disableFiltering={{true}} />
        </template>
      );

      await fillIn('[data-test-id="trigger"]', 'XYZ');

      assert.dom('[data-key="Apple"]').exists();
      assert.dom('[data-key="Banana"]').exists();
      assert.dom('[data-key="Cherry"]').exists();
    });

    test('onSearch resolves items asynchronously and shows loading spinner', async function (assert) {
      const fruits = ['Apple', 'Banana', 'Cherry', 'Dragonfruit'];
      let resolveSearch: (items: string[]) => void = () => {};
      const onSearch = (query: string) => {
        assert.step(`search:${query}`);
        return new Promise<string[]>((resolve) => {
          resolveSearch = resolve;
        });
      };

      await render(
        <template>
          <Autocomplete @onSearch={{onSearch}} @searchDebounce={{0}} />
        </template>
      );

      void fillIn('[data-test-id="trigger"]', 'fr');
      await new Promise((resolve) => setTimeout(resolve, 50));

      assert.dom('[data-test-id="loading-spinner"]').exists('spinner pending');

      resolveSearch(fruits.filter((f) => f.toLowerCase().includes('fr')));
      await settled();

      assert.dom('[data-test-id="loading-spinner"]').doesNotExist();
      assert.dom('[data-key="Dragonfruit"]').exists();
      assert.dom('[data-key="Apple"]').doesNotExist();
      assert.verifySteps(['search:fr']);
    });

    test('keyboard navigation follows DOM order after an async search replaces results', async function (assert) {
      // Faithful shape of an address search: each response builds fresh
      // objects, one previously-matching address is still present, and closer
      // matches are returned before it.
      const addresses = [
        '120 Main St',
        '121 Main St',
        '122 Main St',
        '123 Main St',
        '124 Main St',
        '125 Main St'
      ];

      // First response only has the later entry; the second has everything.
      const onSearch = (query: string) =>
        (query.length > 3 ? addresses : ['123 Main St']).map((label) => ({
          key: label,
          label
        }));

      await render(
        <template>
          <Autocomplete @onSearch={{onSearch}} @searchDebounce={{0}} />
        </template>
      );

      await fillIn('[data-test-id="trigger"]', 'Main');

      await fillIn('[data-test-id="trigger"]', 'Main St');

      const domOrder = [
        ...document.querySelectorAll(
          '[data-component="listbox"] [data-component="listbox-item"]'
        )
      ].map((el) => (el as HTMLElement).dataset['key']);
      assert.deepEqual(domOrder, addresses, 'DOM order matches the response');

      const visited: (string | undefined)[] = [];
      for (let i = 0; i < addresses.length - 1; i++) {
        await triggerKeyEvent(
          '[data-test-id="trigger"]',
          'keydown',
          'ArrowDown'
        );
        visited.push(
          (
            document.querySelector(
              '[data-component="listbox"] [data-component="listbox-item"][data-active="true"]'
            ) as HTMLElement | null
          )?.dataset['key']
        );
      }

      assert.deepEqual(
        visited,
        addresses.slice(1),
        'ArrowDown walks down the list in DOM order'
      );
    });

    test('onSearch: stale responses are ignored (latest wins)', async function (assert) {
      const resolvers: { query: string; resolve: (i: string[]) => void }[] = [];
      const onSearch = (query: string) =>
        new Promise<string[]>((resolve) => {
          resolvers.push({ query, resolve });
        });

      await render(
        <template>
          <Autocomplete @onSearch={{onSearch}} @searchDebounce={{0}} />
        </template>
      );

      void fillIn('[data-test-id="trigger"]', 'a');
      await new Promise((resolve) => setTimeout(resolve, 20));
      void fillIn('[data-test-id="trigger"]', 'ab');
      await new Promise((resolve) => setTimeout(resolve, 20));

      assert.equal(resolvers.length, 2, 'two searches fired');

      // Resolve out of order: latest first, then the stale one
      resolvers[1]?.resolve(['Fresh']);
      await settled();
      resolvers[0]?.resolve(['Stale']);
      await settled();

      assert.dom('[data-key="Fresh"]').exists();
      assert.dom('[data-key="Stale"]').doesNotExist();
    });

    test('searchMessage prompts on blank async query and hides while typing', async function (assert) {
      const onSearch = (query: string) =>
        ['Apple', 'Banana'].filter((f) =>
          f.toLowerCase().includes(query.toLowerCase())
        );

      await render(
        <template>
          <Autocomplete
            @onSearch={{onSearch}}
            @searchDebounce={{0}}
            @searchMessage="Type to search for a fruit..."
          />
        </template>
      );

      await click('[data-component="autocomplete-trigger"]');

      assert
        .dom('[data-test-id="search-message"]')
        .hasText('Type to search for a fruit...');
      assert.dom('[data-test-id="empty-content"]').doesNotExist();

      await fillIn('[data-test-id="trigger"]', 'app');

      assert.dom('[data-test-id="search-message"]').doesNotExist();
      assert.dom('[data-component="listbox"] [data-key="Apple"]').exists();

      await fillIn('[data-test-id="trigger"]', '');

      assert
        .dom('[data-test-id="search-message"]')
        .hasText('Type to search for a fruit...');
    });

    test('searchMessage block takes priority; no message renders nothing on blank query', async function (assert) {
      const onSearch = () => ['Apple'];

      await render(
        <template>
          <Autocomplete @onSearch={{onSearch}} @searchDebounce={{0}}>
            <:searchMessage>Start typing to see suggestions</:searchMessage>
          </Autocomplete>
        </template>
      );

      await click('[data-component="autocomplete-trigger"]');
      assert
        .dom('[data-test-id="search-message"]')
        .hasText('Start typing to see suggestions');

      await render(
        <template>
          <Autocomplete @onSearch={{onSearch}} @searchDebounce={{0}} />
        </template>
      );

      await click('[data-component="autocomplete-trigger"]');
      assert.dom('[data-test-id="search-message"]').doesNotExist();
    });

    test('searchMessage is not shown when default items are displayed', async function (assert) {
      const items = ['Apple', 'Banana'];
      const onSearch = () => items;

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @onSearch={{onSearch}}
            @searchDebounce={{0}}
            @searchMessage="Type to search..."
          />
        </template>
      );

      await click('[data-component="autocomplete-trigger"]');

      assert.dom('[data-test-id="search-message"]').doesNotExist();
      assert.dom('[data-component="listbox"] [data-key="Apple"]').exists();
    });

    test('onSearch: blank query restores default items without searching', async function (assert) {
      const items = ['Default 1', 'Default 2'];
      const searches: string[] = [];
      const onSearch = (query: string) => {
        searches.push(query);
        return ['Result'];
      };

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @onSearch={{onSearch}}
            @searchDebounce={{0}}
          />
        </template>
      );

      await fillIn('[data-test-id="trigger"]', 'r');

      assert.dom('[data-key="Result"]').exists();

      await fillIn('[data-test-id="trigger"]', '');

      assert.deepEqual(searches, ['r'], 'blank query did not trigger search');
      assert.dom('[data-key="Default 1"]').exists();
      assert.dom('[data-key="Default 2"]').exists();
    });

    test('clear button clears selection and input text', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];
      const selectedKey = cell<string | null>('Apple');
      const onSelectionChange = (key: string | null) =>
        (selectedKey.current = key);

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @isClearable={{true}}
            @selectedKey={{selectedKey.current}}
            @onSelectionChange={{onSelectionChange}}
          />
        </template>
      );

      assert.dom('[data-test-id="trigger"]').hasValue('Apple');
      assert.dom('[data-test-id="input-clear-button"]').exists();

      await click('[data-test-id="input-clear-button"]');

      assert.equal(selectedKey.current, null);
      assert.dom('[data-test-id="trigger"]').hasValue('');
    });

    test('it renders disabled input', async function (assert) {
      const items = ['Apple'];

      await render(
        <template>
          <Autocomplete @items={{items}} @isDisabled={{true}} />
        </template>
      );

      assert.dom('[data-test-id="trigger"]').isDisabled();
    });

    test('it respects disabledKeys', async function (assert) {
      const items = ['Apple', 'Banana'];
      const selectedKey = cell<string | null>(null);
      const onSelectionChange = (key: string | null) =>
        (selectedKey.current = key);

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @disabledKeys={{array "Banana"}}
            @selectedKey={{selectedKey.current}}
            @onSelectionChange={{onSelectionChange}}
          />
        </template>
      );

      await click('[data-component="autocomplete-trigger"]');
      await click('[data-component="listbox"] [data-key="Banana"]');

      assert.equal(selectedKey.current, null, 'disabled item not selectable');
    });

    test('it shows empty content when nothing matches; hideEmptyContent hides it', async function (assert) {
      const items = ['Apple'];

      await render(<template><Autocomplete @items={{items}} /></template>);
      await fillIn('[data-test-id="trigger"]', 'XYZ');

      assert.dom('[data-test-id="empty-content"]').exists();
      assert.dom('[data-test-id="empty-content"]').hasText('No results found.');

      await render(
        <template>
          <Autocomplete @items={{items}}>
            <:emptyContent>Nothing here.</:emptyContent>
          </Autocomplete>
        </template>
      );
      await fillIn('[data-test-id="trigger"]', 'XYZ');
      assert.dom('[data-test-id="empty-content"]').hasText('Nothing here.');

      await render(
        <template>
          <Autocomplete @items={{items}} @hideEmptyContent={{true}} />
        </template>
      );
      await fillIn('[data-test-id="trigger"]', 'XYZ');
      assert.dom('[data-test-id="empty-content"]').doesNotExist();
    });

    test('it renders custom items with the item block', async function (assert) {
      const items = [
        { key: 'apple', label: 'Apple', description: 'A fruit' },
        { key: 'banana', label: 'Banana', description: 'Also a fruit' }
      ];

      await render(
        <template>
          <Autocomplete @items={{items}}>
            <:item as |l|>
              <l.Item @key={{l.key}} @description="custom description">
                {{l.label}}
              </l.Item>
            </:item>
          </Autocomplete>
        </template>
      );

      await click('[data-component="autocomplete-trigger"]');

      assert.dom('[data-component="listbox"] [data-key="apple"]').exists();
      assert
        .dom('[data-component="listbox"] [data-key="apple"]')
        .containsText('Apple');
      assert
        .dom('[data-component="listbox"] [data-key="apple"]')
        .containsText('custom description');
    });

    test('external @selectedKey changes update the input value', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];
      const selectedKey = cell<string | null>(null);
      const onSelectionChange = (key: string | null) =>
        (selectedKey.current = key);

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @selectedKey={{selectedKey.current}}
            @onSelectionChange={{onSelectionChange}}
          />
        </template>
      );

      assert.dom('[data-test-id="trigger"]').hasValue('');

      selectedKey.current = 'Cherry';
      await settled();

      assert.dom('[data-test-id="trigger"]').hasValue('Cherry');
    });

    test('hidden native select is rendered for form submission', async function (assert) {
      const items = ['Apple', 'Banana'];

      await render(
        <template><Autocomplete @items={{items}} @name="fruit" /></template>
      );

      assert.dom('[data-component="native-select"]').exists();
      assert
        .dom('[data-component="native-select"]')
        .hasAttribute('name', 'fruit');
    });

    test('Enter does not submit a wrapping form while the dropdown is open', async function (assert) {
      const items = ['Apple', 'Banana'];
      let submitted = 0;
      const onSubmit = (event: Event) => {
        event.preventDefault();
        submitted++;
      };

      await render(
        <template>
          {{! template-lint-disable require-input-label }}
          <form {{on "submit" onSubmit}}>
            <Autocomplete @items={{items}} />
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await fillIn('[data-test-id="trigger"]', 'App');
      await triggerKeyEvent('[data-test-id="trigger"]', 'keydown', 'Enter');

      assert.equal(submitted, 0, 'form not submitted');
      assert.dom('[data-test-id="trigger"]').hasValue('Apple');
    });

    test('it renders named blocks startContent and endContent', async function (assert) {
      const items = ['Apple'];
      const classes = { innerContainer: 'input-container' };

      await render(
        <template>
          <Autocomplete @items={{items}} @classes={{classes}}>
            <:startContent>Start</:startContent>
            <:endContent>End</:endContent>
          </Autocomplete>
        </template>
      );

      assert
        .dom('.input-container [data-test-id="input-start-content"]')
        .containsText('Start');
      assert
        .dom('.input-container [data-test-id="input-end-content"]')
        .containsText('End');
    });

    test('it shows loading spinner when isLoading is true', async function (assert) {
      const items = ['Apple'];

      await render(
        <template>
          <Autocomplete @items={{items}} @isLoading={{true}} />
        </template>
      );

      assert.dom('[data-test-id="loading-spinner"]').exists();
    });

    /**
     * Guard, not a regression repro. Autocomplete pins the listbox to
     * `@selectionMode="single"`, and single mode replaces the selection
     * outright rather than rebuilding it from the rendered items, so it never
     * hit the ListManager bug that Select and Listbox did. This test exists to
     * keep the shared fix from changing Autocomplete's behaviour: selecting a
     * filtered option must still yield exactly that one key.
     */
    test('selecting a filtered option replaces the selection, filtered-out items and all', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];
      const selectedKey = cell<string | null>('Apple');
      const onSelectionChange = (key: string | null) => {
        selectedKey.current = key;
      };

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @selectedKey={{selectedKey.current}}
            @onSelectionChange={{onSelectionChange}}
          />
        </template>
      );

      await click('[data-component="autocomplete-trigger"]');
      await fillIn('[data-component="autocomplete-trigger"]', 'Cherry');

      assert
        .dom('[data-component="listbox"] [data-key="Apple"]')
        .doesNotExist('the previously selected option is filtered out');

      await click('[data-component="listbox"] [data-key="Cherry"]');

      assert.strictEqual(
        selectedKey.current,
        'Cherry',
        'single selection still replaces, it does not accumulate the filtered-out key'
      );
    });
    // -----------------------------------------------------------------------
    // @onBlur
    //
    // Same contract as Select: `@onBlur` reports focus leaving the control,
    // not an option being picked. The trigger blurs on the way into the
    // dropdown, so a selection must not be reported as a blur.
    // -----------------------------------------------------------------------

    test('@onBlur is not called when selecting an option', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];
      const selectedKey = cell<string | null>(null);
      const onSelectionChange = (key: string | null) =>
        (selectedKey.current = key);
      let blurCount = 0;
      const onBlur = () => blurCount++;

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @selectedKey={{selectedKey.current}}
            @onSelectionChange={{onSelectionChange}}
            @onBlur={{onBlur}}
          />
        </template>
      );

      await fillIn('[data-test-id="trigger"]', 'Ban');
      await click('[data-component="listbox"] [data-key="Banana"]');

      assert.strictEqual(selectedKey.current, 'Banana');
      assert.strictEqual(
        blurCount,
        0,
        'picking an option is not focus leaving the control'
      );
    });

    test('@onBlur is not called while the dropdown is open', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];
      let blurCount = 0;
      const onBlur = () => blurCount++;

      await render(
        <template>
          <Autocomplete @items={{items}} @onBlur={{onBlur}} />
        </template>
      );

      await click('[data-test-id="trigger"]');
      await fillIn('[data-test-id="trigger"]', 'a');

      assert.dom('[data-component="listbox"]').exists();
      assert.strictEqual(blurCount, 0, 'still interacting with the control');
    });

    test('@onBlur is called exactly once when focus leaves the control', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];
      const selectedKey = cell<string | null>(null);
      const onSelectionChange = (key: string | null) =>
        (selectedKey.current = key);
      let blurCount = 0;
      const onBlur = () => blurCount++;

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @selectedKey={{selectedKey.current}}
            @onSelectionChange={{onSelectionChange}}
            @onBlur={{onBlur}}
          />
          <button type="button" data-test-id="outside">Outside</button>
        </template>
      );

      await click('[data-test-id="trigger"]');
      await click('[data-component="listbox"] [data-key="Apple"]');
      assert.strictEqual(blurCount, 0, 'selecting is not blurring');

      await click('[data-test-id="outside"]');

      assert.strictEqual(blurCount, 1, 'leaving the control reported one blur');
    });

    test('tearing the Autocomplete down right after a selection neither calls @onBlur nor asserts', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry'];
      const isRendered = cell<boolean>(true);
      let blurCount = 0;
      const onBlur = () => blurCount++;
      const onSelectionChange = (_key: string | null) => {
        isRendered.current = false;
      };

      await render(
        <template>
          {{#if isRendered.current}}
            <Autocomplete
              @items={{items}}
              @onSelectionChange={{onSelectionChange}}
              @onBlur={{onBlur}}
            />
          {{/if}}
        </template>
      );

      await click('[data-test-id="trigger"]');
      await click('[data-component="listbox"] [data-key="Apple"]');

      assert.dom('[data-test-id="trigger"]').doesNotExist('torn down');
      assert.strictEqual(
        blurCount,
        0,
        'no callback fires after the component is gone'
      );
    });

    test('@isClearable clears even with @allowEmpty false, and never renders disabled', async function (assert) {
      const items = ['Apple', 'Banana'];
      const selectedKey = cell<string | null>('Apple');
      const isDisabled = cell<boolean>(false);
      const onSelectionChange = (key: string | null) =>
        (selectedKey.current = key);

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @allowEmpty={{false}}
            @isClearable={{true}}
            @isDisabled={{isDisabled.current}}
            @selectedKey={{selectedKey.current}}
            @onSelectionChange={{onSelectionChange}}
          />
        </template>
      );

      assert.dom('[data-test-id="input-clear-button"]').exists();

      isDisabled.current = true;
      await settled();

      assert
        .dom('[data-test-id="input-clear-button"]')
        .doesNotExist(
          'a disabled control cannot be cleared, so no dead button'
        );

      isDisabled.current = false;
      await settled();

      await click('[data-test-id="input-clear-button"]');

      assert.strictEqual(
        selectedKey.current,
        null,
        '@isClearable is documented to override @allowEmpty'
      );
    });
  }
);
