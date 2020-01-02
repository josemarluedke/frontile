# `<FormSelect>`

## Single select

We use [Ember Power Select](https://github.com/cibernox/ember-power-select/)
under the hood to deliver the best select experience. Please refer to their
documentation to further customization.

In the example below, we have a label, hint, error validation, search and `allowClear`.

<Demo::Forms::FormSelect::Single />

## Multiple select

In the example below you can select multiple options. To enable multiple
select, just pass `@isMultiple={{true}}` to the component.

<Demo::Forms::FormSelect::Multiple />
