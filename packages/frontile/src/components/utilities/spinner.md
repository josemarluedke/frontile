---
imports:
  - import Signature from 'site/components/signature';
---

# Spinner

Indicate loading state in your components, offering a smooth, animated visual cue that operations are in progress.

## Import

```js
import { Spinner } from 'frontile';
```

## Usage

```gts preview
import { Spinner } from 'frontile';

<template><Spinner /></template>
```

## Sizes

The size option allows you to control the size of the Spinner. The available sizes
are: `xs`, `sm`, `md`, `lg`, and `xl`. This makes it easy to integrate the
Spinner into different areas of your UI, whether you need a small indicator for
a button or a large one for page loading.

```gts preview
import { Spinner } from 'frontile';

<template>
  <div class='flex items-center space-x-2'>
    <Spinner @size='xs' />
    <Spinner @size='sm' />
    <Spinner @size='md' />
    <Spinner @size='lg' />
    <Spinner @size='xl' />
  </div>
</template>
```

## Intents

The intent option changes the Spinner's color to match common UI patterns, such
as `primary` actions, `success` states, `warnings`, and `danger` actions.

```gts preview
import { Spinner } from 'frontile';

<template>
  <div class='flex items-center space-x-2'>
    <Spinner @intent='default' />
    <Spinner @intent='primary' />
    <Spinner @intent='secondary' />
    <Spinner @intent='tertiary' />
    <Spinner @intent='success' />
    <Spinner @intent='warning' />
    <Spinner @intent='danger' />
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
import { Spinner } from 'frontile';

<template>
  <div class='flex items-center justify-center'>
    <Spinner
      @class='h-24 w-24 fill-purple-500 text-teal-300 dark:fill-purple-300 dark:text-teal-800'
    />
  </div>
</template>
```

## Accessibility

The spinner is `aria-hidden` by default, and deliberately so: it is a picture of
a state, not the state itself. An unhidden, unnamed `<svg>` is announced as an
image with no name, which tells a screen reader user nothing — and naming the
graphic ("Loading spinner") describes the decoration rather than saying that the
content they asked for is on its way.

Put the state on the thing that is loading. `aria-busy` marks the region, and a
polite live region announces the transition once:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Button, Spinner } from 'frontile';

export default class Example extends Component {
  @tracked isLoading = false;
  @tracked rows: string[] = [];

  load = async () => {
    this.isLoading = true;
    this.rows = [];
    await new Promise((resolve) => setTimeout(resolve, 1500));
    this.rows = ['Fiber route A', 'Fiber route B', 'Fiber route C'];
    this.isLoading = false;
  };

  <template>
    <div class='flex flex-col gap-3'>
      <Button @intent='primary' @onPress={{this.load}}>Load routes</Button>

      <div
        aria-busy={{if this.isLoading 'true' 'false'}}
        aria-live='polite'
        class='border-neutral-soft rounded border p-4'
      >
        {{#if this.isLoading}}
          <span class='flex items-center gap-2'>
            <Spinner @size='sm' @intent='primary' />
            Loading routes…
          </span>
        {{else if this.rows}}
          <ul class='not-prose'>
            {{#each this.rows as |row|}}
              <li>{{row}}</li>
            {{/each}}
          </ul>
        {{else}}
          <p class='text-neutral'>No routes loaded yet.</p>
        {{/if}}
      </div>
    </div>
  </template>
}
```

The visible "Loading routes…" text is what carries the meaning here — the spinner
beside it is redundant by design, which is exactly what makes hiding it correct.

A spinner with no adjacent text needs the text supplied some other way, or the
wait is silent. `VisuallyHidden` is the usual answer for a button that swaps its
label for a spinner:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Button, Spinner, VisuallyHidden } from 'frontile';

export default class Example extends Component {
  @tracked isSaving = false;

  save = async () => {
    this.isSaving = true;
    await new Promise((resolve) => setTimeout(resolve, 1500));
    this.isSaving = false;
  };

  <template>
    <Button @intent='primary' @onPress={{this.save}} disabled={{this.isSaving}}>
      {{#if this.isSaving}}
        <Spinner @size='sm' />
        <VisuallyHidden>Saving, please wait</VisuallyHidden>
      {{else}}
        Save
      {{/if}}
    </Button>
  </template>
}
```

If you genuinely need the graphic itself announced — a full-page loader with
nothing else on screen — pass your own attributes, which are applied after the
default and so win:

```gts preview
import { Spinner } from 'frontile';

<template>
  <Spinner @size='xl' aria-hidden='false' role='status' aria-label='Loading' />
</template>
```

Motion is the other consideration, and worth knowing precisely: the theme applies
`animate-spin` with **no** `motion-reduce` variant, so the spinner keeps turning
for users who have asked for reduced motion. That is a deliberate trade — a
stopped spinner conveys nothing at all — but if your product treats the
preference as absolute, suppress it yourself:

```gts preview
import { Spinner } from 'frontile';

<template>
  <Spinner @intent='primary' @class='motion-reduce:animate-none' />
</template>
```

Which is another reason not to let a spinner be the only sign that something is
happening: the text beside it keeps working when the animation does not.

## API

<Signature @component="Spinner" />
