---
label: New
---
# Checkbox Group

`CheckboxGroup` renders a label and arranges a set of `Checkbox` components.
It manages each checkbox value individually and can display error messages
like other form controls.

## Import 

```js
import { CheckboxGroup } from '@frontile/forms';
```

## Usage

```gts preview
import { CheckboxGroup } from '@frontile/forms';

<template>
  <CheckboxGroup @label='Interests' as |C|>
    <C.Checkbox @label='Music' />
    <C.Checkbox @label='IoT' />
  </CheckboxGroup>
</template>
```

## API

<Signature @package="forms" @component="CheckboxGroup" />
