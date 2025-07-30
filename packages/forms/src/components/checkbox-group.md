---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Checkbox Group

A flexible checkbox group component that allows users to select multiple options from a set of choices. It provides a clean interface with support for labels, validation, different orientations, and comprehensive accessibility features.

## Import

```js
import { CheckboxGroup } from '@frontile/forms';
```

## Usage

### Basic Checkbox Group

The most basic usage of the CheckboxGroup component with a label and options.

```gts preview
import { CheckboxGroup } from '@frontile/forms';

<template>
  <CheckboxGroup @label='Interests' as |Checkbox|>
    <Checkbox @label='Music' />
    <Checkbox @label='Sports' />
    <Checkbox @label='Technology' />
  </CheckboxGroup>
</template>
```

### Controlled Checkbox Group

You can control individual checkbox states by providing `@checked` and handling updates with `@onChange`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';

export default class ControlledCheckboxGroup extends Component {
  @tracked selectedInterests = {
    music: false,
    sports: false,
    technology: false,
    art: false
  };

  updateMusic = (checked: boolean) => {
    this.selectedInterests = { ...this.selectedInterests, music: checked };
  };

  updateSports = (checked: boolean) => {
    this.selectedInterests = { ...this.selectedInterests, sports: checked };
  };

  updateTechnology = (checked: boolean) => {
    this.selectedInterests = { ...this.selectedInterests, technology: checked };
  };

  updateArt = (checked: boolean) => {
    this.selectedInterests = { ...this.selectedInterests, art: checked };
  };

  get selectedCount() {
    return Object.values(this.selectedInterests).filter(Boolean).length;
  }

  get selectedItems() {
    return Object.entries(this.selectedInterests)
      .filter(([_, selected]) => selected)
      .map(([key]) => key)
      .join(', ');
  }

  <template>
    <div class='flex flex-col gap-4'>
      <CheckboxGroup @label='What are your interests?' as |Checkbox|>
        <Checkbox
          @label='Music'
          @checked={{this.selectedInterests.music}}
          @onChange={{this.updateMusic}}
        />
        <Checkbox
          @label='Sports'
          @checked={{this.selectedInterests.sports}}
          @onChange={{this.updateSports}}
        />
        <Checkbox
          @label='Technology'
          @checked={{this.selectedInterests.technology}}
          @onChange={{this.updateTechnology}}
        />
        <Checkbox
          @label='Art'
          @checked={{this.selectedInterests.art}}
          @onChange={{this.updateArt}}
        />
      </CheckboxGroup>

      <div class='p-3 border border-default-300 rounded'>
        <p class='text-sm'>
          Selected ({{this.selectedCount}}):
          {{this.selectedItems}}
        </p>
      </div>
    </div>
  </template>
}
```

### Orientation

Control the layout orientation of checkbox options using the `@orientation` argument. Options can be arranged vertically (default) or horizontally.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';

export default class OrientationExample extends Component {
  @tracked verticalOptions = {
    option1: false,
    option2: false,
    option3: false
  };

  @tracked horizontalOptions = {
    sm: false,
    md: false,
    lg: false,
    xl: false
  };

  updateVerticalOption = (key: string) => (checked: boolean) => {
    this.verticalOptions = { ...this.verticalOptions, [key]: checked };
  };

  updateHorizontalOption = (key: string) => (checked: boolean) => {
    this.horizontalOptions = { ...this.horizontalOptions, [key]: checked };
  };

  <template>
    <div class='flex flex-col gap-4'>
      <CheckboxGroup
        @label='Vertical Layout (Default)'
        @orientation='vertical'
        as |Checkbox|
      >
        <Checkbox
          @label='Option 1'
          @checked={{this.verticalOptions.option1}}
          @onChange={{this.updateVerticalOption 'option1'}}
        />
        <Checkbox
          @label='Option 2'
          @checked={{this.verticalOptions.option2}}
          @onChange={{this.updateVerticalOption 'option2'}}
        />
        <Checkbox
          @label='Option 3'
          @checked={{this.verticalOptions.option3}}
          @onChange={{this.updateVerticalOption 'option3'}}
        />
      </CheckboxGroup>

      <CheckboxGroup
        @label='Horizontal Layout'
        @orientation='horizontal'
        as |Checkbox|
      >
        <Checkbox
          @label='Small'
          @checked={{this.horizontalOptions.sm}}
          @onChange={{this.updateHorizontalOption 'sm'}}
        />
        <Checkbox
          @label='Medium'
          @checked={{this.horizontalOptions.md}}
          @onChange={{this.updateHorizontalOption 'md'}}
        />
        <Checkbox
          @label='Large'
          @checked={{this.horizontalOptions.lg}}
          @onChange={{this.updateHorizontalOption 'lg'}}
        />
        <Checkbox
          @label='Extra Large'
          @checked={{this.horizontalOptions.xl}}
          @onChange={{this.updateHorizontalOption 'xl'}}
        />
      </CheckboxGroup>
    </div>
  </template>
}
```

### Sizes

Control the size of checkbox inputs using the `@size` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';

export default class CheckboxGroupSizes extends Component {
  @tracked smallOptions = { a: false, b: false };
  @tracked mediumOptions = { a: false, b: false };
  @tracked largeOptions = { a: false, b: false };

  updateSmallOption = (key: string) => (checked: boolean) => {
    this.smallOptions = { ...this.smallOptions, [key]: checked };
  };

  updateMediumOption = (key: string) => (checked: boolean) => {
    this.mediumOptions = { ...this.mediumOptions, [key]: checked };
  };

  updateLargeOption = (key: string) => (checked: boolean) => {
    this.largeOptions = { ...this.largeOptions, [key]: checked };
  };

  <template>
    <div class='flex flex-col gap-4'>
      <CheckboxGroup @label='Small Size' @size='sm' as |Checkbox|>
        <Checkbox
          @label='Option A'
          @checked={{this.smallOptions.a}}
          @onChange={{this.updateSmallOption 'a'}}
        />
        <Checkbox
          @label='Option B'
          @checked={{this.smallOptions.b}}
          @onChange={{this.updateSmallOption 'b'}}
        />
      </CheckboxGroup>

      <CheckboxGroup @label='Medium Size' @size='md' as |Checkbox|>
        <Checkbox
          @label='Option A'
          @checked={{this.mediumOptions.a}}
          @onChange={{this.updateMediumOption 'a'}}
        />
        <Checkbox
          @label='Option B'
          @checked={{this.mediumOptions.b}}
          @onChange={{this.updateMediumOption 'b'}}
        />
      </CheckboxGroup>

      <CheckboxGroup @label='Large Size' @size='lg' as |Checkbox|>
        <Checkbox
          @label='Option A'
          @checked={{this.largeOptions.a}}
          @onChange={{this.updateLargeOption 'a'}}
        />
        <Checkbox
          @label='Option B'
          @checked={{this.largeOptions.b}}
          @onChange={{this.updateLargeOption 'b'}}
        />
      </CheckboxGroup>
    </div>
  </template>
}
```

### Checkbox Options with Descriptions

Each checkbox option can include its own description text for additional context.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';

export default class CheckboxWithDescriptions extends Component {
  @tracked features = {
    basic: false,
    pro: false,
    enterprise: false
  };

  updateFeature = (key: string) => (checked: boolean) => {
    this.features = { ...this.features, [key]: checked };
  };

  <template>
    <CheckboxGroup @label='Select features to include' as |Checkbox|>
      <Checkbox
        @label='Basic Features'
        @description='Includes essential functionality for getting started.'
        @checked={{this.features.basic}}
        @onChange={{this.updateFeature 'basic'}}
      />
      <Checkbox
        @label='Pro Features'
        @description='Advanced features for power users and professionals.'
        @checked={{this.features.pro}}
        @onChange={{this.updateFeature 'pro'}}
      />
      <Checkbox
        @label='Enterprise Features'
        @description='Full feature set with dedicated support and custom integrations.'
        @checked={{this.features.enterprise}}
        @onChange={{this.updateFeature 'enterprise'}}
      />
    </CheckboxGroup>
  </template>
}
```

### Form Validation

The CheckboxGroup component integrates with form validation by displaying error messages and updating ARIA attributes accordingly.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';
import { on } from '@ember/modifier';
import { Button } from '@frontile/buttons';

export default class ValidatedCheckboxGroup extends Component {
  @tracked preferences = {
    email: false,
    sms: false,
    push: false
  };
  @tracked errors: string[] = [];

  updatePreference = (key: string) => (checked: boolean) => {
    this.preferences = { ...this.preferences, [key]: checked };
    // Clear errors when user makes a selection
    if (checked) {
      this.errors = [];
    }
  };

  validatePreferences = () => {
    const hasSelection = Object.values(this.preferences).some(Boolean);

    if (!hasSelection) {
      this.errors = ['Please select at least one notification method'];
    } else {
      this.errors = [];
      console.log('Valid selection:', this.preferences);
    }
  };

  <template>
    <div class='flex flex-col gap-4'>
      <CheckboxGroup
        @label='Notification Preferences'
        @description='Choose how you would like to receive notifications'
        @errors={{this.errors}}
        @isRequired={{true}}
        as |Checkbox|
      >
        <Checkbox
          @label='Email notifications'
          @checked={{this.preferences.email}}
          @onChange={{this.updatePreference 'email'}}
        />
        <Checkbox
          @label='SMS notifications'
          @checked={{this.preferences.sms}}
          @onChange={{this.updatePreference 'sms'}}
        />
        <Checkbox
          @label='Push notifications'
          @checked={{this.preferences.push}}
          @onChange={{this.updatePreference 'push'}}
        />
      </CheckboxGroup>

      <div>
        <Button {{on 'click' this.validatePreferences}}>
          Save Preferences
        </Button>
      </div>
    </div>
  </template>
}
```

### With Description

Add helpful description text to the entire checkbox group that appears below the label.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';

export default class CheckboxGroupWithDescription extends Component {
  @tracked permissions = {
    read: false,
    write: false,
    delete: false
  };

  updatePermission = (key: string) => (checked: boolean) => {
    this.permissions = { ...this.permissions, [key]: checked };
  };

  <template>
    <CheckboxGroup
      @label='User Permissions'
      @description='Select the permissions this user should have. You can modify these later in the user settings.'
      as |Checkbox|
    >
      <Checkbox
        @label='Read access'
        @checked={{this.permissions.read}}
        @onChange={{this.updatePermission 'read'}}
      />
      <Checkbox
        @label='Write access'
        @checked={{this.permissions.write}}
        @onChange={{this.updatePermission 'write'}}
      />
      <Checkbox
        @label='Delete access'
        @checked={{this.permissions.delete}}
        @onChange={{this.updatePermission 'delete'}}
      />
    </CheckboxGroup>
  </template>
}
```

### Complete Form Example

Here's a comprehensive example showing a CheckboxGroup in a form context with other inputs:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';
import { Input } from '@frontile/forms';
import { on } from '@ember/modifier';
import { Button } from '@frontile/buttons';

export default class CompleteFormWithCheckbox extends Component {
  @tracked name = '';
  @tracked interests = {
    technology: false,
    sports: false,
    music: false,
    travel: false
  };
  @tracked newsletters = {
    weekly: false,
    monthly: false
  };

  @tracked nameErrors: string[] = [];
  @tracked interestsErrors: string[] = [];
  @tracked newslettersErrors: string[] = [];

  updateName = (value: string) => {
    this.name = value;
    this.nameErrors = [];
  };

  updateInterest = (key: string) => (checked: boolean) => {
    this.interests = { ...this.interests, [key]: checked };
    this.interestsErrors = [];
  };

  updateNewsletter = (key: string) => (checked: boolean) => {
    this.newsletters = { ...this.newsletters, [key]: checked };
    this.newslettersErrors = [];
  };

  handleSubmit = (event: Event) => {
    event.preventDefault();

    // Reset errors
    this.nameErrors = [];
    this.interestsErrors = [];
    this.newslettersErrors = [];

    // Validate form
    let hasErrors = false;

    if (!this.name.trim()) {
      this.nameErrors = ['Name is required'];
      hasErrors = true;
    }

    const hasInterests = Object.values(this.interests).some(Boolean);
    if (!hasInterests) {
      this.interestsErrors = ['Please select at least one interest'];
      hasErrors = true;
    }

    if (!hasErrors) {
      console.log('Form submitted successfully!', {
        name: this.name,
        interests: this.interests,
        newsletters: this.newsletters
      });
    }
  };

  <template>
    <form {{on 'submit' this.handleSubmit}}>
      <div class='flex flex-col gap-4'>

        <Input
          @label='Full Name'
          @value={{this.name}}
          @onInput={{this.updateName}}
          @isRequired={{true}}
          @errors={{this.nameErrors}}
        />

        <CheckboxGroup
          @label='Areas of Interest'
          @description='Select topics you would like to hear about'
          @errors={{this.interestsErrors}}
          @isRequired={{true}}
          @orientation='horizontal'
          as |Checkbox|
        >
          <Checkbox
            @label='Technology'
            @checked={{this.interests.technology}}
            @onChange={{this.updateInterest 'technology'}}
          />
          <Checkbox
            @label='Sports'
            @checked={{this.interests.sports}}
            @onChange={{this.updateInterest 'sports'}}
          />
          <Checkbox
            @label='Music'
            @checked={{this.interests.music}}
            @onChange={{this.updateInterest 'music'}}
          />
          <Checkbox
            @label='Travel'
            @checked={{this.interests.travel}}
            @onChange={{this.updateInterest 'travel'}}
          />
        </CheckboxGroup>

        <CheckboxGroup
          @label='Newsletter Subscriptions'
          @description='Optional newsletters you can subscribe to'
          as |Checkbox|
        >
          <Checkbox
            @label='Weekly Newsletter'
            @description='Get the latest updates every week'
            @checked={{this.newsletters.weekly}}
            @onChange={{this.updateNewsletter 'weekly'}}
          />
          <Checkbox
            @label='Monthly Digest'
            @description='Monthly summary of important news and updates'
            @checked={{this.newsletters.monthly}}
            @onChange={{this.updateNewsletter 'monthly'}}
          />
        </CheckboxGroup>

        <div>
          <Button @class='mt-4'>
            Submit Registration
          </Button>
        </div>

      </div>
    </form>
  </template>
}
```

### Custom Styling

You can customize the appearance of different parts of the checkbox group using the `@classes` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';
import { hash } from '@ember/helper';

export default class CustomStyledCheckboxGroup extends Component {
  @tracked customOptions = {
    option1: false,
    option2: false,
    option3: false
  };

  updateCustomOption = (key: string) => (checked: boolean) => {
    this.customOptions = { ...this.customOptions, [key]: checked };
  };

  <template>
    <CheckboxGroup
      @label='Custom Styled Checkbox Group'
      @classes={{hash
        base='my-custom-checkbox-group'
        label='my-custom-label'
        optionsContainer='my-custom-options-container'
      }}
      as |Checkbox|
    >
      <Checkbox
        @label='Option 1'
        @checked={{this.customOptions.option1}}
        @onChange={{this.updateCustomOption 'option1'}}
      />
      <Checkbox
        @label='Option 2'
        @checked={{this.customOptions.option2}}
        @onChange={{this.updateCustomOption 'option2'}}
      />
      <Checkbox
        @label='Option 3'
        @checked={{this.customOptions.option3}}
        @onChange={{this.updateCustomOption 'option3'}}
      />
    </CheckboxGroup>
  </template>
}
```

## Accessibility

The CheckboxGroup component follows accessibility best practices:

- Proper grouping with fieldset/legend semantics via FormControl
- Proper label association for each checkbox option
- ARIA attributes for invalid states (`aria-invalid`)
- Descriptive text association using `aria-describedby`
- Support for required field indication
- Keyboard navigation follows standard checkbox patterns (space to toggle)
- Screen reader announcements for group label, individual option labels, and validation messages

## API

<Signature @package="forms" @component="CheckboxGroup" />
