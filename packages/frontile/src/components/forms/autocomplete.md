---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Autocomplete

The `Autocomplete` component combines a text input with a listbox popover, letting users filter a list of options by typing. It follows the [WAI-ARIA combobox pattern](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/) and supports static lists, custom filtering, and options loaded asynchronously from an API. Like [Select](https://frontile.dev/docs/components/forms/select), it is built on top of the [Listbox](https://frontile.dev/docs/components/collections/listbox) and [Popover](https://frontile.dev/docs/components/overlays/popover) components and renders a hidden native `<select>` for form submission.

Use `Autocomplete` when the list is long enough that typing beats scrolling — assigning a country, a time zone, a teammate. Use `Select` when scanning a short list is faster than typing, or when you need multiple selection (`Select` supports `@selectionMode="multiple"` together with `@isFilterable`); `Autocomplete` is single-selection only.

## Import

```js
import { Autocomplete } from 'frontile';
```

## Usage

### Basic Autocomplete

Type into the input to filter the options. The default filter is a case-insensitive "contains" match.

```gts preview
import { Autocomplete } from 'frontile';

const countries = [
  'Argentina',
  'Australia',
  'Brazil',
  'Canada',
  'Denmark',
  'France',
  'Germany',
  'Japan',
  'Mexico',
  'Netherlands',
  'New Zealand',
  'Portugal',
  'South Korea',
  'Spain',
  'United Kingdom',
  'United States'
];

<template>
  <Autocomplete @placeholder='Search countries' @items={{countries}} />
</template>
```

### Selection

Pass `@selectedKey` and update it in `@onSelectionChange` to maintain two-way binding, the same data flow as `Select`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Autocomplete } from 'frontile';

const languages = [
  'Elixir',
  'Go',
  'JavaScript',
  'Python',
  'Ruby',
  'Rust',
  'TypeScript'
];

export default class LanguagePicker extends Component {
  @tracked selectedKey: string | null = null;

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  <template>
    <Autocomplete
      @label='Primary language'
      @placeholder='Search languages'
      @items={{languages}}
      @selectedKey={{this.selectedKey}}
      @onSelectionChange={{this.onSelectionChange}}
    />
    <p class='mt-4'>Selected: {{if this.selectedKey this.selectedKey 'none'}}</p>
  </template>
}
```

### Async search with an API

Pass `@onSearch` to load options from an API as the user types. The component debounces calls (250ms by default, tune with `@searchDebounce`), shows a loading spinner while the returned promise is pending, and ignores stale responses so the latest query always wins. Clearing the input restores `@items` without triggering a search.

This example simulates a request with network latency:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Autocomplete } from 'frontile';

interface City {
  key: string;
  label: string;
}

const cities: City[] = [
  { key: 'amsterdam', label: 'Amsterdam' },
  { key: 'barcelona', label: 'Barcelona' },
  { key: 'berlin', label: 'Berlin' },
  { key: 'buenos-aires', label: 'Buenos Aires' },
  { key: 'lisbon', label: 'Lisbon' },
  { key: 'london', label: 'London' },
  { key: 'melbourne', label: 'Melbourne' },
  { key: 'mexico-city', label: 'Mexico City' },
  { key: 'new-york', label: 'New York' },
  { key: 'sao-paulo', label: 'São Paulo' },
  { key: 'seoul', label: 'Seoul' },
  { key: 'tokyo', label: 'Tokyo' }
];

// Stand-in for a real API call, e.g. fetch(`/api/cities?q=${query}`)
const searchCities = (query: string): Promise<City[]> => {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(
        cities.filter((city) =>
          city.label.toLowerCase().includes(query.toLowerCase())
        )
      );
    }, 600);
  });
};

export default class CitySearch extends Component {
  @tracked selectedKey: string | null = null;

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  <template>
    <Autocomplete
      @label='Destination'
      @placeholder='Search cities'
      @searchMessage='Type to search for a city...'
      @onSearch={{searchCities}}
      @selectedKey={{this.selectedKey}}
      @onSelectionChange={{this.onSelectionChange}}
    >
      <:emptyContent>No cities match your search.</:emptyContent>
    </Autocomplete>
  </template>
}
```

Pass `@searchMessage` (or a `:searchMessage` block for rich content) to prompt users who open the dropdown before typing — it shows while the query is blank and there are no options to display, as in the example above. Without it, an opened async autocomplete with no default `@items` shows the empty content instead.

### External filtering

If you want full control over filtering — for example, filtering server-side while controlling the request lifecycle yourself — pass `@disableFiltering={{true}}` and update `@items` from `@onInputChange`:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Autocomplete } from 'frontile';

const allTimezones = [
  'America/Chicago',
  'America/Denver',
  'America/Los_Angeles',
  'America/New_York',
  'Asia/Seoul',
  'Asia/Tokyo',
  'Australia/Sydney',
  'Europe/Berlin',
  'Europe/Lisbon',
  'Europe/London'
];

export default class TimezonePicker extends Component {
  @tracked items = allTimezones;

  onInputChange = (value: string) => {
    // Replace with your own request/filter logic
    this.items = allTimezones.filter((tz) =>
      tz.toLowerCase().includes(value.toLowerCase())
    );
  };

  <template>
    <Autocomplete
      @label='Time zone'
      @placeholder='Search time zones'
      @items={{this.items}}
      @disableFiltering={{true}}
      @onInputChange={{this.onInputChange}}
    />
  </template>
}
```

### Custom filter

Pass `@filter` to change how items match the typed text — here, matching only from the start of the word:

```gts preview
import { Autocomplete } from 'frontile';

const fruits = ['Apple', 'Apricot', 'Banana', 'Cherry', 'Grape', 'Pineapple'];

const startsWith = (itemValue: string, inputValue: string) =>
  itemValue.toLowerCase().startsWith(inputValue.toLowerCase());

<template>
  <Autocomplete
    @placeholder="Try typing 'ap'"
    @items={{fruits}}
    @filter={{startsWith}}
  />
</template>
```

### Custom items

Use the `:item` block to render richer options. Objects with `key` and `label` properties work out of the box.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Autocomplete } from 'frontile';

const teammates = [
  { key: 'ana', label: 'Ana Souza', role: 'Design' },
  { key: 'devon', label: 'Devon Lane', role: 'Engineering' },
  { key: 'kim', label: 'Kim Park', role: 'Product' },
  { key: 'marta', label: 'Marta Silva', role: 'Engineering' },
  { key: 'ravi', label: 'Ravi Patel', role: 'Support' }
];

export default class AssigneePicker extends Component {
  @tracked selectedKey: string | null = null;

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  <template>
    <Autocomplete
      @label='Assignee'
      @placeholder='Search teammates'
      @items={{teammates}}
      @selectedKey={{this.selectedKey}}
      @onSelectionChange={{this.onSelectionChange}}
    >
      <:item as |l|>
        <l.Item @key={{l.key}} @description={{l.item.role}}>
          {{l.label}}
        </l.Item>
      </:item>
    </Autocomplete>
  </template>
}
```

### Custom values

By default the input reverts to the selected option's label when the dropdown closes. Pass `@allowsCustomValue={{true}}` to keep whatever the user typed — useful when suggestions are helpful but not required. Read the final text via `@onInputChange`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Autocomplete } from 'frontile';

const commonRoles = ['Admin', 'Editor', 'Viewer'];

export default class RoleInput extends Component {
  @tracked value = '';

  onInputChange = (value: string) => {
    this.value = value;
  };

  <template>
    <Autocomplete
      @label='Role'
      @description='Pick a suggestion or type your own'
      @items={{commonRoles}}
      @allowsCustomValue={{true}}
      @onInputChange={{this.onInputChange}}
    />
    <p class='mt-4'>Value: {{this.value}}</p>
  </template>
}
```

### Clear button

Pass `@isClearable={{true}}` to show a button that clears both the selection and the typed text.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Autocomplete } from 'frontile';

const browsers = ['Chrome', 'Edge', 'Firefox', 'Safari'];

export default class BrowserPicker extends Component {
  @tracked selectedKey: string | null = 'Firefox';

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  <template>
    <Autocomplete
      @label='Browser'
      @items={{browsers}}
      @isClearable={{true}}
      @selectedKey={{this.selectedKey}}
      @onSelectionChange={{this.onSelectionChange}}
    />
  </template>
}
```

### Sizes and validation

`Autocomplete` accepts the same form control arguments as other Frontile inputs: `@label`, `@description`, `@errors`, `@isInvalid`, `@isRequired`, and `@inputSize`.

```gts preview
import { Autocomplete } from 'frontile';
import { array } from '@ember/helper';

const plans = ['Free', 'Pro', 'Enterprise'];

<template>
  <div class='flex flex-col gap-4'>
    <Autocomplete @inputSize='sm' @placeholder='Small' @items={{plans}} />
    <Autocomplete @inputSize='md' @placeholder='Medium' @items={{plans}} />
    <Autocomplete @inputSize='lg' @placeholder='Large' @items={{plans}} />
    <Autocomplete
      @label='Plan'
      @isRequired={{true}}
      @isInvalid={{true}}
      @errors={{array 'Choose a plan to continue'}}
      @items={{plans}}
    />
  </div>
</template>
```

## Keyboard interaction

| Key | Action |
| --- | --- |
| Type characters | Opens the dropdown and filters the options |
| <kbd>ArrowDown</kbd> / <kbd>ArrowUp</kbd> | Opens the dropdown / moves the highlight |
| <kbd>Enter</kbd> | Selects the highlighted option |
| <kbd>Escape</kbd> | Closes the dropdown |
| <kbd>Home</kbd> / <kbd>End</kbd> | Moves the highlight to the first / last option |

## Accessibility

The input uses `role="combobox"` with `aria-autocomplete="list"`, `aria-expanded`, and `aria-controls` pointing at the popover. Focus stays on the input while <kbd>ArrowUp</kbd>/<kbd>ArrowDown</kbd> move a virtual highlight communicated through `aria-activedescendant`. A visually hidden native `<select>` mirrors the options for form submission via `@name`.

## API

<Signature @component="Autocomplete" />
