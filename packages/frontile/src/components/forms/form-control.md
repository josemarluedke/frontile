---
imports:
  - import Signature from 'site/components/signature';
---

# FormControl

FormControl provides the label, description and error feedback that surround a form
control, and the ids that tie them together for assistive technology. Reach for it when
you need a field Frontile doesn't ship — a file picker, a range slider, a third-party
date picker — and want it to look and announce itself like `Input`, `Select` and
`Checkbox`, which are all built on it.

## Import

```js
import { FormControl } from 'frontile';
```

## Usage

Pass `@label` and give the wrapped control the yielded `id`. That single wiring is what
associates the rendered `<label>` with your control.

```gts preview
import { FormControl } from 'frontile';

<template>
  <FormControl @label='Attachment' as |c|>
    <input
      type='file'
      id={{c.id}}
      class='text-neutral-strong font-body text-base'
    />
  </FormControl>
</template>
```

## Description and Errors

`@description` renders help text above the control and `@errors` renders messages below
it. Neither is connected to the control on its own: the block is responsible for the
ARIA, using the two values FormControl yields for exactly that.

- `c.describedBy` takes two flags — whether there is a description, and whether there is
  feedback — and returns the matching ids for `aria-describedby`.
- `c.isInvalid` is true when `@isInvalid` is set or `@errors` is non-empty, and is what
  you put on `aria-invalid`.

```gts preview
import { FormControl } from 'frontile';

<template>
  <FormControl
    @label='Budget'
    @description='Whole dollars, no separators.'
    @errors='Enter an amount above 0'
    as |c|
  >
    <input
      type='number'
      id={{c.id}}
      value='0'
      aria-invalid={{if c.isInvalid 'true'}}
      aria-describedby={{c.describedBy true c.isInvalid}}
      class='bg-surface-input text-neutral-strong border-neutral-soft aria-invalid:border-danger-soft focus:ring-focus w-full rounded-xl border p-3 leading-tight focus:ring-3 focus:outline-hidden'
    />
  </FormControl>
</template>
```

## Placing the Parts Yourself

The default order — label, description, control, feedback — is what you get from the
string arguments. When a control needs a different order, such as a checkbox whose label
sits after it, use the yielded `Label`, `Description` and `Feedback` components instead
and drop the corresponding argument. They arrive with `for`, `id`, `size` and (for
`Feedback`) the error messages already bound.

`@preventErrorFeedback` suppresses the automatic feedback at the bottom so `c.Feedback`
is the only copy rendered.

Either way, FormControl also renders a visually hidden `aria-live='assertive'` region that
is always in the DOM and holds the error messages when there are any. That region is what
screen readers announce, so the visible `FormFeedback` inside a FormControl is rendered with
`@announce={{false}}` and the message is not announced twice. `@preventErrorFeedback` does
not remove the live region.

Because that region only ever carries the `@errors` text, `c.Feedback` with its own block
content announces nothing. When you render custom content there and want it announced, turn
announcing back on for that invocation with `@announce={{true}}` — an argument passed at the
invocation site wins over the one FormControl bound.

```gts preview
import { FormControl } from 'frontile';

<template>
  <FormControl
    @errors='Accept the terms to continue'
    @preventErrorFeedback={{true}}
    as |c|
  >
    <c.Feedback />
    <div class='flex items-center gap-2'>
      <input
        type='checkbox'
        id={{c.id}}
        aria-invalid={{if c.isInvalid 'true'}}
        aria-describedby={{c.describedBy false c.isInvalid}}
      />
      <c.Label>I accept the terms</c.Label>
    </div>
  </FormControl>
</template>
```

When the label itself needs markup rather than a plain string, use the `:label` block —
it renders inside the same `<label>` element that `@label` would have produced.

```gts preview
import { FormControl } from 'frontile';

<template>
  <FormControl @isRequired={{true}}>
    <:label>
      API token
      <a href='#docs' class='text-primary underline'>Where do I find this?</a>
    </:label>
    <:default as |c|>
      <input
        id={{c.id}}
        required
        class='bg-surface-input text-neutral-strong border-neutral-soft focus:ring-focus w-full rounded-xl border p-3 leading-tight focus:ring-3 focus:outline-hidden'
      />
    </:default>
  </FormControl>
</template>
```

`:description` works the same way, for help text that needs a link or inline markup. It
renders inside the same description element that `@description` would have produced, so
`c.describedBy` still points the control at it.

```gts preview
import { FormControl } from 'frontile';

<template>
  <FormControl @label='Webhook URL'>
    <:description>
      Must be publicly reachable over HTTPS.
      <a href='#docs' class='text-primary underline'>Read the requirements</a>
    </:description>
    <:default as |c|>
      <input
        id={{c.id}}
        aria-describedby={{c.describedBy true false}}
        class='bg-surface-input text-neutral-strong border-neutral-soft focus:ring-focus w-full rounded-xl border p-3 leading-tight focus:ring-3 focus:outline-hidden'
      />
    </:default>
  </FormControl>
</template>
```

## Sizes

`@size` scales the label, description and feedback text. It does not touch the control
inside the block — size that yourself so the two stay in proportion.

```gts preview
import { array } from '@ember/helper';
import { FormControl } from 'frontile';

<template>
  <div class='flex flex-col gap-6'>
    {{#each (array 'sm' 'md' 'lg') as |size|}}
      <FormControl
        @size={{size}}
        @label='Team name'
        @description='Shown to everyone in the workspace.'
        @errors='This name is taken'
        as |c|
      >
        <input
          id={{c.id}}
          value='Platform'
          aria-invalid='true'
          aria-describedby={{c.describedBy true true}}
          class='bg-surface-input text-neutral-strong border-neutral-soft aria-invalid:border-danger-soft focus:ring-focus w-full rounded-xl border p-3 leading-tight focus:ring-3 focus:outline-hidden'
        />
      </FormControl>
    {{/each}}
  </div>
</template>
```

## Accessibility

FormControl renders a plain `<div>` and has no keyboard behavior of its own — the control
you place inside it keeps whatever behavior it already had. What FormControl does is hand
you the pieces needed to describe that control correctly, and it is the block's job to
apply them:

| Yielded value   | Where it goes                                                                                 |
| --------------- | --------------------------------------------------------------------------------------------- |
| `c.id`          | The control's `id`. The rendered `<label>` already points at it with `for`                    |
| `c.isInvalid`   | `aria-invalid` on the control                                                                 |
| `c.describedBy` | `aria-describedby` on the control, called with whether a description and feedback are present |

Notes worth knowing before you rely on it:

- **Required is visual.** `@isRequired` adds an asterisk to the label. Set `required` or
  `aria-required` on the control yourself.
- **Disabled is visual.** `@isDisabled` is passed through for styling only; the control
  owns its own `disabled` attribute.
- **Error feedback is announced.** The feedback element carries `aria-live`, assertive at
  the default `danger` intent and polite otherwise, so messages appearing after the
  initial render are read out.
- **It groups nothing.** There is no `role='group'` and the label's `for` can only point
  at one control, so wrapping several inputs in a single FormControl leaves them
  unlabelled. Use `CheckboxGroup` or `RadioGroup`, or add `role='group'` and
  `aria-labelledby` yourself.

## API

<Signature @component="FormControl" />

<Signature @component="Label" />

<Signature @component="FormDescription" />

<Signature @component="FormFeedback" />
