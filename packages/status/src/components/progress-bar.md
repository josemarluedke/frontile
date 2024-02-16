---
label: New
---

# ProgressBar

ProgressBars shows visually the progression of a process or task

## Import

```js
import { ProgressBar } from '@frontile/status';
```

## Usage

```gjs preview
import { ProgressBar } from '@frontile/status';

<template>
  <ProgressBar @progress={{50}} @label='Progress' />
</template>
```

## ProgressBar Intents

```gjs preview
import { ProgressBar } from '@frontile/status';

<template>
  <div class='grid grid-cols-5 gap-4'>
    <ProgressBar @progress={{50}} @label='Default' @showValueLabel={{false}} />
    <ProgressBar
      @progress={{50}}
      @label='Primary'
      @intent='primary'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @label='Success'
      @intent='success'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @label='Warning'
      @intent='warning'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @label='Danger'
      @intent='danger'
      @showValueLabel={{false}}
    />
  </div>
</template>
```

## ProgressBar Sizes

```gjs preview
import { ProgressBar } from '@frontile/status';

<template>
  <div class='mt-6 grid grid-cols-4 gap-4 items-center'>
    <ProgressBar
      @progress={{50}}
      @size='xs'
      @label='XSmall'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @size='sm'
      @label='Small'
      @showValueLabel={{false}}
    />
    <ProgressBar @progress={{50}} @label='Normal' @showValueLabel={{false}} />
    <ProgressBar
      @progress={{50}}
      @size='lg'
      @label='Large'
      @showValueLabel={{false}}
    />
  </div>
</template>
```

## ProgressBar Radius

```gjs preview
import { ProgressBar } from '@frontile/status';

<template>
  <div class='mt-6 grid grid-cols-4 gap-4'>
    <ProgressBar
      @size='lg'
      @progress={{50}}
      @radius='none'
      @label='None'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @size='lg'
      @progress={{50}}
      @radius='sm'
      @label='Small'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @size='lg'
      @progress={{50}}
      @radius='lg'
      @label='Large'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @size='lg'
      @progress={{50}}
      @radius='full'
      @label='Full'
      @showValueLabel={{false}}
    />
  </div>
</template>
```

## ProgressBar Labels

```gjs preview
import { ProgressBar } from '@frontile/status';
import { hash } from '@ember/helper';

<template>
  <div class='mt-6 grid grid-cols-2 gap-4 items-end'>
    <ProgressBar @progress={{50}} @label='With label' />
    <ProgressBar
      @progress={{50}}
      @label='Hiding label value'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @label='Custom label value'
      @valueLabel='4 out of 8'
    />
    <ProgressBar
      @progress={{50}}
      @label='Custom formatter'
      @formatOptions={{(hash style='currency' currency='USD')}}
    />
  </div>
</template>
```

## Indeterminate

You can pass the argument `@isIndeterminate` to represent when the effort or duration can not be calculated

```gjs preview
import { ProgressBar } from '@frontile/status';

<template>
  <ProgressBar @size='md' @label='Progress' @isIndeterminate={{true}} />
</template>
```

Note that here we used the HTML attribute `class`, instead of the argument `@class`.
Using the class attribute will just append the class names passed in, while the
argument `@class` will override and merge TailwindCSS class names.

## API

<Signature @package="status" @component="ProgressBar" />
