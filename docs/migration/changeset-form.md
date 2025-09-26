# Migrating from Changeset Form

This guide will help you migrate from the deprecated `@frontile/changeset-form` package to the modern `@frontile/forms` package. This migration guide presents three approaches: keeping ember-changeset with legacy forms, keeping ember-changeset with modern forms, or moving to a modern validation solution like Valibot.

## Overview

The `@frontile/changeset-form` package is deprecated and will be removed in future versions. It provided integration between `@frontile/forms-legacy` and `ember-changeset` for form validation and state management.

### What's Changing

- **@frontile/changeset-form** → Deprecated, no longer maintained
- **@frontile/forms-legacy** → Available but legacy, use for gradual migration
- **@frontile/forms** → Modern form components with enhanced features

## Why Migrate?

### Benefits of Migration

1. **Modern Component Architecture**: Better TypeScript support, slots, and customization
2. **Reduced Dependencies**: No longer tied to ember-power-select or complex changeset chains
3. **Improved Performance**: Optimized form data extraction with `form-data-utils`
4. **Better Developer Experience**: Simpler APIs, better error handling
5. **Enhanced Accessibility**: Improved ARIA support and keyboard navigation
6. **Active Maintenance**: Continued updates and bug fixes

### Current Changeset-Form Limitations

- Built on deprecated `@frontile/forms-legacy`
- Complex setup with changeset + validation dependencies
- Limited customization options
- No longer receiving updates

## Migration Approach Overview

You have three main migration paths:

| Approach                    | Validation                                    | Components             | Effort      | Best For                                |
| --------------------------- | --------------------------------------------- | ---------------------- | ----------- | --------------------------------------- |
| **Keep Changeset (Legacy)** | ember-changeset + ember-changeset-validations | @frontile/forms-legacy | Medium      | Gradual migration, minimal changes      |
| **Keep Changeset (Modern)** | ember-changeset + ember-changeset-validations | @frontile/forms        | Medium-High | Want modern components, keep validation |
| **Modern Valibot**          | Valibot                                       | @frontile/forms        | Low-Medium  | New features, greenfield projects       |

## Approach 1: Keep Changeset, Use Forms-Legacy

This approach keeps your existing validation logic while removing the changeset-form wrapper.

### When to Choose This Approach

- You have complex changeset validation logic
- Large codebase with many changeset dependencies
- Gradual migration strategy preferred
- Existing team expertise with ember-changeset

### Step 1: Remove Changeset-Form

```bash
npm uninstall @frontile/changeset-form
```

### Step 2: Direct Changeset Usage

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

#### After (direct changeset + forms-legacy)

```hbs
{{#let (changeset this.model this.validations) as |changeset|}}
  <form {{on 'submit' (fn this.handleSubmit changeset)}}>
    <FormInput
      @label='First Name'
      @value={{get changeset 'firstName'}}
      @onInput={{fn this.updateField changeset 'firstName'}}
      @errors={{this.getFieldErrors changeset 'firstName'}}
      @hasSubmitted={{this.hasSubmitted}}
    />

    <FormTextarea
      @label='Comments'
      @value={{get changeset 'comments'}}
      @onInput={{fn this.updateField changeset 'comments'}}
      @errors={{this.getFieldErrors changeset 'comments'}}
      @hasSubmitted={{this.hasSubmitted}}
    />

    <FormSelect
      @label='Country'
      @options={{this.countries}}
      @selected={{get changeset 'country'}}
      @onChange={{fn this.updateSelect changeset 'country'}}
      @errors={{this.getFieldErrors changeset 'country'}}
      @hasSubmitted={{this.hasSubmitted}}
      as |option|
    >
      {{option}}
    </FormSelect>

    <Button @type='submit'>Save</Button>
  </form>
{{/let}}
```

### Step 3: Component Class Logic

```js
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { FormInput, FormTextarea, FormSelect } from '@frontile/forms-legacy';

export default class MyFormComponent extends Component {
  @tracked hasSubmitted = false;

  // Your existing validation rules
  validations = {
    firstName: validatePresence(true),
    comments: validateLength({ min: 10 }),
    country: validatePresence(true)
  };

  @action
  updateField(changeset, fieldName, value) {
    changeset.set(fieldName, value);
  }

  @action
  updateSelect(changeset, fieldName, selectedValue) {
    changeset.set(fieldName, selectedValue);
  }

  @action
  async handleSubmit(changeset, event) {
    event.preventDefault();
    await changeset.validate();

    this.hasSubmitted = true;

    if (changeset.isInvalid) {
      return;
    }

    try {
      await changeset.save({});
      // Handle success
    } catch (error) {
      // Handle error
    }
  }

  getFieldErrors(changeset, fieldName) {
    const fieldErrors = changeset.errors.filter((error) => {
      return error.key === fieldName;
    });

    return fieldErrors.map((error) => error.validation).flat();
  }
}
```

### Step 4: Complete Migration to Forms-Legacy

For detailed component migration from changeset-form fields to forms-legacy components, refer to the [Forms Legacy Migration Guide](forms-legacy.md) for specific component mappings and API changes.

## Approach 2: Keep Changeset, Use Modern Forms

This approach combines your existing ember-changeset validation with the modern `@frontile/forms` components, giving you the best of both worlds.

### When to Choose This Approach

- You want modern form components with enhanced features
- Existing changeset validation logic is complex and working well
- Need advanced component features (slots, clearable, filtering)
- Want to modernize UI without rewriting validation

### Step 1: Install Modern Forms

```bash
npm uninstall @frontile/changeset-form
npm install @frontile/forms
# Keep: ember-changeset ember-changeset-validations
```

### Step 2: Modern Components with Changeset

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

#### After (changeset + modern forms)

```hbs
{{#let (changeset this.model this.validations) as |changeset|}}
  <form {{on 'submit' (fn this.handleSubmit changeset)}}>
    <div class='flex flex-col gap-4'>
      <Input
        @label='First Name'
        @value={{get changeset 'firstName'}}
        @onInput={{fn this.updateField changeset 'firstName'}}
        @errors={{this.getFieldErrors changeset 'firstName'}}
        @isInvalid={{this.hasFieldError changeset 'firstName'}}
        @isClearable={{true}}
      >
        <:startContent>
          <UserIcon />
        </:startContent>
      </Input>

      <Select
        @label='Country'
        @items={{this.countries}}
        @selectedKeys={{this.getSelectedCountries changeset}}
        @onSelectionChange={{fn this.updateCountrySelection changeset}}
        @errors={{this.getFieldErrors changeset 'country'}}
        @isInvalid={{this.hasFieldError changeset 'country'}}
        @selectionMode='multiple'
        @isFilterable={{true}}
        @isClearable={{true}}
      >
        <:item as |item|>
          <item.Item @key={{item.key}}>{{item.label}}</item.Item>
        </:item>
      </Select>

      {{! For single selection, use selectedKey instead }}
      {{!--
      <Select
        @label='Country'
        @items={{this.countries}}
        @selectedKey={{this.getSelectedCountry changeset}}
        @onSelectionChange={{fn this.updateSingleCountrySelection changeset}}
        @errors={{this.getFieldErrors changeset 'country'}}
        @isInvalid={{this.hasFieldError changeset 'country'}}
        @isFilterable={{true}}
        @isClearable={{true}}
      >
        <:item as |item|>
          <item.Item @key={{item.key}}>{{item.label}}</item.Item>
        </:item>
      </Select>
      --}}

      <Button @type='submit' disabled={{changeset.isInvalid}}>
        Save
      </Button>
    </div>
  </form>
{{/let}}
```

### Step 3: Component Class with Modern Forms + Changeset

```js
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Input, Select, Switch } from '@frontile/forms';
import { Button } from '@frontile/buttons';
import {
  validatePresence,
  validateLength
} from 'ember-changeset-validations/validators';

export default class ModernChangesetFormComponent extends Component {
  @tracked hasSubmitted = false;

  // Keep existing validation rules
  validations = {
    firstName: validatePresence(true),
    country: validatePresence(true)
  };

  countries = [
    { key: 'us', label: 'United States' },
    { key: 'ca', label: 'Canada' },
    { key: 'uk', label: 'United Kingdom' }
  ];

  skillOptions = [
    {
      key: 'js',
      label: 'JavaScript',
      color: 'yellow-500',
      description: 'Frontend & Backend'
    },
    {
      key: 'react',
      label: 'React',
      color: 'blue-500',
      description: 'UI Library'
    },
    {
      key: 'ember',
      label: 'Ember.js',
      color: 'orange-500',
      description: 'Web Framework'
    },
    {
      key: 'node',
      label: 'Node.js',
      color: 'green-500',
      description: 'Server Runtime'
    }
  ];

  @action
  updateField(changeset, fieldName, value) {
    changeset.set(fieldName, value);
    // Real-time validation
    changeset.validate(fieldName);
  }

  @action
  updateCountrySelection(changeset, selectedKeys) {
    // Convert array of keys back to format expected by changeset
    const countryObjects = this.countries.filter((country) =>
      selectedKeys.includes(country.key)
    );
    changeset.set('country', countryObjects);
    changeset.validate('country');
  }

  @action
  updateSingleCountrySelection(changeset, selectedKey) {
    // For single selection, find the single country object
    const countryObject = selectedKey
      ? this.countries.find((country) => country.key === selectedKey)
      : null;
    changeset.set('country', countryObject);
    changeset.validate('country');
  }

  @action
  async handleSubmit(changeset, event) {
    event.preventDefault();
    await changeset.validate();

    this.hasSubmitted = true;

    if (changeset.isInvalid) {
      return;
    }

    try {
      await changeset.save({});
      // Handle success
      console.log('Form submitted successfully:', changeset.data);
    } catch (error) {
      console.error('Submission failed:', error);
    }
  }

  getFieldErrors(changeset, fieldName) {
    if (!this.hasSubmitted && !changeset.get('isValidating')) {
      return [];
    }

    const fieldErrors = changeset.errors.filter((error) => {
      return error.key === fieldName;
    });

    return fieldErrors.map((error) => error.validation).flat();
  }

  hasFieldError(changeset, fieldName) {
    return this.getFieldErrors(changeset, fieldName).length > 0;
  }

  getSelectedCountries(changeset) {
    const countries = changeset.get('country') || [];
    return countries.map((country) => country.key || country);
  }

  getSelectedCountry(changeset) {
    const country = changeset.get('country');
    return country?.key || country || null;
  }

  // Additional helper methods for advanced example
  getSelectedSkills(changeset) {
    const skills = changeset.get('skills') || [];
    return skills.map((skill) => skill.key || skill);
  }

  @action
  updateSkillSelection(changeset, selectedKeys) {
    const skillObjects = this.skillOptions.filter((skill) =>
      selectedKeys.includes(skill.key)
    );
    changeset.set('skills', skillObjects);
    changeset.validate('skills');
  }
}
```

### Step 4: Advanced Modern Forms Features

You can now leverage advanced modern form features while keeping changeset validation:

```hbs
{{#let (changeset this.model this.validations) as |changeset|}}
  <form {{on 'submit' (fn this.handleSubmit changeset)}}>
    <div class='flex flex-col gap-4'>

      {{! Enhanced Input with slots and clearable }}
      <Input
        @label='Email Address'
        @type='email'
        @value={{get changeset 'email'}}
        @onInput={{fn this.updateField changeset 'email'}}
        @errors={{this.getFieldErrors changeset 'email'}}
        @isClearable={{true}}
        @description="We'll never share your email"
      >
        <:startContent>
          <EmailIcon />
        </:startContent>
        <:endContent>
          <Button @size='sm' @variant='subtle'>Verify</Button>
        </:endContent>
      </Input>

      {{! Advanced Select with filtering and custom rendering }}
      <Select
        @label='Skills'
        @items={{this.skillOptions}}
        @selectedKeys={{this.getSelectedSkills changeset}}
        @onSelectionChange={{fn this.updateSkillSelection changeset}}
        @errors={{this.getFieldErrors changeset 'skills'}}
        @selectionMode='multiple'
        @isFilterable={{true}}
        @placeholder='Search and select skills...'
        @popoverSize='lg'
      >
        <:startContent>
          <SearchIcon />
        </:startContent>
        <:item as |item|>
          <item.Item @key={{item.key}}>
            <div class='flex items-center gap-2'>
              <span class='w-3 h-3 rounded-full bg-{{item.color}}'></span>
              <div>
                <div class='font-medium'>{{item.label}}</div>
                <div class='text-sm text-gray-500'>{{item.description}}</div>
              </div>
            </div>
          </item.Item>
        </:item>
        <:emptyContent>
          <div class='text-center p-4'>
            No skills found. Try a different search term.
          </div>
        </:emptyContent>
      </Select>

      {{! Switch component (new, not in forms-legacy) }}
      <Switch
        @label='Enable notifications'
        @isSelected={{get changeset 'notifications'}}
        @onChange={{fn this.updateField changeset 'notifications'}}
        @description='Get updates about your applications'
      >
        <:startContent>
          <NotificationIcon />
        </:startContent>
      </Switch>
    </div>
  </form>
{{/let}}
```

### Benefits of This Approach

✅ **Keep Existing Validation**: No need to rewrite complex changeset validation rules  
✅ **Modern Components**: Get all the latest component features and improvements  
✅ **Enhanced UX**: Slots, clearable inputs, filtering, better accessibility  
✅ **Gradual Migration**: Can migrate one form at a time  
✅ **TypeScript Ready**: Better type support in modern components

### Considerations

⚠️ **Manual Binding**: Requires more boilerplate for data binding compared to Form component  
⚠️ **Validation Timing**: Need to manage when validation runs (real-time vs submit)  
⚠️ **Data Format Mapping**: May need to convert between component formats and changeset expectations

## Approach 3: Modern Forms with Valibot

This approach moves to the modern `@frontile/forms` package with Valibot validation.

### When to Choose This Approach

- Starting new features or components
- Want the most modern form experience
- Prefer TypeScript-first validation
- Don't have complex existing changeset logic

### Step 1: Install Dependencies

```bash
# Remove old packages
npm uninstall @frontile/changeset-form @frontile/forms-legacy
npm uninstall ember-changeset ember-changeset-validations

# Install new packages
npm install @frontile/forms valibot
```

### Step 2: Define Validation Schema

```js
import * as v from 'valibot';

// Define Valibot schema (replaces ember-changeset-validations)
const FormSchema = v.object({
  firstName: v.pipe(
    v.string(),
    v.nonEmpty('First name is required'),
    v.minLength(2, 'First name must be at least 2 characters')
  ),

  comments: v.pipe(
    v.string(),
    v.minLength(10, 'Comments must be at least 10 characters')
  ),

  country: v.pipe(
    v.array(v.string()),
    v.minLength(1, 'Please select a country')
  )
});
```

### Step 3: Modern Form Implementation

```hbs
<Form
  @onChange={{this.handleFormChange}}
  @onSubmit={{this.handleFormSubmit}}
>
  <div class='flex flex-col gap-4'>
    <Input
      @name='firstName'
      @label='First Name'
      @errors={{this.errors.firstName}}
      @isRequired={{true}}
    />

    <Textarea
      @name='comments'
      @label='Comments'
      @description='Tell us about your experience'
      @errors={{this.errors.comments}}
      rows='4'
    />

    <Select
      @name='country'
      @label='Country'
      @items={{this.countries}}
      @selectedKey={{this.selectedCountry}}
      @onSelectionChange={{this.setSelectedCountry}}
      @errors={{this.errors.country}}
      @isFilterable={{true}}
      @placeholder='Select your country'
    >
      <:item as |item|>
        <item.Item @key={{item.key}}>{{item.label}}</item.Item>
      </:item>
    </Select>

    <Button @type='submit' disabled={{this.isSubmitting}}>
      {{if this.isSubmitting 'Saving...' 'Save'}}
    </Button>
  </div>
</Form>
```

### Step 4: Component Class with Valibot

```js
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, Input, Textarea, Select, Checkbox, type FormResultData } from '@frontile/forms';
import { Button } from '@frontile/buttons';
import * as v from 'valibot';

export default class MyFormComponent extends Component {
  @tracked formData = {};
  @tracked errors = {};
  @tracked isSubmitting = false;
  @tracked selectedCountry = null;

  countries = [
    { key: 'us', label: 'United States' },
    { key: 'ca', label: 'Canada' },
    { key: 'uk', label: 'United Kingdom' }
  ];

  // Valibot schema (replaces changeset validations)
  FormSchema = v.object({
    firstName: v.pipe(
      v.string(),
      v.nonEmpty('First name is required'),
      v.minLength(2, 'First name must be at least 2 characters')
    ),
    comments: v.pipe(
      v.string(),
      v.minLength(10, 'Comments must be at least 10 characters')
    ),
    country: v.pipe(
      v.string(),
      v.nonEmpty('Please select a country')
    )
  });

  handleFormChange = (data: FormResultData, event: Event) => {
    this.formData = data;
    // Real-time validation
    this.validateForm(data);
  };

  validateForm = (data: FormResultData) => {
    const validationData = {
      ...data,
      country: this.selectedCountry
    };

    // Try to parse the entire form, but only clear errors for valid fields
    try {
      v.parse(this.FormSchema, validationData);
      // If validation passes completely, clear all errors
      this.errors = {};
    } catch (error) {
      if (error instanceof v.ValiError) {
        // Keep existing errors, but clear errors for fields that are now valid
        const newErrors = { ...this.errors };
        const invalidFields = new Set(
          error.issues.map((issue) => issue.path?.[0]?.key).filter(Boolean)
        );

        // Clear errors for fields that are no longer invalid
        Object.keys(newErrors).forEach((field) => {
          if (!invalidFields.has(field)) {
            delete newErrors[field];
          }
        });

        this.errors = newErrors;
      }
    }
  };

  handleFormSubmit = async (data: FormResultData, event: SubmitEvent) => {
    this.isSubmitting = true;
    this.errors = {};

    const validationData = {
      ...data,
      country: this.selectedCountry
    };

    try {
      const validatedData = v.parse(this.FormSchema, validationData);

      // Your API call logic here
      await this.saveData(validatedData);

      // Handle success
      console.log('Form submitted successfully:', validatedData);

    } catch (error) {
      if (error instanceof v.ValiError) {
        this.errors = this.formatValiError(error);
      } else {
        // Handle API errors
        console.error('Submission failed:', error);
      }
    } finally {
      this.isSubmitting = false;
    }
  };

  formatValiError(valiError: v.ValiError) {
    const errors = {};

    for (const issue of valiError.issues) {
      const path = issue.path?.[0]?.key;
      if (path) {
        if (!errors[path]) {
          errors[path] = [];
        }
        errors[path].push(issue.message);
      }
    }

    return errors;
  }

  setSelectedCountry = (key: string | null) => {
    this.selectedCountry = key;
    // Clear country errors when selection is made
    if (key && this.errors.country) {
      const newErrors = { ...this.errors };
      delete newErrors.country;
      this.errors = newErrors;
    }
  };
}
```

## Decision Matrix

### Choose **Approach 1** (Changeset + Forms-Legacy) if

✅ You have existing complex changeset validation logic  
✅ Large codebase with many changeset dependencies  
✅ Team is experienced with ember-changeset  
✅ Need the most gradual migration strategy  
✅ Want minimal code changes initially

### Choose **Approach 2** (Changeset + Modern Forms) if

✅ Want modern component features while keeping changeset validation  
✅ Need advanced UI features (slots, filtering, clearable inputs)  
✅ Existing changeset validation is complex but components need modernization  
✅ Want better accessibility and UX without rewriting validation logic  
✅ Team is comfortable with some additional boilerplate

### Choose **Approach 3** (Valibot + Modern Forms) if

✅ Starting new features or greenfield projects  
✅ Want modern TypeScript-first validation  
✅ Prefer simpler, more direct validation  
✅ Want the latest component features with automatic data binding  
✅ Don't have complex existing changeset logic

## Migration Checklist

### Pre-Migration Planning

- [ ] Audit current changeset-form usage across codebase
- [ ] Identify complex validation rules and custom logic
- [ ] Choose migration approach based on project needs
- [ ] Plan migration order (start with simpler forms)

### Approach 1: Changeset + Forms-Legacy

- [ ] Remove `@frontile/changeset-form` dependency
- [ ] Install `@frontile/forms-legacy` if not present
- [ ] Convert ChangesetForm wrapper to direct changeset usage
- [ ] Implement manual changeset field binding
- [ ] Add form submission and validation handling
- [ ] Update imports to use forms-legacy components
- [ ] Refer to [Forms Legacy Migration Guide](forms-legacy.md) for component specifics
- [ ] Test all form validation scenarios

### Approach 2: Changeset + Modern Forms

- [ ] Remove `@frontile/changeset-form` dependency
- [ ] Install `@frontile/forms` (keep changeset dependencies)
- [ ] Convert ChangesetForm wrapper to direct changeset usage
- [ ] Implement manual changeset field binding with modern components
- [ ] Update component APIs to modern forms (see [Forms Legacy Migration Guide](forms-legacy.md))
- [ ] Add data format conversion helpers for Select components
- [ ] Implement real-time and submit validation with changeset
- [ ] Test advanced component features (slots, clearable, filtering)
- [ ] Verify error display and validation timing

### Approach 3: Modern Forms + Valibot

- [ ] Remove changeset dependencies
- [ ] Install `@frontile/forms` and `valibot`
- [ ] Convert changeset validations to Valibot schemas
- [ ] Replace changeset-form with Form component
- [ ] Update component APIs (see [Forms Legacy Migration Guide](forms-legacy.md))
- [ ] Implement Valibot validation logic
- [ ] Add error handling and state management
- [ ] Test real-time and submit validation
- [ ] Verify TypeScript integration

### Testing & Validation

- [ ] Test all form submission scenarios
- [ ] Verify validation error display
- [ ] Test real-time validation behavior
- [ ] Check accessibility compliance
- [ ] Validate data serialization
- [ ] Test edge cases and error states

### Post-Migration Cleanup

- [ ] Remove unused changeset-form imports
- [ ] Update TypeScript types if needed
- [ ] Clean up unused validation dependencies (if moving to Valibot)
- [ ] Update documentation and team guidelines

## Key Differences Summary

| Feature               | Changeset-Form              | Changeset + Legacy          | Changeset + Modern          | Modern + Valibot               |
| --------------------- | --------------------------- | --------------------------- | --------------------------- | ------------------------------ |
| **Validation**        | ember-changeset-validations | ember-changeset-validations | ember-changeset-validations | Valibot schemas                |
| **Components**        | Legacy (deprecated)         | Legacy (stable)             | Modern (latest)             | Modern (latest)                |
| **Data Binding**      | Automatic via wrapper       | Manual via changeset.set()  | Manual via changeset.set()  | Automatic via Form component   |
| **Error Handling**    | Built-in via hasSubmitted   | Manual error extraction     | Manual error extraction     | Built-in + Valibot integration |
| **Advanced Features** | None                        | Basic                       | Slots, clearable, filtering | Slots, clearable, filtering    |
| **TypeScript**        | Limited                     | Limited                     | Good                        | Excellent                      |
| **Bundle Size**       | Large                       | Medium                      | Medium-Large                | Small                          |
| **Performance**       | Good                        | Good                        | Good                        | Excellent                      |
| **Maintenance**       | Deprecated                  | Limited updates             | Active development          | Active development             |
| **Migration Effort**  | N/A                         | Medium                      | Medium-High                 | Low-Medium                     |

This migration guide provides three distinct paths for moving away from the deprecated changeset-form package:

1. **Gradual**: Keep changeset validation, use legacy components (lowest risk)
2. **Hybrid**: Keep changeset validation, upgrade to modern components (best of both worlds)
3. **Modern**: Full migration to Valibot validation and modern components (future-proof)

Choose the approach that best fits your project's needs, timeline, and team expertise.
