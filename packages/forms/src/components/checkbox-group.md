---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Checkbox Group

The `CheckboxGroup` component lets you render a set of related checkboxes under a single label, description, and validation state. It integrates with Frontile’s `FormControl` for consistent styling, error feedback, and accessibility, and supports both vertical and horizontal layouts.

## Import

```js
import { CheckboxGroup } from '@frontile/forms';
```

## Usage

### Vertical Layout (Default)

A basic vertical group of checkboxes with independent state.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';

export default class InterestsVertical extends Component {
  @tracked likesMusic = false;
  @tracked likesIot = false;

  onMusicChange = (checked: boolean) => (this.likesMusic = checked);
  onIotChange = (checked: boolean) => (this.likesIot = checked);

  <template>
    <CheckboxGroup @label='Your Interests' as |Checkbox|>
      <Checkbox
        @name='music'
        @label='Music'
        @checked={{this.likesMusic}}
        @onChange={{this.onMusicChange}}
      />
      <Checkbox
        @name='iot'
        @label='IoT'
        @checked={{this.likesIot}}
        @onChange={{this.onIotChange}}
      />
    </CheckboxGroup>

    <p class='mt-4'>
      Selected:
      {{if this.likesMusic 'Music'}}
      {{if this.likesIot 'IoT'}}
    </p>
  </template>
}
```

### Horizontal Layout

Set `@orientation="horizontal"` to lay checkboxes in a row.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';

export default class InterestsHorizontal extends Component {
  @tracked likesCats = false;
  @tracked likesDogs = false;

  onCatsChange = (checked: boolean) => (this.likesCats = checked);
  onDogsChange = (checked: boolean) => (this.likesDogs = checked);

  <template>
    <CheckboxGroup
      @label='Pet Preferences'
      @orientation='horizontal'
      as |Checkbox|
    >
      <Checkbox
        @name='cats'
        @label='Cats'
        @checked={{this.likesCats}}
        @onChange={{this.onCatsChange}}
      />
      <Checkbox
        @name='dogs'
        @label='Dogs'
        @checked={{this.likesDogs}}
        @onChange={{this.onDogsChange}}
      />
    </CheckboxGroup>
  </template>
}
```

### With Description and Error Feedback

Leverage `@description` and `@errors`` to display helper text and validation messages.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';

export default class FormValidationExample extends Component {
  @tracked wantsNewsletter = false;
  @tracked wantsOffers = false;
  @tracked errors: string[] = ['Please select at least one option.'];

  onNewsletterChange = (checked: boolean) => (this.wantsNewsletter = checked);
  onOffersChange = (checked: boolean) => (this.wantsOffers = checked);

  <template>
    <CheckboxGroup
      @label='Subscribe options'
      @description='Choose at least one:'
      @errors={{this.errors}}
      as |Checkbox|
    >
      <Checkbox
        @name='newsletter'
        @label='Newsletter'
        @checked={{this.wantsNewsletter}}
        @onChange={{this.onNewsletterChange}}
      />
      <Checkbox
        @name='offers'
        @label='Special Offers'
        @checked={{this.wantsOffers}}
        @onChange={{this.onOffersChange}}
      />
    </CheckboxGroup>
  </template>
}
```

### Custom Styling

Override internal classes via the @classes argument to apply your own CSS classes.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';

const customClasses = {
  base: 'border p-4 rounded-lg',
  label: 'text-lg font-semibold mb-2',
  optionsContainer: 'flex flex-wrap gap-4'
};

export default class StyledGroupExample extends Component {
  @tracked optionA = false;
  @tracked optionB = false;

  onAChange = (c: boolean) => (this.optionA = c);
  onBChange = (c: boolean) => (this.optionB = c);

  <template>
    <CheckboxGroup
      @label='Custom Styled Group'
      @classes={{customClasses}}
      @orientation='horizontal'
      as |Checkbox|
    >
      <Checkbox
        @name='a'
        @label='Option A'
        @checked={{this.optionA}}
        @onChange={{this.onAChange}}
      />
      <Checkbox
        @name='b'
        @label='Option B'
        @checked={{this.optionB}}
        @onChange={{this.onBChange}}
      />
    </CheckboxGroup>
  </template>
}
```

## API

<Signature @package="forms" @component="CheckboxGroup" />
