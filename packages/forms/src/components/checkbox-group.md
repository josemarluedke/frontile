---
label: New
imports:
  - import Signature from 'site/components/signature';
---
# Checkbox Group


## Import 

```js
import { CheckboxGroup } from '@frontile/forms';
```

## Usage

A checkbox group manages multiple related checkboxes and keeps the
selected values in sync. The yielded `<Checkbox>` automatically wires
the `name` and `onChange` arguments for you.

### Basic Group

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';

export default class CheckboxGroupExample extends Component {
  @tracked news = false;
  @tracked music = false;

  updateNews = (v: boolean) => (this.news = v);
  updateMusic = (v: boolean) => (this.music = v);

  <template>
    <CheckboxGroup @label='Notifications' as |Checkbox|>
      <Checkbox
        @name='news'
        @label='News'
        @checked={{this.news}}
        @onChange={{this.updateNews}}
      />
      <Checkbox
        @name='music'
        @label='Music'
        @checked={{this.music}}
        @onChange={{this.updateMusic}}
      />
    </CheckboxGroup>
    <p class='mt-4'>News: {{this.news}}, Music: {{this.music}}</p>
  </template>
}
```

### Horizontal Layout

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';

const interests = ['Music', 'IoT', 'Gaming'];

export default class HorizontalGroup extends Component {
  @tracked selected = new Set<string>();

  toggle = (label: string, value: boolean) => {
    if (value) {
      this.selected.add(label);
    } else {
      this.selected.delete(label);
    }
  };

  <template>
    <CheckboxGroup
      @label='Interests'
      @orientation='horizontal'
      as |Checkbox|
    >
      {{#each interests as |label|}}
        <Checkbox
          @name={{label}}
          @label={{label}}
          @checked={{this.selected.has(label)}}
          @onChange={{(v) => this.toggle(label, v)}}
        />
      {{/each}}
    </CheckboxGroup>
    <p class='mt-4'>Selected: {{this.selected}}</p>
  </template>
}
```

## API

<Signature @package="forms" @component="CheckboxGroup" />
