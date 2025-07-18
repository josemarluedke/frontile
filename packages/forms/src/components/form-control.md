---
label: New
---
# FormControl

Wrapper component that wires a label, description and feedback around a form
field. It yields helpers for generating accessible IDs.

## Import
```js
import { FormControl } from '@frontile/forms';
```

## Usage
```gts preview
import { FormControl, Input } from '@frontile/forms';

<template>
  <FormControl @label='Email' as |fc|>
    <Input
      id={{fc.id}}
      aria-describedby={{fc.describedBy(true, true)}}
      @isInvalid={{fc.isInvalid}}
    />
    <fc.Description id='email-desc'>We'll never share it.</fc.Description>
    <fc.Feedback @messages='Invalid email' />
  </FormControl>
</template>
```

## API

<Signature @package="forms" @component="FormControl" />
