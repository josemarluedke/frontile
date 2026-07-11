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

    test('multiple selection keeps the dropdown open and typed text', async function (assert) {
      const items = ['Apple', 'Banana', 'Cherry', 'Blackberry'];
      const selectedKeys = cell<string[]>([]);
      const onSelectionChange = (keys: string[]) =>
        (selectedKeys.current = keys);

      await render(
        <template>
          <Autocomplete
            @items={{items}}
            @selectionMode="multiple"
            @selectedKeys={{selectedKeys.current}}
            @onSelectionChange={{onSelectionChange}}
          />
        </template>
      );

      await fillIn('[data-test-id="trigger"]', 'b');
      await click('[data-component="listbox"] [data-key="Banana"]');

      assert.dom('[data-component="listbox"]').exists('dropdown stays open');
      assert.deepEqual(selectedKeys.current, ['Banana']);
      assert
        .dom('[data-test-id="trigger"]')
        .hasValue('b', 'typed text is kept');

      await click('[data-component="listbox"] [data-key="Blackberry"]');
      assert.deepEqual(selectedKeys.current, ['Banana', 'Blackberry']);
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
  }
);
