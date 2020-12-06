# `<ChangesetForm>` usage

Almost every single app out there has some kind of form. It might be a user preference
page or a core part of the experience you are providing your user. Usually,
forms are bound to an object that the user can update or add more values.
To provide rich user experience, validating the user's input might be a requirement,
or to avoid confusing users, you might want to wait for the user to click "save" until
updating parts of the screen that shows the data that the user is changing.

ChangesetForm helps to implement all these features in your apps. We use
[`ember-changeset`](http://github.com/poteto/ember-changeset) under the hood,
validations are provided by [`ember-changeset-validations`](https://github.com/poteto/ember-changeset-validations/).

The `<ChangesetForm>` component yields an object with all the components pre-bonded
to a changeset for you to create a form. It also exposes the changeset itself if
you need to access any information directly.

Here's the list of yielded form components:

| Key           | Component                                                |
| ------------- | -------------------------------------------------------- |
| Text          | [`<FormText>`](/docs/forms/form-input)                   |
| Textarea      | [`<FormTextArea>`](/docs/forms/form-textarea)            |
| Select        | [`<FormSelect>`](/docs/forms/form-select)                |
| Checkbox      | [`<FormCheckbox>`](/docs/forms/form-checkbox)            |
| CheckboxGroup | [`<FormCheckboxGroup>`](/docs/forms/form-checkbox-group) |
| Radio         | [`<FormRadio>`](/docs/forms/form-radio)                  |
| RadioGroup    | [`<FormRadioGroup>`](/docs/forms/form-radio-group)       |

### Form Data Model

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

### Validation

Changeset validation is provided by [`ember-changeset-validations`](https://github.com/poteto/ember-changeset-validations/),
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

### Creating an Instance of a changeset via the template

```hbs
{{#let (changeset this.myFormModel this.myValidations) as |changesetObject|}}
  <ChangesetForm
    @changeset={{changesetObject}}
    as |Form changeset|
  >
    <Form.Input
      @fieldName="name.first"
      @label="First Name"
    />
    <Form.Input
      @fieldName="name.last"
      @label="Last Name"
    />
    <Form.Input
      @fieldName="email"
      @label="Email"
    />
    <Form.Input
      @fieldName="hometown"
      @label="Home Town"
    />
    <Form.Select
      @fieldName="preferences"
      @label="Preferences"
    />

    <button type="submit">Submit</button>
  </ChangesetForm>
{{/let}}
```

### Creating Your Own Changeset via JS

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
<ChangesetForm @changeset={{this.myChangeset}} as |Form changeset|>
  <Form.Input
    @fieldName="myValue"
    @label="My Value"
  />

  <button type="submit">Submit</button>
</ChangesetForm>
```

### Complete Example

<Demo::ChangesetForm::CompleteForm />

Special thanks to [@jasonmevans](https://github.com/jasonmevans),
[@snewcomer](http://github.com/snewcomer),
and [`ember-changeset`](http://github.com/poteto/ember-changeset)
for helping make this component possible.
