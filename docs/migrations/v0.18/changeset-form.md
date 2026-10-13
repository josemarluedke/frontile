---
title: Migrating from Changeset Form
order: 7
category: migrations
subcategory: v0.18
---

# Migrating from Changeset Form

This guide covers migrating from the deprecated `@frontile/changeset-form` package to the modern `frontile` forms. We recommend the Form + Field pattern with Valibot validation, and also cover paths for teams that need to keep `ember-changeset` validation.

## Overview

The `@frontile/changeset-form` package is deprecated and will be removed in 0.19.0. This guide presents three migration paths based on your project's constraints and goals.

## Key Architectural Patterns

**Form + Field pattern** (Approach 1): Automatic data binding, validation, and state management via `<Form>` and `<form.Field>` components.

**Standalone components** (Approaches 2 & 3): Use form components directly with manual binding and validation integration.

See the [Form documentation](https://frontile.dev/docs/components/forms/form) for detailed architecture information.

## Migration Approach Overview

You have three main migration paths, **ordered by recommendation**:

| Approach                                | Validation | Components                           | Effort     | Tech Debt | Best For                                       |
| --------------------------------------- | ---------- | ------------------------------------ | ---------- | --------- | ---------------------------------------------- |
| **1. Modern Forms + Valibot**           | Valibot    | Form + Field pattern                 | Low-Medium | None      | New features, best long-term choice            |
| **2. Changeset + Modern Components**    | Changeset  | Standalone modern components         | Medium     | Medium    | Keep validation, modernize UI                  |
| **3. Changeset + Forms-Legacy**         | Changeset  | Legacy components                    | Medium     | High      | Large codebases needing gradual migration only |

**Recommendation:** choose Approach 1 (Modern Forms + Valibot) unless you have a specific constraint that requires changeset validation.

## Before You Start

Build the package you'll use: `pnpm --filter frontile build` (Approaches 1 & 2) or `pnpm --filter forms-legacy build` (Approach 3)

---

## Approach 1: Modern Forms + Valibot (Recommended)

Uses the modern Form + Field pattern with Valibot validation.

### When to Choose This Approach

- Starting new features or components — a clean break from legacy patterns
- Modernizing existing forms
- Want type-safe, TypeScript-first validation schemas
- Want simpler validation logic without changeset dependencies

### Step 1: Install Dependencies

```bash
# Remove old packages
npm uninstall @frontile/changeset-form @frontile/forms-legacy
npm uninstall ember-changeset ember-changeset-validations

# Install new packages
npm install frontile @frontile/theme valibot
```

### Step 2: Migrate to Form + Field Pattern

#### Before (changeset-form)

```hbs
{{#let (changeset this.model this.validations) as |changeset|}}
  <ChangesetForm @changeset={{changeset}} as |Form|>
    <Form.Input @fieldName='firstName' @label='First Name' />
    <Form.Textarea @fieldName='comments' @label='Comments' />
    <Form.Select
      @fieldName='country'
      @label='Country'
      @options={{this.countries}}
      as |option|
    >
      {{option}}
    </Form.Select>
    <Button @type='submit'>Save</Button>
  </ChangesetForm>
{{/let}}
```

#### After (Modern Forms + Valibot)

Complete GTS component with template:

```gts title="app/components/user-form.gts" collapsible
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';
import { Button } from 'frontile';
import * as v from 'valibot';

// Define schema outside class (replaces changeset validations)
const UserFormSchema = v.object({
  user: v.object({
    firstName: v.pipe(v.string(), v.nonEmpty('Required')),
    email: v.pipe(v.string(), v.nonEmpty('Required'), v.email('Invalid'))
  }),
  country: v.pipe(
    v.fallback(v.string(), ''),  // Required for Select fields
    v.string(),
    v.nonEmpty('Please select a country')
  ),
  plan: v.pipe(
    v.fallback(v.string(), ''),
    v.string(),
    v.nonEmpty('Please select a plan')
  )
});

type UserFormSchema = v.InferOutput<typeof UserFormSchema>;

export default class UserFormComponent extends Component {
  @tracked formData: UserFormSchema = {
    user: { firstName: '', email: '' },
    country: '',
    plan: ''
  };

  countries = [
    { key: 'us', label: 'United States' },
    { key: 'ca', label: 'Canada' }
  ];

  handleChange = (result: FormResultData<UserFormSchema>) => {
    this.formData = result.data;
  };

  handleSubmit = async (result: FormResultData<UserFormSchema>) => {
    // Data is already validated
    await this.saveUser(result.data);
  };

  async saveUser(data: UserFormSchema) {
    // Your API call
  }

  <template>
    <Form
      @data={{this.formData}}
      @schema={{UserFormSchema}}
      @validateOn={{array "change" "submit"}}
      @onChange={{this.handleChange}}
      @onSubmit={{this.handleSubmit}}
      as |form|
    >
      {{! Nested data with dotted notation }}
      <form.Field @name="user.firstName" as |field|>
        <field.Input @label="First Name" />
      </form.Field>

      <form.Field @name="user.email" as |field|>
        <field.Input @type="email" @label="Email" />
      </form.Field>

      <form.Field @name="country" as |field|>
        <field.SingleSelect @label="Country" @items={{this.countries}} @allowEmpty={{true}} />
      </form.Field>

      <form.Field @name="plan" as |field|>
        <field.RadioGroup @label="Select Plan" as |Radio|>
          <Radio @label="Free" @value="free" />
          <Radio @label="Pro" @value="pro" />
        </field.RadioGroup>
      </form.Field>

      <Button @type="submit">Save</Button>
    </Form>
  </template>
}
```

For advanced features like dirty tracking, loading states, and validation timing control, see the [Form documentation](https://frontile.dev/docs/components/forms/form).

---

## Approach 2: Keep Changeset, Use Modern Components

This approach keeps ember-changeset validation while using modern `frontile` form components in **standalone mode** (without Form/Field wrappers).

**Important:** This approach uses modern form components (Input, Select, Switch, etc.) directly, NOT the Form or Field components. You maintain manual control over data binding and validation.

### When to Choose This Approach

- Complex changeset validation you don't want to rewrite
- Need modern UI features — slots, clearable, filtering, better accessibility
- Modernizing components now and validation later
- Team is familiar with changeset and wants to minimize the learning curve
- Willing to accept the extra boilerplate that manual binding requires

### Step 1: Install Modern Forms

```bash
npm uninstall @frontile/changeset-form
npm install frontile @frontile/theme
# Keep: ember-changeset ember-changeset-validations
```

### Step 2: Standalone Components with Changeset

Use modern components directly without Form/Field wrappers:

#### Before (changeset-form)

```hbs
{{#let (changeset this.model this.validations) as |changeset|}}
  <ChangesetForm @changeset={{changeset}} as |Form|>
    <Form.Input @fieldName='firstName' @label='First Name' />

    <Form.Select
      @fieldName='country'
      @label='Country'
      @options={{this.countries}}
      @isMultiple={{true}}
      as |option|
    >
      {{option}}
    </Form.Select>

    <Button @type='submit'>Save</Button>
  </ChangesetForm>
{{/let}}
```

#### After (Changeset + Modern Components Standalone)

```hbs
{{#let (changeset this.model this.validations) as |changeset|}}
  <form {{on 'submit' (fn this.handleSubmit changeset)}}>
    {{! Manual binding required for standalone components }}
    <Input
      @label="First Name"
      @value={{get changeset 'firstName'}}
      @onChange={{fn this.updateField changeset 'firstName'}}
      @errors={{this.getFieldErrors changeset 'firstName'}}
    />

    {{! Key-based Select (not object-based!) }}
    <Select
      @label="Country"
      @items={{this.countries}}
      @selectedKey={{this.getSelectedCountry changeset}}
      @onSelectionChange={{fn this.updateCountry changeset}}
      @allowEmpty={{true}}
      @errors={{this.getFieldErrors changeset 'country'}}
    >
      <:item as |item|>
        <item.Item @key={{item.key}}>{{item.label}}</item.Item>
      </:item>
    </Select>

    {{! Radio uses @checkedValue, not @checked }}
    <Radio
      @label="Free"
      @value="free"
      @checkedValue={{get changeset 'plan'}}
      @onChange={{fn this.updateField changeset 'plan'}}
    />
    <Radio
      @label="Pro"
      @value="pro"
      @checkedValue={{get changeset 'plan'}}
      @onChange={{fn this.updateField changeset 'plan'}}
    />

    <Button @type="submit">Save</Button>
  </form>
{{/let}}
```

### Step 3: Component Class

Key changes: manual binding and Select key-based selection.

```typescript
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

export default class ChangesetFormComponent extends Component {
  @tracked hasSubmitted = false;

  // Keep existing changeset validations
  validations = {
    firstName: validatePresence(true),
    country: validatePresence(true),
    plan: validatePresence(true)
  };

  countries = [
    { key: 'us', label: 'United States' },
    { key: 'ca', label: 'Canada' }
  ];

  updateField = (changeset, fieldName, value) => {
    changeset.set(fieldName, value);
    changeset.validate(fieldName);
  };

  // Select components use keys, need conversion for changeset
  updateCountry = (changeset, selectedKey) => {
    changeset.set('country', selectedKey);
    changeset.validate('country');
  };

  getSelectedCountry(changeset) {
    return changeset.get('country') || null;
  }

  handleSubmit = async (changeset, event) => {
    event.preventDefault();
    await changeset.validate();
    this.hasSubmitted = true;

    if (changeset.isValid) {
      await changeset.save({});
    }
  };

  getFieldErrors(changeset, fieldName) {
    if (!this.hasSubmitted) return [];
    return changeset.errors
      .filter(e => e.key === fieldName)
      .map(e => e.validation)
      .flat();
  }
}
```

---

## Approach 3: Keep Changeset, Use Forms-Legacy

This is the minimal-effort approach for large codebases that need gradual migration. It keeps changeset validation while using legacy form components.

**Warning:** this approach carries the most technical debt of the three, and should only be chosen when time or resource constraints rule out the other two.

### When to Choose This Approach

- Very large codebase — hundreds of forms to migrate
- Limited development resources, need the smallest possible effort now
- Extensive custom changeset validation logic
- A short-term solution you plan to revisit later, accepting the technical debt as a stopgap

### Step 1: Install Forms-Legacy

```bash
npm uninstall @frontile/changeset-form
npm install @frontile/forms-legacy
# Keep: ember-changeset ember-changeset-validations

# Build the package
pnpm --filter forms-legacy build
```

### Step 2: Key Changes

Replace `ChangesetForm` wrapper with manual changeset binding to `@frontile/forms-legacy` components:

```hbs
{{! Before }}
<ChangesetForm @changeset={{changeset}} as |Form|>
  <Form.Input @fieldName='firstName' @label='First Name' />
</ChangesetForm>

{{! After }}
<form {{on 'submit' (fn this.handleSubmit changeset)}}>
  <FormInput
    @label='First Name'
    @value={{get changeset 'firstName'}}
    @onInput={{fn this.updateField changeset 'firstName'}}
    @errors={{this.getFieldErrors changeset 'firstName'}}
    @hasSubmitted={{this.hasSubmitted}}
  />
</form>
```

See the [Forms Legacy Migration Guide](forms-legacy.md) for complete component mappings and detailed migration steps.

**Recommendation:** Plan to migrate to Approach 1 when resources allow.

---

## Common Gotchas

Key API changes when migrating to modern forms:

### 1. Radio: `@checked` → `@checkedValue`

```hbs
{{! Legacy }}
<FormRadio @checked={{this.plan}} @value="free" />

{{! Modern }}
<Radio @checkedValue={{this.plan}} @value="free" />
```

In Approach 1, use `field.RadioGroup` which handles this automatically.

### 2. Select: Object-Based → Key-Based

```hbs
{{! Legacy (object selection) }}
<FormSelect @selected={{this.countryObject}} />

{{! Modern (key selection) }}
<Select @selectedKey="us" />  {{! Just the key string }}
```

Modern Select components use string keys instead of full objects. Add `v.fallback(v.string(), '')` to validation schemas for Select fields.

### 3. Form + Field vs Standalone

**Approach 1** uses Form + Field: `<form.Field @name="email" as |field|><field.Input /></form.Field>`

**Approaches 2 & 3** use standalone components with manual binding: `<Input @value={{this.email}} @onChange={{this.setEmail}} />`

Don't mix these patterns in the same form.

---

## Additional Resources

- [Form documentation](https://frontile.dev/docs/components/forms/form) - Complete Form + Field pattern guide
- [Forms Legacy Migration Guide](forms-legacy.md) - Component-specific migration details
- [Valibot documentation](https://valibot.dev/) - Validation schema reference
