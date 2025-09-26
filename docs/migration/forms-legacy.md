# Migrating from Forms Legacy

This guide will help you migrate from the legacy `@frontile/forms-legacy` package to the modern `@frontile/forms` package. The new forms package provides improved developer experience, better accessibility, enhanced customization options, and reduced external dependencies.

## Overview

### What's New in @frontile/forms

- **Modern Component Architecture**: Clean API with improved TypeScript support
- **Enhanced Accessibility**: Better ARIA support and keyboard navigation
- **Flexible Customization**: Slot-based content insertion and CSS class customization
- **Reduced Dependencies**: No longer depends on ember-power-select or ember-basic-dropdown
- **New Components**: Form wrapper with automatic data extraction, Switch component
- **Improved Developer Experience**: Better error handling and validation integration

### Migration Effort

- **Low**: FormInput, FormTextarea, FormCheckbox, FormRadio (minor API changes)
- **Medium**: FormCheckboxGroup, FormRadioGroup (API restructuring)
- **High**: FormSelect (complete API redesign)

## Installation

```bash
# Remove the legacy package
npm uninstall @frontile/forms-legacy

# Install the new package
npm install @frontile/forms
```

Update your imports:

```js
// Before (forms-legacy)
import FormInput from '@frontile/forms-legacy/components/form-input';
import FormCheckbox from '@frontile/forms-legacy/components/form-checkbox';

// After (forms)
import { Input, Checkbox } from '@frontile/forms';
```

## Breaking Changes

### 1. Component Names

All component names have dropped the `Form` prefix:

- `FormInput` → `Input`
- `FormTextarea` → `Textarea`
- `FormCheckbox` → `Checkbox`
- etc.

### 2. Import Strategy

Changed from default imports to named imports from the package index.

### 3. Error Handling

The error handling approach has been simplified:

- Removed `hasSubmitted`, `hasError`, `showError` props
- Use `errors` and `isInvalid` for error states
- Automatic error display based on `errors` presence

### 4. Validation Integration

Better integration with form validation libraries through the new `Form` component.

### 5. CSS Classes

Theme classes have been updated - check `@frontile/theme` for new class names.

## Component Migration

### FormInput → Input

The Input component now supports start/end content slots and clearable functionality.

#### Before (forms-legacy)

```hbs
<FormInput
  @label='First Name'
  @value={{this.firstName}}
  @onInput={{this.setFirstName}}
  @errors={{this.validationErrors.firstName}}
  @hasSubmitted={{this.hasSubmitted}}
  @size='md'
  @hint='Enter your first name'
  @containerClass='custom-container'
  @inputClass='custom-input'
/>
```

#### After (forms)

```hbs
<Input
  @label='First Name'
  @value={{this.firstName}}
  @onInput={{this.setFirstName}}
  @errors={{this.validationErrors.firstName}}
  @size='md'
  @description='Enter your first name'
  @classes={{hash base='custom-container' input='custom-input'}}
  @isClearable={{true}}
>
  <:startContent>
    <SearchIcon />
  </:startContent>
  <:endContent>
    <Button @size='sm'>Go</Button>
  </:endContent>
</Input>
```

#### Key Changes

- ✅ `@hint` → `@description`
- ✅ `@containerClass` → `@classes={{hash base="..."}}`
- ✅ `@inputClass` → `@classes={{hash input="..."}}`
- ✅ Removed `@hasSubmitted`, `@hasError`, `@showError`
- ✅ Added `@isClearable` option
- ✅ Added `<:startContent>` and `<:endContent>` slots
- ✅ Added `@startContentPointerEvents` and `@endContentPointerEvents` for click handling

### FormTextarea → Textarea

Minimal changes required for textarea migration.

#### Before (forms-legacy)

```hbs
<FormTextarea
  @label='Description'
  @value={{this.description}}
  @onInput={{this.setDescription}}
  @errors={{this.validationErrors.description}}
  @hasSubmitted={{this.hasSubmitted}}
  @rows='4'
/>
```

#### After (forms)

```hbs
<Textarea
  @label='Description'
  @value={{this.description}}
  @onInput={{this.setDescription}}
  @errors={{this.validationErrors.description}}
  rows='4'
/>
```

#### Key Changes

- ✅ Move `@rows` to attributes (`rows="4"`)
- ✅ Removed error state props (`@hasSubmitted`, etc.)

### FormCheckbox → Checkbox

The Checkbox component now has better standalone usage and improved accessibility.

#### Before (forms-legacy)

```hbs
<FormCheckbox
  @label='I agree to the terms'
  @checked={{this.agreedToTerms}}
  @onChange={{this.setAgreedToTerms}}
  @errors={{this.validationErrors.terms}}
  @hasSubmitted={{this.hasSubmitted}}
/>
```

#### After (forms)

```hbs
<Checkbox
  @label='I agree to the terms'
  @checked={{this.agreedToTerms}}
  @onChange={{this.setAgreedToTerms}}
  @errors={{this.validationErrors.terms}}
/>
```

#### Key Changes

- ✅ **No change** - Still uses `@checked`
- ✅ Removed error state props (`@hasSubmitted`, etc.)

### FormCheckboxGroup → CheckboxGroup

CheckboxGroup now uses a component-as-block pattern instead of an items-based API.

#### Before (forms-legacy)

```hbs
<FormCheckboxGroup
  @label='Select your interests'
  @onChange={{this.setInterests}}
  @errors={{this.validationErrors.interests}}
  as |Checkbox|
>
  {{#each this.interestOptions as |option|}}
    <Checkbox
      @value={{option.value}}
      @checked={{this.isInterestSelected option.value}}
    >
      {{option.label}}
    </Checkbox>
  {{/each}}
</FormCheckboxGroup>
```

#### After (forms)

```hbs
<CheckboxGroup
  @label='Select your interests'
  @onChange={{this.setInterests}}
  @errors={{this.validationErrors.interests}}
  @name='interests'
  as |Checkbox|
>
  {{#each this.interestOptions as |option|}}
    <Checkbox
      @value={{option.value}}
      @checked={{this.isInterestSelected option.value}}
    >
      {{option.label}}
    </Checkbox>
  {{/each}}
</CheckboxGroup>
```

#### Key Changes

- ✅ **No change** - Still uses `@onChange`
- ✅ Add `@name` prop for shared name attribute
- ✅ Still uses block params, not items-based API
- ✅ CheckboxGroup provides shared onChange to child checkboxes
- ✅ Manual tracking of selected values still required

#### Data Management (No Change)

```js
// Tracking selected values (same pattern as before)
@tracked selectedInterests = [];

isInterestSelected(value) {
  return this.selectedInterests.includes(value);
}

setInterests = (value, isChecked) => {
  if (isChecked) {
    this.selectedInterests = [...this.selectedInterests, value];
  } else {
    this.selectedInterests = this.selectedInterests.filter(v => v !== value);
  }
};
```

### FormRadio → Radio

Minimal changes required for radio migration.

#### Before (forms-legacy)

```hbs
<FormRadio
  @name='plan'
  @value='premium'
  @checked={{this.selectedPlan}}
  @onChange={{this.setPlan}}
>
  Premium Plan
</FormRadio>
```

#### After (forms)

```hbs
<Radio
  @name='plan'
  @value='premium'
  @checkedValue={{this.selectedPlan}}
  @onChange={{this.setPlan}}
>
  Premium Plan
</Radio>
```

#### Key Changes

- ✅ `@checked` → `@checkedValue` (same concept, just renamed)
- ✅ Both expect the currently selected value, not a boolean
- ✅ Removed error state props (`@hasSubmitted`, etc.)

### FormRadioGroup → RadioGroup

RadioGroup now uses a component-as-block pattern instead of an items-based API.

#### Before (forms-legacy)

```hbs
<FormRadioGroup
  @label='Select a plan'
  @onChange={{this.setPlan}}
  @errors={{this.validationErrors.plan}}
  as |Radio|
>
  {{#each this.planOptions as |option|}}
    <Radio
      @value={{option.value}}
      @checked={{eq this.selectedPlan option.value}}
    >
      {{option.label}}
    </Radio>
  {{/each}}
</FormRadioGroup>
```

#### After (forms)

```hbs
<RadioGroup
  @label='Select a plan'
  @value={{this.selectedPlan}}
  @onChange={{this.setPlan}}
  @errors={{this.validationErrors.plan}}
  @name='plan'
  as |Radio|
>
  {{#each this.planOptions as |option|}}
    <Radio @value={{option.value}}>
      {{option.label}}
    </Radio>
  {{/each}}
</RadioGroup>
```

#### Key Changes

- ✅ **No change** - Still uses `@onChange`
- ✅ Uses `@value` for current selected value
- ✅ Add `@name` prop for shared name attribute
- ✅ Still uses block params, not items-based API
- ✅ RadioGroup automatically passes `@checkedValue` to child radios

### FormSelect → Select

This is the most significant change. The new Select component is completely rebuilt and no longer depends on ember-power-select.

#### Before (forms-legacy)

```hbs
<FormSelect
  @label='Select Country'
  @options={{this.countries}}
  @selected={{this.selectedCountry}}
  @onChange={{this.setCountry}}
  @searchEnabled={{true}}
  @searchField='name'
  @errors={{this.validationErrors.country}}
  @placeholder='Choose a country'
  as |country|
>
  {{country.name}}
</FormSelect>
```

#### After (forms)

```hbs
{{! Single selection mode (default) }}
<Select
  @label='Select Country'
  @items={{this.countries}}
  @selectedKey={{this.selectedCountryKey}}
  @onSelectionChange={{this.setCountry}}
  @isFilterable={{true}}
  @errors={{this.validationErrors.country}}
  @placeholder='Choose a country'
>
  <:item as |item|>
    <item.Item @key={{item.key}}>{{item.label}}</item.Item>
  </:item>
</Select>
```

#### Key Changes

- ✅ `@options` → `@items`
- ✅ `@selected` → `@selectedKey` (string | null for single selection)
- ✅ `@onChange` → `@onSelectionChange` (callback receives string | null for single selection)
- ✅ `@searchEnabled` → `@isFilterable`
- ✅ Removed `@searchField` (filtering works on label automatically)
- ✅ Use `<:item>` slot instead of block param
- ✅ Built-in filtering instead of external dependency

#### Data Format Migration

```js
// Before: Object-based selection
@tracked selectedCountry = null;
@tracked countries = [
  { id: 1, name: 'United States', code: 'US' },
  { id: 2, name: 'Canada', code: 'CA' }
];

setCountry = (country) => {
  this.selectedCountry = country;
};

// After: Key-based selection (single mode)
@tracked selectedCountryKey = null;
@tracked countries = [
  { key: 'us', label: 'United States', code: 'US' },
  { key: 'ca', label: 'Canada', code: 'CA' }
];

setCountry = (key) => {
  this.selectedCountryKey = key;
};

```

#### Multiple Selection

```hbs
{{! Multiple selection }}
<Select
  @selectionMode='multiple'
  @selectedKeys={{this.selectedCountryKeys}}
  @onSelectionChange={{this.setCountries}}
  @items={{this.countries}}
/>
```

```js
// Multiple selection data handling
@tracked selectedCountryKeys = [];

setCountries = (keys) => {
  this.selectedCountryKeys = keys; // receives array of strings
};
```

#### Advanced Select Features

```hbs
{{! Single selection with advanced features }}
<Select
  @items={{this.countries}}
  @selectedKey={{this.selectedKey}}
  @onSelectionChange={{this.onChange}}
  @isFilterable={{true}}
  @isClearable={{true}}
  @isLoading={{this.isLoading}}
  @filter={{this.customFilter}}
  @popoverSize='lg'
>
  <:startContent>
    <SearchIcon />
  </:startContent>
  <:item as |item|>
    <item.Item @key={{item.key}}>
      <div class='flex items-center gap-2'>
        <img src={{item.flag}} alt='' class='w-5 h-5' />
        {{item.label}}
      </div>
    </item.Item>
  </:item>
  <:emptyContent>
    <div class='text-center p-4'>
      No countries found matching your search.
    </div>
  </:emptyContent>
</Select>
```

```js
// Handler for single selection
onChange = (key) => {
  this.selectedKey = key; // receives string | null
};
```

## New Components

### Form Component

The new Form component provides automatic form data extraction and handling.

```hbs
<Form
  @onChange={{this.handleFormChange}}
  @onSubmit={{this.handleFormSubmit}}
>
  <Input @name='firstName' @label='First Name' />
  <Input @name='lastName' @label='Last Name' />
  <Textarea @name='bio' @label='Bio' />

  <button type='submit'>Save</button>
</Form>
```

```js
handleFormChange = (data) => {
  // data contains all form field values automatically
  this.formData = data;
  console.log('Realtime data:', data);
};

handleFormSubmit = (data) => {
  // Handle form submission
  console.log('Submitting:', data);
};
```

### Switch Component

A new toggle/switch component not available in forms-legacy.

```hbs
{{! Controlled mode }}
<Switch
  @label='Enable notifications'
  @isSelected={{this.notificationsEnabled}}
  @onChange={{this.setNotificationsEnabled}}
>
  <:startContent>
    <NotificationIcon />
  </:startContent>
</Switch>

{{! Uncontrolled mode }}
<Switch
  @label='Enable notifications'
  @defaultSelected={{false}}
  @onChange={{this.setNotificationsEnabled}}
>
  <:startContent>
    <NotificationIcon />
  </:startContent>
</Switch>
```

### NativeSelect Component

For simple dropdown needs without the complexity of the full Select component.

```hbs
<NativeSelect
  @label='Priority'
  @selectedKeys={{this.selectedPriority}}
  @onSelectionChange={{this.setPriority}}
  @items={{this.priorityOptions}}
>
  <:item as |item|>
    <item.Option @key={{item.key}}>{{item.label}}</item.Option>
  </:item>
</NativeSelect>
```

## Common Patterns

### Error Handling

```hbs
// Before: Multiple error state props
<FormInput
  @errors={{this.errors}}
  @hasSubmitted={{this.hasSubmitted}}
  @showError={{this.forceShowErrors}}
/>

// After: Simplified approach
<Input @errors={{this.errors}} @isInvalid={{this.hasErrors}} />
```

### Custom Styling

```hbs
{{! Before: Individual class props }}
<FormInput
  @containerClass='my-container'
  @inputClass='my-input'
  @labelClass='my-label'
/>

{{! After: Classes object }}
<Input
  @classes={{hash base='my-container' input='my-input' label='my-label'}}
/>
```

### Form Validation Integration

```js
// Using a validation library like ember-changeset-validations
export default class MyFormComponent extends Component {
  @tracked formData = {};
  @tracked errors = {};

  handleFormChange = (data) => {
    this.formData = data;
    // Run validation
    this.errors = this.validateForm(data);
  };

  handleSubmit = async (data) => {
    const errors = this.validateForm(data);
    if (Object.keys(errors).length === 0) {
      await this.saveForm(data);
    } else {
      this.errors = errors;
    }
  };
}
```

### Complex Form Layout

```hbs
<Form @onChange={{this.handleFormChange}}>
  <div class='grid grid-cols-2 gap-4'>
    <Input @name='firstName' @label='First Name' />
    <Input @name='lastName' @label='Last Name' />
  </div>

  <Input @name='email' @label='Email' @type='email' @isClearable={{true}}>
    <:startContent><EmailIcon /></:startContent>
  </Input>

  <Select
    @name='country'
    @label='Country'
    @items={{this.countries}}
    @isFilterable={{true}}
  >
    <:item as |item|>
      <item.Item @key={{item.key}}>{{item.label}}</item.Item>
    </:item>
  </Select>

  <CheckboxGroup
    @name='interests'
    @label='Interests'
    @onChange={{this.setInterests}}
    as |Checkbox|
  >
    {{#each this.interestOptions as |option|}}
      <Checkbox
        @value={{option.value}}
        @checked={{this.isInterestSelected option.value}}
      >
        {{option.label}}
      </Checkbox>
    {{/each}}
  </CheckboxGroup>
</Form>
```

## Migration Checklist

### Pre-Migration

- [ ] Review current form implementations
- [ ] Update `@frontile/theme` to compatible version
- [ ] Plan Select component migrations carefully (highest effort)

### Package Changes

- [ ] Uninstall `@frontile/forms-legacy`
- [ ] Install `@frontile/forms`
- [ ] Update imports to use named imports

### Component Updates

- [ ] Rename all `Form*` components (drop `Form` prefix)
- [ ] Update error handling props (`hasSubmitted`, `hasError`, etc.)
- [ ] Migrate `@hint` to `@description`
- [ ] Update CSS class props to `@classes` object
- [ ] **Radio components**: Rename `@checked` to `@checkedValue` (same value, just renamed prop)
- [ ] **Checkbox components**: No change needed - still uses `@checked`

### FormSelect Migration (Complex)

- [ ] Convert data format (add `key` and `label` properties)
- [ ] Update `@selected` to `@selectedKeys` array
- [ ] Replace `@onChange` with `@onSelectionChange`
- [ ] Update template to use `<:item>` slot
- [ ] Test filtering behavior
- [ ] Handle multiple selection if needed

### Group Components (CheckboxGroup/RadioGroup)

- [ ] **CheckboxGroup**: Minimal changes - still uses block params and `@onChange`
- [ ] **RadioGroup**: Uses `@value` for current selected value, still uses block params
- [ ] Add `@name` prop to group components

### Testing

- [ ] Test all form interactions
- [ ] Verify error states display correctly
- [ ] Test keyboard navigation and accessibility
- [ ] Validate form submission with new data formats

### Optional Enhancements

- [ ] Add `@isClearable` to appropriate inputs
- [ ] Use start/end content slots for icons or buttons
- [ ] Implement new `Form` component for automatic data extraction
- [ ] Consider using `Switch` component where appropriate

This migration guide covers all the essential changes needed to move from `@frontile/forms-legacy` to `@frontile/forms`. While some components require significant changes (especially FormSelect), the new package provides a much improved developer experience with better accessibility, flexibility, and maintainability.
