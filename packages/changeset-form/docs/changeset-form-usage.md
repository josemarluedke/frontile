---
title: Usage
url: /usage
label: Deprecated
---

# Using ChangesetForm

Almost every single app out there has some kind of form. It might be a user preference
page or a core part of the experience you are providing your user. Usually,
forms are bound to an object that the user can update or add more values.
To provide rich user experience, validating the user's input might be a requirement,
or to avoid confusing users, you might want to wait for the user to click "save" until
updating parts of the screen that shows the data that the user is changing.

ChangesetForm helps to implement all these features in your apps. We use
[ember-changeset](http://github.com/poteto/ember-changeset) under the hood,
validations are provided by [ember-changeset-validations](https://github.com/poteto/ember-changeset-validations/).

The `<ChangesetForm>` component yields an object with all the components pre-bonded
to a changeset for you to create a form. It also exposes the changeset itself if
you need to access any information directly.

## Form Data Model

The data model used to back the `<ChangesetForm>` is an instance of a changeset object by `ember-changeset`,
and so, nested property paths are supported. Ember Data Models are also supported.

```js
import Component from '@glimmer/component';

export default class Demo extends Component {
  myFormModel = {
    name: {
      first: 'Ron',
      last: 'Swanson'
    },
    email: 'ron@pawnee.in.gov',
    hometown: 'Pawnee, IN',
    preferences: ['Lagavulin', 'Steak', 'Bacon', 'No govt.']
  };
}
```

## Validation

Changeset validation is provided by [ember-changeset-validations](https://github.com/poteto/ember-changeset-validations/),
and is optional for any `Changeset` object used by `<ChangesetForm>` components. This takes the form of another
JS object literal mapping properties to validation functions:

```js
import Component from '@glimmer/component';
import validateFormat from 'ember-changeset-validations/validators/format';
import validatePresence from 'ember-changeset-validations/validators/presence';

export default class Demo extends Component {
  // ...
  myValidations = {
    'name.first': validatePresence(true),
    'name.last': validatePresence(true),
    email: validateFormat({ type: 'email' }),
    hometown: validatePresence(true),
    preferences: validatePresence(true)
  };
}
```

## Creating an Instance of a changeset via the template

```hbs
<ChangesetForm
  @changeset={{changeset this.myFormModel this.myValidations}}
  as |Form|
>
  <!-- ... -->
</ChangesetForm>
```

## Creating Your Own Changeset via JS

In this case you are responsible for also providing any validation you wish to apply
to your `Changeset`. The following is a brief example of that method:

```js
import Component from '@glimmer/component';
import { Changeset } from 'ember-changeset';
import lookupValidator from 'ember-changeset-validations';
import validatePresence from 'ember-changeset-validations/validators/presence';

export default class Demo extends Component {
  validations = {
    myValue: validatePresence(true)
  };

  myModel = {
    myValue: ''
  };

  myChangeset = new Changeset(
    this.myModel,
    lookupValidator(this.validations),
    this.validations
  );
}
```

```hbs
<ChangesetForm @changeset={{this.myChangeset}} as |Form|>
  <!-- ... -->
</ChangesetForm>
```

## API

### Args

<Signature @package="changeset-form" @component="ChangesetForm" class="mb-8" />

### Blocks

| Name      | Type                                                                                               |
| --------- | -------------------------------------------------------------------------------------------------- |
| `default` | `[formComponents: FormComponents, changeset: BufferedChangeset, state: { hasSubmitted: boolean }]` |

Here's the list of yielded form components from `FormComponents`:

| Key           | Component             |
| ------------- | --------------------- |
| Text          | `<FormText>`          |
| Textarea      | `<FormTextArea>`      |
| Select        | `<FormSelect>`        |
| Checkbox      | `<FormCheckbox>`      |
| CheckboxGroup | `<FormCheckboxGroup>` |
| Radio         | `<FormRadio>`         |
| RadioGroup    | `<FormRadioGroup>`    |

# Complete Form

This shows how to have a complete form using `ChangesetForm`.

```hbs template
{{#let (changeset this.model this.validations) as |changeset|}}
  <ChangesetForm @changeset={{changeset}} as |Form|>
    <Form.Input
      @label='First Name'
      @fieldName='firstName'
      placeholder='What is your first name?'
    />
    <Form.Input
      @label='Last Name'
      @fieldName='lastName'
      @containerClass='mt-4'
      placeholder='What is your family name?'
    />
    <Form.Input
      @label='Email Address'
      @fieldName='email'
      type='email'
      @containerClass='mt-4'
    />
    <Form.Textarea
      @label='Comments'
      @fieldName='comments'
      @containerClass='mt-4'
    />
    <Form.Select
      @label='Countries'
      @fieldName='countries'
      @isMultiple={{true}}
      @options={{this.countries}}
      @allowClear={{true}}
      @containerClass='mt-4'
      as |option|
    >
      {{option}}
    </Form.Select>
    <Form.CheckboxGroup
      @groupName='coreValues'
      @label='Core Values'
      @containerClass='mt-4'
      as |Checkbox|
    >
      <Checkbox @label='Hungry' @fieldName='hungry' />
      <Checkbox @label='Humble' @fieldName='humble' />
      <Checkbox @label='Curious' @fieldName='curious' />
    </Form.CheckboxGroup>
    <Form.RadioGroup
      @label='Favorite Meal'
      @containerClass='mt-4'
      @fieldName='favoriteMeal'
      as |Radio|
    >
      <Radio @label='Breakfast' @value='breakfast' />
      <Radio @label='Lunch' @value='lunch' />
      <Radio @label='Dinner' @value='dinner' />
    </Form.RadioGroup>
    <Button
      @type='submit'
      @intent='primary'
      disabled={{changeset.isInvalid}}
      class='mt-4'
    >
      Save
    </Button>
    <Button @type='reset' @appearance='outlined'>
      Reset
    </Button>
    <div class='mt-4'>
      <code>
        <p>isPristine: {{changeset.isPristine}}</p>
        <p>isValid: {{changeset.isValid}}</p>
        <p>isInvalid: {{changeset.isInvalid}}</p>
      </code>
    </div>
  </ChangesetForm>
{{/let}}
```

```ts component
import Component from '@glimmer/component';
import validateFormat from 'ember-changeset-validations/validators/format';
import validatePresence from 'ember-changeset-validations/validators/presence';

export const myValidations = {
  firstName: validatePresence(true),
  lastName: validatePresence(true),
  email: validateFormat({ type: 'email' }),
  countries: validatePresence(true)
};

export default class Demo extends Component {
  validations = myValidations;
  countries = [
    'Brazil',
    'India',
    'Israel',
    'Japan',
    'United Kingdom',
    'United States'
  ];

  model = {
    firstName: null,
    lastName: null,
    email: 'frontile@example.com',
    comments: 'Changeset forms are great! 🚀',
    countries: ['Brazil', 'United States'],
    coreValues: {
      hungry: true,
      humble: true,
      curious: true
    },
    favoriteMeal: 'lunch'
  };
}
```
