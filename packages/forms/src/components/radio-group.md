---
label: New
---
# Radio Group

`RadioGroup` groups multiple `Radio` components allowing the user to pick a
single value.

## Import 

```js
import { RadioGroup } from '@frontile/forms';
```

## Usage

```gts preview
import { RadioGroup } from '@frontile/forms';

<template>
  <RadioGroup @label='Interests' as |R|>
    <R.Radio @label='Music' @value='music' />
    <R.Radio @label='IoT' @value='iot' />
  </RadioGroup>
</template>
```

## API

<Signature @package="forms" @component="RadioGroup" />
