---
label: New
---
# Form

`Form` collects values from its form controls and passes them to callbacks for
`onChange` and `onSubmit` events.

## Import 

```js
import { Form } from '@frontile/forms';
```

## Usage

```gts preview
import { Form, Input } from '@frontile/forms';

<template>
  <Form @onChange={{fn (data) (console.log data)}}>
    <Input @name='firstName' />
    <button type='submit'>Submit</button>
  </Form>
</template>
```

## API

<Signature @package="forms" @component="Form" />
