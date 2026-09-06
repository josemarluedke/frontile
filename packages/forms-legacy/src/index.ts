import { deprecate } from '@ember/debug';

deprecate(
  'The "@frontile/forms-legacy" package is deprecated and will be removed in 0.19.0. ' +
    'Migrate to the modern "frontile" forms instead. ' +
    'See https://frontile.dev/docs/migrations/forms-legacy',
  false,
  {
    id: 'frontile.forms-legacy',
    until: '0.19.0',
    for: 'frontile',
    since: { available: '0.18.0', enabled: '0.18.0' },
    url: 'https://frontile.dev/docs/migrations/forms-legacy'
  }
);

export { default as FormInput } from './components/form-input';
export { default as FormCheckbox } from './components/form-checkbox';
export { default as FormCheckboxGroup } from './components/form-checkbox-group';
export { default as FormRadio } from './components/form-radio';
export { default as FormRadioGroup } from './components/form-radio-group';
export { default as FormSelect } from './components/form-select';
export { default as FormTextarea } from './components/form-textarea';
export { default as FormField } from './components/form-field';
