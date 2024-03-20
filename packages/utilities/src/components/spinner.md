---
label: New
---
# Spinner

Indicate loading state in your components, offering a smooth, animated visual cue that operations are in progress.

## Import 
```js
import { Spinner } from '@frontile/utilities';
```

## Usage

```gts preview
import { Spinner } from '@frontile/utilities';

<template>
  <Spinner />
</template>
```

## Sizes

The size option allows you to control the size of the Spinner. The available sizes 
are: `xs`, `sm`, `md`, `lg`, and `xl`. This makes it easy to integrate the 
Spinner into different areas of your UI, whether you need a small indicator for 
a button or a large one for page loading.

```gts preview
import { Spinner } from '@frontile/utilities';

<template>
  <div class="flex items-center space-x-2">
    <Spinner @size="xs" />
    <Spinner @size="sm" />
    <Spinner @size="md" />
    <Spinner @size="lg" />
    <Spinner @size="xl" />
  </div>
</template>
```
## Intents

The intent option changes the Spinner's color to match common UI patterns, such 
as `primary` actions, `success` states, `warnings`, and `danger` actions.

```gts preview
import { Spinner } from '@frontile/utilities';

<template>
  <div class="flex items-center space-x-2">
    <Spinner @intent="default" />
    <Spinner @intent="primary" />
    <Spinner @intent="success" />
    <Spinner @intent="warning" />
    <Spinner @intent="danger" />
  </div>
</template>
```

## Style Customization

You can further customize the Spinner by adding your own CSS classes using the 
`class` argument. This is particularly useful overwriting styles that does not 
work for your use case. You can also overwrite the colors using 
`fill-{*}` classes to modify the highlighted color and `text-{*}` classes to 
modify the background.

```gts preview
import { Spinner } from '@frontile/utilities';

<template>
  <div class="flex items-center justify-center">
    <Spinner 
      @class="h-24 w-24 fill-purple-500 text-teal-300 dark:fill-purple-300 dark:text-teal-800"
    />
  </div>
</template>
```

## API

<Signature @package="utilities" @component="Spinner" />
